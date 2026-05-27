//
//  UserInfoModel.swift
//  lns
//
//  Created by LNS2 on 2024/3/22.
//

import Foundation
import DeviceKit
import UMCommon

enum ABTEST_TYPE {
    case A
    case B
}

//审核状态
enum AUDIT_STATUS {
    case pass     //审核通过
    case checking   //审核中
}

class ABTESTMODEL: NSObject {
    var isInit = false
    
    var diet_log_note = ABTEST_TYPE.A
    
    var tutorial_briefing_price_hidden = ABTEST_TYPE.A //a组（默认）：教程详情页隐藏价格、    b组：教程详情页显示价格
}

class UserInfoModel {
    
    static let shared = UserInfoModel()
    
    private init(){
        
        let deviceModel = Device.current// 获取设备型号名称
        
        self.deviceModelName = "\(deviceModel)"//deviceModel.localizedModel ?? "iphone unknown type"
        self.deviceModelVersion = deviceModel.systemVersion ?? "v0"
        DLLog(message: "deviceModel:\(deviceModel)  --  \(deviceModel.systemVersion ?? "")   ==  \(deviceModel.name ?? "")   \(UIDevice.current.name)")
        DLLog(message: "deviceModel Name:\(UIDevice.current.name) --- \(UIDevice.current.description)")
        
    }
    
    var currentVcName = ""
    var currentVc = ViewController()
    var postNum = 3
    var failToastNum = 0
    var noUidResponseNum = 0// 返回501 的次数
    private var isHandlingForcedLogout = false
    
    var uId = ""
    var registDate = Date().nextDay(days: 0)
    var birthDay = ""
    var birthYear = ""
    var gender = ""
    var sex = ""
    var headimgurl = ""
    var avatarStatus = AUDIT_STATUS.pass
    var id = ""
    var nickname = ""
    var phone = ""
    var phoneStar = ""
    var isBindWeChat = false
    var isBindAppId  = false
    var inviteCode = ""
    var uLevel = ""
    //客服消息是否有未读
    var msgUnRead = false
    //使用教程，小组件是否有未读
    //使用教程--小组件  红点去除   2025年04月08日11:27:30
    var widgetNewFuncRead = true
    //营养统计功能--是否未读
    var statNewFuncRead = true
    //设置--新功能  个性化设置
    var settingNewFuncRead = true
    //消息通知是否有新消息
    var newsListHasUnRead = false
    
    var isAppStoreMark = "0"
    //日志--每日显示多少餐   3 ~ 6 餐
    var mealsNumber = 6
    //是否隐藏日志--免费获取计划按钮   true 隐藏   false 显示
    var hidden_survery_button_status = true
    //是否显示喝水功能
    var show_water_status = true
    //是否显示AI教练入口
    var show_ai_coach_status = true
    //是否有未读的最新AI教练报告
    var has_unread_latest_ai_coach_report = false
    ///是否显示下一餐饮食建议
    var show_next_advice = true
    //体重单位  1  kg   2  斤   3 磅
    var weightUnit = 1
    var weightUnitName = "kg"
    var weightCoefficient = 1.0  //单位kg 转换成 当前单位 时候的系数    斤  为 2  ，磅为 2.2046226
    
    var hiddenMeaTimeStatus = false
    var mealsTimeAlertDict = NSDictionary()
    
    var showRemainCalories = false///日志页，是否显示剩余摄入  默认false
    var showNotifiAuthoriAlertVM = false///是否弹通知权限的弹窗
    
    //苹果健康APP运动数据，是否计入每日消耗，默认不计入  0   未设置过   1 设置不计入   2  设置计入
    var statSportDataFromHealth = "0"
    //运动记录是否计入目标
    var statSportDataToTarget = "0"
    
    var wxOpenId = ""
    var wxUnionId = ""
    var wxAccessToken = ""
    var wxRefreshToken = ""
    var wxNickName = ""
    var wxHeadImgUrl = ""
    var lastMarkAlertTime = ""
    var token = ""
    
