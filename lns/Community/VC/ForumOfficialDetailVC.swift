//
//  ForumOfficialDetailVC.swift
//  lns
//
//  Created by Elavatine on 2024/11/6.
//

import MCToast
import MJRefresh
import IQKeyboardManagerSwift
import Photos
import Kingfisher
//import MBProgressHUD


class ForumOfficialDetailVC: WHBaseViewVC {
    
    var model = ForumModel()
    var thumbBlock:((ForumModel)->())?
    var deleteBlock:((ForumModel)->())?
    var bannerHeight = kFitWidth(150)
    
    var commenListHeight = kFitWidth(10)
    var pollSelectCount = 0
    
    var isToComment = false
    var tableViewisLoad = false
        
    ///站内信跳转进来的时候，查询评论列表，需要传参
    var commentId = ""
    ///站内信跳转进来的时候，查询评论列表，需要传参
    var replyId = ""
    var commentDeleteString = ""
    var isFromNewsList = false
    
    var isLoadMoreComment = false
    var oldOffsetY = CGFloat(0)
    
    var detailBackBlock:((TimeInterval,ZFAVPlayerManager)->())?
    var isPop = true
    
    var playIsPlay = true
    var isCommentScroll = false
    
    var isManualPause = false
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(endFullAction), name: NSNotification.Name(rawValue: "tutorialEnterFullScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exitFullAction), name: NSNotification.Name(rawValue: "tutorialExitFullScreen"), object: nil)
        if self.model.contentType == .VIDEO{
            if self.scrollViewBase.contentOffset.y >= self.videoVm.selfHeight{
                ZFPlayerModel.shared.playerManager.pause()
            }else{
                ZFPlayerModel.shared.playerManager.play()
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        UserConfigModel.shared.canPushForumDetail = true
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCommentListImg), name: NSNotification.Name(rawValue: "commentImgLoaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if commentDeleteString.count > 0{
//            MCToast.mc_text("\(commentDeleteString)")
            JFPopupView.popup.toast(hit: "\(commentDeleteString)")
            commentDeleteString = ""
        }
    }
    override var prefersStatusBarHidden: Bool{
        return UserConfigModel.shared.allowedOrientations != .portrait
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        
        if self.model.contentType == .VIDEO{
            if self.isMovingFromParent{
                self.controlView.isHidden = true
                ZFPlayerModel.shared.playerManager.scalingMode = .aspectFill
                if self.isFromNewsList {
                    ZFPlayerModel.shared.playerManager.stop()
                    ZFPlayerModel.shared.playerManager.rate = 1
                }else{
//                    ZFPlayerModel.shared.playerManager.pause()
                    ZFPlayerModel.shared.playerManager.stop()
                    ZFPlayerModel.shared.playerManager.rate = 1
//                    if self.detailBackBlock != nil{
//                        self.detailBackBlock!(ZFPlayerModel.shared.player.currentTime,ZFPlayerModel.shared.playerManager)
//                    }
                }
            }else{
//                ZFPlayerModel.shared.playerManager.pause()
                ZFPlayerModel.shared.playerManager.stop()
            }
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCommentListImg), name: NSNotification.Name(rawValue: "commentImgLoaded"), object: nil)
        initUI()
        self.updateThumbStatus()
        self.updateCommentCount()
        
        if self.model.contentType == .VIDEO && self.model.poster == .customer && self.isFromNewsList == false{
            if playIsPlay{
                DLLog(message: "playIsPlay    ---  true")
                initVideo()
            }else{
                DLLog(message: "playIsPlay    ---  false")
                initPlayer()
            }
        }
        sendForumDetailRequest()
    }
    lazy var naviVm: ForumNaviVM = {
        let vm = ForumNaviVM.init(frame: .zero)
        vm.backArrowButton.tapBlock = {()in
            self.backTapAction()
        }
        vm.shareBlock = {()in
            if self.model.webLink.count > 0 {
                self.shareAlertVm.showView(model: self.model)
                self.sendCreateShareLink(model: self.model, isShowShareView: false)
            }else{
                self.sendCreateShareLink(model: self.model,isShowShareView: true)
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
        vm.deleteForumBlock = {()in
            DLLog(message: "删除帖子\(self.model.title)")
            self.presentAlertVc(confirmBtn: "删除", message: "", title: "是否删除此帖子？", cancelBtn: "取消", handler: { action in
                self.sendDeleteForumRequest()
            }, viewController: self)
        }
        return vm
    }()
    lazy var tableView: ForumCommentListTableView = {
        let vm = ForumCommentListTableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight()-kFitWidth(56)-WHUtils().getBottomSafeAreaHeight()), style: .plain)
        vm.delegate = self
        vm.dataSource = self
        vm.backgroundColor = .white
        vm.separatorStyle = .none
        vm.bounces = false
        vm.register(ForumOfficialTextCell.classForCoder(), forCellReuseIdentifier: "ForumOfficialTextCell")
        vm.register(ForumOfficialPollCell.classForCoder(), forCellReuseIdentifier: "ForumOfficialPollCell")
        if #available(iOS 15.0, *) {
            vm.sectionHeaderTopPadding = 0
        }
        vm.reloadCompletion = {()in
            let size = self.tableView.contentSize
            self.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: size.height)
            self.commentListVm.frame = CGRect.init(x: 0, y: size.height, width: SCREEN_WIDHT, height: self.commenListHeight+kFitWidth(40))
            self.loadAllLabel.frame = CGRect.init(x: 0, y: self.commentListVm.frame.maxY-1, width: SCREEN_WIDHT, height: kFitWidth(80))
            self.bannerImgVm.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.bannerHeight+kFitWidth(14))
            self.scrollViewBase.contentSize = CGSize.init(width: 0, height: size.height+self.commenListHeight+kFitWidth(40)+kFitWidth(80))
