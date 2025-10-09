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
    
    func dealDataSource(dict:NSDictionary) {
        DLLog(message: "常量数据：\(dict)")
        self.cc_label_array = dict["cc_label"]as? NSArray ?? []
        self.fitness_label_array = dict["fitness_label"]as? NSArray ?? []
        self.food_unit_array = dict["food_unit"]as? NSArray ?? []
        self.diet_log_note_label_array = dict["diet_log_note_label"]as? NSArray ?? []
        
        
        self.forum_report_type_dict = dict["forum_report_type"]as? NSDictionary ?? [:]
        
        self.chat_reply = dict.stringValueForKey(key: "chat_reply")
        self.chat_welcome = dict.stringValueForKey(key: "chat_welcome")
        
        UserDefaults.set(value: self.fitness_label_array, forKey: .fitness_label_array)
//        self.cc_label_array = WHUtils.getArrayFromJSONString(jsonString: dict.stringValueForKey(key: "cc_label"))
//        self.fitness_label_array = WHUtils.getArrayFromJSONString(jsonString: dict.stringValueForKey(key: "fitness_label"))
//        self.food_unit_array = WHUtils.getArrayFromJSONString(jsonString: dict.stringValueForKey(key: "food_unit"))
//        self.forum_report_type_dict = WHUtils.getDictionaryFromJSONString(jsonString: dict.stringValueForKey(key: "forum_report_type"))
    }
}
