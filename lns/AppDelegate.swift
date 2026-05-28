//
//  AppDelegate.swift
//  lns
//
//  Created by LNS2 on 2024/3/21.
//

import UIKit
import IQKeyboardManagerSwift
import MCToast
import CryptoKit
import UMCommon
import UserNotifications
import Kingfisher
import AliyunPlayer

@main
class AppDelegate: UIResponder, UIApplicationDelegate{

    private var jpushInitialized = false
    private var isRefreshingVipInfoOnWarmStart = false

//    var orientationLock = UIInterfaceOrientationMask.portrait

    var window: UIWindow?
    var psharecode = ""
    var allowRotation = false
    
    lazy var planDetailAlertVM : PlanLeadIntoDetailsMsgAlertVM = {
        let vm = PlanLeadIntoDetailsMsgAlertVM.init(frame: .zero)
        vm.saveBlock = {()in
            self.sendLeadIntoPlanRequest()
        }
        return vm
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        DLLog(message: "application  -----   didFinishLaunchingWithOptions")
//        UserDefaults.standard.setValue("wpjNlDo2knDssC8X", forKey: token)
//        UserDefaults.standard.setValue("f85f9118da17e98d62e1003729929afa", forKey: userId)
//        UserInfoModel.shared.uId = "f85f9118da17e98d62e1003729929afa"
//        UserInfoModel.shared.token = "wpjNlDo2knDssC8X"
        
        let launchWindow: UIWindow
        if let existingWindow = window {
            launchWindow = existingWindow
//            window = launchWindow
        } else {
            launchWindow = UIWindow(frame: UIScreen.main.bounds)
        }
        UserConfigModel.shared.overrideUserInterfaceStyle = UserDefaults.getAppearanceStyle()
        launchWindow.overrideUserInterfaceStyle = UserConfigModel.shared.overrideUserInterfaceStyle
        window = launchWindow
        launchWindow.backgroundColor = .THEME
        UIApplication.shared.applyInterfaceStyle(UserConfigModel.shared.overrideUserInterfaceStyle)
        MCToastConfig.shared.text.maxWidth = kFitWidth(343)//SCREEN_WIDHT-kFitWidth(82)-kFitWidth(72)
        
        let token = UserDefaults.standard.value(forKey: token) as? String ?? ""
        let uId = UserDefaults.standard.value(forKey: userId) as? String ?? ""
        let isLaunchWelcome = UserDefaults.standard.value(forKey: isLaunchWelcome)as? String ?? ""
        let rootViewController: UIViewController
        if isLaunchWelcome == "" && token == ""{
//            self.window?.rootViewController = WelcomeLaunchVC()
//            self.window?.rootViewController = FirstLaunchVC()
            rootViewController = FirstLaunchVC()
        }else{
            let elaLchVc = ElaLaunchVC()
            
            elaLchVc.lchBlock = {[weak self, weak elaLchVc] in
                guard let self = self, let window = self.window else { return }
                let rootVc: UIViewController
                
                if token.count > 1 && uId.count > 1{
                    let phone = UserDefaults.standard.value(forKey: userPhone) as? String ?? ""
                    UserInfoModel.shared.uId = uId
                    UserInfoModel.shared.token = token
                    UserInfoModel.shared.phone = phone
                    sendSplashIdRequest()
                    ElaProIAPManager.shared.bindPendingPurchaseIfNeeded()
                    
                    UserInfoModel.shared.mealsNumber = UserDefaults.getMealsNumber()
                    UserInfoModel.shared.hidden_survery_button_status = UserDefaults.getSurveryStatus()
                    UserInfoModel.shared.hiddenMeaTimeStatus = UserDefaults.getLogsTimeStatus()
                    UserDefaults.initWeightUnit()
                    
                    if isIpad(){
                        rootVc = MainTabBarController()
                    }else{
                        if #available(iOS 26.0, *) {
                            rootVc = SystemTabbar()
                        }else{
                            rootVc = WHTabBarVC()
                        }
                    }
                    
                    WidgetUtils().saveUserInfo(uId: "\(uId)", uToken: "\(token)")
                }else{
                    UserInfoModel.shared.uId = ""
                    UserInfoModel.shared.token = ""
                    
                    let agreeProtocal = UserDefaults.standard.value(forKey: "agreeProtocal") as? String ?? ""
                    if agreeProtocal.count > 0 {
                        rootVc = UINavigationController(rootViewController: FirstLaunchVC(skipAnimation: true, forceNeedBuildPlanOnConfirm: true))
                    }else{
                        rootVc = UINavigationController(rootViewController: WelcomeVC())
                    }
                }
                UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: {
                                    window.rootViewController = rootVc
                }) { _ in
                    elaLchVc?.removeFromParent()
                }
            }
            
//            self.window?.rootViewController = elaLchVc
            rootViewController = elaLchVc
        }
        window?.rootViewController = rootViewController
        launchWindow.makeKeyAndVisible()
        //2026年02月04日13:41:23   个性化设置新功能红点不再显示
        UserInfoModel.shared.settingNewFuncRead = true//(UserDefaults.standard.value(forKey: "settingNewFuncRead")as? String ?? "").count > 0 ? true : false
        UserInfoModel.shared.widgetNewFuncRead = true
        
        EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW, scenarioType: .launch_App, text: "")
        sendSmsDataRequest()
        
        var launchInt = UserDefaults.standard.value(forKey: launchNum) as? Int ?? 0
        launchInt = launchInt + 1
        UserDefaults.standard.setValue(launchInt, forKey: launchNum)