//            self.bannerImgVm.updateFrame(bannerHeight: self.bannerHeight)
            if self.isToComment{
                self.scroToComment(tableHeight:size.height)
            }
        }
        return vm
    }()
    
    lazy var controlView: TutorialVideoControlView = {
        let vi = TutorialVideoControlView()
        vi.prepareShowControlView = true
//        vi.autoFadeTimeInterval = 0.2
        vi.portraitControlView.shareVideoBtn.isHidden = true
        vi.portraitControlView.backBtn.isHidden = true
//        vi.landScapeControlView.backBtn.isHidden = true
        vi.fastViewAnimated = true
        vi.prepareShowLoading = true
        vi.portraitControlView.nextBtn.isHidden = true
        vi.landScapeControlView.nextBtn.isHidden = true
        vi.customDisablePanMovingDirection = true
        vi.backBtnClickCallback = {()in
            self.backTapAction()
        }
        vi.portraitControlView.pauseManualTapBlock = {(isPlay)in
            if isPlay == false{
                self.isManualPause = false
            }else{
                self.isManualPause = true
            }
        }
        vi.landScapeControlView.pauseManualTapBlock = {(isPlay)in
            if isPlay == false{
                self.isManualPause = false
            }else{
                self.isManualPause = true
            }
        }
        return vi
    }()
    lazy var videoVm: ForumOfficialVideoVM = {
        let imgHeight = self.model.coverImgHeight/self.model.coverImgWidth*SCREEN_WIDHT
        let vm = ForumOfficialVideoVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: imgHeight))
//        let vm = ForumOfficialVideoVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: self.model.coverImgHeight))
        vm.backgroundColor = .COLOR_GRAY_BLACK_85
        vm.videoWidth = self.model.contentWidth
        vm.controller = self
        if self.model.contentType == .VIDEO{
            vm.updateUIForForumDetail(model: model)
        }
        vm.playBlock = {()in
            self.backArrowButton.isHidden = true
            self.videoVm.play()
            self.controlView.resetControlView()
        }
        vm.heightChanged = {(videoHeight)in
            self.videoVm.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: videoHeight)
