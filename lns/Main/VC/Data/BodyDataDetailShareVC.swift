//
//  BodyDataDetailShareVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/18.
//

import Foundation
import Photos
import MCToast

class BodyDataDetailShareVC: WHBaseViewVC {
    
    var dataTypeName = "体重"
    var unitString = "kg"
    var showTypeString = ""
    var showColor = "000000"//"005CBF"
    
    var dataArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        whLineChart.setDataArray(dataArray as! [Any], andKey: showTypeString)
        dealDataArray()
    }
    lazy var whiteView : UIView = {
        var vi = UIView.init(frame: CGRect.init(x: kFitWidth(28), y: kFitWidth(56)+getNavigationBarHeight(), width: SCREEN_WIDHT-kFitWidth(56), height: (SCREEN_WIDHT-kFitWidth(56))*1.25))
        if isIpad(){
            vi = UIView.init(frame: CGRect.init(x: kFitWidth(28), y: kFitWidth(56)+getNavigationBarHeight(), width: SCREEN_WIDHT-kFitWidth(56), height: (SCREEN_WIDHT-kFitWidth(56))*1.1))
        }
        vi.backgroundColor = .white
//        vi.addClipCorner(corners: [.bottomLeft,.bottomRight], radius: kFitWidth(16))
        vi.layer.cornerRadius = kFitWidth(24)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var bgImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "data_share_bg")
        
        return img
    }()
    lazy var avatarImgView : UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: kFitWidth(24), y: kFitWidth(24), width: kFitWidth(32), height: kFitWidth(32)))
        img.setImgUrl(urlString: UserInfoModel.shared.headimgurl)
        img.layer.cornerRadius = kFitWidth(16)
        img.clipsToBounds = true
        
        return img
    }()
    lazy var nameLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.text = "\(UserInfoModel.shared.nickname)"
        
        return lab
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "给你分享了一条身体数据"
        
        return lab
    }()
    lazy var leftThemeRectView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
                
        return vi
    }()
    lazy var typeLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColor_16(colorStr: "3D5166")
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.text = "\(dataTypeName)变化"
        
        return lab
    }()
    lazy var numberLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColor_16(colorStr: "3D5166")
        lab.font = UIFont().DDInFontMedium(fontSize: 40)
        return lab
    }()
    lazy var ascImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "data_share_asc_icon")
        
        return img
    }()
    lazy var unitLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColor_16(colorStr: "3D5166")
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.text = "\(unitString)"
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "3D5166")
        
        return vi
    }()
    lazy var whLineChart: DataDetailShareLineView = {
        let line = DataDetailShareLineView.init(frame: CGRect.init(x: 0, y: kFitWidth(76), width: SCREEN_WIDHT-kFitWidth(56), height: kFitWidth(160)))
        line.unitString = self.unitString
        return line
    }()
    
    lazy var wechatButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(50), y: self.whiteView.frame.maxY+kFitWidth(40), width: kFitWidth(58), height: kFitWidth(60)))
        if isIpad(){
            btn.center = CGPoint.init(x: SCREEN_WIDHT*0.25, y: self.whiteView.frame.maxY+kFitWidth(40))
        }
        btn.imgView.setImgLocal(imgName: "plan_share_wechat_icon")
        btn.contenLab.text = "微信"
        btn.tapBlock = {()in
            self.shareToSession()
        }
//        btn.addTarget(self, action: #selector(shareToSession), for: .touchUpInside)
        return btn
    }()
    lazy var circleButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(158), y: self.whiteView.frame.maxY+kFitWidth(40), width: kFitWidth(58), height: kFitWidth(60)))
        if isIpad(){
            btn.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteView.frame.maxY+kFitWidth(40))
        }
        btn.imgView.setImgLocal(imgName: "plan_share_circle_icon")
        btn.contenLab.text = "朋友圈"
        btn.tapBlock = {()in
            self.shareToTimeLine()
        }
//        btn.addTarget(self, action: #selector(shareToTimeLine), for: .touchUpInside)
        return btn
    }()
    lazy var saveButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(266), y: self.whiteView.frame.maxY+kFitWidth(40), width: kFitWidth(58), height: kFitWidth(60)))
        if isIpad(){
            btn.center = CGPoint.init(x: SCREEN_WIDHT*0.75, y: self.whiteView.frame.maxY+kFitWidth(40))
        }
        btn.imgView.setImgLocal(imgName: "plan_share_save_icon")
        btn.contenLab.text = "保存图片"
        btn.tapBlock = {()in
            self.saveAction()
        }
//        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return btn
    }()
}

