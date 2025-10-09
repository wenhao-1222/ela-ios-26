//
//  ForumDetailVC.swift
//  lns
//
//  Created by Elavatine on 2024/11/1.
//

@preconcurrency import WebKit
import AVFoundation
import IQKeyboardManagerSwift
import MJRefresh
import MCToast
import Photos

enum ScriptMessageName {
    case scan //
    
    var name: String {
        switch self {
        case .scan:
            return "scan"
        }
    }
}

class ForumDetailVC: WHBaseViewVC {
    
    var model = ForumModel()
    
//    let config = WKWebViewConfiguration()
    var wkWebView : WKWebView!
    var bridge = WKWebViewJavascriptBridge()
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var progressView = UIProgressView()
    let h5TitleLabel = UILabel()
    
    var thumbBlock:((ForumModel)->())?
    var isToComment = false
    
    var webViewHeight = kFitWidth(0)
    var commenListHeight = kFitWidth(0)
    
    ///站内信跳转进来的时候，查询评论列表，需要传参
    var commentId = ""
    ///站内信跳转进来的时候，查询评论列表，需要传参
    var replyId = ""
    var commentDeleteString = ""
    var isCommentScroll = false
    
    var webViewisLoad = false
    var commentCellFrame = CGRect()
    var oldOffsetY = CGFloat(0)
    
    var list: [HeroBrowserViewModule] = []
    
    private let canGoBackKeyPath = "canGoBack"
    
    override func viewDidAppear(_ animated: Bool) {
        UserConfigModel.shared.canPushForumDetail = true
//        self.navigationController?.fd_interactivePopDisabled = false
//        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
    }
    override func viewDidDisappear(_ animated: Bool) {
//        self.navigationController?.fd_interactivePopDisabled = true
//        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        
        wkWebView.removeFromSuperview()
        wkWebView = nil
        IQKeyboardManager.shared.enable = true
    }
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openInteractivePopGesture()
        initUI()
        commenListHeight = SCREEN_HEIGHT-naviVm.selfHeight-bottomFuncVm.selfHeight
        self.updateThumbStatus()
        self.updateCommentCount()

