//
//  WHNetworkUtil.swift
//  ttjx
//
//  Created by 文 on 2019/10/11.
//  Copyright © 2019 ttjx. All rights reserved.
//

import UIKit
import CommonCrypto
import Alamofire
import MCToast
import DeviceKit

class WHNetworkUtil: SessionManager {

    static var instance : WHNetworkUtil? = nil
    
    public var dataRequest : DataRequest?

    private func shouldRefreshDefaultNutritionMineralsAfterSuccess(urlString: String) -> Bool {
        let urls: Set<String> = [
            URL_goal_week_save,
            URL_question_custom_save,
//            URL_question_custom_save_v2,
            URL_goal_circle_save,
//            URL_dietplan_active,
            URL_clear_logs,
            URL_diet_plan_create,
//            URL_diet_plan_foods_replace,
//            URL_question_survey_save,
//            URL_question_survey_savepart,
//            URL_question_survey_savepart_v2,
//            URL_question_survey_part_save,
//            URL_User_logs_update_notes,
//            URL_User_logs_update_water,
//            URL_User_logs_update_meal_time,
//            URL_User_logs_update_details,
//            URL_User_logs_goal_update,
//            URL_dietplan_update,
//            URL_ai_coach_report_recommend_update
        ]
        return urls.contains(urlString)
    }

    private func refreshDefaultNutritionMineralsAfterSuccessIfNeeded(urlString: String) {
        guard shouldRefreshDefaultNutritionMineralsAfterSuccess(urlString: urlString) else { return }
        UserInfoModel.shared.refreshDefaultNutritionMineralsAfterTargetChange()
    }
    
    class func shareManager() -> WHNetworkUtil{
    
        let header : HTTPHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        let configration = URLSessionConfiguration.default
        configration.httpAdditionalHeaders = header
        configration.timeoutIntervalForRequest = 10
        
        let manager = SessionManager.default
        manager.delegate.sessionDidReceiveChallenge = {
            session,challenge in
            return    (URLSession.AuthChallengeDisposition.useCredential,URLCredential(trust:challenge.protectionSpace.serverTrust!))
        }

        instance = WHNetworkUtil(configuration: configration)

        return instance!
    }
    func GET(urlString : String,vc:UIViewController? = nil,success : @escaping (_ responseObject : [String : AnyObject]) -> ()) -> () {
        var header : HTTPHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    
        let uId = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: UserInfoModel.shared.uId)
        let uToken = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: UserInfoModel.shared.token)
        header["uid"] = "\(uId ?? "")"
        header["token"] = "\(uToken ?? "")"
        
//        header["uid"] = "\(UserInfoModel.shared.uId)"
//        header["token"] = "\(UserInfoModel.shared.token)"
        
        DLLog(message: "\(urlString)")
        #if DEBUG
        let debugLogID = DebugNetworkLogStore.shared.recordRequest(
            method: "GET",
            url: urlString,
            parameters: nil
        )
        #endif
        Alamofire.request(urlString,method: .get,encoding: JSONEncoding.default,headers: header).responseJSON { response in
            DLLog(message: "\(response)")
            #if DEBUG
            DebugNetworkLogStore.shared.recordResponse(
                id: debugLogID,
                statusCode: response.response?.statusCode,
                response: response.result.value ?? response.data ?? response.debugDescription,
                error: response.error
            )
            #endif
            MCToast.mc_remove()
            if let value = response.result.value as? [String : AnyObject]{
                DLLog(message: "\(urlString)  \(value)")
                
                let code = value["code"]as? Int ?? -1
                
                if (code == 200) {
                    success(value)
                }else{
                    if (vc != nil){
                        let errorTitle = "\(value["message"] as? String ?? "网络异常，请稍后重试")"
                        let alertVc = UIAlertController(title: "\(errorTitle)", message: "", preferredStyle: .alert)
                        
                        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler:nil)
                        alertVc.addAction(cancelAction)

                        vc!.present(alertVc, animated:true, completion:nil)
                    }
                }
            }
        }
    }