//        initKTVHTTPCache()
        initWxApi()
//        initBuyly()
        initIQKeyBoard()
        initUMCommon()
        initAliYunVideoPlayerConfig()
//        initJpush(launchOptions: launchOptions)
        setupJpushIfAuthorized(launchOptions)
        UserInfoModel.shared.dealDataSourceArray()
        JFHeroBrowserGlobalConfig.default.networkImageProvider = HeroNetworkImageProvider.shared
        JFHeroBrowserGlobalConfig.default.enableBlurEffect = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateWaterShortcutItems), name: NOTIFI_NAME_SHORTCUTITEMS, object: nil)
        updateWaterShortcutItems()
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem,
          shortcutItem.type.hasPrefix("com.lns.water.add"),
          let num = shortcutItem.userInfo?["water"] as? String {
            DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
                self.handleWaterShortcut(num)
            })
       }
        
        if let remoteInfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            let targetPage = remoteInfo["target_page"] as? String ?? ""
            if targetPage.count > 0 {
                let spuId = remoteInfo["spu_id"]as? Int ?? 0
                let spuName = remoteInfo["spu_name"]as? String ?? ""
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.dealNotification(target_page: targetPage,spuId: "\(spuId)",spuName: spuName)
                }
            }
        }

        return true
    }
    //禁用了三方输入法
//    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
//        if extensionPointIdentifier == UIApplication.ExtensionPointIdentifier.keyboard{
//            return false
//        }
//        return true
//    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        if #available(iOS 16.0, *) {
            return UserConfigModel.shared.allowedOrientations
//        }else{
//            return .portrait
//        }
    }
//    func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
//
//    }

    func applicationWillTerminate(_ application: UIApplication) {
        DLLog(message: "application  -----   WillTerminate")
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        DLLog(message: "application  -----   DidEnterBackground")
        application.applicationIconBadgeNumber = 0
        JPUSHService.setBadge(0)
        NotificationCenter.default.post(name: NOTIFI_NAME_ENTER_BACKGROUND, object: nil)
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        DLLog(message: "application  -----   DidBecomeActive")
        NotificationCenter.default.post(name: NOTIFI_NAME_DID_BECOME_ACTIVE, object: nil)
        NotificationManager.shared.reportDeliveredMealNotificationsIfNeeded()

        JPUSHService.setBadge(0)
        setupJpushIfAuthorized()
        getHealthAppData()
        application.applicationIconBadgeNumber = 0
        ElaProIAPManager.shared.bindPendingPurchaseIfNeeded()
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        let token = UserDefaults.standard.value(forKey: token) as? String ?? ""
        let uId = UserDefaults.standard.value(forKey: userId) as? String ?? ""
        if token.count > 0 && uId.count > 0 {
            UserInfoModel.shared.uId = uId
            UserInfoModel.shared.token = token
            refreshVipInfoOnWarmStartIfNeeded()
        }else{
            UserInfoModel.shared.uId = ""
            UserInfoModel.shared.token = ""
        }
    }
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        let handleUrlStr = url.absoluteString
        
