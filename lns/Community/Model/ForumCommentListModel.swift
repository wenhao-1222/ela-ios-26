//
//  ForumCommentListModel.swift
//  lns
//
//  Created by Elavatine on 2024/11/13.
//

class ForumCommentListModel: NSObject {
    
    var commentModel = ForumCommentModel()
    
    var replyModels = [ForumCommentReplyModel]()
    
    
    func replyModelIds() -> [String] {
        var ids:[String] = [String]()
        
        for model in self.replyModels{
            ids.append(model.id)
        }
        
        return ids
    }
}