//    func POSTTTTT(urlString: String, parameters: [String: AnyObject]?, isNeedToast: Bool? = false, vc: UIViewController? = nil, timeOut: TimeInterval? = 10.0, taskId: String = "", success: @escaping (_ responseObject: [String: AnyObject]) -> (), failure: ((Bool) -> Void)? = nil) {
//        
//        NetworkMonitor.shared.addRequest { [weak self] in
//            guard let self = self else { return }
//            
//            DispatchQueue.global(qos: .userInitiated).async {
//                var header: HTTPHeaders = Alamofire.SessionManager.defaultHTTPHeaders
//                let uId = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: UserInfoModel.shared.uId)
//                let uToken = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: UserInfoModel.shared.token)
//                header["uid"] = "\(uId ?? "")"
//                header["token"] = "\(uToken ?? "")"
//
//                let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
//                let buildVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
//
//                var paraDict: Parameters = [
//                    "phonetype": "iOS",
//                    "phonemodel": "\(Device.current)",
//                    "phoneos": "\(UserInfoModel.shared.deviceModelVersion)",
//                    "vercode": "\(buildVersion)",
//                    "vername": "\(currentVersion)",
//                    "phonetime": "\(Date().currentSeconds)"
//                ]
//                for key in paraDict.keys {
//                    let value = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: paraDict[key] as! String)
//                    paraDict.updateValue(value ?? "", forKey: key)
//                }
//
//                if parameters != nil {
//                    for item in parameters! {
//                        if item.value.isKind(of: NSString.self) {
//                            let value = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: item.value as! String)
//                            paraDict.updateValue(value ?? "", forKey: item.key)
//                        } else if item.value.isKind(of: NSArray.self) || item.value.isKind(of: NSMutableArray.self) {
//                            let value = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: WHUtils.getJSONStringFromArray(array: item.value as! NSArray))
//                            paraDict.updateValue(value ?? "", forKey: item.key)
//                        } else if item.value.isKind(of: NSDictionary.self) {
//                            let value = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: WHUtils.getJSONStringFromDictionary(dictionary: item.value as! NSDictionary))
//                            paraDict.updateValue(value ?? "", forKey: item.key)
//                        } else {
//                            paraDict.updateValue(item.value, forKey: item.key)
//                        }
//                    }
//                }
//
//                let manager = Alamofire.SessionManager.default
//                manager.session.configuration.timeoutIntervalForRequest = timeOut ?? 10.0
//
//                manager.request(urlString, method: .post, parameters: paraDict, encoding: JSONEncoding.default, headers: header).responseJSON { response in
//                    DLLog(message: "\(urlString) response: \(response)")
//
//                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                    let currentVc = appDelegate.getKeyWindow().rootViewController
//
//                    switch response.result {
//                    case .success:
//                        if let value = response.result.value as? [String: AnyObject] {
//                            // 成功逻辑略...（你的代码继续保持）
//                            DispatchQueue.main.async {
//                                success(value)
//                            }
//                        } else {
//                            // 数据结构异常
//                            MCToast.mc_remove()
//                            DispatchQueue.main.async {
//                                failure?(true)
//                            }
//                        }
//                    case .failure:
//                        // 新增：自动延迟重试！！
//                        DLLog(message: "[NetworkMonitor] 请求失败，准备加入pending")
//                        NetworkMonitor.shared.retryLater({
//                            self.POST(urlString: urlString, parameters: parameters, isNeedToast: isNeedToast, vc: vc, timeOut: timeOut, taskId: taskId, success: success, failure: failure)
//                        }, retryCount: 0)
//
//                        MCToast.mc_remove()
//                        DispatchQueue.main.async {
//                            failure?(true)
//                        }
//                    }
//                }
//            }
//        }
//    }
    /**
     urlString   接口
     parameters   参数
     isNeedToast  是否需要弹框
     vc   视图控制器
     success  成功回调
     */