        sendForumDetailRequest()
        if commentDeleteString.count > 0{
            MCToast.mc_text("\(commentDeleteString)")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    lazy var naviVm: ForumNaviVM = {
        let vm = ForumNaviVM.init(frame: .zero)
        vm.updateUI(model: self.model)
        vm.backArrowButton.tapBlock = {()in
            self.backTapAction()
        }
        vm.shareBlock = {()in
            self.shareAlertVm.showView(model: self.model)
        }
        
        return vm
    }()
    lazy var commentListVm: ForumCommentListVM = {
        let vm = ForumCommentListVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: commenListHeight))
        vm.model = self.model
        vm.controller = self
        vm.backgroundColor = .white
        if self.commentId.count > 0 || self.replyId.count > 0{
            vm.isFromNewsVC = true
            vm.commentId = self.commentId
            vm.replyId = self.replyId
//            vm.isShowHightlight = true
            vm.sendCommentListRequest(commentId: self.commentId, replyId: self.replyId)
        }else{
            vm.sendCommentListRequest()
        }
        vm.loadMoreDataBlock = {(hasMore)in
            if hasMore{
                self.loadAllLabel.text = "- 数据加载中 -"
                self.scrollViewBase.mj_footer!.endRefreshing()
            }else{
                self.loadAllLabel.text = "- 已全部加载完 -"
//                self.scrollViewBase.mj_footer!.endRefreshingWithNoMoreData()
                self.scrollViewBase.mj_footer = nil
            }
            if self.model.commentable == .refuse{
                self.loadAllLabel.text = "作者已关闭评论"
            }
        }
        vm.tapBlock = {(model)in
//            self.commomAlertVm.model = model
//            self.commomAlertVm.reModel = ForumCommentReplyModel()
//            self.commomAlertVm.showView()
            self.showCommentAlertVm(coModel: model, reModle: ForumCommentReplyModel())
        }
        vm.longPressCommentBlock = {(coModel)in
            self.funcAlertVm.commentModel = coModel
            self.funcAlertVm.replyModel = ForumCommentReplyModel()
            self.funcAlertVm.showView()
        }
        vm.longPressReplyBlock = {(reModel)in
            self.funcAlertVm.commentModel = ForumCommentModel()
            self.funcAlertVm.replyModel = reModel
            self.funcAlertVm.showView()
        }
        vm.tapReplyBlock = {(reModel)in
//            self.commomAlertVm.model = ForumCommentModel()
//            self.commomAlertVm.reModel = reModel
//            self.commomAlertVm.showView()
            self.showCommentAlertVm(coModel: ForumCommentModel(), reModle: reModel)
        }
        vm.tableView.reloadCompletion = {()in
            let size = self.commentListVm.tableView.contentSize
            if abs(self.commenListHeight - size.height) > 1{
                self.commenListHeight = size.height
                self.updateCommentListFrame()
            }
        }
        vm.scrollToOffsetY = {(cellFrame)in
            if self.isCommentScroll == false{
                self.isCommentScroll = true
                self.commentCellFrame = cellFrame
                self.scroToComment()
            }
        }
        return vm
    }()
    lazy var shareAlertVm: ForumShareVM = {
        let vm = ForumShareVM.init(frame: .zero)
        vm.reportForumBlock = {()in
            self.reportAlertVm.commentModel = ForumCommentModel()
            self.reportAlertVm.replyModel = ForumCommentReplyModel()
            self.reportAlertVm.showView()
        }
        return vm
    }()
    lazy var bottomFuncVm: ForumCommentVM = {
        let vm = ForumCommentVM.init(frame: .zero)
        vm.textField.tapBlock = {()in
            self.commentListVm.replyIndexPath = IndexPath()
//            self.commomAlertVm.model = ForumCommentModel()
//            self.commomAlertVm.reModel = ForumCommentReplyModel()
//            self.commomAlertVm.showView()
            self.showCommentAlertVm(coModel: ForumCommentModel(), reModle: ForumCommentReplyModel())
        }
        vm.thumbUpTapBlock = {()in
            self.sendThumbsUpRequest(bizType: "1")
        }
        vm.commomTapBlock = {()in
            self.commentListVm.replyIndexPath = IndexPath()
            self.showCommentAlertVm(coModel: ForumCommentModel(), reModle: ForumCommentReplyModel())
//            //评论列表的高度能铺满一个屏幕，则滑动到显示第一条评论的位置
//            if self.commenListHeight > SCREEN_HEIGHT-self.naviVm.selfHeight-self.bottomFuncVm.selfHeight{
//                self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: self.commentListVm.frame.minY), animated: true)
//            }else{
//                //如果帖子详情 + 评论能铺满一个屏幕，则滑动到页面最底部
//                //否则，不做滑动处理
//                if self.webViewHeight + self.commenListHeight > SCREEN_HEIGHT-self.naviVm.selfHeight-self.bottomFuncVm.selfHeight{
//                    self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: self.commentListVm.frame.maxY-(SCREEN_HEIGHT-self.naviVm.selfHeight-self.bottomFuncVm.selfHeight)), animated: true)
//                }
//            }
        }
        vm.hiddenSelfBlock = {()in
            self.scrollViewBase.frame = CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight()+kFitWidth(4), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()-kFitWidth(4))
        }
        return vm
    }()
    lazy var commomAlertVm: ForumCommentAlertVM = {
        let vm = ForumCommentAlertVM.init(frame: .zero)
        vm.controller = self
        vm.inputBlock = {()in
            self.bottomFuncVm.textField.textField.text = self.commomAlertVm.textView.text
        }
        vm.commonBlock = {()in
            if self.commomAlertVm.model.id.count > 0{
                self.sendCommentReplyRequest(commentId: self.commomAlertVm.model.id)
            }else if self.commomAlertVm.reModel.id.count > 0 {
                self.sendCommentReplyRequest(commentId: self.commomAlertVm.reModel.commentId, parentId: self.commomAlertVm.reModel.id)
            }else{
                self.sendCommentRequest()
            }
        }
        return vm
    }()
    lazy var funcAlertVm: ForumCommentFuncAlertVM = {
        let vm = ForumCommentFuncAlertVM.init(frame: .zero)
        vm.authorId = self.model.authorUid
        vm.deleteCommentBlock = {(coModel)in
            self.presentAlertVc(confirmBtn: "删除", message: "确认删除此评论？", title: "提示", cancelBtn: "取消", handler: { action in
                self.sendDeleteCommentRequest(coModel: coModel)
            }, viewController: self)
        }
        vm.deleteReplyBlock = {(reModel)in
            self.presentAlertVc(confirmBtn: "删除", message: "确认删除此回复？", title: "提示", cancelBtn: "取消", handler: { action in
                self.sendDeleteReplyRequest(reModel: reModel)
            }, viewController: self)
        }
        vm.replyCommentBlock = {(coModel)in
            self.showCommentAlertVm(coModel: coModel, reModle: ForumCommentReplyModel())
        }
        vm.replyReplyBlock = {(reModel)in
            self.showCommentAlertVm(coModel: ForumCommentModel(), reModle: reModel)
        }
        vm.reportCommentBlock = {(coModel)in
            self.reportAlertVm.commentModel = coModel
            self.reportAlertVm.replyModel = ForumCommentReplyModel()
            self.reportAlertVm.showView()
        }
        vm.reportReplyBlock = {(reModel)in
            self.reportAlertVm.commentModel = ForumCommentModel()
            self.reportAlertVm.replyModel = reModel
            self.reportAlertVm.showView()
        }
        return vm
    }()
    lazy var reportAlertVm: CommentReportAlertVM = {
        let vm = CommentReportAlertVM.init(frame: .zero)
        vm.submitBlock = {(reportReason)in
            if self.reportAlertVm.commentModel.id.count > 0 {
                self.sendReportCommentReqeust(bizType: "2", id: self.reportAlertVm.commentModel.id, reason: reportReason)
            }else if self.reportAlertVm.replyModel.id.count > 0{
                self.sendReportCommentReqeust(bizType: "3", id: self.reportAlertVm.replyModel.id, reason: reportReason)
            }else{
                self.sendReportCommentReqeust(bizType: "1", id: self.model.id, reason: reportReason)
            }
        }
        return vm
    }()
    lazy var loadAllLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(120)))
        lab.text = "- 已全部加载完 -"
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.backgroundColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LIGHT_GREY
        return vi
    }()
}

