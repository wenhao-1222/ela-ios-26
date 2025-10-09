//
//  SportCatogaryModel.swift
//  lns
//
//  Created by Elavatine on 2024/11/22.
//


class SportCatogaryModel: NSObject {
    
    var sn = ""
    
    var id = ""
    
    var ctime = ""
    
    var icon = ""
    
    var name = ""
    
    func dealDictForModel(dict:NSDictionary) -> SportCatogaryModel {
        let model = SportCatogaryModel()
        model.sn = dict.stringValueForKey(key: "sn")
        model.id = dict.stringValueForKey(key: "id")
        model.ctime = dict.stringValueForKey(key: "ctime")
        model.icon = dict.stringValueForKey(key: "icon")
        model.name = dict.stringValueForKey(key: "name")
        
        return model
    }
}