//            self.tableView.beginUpdates()
//            self.tableView.endUpdates()
            ZFPlayerModel.shared.playerManager.scalingMode = .aspectFit
            UIView.performWithoutAnimation {
                self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .none)
            }
        }
        return vm
    }()
    lazy var bannerImgVm: ForumOfficialImgsVM = {
        let vm = ForumOfficialImgsVM.init(frame: CGRect.init(x: 0, y: naviVm.frame.maxY, width: SCREEN_WIDHT, height: bannerHeight+kFitWidth(14)))
        vm.updateUI(dataArray: self.model.imgsContent as NSArray)
        
        vm.tapBlock = {(imgIndex)in
            self.hero.browserPhoto(viewModules: self.bannerImgVm.list, initIndex: imgIndex) {
               [
                   .pageControlType(.pageControl),
                   .heroView(self.bannerImgVm.imgList[imgIndex]),
                   .heroBrowserDidLongPressHandle({ [weak self] heroBrowser,vm  in
                       self?.longPressHandle(vm: vm)
                   }),
                   .imageDidChangeHandle({ [weak self] imageIndex in
                       guard let self = self else { return nil }
                       self.bannerImgVm.scrollView.setContentOffset(CGPoint(x: SCREEN_WIDHT*CGFloat(imageIndex), y: 0), animated: false)
//                               let img = self.bannerImgVm.imgList[imageIndex]
                       return self.bannerImgVm.imgList[imageIndex]
//                               self?.bannerImgVm.scrollView.setContentOffset(CGPoint(x: SCREEN_WIDHT*CGFloat(imageIndex), y: 0), animated: false)
//                               guard let self = self else { return nil }
//                               guard let cell = self.collectionView.cellForItem(at: IndexPath(item: imageIndex, section: 0)) as? NetworkImageCollectionViewCell else { return nil }
//                               let rect = cell.convert(cell.imageView.frame, to: self.view)
//                               if self.view.frame.contains(rect) {
//                                   return cell.imageView
//                               }
//                               return nil
                   })
               ]
           }

//            let showController = ShowBigImgController(urls: self.model.imgsContent, url: self.model.imgsContent[imgIndex],isNavi: true)
//            self.navigationController?.pushViewController(showController, animated: true)
        }
        return vm
    }()
    lazy var pollHeadVm: ForumPollTableHeadVM = {
        let vm = ForumPollTableHeadVM.init(frame: .zero)
        vm.titleLab.text = "\(model.pollModel.pollTitle)"
        return vm
    }()
    lazy var pollFootVm: ForumPollTableFootVM = {
        let vm = ForumPollTableFootVM.init(frame: .zero)
        
        if model.forumPostPollModel.isPoll{
//            if model.pollModel.optionThreshold <= 1 || model.forumPostPollModel.isPoll{
            vm.selfHeight = kFitWidth(40)
            vm.submitButton.isHidden = true
        }else{
            vm.leftTipsLabel.text = "最多选择\(model.pollModel.optionThreshold)项"
        }
        vm.submitButton.addTarget(self, action: #selector(submitPollMultipleAction), for: .touchUpInside)
        return vm
    }()
    lazy var bottomFuncVm: ForumCommentVM = {
        let vm = ForumCommentVM.init(frame: .zero)
        vm.textField.tapBlock = {()in
            if self.model.commentable == .pass{
                self.commentListVm.replyIndexPath = IndexPath()
                self.showCommentAlertVm(coModel: ForumCommentModel(), reModle: ForumCommentReplyModel())
            }else{
                MCToast.mc_text("评论功能已关闭。")
            }
        }
        vm.thumbUpTapBlock = {()in
            self.sendThumbsUpRequest(bizType: "1")
        }
        vm.commomTapBlock = {()in
            self.commentListVm.replyIndexPath = IndexPath()
            self.showCommentAlertVm(coModel: ForumCommentModel(), reModle: ForumCommentReplyModel())
        }
        vm.hiddenSelfBlock = {()in
            self.tableView.frame = CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-WHUtils().getNavigationBarHeight())
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
            DispatchQueue.main.asyncAfter(deadline: .now()+0.4, execute: {
                vm.sendCommentListRequest(commentId: self.commentId, replyId: self.replyId)
            })
        }else{
            vm.sendCommentListRequest()
        }
        
        vm.loadMoreDataBlock = {(hasMore)in
//            DLLog(message: "scrollViewDidScroll: loadMoreDataBlock  --- \(hasMore)")
            if hasMore{
                self.loadAllLabel.text = "- 数据加载中 -"
                self.scrollViewBase.mj_footer?.endRefreshing()
            }else{
                self.isLoadMoreComment = false
                self.loadAllLabel.text = "- 已全部加载完 -"
//                self.scrollViewBase.mj_footer?.endRefreshingWithNoMoreData()
                self.scrollViewBase.mj_footer = nil
            }
            if self.model.commentable == .refuse{
                self.loadAllLabel.text = "作者已关闭评论"
            }
        }
        vm.tapBlock = {(model)in
            DLLog(message: "tapCommentList----")
            self.showCommentAlertVm(coModel: model, reModle: ForumCommentReplyModel())
        }
        vm.tapReplyBlock = {(reModel)in
            DLLog(message: "tapCommentList----reply")
            self.showCommentAlertVm(coModel: ForumCommentModel(), reModle: reModel)
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
        vm.tableView.reloadCompletion = {()in
            let size = self.commentListVm.tableView.contentSize
            if abs(self.commenListHeight - size.height) > 1{
                self.commenListHeight = size.height
                DLLog(message: "commentListVm reloadCompletion:\(size.height)")
                self.commentListVm.frame = CGRect.init(x: 0, y: self.tableView.frame.maxY, width: SCREEN_WIDHT, height: self.commenListHeight+kFitWidth(40))
                self.commentListVm.tableView.frame = CGRect.init(x: 0, y: kFitWidth(40), width: SCREEN_WIDHT, height: self.commenListHeight)
                self.loadAllLabel.frame = CGRect.init(x: 0, y: self.commentListVm.frame.maxY-2, width: SCREEN_WIDHT, height: kFitWidth(80))
                self.scrollViewBase.contentSize = CGSize.init(width: 0, height: self.tableView.frame.maxY + self.commenListHeight+kFitWidth(40)+kFitWidth(80))
            }
        }
        vm.scrollToOffsetY = {(cellFrame)in
            if self.isCommentScroll == false{
                self.isCommentScroll = true
                let tableOriginY = cellFrame.origin.y+cellFrame.size.height*0.5
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                    self.scrollViewBase.setContentOffset(CGPoint(x: 0, y: tableOriginY+self.tableView.frame.maxY-(SCREEN_HEIGHT-self.naviVm.selfHeight-self.bottomFuncVm.selfHeight)*0.4), animated: true)
                })
            }
        }
        vm.setTopOffsetY = {(cellFrame)in
//            let tableOriginY = cellFrame.origin.y+cellFrame.size.height*0.5
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                self.scrollViewBase.setContentOffset(CGPoint(x: 0, y: self.commentListVm.frame.minY), animated: true)
            })
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
        vm.setTopBlock = {(coModel)in
            self.commentListVm.sendCommentSetTopRequest(commentId: coModel.id, isTop: coModel.isTop == .pass ? false : true)
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
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(80)))
        lab.text = ""
        lab.backgroundColor = .clear//WHColor_ARC()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.layer.borderColor = UIColor.white.cgColor
        lab.layer.borderWidth = kFitWidth(2)
        
        return lab
    }()
    lazy var coverBlackView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: -SCREEN_WIDHT*2, y: -SCREEN_HEIGHT*2, width: SCREEN_WIDHT*5, height: SCREEN_HEIGHT*5))
        vi.backgroundColor = .black
        vi.isHidden = true
        
        return vi
    }()
}

