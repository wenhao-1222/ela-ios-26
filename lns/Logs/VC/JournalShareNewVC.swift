//
//  JournalShareNewVC.swift
//  lns
//
//  Created by LNS2 on 2024/7/10.
//

import Foundation
import Photos
import MCToast

class JournalShareNewVC: WHBaseViewVC {
    
    var dayString = ""
    var detailsDict = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: (SCREEN_WIDHT-kFitWidth(320))*0.5, y: kFitWidth(12), width: kFitWidth(320), height: kFitWidth(530)))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var topVm : JournalShareTopVM = {
        let vm = JournalShareTopVM.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(320), height: 0))
        vm.refreshUIForLogs(dict: self.detailsDict)
        vm.nameVm.refreshUI(name: UserInfoModel.shared.nickname, avatar: UserInfoModel.shared.headimgurl)
        vm.nameVm.tipsLabel.text = "给你分享了一个饮食日志"
//        vm.contentWhiteNewView.daysLabel.text = "\(self.dayString)"
        return vm
    }()
    lazy var mealsMsgVM : PlanShareMealsMsgVM = {
        let vm = PlanShareMealsMsgVM.init(frame: CGRect.init(x: 0, y: self.topVm.frame.maxY+kFitWidth(2), width: 0, height: 0))
        
        vm.updateUI(dataArray: detailsDict["foods"]as? NSArray ?? [])
        return vm
    }()
    lazy var tipsLabelone : UILabel = {
        let lab = UILabel()
        lab.text = "elavatine内打开计划列表/导入计划/输入分享码使用该计划"
        lab.adjustsFontSizeToFitWidth = true
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .center
        lab.isHidden = true
        
        return lab
    }()
    lazy var shareLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.isHidden = true
        
        return lab
    }()
    lazy var tipsLabelTwo : UILabel = {
        let lab = UILabel()
        lab.text = "- 滚动预览用餐食物，保存显示完整清单 -"
        lab.adjustsFontSizeToFitWidth = true
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var wechatButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: self.whiteView.frame.minX+kFitWidth(22), y: self.whiteView.frame.maxY+kFitWidth(50), width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "plan_share_wechat_icon")
        btn.contenLab.text = "微信"
        btn.tapBlock = {()in
            self.shareToSession()
        }
//        btn.addTarget(self, action: #selector(shareToSession), for: .touchUpInside)
        return btn
    }()
    lazy var circleButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: self.whiteView.frame.minX+kFitWidth(130), y: self.whiteView.frame.maxY+kFitWidth(50), width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "plan_share_circle_icon")
        btn.contenLab.text = "朋友圈"
        btn.tapBlock = {()in
            self.shareToTimeLine()
        }
//        btn.addTarget(self, action: #selector(shareToTimeLine), for: .touchUpInside)
        return btn
    }()
    lazy var saveButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: self.whiteView.frame.minX+kFitWidth(238), y: self.whiteView.frame.maxY+kFitWidth(50), width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "plan_share_save_icon")
        btn.contenLab.text = "保存图片"
        btn.tapBlock = {()in
            self.saveAction()
        }
//        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return btn
    }()
    lazy var shareVm : LogsDetailsShareVM = {
        let vm = LogsDetailsShareVM.init(frame: .zero)
//        vm.topVm.refreshUIForLogs(dict: self.detailsDict)
        vm.topVm.contentWhiteNewView.refreshUIForLogsNew(dict: self.detailsDict)
        vm.topVm.nameVm.refreshUI(name: UserInfoModel.shared.nickname, avatar: UserInfoModel.shared.headimgurl)
        vm.topVm.nameVm.tipsLabel.text = "给你分享了一个饮食日志"
//        vm.topVm.contentWhiteView.daysLabel.text = "\(self.dayString) 营养目标"
        vm.updateUIForLog(dataArray: self.detailsDict["foods"]as? NSArray ?? [])
//        vm.topVm.contentWhiteView.daysLabel.text = "\(self.dayString)"
        vm.bottomTipsLabel.isHidden = true
        return vm
    }()
}

extension JournalShareNewVC{
    @objc func shareToSession(){
        let image = self.shareVm.mc_makeImage()
        
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
        let image = self.shareVm.mc_makeImage()
        
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
                    let image = self.shareVm.mc_makeImage()
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
    }
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject){
        MCToast.mc_remove()
        if error != nil{
            MCToast.mc_text("保存失败。")
        }else{
            MCToast.mc_text("已保存到系统相册")
        }
    }
}
extension JournalShareNewVC{
    func initUI() {
        view.backgroundColor = WHColor_16(colorStr: "1F2833")
        initNavi(titleStr: "分享日志",isWhite: true)
        self.navigationView.backgroundColor = .clear
        
        self.backArrowButton.setImgName(imgName: "plan_share_close_icon")
        
        view.addSubview(scrollViewBase)
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.frame = CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight())
        
        scrollViewBase.addSubview(whiteView)
        whiteView.addSubview(topVm)
        whiteView.addSubview(mealsMsgVM)
        
        scrollViewBase.addSubview(tipsLabelTwo)
        
        if WXApi.isWXAppInstalled(){
            scrollViewBase.addSubview(wechatButton)
            scrollViewBase.addSubview(circleButton)
            scrollViewBase.addSubview(saveButton)
        }else{
            scrollViewBase.addSubview(saveButton)
            saveButton.frame = circleButton.frame
        }
        scrollViewBase.contentSize = CGSize.init(width: 0, height: wechatButton.frame.maxY+kFitWidth(20))
        
        setConstrait()
        
        view.addSubview(shareVm)
    }
    func setConstrait() {
        tipsLabelTwo.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(whiteView.snp.bottom).offset(kFitWidth(16))
        }
    }
}
