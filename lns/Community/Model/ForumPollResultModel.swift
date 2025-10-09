//
//  ForumPollResultModel.swift
//  lns
//  投票结果
//  Created by Elavatine on 2024/12/20.
//

class ForumPollResultModel: NSObject {
    
    //参与人数
    var participants = 1
    
    var total = 1
    
    var statistics = NSArray()
    
    func dealDictForModel(dict:NSDictionary) -> ForumPollResultModel {
        let model = ForumPollResultModel()
        
        model.participants = dict.stringValueForKey(key: "participants").intValue
        model.total = dict.stringValueForKey(key: "total").intValue
        model.statistics = dict["statistics"]as? NSArray ?? []
        
        return model
    }
}