extension ForumOfficialDetailVC{
    func updateThumbStatus() {
        if model.upvoteCount.intValue > 0 {
            bottomFuncVm.thumbsUpButton.setTitle("\(model.upvoteCount)", for: .normal)
            bottomFuncVm.thumbsUpButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        }else{
            bottomFuncVm.thumbsUpButton.setTitle("点赞", for: .normal)
            bottomFuncVm.thumbsUpButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        }
        if model.upvote == .pass{
            bottomFuncVm.thumbsUpButton.setImage(UIImage(named: "forum_thumbs_up_highlight_max"), for: .normal)
            bottomFuncVm.thumbsUpButton.setTitleColor(WHColor_16(colorStr: "F5BA18"), for: .normal)
        }else{
            bottomFuncVm.thumbsUpButton.setImage(UIImage(named: "forum_thumbs_up_max"), for: .normal)
            bottomFuncVm.thumbsUpButton.setTitleColor(.COLOR_GRAY_BLACK_45, for: .normal)
        }
    }
    func updateCommentCount() {
        if model.totalCommentCount.count > 0 && model.totalCommentCount.intValue > 0{
            bottomFuncVm.commonButton.setTitle("\(model.totalCommentCount)", for: .normal)
            bottomFuncVm.commonButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        }else{
            bottomFuncVm.commonButton.setTitle("评论", for: .normal)
            bottomFuncVm.commonButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        }
    }
    func showCommentAlertVm(coModel:ForumCommentModel,reModle:ForumCommentReplyModel) {
        if self.model.commentable == .refuse{
            MCToast.mc_text("评论功能已关闭")
            return
        }
        self.commomAlertVm.model = coModel
        self.commomAlertVm.reModel = reModle
        view.bringSubviewToFront(self.commomAlertVm)
        if !UserInfoModel.shared.ossParamIsValid(){
            self.sendOssStsRequest()
        }
        self.commomAlertVm.showView()
    }
    @objc func submitPollMultipleAction() {
        let pollArray = NSMutableArray()
        
        for pollItemmodel in model.pollModel.pollArray{
            if pollItemmodel.isSelect{
                pollArray.add(pollItemmodel.title)
            }
        }
        
        self.sendVotePollRequest(voteContent: pollArray)
    }
    //自动偏移到评论
    func scrollToCommentAuto() {
        
    }
    @objc func reloadCommentListImg() {
        self.commentListVm.tableView.reloadData()
    }
    func scroToComment(tableHeight:CGFloat) {
        DLLog(message: "tableViewisLoad:\(tableViewisLoad)  --- \(tableHeight)")
        if self.tableViewisLoad{
            DLLog(message: "tableViewisLoad:\(tableViewisLoad)  --- \(tableHeight)")
            self.isToComment = false
            DispatchQueue.main.asyncAfter(deadline: .now()+0.4, execute: {
                if self.commenListHeight > SCREEN_HEIGHT-self.naviVm.selfHeight-self.bottomFuncVm.selfHeight{
                    self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: tableHeight), animated: true)
                }else{
                    let offsetHeight = self.scrollViewBase.contentOffset.y
                    self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: offsetHeight), animated: true)
                }
            })
        }
    }
    func updateUIForNewsList(newsModel:ForumCommentNewsModel) {
        
    }
    func longPressHandle(vm: HeroBrowserViewModuleBaseProtocol) {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == PHAuthorizationStatus.authorized || status == PHAuthorizationStatus.notDetermined {
                //保存图片 actionSheet 使用我另一个库 JFPopup 实现，有兴趣欢迎star.
                JFPopupView.popup.actionSheet {
                    [
                        JFPopupAction(with: "保存", subTitle: nil) {
                            if let imgVM = vm as? HeroBrowserViewModule {
                                JFPopupView.popup.loading(hit: "图片保存中")
                                imgVM.asyncLoadRawSource { result in
                                    JFPopupView.popup.hideLoading()
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

extension ForumOfficialDetailVC:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.type == .poll ? 2 : 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return model.content.count > 0 ? 3 : 2
        }else{
            return model.pollModel.pollArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ForumOfficialTextCell") as? ForumOfficialTextCell
            if indexPath.row == 0 {
                cell?.updateContent(text: self.model.title)
                if self.model.content.count == 0 && self.model.type == .common{
                    self.tableViewisLoad = true
                    DLLog(message: "tableViewisLoad:\(tableViewisLoad)")
                }
            }else if indexPath.row == 1{
                if model.content.count > 0 {
                    cell?.contentRefreshBlock = {()in
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                    }
                    cell?.updateContentText(text: self.model.content)
                    if self.model.type == .common{
                        self.tableViewisLoad = true
                        DLLog(message: "tableViewisLoad:\(tableViewisLoad)")
                    }
                    
                }else{
                    cell?.updateTimeAndLocation(time: self.model.showTime, location: self.model.location)
                }
            }else{
                cell?.updateTimeAndLocation(time: self.model.showTime, location: self.model.location)
            }
            return cell ?? ForumOfficialTextCell()
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ForumOfficialPollCell") as? ForumOfficialPollCell
            let pollItemmodel = model.pollModel.pollArray[indexPath.row]
            cell?.updateUI(model: pollItemmodel, index: indexPath.row, hasImage: model.pollModel.hasImage == .pass)
            if model.pollModel.showResult == .pass && model.forumPostPollModel.isPoll {
                cell?.updatePercent(model: model.pollResultModel, hasImage: model.pollModel.hasImage == .pass)
                cell?.updateSelfChoice(model: model.forumPostPollModel)
            }else if model.pollModel.showResult == .refuse && model.forumPostPollModel.isPoll {
                cell?.updateSelfChoice(model: model.forumPostPollModel)
            }
            self.tableViewisLoad = true
            DLLog(message: "tableViewisLoad:\(tableViewisLoad)")
            return cell ?? PublishPollItemCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            if self.model.forumPostPollModel.isPoll == false{
//                if self.model.pollModel.pollType == .multiple{
                    let pollItemmodel = model.pollModel.pollArray[indexPath.row]
                    if self.pollSelectCount >= self.model.pollModel.optionThreshold && pollItemmodel.isSelect == false{
                        MCToast.mc_text("最多选择 \(self.model.pollModel.optionThreshold) 项",respond: .allow)
                    }else{
                        pollItemmodel.isSelect = !pollItemmodel.isSelect
                        
                        if pollItemmodel.isSelect {
                            self.pollSelectCount += 1
                        }else{
                            self.pollSelectCount -= 1
                        }
                        
                        let cell = self.tableView.cellForRow(at: indexPath) as? ForumOfficialPollCell
                        cell?.updateMultipleSelectStatus(isSelect: pollItemmodel.isSelect)
                        
                        if self.pollSelectCount > 0 {
                            self.pollFootVm.submitButton.isEnabled = true
                        }else{
                            self.pollFootVm.submitButton.isEnabled = false
                        }
                    }
//                }else{
//                    let pollItemmodel = model.pollModel.pollArray[indexPath.row]
//                    self.sendVotePollRequest(voteContent: [pollItemmodel.title])
//                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ForumOfficialTextCell") as? ForumOfficialTextCell
//            return cell?.detailLab.frame.height ?? tableView.estimatedRowHeight
            return tableView.estimatedRowHeight
        }else{
            if model.pollModel.hasImage == .pass{
                return kFitWidth(74)
            }else{
                return kFitWidth(48)
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            if self.model.contentType == .VIDEO{
                return videoVm
            }else if self.model.contentType == .IMAGE{
                return bannerImgVm
            }else{
                return nil
            }
        }else {
            return pollHeadVm
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if self.model.contentType == .VIDEO{
                return videoVm.selfHeight
            }else if self.model.contentType == .IMAGE{
                if self.model.imgsContent.count > 1{
                    return bannerHeight + kFitWidth(20)
                }else{
                    return bannerHeight
                }
            }else{
                return 0
            }
        }else {
            return pollHeadVm.selfHeight
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if model.type == .poll{
            if section == 0 {
                return nil
            }else {
                //不显示投票结果，且自己已投票
                if model.pollModel.showResult == .refuse && model.forumPostPollModel.isPoll {
//                    pollFootVm.leftTipsLabel.text = "已投票"
                    pollFootVm.numberLabel.text = ""
                    if model.forumPostPollModel.pollArray.count == 1{
                        var pollString = model.forumPostPollModel.pollArray[0].title
                        if pollString.count > 10 {
                            pollString = "\(pollString.mc_clipFromPrefix(to: 10))..."
                        }
                        pollFootVm.leftTipsLabel.text = "已选择:\(pollString)"
                    }else{
                        pollFootVm.leftTipsLabel.text = "已选择\(model.forumPostPollModel.pollArray.count)项"
                    }
//                    pollFootVm.numberLabel.text = "\(self.model.pollResultModel.participants) 人参与"
                }else{
                    if self.model.pollResultModel.participants > 0 && self.model.forumPostPollModel.isPoll{
//                        pollFootVm.leftTipsLabel.isHidden = true
                        if model.forumPostPollModel.pollArray.count == 1{
                            var pollString = model.forumPostPollModel.pollArray[0].title
                            if pollString.count > 10 {
                                pollString = "\(pollString.mc_clipFromPrefix(to: 10))..."
                            }
                            pollFootVm.leftTipsLabel.text = "已选择:\(pollString)"
                        }else{
                            pollFootVm.leftTipsLabel.text = "已选择\(model.forumPostPollModel.pollArray.count)项"
                        }
                        pollFootVm.numberLabel.text = "\(self.model.pollResultModel.participants) 人参与"
                    }else{
                        pollFootVm.leftTipsLabel.isHidden = false
                        pollFootVm.numberLabel.text = ""
                    }
                }
                
                return pollFootVm
            }
        }else{
            return nil
        }
        
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if model.type == .poll{
            if section == 0 {
                return 0
            }else {
//                self.tableViewisLoad = true
//                DLLog(message: "tableViewisLoad:\(tableViewisLoad)")
                if self.model.forumPostPollModel.isPoll{
                    self.pollFootVm.submitButton.isHidden = true
                    return kFitWidth(40)
                }else{
                    return kFitWidth(70)//self.model.pollModel.optionThreshold > 1 ? kFitWidth(70) : kFitWidth(40)
                }
            }
        }else{
//            self.tableViewisLoad = true
//            DLLog(message: "tableViewisLoad:\(tableViewisLoad)")
            return 0
        }
    }
}

extension ForumOfficialDetailVC:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollViewBase{//} && self.isLoadMoreComment == false{
            if scrollView.contentOffset.y < 0{
                scrollView.contentOffset.y = 0
            }
            if self.model.contentType == .VIDEO && self.isManualPause == false{
                if scrollView.contentOffset.y >= self.videoVm.selfHeight{
                    ZFPlayerModel.shared.playerManager.pause()
                }else{
                    if scrollView.contentOffset.y == 0 {
                        ZFPlayerModel.shared.playerManager.play()
                        self.controlView.hideWith(animated: true, isSingleTap: false)
                    }
//                    ZFPlayerModel.shared.playerManager.play()
//                    self.controlView.hideWith(animated: false, isSingleTap: false)
                }
            }
            
            let contentSizeHeight = self.scrollViewBase.contentSize.height - self.scrollViewBase.frame.height
//            DLLog(message: "contentSizeHeight:\(contentSizeHeight)    ---  scrollView.contentOffset.y:  \(scrollView.contentOffset.y)")
//            DLLog(message: "scrollViewDidScroll:\(abs(scrollView.contentOffset.y - contentSizeHeight + kFitWidth(150)))")
            if abs(scrollView.contentOffset.y - contentSizeHeight + kFitWidth(150)) <= kFitWidth(100){
                self.isLoadMoreComment = true
                self.commentListVm.loadMoreAction()
            }
        }
//        DLLog(message: "scrollViewBase.contentOffset.y:\(scrollViewBase.contentOffset.y)")
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.oldOffsetY = self.scrollViewBase.contentOffset.y
            DLLog(message: "tapCommentList----\(self.oldOffsetY)   - \(self.commentListVm.replyIndexPath)")
            if self.commomAlertVm.model.id.count == 0 && self.commomAlertVm.reModel.id.count == 0{
                return
            }
            
            var selectRect = self.commentListVm.tableView.rectForHeader(inSection: self.commentListVm.replyIndexPath.section)
            if self.commomAlertVm.model.id.count == 0{
                selectRect = self.commentListVm.tableView.rectForRow(at: self.commentListVm.replyIndexPath)
            }
            DLLog(message: "tapCommentList---- keyboardWillShow:-- \(selectRect)")
            DLLog(message: "tapCommentList---- keyboardWillShow:-- \(keyboardSize)")
            self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: self.commentListVm.frame.origin.y+selectRect.maxY+self.commomAlertVm.contentWhiteHeight+kFitWidth(10)+keyboardSize.size.height-self.scrollViewBase.frame.height-self.commentListVm.labelHeight-WHUtils().getBottomSafeAreaHeight()), animated: true)
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        DLLog(message: "tapCommentList----")
        self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: self.oldOffsetY), animated: true)
    }
    @objc func endFullAction() {
        self.coverBlackView.isHidden = false
        UserConfigModel.shared.userInterfaceOrientation = .landscapeLeft
        UserConfigModel.shared.allowedOrientations = .landscape
        if #available(iOS 16.0, *) {
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIDevice.current.setValue(NSNumber(value: UserConfigModel.shared.allowedOrientations.rawValue), forKey: "orientation")
//            ZFOrientationObserver()
            // Fallback on earlier versions
//            UIDevice.
        }
    }
    @objc func exitFullAction() {
//        UserConfigModel.shared.allowedOrientations = .portrait
//        UserConfigModel.shared.userInterfaceOrientation = .portrait
        UIView.animate(withDuration: 0.3) {
            self.coverBlackView.alpha = 0
        }completion: { t in
            self.coverBlackView.isHidden = true
            self.coverBlackView.alpha = 1
        }
        self.videoVm.controlView.rateView.isHidden = true
        UserConfigModel.shared.userInterfaceOrientation = .portrait
        UserConfigModel.shared.allowedOrientations = .portrait
        if #available(iOS 16.0, *) {
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIDevice.current.setValue(NSNumber(value: UserConfigModel.shared.allowedOrientations.rawValue), forKey: "orientation")
//            UIDevice.current.setValue(UserConfigModel.shared.allowedOrientations.rawValue, forKey: "orientation")
            // Fallback on earlier versions
        }
    }
}
extension ForumOfficialDetailVC{
    func initUI() {
        view.addSubview(naviVm)
        view.addSubview(scrollViewBase)
        naviVm.updateUI(model: self.model)
        
        view.backgroundColor = .white
        scrollViewBase.delegate = self
        scrollViewBase.backgroundColor = .white
        if #available(iOS 17.4, *) {
            scrollViewBase.bouncesVertically = true
        }
        scrollViewBase.contentInsetAdjustmentBehavior = .never
        scrollViewBase.frame = CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(4), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-naviVm.selfHeight-bottomFuncVm.selfHeight-kFitWidth(5))
        addSubviews()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getKeyWindow().addSubview(self.shareAlertVm)
    }
    func addSubviews() {
        getImgSize()
        
        self.scrollViewBase.addSubview(self.tableView)
        
        self.view.addSubview(self.bottomFuncVm)
        self.view.addSubview(self.commomAlertVm)
        self.view.addSubview(self.funcAlertVm)
        self.view.addSubview(self.reportAlertVm)
        self.bottomFuncVm.refreshUI(model: self.model)
        if self.model.commentable == .refuse{
            self.bottomFuncVm.textField.setDisableStatus()
        }else{
            self.scrollViewBase.addSubview(self.commentListVm)
//            self.scrollViewBase.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: {
//                self.commentListVm.loadMoreAction()
//            })
            let footer = ForumLoadingFooter.init(refreshingBlock: {
                self.commentListVm.loadMoreAction()
            })
            self.scrollViewBase.mj_footer = footer
        }
        self.scrollViewBase.addSubview(loadAllLabel)
        view.addSubview(coverBlackView)
    }
    func initVideo() {
        ZFPlayerModel.shared.player.addPlayerView(toContainerView: self.videoVm)
        ZFPlayerModel.shared.player.controlView = self.controlView
        ZFPlayerModel.shared.playerManager.play()
        ZFPlayerModel.shared.playerManager.volume = 1.0
        ZFPlayerModel.shared.player.playerDidToEnd = {(asset)in
            DLLog(message: "playerDidToEnd:")
//            self.playerManager?.seek(toTime: 0)
            ZFPlayerModel.shared.playerManager.replay()
        }
        ZFPlayerModel.shared.player.playerPlayFailed = {(asset,error)in
            DLLog(message: "playerPlayFailed:\(error)")
            ZFPlayerModel.shared.playerManager.play()
            ZFPlayerModel.shared.playerManager.player.volume = 1.0
        }
        ZFPlayerModel.shared.player.orientationWillChange = {player,isFullScreen in
            if isFullScreen{
                self.coverBlackView.isHidden = false
            }
            self.setNeedsStatusBarAppearanceUpdate()
            if #available(iOS 16.0, *) {
//                self.setNeedsUpdateOfSupportedInterfaceOrientations()
            } else {
                // Fallback on earlier versions
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
        ZFPlayerModel.shared.player.playerPlayTimeChanged = {asset,current,total in
//            DLLog(message: "playerPlayTimeChanged:\(current) -- \(total)")
            if current > 0.05{
                self.videoVm.videoImageView.isHidden = true
                self.controlView.hiddenCoverImgView()
//                ZFPlayerModel.shared.playerManager.scalingMode = .aspectFit
                UIView.animate(withDuration: 0.1) {
                    ZFPlayerModel.shared.player.currentPlayerManager.view.alpha = 1
                }
            }
        }
        ZFPlayerModel.shared.player.playerPlayStateChanged = { asset, state in
            DLLog(message: "playerPlayStateChanged : \(state)")
            if state == .playStatePaused{
                self.controlView.showWithAnimatedForPlayEnd()
                self.controlView.cancelAutoFadeOutControlView()
            }else{
                self.isManualPause = false
                self.controlView.autoFadeOutControlView()
            }
        }
//        ZFPlayerModel.shared.player.seek(toTime: self.currentSeekTime, completionHandler: { t in
//            ZFPlayerModel.shared.playerManager.play()
//            ZFPlayerModel.shared.playerManager.player.volume = 0.5
//        })
        
        ZFPlayerModel.shared.player.allowOrentitaionRotation = false
        ZFPlayerModel.shared.player.forceDeviceOrientation = true
    }
    func initPlayer() {
        if let videoUrl = self.model.videoUrl{
            ZFPlayerModel.shared.addToForumDetail(containerView: self.videoVm)
            ZFPlayerModel.shared.playerManager.scalingMode = .aspectFit
    //        ZFPlayerModel.shared.player.addPlayerView(toContainerView: self.videoVm)
            if self.controlView.superview != nil{
                self.controlView.removeFromSuperview()
            }
            ZFPlayerModel.shared.player.controlView = self.controlView
//            ZFPlayerModel.shared.player.assetURL = videoUrl
            ZFPlayerModel.shared.player.customAudioSession = true
            DSImageUploader().dealImgUrlSignForOss(urlStr: videoUrl.absoluteString, completion: { str in
                DLLog(message: "视频播放URL:\(str)")
                if let strURL = URL(string: str){
//                    DispatchQueue.global(qos: .userInteractive).async {
                        ZFPlayerModel.shared.player.assetURL = strURL
//                    }
                }
            })
//            ZFPlayerModel.shared.player.playerPrepareToPlay = {(asset ,assertUrl)in
////                ZFPlayerModel.shared.playerManager.player.automaticallyWaitsToMinimizeStalling = false
//                DispatchQueue.main.async {
//                    ZFPlayerModel.shared.playerManager.play()
//                }
//            }
            ZFPlayerModel.shared.player.playerPlayTimeChanged = {asset,current,total in
                if current > 0.05{
                    self.videoVm.videoImageView.isHidden = true
                    self.controlView.hiddenCoverImgView()
                    UIView.animate(withDuration: 0.1) {
                        ZFPlayerModel.shared.player.currentPlayerManager.view.alpha = 1
                    }
                }
            }
            ZFPlayerModel.shared.player.orientationWillChange = {player,isFullScreen in
                if isFullScreen{
                    self.coverBlackView.isHidden = false
                }
                self.setNeedsStatusBarAppearanceUpdate()
                if #available(iOS 16.0, *) {
    //                self.setNeedsUpdateOfSupportedInterfaceOrientations()
                } else {
                    // Fallback on earlier versions
                    UIViewController.attemptRotationToDeviceOrientation()
                }
            }
            ZFPlayerModel.shared.player.playerDidToEnd = {(asset)in
                DLLog(message: "playerDidToEnd:")
    //            self.playerManager?.seek(toTime: 0)
//                ZFPlayerModel.shared.playerManager.replay()
                ZFPlayerModel.shared.playerManager.seek(toTime: 0)
            }
            ZFPlayerModel.shared.player.playerPlayStateChanged = { asset, state in
//                DLLog(message: "playerPlayStateChanged : \(state)")
                if state == .playStatePaused{
                    self.controlView.showWithAnimatedForPlayEnd()
                    self.controlView.cancelAutoFadeOutControlView()
                }else{
                    self.isManualPause = false
                    self.controlView.autoFadeOutControlView()
                }
            }
        }
    }
}