//    func POST(urlString : String, parameters : [String : AnyObject]?,isNeedToast:Bool? = false, vc:UIViewController? = nil,timeOut:TimeInterval? = 10.0,taskId:String="",success : @escaping (_ responseObject : [String : AnyObject]) -> (), failure: ((Bool) -> Void)? = nil) -> () {
    func POST(urlString : String,
                  parameters : [String : AnyObject]?,
                  isNeedToast:Bool? = false,
                  vc:UIViewController? = nil,
                  timeOut:TimeInterval? = 10.0,
                  taskId:String="",
                  requestConfig: ((DataRequest) -> Void)? = nil,
                  success : @escaping (_ responseObject : [String : AnyObject]) -> (),
                  failure: ((Bool) -> Void)? = nil) -> () {
        // 后台队列，避免阻塞主线程
        DLLog(message: "----------  uid   token  ----------------------")
        DLLog(message: "---- uId:\(UserInfoModel.shared.uId)")
        DLLog(message: "---- token:\(UserInfoModel.shared.token)")
        
        let msgDictError: [String: Any] = [
            "url": urlString,
            "parameters": parameters ?? [:],
            "taskId": taskId
        ]
        let currentOwnerUid = UserInfoModel.shared.uId.trimmingCharacters(in: .whitespacesAndNewlines)
        let cachedOwnerUid = (UserDefaults.standard.value(forKey: userId) as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let requestOwnerUid = currentOwnerUid.isEmpty ? cachedOwnerUid : currentOwnerUid
        let droppedHandler: (() -> Void)? = urlString == URL_user_group_init ? {
            DispatchQueue.main.async {
                failure?(true)
            }
        } : nil

        NetworkMonitor.shared.addRequest ({
            if urlString == URL_get_current_nutrition {
                let currentUId = UserInfoModel.shared.uId.count >= 4 ? UserInfoModel.shared.uId : (UserDefaults.standard.value(forKey: userId) as? String ?? "")
                let currentToken = UserInfoModel.shared.token.count >= 4 ? UserInfoModel.shared.token : (UserDefaults.standard.value(forKey: token) as? String ?? "")
                if UserInfoModel.shared.isLoggingOut || currentUId.count < 4 || currentToken.count < 4 {
                    failure?(false)
                    return
                }
            }

            if UserInfoModel.shared.uId.count < 4 || UserInfoModel.shared.token.count < 4{
                let uId = UserDefaults.standard.value(forKey: userId) as? String ?? ""
                let token = UserDefaults.standard.value(forKey: token) as? String ?? ""
                UserInfoModel.shared.uId = uId
                UserInfoModel.shared.token = token
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                var header : HTTPHeaders = Alamofire.SessionManager.defaultHTTPHeaders
                let uId = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: UserInfoModel.shared.uId)
                let uToken = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: UserInfoModel.shared.token)
                header["uid"] = "\(uId ?? "")"
                header["token"] = "\(uToken ?? "")"
                
                let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
                let buildVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
                
                var paraDict:Parameters = ["phonetype":"iOS",
                                           "phonemodel":"\(Device.current)",
                                           "phoneName":"\(UIDevice.current.name)",
//                                           "deviceId": urlString == URL_user_group_init ? "" : DeviceUUIDManager.shared.testUUIDWithoutHyphen,
//                                           "deviceId": urlString == URL_user_group_msg ? "" : DeviceUUIDManager.shared.testUUIDWithoutHyphen,
                                           "deviceId": DeviceUUIDManager.shared.uuidWithoutHyphen,
        //                                   "phonemodel":"\(UserInfoModel.shared.deviceModelName)",
                                           "phoneos":"\(UserInfoModel.shared.deviceModelVersion)",
                                           "vercode":"\(buildVersion)",
                                           "vername":"\(currentVersion)",
                                           "phonetime":"\(Date().currentSeconds)"]
                
                DLLog(message: "paraDict:\(paraDict)")
                for key in paraDict.keys{
                    let value = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: paraDict[key] as! String)
                    paraDict.updateValue(value ?? "", forKey: key)
                }
                
                if parameters != nil {
                    for item in parameters!{
                        if item.value.isKind(of: NSString.self){
                            let value = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: item.value as! String)
                            paraDict.updateValue(value ?? "", forKey: item.key)
                        }else if item.value.isKind(of: NSArray.self) || item.value.isKind(of: NSMutableArray.self){
                            let value = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: WHUtils.getJSONStringFromArray(array: item.value as! NSArray))
                            paraDict.updateValue(value ?? "", forKey: item.key)
                        }else if item.value.isKind(of: NSDictionary.self){
                            let value = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: WHUtils.getJSONStringFromDictionary(dictionary: item.value as! NSDictionary))
                            paraDict.updateValue(value ?? "", forKey: item.key)
                        }else{
                            paraDict.updateValue(item.value, forKey: item.key)
                        }
                    }
                }
                
                let manager = Alamofire.SessionManager.default
                manager.session.configuration.timeoutIntervalForRequest = timeOut ?? 10.0
    //            WHNetworkUtil.shareManager().dataRequest =
                DLLog(message: "\(urlString)入参:\(paraDict)")
                #if DEBUG
                let debugLogID = DebugNetworkLogStore.shared.recordRequest(
                    method: "POST",
                    url: urlString,
                    parameters: parameters,
                    encodedParameters: paraDict,
                    taskId: taskId
                )
                #endif
