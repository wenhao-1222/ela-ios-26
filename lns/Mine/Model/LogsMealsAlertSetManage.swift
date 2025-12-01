//
//  LogsMealsAlertSetManage.swift
//  lns
//
//  Created by Elavatine on 2024/10/18.
//

import UserNotifications

class LogsMealsAlertSetManage: NSObject {
//    var lunchPlaceHoderArrays =  ["🗂️ 午餐空缺，数据完整度待提高",
//                                 "🕒 午餐时间已过，记录一下防止遗忘",
//                                 "🔔 午餐数据缺失，提醒已启动，立即补记",
//                                 "🕒 午餐刚过不久，此刻记录最清楚，顺手补一下省得晚上回想",
//                                 "🧩 午餐还没记录，营养拼图留空格，补上吗？",
//                                 "🔄 午餐缺口未补，全日统计无法闭环",
//                                 "📌 午餐漏记会造成计算偏差，马上补上",
//                                 "📈 进度曲线停在午餐，补记一餐继续向上",
//                                 "🌟 一餐之差，影响全天评估，去记录午餐吧",
//                                 "🔄 午餐留空，今天的摄入统计不完整，补记后结果更可靠",
//                                 "📊 午餐未填，全天的饮食情况会少一段，记录后更容易回顾",
//                                 "🕒 午餐时间已过，趁现在还记得，补记一下防止遗忘",
//                                 "🌱 午餐数据缺失，不容易判断今天吃得多还是少，记录一下方便自查",
//                                 "😯 午餐还空着呢，别忘了记录喔",
//                                 "💪🏼 你的午餐还没记录，坚持自律才能养成习惯",
//                                 "👊🏼 是时候记录午餐了"]
//    var dinnerPlaceHoderArrays = ["🧩 晚餐还没记录，不要让前面努力的成果白费",
//                                  "🕒 趁现在还记得，把这一餐补上，才不辜负前面花的时间",
//                                  "🏅 记录晚餐可守住连续打卡，别让它断",
//                                  "🛡️ 晚餐数据显示空白，完成后提升准确度",
//                                  "🗂️ 晚餐记录待补，记录保持数据连贯",
//                                  "📌 晚餐缺口会拉低今日完成度",
//                                  "🎯 晚餐未录，卡路里预算待校准",
//                                  "⏰ 晚餐时间已过，及时记录防遗忘",
//                                  "🌟 缺了晚餐，影响今日数据准确度，补上吧",
//                                  "🧩 晚餐漏记，营养拼图将留空白",
//                                  "📝 记录晚餐，给今日画上完整句号",
//                                  "🔥 晚餐还没记录，不要让一时的松懈影响你的自律",
//                                  "🔔 晚餐未记录，养成自律习惯就差一步",
//                                  "⚠️ 晚餐还没记录，现在不记更待何时？",
//                                  "🙏🏼 去记录晚餐吧，求求你了",
//                                  "🕒 到点记录晚餐了"]
    private let mealPrefix = "meal_reminder_"
    
