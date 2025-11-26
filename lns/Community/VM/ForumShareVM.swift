//
//  ForumShareVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/6.
//
import UIKit
import Foundation
import MCToast

enum SHARE_TYPE {
    case forum   // 分享帖子
    case tutorial// 分享教程
}

class ForumShareVM: UIView {
    
    var whiteViewHeight = kFitWidth(140) + WHUtils().getBottomSafeAreaHeight() + kFitWidth(16)
    
    var model = ForumModel()
    var tutorialModel = ForumTutorialModel()
    var thumbImg = UIImage()
    
    var shareType = SHARE_TYPE.forum
    
    var reportForumBlock:(()->())?
    var deleteForumBlock:(()->())?
    /// 蒙层目标透明度：浅色 0.15，深色 0.85
    private var targetDimAlpha: CGFloat {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.25
        } else {
            // iOS 13 以下没有深色模式，按浅色处理
            return 0.25
        }
    }
    // 主题变更时（例如从浅色切到深色）同步调整蒙层透明度
   override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
       super.traitCollectionDidChange(previousTraitCollection)
       UIView.animate(withDuration: 0.2) {
           self.bgView.alpha = self.targetDimAlpha
           self.cancelButton.setBackgroundImage(createImageWithColor(color: .COLOR_CARD_BG_WHITE), for: .normal)
       }
   }
    override init(frame:CGRect){
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//.COLOR_BG_BLACK.withAlphaComponent(0.65)//WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
//        self.alpha = 0
        self.isHidden = true
        initUI()
        
        // [修改] 仅在背景层（self）加一个 tap；不取消子视图触摸；并用 delegate 过滤 whiteView 内部触点，避免拦截按钮
        let bgTap = UITapGestureRecognizer(target: self, action: #selector(hiddenView))
        bgTap.cancelsTouchesInView = false // [修改] 关键：不取消按钮的 touches（否则 .touchUpInside 触发不了）
        bgTap.delegate = self             // [修改] 用于过滤 whiteView 内部区域
        self.addGestureRecognizer(bgTap)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = .COLOR_ALERT_BG_BLACK//WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenView))
        v.addGestureRecognizer(tap)
        return v
    }()
    lazy var whiteView : UIView = {
        let vi = UIView(frame: CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.alpha = 0
        
        return vi
    }()
    
    // MARK: - Share Buttons
    lazy var wechatButton : PlanShareButton = {
        let btn = PlanShareButton(frame: CGRect(x: kFitWidth(27), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "forum_share_wechat_icon")
        btn.contenLab.text = "微信"
        btn.contenLab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        btn.labelColor = .COLOR_TEXT_TITLE_0f1214_50
        btn.contenLab.font = .systemFont(ofSize: 12, weight: .medium)
        btn.tapBlock = { [weak self] in
            guard let self else { return }
            self.shareToSession()
            self.wechatButton.contenLab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        }
        return btn
    }()
    lazy var circleButton : PlanShareButton = {
        let btn = PlanShareButton(frame: CGRect(x: kFitWidth(115), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "forum_share_circle_icon")
        btn.contenLab.text = "朋友圈"
        btn.contenLab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        btn.labelColor = .COLOR_TEXT_TITLE_0f1214_50
        btn.contenLab.font = .systemFont(ofSize: 12, weight: .medium)
        btn.tapBlock = { [weak self] in
            guard let self else { return }
            self.shareToTimeLine()
            self.circleButton.contenLab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        }
        return btn
    }()
    lazy var copyButton : PlanShareButton = {
        let btn = PlanShareButton(frame: CGRect(x: kFitWidth(203), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "forum_share_copy_icon")
        btn.contenLab.text = "复制链接"
        btn.contenLab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        btn.labelColor = .COLOR_TEXT_TITLE_0f1214_50
        btn.contenLab.font = .systemFont(ofSize: 12, weight: .medium)
        btn.tapBlock = { [weak self] in
            guard let self else { return }
            self.copyLinkAction()
            self.copyButton.contenLab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        }
        return btn
    }()
    lazy var reportButton : PlanShareButton = {
        let btn = PlanShareButton(frame: CGRect(x: kFitWidth(291), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "forum_share_report_icon")
        btn.contenLab.text = "举报"
        btn.contenLab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        btn.labelColor = .COLOR_TEXT_TITLE_0f1214_50
        btn.contenLab.font = .systemFont(ofSize: 12, weight: .medium)
        btn.tapBlock = { [weak self] in
            guard let self else { return }
            self.reportAction()
            self.reportButton.contenLab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        }
        return btn
    }()
    lazy var deleteButton : PlanShareButton = {
        let btn = PlanShareButton(frame: CGRect(x: kFitWidth(291), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60)))
        btn.contenLab.text = "删除"
        btn.imgView.image = UIImage(systemName: "trash.fill")
        btn.imgView.tintColor = .systemRed
        btn.isHidden = true
        btn.contenLab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        btn.labelColor = .COLOR_TEXT_TITLE_0f1214_50
        btn.contenLab.font = .systemFont(ofSize: 12, weight: .medium)
        btn.tapBlock = { [weak self] in
            guard let self else { return }
            self.deleteAction()
            self.deleteButton.contenLab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        }
        return btn
    }()
    lazy var lineGapView: UIView = {
        let vi = UIView(frame: CGRect(x: 0, y: kFitWidth(92), width: SCREEN_WIDHT, height: kFitWidth(8)))
        vi.backgroundColor = .COLOR_LINE_F0
        return vi
    }()
    lazy var cancelButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: kFitWidth(100), width: SCREEN_WIDHT, height: kFitWidth(40)))
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_CARD_BG_WHITE), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_LINE_F0), for: .highlighted)
        btn.setTitle("取消", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        return btn
    }()
}