//                manager.request(urlString, method: .post, parameters: paraDict, encoding: JSONEncoding.default,headers: header).responseJSON { (response) in
            let dataRequest = manager.request(urlString, method: .post, parameters: paraDict, encoding: JSONEncoding.default,headers: header)
                            requestConfig?(dataRequest)
                            dataRequest.responseJSON { (response) in
                DLLog(message: "\(urlString) \n \(response)")
                #if DEBUG
                DebugNetworkLogStore.shared.recordResponse(
                    id: debugLogID,
                    statusCode: response.response?.statusCode,
                    response: response.result.value ?? response.data ?? response.debugDescription,
                    error: response.error
                )
                #endif
                    
                    switch response.result{
                    case .success:
                        if let value = response.result.value as? [String : AnyObject]{
                            if urlString == URL_community_forum_notice_list || urlString == URL_community_comment_list_push || urlString ==  URL_forum_add || urlString == URL_Uer_Cancel_pre || urlString == URL_user_habit_leaderboard || urlString == URL_user_habit_claimStreakReward || urlString == URL_diet_plan_create || urlString == URL_user_group_init{
                                MCToast.mc_remove()
                                DispatchQueue.main.async {
                                    success(value)
                                    if urlString == URL_diet_plan_create,
                                       (value["code"] as? Int ?? -1) == 200 {
                                        self.refreshDefaultNutritionMineralsAfterSuccessIfNeeded(urlString: urlString)
                                    }
                                }
                                return
                            }else if urlString == URL_foods_ai_identify{
                                let result = NSMutableDictionary(dictionary: value)
                                result.setValue("\(taskId)", forKey: "taskId")
                                DispatchQueue.main.async {
                                    success(result as! [String : AnyObject])
                                }
                                return
                            }
                            let code = value["code"]as? Int ?? -1
                            
                            if code == 501{
                                UserInfoModel.shared.noUidResponseNum += 1
                            }
                            
                            if (code == 200) {
                                if urlString != URL_goal_week_save || urlString != URL_dietplan_del{
                                    MCToast.mc_remove()
                                }
                                DispatchQueue.main.async {
                                    success(value)
                                    self.refreshDefaultNutritionMineralsAfterSuccessIfNeeded(urlString: urlString)
                                }
                            }else if code == 422{
                                DispatchQueue.main.async {
                                    success(value)
                                }
                            }else if code == 403 && urlString == URL_ai_coach_launch {
                                DispatchQueue.main.async {
                                    success(value)
                                }
                            }else if code == 409 && urlString == URL_iap_dientity_bind {
                                DispatchQueue.main.async {
                                    success(value)
                                }
                            }else if (code == 400 && (urlString == URL_community_comment_list_push || urlString == URL_daily_nutrition_report || urlString == URL_weekly_nutrition_report)) {
                                DispatchQueue.main.async {
//                                    success(["code":"400"]as [String : AnyObject])
                                    let result = NSMutableDictionary(dictionary: value)
                                    success(result as! [String : AnyObject])
                                }
                            }else if (code == 401 || (code == 501 && UserInfoModel.shared.noUidResponseNum > 10)) {//401 token失效，501 uid无效(
                                guard UserInfoModel.shared.beginForcedLogoutHandlingIfNeeded() else {
                                    MCToast.mc_remove()
                                    return
                                }

                                MCToast.mc_remove()
                                NetworkMonitor.shared.clearPendingRequests(ownerUid: UserInfoModel.shared.uId)
                                LogsSQLiteUploadManager().clearUploadQueue()
                                LogsMealsAlertSetManage().removeAllNotifi()
                                
                                LogsSQLiteManager.getInstance().deleteAllData()
                                BodyDataSQLiteManager.getInstance().deleteAllData()
                                CourseProgressSQLiteManager.getInstance().deleteAllData()
                                UserDefaults.standard.setValue("", forKey: token)
                                UserDefaults.standard.setValue("", forKey: userId)
                                UserDefaults.clearNutritionDefaultMineralCache()
                                UserDefaults.set(value: "", forKey: .myFoodsList)
                                UserDefaults.set(value: "", forKey: .hidsoryFoodsAdd)
                                UserInfoModel.shared.uId = ""
                                UserInfoModel.shared.token = ""
                                QuestinonaireMsgModel.shared.surveytype = ""
                                // 401 代表当前账号在别的设备登录，当前设备需要强制退回到登录前页面。
                                // 这里额外传 `teardownTabBarControllers: true`，
                                // 目的是在切 root 之前，主动释放旧的 tabbar 页面和它们持有的界面层级，
                                // 避免旧页面残留后继续响应通知，造成重复请求 / 重复提交。
                                UserInfoModel.shared.logoutClearMsg(teardownTabBarControllers: true)
                                
                                DispatchQueue.main.async {
                                    let errorTitle = "\(value["message"] as? String ?? "账号登录过期，请重新登录！")"
                                    let alertVc = UIAlertController(title: "\(errorTitle)", message: "", preferredStyle: .alert)
                                    let cancelAction = UIAlertAction(title: "确定", style: .default, handler: nil)
                                    alertVc.addAction(cancelAction)

                                    UIApplication.topViewController()?.present(alertVc, animated:true, completion:nil)
                                    
                                }
                            }else{
                                MCToast.mc_remove()
                                if urlString != URL_sport_add || (value["message"] as? String ?? "").contains("存在")
                                || urlString != URL_dietplan_plan_active{
                                    var msgDict: NSMutableDictionary = [
                                        "stage": "response_error",
                                        "code": code,
                                        "url":urlString,
                                        "message": value as Any,
                                        "params": parameters ?? [:]
                                    ]
                                    if urlString == URL_User_logs_update_details{
                                        msgDict = [
                                            "stage": "response_error",
                                            "code": code,
                                            "url":urlString,
                                            "message": value as Any
                                        ]
                                    }
                                    WHUtils().sendErrorMsgRequest(msgDict: msgDict)
                                }
                                
                                DispatchQueue.main.async {
                                    failure?(true)
                                }
                                if urlString == URL_foods_list{
                                    MCToast.mc_failure("网络异常，请稍后重试（\(code)）",respond: .allow)
                                }else if isNeedToast! && (vc != nil){
                                    DispatchQueue.main.async {
                                        let errorTitle = "\(value["message"] as? String ?? "网络异常，请稍后重试")"
                                        let alertVc = UIAlertController(title: "\(errorTitle)", message: "", preferredStyle: .alert)
                                        let cancelAction = UIAlertAction(title: "确定", style: .cancel) { action in

                                        }
                                        alertVc.addAction(cancelAction)
                                        vc!.present(alertVc, animated:true, completion:nil)
                                    }
                                }
                            }
                        }else{
                            DLLog(message: "\(urlString) response: \(response)")
                            MCToast.mc_remove()
                            let msgDict: NSMutableDictionary = [
                                "stage": "response_error",
                                "url":urlString,
                                "message": response as Any,
                                "params": parameters ?? [:]
                            ]
                            WHUtils().sendErrorMsgRequest(msgDict: msgDict)
                            if urlString == URL_community_forum_notice_list{
                                DispatchQueue.main.async {
                                    success(["code":"404"]as [String : AnyObject])
                                }
                                return
                            }
                            if urlString == URL_foods_list{
                                MCToast.mc_failure("数据结构异常，请稍后重试",respond: .allow)
                            }else{
                                if isNeedToast! && (vc != nil){
                                    DispatchQueue.main.async {
                                        let alertVc = UIAlertController(title: "异常的数据结构", message: "", preferredStyle: .alert)
                                        let cancelAction =  UIAlertAction(title: "确定", style: .cancel) { action in

                                        }
                                        alertVc.addAction(cancelAction)

                                        vc!.present(alertVc, animated:true, completion:nil)
                                    }
                                }
                            }
                        }
                        break
                    case .failure:
                        MCToast.mc_remove()
//                        // 新增：自动延迟重试！！
//                        DLLog(message: "[NetworkMonitor] 请求失败，准备加入pending - \(urlString)")
//                       let allowRetry = NetworkMonitor.shared.shouldAllowRetry(for: urlString)
//
//                       if allowRetry {
//                           DLLog(message: "[NetworkMonitor] 请求失败，允许重试，加入pending - \(urlString)")
//                           NetworkMonitor.shared.retryLater({
//                               self.POST(urlString: urlString, parameters: parameters, isNeedToast: isNeedToast, vc: vc, timeOut: timeOut, taskId: taskId, success: success, failure: failure)
//                           }, retryCount: 0)
//                       } else {
//                           DLLog(message: "[NetworkMonitor] 请求失败，但禁止重试，直接回调失败 - \(urlString)")
//                           DispatchQueue.main.async {
//                               failure?(true)
//                           }
//                       }
                        var isCancelled: Bool = true
                        if let afError = response.error as? AFError {
//                            isCancelled = afError.iscancel
                        } else {
                            let nsError = response.error as NSError?
                            isCancelled = nsError?.code == NSURLErrorCancelled
                        }
                        if isCancelled {
                            DLLog(message: "[NetworkMonitor] 请求已取消 - \(urlString)")
                            DispatchQueue.main.async {
                                failure?(false)
                            }
                            break
                        }

                        // 新增：自动延迟重试！！
                        DLLog(message: "[NetworkMonitor] 请求失败，准备加入pending - \(urlString)")
                        let allowRetry = NetworkMonitor.shared.shouldAllowRetry(for: urlString)

                        if allowRetry {
                            DLLog(message: "[NetworkMonitor] 请求失败，允许重试，加入pending - \(urlString)")
                            var retryMsgDict = msgDictError
                            retryMsgDict["error"] = response.error?.localizedDescription ?? ""
                            NetworkMonitor.shared.retryLater({
                                self.POST(urlString: urlString, parameters: parameters, isNeedToast: isNeedToast, vc: vc, timeOut: timeOut, taskId: taskId, requestConfig: requestConfig, success: success, failure: failure)
                            }, retryCount: 0, msgDict: retryMsgDict, ownerUid: requestOwnerUid, onDropped: droppedHandler)
                        } else {
                            DLLog(message: "[NetworkMonitor] 请求失败，但禁止重试，直接回调失败 - \(urlString)")
                            DispatchQueue.main.async {
                                failure?(true)
                            }
                        }
                        break
                    }
                }
            }
        }, msgDict: msgDictError, ownerUid: requestOwnerUid, onDropped: droppedHandler)
    }

    public func md5(strs:String) ->String!{
       let str = strs.cString(using: String.Encoding.utf8)
       let strLen = CUnsignedInt(strs.lengthOfBytes(using: String.Encoding.utf8))
       let digestLen = Int(CC_MD5_DIGEST_LENGTH)
       let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
       CC_MD5(str!, strLen, result)
       let hash = NSMutableString()
       for i in 0 ..< digestLen {
           hash.appendFormat("%02x", result[i])
       }
       free(result)
        let signStr = String(format: hash as String)
        return signStr.uppercased()
    }
      
}

