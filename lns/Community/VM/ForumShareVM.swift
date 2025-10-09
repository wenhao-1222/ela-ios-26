//
//  ForumShareVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/6.
//

enum SHARE_TYPE {
    case forum//分享帖子
    case tutorial//分享教程
}

import MCToast

class ForumShareVM: UIView {
    
    var whiteViewHeight = kFitWidth(140) + WHUtils().getBottomSafeAreaHeight() + kFitWidth(16)
    
    var model = ForumModel()
    var tutorialModel = ForumTutorialModel()
    var thumbImg = UIImage()
    
    var shareType = SHARE_TYPE.forum
    
    var reportForumBlock:(()->())?
    var deleteForumBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
        self.alpha = 0
        self.isHidden = true
        initUI()
        
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        vi.alpha = 0
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var wechatButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(27), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "forum_share_wechat_icon")
        btn.contenLab.text = "微信"
        btn.contenLab.textColor = .COLOR_GRAY_BLACK_45
        btn.labelColor = .COLOR_GRAY_BLACK_45
        btn.contenLab.font = .systemFont(ofSize: 12, weight: .medium)
        btn.tapBlock = {()in
            self.shareToSession()
            self.wechatButton.contenLab.textColor = .COLOR_GRAY_BLACK_45
        }
        return btn
    }()
    lazy var circleButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(115), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60)))
//        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(159), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "forum_share_circle_icon")
        btn.contenLab.text = "朋友圈"
        btn.contenLab.textColor = .COLOR_GRAY_BLACK_45
        btn.labelColor = .COLOR_GRAY_BLACK_45
        btn.contenLab.font = .systemFont(ofSize: 12, weight: .medium)
        btn.tapBlock = {()in
            self.shareToTimeLine()
            self.circleButton.contenLab.textColor = .COLOR_GRAY_BLACK_45
        }
        
        return btn
    }()
    lazy var copyButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(203), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60)))
//        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(290), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "forum_share_copy_icon")
        btn.contenLab.text = "复制链接"
        btn.contenLab.textColor = .COLOR_GRAY_BLACK_45
        btn.labelColor = .COLOR_GRAY_BLACK_45
        btn.contenLab.font = .systemFont(ofSize: 12, weight: .medium)
        btn.tapBlock = {()in
            self.copyLinkAction()
            self.copyButton.contenLab.textColor = .COLOR_GRAY_BLACK_45
        }
        return btn
    }()
    lazy var reportButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(291), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "forum_share_report_icon")
        btn.contenLab.text = "举报"
        btn.contenLab.textColor = .COLOR_GRAY_BLACK_45
        btn.labelColor = .COLOR_GRAY_BLACK_45
        btn.contenLab.font = .systemFont(ofSize: 12, weight: .medium)
        btn.tapBlock = {()in
            self.reportAction()
            self.reportButton.contenLab.textColor = .COLOR_GRAY_BLACK_45
        }
        return btn
    }()
    lazy var deleteButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(291), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60)))
//        btn.imgView.setImgLocal(imgName: "forum_share_delete_icon")
        btn.contenLab.text = "删除"
//        btn.imgView.frame =  CGRect.init(x: kFitWidth(13), y: kFitWidth(3), width: kFitWidth(34), height: kFitWidth(34))
        btn.imgView.image = UIImage(systemName: "trash.fill")
        btn.imgView.tintColor = .systemRed
        btn.isHidden = true
        btn.contenLab.textColor = .COLOR_GRAY_BLACK_45
        btn.labelColor = .COLOR_GRAY_BLACK_45
        btn.contenLab.font = .systemFont(ofSize: 12, weight: .medium)
        btn.tapBlock = {()in
            self.deleteAction()
            self.deleteButton.contenLab.textColor = .COLOR_GRAY_BLACK_45
        }
        return btn
    }()
    lazy var lineGapView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: kFitWidth(92), width: SCREEN_WIDHT, height: kFitWidth(8)))
        vi.backgroundColor = .COLOR_LIGHT_GREY
        return vi
    }()
    lazy var cancelButton: UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x: 0, y: kFitWidth(100), width: SCREEN_WIDHT, height: kFitWidth(40)))
        btn.setBackgroundImage(createImageWithColor(color: .white), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_LINE_GREY), for: .highlighted)
        btn.setTitle("取消", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        
        return btn
    }()
}