    var appleId = ""
    var idc = "86"
    
    var isRegist = ""
    var state = 1
    var deviceModelName = ""
    var deviceModelVersion = ""
    
    var streakDict = NSDictionary()
    //最后一次测量的体重数据 单位  kg
    var lastWeight = 0.0
    
    ///碳循环开始日期     +    开始日期的偏移量
    var ccStartDate = Date().todayDate
    var ccStartOffsetIndex = 0
    
    var onboarding_flow_status = true
    
    var event_log_session_id = ""
    
//    var serviceWelcome = "在Elavatine，我们非常重视聆听用户宝贵的建议。请输入您遇到的问题或建议（例如：XX食物数据错误，数据库缺少XX食物，软件bug等），我们会在最短的时间内回复您。感谢您的支持与理解!"
    var serviceWelcome = "请输入你遇到的问题或建议（例如：XX食物数据错误，数据库缺少XX食物，软件bug等）。"
    var serviceResponce = "感谢你联系Elavatine！我们已经收到你的消息，并会在最短的时间内回复你。感谢你的耐心与支持！"
    
    var gpas = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC3//sR2tXw0wrC2DySx8vNGlqt3Y7ldU9+LBLI6e1KS5lfc5jlTGF7KBTSkCHBM3ouEHWqp1ZJ85iJe59aF5gIB2klBd6h4wrbbHA2XE1sq21ykja/Gqx7/IRia3zQfxGv/qEkyGOx+XALVoOlZqDwh76o2n1vP1D+tD3amHsK7QIDAQAB"
    var spas = "MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAOXlEEcPdps7J5gI4uRpaSkleAlB8ySU5Y+Z0kCcbV4PoJX5Q6lQozLku18YdAQztqjnHcGkzHgw1FRhXAECZTzg+HA2brGlMmuDnNkKWgWaxf4Tm6RYTlgVG7yLn7l3wu5BNNO/hd/NtMJM6E43y6P7KmSiYRO5U3CBEVUWMd3VAgMBAAECgYEAkqHVDQ4O35oOegmI9plJauYsNvNqqzWRalN5aJ6dn3YmPiI8Bt2ZClgcLt6A+UEmy3qGX0HG7Q5wD9X9geNOQB3ZiD/pGAGW08wS/wTxnWSnSBwdtZ03pUttfnFctkxULfDq4iG1ywdjqEk3F8QVFajQ0c76kWbt9LGAv2OGIi0CQQD2CmbVFXy4JeNHK3TDoLMjsUCiLa+qPnyyVDLDG9Ozb7wN2ydTrMhI+0udmjKvy/Lm1E2bKyp42iYuubEqvSAXAkEA7zNZsOgUe0q73sxXqrLQ7Fs7TNtIEXghrGmkVTHN0I7uMKzQ7KEbA6hfcBm4hPMoLa6Ag3m9tiMNBWtDWc/Y8wJAK0//dEl5EC3TSccTohCbGJBukV47i1u+teHuobw3U2I7F7FZxfgntflPAWqQu7PKieob01IRAv9cM2OLFbv/dwJBAIniXedeQMA5ekaaIEbjwQ8eH/bTyJ1ZVH/gfbwmc2+vlJo2ZFCjJcFcA3fJO9ZXnGeI2cfwG22sksr24+IXsAUCQG5yvVIleTDYqWuWVG1Rc8fk5UFjoZzJpp0nil0z+0fR5rogr4fxcH7vbWsE0id7gSvtV7KxPzkvJTpOK3yGDN0="
    
    var isAddFoods = false
    var isFromSetting = false
    
    var ossAccessKeyId = ""
    var ossAccessKeySecret = ""
    var ossEndpoint = ""//"https://oss-cn-shenzhen.aliyuncs.com"
    var ossExpiration = ""
    var ossSecurityToken = ""
    //OSS参数获取的时间
    var ossParamGetTime = 0
//    var ossBucketName = "lnsapp-static-o"
    