extension WHNetworkUtil{
    //    字典转换为JSONString
//    func getJSONStringFromDictionary(dictionary:NSDictionary) -> String {
//        if (!JSONSerialization.isValidJSONObject(dictionary)) {
//            DLLog(message: "无法解析出JSONString")
//            return ""
//        }
////        let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData?
////        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
////        return JSONString! as String
//        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
//            return ""
//        }
//        return String(data: data, encoding: .utf8) ?? ""
//    }
    
    func getStrForSign(param:[String:String]) -> String{
        let paramTemp = Array(param.keys).sorted(by: <)
        
        var paramStr = ""
        for (_,item) in paramTemp.enumerated(){
            let keyStr = item
            let valueStr = param[item]
            let strTemp = keyStr + "=" + valueStr!
            paramStr = paramStr + strTemp + "&"
        }
        paramStr = paramStr + "key=A7FA6348FEBDCA8A64FDA192CA4812E6"
        DLLog(message: "paramStr :  \(paramStr)")
        
        return paramStr
    }
    
    func openNetWorkServiceWithBolck(action :@escaping ((Bool)->())) {
        var header : HTTPHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        let uId = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: UserInfoModel.shared.uId)
        let uToken = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: UserInfoModel.shared.token)
        header["uid"] = "\(uId ?? "")"
        header["token"] = "\(uToken ?? "")"
        
        // 使用Alamofire发起一个简单的GET请求
        Alamofire.request(URL_app_version,method: .get,encoding: JSONEncoding.default,headers: header).responseJSON { response in
            DLLog(message: "\(response)")
            switch response.result{
            case .success:
                action(true)
                break
            case .failure:
                // 如果请求失败，则根据错误信息判断是否是因为网络权限问题
//                if let statusCode = response.response?.statusCode {
                if let statusCode = response.response?.statusCode, statusCode == 403 {
                    DLLog(message: "\(statusCode)")
                    // 假设403状态码表示网络权限问题
                    action(false)
                } else {
                    // 其他错误类型
                    action(true)
                }
                break
            }
        }
    }
}
