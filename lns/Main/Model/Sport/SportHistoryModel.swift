//
//  SportHistoryModel.swift
//  lns
//
//  Created by Elavatine on 2024/11/25.
//


class SportHistoryModel: NSObject {
    
    var id = ""
    
    var sportItemId = ""
    
    var met = ""
    
    var name = ""
    
    var duration = ""
    var durationUser = ""
    var calories = ""
    var caloriesUser = ""
    var ctime = ""
    
    var sdate = ""
    
    var weight = ""
    
    //1  为APP记录的数据   2 为获取的健康APP数据，不可编辑
    var source = "1"
    //是否计入营养目标
    var isSyn = false
    
    func dealDict(dict:NSDictionary) -> SportHistoryModel {
        let model = SportHistoryModel()
        model.id = dict.stringValueForKey(key: "id")
        model.ctime = dict.stringValueForKey(key: "ctime")
        model.duration = dict.stringValueForKey(key: "duration")
        model.calories = dict.stringValueForKey(key: "calories")
        model.met = dict.stringValueForKey(key: "met")
        model.sdate = dict.stringValueForKey(key: "sdate")
        model.sportItemId = dict.stringValueForKey(key: "sportItemId")
        model.name = dict.stringValueForKey(key: "sportItemName")
        model.weight = dict.stringValueForKey(key: "weight")
        model.caloriesUser = dict.stringValueForKey(key: "caloriesUser")
        model.durationUser = dict.stringValueForKey(key: "durationUser")
        model.source = dict.stringValueForKey(key: "source")
        model.isSyn = dict.stringValueForKey(key: "sportCaloriesInTarget") == "1" ? true : false
        
        return model
    }
}