extension ForumShareVM{
    @objc func shareToSession(){
        let message = WXMediaMessage()
        
        if self.thumbImg.isSizeLessThanKB(256){
            message.setThumbImage(self.thumbImg)
        }else{
            if let img = UIImage(named: "control_widget_icon") {
                message.setThumbImage(img)
            }
        }
        let obj = WXWebpageObject()
        if self.shareType == .tutorial{
            message.title = "\(tutorialModel.title)"
            message.description = "\(tutorialModel.subTitle)"
            obj.webpageUrl = tutorialModel.webLink
        }else{
            message.title = "\(model.title)"
            if model.poster == .platform{
                message.description = "\(model.subTitle)"
            }else{
                message.description = "\(model.content)"
            }
            obj.webpageUrl = model.webLink
        }
        
        message.mediaObject = obj
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(WXSceneSession.rawValue)
        WXApi.send(req)
        if self.tutorialModel.id.count > 0 {
            sendShareTutorialRequest(channelType: "1")
        }else{
            sendShareRequest(channelType: "1")
        }
        
        self.hiddenView()
    }
    @objc func shareToTimeLine(){
        let message = WXMediaMessage()
        if self.thumbImg.isSizeLessThanKB(256){
            message.setThumbImage(self.thumbImg)
        }else{
            if let img = UIImage(named: "control_widget_icon") {
                message.setThumbImage(img)
            }
        }
        let obj = WXWebpageObject()
        
        if self.shareType == .tutorial{
            message.title = "\(tutorialModel.title)"
            message.description = "\(tutorialModel.subTitle)"
            obj.webpageUrl = tutorialModel.webLink
        }else{
            message.title = "\(model.title)"
            if model.poster == .platform{
                message.description = "\(model.subTitle)"
            }else{
                message.description = "\(model.content)"
            }
            
            obj.webpageUrl = model.webLink
        }
            
        message.mediaObject = obj
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(WXSceneTimeline.rawValue)
        WXApi.send(req)
        if self.tutorialModel.id.count > 0 {
            sendShareTutorialRequest(channelType: "2")
        }else{
            sendShareRequest(channelType: "1")
        }
        self.hiddenView()
    }
    func copyLinkAction(){
        if self.shareType == .tutorial{
            UIPasteboard.general.string = "\(self.tutorialModel.webLink)"
        }else{
            UIPasteboard.general.string = "\(self.model.webLink)"
        }
        
        if self.tutorialModel.id.count > 0 {
            sendShareTutorialRequest(channelType: "3")
        }else{
            sendShareRequest(channelType: "1")
        }
//        MCToast.mc_success("链接已复制！")
        MBProgressHUD.xy_show("链接已复制！")
        self.hiddenView()
    }
    func reportAction() {
        if self.reportForumBlock != nil{
            self.reportForumBlock!()
        }
        self.hiddenView()
    }
    func deleteAction() {
        if self.deleteForumBlock != nil{
            self.deleteForumBlock!()
        }
        self.hiddenView()
    }
}

extension ForumShareVM{
    @objc func nothingAction(){
        
    }
    func showView(model:ForumModel) {
        self.shareType = .forum
        self.isHidden = false
        self.model = model
        
        if self.model.authorUid == UserInfoModel.shared.uId{
            deleteButton.isHidden = false
            reportButton.isHidden = true
        }
        // 保证在当前屏幕尺寸下展示
               let bounds = appDelegate.getKeyWindow().bounds
               self.frame = bounds
               whiteView.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: whiteViewHeight)

        lineGapView.frame = CGRect.init(x: 0, y: kFitWidth(92), width: bounds.width, height: kFitWidth(8))
        cancelButton.frame =  CGRect.init(x: 0, y: kFitWidth(100), width: bounds.width, height: kFitWidth(40))
        // 先拼出要下载的图片 URL
            var thumbImgUrl = model.headImgUrl
            if model.covers.count > 0 {
                if model.coverType == .IMAGE {
                    thumbImgUrl = model.covers[0] as? String ?? ""
                } else {
                    thumbImgUrl = model.coverThumbImgUrl
                }
            }

