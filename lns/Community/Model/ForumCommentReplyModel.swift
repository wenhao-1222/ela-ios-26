//
//  ForumCommentReplyModel.swift
//  lns
//
//  Created by Elavatine on 2024/11/13.
//

import Kingfisher


class ForumCommentReplyModel: NSObject {
    //id
    var id = ""
    //评论id
    var commentId = ""
    //帖子id
    var postId = ""
    //回复id
    var parentId = ""
    //头像   评论者
    var headImgUrl = ""
    var nickName = ""
    var userId = ""
    //头像   被回复者
    var headImgUrlTo = ""
    var nickNameTo = ""
    var userIdTo = ""
    //类型   1  评论   2 回复
    var type = ""
    //回复
    var replyId = ""
    //评论内容
    var commentString = ""
    var commentHeight = kFitWidth(0)
    //评论的图片
    var imgUrl = ""
    var imgWidth = kFitWidth(210)
    var imgHeight = kFitWidth(0)
    var imgView = UIImageView()
    var commentImg = UIImage()
    //评论时间
    var time = ""
    var timeForShow = ""
    //ip地址
    var addressIp = ""
    //是否点赞
    var upvote = FORUM_AUDIT_STATUS.refuse
    //点赞数
    var upvoteCount = ""
    //是否是作者
    var isAuthor = FORUM_AUDIT_STATUS.refuse
    //是否作者赞过
    var isAuthorLike = FORUM_AUDIT_STATUS.refuse
    //是否为官方认证
    var isKeyUser = FORUM_AUDIT_STATUS.refuse
    
    var contentHeight = kFitWidth(36)
    
    func dealData(dict:NSDictionary) -> ForumCommentReplyModel {
        let model = ForumCommentReplyModel()
        model.commentId = dict.stringValueForKey(key: "commentId")
        model.id = dict.stringValueForKey(key: "id")
        model.commentString = dict.stringValueForKey(key: "content").trimmingCharacters(in: .whitespacesAndNewlines)
        model.postId = dict.stringValueForKey(key: "postId")
        model.parentId = dict.stringValueForKey(key: "parentId")
        
        model.upvote = dict.stringValueForKey(key: "like") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.upvoteCount = dict.stringValueForKey(key: "likeCount")
        
        model.isAuthor = dict.stringValueForKey(key: "isAuthor") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.isKeyUser = dict.stringValueForKey(key: "keyUser") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        
//        if model.isAuthor == .pass && model.upvote == .pass{
//            model.isAuthorLike = .pass
//        }else{
//            model.isAuthorLike = .refuse
//        }
        
        model.headImgUrl = dict.stringValueForKey(key: "fromAvatar")
        model.nickName = dict.stringValueForKey(key: "fromNickname")
        model.userId = dict.stringValueForKey(key: "fromUid")
        
        model.headImgUrlTo = dict.stringValueForKey(key: "toAvatar")
        model.nickNameTo = dict.stringValueForKey(key: "toNickname")
        model.userIdTo = dict.stringValueForKey(key: "toUid")
        
        let timeString = dict.stringValueForKey(key: "ctime").replacingOccurrences(of: "T", with: " ")
        model.time = timeString
        
//        model.timeForShow = Date().changeDateFormatter(dateString: timeString, formatter: "yyyy-MM-dd HH:mm:ss", targetFormatter: "MM-dd")
        model.timeForShow = ForumTimeUtils().changeTimeForShowNN(timeStr: dict.stringValueForKey(key: "ctime").replacingOccurrences(of: "T", with: " "),
                                                            nowTime: dict.stringValueForKey(key: "now").replacingOccurrences(of: "T", with: " "))
        model.addressIp = dict.stringValueForKey(key: "location")
        
        let imageArr = dict["image"]as? NSArray ?? []
        if imageArr.count > 0 {
            model.imgUrl = imageArr[0]as? String ?? ""
        }
        
        if model.commentString.count > 0 {
            if model.nickNameTo.count > 0 {
                let str = "回复 \(model.nickNameTo) \(model.commentString)"
                model.commentHeight = self.getCommentHeight(comment: str)
            }else{
                model.commentHeight = self.getCommentHeight(comment: "\(model.commentString)")
//                model.commentHeight = self.getCommentHeight(comment: "\(model.commentString) \(model.timeForShow) \(model.addressIp)")
            }
            model.contentHeight = model.contentHeight + model.commentHeight
        }
        
        if model.imgUrl.count > 0 {
//            let imgUrl = URL(string: model.imgUrl)
            var imgW = kFitWidth(210)*0.6
            
            DSImageUploader().dealImgUrlSignForOss(urlStr: model.imgUrl) { signUrl in
                guard let resourceUrl = URL(string: signUrl) else{
                    return
                }
                
                let resource = KF.ImageResource(downloadURL: resourceUrl, cacheKey: model.imgUrl)
                self.imgView.kf.setImage(with: resource,options: [.transition(.fade(0.2))]) { [self] result in
                    DLLog(message: "result:\(result)")
                    
                    let imgOriSize = imgView.image?.size
                    var imgOriginH = imgW * ((imgOriSize?.height ?? 0) / (imgOriSize?.width ?? 1))
                    
                    if imgOriginH > imgW{
                        imgOriginH = imgW
                        imgW = imgOriginH * ((imgOriSize?.width ?? 0) / (imgOriSize?.height ?? 1))
                    }
                    model.imgWidth = imgW
                    model.imgHeight = imgOriginH
                    
                    model.commentImg = imgView.image ?? UIImage()
                    model.contentHeight = model.contentHeight + kFitWidth(10) + model.imgHeight
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "commentImgLoaded"), object: nil)
                }
            }
        }
        
        model.contentHeight = model.contentHeight + kFitWidth(22)
        
        //无文字，纯图  如果是回复的另外一条回复 需要添加  “回复”  一行的高度
        if model.commentString.count == 0 && model.nickNameTo.count > 0 && model.parentId.count > 0{
            model.contentHeight = model.contentHeight + kFitWidth(22)
        }
        
        return model
    }
    
    func getCommentHeight(comment:String) -> CGFloat {
        return WHUtils().getHeightOfString(string: comment, font: .systemFont(ofSize: 14, weight: .medium), width: kFitWidth(217))
    }
}