//        if handleUrlStr.contains("elavatinelns://mealsIndex"){
//            WidgetMsgModel.shared.mealsIndex = Int(handleUrlStr.mc_cutToSuffix(from: handleUrlStr.count - 1)) ?? 1
//
//            if UserInfoModel.shared.uId.count > 1 {
//                DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "widgetAddFoodsForLogs"), object: nil)
//                })
//            }
//            return true
//        }
        if let handleUrl = URL(string: handleUrlStr){
            return WXApi.handleOpen(handleUrl, delegate: self)
        }
        return false
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        DLLog(message: "open url:\(url)")
        let handleUrlStr = url.absoluteString
        UserDefaults.standard.set("\(handleUrlStr)", forKey: "elavatinelnsMealsIndexOpenUrl")
        
        if url.host == "safepay"{
            // 支付跳转支付宝钱包进行支付，处理支付结果
            AlipaySDK.defaultService().processOrder(withPaymentResult: url) { resultDict in
                let payResult = resultDict as? NSDictionary ?? [:]
                DLLog(message: "AlipaySDK result:\(payResult)")
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "alipayResult"), object: payResult)
            }
        }
        if handleUrlStr.contains("elavatinelns://mealsIndex"){
            WidgetMsgModel.shared.mealsIndex = Int(handleUrlStr.mc_cutToSuffix(from: handleUrlStr.count - 1)) ?? 1
            
            WidgetUtils().saveMealsData(mealsIndex: Int(handleUrlStr.mc_cutToSuffix(from: handleUrlStr.count - 1)) ?? 1)
            if UserInfoModel.shared.uId.count > 1 {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "widgetAddFoodsForLogs"), object: nil)
                })
            }
            return false
        }
        
        if let handleUrl = URL(string: handleUrlStr) {
           return WXApi.handleOpen(handleUrl, delegate: self)
        }
        if MobClick.handle(url){
            return true
        }
        return false
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let handleUrlStr = url.absoluteString

        if MobClick.handle(url){
            return true
        }
//        let handleUrlStr = url.absoluteString
        if let handleUrl = URL(string: handleUrlStr) {
           return WXApi.handleOpen(handleUrl, delegate: self)
        }
        return false
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
        return WXApi.handleOpenUniversalLink(userActivity, delegate: self)
    }
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        restartApp()
    }
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type.hasPrefix("com.lns.water.add"),
           let num = shortcutItem.userInfo?["water"] as? String {
            handleWaterShortcut(num)
            completionHandler(true)
            return
        }
        completionHandler(false)
    }
    
    func restartApp()  {
        guard let url = URL(string: "elavatinelns://") else{
            return
        }
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url,options: [:],completionHandler: nil)
        }
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let info = response.notification.request.content.userInfo
        if info["action"] as? String == "water_reminder" {
            openWaterVC()
        }
        let content = response.notification.request.content

        // 判断是否是你的吃饭提醒（meal reminder）
        if response.notification.request.identifier.hasPrefix("meal_reminder_") {
            NotificationManager.shared.reportMealNotificationClick(content)
        }
        completionHandler()
    }

    private func openWaterVC() {
        guard UserInfoModel.shared.token.count > 0 else { return }
        let vc = JournalWaterVC()
        vc.sDate = Date().todayDate
        if let top = UIApplication.topViewController() {
            if let nav = top.navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                top.present(vc, animated: true)
            }
        }
    }
}