extension ForumDetailVC{
    func updateThumbStatus() {
        if model.upvoteCount.intValue > 0 {
            bottomFuncVm.thumbsUpButton.setTitle("\(model.upvoteCount)", for: .normal)
        }else{
            bottomFuncVm.thumbsUpButton.setTitle("点赞", for: .normal)
        }
        if model.upvote == .pass{
            bottomFuncVm.thumbsUpButton.setImage(UIImage(named: "forum_thumbs_up_highlight"), for: .normal)
            bottomFuncVm.thumbsUpButton.setTitleColor(WHColor_16(colorStr: "F5BA18"), for: .normal)
        }else{
            bottomFuncVm.thumbsUpButton.setImage(UIImage(named: "forum_thumbs_up_normal"), for: .normal)
            bottomFuncVm.thumbsUpButton.setTitleColor(.COLOR_GRAY_BLACK_45, for: .normal)
        }
//        bottomFuncVm.thumbsUpButton.imagePosition(style: .top, spacing: kFitWidth(3))
    }
    func updateCommentCount() {
        if model.totalCommentCount.count > 0 && model.totalCommentCount.intValue > 0{
            bottomFuncVm.commonButton.setTitle("\(model.totalCommentCount)", for: .normal)
        }else{
            bottomFuncVm.commonButton.setTitle("评论", for: .normal)
        }
//        bottomFuncVm.commonButton.imagePosition(style: .top, spacing: kFitWidth(3))
    }
    func showCommentAlertVm(coModel:ForumCommentModel,reModle:ForumCommentReplyModel) {
        self.commomAlertVm.model = coModel
        self.commomAlertVm.reModel = reModle
        self.commomAlertVm.showView()
    }
    func scroToComment() {
        if self.webViewisLoad {
            let tableOriginY = self.commentCellFrame.origin.y+self.commentCellFrame.size.height*0.5
            self.scrollViewBase.setContentOffset(CGPoint(x: 0, y: tableOriginY+self.webViewHeight-(SCREEN_HEIGHT-self.naviVm.selfHeight-self.bottomFuncVm.selfHeight)*0.4), animated: true)
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                self.scroToComment()
            })
        }
    }
}

extension ForumDetailVC{
    func initUI() {
        view.addSubview(naviVm)
        view.backgroundColor = .white
        let configuration = WKWebViewConfiguration()
        
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .all
          let userContentController = WKUserContentController()
//        userContentController.addUserScript(wkUScript)
          userContentController.add(self, name: ScriptMessageName.scan.name)

          configuration.userContentController = userContentController
        
        wkWebView = WKWebView.init(frame: .zero, configuration: configuration)
        wkWebView.scrollView.bounces = false
        wkWebView.backgroundColor = .white
        view.addSubview(scrollViewBase)
        scrollViewBase.frame = CGRect.init(x: 0, y: naviVm.frame.maxY+kFitWidth(4), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-naviVm.selfHeight-bottomFuncVm.selfHeight-kFitWidth(4))
        scrollViewBase.delegate = self
        scrollViewBase.addSubview(wkWebView)
//        scrollViewBase.bounces = false
        scrollViewBase.backgroundColor = .white
        if #available(iOS 17.4, *) {
            scrollViewBase.bouncesVertically = true
        } else {
            // Fallback on earlier versions
        }
        scrollViewBase.contentInsetAdjustmentBehavior = .never
        
