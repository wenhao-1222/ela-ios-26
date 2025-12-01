//
//  ConstantModel.swift
//  lns
//
//  Created by Elavatine on 2025/6/18.
//


class ConstantModel {
    
    static let shared = ConstantModel()
    
    private init(){
        
    }
    ///碳循环标签
    var cc_label_array = NSArray()
    ///联系客服自动回复语
    var chat_reply = ""
    ///联系客服自动欢迎语
    var chat_welcome = ""
    ///锻炼身体部位的标签
    var fitness_label_array = NSArray()
    ///食物单位
    var food_unit_array = NSArray()
    ///举报类型
    var forum_report_type_dict = NSDictionary()
    ///日志--注释  标签
    var diet_log_note_label_array = NSArray()
    ///AI识别--功能是否能用
    var ai_identify_image_status = true
    
    var lunchPlaceHoderArrays:[String] = ["🗂️ 午餐空缺，数据完整度待提高",
                                          "🕒 午餐时间已过，记录一下防止遗忘",
                                          "🔔 午餐数据缺失，提醒已启动，立即补记",
                                          "🕒 午餐刚过不久，此刻记录最清楚，顺手补一下省得晚上回想",
                                          "🧩 午餐还没记录，营养拼图留空格，补上吗？",
                                          "🔄 午餐缺口未补，全日统计无法闭环",
                                          "📌 午餐漏记会造成计算偏差，马上补上",
                                          "📈 进度曲线停在午餐，补记一餐继续向上",
                                          "🌟 一餐之差，影响全天评估，去记录午餐吧",
                                          "🔄 午餐留空，今天的摄入统计不完整，补记后结果更可靠",
                                          "📊 午餐未填，全天的饮食情况会少一段，记录后更容易回顾",
                                          "🕒 午餐时间已过，趁现在还记得，补记一下防止遗忘",
                                          "🌱 午餐数据缺失，不容易判断今天吃得多还是少，记录一下方便自查",
                                          "😯 午餐还空着呢，别忘了记录喔",
                                          "💪🏼 你的午餐还没记录，坚持自律才能养成习惯",
                                          "👊🏼 是时候记录午餐了"]
    
    var dinnerPlaceHoderArrays:[String] = ["🧩 晚餐还没记录，不要让前面努力的成果白费",
                                           "🕒 趁现在还记得，把这一餐补上，才不辜负前面花的时间",
                                           "🏅 记录晚餐可守住连续打卡，别让它断",
                                           "🛡️ 晚餐数据显示空白，完成后提升准确度",
                                           "🗂️ 晚餐记录待补，记录保持数据连贯",
                                           "📌 晚餐缺口会拉低今日完成度",
                                           "🎯 晚餐未录，卡路里预算待校准",
                                           "⏰ 晚餐时间已过，及时记录防遗忘",
                                           "🌟 缺了晚餐，影响今日数据准确度，补上吧",
                                           "🧩 晚餐漏记，营养拼图将留空白",
                                           "📝 记录晚餐，给今日画上完整句号",
                                           "🔥 晚餐还没记录，不要让一时的松懈影响你的自律",
                                           "🔔 晚餐未记录，养成自律习惯就差一步",
                                           "⚠️ 晚餐还没记录，现在不记更待何时？",
                                           "🙏🏼 去记录晚餐吧，求求你了",
                                           "🕒 到点记录晚餐了"]
    
    func dealDataSource(dict:NSDictionary) {
        DLLog(message: "常量数据：\(dict)")
        self.ai_identify_image_status = dict.stringValueForKey(key: "ai_identify_image_status") == "1"
        self.cc_label_array = dict["cc_label"]as? NSArray ?? []
        self.fitness_label_array = dict["fitness_label"]as? NSArray ?? []
        self.food_unit_array = dict["food_unit"]as? NSArray ?? []
        self.diet_log_note_label_array = dict["diet_log_note_label"]as? NSArray ?? []
        
        let remindTips = dict["diet_log_missed_remind_tips"]as? NSDictionary ?? [:]
        
        if let lunchTips = remindTips["lunchTips"]as? [String] ,
           lunchTips.count > 0{
            self.lunchPlaceHoderArrays = lunchTips
        }
        if let dinnerTips = remindTips["dinnerTips"]as? [String] ,
           dinnerTips.count > 0{
            self.dinnerPlaceHoderArrays = dinnerTips
        }
//        self.lunchPlaceHoderArrays = remindTips["lunchTips"]as? [String] ?? [String]()
//        self.dinnerPlaceHoderArrays = remindTips["dinnerTips"]as? [String] ?? [String]()
        
        self.forum_report_type_dict = dict["forum_report_type"]as? NSDictionary ?? [:]
        
        self.chat_reply = dict.stringValueForKey(key: "chat_reply")
        self.chat_welcome = dict.stringValueForKey(key: "chat_welcome")
        
        UserDefaults.set(value: self.fitness_label_array, forKey: .fitness_label_array)
    }
}