extension ForumOfficialDetailVC{
    func getImgSize() {
        if model.imgsContent.count == 0 {
            return
        }
//        
//        if model.coverImgHeight > 0 && model.coverImgWidth > 0 {
//            let imgOriginH = SCREEN_WIDHT * model.coverImgHeight / model.coverImgWidth
//            if imgOriginH > SCREEN_WIDHT * 1.2 {
//                self.bannerHeight = SCREEN_WIDHT * 1.2
//            } else {
//                self.bannerHeight = imgOriginH
//            }
//            UIView.performWithoutAnimation {
//                self.tableView.beginUpdates()
//                self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .none)
//                self.tableView.endUpdates()
//            }
//            return
//        }

        let imgView = UIImageView()
        
        guard let imgUrl = URL(string: model.imgsContent[0]) else { return }
        
        DSImageUploader().dealImgUrlSignForOss(urlStr: model.imgsContent[0]) { signUrl in
            guard let resourceUrl = URL(string: signUrl) else{
                return
            }
            
            let resource = KF.ImageResource(downloadURL: resourceUrl, cacheKey: self.model.imgsContent[0])
            imgView.kf.setImage(with: resource,options: [.transition(.fade(0.2))]) { [self] result in
                DLLog(message: "result:\(result)")
                
                let imgOriSize = imgView.image?.size
                let imgOriginH = SCREEN_WIDHT * (imgOriSize?.height ?? 0)/(imgOriSize?.width ?? 1)
                if imgOriginH > SCREEN_WIDHT*1.2{
                    self.bannerHeight = SCREEN_WIDHT*1.2
                }else{
                    self.bannerHeight = imgOriginH
                }
                UIView.performWithoutAnimation {
                    self.tableView.beginUpdates()
                    self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .none)
                    self.tableView.endUpdates()
                }
            }
        }
        
    }
}