        scrollViewBase.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: {
            self.commentListVm.loadMoreAction()
        })
        
        view.addSubview(bottomFuncVm)
        view.addSubview(commomAlertVm)
        view.addSubview(funcAlertVm)
        view.addSubview(reportAlertVm)
        updateThumbStatus()
        self.bottomFuncVm.refreshUI(model: self.model)
        if self.model.commentable == .refuse{
            self.bottomFuncVm.textField.setDisableStatus()
//            self.bottomFuncVm.setDisableComment()
            
        }else{
            self.scrollViewBase.addSubview(self.commentListVm)
            commentListVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: (SCREEN_HEIGHT-naviVm.selfHeight-bottomFuncVm.selfHeight)*1.5)
            scrollViewBase.contentSize = CGSize.init(width: 0, height: commentListVm.frame.maxY)
            self.scrollViewBase.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: {
                self.commentListVm.loadMoreAction()
            })
        }
        
        wkWebView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(kFitWidth(0))
        }
        wkWebView.scrollView.contentInsetAdjustmentBehavior = .never
        wkWebView.navigationDelegate = self
        wkWebView.uiDelegate = self
        wkWebView.backgroundColor = .white//WHColorWithAlpha(colorStr: "1E1E1E", alpha: 1)//WHColor_16(colorStr: "F6F6F6")
        wkWebView.scrollView.backgroundColor = .white//WHColorWithAlpha(colorStr: "1E1E1E", alpha: 1)
        wkWebView.isOpaque = false
        wkWebView.scrollView.bounces = false
        wkWebView.scrollView.isScrollEnabled = false
        wkWebView.scrollView.showsVerticalScrollIndicator = false
        wkWebView.scrollView.showsHorizontalScrollIndicator = false
        wkWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        wkWebView.addObserver(self, forKeyPath: canGoBackKeyPath, options: .new, context: nil)
        
        
        bridge = WKWebViewJavascriptBridge.init(for: wkWebView)
        bridge.setWebViewDelegate(self)
        
        bridge.registerHandler("hitImgCallback") { data, callBack in
            DLLog(message: "hitImgCallback:\(data ?? "")")
        }
        bridge.registerHandler("observevalue") { data, callBack in
            DLLog(message: "observevalue:\(data ?? "")")
        }
        
        self.view.addSubview(progressView)
        progressView.progressTintColor = UIColor.THEME
        progressView.trackTintColor = UIColor.clear
        progressView.snp.makeConstraints { (frame) in
            frame.width.equalTo(SCREEN_WIDHT)
            frame.height.equalTo(2)
            frame.top.equalTo(wkWebView.snp.top)
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getKeyWindow().addSubview(self.shareAlertVm)
    }
    func updateCommentListFrame() {
        let listFrame = self.commentListVm.frame
        self.commentListVm.frame = CGRect.init(x: 0, y: listFrame.origin.y, width: SCREEN_WIDHT, height: self.commenListHeight+self.commentListVm.labelHeight)
        self.commentListVm.tableView.frame = CGRect.init(x: 0, y: self.commentListVm.labelHeight, width: SCREEN_WIDHT, height: self.commenListHeight)
//        self.commentListVm.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.commenListHeight-kFitWidth(100))
        self.loadAllLabel.frame = CGRect.init(x: 0, y: self.commentListVm.frame.maxY, width: SCREEN_WIDHT, height: kFitWidth(120))
        self.lineView.frame = CGRect.init(x: 0, y: self.loadAllLabel.frame.minY, width: SCREEN_WIDHT, height: kFitWidth(1))
        self.scrollViewBase.contentSize = CGSize.init(width: 0, height: listFrame.origin.y+self.commenListHeight+self.commentListVm.labelHeight+kFitWidth(120))
//        self.commentListVm.tableView.bounces = true
//        commenListHeight
    }
    func loadUrlString() {
        let url = URL(string: model.webLink as String)
        let request = URLRequest(url: url!)
        wkWebView.load(request)
    }
    func loadServerHtml() {
//        wkWebView.loadHTMLString(model.content, baseURL: nil)
        guard let webView = wkWebView else {
            return
        }
        webView.loadHTMLString(model.content, baseURL: nil)
    }
    
    func longPressHandle(vm: HeroBrowserViewModuleBaseProtocol) {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == PHAuthorizationStatus.authorized || status == PHAuthorizationStatus.notDetermined {
                //保存图片 actionSheet 使用我另一个库 JFPopup 实现，有兴趣欢迎star.
                JFPopupView.popup.actionSheet {
                    [
                        JFPopupAction(with: "保存", subTitle: nil) {
                            if let imgVM = vm as? HeroBrowserViewModule {
//                                JFPopupView.popup.loading(hit: "图片保存中")
                                imgVM.asyncLoadRawSource { result in
//                                    JFPopupView.popup.hideLoading()
                                    switch result {
                                    case let .success(image):
                                        print(image)
                                        //还需请求权限，这里就不演示了
                                        //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        //                                JFPopupView.popup.toast(hit: "保存图片成功（只做演示无功能）")
                                        self.savePhotos(image: image, data: nil)
                                        break
                                    case _ :
                                        break
                                    }
                                }
                            }
                        },
        //                JFPopupAction(with: "分享", subTitle: nil, clickActionCallBack: {
        //                    JFPopupView.popup.toast(hit: "分享成功（只做演示无功能）")
        //                }),
                    ]
                }
            }else{
                //去设置
                self.openSystemSettingPhotoLibrary()
            }
        }
    }
    func savePhotos(image: UIImage?,data: Data?) {
//        PHPhotoLibrary.requestAuthorization { (status) in
//            if status == PHAuthorizationStatus.authorized || status == PHAuthorizationStatus.notDetermined {
                PHPhotoLibrary.shared().performChanges {
                    if let imgData = data {
                        let req = PHAssetCreationRequest.forAsset()
                        req.addResource(with: .photo, data: imgData, options: nil)
                    }else if let img = image{
                        _ = PHAssetChangeRequest.creationRequestForAsset(from: img)
                    }else{
                        MBProgressHUD.xy_hide()
                        return
                    }
                } completionHandler: { (finish, error) in
                    DispatchQueue.main.async {
                        if finish {
                            JFPopupView.popup.toast(hit: "保存成功")
                        }else{
                            JFPopupView.popup.toast(hit: "保存失败")
                        }
                    }
                };
//            }else{
//                MBProgressHUD.xy_hide()
//                //去设置
//                self.openSystemSettingPhotoLibrary()
//            }
//        }
    }
    
    func openSystemSettingPhotoLibrary() {
        let alert = UIAlertController(title:"未获得权限访问您的照片", message:"请在设置选项中允许访问您的照片", preferredStyle: .alert)
        let confirm = UIAlertAction(title:"去设置", style: .default) { (_)in
            let url=URL.init(string: UIApplication.openSettingsURLString)
            if  UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.open(url!, options: [:], completionHandler: { (ist)in
                })
            }
        }
        let cancel = UIAlertAction(title:"取消", style: .cancel, handler:nil)
        alert.addAction(cancel)
        alert.addAction(confirm)
        self.present(alert, animated:true, completion:nil)
    }
}