// MARK: - Share Actions
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
            // NOTE: 这里你原逻辑是 "1"，如果朋友圈应该是 "2"，可按后端约定调整
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
        MBProgressHUD.xy_show("链接已复制！")
        self.hiddenView()
    }
    func reportAction() {
        reportForumBlock?()
        self.hiddenView()
    }
    func deleteAction() {
        deleteForumBlock?()
        self.hiddenView()
    }
}

// MARK: - Show / Hide
extension ForumShareVM{
    @objc func nothingAction(){ /* 保留空实现 */ }
    
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

        lineGapView.frame = CGRect(x: 0, y: kFitWidth(92), width: bounds.width, height: kFitWidth(8))
        cancelButton.frame = CGRect(x: 0, y: kFitWidth(100), width: bounds.width, height: kFitWidth(40))
        
        // 拼出要下载的图片 URL
        var thumbImgUrl = model.headImgUrl
        if model.covers.count > 0 {
            if model.coverType == .IMAGE {
                thumbImgUrl = model.covers[0] as? String ?? ""
            } else {
                thumbImgUrl = model.coverThumbImgUrl
            }
        }

        // 下载并尽量压缩到 ≤256KB
        if let imgUrl = URL(string: thumbImgUrl), thumbImgUrl.count > 0 {
            DSImageUploader().dealImgUrlSignForOss(urlStr: thumbImgUrl) { _ in
                WHUtils().downloadImage(from: imgUrl) { img in
                    guard let originalImage = img else { return }
                    if let compressedData = originalImage.compressed(toMaxKB: 256),
                       let compressedImage = UIImage(data: compressedData) {
                        self.thumbImg = compressedImage
                        let sizeKB = Double(compressedData.count) / 1024.0
                        DLLog(message: "下载后并压缩到 ≤256KB，最终大小约为 \(String(format: "%.1f", sizeKB))kb")
                    } else {
                        self.thumbImg = originalImage
                        print("下载完成，但压缩失败，thumbImg 保持原图")
                    }
                }
            }
        }

        self.bgView.alpha = 0
        // 动画展示弹窗
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
//            self.alpha = 1
            self.bgView.alpha = self.targetDimAlpha
            self.whiteView.alpha = 1
            self.whiteView.center = CGPoint(x: bounds.width * 0.5,
                                            y: (bounds.height - self.whiteViewHeight * 0.5 + kFitWidth(16)))
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
        lineGapView.frame = CGRect(x: 0, y: kFitWidth(92), width: bounds.width, height: kFitWidth(8))
        cancelButton.frame = CGRect(x: 0, y: kFitWidth(100), width: bounds.width, height: kFitWidth(40))
        let buttonY = copyButton.center.y
        
        if WXApi.isWXAppInstalled(){
            wechatButton.isHidden = false
            circleButton.isHidden = false
            wechatButton.center = CGPoint(x: bounds.width*0.25, y: buttonY)
            circleButton.center = CGPoint(x: bounds.width*0.5,  y: buttonY)
            copyButton.center   = CGPoint(x: bounds.width*0.75, y: buttonY)
        }else{
            wechatButton.isHidden = true
            circleButton.isHidden = true
            copyButton.center = CGPoint(x: bounds.width*0.5, y: buttonY)
        }
        
        self.bgView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
//            self.alpha = 1
            self.bgView.alpha = self.targetDimAlpha
            self.whiteView.alpha = 1
            self.whiteView.center = CGPoint(x: bounds.width*0.5,
                                            y: (bounds.height - self.whiteViewHeight*0.5 + kFitWidth(16)))
        }
    }
    
    @objc func hiddenView() {
        let bounds = appDelegate.getKeyWindow().bounds
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
//            self.alpha = 0
            self.bgView.alpha = 0
            self.whiteView.alpha = 0.7
            self.whiteView.center = CGPoint(x: bounds.width*0.5,
                                            y: bounds.height*1.5 + kFitWidth(16))
        } completion: { _ in
            self.isHidden = true
        }
    }
    
    func updateForShare() {
        circleButton.frame = CGRect(x: kFitWidth(159), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60))
        copyButton.frame   = CGRect(x: kFitWidth(290), y: kFitWidth(20), width: kFitWidth(58), height: kFitWidth(60))
        reportButton.isHidden = true
    }
}

extension ForumShareVM{
    func initUI() {
        addSubview(bgView)
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

// MARK: - Network
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

// MARK: - 关键：只让背景 tap 生效，whiteView 内部交给按钮
extension ForumShareVM: UIGestureRecognizerDelegate {
    // [修改] 过滤：如果触点在 whiteView 内，就让按钮去处理；还要避免拦截 UIControl（按钮等）
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let p = touch.location(in: whiteView)
        if whiteView.bounds.contains(p) { return false } // whiteView 内部不处理背景 tap
        if touch.view is UIControl { return false }      // 避免拦截按钮
        return true
    }
}
