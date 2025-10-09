//
//  SettingVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/14.
//  

import Foundation
import MCToast

class SettingVC: WHBaseViewVC {
    
    var versionMsgDict = NSDictionary()
    
    override func viewWillAppear(_ animated: Bool) {
        bindPhoneVm.detailLabel.text = "\(UserInfoModel.shared.phoneStar)"
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
        
        personalSettingVm.redView.isHidden = UserInfoModel.shared.settingNewFuncRead
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
//        sendGetVersionRequest()
    }
    lazy var topVm: SettingTopVM = {
        let vm = SettingTopVM.init(frame: .zero)
        vm.checkVersionButton.addTarget(self, action: #selector(checkVersionAction), for: .touchUpInside)
        return vm
    }()
    lazy var bindPhoneVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.topVm.frame.maxY+kFitWidth(8), width: 0, height: 0))
        vm.leftLabel.text = "手机号绑定"
        vm.detailLabel.text = "\(UserInfoModel.shared.phoneStar)"
        vm.tapBlock = {()in
            let vc = UpdatePhoneVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return vm
    }()
    lazy var bindOtherVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.bindPhoneVm.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "关联第三方账号"
        vm.detailLabel.text = "绑定后可快捷登录"
        vm.tapBlock = {()in
            let vc = BindOtherAccountVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return vm
    }()
    lazy var resetLogsVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.bindOtherVm.frame.maxY+kFitWidth(8), width: 0, height: 0))
//        vm.leftLabel.text = "个性化设置"
        vm.leftLabel.text = "重置日志列表"
        vm.detailLabel.text = ""
        vm.tapBlock = {()in
//            let vc = JournalSettingVC()
//            self.navigationController?.pushViewController(vc, animated: true)
            self.clearLogsAction()
        }
        return vm
    }()
    lazy var personalSettingVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.resetLogsVm.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "个性化设置"
//        vm.leftLabel.text = "重置日志列表"
        vm.detailLabel.text = ""
        vm.tapBlock = {()in
            let vc = JournalSettingVC()
            self.navigationController?.pushViewController(vc, animated: true)
//            self.clearLogsAction()
        }
        return vm
    }()
    lazy var clearCacheVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.personalSettingVm.frame.maxY+kFitWidth(8), width: 0, height: 0))
        vm.leftLabel.text = "清除缓存"
        vm.detailLabel.text = "\(self.getCacheFileSize())"
        vm.tapBlock = {()in
            self.clearCacheVm.detailLabel.text = "\(self.clearFileCache())"
        }
        
        return vm
    }()
    lazy var registerProtocalVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.clearCacheVm.frame.maxY+kFitWidth(8), width: 0, height: 0))
        vm.leftLabel.text = "用户注册协议"
        vm.detailLabel.text = ""
        vm.tapBlock = {()in
            let vc = WHCommonH5VC()
            vc.urlString = URL_agreement as NSString
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return vm
    }()
    lazy var privaceVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.registerProtocalVm.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "隐私政策"
        vm.detailLabel.text = ""
        vm.tapBlock = {()in
            let vc = WHCommonH5VC()
            vc.urlString = URL_privacy as NSString
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return vm
    }()
    lazy var bottomVm: SettingBottomVM = {
        let vm = SettingBottomVM.init(frame: CGRect.init(x: 0, y: self.privaceVm.frame.maxY, width: 0, height: 0))
        vm.cancelAccountButton.addTarget(self, action: #selector(cancelAccountAction), for: .touchUpInside)
        vm.loginOutButton.addTarget(self, action: #selector(logoutAction), for: .touchUpInside)
        return vm
    }()
}

extension SettingVC{
    @objc func cancelAccountAction() {
        let vc = CancelAccountVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func logoutAction() {
        self.presentAlertVc(confirmBtn: "退出登录", message: "", title: "登出此Elavatine账号？", cancelBtn: "取消", handler: { action in
            LogsMealsAlertSetManage().removeAllNotifi()
            self.sendLogOutRequest()
        }, viewController: self)
    }
    @objc func checkVersionAction(){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
            let urlString = "itms-apps://itunes.apple.com/app/id6503123667"
            self.openUrl(urlString: urlString)
        })
    }
}
extension SettingVC{
    func initUI() {
        initNavi(titleStr: "系统设置")
        view.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        
        view.addSubview(scrollViewBase)
        scrollViewBase.frame = CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight())
        
        scrollViewBase.addSubview(topVm)
        
        scrollViewBase.addSubview(bindPhoneVm)
        scrollViewBase.addSubview(bindOtherVm)
        scrollViewBase.addSubview(resetLogsVm)
        scrollViewBase.addSubview(personalSettingVm)
        scrollViewBase.addSubview(clearCacheVm)
        scrollViewBase.addSubview(registerProtocalVm)
        scrollViewBase.addSubview(privaceVm)
        scrollViewBase.addSubview(bottomVm)
        