//MARK: 初始化三方SDK
extension AppDelegate{
    //微信
    func initWxApi(){
        WXApi.registerApp("wx0991ecd2b540c7b8", universalLink: "https://api.leungnutritionsciences.cn/lns/")
    }
    func initAliYunVideoPlayerConfig() {
        // 假设从本地缓存/服务端拿到 accountEnv，也可传 nil 走兜底
        let env = RegionSelector.decideEnv(accountEnv: nil, playbackBaseURL: nil)

        if env == .sea {
//          AlivcBase.EnvironmentManager.globalEnvironment = ENV_SEA
            AlivcBase.environmentManager.setGlobalEnvironment(AlivcGlobalEnv.SEA)
        } else {
//          AlivcBase.EnvironmentManager.globalEnvironment = ENV_DEFAULT // 不再用已弃用的 ENV_CN
            AlivcBase.environmentManager.setGlobalEnvironment(AlivcGlobalEnv.DEFAULT)
        }

        AliPrivateService.initLicense() // 5.4.7.1+ 必须在建播放器前调用
    }
    func initIQKeyBoard(){
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        // 控制是否显示键盘上的工具条
//         IQKeyboardManager.shared.enableAutoToolbar = true
        //最新版的设置键盘的returnKey的关键字 ,可以点击键盘上的next键，自动跳转到下一个输入框，最后一个输入框点击完成，自动收起键盘
//        IQKeyboardManager.shared.toolbarManageBehaviour = .bySubviews
    }
    func initUMCommon() {
        #if DEBUG
            UMConfigure.initWithAppkey("666fe76a940d5a4c496f7003", channel: "DEBUG")
        UMConfigure.setLogEnabled(true)
        #else
            UMConfigure.initWithAppkey("666fe76a940d5a4c496f7003", channel: "APP Store")
        UMConfigure.setLogEnabled(false)
        #endif
        
    }
    ///实时获取健康APP的数据
    @objc func getHealthAppData() {
        let launchInt = UserDefaults.standard.value(forKey: launchNum) as? Int ?? 0
        
        //如果不需要显示营养目标的引导功能，则弹健康APP的授权请求框
        if launchInt > 2 && UserInfoModel.shared.uId.count > 0 && UserInfoModel.shared.token.count > 0{
            HealthKitManager.init().getLatestWeightSample { entity in
                //            DLLog(message: "HealthKitManager:\(String(describing: entity))")
            }
        }
    }
    func setupJpushIfAuthorized(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized { //&& self.jpushInitialized == false {
//                self.jpushInitialized = true
                DispatchQueue.main.async {
                    self.initJpush(launchOptions: launchOptions)
                }
            }
        }
    }
    func initJpush(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let entity = JPUSHRegisterEntity()
        entity.types = 1 << 0 | 1 << 1 | 1 << 2
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        
        let userSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound],
                                                              categories: nil)
        JPUSHService.register(forRemoteNotificationTypes: userSettings.types.rawValue,
                                          categories: nil)
        
        #if DEBUG
            JPUSHService.setup(withOption: launchOptions, appKey: "1cdfb29edba790f3609b816b", channel: "DEBUG", apsForProduction: false)
        #else
            JPUSHService.setup(withOption: launchOptions, appKey: "1cdfb29edba790f3609b816b", channel: "App Store", apsForProduction: true)
        #endif
    }
    func recognitionPasteboard() {
        let status = UserDefaults.standard.bool(forKey: "UIPasteboardStatus")
        if status == false { copyVerify() }
        if #available(iOS 14.0, *) {
            // 设置粘贴板的检测模式
            UIPasteboard.general.detectPatterns(for: [.probableWebURL, .number, .probableWebSearch]) { result in
                DLLog(message: "clipboardString:\(result)")
                switch result {
                case let .success(pattern):
                    DLLog(message: "clipboardString:success  \(result)")
//                    if pattern.contains(.probableWebURL) {
                        // 识别剪贴板中的内容
                        self.copyVerify()
//                    }
                case let .failure(error):
                    DLLog(message: "clipboardString:error  \(result)")
                    DLLog(message: "clipboardString:error -- \(error)")
//                    printLog(error)
                }
            }
        }else {
            DLLog(message: "clipboardString:")
            copyVerify()
        }
        DLLog(message: "clipboardString:finish --")
    }
    func copyVerify() {
        // 识别剪贴板中的内容
        DLLog(message: "clipboardString:识别剪贴板中的内容")
        guard
            let clipboardString = UIPasteboard.general.string
        else {
            return
        }
        UserDefaults.standard.set(true, forKey: "UIPasteboardStatus")
        UserDefaults.standard.synchronize()
        
        let shareCode = UserDefaults.standard.value(forKey: self_shareCode) as? String ?? ""
        DLLog(message: "clipboardString:\(clipboardString)")
        if clipboardString.count == 5 && clipboardString != shareCode && UserInfoModel.shared.token.count > 0{
            self.sendPlanShareMsgRequest(psharecode: clipboardString)
        }
    }
}

extension AppDelegate:JPUSHRegisterDelegate{
    func jpushNotificationAuthorization(_ status: JPAuthorizationStatus, withInfo info: [AnyHashable : Any]?) {
        DLLog(message: "JPush:(jpushNotificationAuthorization) \(info)")
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        DLLog(message: "JPush:(jpushNotificationCenter didReceive) \(userInfo)")
       let target_page = userInfo["target_page"]as? String ?? ""
        DLLog(message: "JPush:   target_page  ---   \(target_page)")
        if target_page.count > 0 {
            let spuId = userInfo["spu_id"]as? Int ?? 0
            let spuName = userInfo["spu_name"]as? String ?? ""
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                self.dealNotification(target_page: target_page,spuId: "\(spuId)",spuName: spuName)
            })
        }else{
            let content = response.notification.request.content

            // 判断是否是你的吃饭提醒（meal reminder）
            if response.notification.request.identifier.hasPrefix("meal_reminder_") {
                NotificationManager.shared.reportMealNotificationClick(content)
            }
        }
        
        if response.notification.request.trigger is UNPushNotificationTrigger{
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler()
    }
    func jpushNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (Int) -> Void) {
        let userInfo = notification.request.content.userInfo
        DLLog(message: "JPush:(jpushNotificationCenter willPresent) \(userInfo)")
        if notification.request.trigger is UNPushNotificationTrigger{
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DLLog(message: "JPush:(didReceiveRemoteNotification) \(userInfo)")
        NotificationManager.shared.reportDeliveredMealNotificationsIfNeeded()
        completionHandler(UIBackgroundFetchResult.newData)
    }
    func jpushNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification) {
        DLLog(message: "JPush:(jpushNotificationCenter) \(notification)")
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        DLLog(message: "JPush:deviceToken:\(deviceToken.toHexString())")
        JPUSHService.registerDeviceToken(deviceToken)
        DLLog(message: "JPush:registrationID:\(JPUSHService.registrationID())")
        self.sendSaveRegistIdRequest()
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        DLLog(message: "JPush:didFailToRegisterForRemoteNotificationsWithError:\(error)")
    }
}