    func removeAllNotifi() {
        //        //移除所有本地已展示的通知
//        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let ids = pendingMealIdentifiers()
//        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    //MARK: 刷新本地用餐提醒
    public func refreshClockAlertMsg() {
        removeAllNotifi()
        UNUserNotificationCenter.current().getNotificationSettings { settings in
                    if settings.authorizationStatus == .authorized {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { complete, error in
//            if complete{
                DLLog(message: "有【通知】权限")
                let mandatory = UserInfoModel.shared.mealsTimeAlertDict.stringValueForKey(key: "mandatory")
                let dataSourceArray = NSMutableArray(array: UserInfoModel.shared.mealsTimeAlertDict["alert"]as? NSArray ?? [])
                
                for i in 0..<dataSourceArray.count{
                    //ps:用户设置显示3餐的时候，4、5、6餐的提醒无效
                    if i+1 <= UserInfoModel.shared.mealsNumber{
                        let dict = dataSourceArray[i]as? NSDictionary ?? [:]
                        if dict.stringValueForKey(key: "status") == "1"{
                            self.dealClockMsg(dict: dict, mandatory: mandatory)
                        }
                    }
                }
            }
        }
    }
    
    private func dealClockMsg(dict:NSDictionary,mandatory:String){
        let rotation = dict["rotation"]as? NSArray ?? []
        let clock = dict.stringValueForKey(key: "clock").mc_clipFromPrefix(to: 5)
        var remark = dict.stringValueForKey(key: "remark")
        
        if remark.count > 0 {
            
        }else{
//            if dict.stringValueForKey(key: "sn") == "2"{
//                remark = lunchPlaceHoderArrays.randomElement() ?? dict.stringValueForKey(key: "placeholder")
//            }else if dict.stringValueForKey(key: "sn") == "3"{
//                remark = dinnerPlaceHoderArrays.randomElement() ?? dict.stringValueForKey(key: "placeholder")
//            }else{
//                remark = dict.stringValueForKey(key: "placeholder")
//            }
            remark = dict.stringValueForKey(key: "placeholder")
        }
        
        let nextWeekDays = NaturalUtil().getDateNextWeekDaysArray()
        
        for i in 0..<nextWeekDays.count{
            let day = nextWeekDays[i]as? String ?? ""//未来一周的日期
            //日期对应 周几
            let dayWeek = Date().getWeekdayIndex(from: day)
//            DLLog(message: "\(dayWeek)  -- \(day)")
            
            //如果用户当天设置了闹钟，接下来判断是否强制
            
            if rotation.contains(dayWeek){
                //提醒的  日期  时  分  秒
                let dateString = "\(day) \(clock):00"
                let date = Date().changeDateStringToDate(dateString: dateString,formatter: "yyyy-MM-dd HH:mm:ss")
//                DLLog(message: "****** \(dateString)  -- \(date) \n sn:\(dict.stringValueForKey(key: "sn"))  \n remark:\(remark)")
                
                if dict.stringValueForKey(key: "sn") == "2"{
                    if dict.stringValueForKey(key: "remark") == ""{
                        remark = ConstantModel.shared.lunchPlaceHoderArrays.randomElement() ?? dict.stringValueForKey(key: "placeholder")
                    }
                }else if dict.stringValueForKey(key: "sn") == "3"{
                    if dict.stringValueForKey(key: "remark") == ""{
                        remark = ConstantModel.shared.dinnerPlaceHoderArrays.randomElement() ?? dict.stringValueForKey(key: "placeholder")
                    }
                }
                
                //1.强制，则不获取日志信息
                if mandatory == "1"{
//                    scheduleLocalNotification(title: "Elavatine", body: remark, date: date)
                    
                    scheduleLocalNotification(title: "Elavatine", body: remark, date: date, sn: dict.stringValueForKey(key: "sn"), day: day)
                }else{//2.不强制，则获取日志信息，判断当餐是否有食物
                    judgeLogsData(title: "Elavatine", body: remark, date: date,dateString:day,sn: dict.stringValueForKey(key: "sn"))
                }
            }
        }
    }
    //非强制提醒，判断当天日志是否已添加食物
    func judgeLogsData(title: String, body: String,date:Date,dateString:String,sn:String) {
        let logsDict = LogsSQLiteManager.getInstance().queryLogsData(sdata: dateString)
        let mealsArray = NSMutableArray(array: WHUtils.getArrayFromJSONString(jsonString: logsDict["foods"]as? String ?? "[]"))
        var isEat = false
        for i in 0..<mealsArray.count{
            if "\(i+1)" == sn{
                let mealPerArr = mealsArray[i]as? NSMutableArray ?? []
                for j in 0..<mealPerArr.count{
                    let dictTemp = mealPerArr[j]as? NSMutableDictionary ?? [:]
                    if dictTemp.stringValueForKey(key: "state") == "1"{
                        isEat = true
                        break
                    }
                }
            }
        }
        
        //如果当天日志，当餐没有食物，则提醒
        if isEat == false{
            scheduleLocalNotification(title: title, body: body, date: date, sn: sn, day: dateString)
        }
    }
    //MARK: 注册本地通知
    private func scheduleLocalNotification(title: String, body: String,date:Date, sn:String, day:String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = ((content.badge?.intValue ?? 0) + 1) as NSNumber
        let components = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        // 设置触发器
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let id = notificationIdentifier(day: day, sn: sn)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        // 添加请求
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func notificationIdentifier(day:String, sn:String) -> String {
        return "\(mealPrefix)\(day)_\(sn)"
    }

    private func pendingMealIdentifiers() -> [String] {
        var ids = [String]()
        let dataSourceArray = NSMutableArray(array: UserInfoModel.shared.mealsTimeAlertDict["alert"] as? NSArray ?? [])
        let days = NaturalUtil().getDateNextWeekDaysArray()
        for day in days {
            let dayStr = day as? String ?? ""
            for item in dataSourceArray {
                let dict = item as? NSDictionary ?? [:]
                let sn = dict.stringValueForKey(key: "sn")
                ids.append(notificationIdentifier(day: dayStr, sn: sn))
            }
        }
        return ids
    }
}


//    var lunchPlaceHoderArrays = ["📒 午餐记录仍为空白，填上后今日数据即可完整",
//                                 "🧩 午餐缺少，营养拼图留空格，补上吗？",
//                                 "📈 进度曲线停在午餐，补记一餐继续向上",
//                                 "🚀 午餐未填，今日目标还差最后一步",
//                                 "🏅 记录午餐可守住连续打卡，别让它断",
//                                 "🔄 午餐缺口未补，全日统计无法闭环",
//                                 "🔔 午餐数据缺失，提醒已启动—立即补记",
//                                 "🏃‍ 距日摄入目标仅差午餐一步，加油！",
//                                 "📊 午餐未录，今日报告暂缓生成",
//                                 "🔰 午餐还没登场，完成后即可查看全天概览",
//                                 "📌 午餐漏记会造成估算偏差，马上补上",
//                                 "✏️ 午餐记录留空，填完更好掌控饮食",
//                                 "📋 午餐尚未登记，今天清单待补齐",
//                                 "🔥 午餐缺席，进步条将中断—补上维持连贯",
//                                 "🌟 一餐之差，影响全天评估，记录午餐吧",
//                                 "🕒 午餐时间已过，记录一下防止遗忘",
//                                 "🛡️ 午餐未填，全天统计防护值下降",
//                                 "🌱 午餐数据待补，全日摄入才可靠",
//                                 "📍 午餐仍未记录，完成后才算达成日目标",
//                                 "🗂️ 午餐空缺，数据完整度待提高"]
    
//    var dinnerPlaceHoderArrays = ["🍽️ 晚餐记录为空，补上后锁定今日成果",
//                                 "🌙 晚餐缺失，夜间报告将留缺口，请补充",
//                                 "🔗 连续打卡待续，晚餐尚未记录",
//                                 "📈 今天曲线停在晚餐，再添一格即可封顶",
//                                 "🔔 晚餐未录，全天统计尚不完整",
//                                 "🚀 记录晚餐，立刻完成日目标收官",
//                                 "🏅 补记晚餐守住连续达标徽章",
//                                 "🧩 晚餐漏记，营养拼图将留空白",
//                                 "📊 晚餐数据缺口，今日汇总暂缓发布",
//                                 "🎯 晚餐未录，卡路里预算待校准",
//                                 "💡 记录晚餐即可生成完整日报",
//                                 "🌟 缺了晚餐，影响今日评分，补上吧",
//                                 "⏰ 晚餐时间已过，及时记录防遗忘",
//                                 "🛡️ 晚餐数据显示空白，完成后提升准确度",
//                                 "🔄 晚餐未填，明日建议将以缺口开场",
//                                 "📌 晚餐缺口会拉低今日完成度",
//                                 "🔥 只差晚餐，今日连胜可保",
//                                 "🗂️ 晚餐记录待补，一键保持数据连贯",
//                                 "🚧 晚餐未记，数据链待修复",
//                                 "📝 记录晚餐，给今日画上完整句号"]