            // 如果有有效的 URL，就去下载原图，下载完成后立即压缩到 ≤256KB
            if let imgUrl = URL(string: thumbImgUrl), thumbImgUrl.count > 0 {
                DSImageUploader().dealImgUrlSignForOss(urlStr: thumbImgUrl) { _ in
                    WHUtils().downloadImage(from: imgUrl) { img in
                        guard let originalImage = img else { return }
                        
                        // 尝试压缩到 ≤256 KB
                        if let compressedData = originalImage.compressed(toMaxKB: 256),
                           let compressedImage = UIImage(data: compressedData) {
                            self.thumbImg = compressedImage
                            let sizeKB = Double(compressedData.count) / 1024.0
                            DLLog(message: "下载后并压缩到 ≤256KB，最终大小约为 \(String(format: "%.1f", sizeKB))kb")
//                            print("下载后并压缩到 ≤256KB，最终大小约为 \(String(format: "%.1f", sizeKB)"KB))
                        } else {
                            // 如果压缩失败，就直接用原图（可能超限）
                            self.thumbImg = originalImage
                            print("下载完成，但压缩失败，thumbImg 保持原图")
                        }
                    }
                }
            }

            // 动画展示弹窗
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
                self.alpha = 1
                self.whiteView.alpha = 1
                self.whiteView.center = CGPoint(x: SCREEN_WIDHT * 0.5,
                                                y: (SCREEN_HEIGHT - self.whiteViewHeight * 0.5 + kFitWidth(16)))
            }
    }
    
    func showViewForTutorial(tutorialMo:ForumTutorialModel) {
        self.shareType = .tutorial
        self.isHidden = false
        self.reportButton.isHidden = true
        self.tutorialModel = tutorialMo
        self.thumbImg = tutorialModel.coverImg ?? UIImage()
        
        // 保证在当前屏幕尺寸下展示
        let bounds = appDelegate.getKeyWindow().bounds
        self.frame = bounds
        whiteView.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: whiteViewHeight)
        lineGapView.frame = CGRect.init(x: 0, y: kFitWidth(92), width: bounds.width, height: kFitWidth(8))
        cancelButton.frame =  CGRect.init(x: 0, y: kFitWidth(100), width: bounds.width, height: kFitWidth(40))
        let buttonY = copyButton.center.y
        
        let copyButtonCenter = copyButton.center
        if WXApi.isWXAppInstalled(){
            wechatButton.isHidden = false
            circleButton.isHidden = false
//            wechatButton.center = CGPoint.init(x: SCREEN_WIDHT*0.25, y: copyButtonCenter.y)
//            circleButton.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: copyButtonCenter.y)
//            copyButton.center = CGPoint.init(x: SCREEN_WIDHT*0.75, y: copyButtonCenter.y)
            
            wechatButton.center = CGPoint(x: bounds.width*0.25, y: buttonY)
                        circleButton.center = CGPoint(x: bounds.width*0.5, y: buttonY)
                        copyButton.center = CGPoint(x: bounds.width*0.75, y: buttonY)
        }else{
            wechatButton.isHidden = true
            circleButton.isHidden = true
//            copyButton.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: copyButtonCenter.y)
            copyButton.center = CGPoint(x: bounds.width*0.5, y: buttonY)
        }
        
        
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.alpha = 1
            self.whiteView.alpha = 1
//            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: (SCREEN_HEIGHT-self.whiteViewHeight*0.5+kFitWidth(16)))
            self.whiteView.center = CGPoint(x: bounds.width*0.5,
                                                        y: (bounds.height-self.whiteViewHeight*0.5+kFitWidth(16)))
        }
    }
    @objc func hiddenView() {
        let bounds = appDelegate.getKeyWindow().bounds
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.alpha = 0
            self.whiteView.alpha = 0.7
//            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
            self.whiteView.center = CGPoint(x: bounds.width*0.5,
                                                        y: bounds.height*1.5+kFitWidth(16))
        }completion: { t in
            self.isHidden = true
        }
    }
    func updateForShare() {
        circleButton.frame = CGRect.init(x: kFitWidth(159), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60))
        copyButton.frame = CGRect.init(x: kFitWidth(290), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60))
        reportButton.isHidden = true
    }
}
extension ForumShareVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(wechatButton)
        whiteView.addSubview(circleButton)
        whiteView.addSubview(copyButton)
        whiteView.addSubview(reportButton)
        whiteView.addSubview(deleteButton)
        
        whiteView.addSubview(lineGapView)
        whiteView.addSubview(cancelButton)
    }
    
}

extension ForumShareVM{
    func sendShareRequest(channelType:String) {
        let param = ["id":"\(model.id)",
                     "channel":"\(channelType)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_community_forum_share, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "sendShareRequest:\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            DLLog(message: "sendShareRequest:\(dataString ?? "")")
        }
    }
    func sendShareTutorialRequest(channelType:String) {
        let param = ["id":"\(self.tutorialModel.id)",
                     "channel":"\(channelType)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_tutorial_share, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "sendShareTutorialRequest:\(responseObject)")
        }
    }
}