//MARK: 微信代理方法
extension AppDelegate: WXApiDelegate {
    //MARK:微信回调
    func onResp(_ resp: BaseResp) {
        if resp.isKind(of: PayResp.self) {
             //这里是微信支付的回调
            if let payResp = resp as? PayResp {
                // 支付结果处理
                switch payResp.errCode {
                case WXSuccess.rawValue:
                    print("支付成功")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "wechatSuccess"), object: nil)
                default:
                    print("支付失败，错误码：\(payResp.errCode)")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "wechatFail"), object: nil)
                }
            }
        }  else if resp.isKind(of: SendAuthResp.self){
         //这里是授权登录的回调
            let aresp = resp as! SendAuthResp
            DLLog(message: "onResp   ------ \(aresp.description)")
            DispatchQueue.main.async {
                if aresp.errCode == 0 {
                    if let code = aresp.code {
                        DLLog(message: "\(code)")
                        if UserInfoModel.shared.token.count > 0 {
                            self.sendCodeRequest(code: code, isLogin: false)
                        }else{
                            self.sendCodeRequest(code: code)
                        }
                    } else {
                        MCToast.mc_text("微信授权失败")
                    }
                } else {
                    MCToast.mc_text("微信授权失败")
                }
            }
        }else if resp.isKind(of: SendMessageToWXResp.self){
            let send = resp as? SendMessageToWXResp
            if send?.errCode == 0 {
                DLLog(message: "分享成功")
            }else{
                DLLog(message: "分享失败")
            }
        }
    }
    func onReq(_ req: BaseReq) {
        DLLog(message: "onReq   ------ \(req)")
    }
 }

//MARK: 网络请求
extension AppDelegate{
    func refreshVipInfoOnWarmStartIfNeeded() {
        guard UserInfoModel.shared.uId.count > 0,
              UserInfoModel.shared.token.count > 0,
              !isRefreshingVipInfoOnWarmStart else {
            return
        }

        isRefreshingVipInfoOnWarmStart = true
        WHNetworkUtil.shareManager().POST(urlString: URL_pro_info, parameters: nil) { [weak self] responseObject in
            self?.isRefreshingVipInfoOnWarmStart = false

            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            let vipModel = VIPModel.shared.update(with: dataDict)
            UserDefaults.set(value: "\(vipModel.status?.rawValue ?? 0)", forKey: .vipStatus)

            DLLog(message: "refreshVipInfoOnWarmStartIfNeeded:\(dataDict)")
            DLLog(message: "refreshVipInfoOnWarmStartIfNeeded model: uid=\(vipModel.uid), status=\(vipModel.status?.rawValue ?? 0), isLifetime=\(vipModel.isLifetime), expireTime=\(vipModel.expireTime)")
        } failure: { [weak self] _ in
            self?.isRefreshingVipInfoOnWarmStart = false
        }
    }