extension ForumDetailVC: WKScriptMessageHandler {
// 实现WKScriptMessageHandler的回调方法
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        DLLog(message: "userContentController:\(message)")
        // 假设JavaScript调用send message时带有videoUrl参数
        if let videoURL = message.body as? String, let url = URL(string: videoURL) {
            player?.pause() // 暂停当前播放
            player?.replaceCurrentItem(with: AVPlayerItem(url: url)) // 更换播放内容
            player?.play() // 播放新的视频
        }
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.oldOffsetY = self.scrollViewBase.contentOffset.y
            if self.commomAlertVm.model.id.count == 0 && self.commomAlertVm.reModel.id.count == 0{
                return
            }
            var selectRect = self.commentListVm.tableView.rectForHeader(inSection: self.commentListVm.replyIndexPath.section)
            if self.commomAlertVm.model.id.count == 0{
                selectRect = self.commentListVm.tableView.rectForRow(at: self.commentListVm.replyIndexPath)
            }
            
//            let screenRect = self.commentListVm.tableView.convert(selectRect, to: nil)
//            DLLog(message: "showCommentAlertVm(coMode:\(selectRect)")
//            DLLog(message: "showCommentAlertVm(coMode:screenRect -- \(screenRect)")
//            var offsetY = self.oldOffsetY + self.scrollViewBase.frame.size.height - (self.commomAlertVm.contentWhiteHeight+keyboardSize.size.height) - screenRect.size.height + self.bottomFuncVm.selfHeight
//            offsetY = self.oldOffsetY + self.scrollViewBase.frame.size.height-((keyboardSize.size.height - self.bottomFuncVm.selfHeight)+self.commomAlertVm.contentWhiteHeight+screenRect.size.height)+abs(screenRect.origin.y-WHUtils().getNavigationBarHeight())
//            DLLog(message: "showCommentAlertVm(coMode:oldOffsetY:\(oldOffsetY)")
//            DLLog(message: "showCommentAlertVm(coMode:scrollViewBaseheight:\(self.scrollViewBase.frame.size.height)")
//            DLLog(message: "showCommentAlertVm(coMode:commomAlertVmWhiteHeight:\(self.commomAlertVm.contentWhiteHeight)")
//            DLLog(message: "showCommentAlertVm(coMode:keyboardHeight:\(keyboardSize.size.height)")
//            DLLog(message: "showCommentAlertVm(coMode:offsetY:\(offsetY)")
            
//            self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: offsetY), animated: true)
            self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: self.commentListVm.frame.origin.y+selectRect.maxY+self.commomAlertVm.contentWhiteHeight+keyboardSize.origin.y-self.scrollViewBase.frame.height-WHUtils().getNavigationBarHeight()-self.bottomFuncVm.selfHeight), animated: true)
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: self.oldOffsetY), animated: true)
    }
}

