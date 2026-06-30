//
//  SettingVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/14.
//  

import Foundation
import MCToast
import UIKit

class SettingVC: WHBaseViewVC {
    
    var versionMsgDict = NSDictionary()
    private let cacheSizeQueue = DispatchQueue(label: "com.elavatine.setting.cacheSize", qos: .utility)
    private var isRestorePurchaseInProgress = false
    private lazy var restorePurchaseLoadingView: UIView = {
        let maskView = UIView(frame: view.bounds)
        maskView.backgroundColor = UIColor.black.withAlphaComponent(0.18)
        maskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        maskView.isHidden = true
        maskView.isUserInteractionEnabled = true

        let contentView = UIView()
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.76)
        contentView.layer.cornerRadius = kFitWidth(8)
        contentView.clipsToBounds = true
        contentView.tag = 10001

        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.tag = 10002
        indicator.startAnimating()

        let label = UILabel()
        label.text = "正在恢复购买"
        label.textColor = .white
        label.font = .systemFont(ofSize: kFitWidth(14), weight: .medium)
        label.textAlignment = .center
        label.tag = 10003

        maskView.addSubview(contentView)
        contentView.addSubview(indicator)
        contentView.addSubview(label)
        return maskView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindPhoneVm.detailLabel.text = "\(UserInfoModel.shared.phoneStar)"
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
        if isRestorePurchaseInProgress {
            setSettingPageInteractionEnabled(false)
            updateInteractivePopGestureBlocked(true)
        }
        
//        personalSettingVm.redView.isHidden = UserInfoModel.shared.settingNewFuncRead
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 禁用页面展开动画 —— SettingVC 专属方式
        DispatchQueue.main.async {
            if let transitionView = self.view.superview,
               NSStringFromClass(type(of: transitionView)).contains("UITransitionView") {
                transitionView.layer.removeAllAnimations()
            }
        }
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
    lazy var restorePurchaseVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.bindOtherVm.frame.maxY+kFitWidth(8), width: 0, height: 0))
        vm.leftLabel.text = "恢复购买"
        vm.detailLabel.text = "恢复已购订阅"
        vm.tapBlock = {()in
            self.restorePurchaseAction()
        }
        return vm
    }()
    lazy var resetLogsVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.restorePurchaseVm.frame.maxY, width: 0, height: 0))
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
        vm.detailLabel.text = "计算中"
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
        view.backgroundColor = .COLOR_BG_F2//WHColor_16(colorStr: "FAFAFA")
        
        view.addSubview(scrollViewBase)
        scrollViewBase.frame = CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight())
        
        scrollViewBase.addSubview(topVm)
        
        scrollViewBase.addSubview(bindPhoneVm)
        scrollViewBase.addSubview(bindOtherVm)
        scrollViewBase.addSubview(restorePurchaseVm)
        scrollViewBase.addSubview(resetLogsVm)
        scrollViewBase.addSubview(personalSettingVm)
        scrollViewBase.addSubview(clearCacheVm)
        scrollViewBase.addSubview(registerProtocalVm)
        scrollViewBase.addSubview(privaceVm)
        scrollViewBase.addSubview(bottomVm)
        self.scrollViewBase.layoutIfNeeded()
        self.view.layoutIfNeeded()
        
        scrollViewBase.contentSize = CGSize.init(width: 0, height: bottomVm.frame.maxY+getBottomSafeAreaHeight())
        refreshCacheSize()
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

    func restorePurchaseAction() {
        guard !isRestorePurchaseInProgress else { return }
        beginRestorePurchaseLoading()
        ElaProIAPManager.shared.restorePurchases { result in
            DispatchQueue.main.async {
                self.endRestorePurchaseLoading()

                switch result {
                case .success(let outcome):
                    switch outcome {
                    case .restored:
                        self.showRestorePurchaseToast("恢复购买成功", duration: 3)
                    case .notFound:
                        MCToast.mc_text("未找到可恢复的订阅", respond: .allow)
                    case .boundToOtherAccount:
                        self.showRestorePurchaseBoundToOtherAccountAlert()
                    case .pendingLoginBind:
                        MCToast.mc_text("恢复成功，请登录后同步会员", respond: .allow)
                    case .pendingServerSync:
                        MCToast.mc_text("已找到订阅，会员状态同步中", respond: .allow)
                    }
                case .failure(let error):
                    let message = error.localizedDescription.isEmpty ? "恢复购买失败，请稍后重试" : error.localizedDescription
                    guard !self.shouldSuppressRestorePurchaseErrorToast(message) else { return }
                    MCToast.mc_text(message, respond: .allow)
                }
            }
        }
    }

    private func showRestorePurchaseBoundToOtherAccountAlert() {
        presentAlertVc(confirmBtn: "知道了",
                       message: "",
                       title: "该APPLE账户订阅已绑定其他账号",
                       cancelBtn: nil,
                       handler: { _ in },
                       viewController: self)
    }

    private func shouldSuppressRestorePurchaseErrorToast(_ message: String) -> Bool {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedMessage == "请求已取消" ||
            trimmedMessage == "已取消购买" ||
            trimmedMessage.localizedCaseInsensitiveContains("cancel")
    }

    private func beginRestorePurchaseLoading() {
        isRestorePurchaseInProgress = true
        setSettingPageInteractionEnabled(false)
        updateInteractivePopGestureBlocked(true)
        if restorePurchaseLoadingView.superview == nil {
            view.addSubview(restorePurchaseLoadingView)
        }
        restorePurchaseLoadingView.frame = view.bounds
        layoutRestorePurchaseLoadingView()
        restorePurchaseLoadingView.isHidden = false
        restorePurchaseLoadingView.superview?.bringSubviewToFront(restorePurchaseLoadingView)
        (restorePurchaseLoadingView.viewWithTag(10002) as? UIActivityIndicatorView)?.startAnimating()
    }

    private func endRestorePurchaseLoading() {
        guard isRestorePurchaseInProgress else { return }
        isRestorePurchaseInProgress = false
        updateInteractivePopGestureBlocked(false)
        setSettingPageInteractionEnabled(true)
        restorePurchaseLoadingView.isHidden = true
        (restorePurchaseLoadingView.viewWithTag(10002) as? UIActivityIndicatorView)?.stopAnimating()
    }

    private func setSettingPageInteractionEnabled(_ enabled: Bool) {
        scrollViewBase.isUserInteractionEnabled = enabled
        navigationView.isUserInteractionEnabled = enabled
        backArrowButton.isUserInteractionEnabled = enabled
        naviBackImg.isUserInteractionEnabled = enabled
        navigationController?.navigationBar.isUserInteractionEnabled = enabled
        tabBarController?.tabBar.isUserInteractionEnabled = enabled
    }

    private func layoutRestorePurchaseLoadingView() {
        guard let contentView = restorePurchaseLoadingView.viewWithTag(10001),
              let indicator = contentView.viewWithTag(10002) as? UIActivityIndicatorView,
              let label = contentView.viewWithTag(10003) as? UILabel else {
            return
        }

        let contentWidth = kFitWidth(132)
        let contentHeight = kFitWidth(112)
        contentView.frame = CGRect(x: (restorePurchaseLoadingView.bounds.width - contentWidth) * 0.5,
                                   y: (restorePurchaseLoadingView.bounds.height - contentHeight) * 0.5,
                                   width: contentWidth,
                                   height: contentHeight)
        indicator.center = CGPoint(x: contentWidth * 0.5, y: kFitWidth(39))
        label.frame = CGRect(x: kFitWidth(10),
                             y: kFitWidth(66),
                             width: contentWidth - kFitWidth(20),
                             height: kFitWidth(24))
    }

    private func showRestorePurchaseToast(_ message: String, duration: TimeInterval) {
        let toastView = UILabel()
        toastView.text = message
        toastView.textColor = .white
        toastView.font = .systemFont(ofSize: kFitWidth(14), weight: .medium)
        toastView.textAlignment = .center
        toastView.numberOfLines = 0
        toastView.backgroundColor = UIColor.black.withAlphaComponent(0.76)
        toastView.layer.cornerRadius = kFitWidth(8)
        toastView.clipsToBounds = true
        toastView.isUserInteractionEnabled = false

        let maxWidth = min(SCREEN_WIDHT - kFitWidth(80), kFitWidth(220))
        let textSize = toastView.sizeThatFits(CGSize(width: maxWidth - kFitWidth(30),
                                                     height: CGFloat.greatestFiniteMagnitude))
        let width = max(kFitWidth(120), textSize.width + kFitWidth(30))
        let height = max(kFitWidth(44), textSize.height + kFitWidth(22))
        toastView.frame = CGRect(x: (view.bounds.width - width) * 0.5,
                                 y: (view.bounds.height - height) * 0.5,
                                 width: width,
                                 height: height)
        toastView.alpha = 0

        view.addSubview(toastView)
        UIView.animate(withDuration: 0.18) {
            toastView.alpha = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.18, animations: {
                toastView.alpha = 0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        }
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
            UserDefaults.set(value: [:], forKey: .jounal_meal_advice)
//            NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_TODAY_JOUNAL, object: nil)
            HealthKitNaturnalManager().clearWaterDataFromToday { t in
                
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        }
    }
    func sendLogOutRequest() {
        MCToast.mc_loading()
        let logoutUid = UserInfoModel.shared.uId
        UserInfoModel.shared.beginLogoutHandling()
        NetworkMonitor.shared.clearPendingRequests(ownerUid: logoutUid)
        LogsSQLiteUploadManager().clearUploadQueue()
        WHNetworkUtil.shareManager().POST(urlString: URL_Login_out, parameters: nil,isNeedToast: true,vc: self) { responseObject in
            
        }
//        UserInfoModel.shared.logoutClearMsg()
//        WHBaseViewVC().changeRootVcToWelcome()
        WHBaseViewVC().changeRootVcToWelcome(teardownTabBarControllers: true)
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
    private func refreshCacheSize() {
        cacheSizeQueue.async { [weak self] in
            guard let self = self else { return }
            let cacheSize = self.getCacheFileSize()
            DispatchQueue.main.async { [weak self] in
                self?.clearCacheVm.detailLabel.text = cacheSize
            }
        }
    }

    func getCacheFileSize() -> String{
        var foldSize: UInt64 = 0
        for fileURL in clearableCacheFileURLs() {
            let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            foldSize += UInt64(fileSize)
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
        for fileURL in clearableCacheFileURLs() {
            try? FileManager.default.removeItem(at: fileURL)
        }
        return getCacheFileSize()
    }

    private func clearableCacheFileURLs() -> [URL] {
        guard let cacheDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
              let enumerator = FileManager.default.enumerator(
                at: cacheDirectoryURL,
                includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
                options: [.skipsHiddenFiles]
              ) else {
            return []
        }

        return enumerator.compactMap { item -> URL? in
            guard let fileURL = item as? URL,
                  shouldIncludeCacheFile(fileURL) else {
                return nil
            }
            return fileURL
        }
    }

    private func shouldIncludeCacheFile(_ fileURL: URL) -> Bool {
        let resourceValues = try? fileURL.resourceValues(forKeys: [.isRegularFileKey])
        guard resourceValues?.isRegularFile == true else { return false }

        let lowercasedPath = fileURL.path.lowercased()
        let databaseSuffixes = [".sqlite", ".sqlite3", ".db", ".sqlite-wal", ".sqlite-shm", ".db-wal", ".db-shm"]
        return databaseSuffixes.contains { lowercasedPath.hasSuffix($0) } == false
    }
}