extension ForumOfficialDetailVC{
    func sendForumDetailRequest() {
        let param = ["id":"\(model.id)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_community_forum_detail, parameters: param as [String: AnyObject],isNeedToast: true,vc: self) { responseObject in
            DispatchQueue.global(qos: .userInitiated).async(execute: {
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
                DLLog(message: "sendForumDetailRequest:\(dataObj)")
                self.model = ForumModel().initWithDictCoverInfo(dict: dataObj)
                
                DispatchQueue.main.async {
                    self.naviVm.updateUI(model: self.model)
                    UIView.performWithoutAnimation {
                        self.tableView.reloadData()
                    }
                    
//                    self.tableView.setNeedsDisplay()
//                    self.tableView.layoutIfNeeded()
                
                    if self.commentId.count > 0 || self.replyId.count > 0 || self.commentDeleteString.count > 0 || self.isFromNewsList{
                        if self.model.contentType == .VIDEO{
                            self.initPlayer()
                        }else{
                            self.bannerImgVm.updateUI(dataArray: self.model.imgsContent as NSArray)
                        }
                    }
                    if self.model.contentType == .IMAGE{
                        self.getImgSize()
                    }
//                self.getImgSize()
                if self.model.totalCommentCount.intValue == 0 {
                    self.commentListVm.commentCountLabel.text = "评论"
                }else{
                    self.commentListVm.commentCountLabel.text = "评论 \(self.model.totalCommentCount)"
    //                self.commentListVm.commentCountLabel.text = "共 \(self.model.totalCommentCount) 条评论"
                }
                self.updateThumbStatus()
                self.updateCommentCount()
                }
                    
            })
        }
    }
    func sendCommentRequest() {
        let imgString = self.commomAlertVm.commonImgUrl.count > 0 ? self.getJSONStringFromArray(array: [self.commomAlertVm.commonImgUrl])
                                                                    : ""
        let param = ["id":"\(model.id)",
                     "content":"\(self.commomAlertVm.textView.text ?? "")",
                     "image":imgString]
        WHNetworkUtil.shareManager().POST(urlString: URL_community_comment_add, parameters: param as [String: AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendCommentRequest:\(dataObj)")
            
            self.bottomFuncVm.textField.textField.text = ""
            self.commomAlertVm.clearMSg()
            let coModel = ForumCommentModel().dealData(dict: dataObj)
            self.commentListVm.addComment(coModel: coModel)
            self.model.commentCount = "\(self.model.commentCount.intValue + 1)"
            self.model.totalCommentCount = "\(self.model.totalCommentCount.intValue + 1)"
            self.commentListVm.commentCountLabel.text = "共 \(self.model.totalCommentCount) 条评论"
            self.updateCommentCount()
            
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: self.commentListVm.frame.minY), animated: false)
            }
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
            self.model.totalCommentCount = "\(self.model.totalCommentCount.intValue + 1)"
            self.commentListVm.commentCountLabel.text = "共 \(self.model.totalCommentCount) 条评论"
            self.updateCommentCount()
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
        DLLog(message: "sendCommentReplyRequest(commentId:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_community_reply_add, parameters: param as [String: AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "sendCommentReplyRequest(commentId:\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendCommentReplyRequest(commentId:\(dataObj)")
            
            self.bottomFuncVm.textField.textField.text = ""
//            self.commomAlertVm.textView.text = ""
//            self.commomAlertVm.commonImgUrl = ""
//            self.commomAlertVm.showImgView(isShow: false)
            self.commomAlertVm.clearMSg()
            
            let reModel = ForumCommentReplyModel().dealData(dict: dataObj)
            self.commentListVm.addReply(reModel: reModel)
            self.model.totalCommentCount = "\(self.model.totalCommentCount.intValue + 1)"
            self.commentListVm.commentCountLabel.text = "共 \(self.model.totalCommentCount) 条评论"
            self.updateCommentCount()
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
            self.updateCommentCount()
        }
    }
    func sendDeleteReplyRequest(reModel:ForumCommentReplyModel) {
        let param = ["id":"\(reModel.id)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_community_reply_delete, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            self.commentListVm.deleteCommentReply()
            self.model.totalCommentCount = "\(self.model.totalCommentCount.intValue - 1)"
            
            if self.model.totalCommentCount.intValue == 0 {
                self.commentListVm.commentCountLabel.text = "评论"
            }else{
                self.commentListVm.commentCountLabel.text = "共 \(self.model.totalCommentCount) 条评论"
            }
            self.updateCommentCount()
        }
    }
    func sendReportCommentReqeust(bizType:String,id:String,reason:String) {
        let param = ["id":"\(id)",
                     "bizType":"\(bizType)",
                     "reason":"\(reason)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_report, parameters: param as [String:AnyObject],isNeedToast: true
                                          ,vc: self) { responseObject in
//            MCToast.mc_text("Elavatine已收到您的反馈",respond: .allow)
            MCToast.mc_text("\(responseObject["message"]as? String ?? "")",respond: .allow)
        }
    }
    
    func sendVotePollRequest(voteContent:NSArray) {
        let param = ["postId":"\(model.id)",
                     "pollOption":voteContent] as [String : Any]
        DLLog(message: "sendVotePollRequest param:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_poll_vote, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "sendVotePollRequest:\(responseObject)")
            //不返回投票结果的帖子，投票成功后，吐司提示
            if self.model.pollModel.showResult == .refuse{
                MCToast.mc_text("投票成功")
            }
            
            self.pollFootVm.submitButton.isEnabled = false
            self.pollFootVm.submitButton.isHidden = true
            self.pollFootVm.selfHeight = kFitWidth(40)
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendVotePollRequest:\(dataObj)")
            
            self.sendForumDetailRequest()
        }
    }
    func sendCreateShareLink(model:ForumModel,isShowShareView:Bool?=true) {
        let param = ["id":"\(model.id)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_community_forum_share_create, parameters: param as [String:AnyObject]) { responseObject in
            if isShowShareView == true{
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                DLLog(message: "sendCreateShareLink:\(dataString ?? "")")
                let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
                model.webLink = dataDict.stringValueForKey(key: "weblink")
                self.shareAlertVm.showView(model: model)
            }
        }
    }
    func sendOssStsRequest() {
        WHNetworkUtil.shareManager().GET(urlString: URL_OSS_sts) { responseObject in
            DLLog(message: "\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            UserInfoModel.shared.updateOssParams(dict: self.getDictionaryFromJSONString(jsonString: dataString ?? ""))
        }
    }
    func sendDeleteForumRequest() {
        let param = ["id":"\(model.id)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_delete, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            self.deleteBlock?(self.model)
            self.backTapAction()
        }
    }
}