extension ForumDetailVC:WKNavigationDelegate,WKUIDelegate{
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        if let currentUrl = webView.url{
            DLLog(message: "重定向地址：\(currentUrl)")
        }
    }
    // 监听网页加载进度
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            DLLog(message: "监听网页加载进度")
            progressView.progress = Float(wkWebView.estimatedProgress)
            DLLog(message: Float(wkWebView.estimatedProgress))
        }else if keyPath == canGoBackKeyPath{
            if let newValue = change?[NSKeyValueChangeKey.newKey]{
                let newV = newValue as! Bool
                if newV == true{
                    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
                }else{
                    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
                }
            }
        }else if keyPath == "contentSize"{
//            let height = self.wkWebView.scrollView.contentSize.height
//            DLLog(message: "observeValuej:\(height)")
        }
    }
    
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DLLog(message: "开始加载...")
        DLLog(message: webView.url?.absoluteString)
        
        wkWebView.scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        if webView.url?.absoluteString.range(of: "weixin://wap/pay?") != nil || webView.url?.absoluteString.range(of: "alipay://alipayclient/") != nil || (webView.url?.absoluteString.contains("taobao:"))!{
            self.openUrl(urlString: webView.url!.absoluteString)
        }else if webView.url?.absoluteString.range(of: "elaforum://forumDetail?") != nil{
            //点击图片的重定向回调
            var urlStirng = "\(webView.url?.absoluteString ?? "")"
            urlStirng = urlStirng.replacingOccurrences(of: "elaforum://forumDetail?", with: "")
            let urlParam = urlStirng.components(separatedBy: "&")
            
            var imgUrls = NSArray()
            var imgIndex = 0
            
            for i in 0..<urlParam.count{
                let str = urlParam[i]
                let str2 = str.removingPercentEncoding ?? ""
                if str2.contains("imgIndex"){
                    let imgIndexArray = str2.components(separatedBy: "=")
                    DLLog(message: "解析获取  imgIndex:\(imgIndexArray.last ?? "")")
                    imgIndex = (imgIndexArray.last ?? "0").intValue
                }else if str2.contains("imgArray"){
                    let imgArray = str2.components(separatedBy: "=")
                    DLLog(message: "解析获取  imgArray:\(imgArray.last ?? "")")
                    imgUrls = self.getArrayFromJSONString(jsonString: imgArray.last ?? "")
                    DLLog(message: "解析获取  imgArray(数组):\(imgUrls)")
                }
            }
            if imgUrls.count > imgIndex{
                list.removeAll()
                for i in 0..<imgUrls.count{
                    let imgUrlString = imgUrls[i]as? String ?? ""
                    DSImageUploader().dealImgUrlSignForOss(urlStr: "\(imgUrlString)") { signUrl in
                        self.list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: signUrl, originImgUrl: signUrl))
                    }
//                    list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: "\(imgUrlString)?imageView2/0/w/300", originImgUrl: imgUrlString))
                }
                
                self.hero.browserPhoto(viewModules: list, initIndex: imgIndex) {
                   [
                       .pageControlType(.pageControl),
//                       .heroView(self.bannerImgVm.imgList[imgIndex]),
                       .heroBrowserDidLongPressHandle({ [weak self] heroBrowser,vm  in
                           self?.longPressHandle(vm: vm)
                       }),
//                       .imageDidChangeHandle({ [weak self] imageIndex in
//                           guard let self = self else { return nil }
//                           self.bannerImgVm.scrollView.setContentOffset(CGPoint(x: SCREEN_WIDHT*CGFloat(imageIndex), y: 0), animated: false)
//    //                               let img = self.bannerImgVm.imgList[imageIndex]
//                           return self.bannerImgVm.imgList[imageIndex]
//    //                               self?.bannerImgVm.scrollView.setContentOffset(CGPoint(x: SCREEN_WIDHT*CGFloat(imageIndex), y: 0), animated: false)
//    //                               guard let self = self else { return nil }
//    //                               guard let cell = self.collectionView.cellForItem(at: IndexPath(item: imageIndex, section: 0)) as? NetworkImageCollectionViewCell else { return nil }
//    //                               let rect = cell.convert(cell.imageView.frame, to: self.view)
//    //                               if self.view.frame.contains(rect) {
//    //                                   return cell.imageView
//    //                               }
//    //                               return nil
//                       })
                   ]
               }
//                let showController = ShowBigImgController(urls: imgUrls as! [String], url: imgUrls[imgIndex] as! String,isNavi: true)
////                showController.modalPresentationStyle = .overFullScreen
////                self.present(showController, animated: false, completion: nil)
//                self.navigationController?.pushViewController(showController, animated: true)
            }
        }
    }
    
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        DLLog(message: "当内容开始返回...")
    }
    
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        DLLog(message: "页面加载完成...")
        /// 获取网页title
        h5TitleLabel.text = wkWebView.title
        
        wkWebView.scrollView.removeObserver(self, forKeyPath: "contentSize")
        UIView.animate(withDuration: 0.5) {
            self.progressView.isHidden = true
        }
