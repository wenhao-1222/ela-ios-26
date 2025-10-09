//
//  ForumPostPollModel.swift
//  lns
//  当前用户投票信息，若未投票，则为空
//  Created by Elavatine on 2024/12/20.
//


class ForumPostPollModel: NSObject {
    
    //是否已投票
    var isPoll = false
    
    var cTime = ""
    
    var id = ""
    //用户的投票选项
    var pollArray:[ForumPollModel] = [ForumPollModel]()
    //帖子 id
    var postId = ""
    //投票类型
    var pollType = POLL_TYPE.single
    
    func dealDictForModel(dict:NSDictionary) -> ForumPostPollModel{
        let model = ForumPostPollModel()
        if dict.stringValueForKey(key: "id").count > 0 {
            model.isPoll = true
            model.cTime = dict.stringValueForKey(key: "ctime")
            model.id = dict.stringValueForKey(key: "id")
            model.postId = dict.stringValueForKey(key: "postId")
            model.pollType = dict.stringValueForKey(key: "pollType") == "1" ? .single : .multiple
            
            let options = dict["pollOption"] as? NSArray ?? []
            
            for i in 0..<options.count{
                let optionTitle = options[i]as? String ?? ""
                
                let pollItemModel = ForumPollModel()
                pollItemModel.title = optionTitle
                model.pollArray.append(pollItemModel)
            }
            
        }else{
            model.isPoll = false
        }
        
        return model
    }
    
}
