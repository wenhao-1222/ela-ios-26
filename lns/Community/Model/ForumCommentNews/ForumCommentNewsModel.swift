//
//  ForumCommentNewsModel.swift
//  lns
//
//  Created by Elavatine on 2025/1/8.
//

//审核状态
enum FORUM_NEWS_READ_STATUS {
    case read     //已读
    case unread   //未读
}
//站内信类型
enum FORUM_NEWS_TYPE {
    case comment  //type = 1  说明是别人评论了你的帖子
    case reply    //type = 2
    case like     //type = 3
    case report   //type = 4  举报结果
    case follow   //type = 5 关注
}

class ForumCommentNewsModel: NSObject {
    
    ///消息id
    var id = ""
    ///评论id
    var commentId = ""
    ///评论内容
    var content = ""
    ///回复者头像
    var fromAvatar = ""
    ///回复者昵称
    var fromNickname = ""
    ///回复者id
    var fromUid = ""
    ///回复的图片
    var imageUrl = ""
    //是否已点赞
    var like = FORUM_AUDIT_STATUS.refuse
    
    var likeBizType = ""
    ///引用的内容
    var parentContent = ""
    ///引用的内容  用于显示  包含用户昵称
    var parentContentShow = ""
    ///引用的id
    var parentId = ""
    ///引用的图片
    var parentImageUrl = ""
    ///引用的昵称
    var parentNickname = ""
    ///引用的用户id
    var parentUid = ""
    ///帖子id
    var postId = ""
    ///发帖平台
    var postType = FORUM_SOURCE.customer
    ///帖子title
    var postTitle = ""
    ///回复的用户id
    var toUid = ""
    ///是否已读
    var readFlag = FORUM_NEWS_READ_STATUS.unread
    ///回复id
    var replyId = ""
    ///
    var title = ""
    ///
    var type = FORUM_NEWS_TYPE.comment
    //帖子 内容类型  图+文  、 视频 +文
    var contentType = CONTENT_TYPE.IMAGE
    //视频url
    var videoUrl : URL?
    var cTime = ""
    ///显示的时间
    var timeForShow = ""
    //评论或者回复，是否已删除
    var isDelete = false
    
    var postCoverUrl = ""
    //封面图类型
    var coverType = COVER_TYPE.IMAGE
    //封面为视频时，视频第一帧
    var coverImg : UIImage?
    //封面图宽度
    var coverImgWidth = SCREEN_WIDHT
    //封面图高度
    var coverImgHeight = kFitWidth(0)
    //封面  图片/视频的高度
    var contentWidth = kFitWidth(343)
    var contentHeight = kFitWidth(150)
    //评论内容距离底部间隙
    var bottomGap = kFitWidth(75)
    