extension BodyDataDetailShareVC{
    func initUI() {
        view.backgroundColor = WHColor_16(colorStr: "1F2833")
        initNavi(titleStr: "分享",isWhite: true)
        self.navigationView.backgroundColor = .clear
//        self.backArrowButton.setImage(UIImage(named: "plan_share_close_icon"), for: .normal)
//        self.backArrowButton.setImage(UIImage(named: "plan_share_close_icon"), for: .highlighted)
//        self.backArrowButton.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        
        self.backArrowButton.setImgName(imgName: "plan_share_close_icon")
        
        view.addSubview(whiteView)
        whiteView.addSubview(bgImgView)
        whiteView.addSubview(avatarImgView)
        whiteView.addSubview(nameLabel)
        whiteView.addSubview(tipsLabel)
        whiteView.addSubview(leftThemeRectView)
        whiteView.addSubview(typeLabel)
        whiteView.addSubview(numberLabel)
        whiteView.addSubview(ascImgView)
        whiteView.addSubview(unitLabel)
        whiteView.addSubview(lineView)
        whiteView.addSubview(whLineChart)
        
        if WXApi.isWXAppInstalled(){
            view.addSubview(wechatButton)
            view.addSubview(circleButton)
            view.addSubview(saveButton)
        }else{
            view.addSubview(saveButton)
            saveButton.frame = circleButton.frame
        }
        
        setConstrait()
    }
    
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
//            make.height.equalTo(kFitWidth(320))
            make.height.equalTo(SCREEN_WIDHT-kFitWidth(56))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(64))
            make.top.equalTo(kFitWidth(24))
        }
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(64))
            make.top.equalTo(kFitWidth(44))
        }
        lineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(103))
            make.height.equalTo(kFitWidth(1))
            make.bottom.equalTo(kFitWidth(-40))
        }
        leftThemeRectView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(kFitWidth(6))
            make.height.equalTo(kFitWidth(24))
            make.bottom.equalTo(kFitWidth(-53))
        }
        typeLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.centerY.lessThanOrEqualTo(leftThemeRectView)
        }
        ascImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-24))
            make.bottom.equalTo(kFitWidth(-69))
            make.width.equalTo(kFitWidth(24))
            make.height.equalTo(kFitWidth(16))
        }
        unitLabel.snp.makeConstraints { make in
            make.left.equalTo(ascImgView)
            make.top.equalTo(ascImgView.snp.bottom).offset(kFitWidth(1))
        }
        numberLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-56))
            make.centerY.lessThanOrEqualTo(leftThemeRectView)
        }
    }
}

extension BodyDataDetailShareVC{
    func dealDataArray() {
        var minNumber = 0
        var maxNumber = 0
        
        let startDict = self.dataArray.firstObject as? NSDictionary ?? [:]
        let endDict = self.dataArray.lastObject as? NSDictionary ?? [:]
        
        let firstNumber = startDict.doubleValueForKey(key: showTypeString)
        let lastNumber = endDict.doubleValueForKey(key: showTypeString)
        
        let num = lastNumber - firstNumber
        
        numberLabel.text = WHUtils.convertStringToString("\(abs(num))")
        
        if num < 0 {
            ascImgView.setImgLocal(imgName: "data_share_desc_icon")
        }else if num > 0 {
            ascImgView.setImgLocal(imgName: "data_share_asc_icon")
        }else{
            ascImgView.setImgLocal(imgName: "data_share_ping_icon")
        }
    }
    
}

extension BodyDataDetailShareVC{
    @objc func shareToSession(){
        let image = self.whiteView.mc_makeImage()
        
        let message = WXMediaMessage()
        message.setThumbImage(UIImage.init(named: "avatar_default")!)
        message.title = "标题"
        message.description = "描述"
        
        let obj = WXImageObject()
        
        // 将UIImage转换为PNG格式的Data
        if let pngData = image.pngData() {
            // 使用pngData
            print("转换成PNG格式的数据成功，数据长度：\(pngData.count)")
            obj.imageData = pngData
            
        } else {
            print("转换成PNG格式的数据失败")
        }
        
        message.mediaObject = obj
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(WXSceneSession.rawValue)
        WXApi.send(req)
        
    }
    @objc func shareToTimeLine(){
        let image = self.whiteView.mc_makeImage()
        
        let message = WXMediaMessage()
        message.setThumbImage(UIImage.init(named: "avatar_default")!)
        message.title = "标题"
        message.description = "描述"
        
        let obj = WXImageObject()
        
        // 将UIImage转换为PNG格式的Data
        if let pngData = image.pngData() {
            // 使用pngData
            print("转换成PNG格式的数据成功，数据长度：\(pngData.count)")
            obj.imageData = pngData
            
        } else {
            print("转换成PNG格式的数据失败")
        }
        
        message.mediaObject = obj
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(WXSceneTimeline.rawValue)
        WXApi.send(req)
    }
    @objc func saveAction() {
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                if status == .restricted || status == .denied{
                    self.presentAlertVc(confirmBtn: "打开", message: "无访问相册权限，是否去打开权限?", title: "提示", cancelBtn: "取消", handler: { (actions) in
                        let url = NSURL.init(string: UIApplication.openSettingsURLString)
                        if UIApplication.shared.canOpenURL(url! as URL){
                            UIApplication.shared.openURL(url! as URL)
                        }
                    }, viewController: self)
                }else{
                    MCToast.mc_loading(duration: 30)
                    let image = self.whiteView.mc_makeImage()
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
    }
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject){
        MCToast.mc_remove()
        if error != nil{
            MCToast.mc_text("保存失败",respond: .allow)
        }else{
            MCToast.mc_text("已保存到系统相册",respond: .allow)
        }
    }
}