        scrollViewBase.contentSize = CGSize.init(width: 0, height: bottomVm.frame.maxY+getBottomSafeAreaHeight())
    }
    func clearLogsAction() {
        let alertVc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // MARK: - iPad 专属配置
        if let popover = alertVc.popoverPresentationController {
            // 锚点设置为触发按钮
            popover.sourceView = self.resetLogsVm
            popover.permittedArrowDirections = [.up]
        }
        let clearNextAction = UIAlertAction(title: "清空今日开始往后的数据", style: .default) { action in
            TouchGenerator.shared.touchGenerator()
            self.presentAlertVc(confirmBtn: "是", message: "是否继续？", title: "点击“是”将清空今日往后的日志内容，可能会清除碳循环目标", cancelBtn: "否", handler: { action in
                LogsSQLiteManager.getInstance().deleteTableData(sDate: Date().nextDay(days: 0))
                self.sendClearLogsRequest(type: "today")
            }, viewController: self)
        }
        let clearAllAction = UIAlertAction(title: "清空所有数据", style: .default) { action in
            TouchGenerator.shared.touchGenerator()
            self.presentAlertVc(confirmBtn: "是", message: "是否继续？", title: "点击“是”将清空全部日志内容\n可能会清除碳循环目标", cancelBtn: "否", handler: { action in
                LogsSQLiteManager.getInstance().deleteAllData()
                self.sendClearLogsRequest(type: "all")
            }, viewController: self)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel){ action in
//            TouchGenerator.shared.touchGenerator()
        }
        
        alertVc.addAction(clearNextAction)
        alertVc.addAction(clearAllAction)
        alertVc.addAction(cancelAction)
        self.present(alertVc, animated: true)
    }
}

extension SettingVC{
    @objc func sendGetVersionRequest() {
        WHNetworkUtil.shareManager().GET(urlString: URL_app_version, vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            self.versionMsgDict = self.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            let buildVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            
            let lastVer = self.versionMsgDict.stringValueForKey(key: "ios_app_latest_ver")
            let buildVer = self.versionMsgDict.stringValueForKey(key: "ios_app_build_ver")
            
            if lastVer == currentVersion || buildVer == buildVersion{
//                self.topVm.checkVersionButton.isHidden = true
                self.presentAlertVcNoAction(title: "当前已是最新版本", viewController: self)
            }else{
//                self.topVm.checkVersionButton.isHidden = false
                let log = self.versionMsgDict.stringValueForKey(key: "release_log")
                let lastVer = self.versionMsgDict.stringValueForKey(key: "ios_app_latest_ver")
                
                self.presentAlertVc(confirmBtn: "更新", message: "更新内容\n\(log)", title: "最新版本 V\(lastVer)", cancelBtn: "取消",textAlignLeft: true, handler: { action in
                    let urlString = "itms-apps://itunes.apple.com/app/id6503123667"
                    self.openUrl(urlString: urlString)
                }, viewController: self)
            }
        }
    }
    func sendClearLogsRequest(type:String) {
        let param = ["cleartype":type]
        WHNetworkUtil.shareManager().POST(urlString: URL_clear_logs, parameters: param as [String: AnyObject],isNeedToast: true,vc: self) { responseObject in
            MCToast.mc_text("已重置日志列表数据",respond: .allow)
            HealthKitNaturnalManager().clearWaterDataFromToday { t in
                
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        }
    }
    func sendLogOutRequest() {
        MCToast.mc_loading()
        WHNetworkUtil.shareManager().POST(urlString: URL_Login_out, parameters: nil,isNeedToast: true,vc: self) { responseObject in
            
        }
//        UserInfoModel.shared.logoutClearMsg()
//        WHBaseViewVC().changeRootVcToWelcome()
        WHBaseViewVC().changeRootVcToWelcome()
        LogsSQLiteUploadManager().clearNaturalData()
        BodyDataSQLiteManager.getInstance().deleteAllData()
        LogsSQLiteManager.getInstance().deleteAllData()
        CourseProgressSQLiteManager.getInstance().deleteAllData()
        
        WidgetUtils().saveUserInfo(uId: "", uToken: "")
        UserDefaults.standard.setValue("", forKey: token)
        UserDefaults.standard.setValue("", forKey: userId)
        UserDefaults.set(value: "", forKey: .myFoodsList)
        UserDefaults.set(value: "", forKey: .hidsoryFoodsAdd)
        UserInfoModel.shared.clearMsg()
    }
}

extension SettingVC{
    func getCacheFileSize() -> String{
        var foldSize: UInt64 = 0
        let filePath: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
        if let files = FileManager.default.subpaths(atPath: filePath) {
            for path in files {
                let temPath: String = filePath+"/"+path
                DLLog(message: "temPath\(temPath)")
                let folder = try? FileManager.default.attributesOfItem(atPath: temPath) as NSDictionary
                if let c = folder?.fileSize() {
                    foldSize += c
                }
            }
        }
        
        //保留2位小数
        if foldSize > 1024*1024 {
            return String(format: "%.2f", Double(foldSize)/1024.0/1024.0) + "MB"
        }else if foldSize > 1024 {
            return String(format: "%.2f", Double(foldSize)/1024.0) + "KB"
        }else {
            return String(foldSize) + "B"
        }
    }
    func clearFileCache() -> String {
        let filePath: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
        if let files = FileManager.default.subpaths(atPath: filePath) {
            for path in files {
                if !path.contains(".sqlite"){
                    let temPath: String = filePath+"/"+path
                    if FileManager.default.fileExists(atPath: temPath) {
                        try? FileManager.default.removeItem(atPath: temPath)
                    }
                }
            }
        }
        return getCacheFileSize()
    }
}