    func sendCodeRequest(code:String,isLogin:Bool? = true){
        let param = ["code":"\(code)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_Login_wechat, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendCodeRequest:\(dataObj)")
            
            UserInfoModel.shared.wxOpenId = dataObj["openid"]as? String ?? ""
            UserInfoModel.shared.wxUnionId = dataObj["unionid"]as? String ?? ""
            UserInfoModel.shared.wxAccessToken = dataObj["access_token"]as? String ?? ""
            UserInfoModel.shared.wxRefreshToken = dataObj["refresh_token"]as? String ?? ""
            UserInfoModel.shared.wxNickName = dataObj["nickname"]as? String ?? ""
            UserInfoModel.shared.wxHeadImgUrl = dataObj["headimgurl"]as? String ?? ""
            
            if isLogin ?? true{
                UserInfoModel.shared.isRegist = dataObj["registered"]as? String ?? ""
                UserInfoModel.shared.state = dataObj["state"]as? Int ?? 1
                UserInfoModel.shared.token = dataObj["token"]as? String ?? ""
                UserInfoModel.shared.uId   = dataObj["uid"]as? String ?? ""
                
                UserDefaults.standard.setValue("\(dataObj["token"]as? String ?? "")", forKey: token)
                UserDefaults.standard.setValue("\(dataObj["uid"]as? String ?? "")", forKey: userId)
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "wechatLogin"), object: nil)
            }else{
                NotificationCenter.default.post(name: Notification.Name(rawValue: "wechatBind"), object: nil)
            }
        }
    }
    
    func sendPlanShareMsgRequest(psharecode:String){
        let param = ["psharecode":"\(psharecode)"]
        DLLog(message: "application  ----- sendPlanShareMsgRequest")
        WHNetworkUtil.shareManager().POST(urlString: URL_plan_brief, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            UIPasteboard.general.string = " "
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
//            let dict = responseObject["data"]as? NSDictionary ?? [:]
            self.getKeyWindow().addSubview(self.planDetailAlertVM)
            self.planDetailAlertVM.refreshUI(dict: dict)
            self.psharecode = dict["psharecode"]as? String ?? ""
        }
    }
    func sendLeadIntoPlanRequest() {
        MCToast.mc_text("计划导入中...")
        let uId = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: UserInfoModel.shared.uId)
        let shareCode = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: psharecode)
        
        WHNetworkUtil.shareManager().GET(urlString: "\(URL_plan_leadinto)?uid=\(uId ?? "")&psharecode=\(shareCode ?? "")", vc:  UIApplication.topViewController()) { responseObject in
            self.planDetailAlertVM.hiddenView()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leadIntoPlan"), object: nil)
//            MCToast.mc_text("已为您导入计划，请前往计划列表查看",offset: kFitWidth(-100)-SCREEN_HEIGHT*0.5,respond: .respond)
            
            if UserInfoModel.shared.currentVcName != "PlanListVC"{
                let vc = PlanListVC()
                UserInfoModel.shared.currentVc.navigationController?.pushViewController(vc, animated: true)
            }
            
            DLLog(message: UserInfoModel.shared.currentVc)
//            WHUtils().getCurrentController()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func sendSmsDataRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_app_version_new, parameters: nil) { responseObject in
            DLLog(message: "\(responseObject)")
        }
    }
    func sendSaveRegistIdRequest() {
        if JPUSHService.registrationID().count > 0 && self.jpushInitialized == false{
            jpushInitialized = true
            let param = ["jpush_regid_ios":"\(JPUSHService.registrationID())"]
            DLLog(message: "sendSaveRegistIdRequest(param):\(param)")
           WHNetworkUtil.shareManager().POST(urlString: URL_User_Material_Update, parameters: param as [String : AnyObject]) { responseObject in
                DLLog(message: "sendSaveRegistIdRequest:\(responseObject)")
            }
        }
    }
    func sendSplashIdRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_splash_ad, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendSplashIdRequest:\(dataArr)")
            
            if dataArr.count > 0 {
                let group = DispatchGroup()
                group.enter()
                let saveArr = NSMutableArray()
                for case let dict as NSDictionary in dataArr {
                    let mDict = NSMutableDictionary(dictionary: dict)
                    if mDict.stringValueForKey(key: "materialType") == "1"{//只处理图片，不考虑视频
                        group.enter()
                        let urlString = dict.stringValueForKey(key: "ossUrl")
                        DSImageUploader().dealImgUrlSignForOss(urlStr: urlString) { signUrl in
                            if let url = URL(string: urlString) {
                                let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                                let dir = caches.appendingPathComponent("SplashAds")
                                try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
                                let fileURL = dir.appendingPathComponent(url.lastPathComponent)
                                mDict.setValue(fileURL.path, forKey: "localPath")
                                if !FileManager.default.fileExists(atPath: fileURL.path) {
                                    URLSession.shared.dataTask(with: url) { data, _, _ in
                                        if let data = data { try? data.write(to: fileURL) }
                                    }.resume()
                                }
                                let darkUrlString = url.deletingPathExtension().absoluteString + "_dark." + url.pathExtension
                                if let darkUrl = URL(string: darkUrlString) {
                                    let darkFileURL = dir.appendingPathComponent("\(darkUrl.deletingPathExtension().lastPathComponent).\(darkUrl.pathExtension)")
                                    mDict.setValue(darkFileURL.path, forKey: "localPathDark")
                                    if !FileManager.default.fileExists(atPath: darkFileURL.path) {
                                        URLSession.shared.dataTask(with: darkUrl) { data, _, _ in
                                            if let data = data { try? data.write(to: darkFileURL) }
                                        }.resume()
                                    }
                                }
                            }
                            saveArr.add(mDict)
                            group.leave()
                        }
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                    group.leave()
                })
                group.notify(queue: .global()) {
                    UserDefaults.setSplashMaterials(saveArr)
                }
            }else{
                UserDefaults.setSplashMaterials([])
            }
        }
    }
}