//        let jsTxt = "document.body.offsetHeight;"
        let jsTxt = "document.body.scrollHeight;"
        self.wkWebView.evaluateJavaScript(jsTxt) { height, error in
            if height != nil{
//                let fittingSize = self.wkWebView.sizeThatFits(.zero)
                let offsetHeight = height as! CGFloat
                let contentHeight = self.wkWebView.scrollView.contentSize.height
//                    let height = abs(contentHeight)
                DLLog(message: "高度： \(offsetHeight)  -\(contentHeight)")
                self.webViewHeight = height as! CGFloat//max(abs(offsetHeight), abs(contentHeight)) + kFitWidth(10)
                self.wkWebView.snp.remakeConstraints { make in
                    make.left.top.width.equalToSuperview()
                    make.height.equalTo(self.webViewHeight)
                }
                self.commentListVm.frame = CGRect.init(x: 0, y: self.webViewHeight, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.naviVm.selfHeight-self.bottomFuncVm.selfHeight+self.commentListVm.labelHeight)
                if self.model.commentable == .refuse{
                    self.scrollViewBase.addSubview(self.loadAllLabel)
                    self.scrollViewBase.addSubview(self.lineView)
                    self.commentListVm.isHidden = true
                    self.loadAllLabel.frame = CGRect.init(x: 0, y: self.webViewHeight, width: SCREEN_WIDHT, height: kFitWidth(120))
                    self.lineView.frame = CGRect.init(x: 0, y: self.loadAllLabel.frame.minY, width: SCREEN_WIDHT, height: kFitWidth(1))
                    self.scrollViewBase.contentSize = CGSize.init(width: 0, height: self.webViewHeight+kFitWidth(120))
                }else{
                    self.scrollViewBase.contentSize = CGSize.init(width: 0, height: self.webViewHeight+self.commenListHeight+kFitWidth(80))
                    self.updateCommentListFrame()
                    if self.isToComment{
                        if self.model.commentable == .pass {
                            if self.commenListHeight > SCREEN_HEIGHT-self.naviVm.selfHeight-self.bottomFuncVm.selfHeight{
                                self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: self.webViewHeight), animated: false)
                            }else{
        //                            let offsetHeight = self.scrollViewBase.contentOffset.y
                                self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: self.webViewHeight+self.commenListHeight+self.commentListVm.labelHeight-(SCREEN_HEIGHT-self.naviVm.selfHeight-self.bottomFuncVm.selfHeight)), animated: true)
        //                            self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: self.webViewHeight+self.commenListHeight), animated: false)
                            }
                        }else{
                            MCToast.mc_text("作者已关闭评论")
                        }
                    }
                }
            }
            self.webViewisLoad = true
        }
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            print("Intercepted click: \(url)")
            
            if url.absoluteString.range(of: "about:blank") != nil ||
                url.absoluteString.range(of: "https://api.leungnutritionsciences.cn") != nil ||
                url.absoluteString.range(of: "https://teststatic.leungnutritionsciences.cn") != nil ||
                url.absoluteString.range(of: "elaforum://forumDetail?") != nil{
                decisionHandler(.allow)
            }else{
                decisionHandler(.cancel)
            }
            return
        }
        DLLog(message: "decidePolicyFor:\(navigationAction.description)")
        
        decisionHandler(.allow)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        DLLog(message: "页面加载失败...")
        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = 0.0
            self.progressView.isHidden = true
        }
    }
    // 实现以下代理方法
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
         let cred = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
         completionHandler(.useCredential, cred)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if (!(navigationAction.targetFrame?.isMainFrame ?? false)) {
            wkWebView.load(navigationAction.request)
        }

        return nil;
    }
}

extension ForumDetailVC:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        DLLog(message: "scrollViewDidScroll(_ scrollView  ForumDetailVC")
        if self.scrollViewBase.contentOffset.y < 0 {
            self.scrollViewBase.contentOffset.y = 0
        }
    }
}