    let dateSourceYearArray = NaturalUtil().getNext3YearsArray()
    lazy var dateSourceMonthArray: NSArray = {
        var monthArray = NSMutableArray()
        for i in 1..<13{
            let str = "\(i)"
            monthArray.add(str)
        }
        return monthArray
    }()
    var dateArrayForStat = NSMutableArray()
    var dateArrayDealComplete = false
    
    //是否拥有发帖的权限
    var isAllowedPosterForum = false
    
    var abTestModel = ABTESTMODEL()
    
    var addressModel = AddressModel()
    let vipModel = VIPModel.shared
}

extension UserInfoModel{
    func updateMsg(dict:NSDictionary){
        DLLog(message: "UserInfoModel：\(dict)")
        self.birthDay = dict["birthday"]as? String ?? ""
        self.gender = dict.stringValueForKey(key: "gender")//"\(dict["gender"]as? Int ?? 0)"
        self.headimgurl = dict["headimgurl"]as? String ?? ""
        self.id = dict["id"]as? String ?? ""
        self.registDate = dict.stringValueForKey(key: "ctime")
        self.nickname = dict["nickname"]as? String ?? ""
        self.phone = dict["phone"]as? String ?? ""
        self.inviteCode = dict["invcode"]as? String ?? ""
        self.uLevel = dict.stringValueForKey(key: "ulevel")
        self.isAppStoreMark = dict["appstorerated"]as? String ?? "0"
        self.msgUnRead = dict.stringValueForKey(key: "unread") == "true" ? true : false
        self.idc = dict.stringValueForKey(key: "idc")
        self.streakDict = dict["streak"]as? NSDictionary ?? [:]
        self.avatarStatus = dict.stringValueForKey(key: "avatar_audit_status") == "1" ? .checking : .pass
        
        changePhoneStar()
        if self.gender == "1"{
            self.sex = "男"
        }else if self.gender == "2"{
            self.sex = "女"
        }else{
            self.sex = "保密"
        }
        
        self.isBindWeChat = dict["wxconnected"]as? String ?? "" == "true" ? true : false
        self.isBindAppId = dict["appleconnected"]as? String ?? "" == "true" ? true : false
       
        self.setMobMsg(dict: dict)
        updateShowMealsIfNeeded(dict: dict)
        
//        if self.msgUnRead == true{
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "serviceMsgUnRead"), object: nil)
//        }else{
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "serviceMsgRead"), object: nil)
//        }
        
        UserDefaults.standard.set(dict["phone"]as? String ?? "", forKey: userPhone)
    }
    func updateUserConfig(dict:NSDictionary) {
        self.isAppStoreMark = dict["appstorerated"]as? String ?? "0"
        self.statSportDataFromHealth = dict.stringValueForKey(key: "sport_calories_in_target")
        self.statSportDataToTarget = dict.stringValueForKey(key: "target_include_sport_calories")
        WidgetUtils().saveSportInTargetStatus(status: dict.stringValueForKey(key: "target_include_sport_calories"))
        self.show_water_status = dict.stringValueForKey(key: "drinking_water_status") == "1" ? true : false
        if dict.allKeys.contains(where: { "\($0)" == "ai_coach_status" }) {
            self.show_ai_coach_status = dict.stringValueForKey(key: "ai_coach_status") == "1" ? true : false
        }
        self.has_unread_latest_ai_coach_report = dict.stringValueForKey(key: "has_unread_latest_ai_coach_report") == "1" ? true : false
        self.show_next_advice = dict.stringValueForKey(key: "next_meal_advice_status") == "1" ? true : false
//        NotificationCenter.default.post(name: NOTIFI_NAME_SHORTCUTITEMS, object: nil)
//        self.setABTestModel(dict: WHUtils.getDictionaryFromJSONString(jsonString: dict.stringValueForKey(key: "params")))
        self.setABTestModel(dict: dict["params"]as? NSDictionary ?? [:])
//        let survery_button_status = dict.stringValueForKey(key: "survey_button_status") == "1" ? false : true
//        if self.hidden_survery_button_status != survery_button_status{
//            self.hidden_survery_button_status = survery_button_status
//            UserDefaults.set(value: "\(UserInfoModel.shared.hidden_survery_button_status ? 0 : 1)", forKey: .isShowSurveryButton)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
//        }
        
        let meal_time_status = dict.stringValueForKey(key: "meal_time_status") == "1" ? false : true
        if self.hiddenMeaTimeStatus != meal_time_status{
            self.hiddenMeaTimeStatus = meal_time_status
            UserDefaults.set(value: "\(UserInfoModel.shared.hiddenMeaTimeStatus ? 0 : 1)", forKey: .isShowLogsTime)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        }
        
        let natGoalStyle = dict.stringValueForKey(key: "nut_goal_style") == "2" ? true : false
        if self.showRemainCalories != natGoalStyle{
            self.showRemainCalories = natGoalStyle
            UserDefaults.set(value: "\(UserInfoModel.shared.showRemainCalories ? 2 : 1)", forKey: .isShowLogsRemainCalories)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsCaloriesStyleMsg"), object: nil)
        }
//        let meal_time_alert = dict.stringValueForKey(key: "")
//        if meal_time_alert.count > 0 {
//            self.mealsTimeAlertDict = WHUtils.getDictionaryFromJSONString(jsonString: meal_time_alert)
//        }
        self.mealsTimeAlertDict = dict["meal_time_alert"]as? NSDictionary ?? [:]
        
        self.dealCCStartMsg(dict: dict)
        
        updateShowMealsIfNeeded(dict: dict)
        
        if dict.stringValueForKey(key: "weight_unit") == "2"{
            self.weightUnit = 2
            self.weightUnitName = "斤"
            self.weightCoefficient = 2.0
        }else if dict.stringValueForKey(key: "weight_unit") == "3"{
            self.weightUnit = 3
            self.weightUnitName = "磅"
            self.weightCoefficient = 2.2046226
        }else{
            self.weightUnit = 1
            self.weightUnitName = "kg"
            self.weightCoefficient = 1.0
        }
    }
    //MARK: 处理碳循环   今日  信息
    func dealCCStartMsg(dict:NSDictionary) {
        if dict.stringValueForKey(key: "cc_start_date").count > 0 {
            self.ccStartDate = dict.stringValueForKey(key: "cc_start_date")
        }else{
            self.ccStartDate = Date().todayDate
        }
        
        if dict.stringValueForKey(key: "cc_start_date_offset_index").intValue > 0{
            self.ccStartOffsetIndex = dict.stringValueForKey(key: "cc_start_date_offset_index").intValue
        }else{
            self.ccStartOffsetIndex = 0
        }
    }
    func setABTestModel(dict:NSDictionary) {
        if self.abTestModel.isInit == false{
            self.abTestModel.isInit = true
            let AbTestDict = dict["ab_test"]as? NSDictionary ?? [:]
            if AbTestDict.stringValueForKey(key: "diet_log_note") == "B" {
                self.abTestModel.diet_log_note = .B
            }else{
                self.abTestModel.diet_log_note = .A
            }
            
            if AbTestDict.stringValueForKey(key: "tutorial_briefing_price_hidden") == "A"{
                self.abTestModel.tutorial_briefing_price_hidden = .A
            }else{
                self.abTestModel.tutorial_briefing_price_hidden = .B
            }
            NotificationCenter.default.post(name: NOTIFI_NAME_ABTEST, object: nil)
        }
    }
    func setMobMsg(dict:NSDictionary) {
        MobClick.profileSignIn(withPUID: "\(dict["phone"]as? String ?? "")", provider: "iOS")
        MobClick.userProfile(dict.stringValueForKey(key: "nickname"), to: "nickname")
        MobClick.userProfile(dict.stringValueForKey(key: "id"), to: "uId")
    }

    private func updateShowMealsIfNeeded(dict: NSDictionary) {
        guard dict.allKeys.contains(where: { "\($0)" == "show_meals" }),
              let showMealsNum = Int(dict.stringValueForKey(key: "show_meals")) else {
            return
        }

        if self.mealsNumber != showMealsNum {
            self.mealsNumber = showMealsNum
            UserDefaults.set(value: "\(showMealsNum)", forKey: .mealsNumber)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        }
    }

    func changePhoneStar() {
        self.phoneStar = WHUtils().maskPhoneNumber(self.phone)
//        if WHBaseViewVC().judgePhoneNumber(phoneNum: self.phone){
//            self.phoneStar = "\(self.phone.mc_clipFromPrefix(to: 3))****\(self.phone.mc_cutToSuffix(from: 7))"
//        }else{
//            self.phoneStar = self.phone
//        }
    }
    func clearMsg() {
        isHandlingForcedLogout = false
        clearDietPlanCreateDraftCache()
        ElaProIAPManager.shared.clearLocalEntitlementCache()
        self.birthDay = ""
        self.gender = ""
        self.isAppStoreMark = "0"
        self.registDate = ""
        self.headimgurl = ""
        self.id = ""
        self.nickname = ""
        self.phone = ""
        self.sex = "保密"
        self.uId = ""
        self.token = ""
        self.uLevel = ""
        self.inviteCode = ""
        
        self.isBindWeChat = false
        self.isBindAppId = false
        self.vipModel.reset()
        UserDefaults.set(value: [:], forKey: .jounal_meal_advice)
        UserDefaults.set(value: "0", forKey: .vipStatus)
        UserDefaults.setHabitRankListVMDataArray([])
    }

    func beginForcedLogoutHandlingIfNeeded() -> Bool {
        guard isHandlingForcedLogout == false else { return false }
        isHandlingForcedLogout = true
        return true
    }

    func resetForcedLogoutHandling() {
        isHandlingForcedLogout = false
    }
    
    func updateOssParams(dict:NSDictionary) {
        DLLog(message: "tools/oss/sts:\(dict)")
        self.ossAccessKeyId = dict["accessKeyId"]as? String ?? ""
        self.ossAccessKeySecret = dict["accessKeySecret"]as? String ?? ""
        self.ossEndpoint = dict["endpoint"]as? String ?? ""
        self.ossSecurityToken = dict["securityToken"]as? String ?? ""
        self.ossExpiration = dict["expiration"]as? String ?? ""
        self.ossParamGetTime = Date().timeStamp.intValue + 3000
    }
    
    func ossParamIsValid() -> Bool {
        DLLog(message: "oss参数校验:\(UserInfoModel.shared.ossParamGetTime)")
        if UserInfoModel.shared.ossAccessKeyId.count > 0 && (UserInfoModel.shared.ossParamGetTime > Date().timeStamp.intValue){
            DLLog(message: "oss参数校验:  有效")
            return true
        }
        DLLog(message: "oss参数校验:  无效")
        return false
    }
    
    //获取所有日期的数据
    func dealDataSourceArray() {
        DispatchQueue.global(qos: .userInitiated).async {
            for i in 0..<self.dateSourceYearArray.count{
                let yearInt = Int(self.dateSourceYearArray[i]as? String ?? "0") ?? 0
                for j in 0..<self.dateSourceMonthArray.count{
                    let monthInt = Int(self.dateSourceMonthArray[j]as? String ?? "0") ?? 0
    //                let monthString = "\(yearInt)年\(monthInt)月"
                    let daysNumForMonth = NaturalUtil().getDaysInMonth(year: yearInt, month: monthInt)
                    
                    let daysArray = NSMutableArray()
                    
                    var weeksNumber = 1
                    for day in 0..<daysNumForMonth{
                        
                        var dateString = ""
                        if monthInt < 10{
                            dateString = "\(yearInt)-0\(monthInt)"
                        }else{
                            dateString = "\(yearInt)-\(monthInt)"
                        }
                        if day < 9 {
                            dateString = "\(dateString)-0\(day+1)"
                        }else{
                            dateString = "\(dateString)-\(day+1)"
                        }
                        let weekDay = Date().getWeekdayIndex(from: dateString)
                        
                        
                        let dayDict = ["day":"\(day+1)",
                                       "weekDay":"\(weekDay)",
                                       "weekIndex":"\(weeksNumber)"]
                        daysArray.add(dayDict)
                        
                        if day == 0 && weekDay == 6{
                            //如果当月第一天日期为周六 ，则将周数 + 1
                            weeksNumber = weeksNumber + 1
                        }else if weekDay == 6 && day < daysNumForMonth - 1{
                            //如果当前日期为周六，且不是当月最后一天
                            weeksNumber = weeksNumber + 1
                        }
                    }
                    
                    let monthDict = ["month":"\(yearInt)年\(monthInt)月",
                                     "weeks":"\(weeksNumber)",
                                     "yearIndex":"\(yearInt)",
                                     "monthIndex":"\(monthInt)",
                                     "days":daysArray] as [String : Any]
                    
                    self.dateArrayForStat.add(monthDict)
                }
            }
            self.dateArrayDealComplete = true
        }
    }
    ///退出登录，清除本地个人信息，保留日志和身体数据
    ///
    /// `teardownTabBarControllers` 是这次为 401 / 多设备登录补的开关。
    /// 默认仍然是 `false`，表示走项目里原来的退出清理流程；
    /// 当 401 强制下线时传 `true`，会在切回欢迎页之前，额外释放旧的 tabbar 页面层级，
    /// 避免这些旧页面因为引用残留继续响应通知或继续发请求。
    func logoutClearMsg(teardownTabBarControllers: Bool = false) {
        LogsMealsAlertSetManage().removeAllNotifi()
        clearDietPlanCreateDraftCache()
        ElaProIAPManager.shared.clearLocalEntitlementCache()
        self.vipModel.reset()
//        UserInfoModel.shared.clearMsg()
//
//        UserDefaults.standard.setValue("", forKey: token)
//        UserDefaults.standard.setValue("", forKey: userId)
//        UserDefaults.set(value: "", forKey: .myFoodsList)
//        UserDefaults.set(value: "", forKey: .hidsoryFoodsAdd)
//        UserInfoModel.shared.uId = ""
//        UserInfoModel.shared.token = ""
//        QuestinonaireMsgModel.shared.surveytype = ""
//        LogsMealsAlertSetManage().removeAllNotifi()
//
//        WidgetUtils().saveUserInfo(uId: "", uToken: "")
        UserDefaults.removeAllBodyDataLoadFlag(uid: UserInfoModel.shared.uId)
        // 这里把释放 tabbar 的开关继续往下传，真正的 controller 清理在切 root 前完成。
        WHBaseViewVC().changeRootVcToWelcome(teardownTabBarControllers: teardownTabBarControllers)
        LogsSQLiteUploadManager().clearNaturalData()
        BodyDataSQLiteManager.getInstance().deleteAllData()
        LogsSQLiteManager.getInstance().deleteAllData()
        CourseProgressSQLiteManager.getInstance().deleteAllData()
        
        WidgetUtils().saveUserInfo(uId: "", uToken: "")
        UserDefaults.standard.setValue("", forKey: token)
        UserDefaults.standard.setValue("", forKey: userId)
        UserDefaults.set(value: "", forKey: .myFoodsList)
        UserDefaults.set(value: "", forKey: .hidsoryFoodsAdd)
//        UserInfoModel.shared.clearMsg()
    }
    
    private func clearDietPlanCreateDraftCache() {
        let prefix = "diet_plan_create_draft_"
        let defaults = UserDefaults.standard
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(prefix) {
            defaults.removeObject(forKey: key)
        }
    }
}