//MARK: 自定义方法
extension AppDelegate{
    /// 统一切换根控制器。
    /// - Parameters:
    ///   - newRootVC: 即将展示的新 root controller。
    ///   - teardownTabBarControllers: 是否在切 root 之前，主动释放旧的 tabbar 体系页面。
    ///
    /// 这里默认不做额外清理，保持项目里原有的切 root 行为完全不变。
    /// 只有在 401 / 多设备登录这类“必须强制回到登录前页面”的场景下，
    /// 才会传 `true`，先把旧 tabbar 及其子控制器打散，再切到新的 root。
    ///
    /// 这样做的目的，是避免旧 tabbar 页面因为通知、window 浮层或导航栈引用而没有及时释放，
    /// 继续在后台响应事件，导致出现重复请求、重复提交之类的灵异问题。
    func switchRootViewController(to newRootVC: UIViewController, teardownTabBarControllers: Bool = false) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.switchRootViewController(to: newRootVC, teardownTabBarControllers: teardownTabBarControllers)
            }
            return
        }

        UserInfoModel.shared.noUidResponseNum = 0
        let keyWindow = getKeyWindow()
        if teardownTabBarControllers {
            teardownTabBarControllersIfNeeded(in: keyWindow)
        }
        let transtition = CATransition()
        transtition.duration = 0.3
        transtition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        keyWindow.layer.add(transtition, forKey: "animation")
        keyWindow.rootViewController = newRootVC
        keyWindow.makeKeyAndVisible()
    }
    func getKeyWindow() -> UIWindow{
//        if let keyWindow = UIApplication.shared.connectedScenes
//            .filter({$0 is UIWindowScene})
//            .map({($0 as! UIWindowScene).windows})
//            .first?.first {
//            return keyWindow
//        }
//
        if #available(iOS 13.0, *){
            for window in UIApplication.shared.windows {
                if window.isKeyWindow {
                    return window
                }
            }
        }
        let keyWindow = UIApplication.shared.keyWindow ?? self.window // 在 iOS 13 以下，可以继续使用 keyWindow
        
        return keyWindow ?? self.window!
    }
    
    /// 在“401 多设备登录，强制回到登录前页面”时，主动清理当前 window 上的 tabbar 页面体系。
    ///
    /// 这里做两件事：
    /// 1. 先找到当前 root 下真正承载业务页面的 `UITabBarController`
    /// 2. 再移除挂在 `keyWindow` 上的业务浮层，并把 tabbar / navigation / child controller 层级打散
    ///
    /// 之所以只清理 tabbar 页面，是因为这次问题集中出现在“用户已登录并停留在主业务区”之后，
    /// 一旦 401 发生，这部分旧页面已经不应该再继续存活。
    private func teardownTabBarControllersIfNeeded(in window: UIWindow) {
        guard let rootViewController = window.rootViewController,
              let tabBarController = findTabBarController(from: rootViewController) else {
            return
        }

        let viewControllersToRelease = tabBarController.viewControllers ?? []

        // 先移除直接挂在 keyWindow 上、但不属于 tabbar 根视图的业务浮层。
        // 这样做是为了避免旧页面虽然已经切 root，但 window 上仍然挂着它们创建的 view，
        // 这些 view 反过来继续持有 controller 或 block，导致页面无法正常释放。
        for subview in window.subviews where subview !== tabBarController.view {
            subview.removeFromSuperview()
        }

        // 先清空 tabbar 自己维护的 controller 列表，避免 UIKit 在同步 selected 状态时
        // 还拿着一份即将被拆掉的旧 controller 引用，触发 “selected controller 不在列表中” 的断言。
        tabBarController.viewControllers = []

        // 再递归打散旧 controller 树，尽量让旧页面在本次 runloop 后就进入释放流程。
        for viewController in viewControllersToRelease {
            prepareViewControllerForRelease(viewController)
        }
        prepareViewControllerForRelease(tabBarController)
    }
    
    /// 递归释放 controller 树中与展示相关的强引用关系。
    ///
    /// 这里不做任何业务状态修改，只处理界面层级：
    /// - dismiss 已经 present 的页面
    /// - 清空 navigationController 的栈
    /// - 移除 child controller
    /// - 结束当前正在编辑的输入状态
    ///
    /// 这样可以最大程度减少旧 tabbar 页面在切 root 后继续残留的概率。
    private func prepareViewControllerForRelease(_ viewController: UIViewController) {
        if let presentedViewController = viewController.presentedViewController {
            prepareViewControllerForRelease(presentedViewController)
            presentedViewController.dismiss(animated: false)
        }

        if let tabBarController = viewController as? UITabBarController {
            for child in tabBarController.viewControllers ?? [] {
                prepareViewControllerForRelease(child)
            }
        }

        if let navigationController = viewController as? UINavigationController {
            for child in navigationController.viewControllers {
                prepareViewControllerForRelease(child)
            }
            navigationController.setViewControllers([], animated: false)
        }

        for child in viewController.children {
            prepareViewControllerForRelease(child)
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        viewController.view.endEditing(true)
    }
    
    /// 从当前 root controller 树里找到业务主区使用的 `UITabBarController`。
    ///
    /// 项目里 tabbar 可能被 navigationController、presented controller 或 child controller 包住，
    /// 所以这里用递归方式查找，而不是简单假设 `window.rootViewController` 就一定是 tabbar。
    private func findTabBarController(from viewController: UIViewController?) -> UITabBarController? {
        guard let viewController = viewController else { return nil }
        if let tabBarController = viewController as? UITabBarController {
            return tabBarController
        }
        if let navigationController = viewController as? UINavigationController {
            for child in navigationController.viewControllers.reversed() {
                if let tabBarController = findTabBarController(from: child) {
                    return tabBarController
                }
            }
        }
        if let presentedViewController = viewController.presentedViewController,
           let tabBarController = findTabBarController(from: presentedViewController) {
            return tabBarController
        }
        for child in viewController.children {
            if let tabBarController = findTabBarController(from: child) {
                return tabBarController
            }
        }
        return nil
    }
}