    func dealModelWithDict(dict:NSDictionary) -> ForumCommentNewsModel {
        var model = ForumCommentNewsModel()
        
        model.id = dict.stringValueForKey(key: "id")
        model.title = dict.stringValueForKey(key: "title")
        model.fromAvatar = dict.stringValueForKey(key: "fromAvatar")
        model.fromNickname = dict.stringValueForKey(key: "fromNickname")
        model.fromUid = dict.stringValueForKey(key: "fromUid")
        model.parentNickname = dict.stringValueForKey(key: "parentNickname")
        model.parentUid = dict.stringValueForKey(key: "parentUid")
        model.postType = dict.stringValueForKey(key: "poster") == "1" ? .platform : .customer
        let timeString = dict.stringValueForKey(key: "ctime").replacingOccurrences(of: "T", with: " ")
        model.cTime = timeString
        model.timeForShow = ForumTimeUtils().changeTimeForShowNN(timeStr: dict.stringValueForKey(key: "ctime").replacingOccurrences(of: "T", with: " "),
                                                            nowTime: dict.stringValueForKey(key: "now").replacingOccurrences(of: "T", with: " "))
        
        if dict.stringValueForKey(key: "type") == "1"{
            model.type = .comment
        }else if dict.stringValueForKey(key: "type") == "2"{
            model.type = .reply
        }else if dict.stringValueForKey(key: "type") == "3"{
            model.type = .like
        }else if dict.stringValueForKey(key: "type") == "4"{
            model.type = .report
            model = self.dealReportDict(dict: dict, model: model)
            return model
        }else if dict.stringValueForKey(key: "type") == "5"{
            model.type = .follow
        }
        model.postTitle = dict.stringValueForKey(key: "postTitle")
        model.commentId = dict.stringValueForKey(key: "commentId")
        model.content = dict.stringValueForKey(key: "content")
        model.like = dict.stringValueForKey(key: "like") == "1" ? .pass : .refuse
        model.likeBizType = dict.stringValueForKey(key: "likeBizType")
        model.parentContent = dict.stringValueForKey(key: "parentContent")
        model.parentId = dict.stringValueForKey(key: "parentId")
        model.postId = dict.stringValueForKey(key: "postId")
        model.readFlag = dict.stringValueForKey(key: "readFlag") == "1" ? .read : .unread
        model.replyId = dict.stringValueForKey(key: "replyId")
        model.toUid = dict.stringValueForKey(key: "toUid")
        
        
        let imageArr = dict["image"]as? NSArray ?? []
        if imageArr.count > 0 {
            model.imageUrl = imageArr[0] as? String ?? ""
        }
        
        let parentImageArr = dict["parentImage"]as? NSArray ?? []
        if parentImageArr.count > 0 {
            model.parentImageUrl = parentImageArr[0] as? String ?? ""
        }
        
//        let postCoverImageArr = dict["postCover"]as? NSArray ?? []
//        if postCoverImageArr.count > 0 {
//            model.postCoverUrl = postCoverImageArr[0] as? String ?? ""
//            model.coverType = ForumModel().getCoverType(urlString: model.postCoverUrl)
//            if model.coverType == .VIDEO{
//                model.contentType = .VIDEO
//                model.videoUrl = URL(string: model.postCoverUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
//                model.coverImg = createImageWithColor(color: .WIDGET_COLOR_GRAY_BLACK_04)
//                VideoUtils().generateThumbnailFromVideo(videoURL: model.videoUrl!, maxSize: CGSize.init(width: kFitWidth(343), height: kFitWidth(343))) { image, size in
//                    if let coverImage = image{
//                        model.coverImg = image
//                        let videoW = kFitWidth(343)
//                        var videoH = videoW*(size.height)/(size.width)
//                        videoH = videoH > videoW ? videoW : videoH
//                        model.contentWidth = videoW
//                        model.contentHeight = videoH
//                        
////                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "forumListVideoGetFirstFrame"), object: ["id":model.id])
//                    }
//                }
//            }
//        }
        
        if model.toUid == UserInfoModel.shared.uId {
            model.parentContentShow = model.parentContent
            if model.parentContentShow == "" && model.parentImageUrl == ""{
                model.parentContentShow = "评论已删除"
            }
        }else{
            model.parentContentShow = "\(model.parentNickname):\(model.parentContent)"
        }
        if model.imageUrl.count > 0 {
            model.bottomGap = kFitWidth(95)
        }
        model.isDelete = dealDeleteStatus(dict: dict,model: model)
        
        if model.isDelete {
            model.bottomGap = kFitWidth(55)
        }
        
//        let coverInfo = dict[""]as? NSDictionary ?? [:]
        guard let coverInfo = dict["coverInfo"]as? NSDictionary,
                let coverOssUrl = coverInfo["ossUrl"]as? String
              else { return model }
        
        model.postCoverUrl = coverOssUrl
        
        let coverWidth = coverInfo.doubleValueForKey(key: "coverWidth")
        let coverHeight = coverInfo.doubleValueForKey(key: "coverHeight")
        
        if coverWidth > 0 && coverHeight > 0 {
            if (model.coverImgWidth*coverHeight/coverWidth)/model.coverImgWidth > 5/4{
                model.coverImgHeight = model.coverImgWidth*5/4
            }else{
                model.coverImgHeight = model.coverImgWidth*coverHeight/coverWidth
            }
        }else{
            model.coverImgHeight = kFitWidth(200)
        }
        
        return model
    }
    
    func dealReportDict(dict:NSDictionary,model:ForumCommentNewsModel) -> ForumCommentNewsModel {
        model.content = dict.stringValueForKey(key: "msgContent")
        model.parentNickname = dict.stringValueForKey(key: "toNickname")
        model.parentUid = dict.stringValueForKey(key: "toUid")
        
        return model
    }
    func dealDeleteStatus(dict:NSDictionary,model:ForumCommentNewsModel) -> Bool {
        if dict.stringValueForKey(key: "type") == "1" || dict.stringValueForKey(key: "type") == "2"{
            let imageArr = dict["image"]as? NSArray ?? []
            let content = dict.stringValueForKey(key: "content")
            let parentContent = dict.stringValueForKey(key: "parentContent")
            if imageArr.count == 0 && content == ""{//}(content == "" || parentContent == ""){
                if dict.stringValueForKey(key: "type") == "1"{
                    model.content = "评论已删除"
                }else if dict.stringValueForKey(key: "type") == "2"{
                    model.content = "回复已删除"
                }
                return true
            }
        }
        return false
    }
}