extension ForumDetailVC{
    func sendForumDetailRequest() {
        let param = ["id":"\(model.id)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_community_forum_detail, parameters: param as [String: AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendForumDetailRequest:\(dataObj)")
            self.model = ForumModel().initWithDictCoverInfo(dict: dataObj)
            
            DLLog(message: "sendForumDetailRequest:\(self.model.description)")
//            self.loadUrlString()
            self.naviVm.updateUI(model: self.model)
            self.loadServerHtml()
            
            self.updateThumbStatus()
            self.updateCommentCount()
            if self.model.totalCommentCount.intValue == 0 {
                self.commentListVm.commentCountLabel.text = "评论"
            }else{
                self.commentListVm.commentCountLabel.text = "共 \(self.model.totalCommentCount) 条评论"
            }
        }
    }
    func sendCommentRequest() {
        let imgString = self.commomAlertVm.commonImgUrl.count > 0 ? self.getJSONStringFromArray(array: [self.commomAlertVm.commonImgUrl])
                                                                    : ""
        let param = ["id":"\(model.id)",
                     "content":"\(self.commomAlertVm.textView.text ?? "")",
                     "image":imgString]
        WHNetworkUtil.shareManager().POST(urlString: URL_community_comment_add, parameters: param as [String: AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "sendCommentRequest:\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            DLLog(message: "sendCommentRequest:\(dataString ?? "")")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendCommentRequest:\(dataObj)")
            
            self.bottomFuncVm.textField.textField.text = ""
            self.commomAlertVm.clearMSg()
            let coModel = ForumCommentModel().dealData(dict: dataObj)
            self.commentListVm.addComment(coModel: coModel)
            self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: self.commentListVm.frame.minY), animated: true)
            self.model.commentCount = "\(self.model.commentCount.intValue + 1)"
            self.model.totalCommentCount = "\(self.model.totalCommentCount.intValue + 1)"
            self.commentListVm.commentCountLabel.text = "共 \(self.model.totalCommentCount) 条评论"
        }
    }
    func sendCommentReplyRequest(commentId:String) {
        let imgString = self.commomAlertVm.commonImgUrl.count > 0 ? self.getJSONStringFromArray(array: [self.commomAlertVm.commonImgUrl])
                                                                    : ""
        let param = ["id":"\(model.id)",
                     "commentId":"\(commentId)",
                     "content":"\(self.commomAlertVm.textView.text ?? "")",
                     "image":imgString]
        WHNetworkUtil.shareManager().POST(urlString: URL_community_reply_add, parameters: param as [String: AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendCommentReplyRequest:\(dataObj)")
            
            self.bottomFuncVm.textField.textField.text = ""
//            self.commomAlertVm.textView.text = ""
//            self.commomAlertVm.commonImgUrl = ""
//            self.commomAlertVm.showImgView(isShow: false)
            self.commomAlertVm.clearMSg()
            
            let reModel = ForumCommentReplyModel().dealData(dict: dataObj)
            self.commentListVm.addReply(reModel: reModel)
        }
    }
    func sendCommentReplyRequest(commentId:String,parentId:String) {
        let imgString = self.commomAlertVm.commonImgUrl.count > 0 ? self.getJSONStringFromArray(array: [self.commomAlertVm.commonImgUrl])
                                                                    : ""
        let param = ["id":"\(model.id)",
                     "commentId":"\(commentId)",
                     "parentId":"\(parentId)",
                     "content":"\(self.commomAlertVm.textView.text ?? "")",
                     "image":imgString]
        DLLog(message: "sendCommentReplyRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_community_reply_add, parameters: param as [String: AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "sendForumDetailRequest:\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendForumDetailRequest:\(dataObj)")
            
            self.bottomFuncVm.textField.textField.text = ""
//            self.commomAlertVm.textView.text = ""
//            self.commomAlertVm.commonImgUrl = ""
//            self.commomAlertVm.showImgView(isShow: false)
            self.commomAlertVm.clearMSg()
            
            let reModel = ForumCommentReplyModel().dealData(dict: dataObj)
            self.commentListVm.addReply(reModel: reModel)
        }
    }
    func sendReportCommentReqeust(bizType:String,id:String,reason:String) {
        let param = ["id":"\(id)",
                     "bizType":"\(bizType)",
                     "reason":"\(reason)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_report, parameters: param as [String:AnyObject],isNeedToast: true
                                          ,vc: self) { responseObject in
            MCToast.mc_text("\(responseObject["message"]as? String ?? "")",respond: .allow)
        }
    }
    @objc func sendThumbsUpRequest(bizType:String) {
//        if model.upvote == .refuse{
//            TouchGenerator.shared.touchGenerator()
//        }
        let upvote = model.upvote == .pass ? "0" : "1"
        let param = ["id":"\(model.id)",
                     "bizType":"\(bizType)",
                     "like":"\(upvote)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_community_forum_thumb, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: "sendThumbsUpRequest:\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            
            DLLog(message: "sendThumbsUpRequest:\(dataString ?? "")")
            if dataString == "1"{
                self.model.upvote = .pass
                self.model.upvoteCount = "\(self.model.upvoteCount.intValue + 1)"
            }else{
                self.model.upvote = .refuse
                self.model.upvoteCount = "\(self.model.upvoteCount.intValue - 1)"
            }
            
            self.updateThumbStatus()
            if self.thumbBlock != nil{
                self.thumbBlock!(self.model)
            }
        }
    }
    
    func sendDeleteCommentRequest(coModel:ForumCommentModel) {
        let param = ["id":"\(coModel.id)"]
        //value    String    "ed47ea1e2cc577b457eeec87c6e02615"
        WHNetworkUtil.shareManager().POST(urlString: URL_community_comment_delete, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            self.commentListVm.deleteComment()
            self.model.commentCount = "\(self.model.commentCount.intValue - 1 - coModel.replyCount.intValue)"
            self.model.totalCommentCount = "\(self.model.totalCommentCount.intValue - 1 - coModel.replyCount.intValue)"
            if self.model.totalCommentCount.intValue == 0 {
                self.commentListVm.commentCountLabel.text = "评论"
            }else{
                self.commentListVm.commentCountLabel.text = "共 \(self.model.totalCommentCount) 条评论"
            }
        }
    }
    func sendDeleteReplyRequest(reModel:ForumCommentReplyModel) {
        let param = ["id":"\(reModel.id)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_community_reply_delete, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            self.commentListVm.deleteCommentReply()
        }
    }
}