//MARK: 点击通知的逻辑处理
extension AppDelegate{
    func dealNotification(target_page:String,spuId:String="",spuName:String="") {
        let currentVc = UIApplication.topViewController()
        //跳转到周报
        if target_page == "weekly_nutrition_report"{
            if UserInfoModel.shared.token.count > 0 {
//                let currentVc = UserInfoModel.shared.currentVc//WHUtils().getCurrentController()
                let vc = JournalReportVC()

                let todayDate = Date().todayDate
                let logsModel = LogsSQLiteManager.getInstance().getLogsByDate(sDate: Date().todayDate)!
                let sportDict = SportDataSQLiteManager.getInstance().querySportsData(sDate: todayDate)
                DLLog(message: "SportDataSQLiteManager:\(sportDict)")
                
                let dict = NSMutableDictionary(dictionary: logsModel.modelToDict())
                if UserInfoModel.shared.statSportDataToTarget == "1"{
                    dict.setValue("\(sportDict.stringValueForKey(key: "sportCalories"))", forKey: "sportCalories")
                }else{
                    dict.setValue("", forKey: "sportCalories")
                }
                vc.detailDict = dict
                vc.currentIndex = 1
                if currentVc?.navigationController != nil{
                    currentVc?.navigationController?.pushViewController(vc, animated: true)
                }else{
                    currentVc?.present(vc, animated: true)
                }
            }
        }else if target_page == "MallDetailVC"{
            if UserInfoModel.shared.token.count > 0{
                let vc = MallDetailVC()
                vc.listModel.id = spuId
                vc.listModel.name = spuName
                if currentVc?.navigationController != nil{
                    currentVc?.navigationController?.pushViewController(vc, animated: true)
                }else{
                    currentVc?.present(vc, animated: true)
                }
            }
        }
    }
}
extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }

    var keyWindow: UIWindow? {
        return self.windows.first { $0.isKeyWindow }
    }
}
extension AppDelegate{
    @objc public func updateWaterShortcutItems() {
        let records = UserDefaults.getWaterRecord()
        var items: [UIApplicationShortcutItem] = []
        if UserInfoModel.shared.show_water_status {
            for (idx, num) in records.prefix(3).enumerated() {
                let icon = UIApplicationShortcutIcon(type: .add)
                let item = UIApplicationShortcutItem(type: "com.lns.water.add\(idx)",
                                                    localizedTitle: "\u{1F4A7} \(num)ml",
                                                    localizedSubtitle: nil,
                                                    icon: icon,
                                                    userInfo: ["water": num as NSString])
                items.append(item)
            }
        }
        
        UIApplication.shared.shortcutItems = items
    }

    private func handleWaterShortcut(_ num: String) {
        guard UserInfoModel.shared.token.count > 0 else { return }
//        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
            let sDate = Date().todayDate
            let total = LogsSQLiteManager.getInstance().addWaterNumStatus(sDate: sDate, num: num)
            HealthKitNaturnalManager().saveWaterData(sdate: sDate, waterNum: num.doubleValue, isTotal: false)
            LogsSQLiteUploadManager().sendWaterSynRequest(dict: ["sdate": sDate, "waterNum": total])
//            LogsSQLiteManager.getInstance().insertWater(sDate: sDate, waterNum: total)
//            LogsSQLiteManager.getInstance().updateLogsEtime(sDate: sDate, endTime: Date().currentSecondsUTC8)
//            MCToast.mc_text("已添加\(num)ml")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
//            self.updateWaterShortcutItems()
//        })
    }
}
