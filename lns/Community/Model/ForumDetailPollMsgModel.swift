//
//  ForumDetailPollMsgModel.swift
//  lns
//
//  Created by Elavatine on 2024/12/19.
//


enum POLL_TYPE {
    case single  //单选
    case multiple //多选
}

class ForumDetailPollMsgModel: NSObject {
    
    //投票类型
    var pollType = POLL_TYPE.single
    //投票标题
    var pollTitle = ""
    //是否有图片
    var hasImage = FORUM_AUDIT_STATUS.refuse
    //是否返回投票结果
    var showResult = FORUM_AUDIT_STATUS.pass
    //最多选多少个选项
    var optionThreshold = 1
    //选项数组
    var pollArray:[ForumPollModel] = [ForumPollModel]()
    
    
    func dealDataSource(dict:NSDictionary) -> ForumDetailPollMsgModel {
        let model = ForumDetailPollMsgModel()
        model.pollType = dict.stringValueForKey(key: "pollType") == "1" ? .single : .multiple
        model.hasImage = dict.stringValueForKey(key: "haveImage") == "1" ? .pass : .refuse
        model.showResult = dict.stringValueForKey(key: "showResult") == "1" ? .pass : .refuse
        model.optionThreshold = Int(dict.doubleValueForKey(key: "optionThreshold"))
        
        if dict.stringValueForKey(key: "pollTitle").count > 0 {
            model.pollTitle = dict.stringValueForKey(key: "pollTitle")
        }else{
            model.pollTitle = "投票选项"
        }
        
        let pollOptions = dict["pollOption"]as? NSArray ?? []
        
        for i in 0..<pollOptions.count{
            let dict = pollOptions[i]as? NSDictionary ?? [:]
            let pollItemModel = ForumPollModel()
            pollItemModel.title = dict.stringValueForKey(key: "content")
            pollItemModel.sn = dict.stringValueForKey(key: "sn")
            
            if model.hasImage == .pass{
                let imgs = dict["image"]as? NSArray ?? []
                if imgs.count > 0 {
                    pollItemModel.imageUrl = imgs[0]as? String ?? ""
                }
            }
            model.pollArray.append(pollItemModel)
        }
        
        return model
    }
}

