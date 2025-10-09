//
//  ForumModel.swift
//  lns
//
//  Created by Elavatine on 2024/11/1.
//

//帖子类型
public enum FORUM_TYPE {
    case common   //通用
    case poll     //投票
}
//发帖放
enum FORUM_SOURCE {
    case platform //后台
    case customer //用户
}
//审核状态
enum FORUM_AUDIT_STATUS {
    case pass     //审核通过
    case refuse   //拒绝
}
//帖子可见范围
enum FORUM_VISIBLE_SCOPE {
    case owner
    case fans
    case all
}
//帖子封面 类型
enum COVER_TYPE {
    case IMAGE  //图片
    case VIDEO  //视频
}
enum CONTENT_TYPE {
    case IMAGE   //图片+ 文
    case VIDEO   //视频 + 文
    case TEXT
}
class ForumModel: NSObject {
    
    var id = ""
    //标题
    var title = ""
    //标题高度
    var titleHeight = kFitWidth(0)
    //副标题
    var subTitle = ""
    //富文本
    var content = ""
    //帖子类型
    var type = FORUM_TYPE.common
    //浏览量
    var postViewCount = ""
    //封面图
    var covers = NSArray()
    //封面缩略图
    var coverThumbImgUrl = ""
    //封面图宽度
    var coverImgWidth = SCREEN_WIDHT-kFitWidth(32)
    //封面图高度
    var coverImgHeight = kFitWidth(0)
    //封面图类型
    var coverType = COVER_TYPE.IMAGE
    //内容类型  图+文  、 视频 +文
    var contentType = CONTENT_TYPE.IMAGE
    //H5链接
    var webLink = ""
    //置顶
    var isTop = FORUM_AUDIT_STATUS.refuse
    //用户头像
    var headImgUrl = ""
    
//    var isPoll
    
    //是否点赞
    var upvote = FORUM_AUDIT_STATUS.refuse
    //点赞数
    var upvoteCount = ""
    //是否能点赞
    var likable = FORUM_AUDIT_STATUS.pass
    //评论数
    var commentCount = ""
    //总评论数  =  评论 + 回复
    var totalCommentCount = ""
    
    //系统当前时间
    var serverTime = ""
    //创建时间
    var cTime = ""
    //更新时间
    var eTime = ""
    //显示的时间
    var showTime = ""
    //排序顺序
    var sn = ""
    //标签
    var tag = ""
    //
    var location = ""
    
    //发帖方
    var poster = FORUM_SOURCE.platform
    
    //总的审核状态
    var auditStatus = FORUM_AUDIT_STATUS.pass
    //人工审核状态
    var manualAuditStatus = FORUM_AUDIT_STATUS.pass
    //机器审核状态
    var machineAuditStatus = FORUM_AUDIT_STATUS.pass
    //是否可评论
    var commentable = FORUM_AUDIT_STATUS.pass
    //是否为认证用户
    var keyUser = FORUM_AUDIT_STATUS.refuse
    //帖子状态
    var status = FORUM_AUDIT_STATUS.pass
    //可见范围
    var visibleScope = FORUM_VISIBLE_SCOPE.all
    //创建者
    var createBy = ""
    //作者
    var authorUid = ""
    //更新者
    var updateBy = ""
    
    //封面  图片/视频的高度
    var contentWidth = SCREEN_WIDHT-kFitWidth(32)//kFitWidth(343)
    var contentHeight = kFitWidth(0)
    //封面为视频时，视频第一帧
    var coverImg : UIImage?
    //视频url
    var videoUrl : URL?
    //视频时长
    var videoDuration = Int(0)
    //显示的视频时长  分：秒
    var videoDurationForShow = ""
    
    var imgIsLoaded:Bool = false
    
    //内容高度
//    var imgView = UIImageView()
    var cellHeight = kFitWidth(0)
    
    var pollModel = ForumDetailPollMsgModel()
    
    var imgsContent:[String] = [String]()
    var videoUrlContent = ""
    
    
    var forumPostPollModel = ForumPostPollModel()
    var pollResultModel = ForumPollResultModel()
    
    var videoImgComplete:(()->())?
}

extension ForumModel{
    func initWithDict(dict:NSDictionary) -> ForumModel{
        let model = ForumModel()
        model.id = dict.stringValueForKey(key: "id")
        model.title = dict.stringValueForKey(key: "title").trimmingCharacters(in: .whitespacesAndNewlines)
        
        model.titleHeight = WHUtils().getHeightOfString(string: dict.stringValueForKey(key: "title"), font: .systemFont(ofSize: 18, weight: .bold), width: SCREEN_WIDHT-kFitWidth(32))
        
        model.subTitle = dict.stringValueForKey(key: "subtitle")
        model.content = dict.stringValueForKey(key: "content").trimmingCharacters(in: .whitespacesAndNewlines)
        model.webLink = dict.stringValueForKey(key: "weblink")
        model.location = dict.stringValueForKey(key: "location")
        
        if dict.stringValueForKey(key: "contentType") == "1"{
            model.contentType = .IMAGE
        }else if dict.stringValueForKey(key: "contentType") == "2"{
            model.contentType = .VIDEO
//            return model
        }else{
            model.contentType = .TEXT
        }
//        model.contentType = dict.stringValueForKey(key: "contentType") == "2" ? .VIDEO : .IMAGE
        
        let materialObj = dict["material"]as? NSDictionary ?? [:]
        if model.contentType == .IMAGE{
            let images = materialObj["image"]as? NSArray ?? []
            for i in 0..<images.count{
                let imgDict = images[i]as? NSDictionary ?? [:]
                model.imgsContent.append(imgDict.stringValueForKey(key: "ossUrl"))
            }
        }else{
            let videos = materialObj["video"]as? NSArray ?? []
            if videos.count > 0 {
                let videoDict = videos[0]as? NSDictionary ?? [:]
                model.videoUrlContent = videoDict.stringValueForKey(key: "ossUrl")
                model.videoUrl = URL(string: model.videoUrlContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)//URL(string: model.covers[0]as? String ?? "")
//                let videoSize = self.dealCellHeight(dict: dict, videoUrl: model.videoUrl!)
//                model.contentHeight = videoSize.height
//                model.contentWidth = videoSize.width
            }
        }
        
        model.covers = dict["cover"]as? NSArray ?? []
        if model.covers.count > 0 {
            model.coverType = self.getCoverType(urlString: model.covers[0]as? String ?? "")
            model.coverImgHeight = kFitWidth(200)
            if model.coverType == .VIDEO{
                model.contentWidth = SCREEN_WIDHT-kFitWidth(32)//kFitWidth(343)
                model.contentHeight = kFitWidth(150)
//                model.coverImg = createImageWithColor(color: .WIDGET_COLOR_GRAY_BLACK_04)
                VideoUtils().generateThumbnailFromVideo(videoURL: model.videoUrl!, maxSize: CGSize.init(width: kFitWidth(343), height: kFitWidth(343))) { image, size in
//                    DLLog(message: "videoPlayerView height:\(model.title) \(size.width)---\(size.height)")
                    if let coverImage = image{
//                        model.coverImg = image
                        let videoW = SCREEN_WIDHT-kFitWidth(32)
                        var videoH = videoW*(size.height)/(size.width)
//                        DLLog(message: "videoPlayerView height:\(model.title) \(videoH)")
                        videoH = videoH > videoW ? videoW : videoH
//                        model.contentWidth = videoW
                        model.contentHeight = videoH
//                        DLLog(message: "videoPlayerView height:\(model.title) ------ \(videoH)")
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "forumListVideoGetFirstFrame"),
                                                        object: ["id":model.id,
                                                                 "contentHeight":videoH,
                                                                 "coverImg":coverImage])
                    }else{
                        DLLog(message: "videoPlayerView height:\(model.title)  视频封面获取失败")
                    }
                }
            }else{
                model.coverThumbImgUrl = "\(model.covers[0]as? String ?? "")?x-oss-process=image/resize,w_\(kFitWidth(343)),m_lfit".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            }
        }
        
        model.cellHeight = kFitWidth(128) + model.titleHeight + model.coverImgHeight// + model.contentHeight
        model.postViewCount = dict.stringValueForKey(key: "postViewCount")
        model.commentCount = dict.stringValueForKey(key: "commentCount")
        model.totalCommentCount = dict.stringValueForKey(key: "totalCommentCount")
        
        model.createBy = dict.stringValueForKey(key: "createdBy")
        model.authorUid = dict.stringValueForKey(key: "uid")
        model.headImgUrl = dict.stringValueForKey(key: "headimgurl")
        model.updateBy = dict.stringValueForKey(key: "updatedBy")
        
        if model.headImgUrl.count == 0 {
            model.headImgUrl = "https://teststatic.leungnutritionsciences.cn/avatar/default_avatar_2.png"
        }
        
        if dict.stringValueForKey(key: "type") == "1" {
            model.type = .common
        }else if dict.stringValueForKey(key: "type") == "2" {
            model.type = .poll
            model.pollModel = ForumDetailPollMsgModel().dealDataSource(dict: dict["pollJson"]as? NSDictionary ?? [:])
            model.forumPostPollModel = ForumPostPollModel().dealDictForModel(dict: dict["forumPostPollData"]as? NSDictionary ?? [:])
            model.pollResultModel = ForumPollResultModel().dealDictForModel(dict: dict["pollResult"]as? NSDictionary ?? [:])
        }
//        model.type = dict.stringValueForKey(key: "type") == "1" ? FORUM_TYPE.common : FORUM_TYPE.common
        model.isTop = dict.stringValueForKey(key: "top") == "0" ? FORUM_AUDIT_STATUS.refuse : FORUM_AUDIT_STATUS.pass
        
        model.status = dict.stringValueForKey(key: "status") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.commentable = dict.stringValueForKey(key: "commentable") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.upvote = dict.stringValueForKey(key: "like") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.likable = dict.stringValueForKey(key: "likable") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.upvoteCount = dict.stringValueForKey(key: "likeCount")
        
        model.auditStatus = dict.stringValueForKey(key: "audit") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.manualAuditStatus = dict.stringValueForKey(key: "manualAudit") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.machineAuditStatus = dict.stringValueForKey(key: "machineAudit") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.keyUser = dict.stringValueForKey(key: "keyUser") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.poster = dict.stringValueForKey(key: "poster") == "1" ? FORUM_SOURCE.platform : FORUM_SOURCE.customer
        
        if dict.stringValueForKey(key: "visibleScope") == "1"{
            model.visibleScope = FORUM_VISIBLE_SCOPE.owner
        }else if dict.stringValueForKey(key: "visibleScope") == "2"{
            model.visibleScope = FORUM_VISIBLE_SCOPE.fans
        }else{
            model.visibleScope = FORUM_VISIBLE_SCOPE.all
        }
        
        model.serverTime = dict.stringValueForKey(key: "now").replacingOccurrences(of: "T", with: " ")
        model.cTime = dict.stringValueForKey(key: "ctime").replacingOccurrences(of: "T", with: " ")
        model.eTime = dict.stringValueForKey(key: "etime").replacingOccurrences(of: "T", with: " ")
        if dict.stringValueForKey(key: "ctime").count > 0 && dict.stringValueForKey(key: "now").count > 0 {
            model.showTime = ForumTimeUtils().changeTimeForShowNN(timeStr: dict.stringValueForKey(key: "ctime").replacingOccurrences(of: "T", with: " "),
                                                                nowTime: dict.stringValueForKey(key: "now").replacingOccurrences(of: "T", with: " "))
        }
        
        model.sn = dict.stringValueForKey(key: "sn")
        model.tag = dict.stringValueForKey(key: "tag")
        
        return model
    }
    func initWithDictCoverInfo(dict:NSDictionary) -> ForumModel{
        let model = ForumModel()
        model.id = dict.stringValueForKey(key: "id")
        model.title = dict.stringValueForKey(key: "title").trimmingCharacters(in: .whitespacesAndNewlines)
        
        model.titleHeight = WHUtils().getHeightOfString(string: dict.stringValueForKey(key: "title"), font: .systemFont(ofSize: 18, weight: .bold), width: SCREEN_WIDHT-kFitWidth(32))
        
        model.subTitle = dict.stringValueForKey(key: "subtitle")
        model.content = dict.stringValueForKey(key: "content").trimmingCharacters(in: .whitespacesAndNewlines)
        model.webLink = dict.stringValueForKey(key: "weblink")
        model.location = dict.stringValueForKey(key: "location")
        
        if dict.stringValueForKey(key: "contentType") == "1"{
            model.contentType = .IMAGE
        }else if dict.stringValueForKey(key: "contentType") == "2"{
            model.contentType = .VIDEO
//            return model
        }else{
            model.contentType = .TEXT
        }
//        model.contentType = dict.stringValueForKey(key: "contentType") == "2" ? .VIDEO : .IMAGE
        
        let materialObj = dict["material"]as? NSDictionary ?? [:]
        if model.contentType == .IMAGE{
            let images = materialObj["image"]as? NSArray ?? []
            for i in 0..<images.count{
                let imgDict = images[i]as? NSDictionary ?? [:]
                model.imgsContent.append(imgDict.stringValueForKey(key: "ossUrl"))
            }
        }else{
            let videos = materialObj["video"]as? NSArray ?? []
            if videos.count > 0 {
                let videoDict = videos[0]as? NSDictionary ?? [:]
                model.videoUrlContent = videoDict.stringValueForKey(key: "ossUrl")
                model.videoUrl = URL(string: model.videoUrlContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            }
        }
        
        model.covers = dict["cover"]as? NSArray ?? []
        if model.covers.count > 0 {
            model.coverType = self.getCoverType(urlString: model.covers[0]as? String ?? "")
            let coverInfo = dict["coverInfo"]as? NSDictionary ?? [:]
            model.coverThumbImgUrl = coverInfo.stringValueForKey(key: "ossUrl")
            if coverInfo.stringValueForKey(key: "videoDuration").count > 0 {
                model.videoDuration = coverInfo.stringValueForKey(key: "videoDuration").intValue/1000
                let minute = model.videoDuration/60
                let second = model.videoDuration%60
                if minute < 10 {
                    model.videoDurationForShow = "0\(minute):"
                }else{
                    model.videoDurationForShow = "\(minute):"
                }
                if second < 10 {
                    model.videoDurationForShow = model.videoDurationForShow + "0\(second)"
                }else{
                    model.videoDurationForShow = model.videoDurationForShow + "\(second)"
                }
            }
            
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
            if model.coverType == .VIDEO{
                model.contentWidth = SCREEN_WIDHT-kFitWidth(32)
                if coverWidth > 0 && coverHeight > 0 {
                    model.contentHeight = model.coverImgHeight
                    if model.coverThumbImgUrl.count == 0 {
                        model.coverImg = createImageWithColor(color: .WIDGET_COLOR_GRAY_BLACK_04)
                    }
                }else{
                    model.coverImg = createImageWithColor(color: .WIDGET_COLOR_GRAY_BLACK_04)
                    model.contentHeight = kFitWidth(150)
//                    if model.videoUrl != nil{
//                        DSImageUploader().dealImgUrlSignForOss(urlStr: model.videoUrl!.absoluteString) { signUrl in
//                            VideoUtils().generateThumbnailFromVideo(videoURL: URL(string: signUrl)!, maxSize: CGSize.init(width: SCREEN_WIDHT-kFitWidth(32), height: SCREEN_WIDHT-kFitWidth(32))) { image, size in
//            //                    DLLog(message: "videoPlayerView height:\(model.title) \(size.width)---\(size.height)")
//                                if let coverImage = image{
//                                    model.coverImg = image
//                                    let videoW = SCREEN_WIDHT-kFitWidth(32)
//                                    var videoH = videoW*(size.height)/(size.width)
//        //                            DLLog(message: "videoPlayerView height:\(model.title) \(videoH)")
//                                    videoH = videoH > videoW ? videoW : videoH
//                                    
//                                    if videoH/videoW > 5/4{
//                                        videoH = videoW*5/4
//                                    }
//            //                        model.contentWidth = videoW
//                                    model.contentHeight = videoH
//            //                        DLLog(message: "videoPlayerView height:\(model.title) ------ \(videoH)")
//                                    
//                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "forumListVideoGetFirstFrame"),
//                                                                    object: ["id":model.id,
//                                                                             "contentHeight":videoH,
//                                                                             "coverImg":coverImage])
//                                }else{
//                                    DLLog(message: "videoPlayerView height:\(model.title)  视频封面获取失败")
//                                }
//                            }
//                        }
//                    }
                }
            }else{
                model.coverThumbImgUrl = "\(model.covers[0]as? String ?? "")?x-oss-process=image/resize,w_\(kFitWidth(343)),m_lfit".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            }
        }
        
        model.cellHeight = kFitWidth(128) + model.titleHeight + model.coverImgHeight// + model.contentHeight
        model.postViewCount = dict.stringValueForKey(key: "postViewCount")
        model.commentCount = dict.stringValueForKey(key: "commentCount")
        model.totalCommentCount = dict.stringValueForKey(key: "totalCommentCount")
        
        model.createBy = dict.stringValueForKey(key: "createdBy")
        model.authorUid = dict.stringValueForKey(key: "uid")
        model.headImgUrl = dict.stringValueForKey(key: "headimgurl")
        model.updateBy = dict.stringValueForKey(key: "updatedBy")
        
        if dict.stringValueForKey(key: "type") == "1" {
            model.type = .common
        }else if dict.stringValueForKey(key: "type") == "2" {
            model.type = .poll
            model.pollModel = ForumDetailPollMsgModel().dealDataSource(dict: dict["pollJson"]as? NSDictionary ?? [:])
            model.forumPostPollModel = ForumPostPollModel().dealDictForModel(dict: dict["forumPostPollData"]as? NSDictionary ?? [:])
            model.pollResultModel = ForumPollResultModel().dealDictForModel(dict: dict["pollResult"]as? NSDictionary ?? [:])
        }
//        model.type = dict.stringValueForKey(key: "type") == "1" ? FORUM_TYPE.common : FORUM_TYPE.common
        model.isTop = dict.stringValueForKey(key: "top") == "0" ? FORUM_AUDIT_STATUS.refuse : FORUM_AUDIT_STATUS.pass
        
        model.status = dict.stringValueForKey(key: "status") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.commentable = dict.stringValueForKey(key: "commentable") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.upvote = dict.stringValueForKey(key: "like") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.likable = dict.stringValueForKey(key: "likable") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.upvoteCount = dict.stringValueForKey(key: "likeCount")
        
        
        model.auditStatus = dict.stringValueForKey(key: "audit") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.manualAuditStatus = dict.stringValueForKey(key: "manualAudit") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.machineAuditStatus = dict.stringValueForKey(key: "machineAudit") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.keyUser = dict.stringValueForKey(key: "keyUser") == "1" ? FORUM_AUDIT_STATUS.pass : FORUM_AUDIT_STATUS.refuse
        model.poster = dict.stringValueForKey(key: "poster") == "1" ? FORUM_SOURCE.platform : FORUM_SOURCE.customer
        
        if dict.stringValueForKey(key: "visibleScope") == "1"{
            model.visibleScope = FORUM_VISIBLE_SCOPE.owner
        }else if dict.stringValueForKey(key: "visibleScope") == "2"{
            model.visibleScope = FORUM_VISIBLE_SCOPE.fans
        }else{
            model.visibleScope = FORUM_VISIBLE_SCOPE.all
        }
        
        model.serverTime = dict.stringValueForKey(key: "now").replacingOccurrences(of: "T", with: " ")
        model.cTime = dict.stringValueForKey(key: "ctime").replacingOccurrences(of: "T", with: " ")
        model.eTime = dict.stringValueForKey(key: "etime").replacingOccurrences(of: "T", with: " ")
        if dict.stringValueForKey(key: "ctime").count > 0 && dict.stringValueForKey(key: "now").count > 0 {
            model.showTime = ForumTimeUtils().changeTimeForShowNN(timeStr: dict.stringValueForKey(key: "ctime").replacingOccurrences(of: "T", with: " "),
                                                                nowTime: dict.stringValueForKey(key: "now").replacingOccurrences(of: "T", with: " "))
        }
        
        model.sn = dict.stringValueForKey(key: "sn")
        model.tag = dict.stringValueForKey(key: "tag")
        
        return model
    }
    func dealCellHeight(dict:NSDictionary,videoUrl:URL) -> CGSize {
        let imgWidth = SCREEN_WIDHT-kFitWidth(32)//kFitWidth(343)
        let videoSize = VideoUtils.getVideoSize(by: videoUrl)
        
        if videoSize.width < imgWidth{
            return videoSize
        }else{
            var videoHeight = imgWidth*(videoSize.height)/videoSize.width
            if videoHeight > imgWidth{
                videoHeight = imgWidth
                let width = videoSize.width/videoSize.height*videoHeight
                return CGSize.init(width: imgWidth, height: videoHeight)
            }else{
                return CGSize.init(width: imgWidth, height: videoHeight)
            }
        }
    }
    func getImageSize(_ url: String?) -> CGSize {
        guard let urlStr = url else {
            return CGSize.zero
        }

        let tempUrl = URL(string: urlStr)
        let imageSourceRef = CGImageSourceCreateWithURL(tempUrl! as CFURL, nil)
        var imgWidth: CGFloat = SCREEN_WIDHT-kFitWidth(32)//kFitWidth(343)
        var imgHeight: CGFloat = 0

        if let imageSRef = imageSourceRef {
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSRef, 0, nil)
            if let imageP = imageProperties {
                let imageDict = imageP as Dictionary
                let width = imageDict[kCGImagePropertyPixelWidth] as! CGFloat
                let height = imageDict[kCGImagePropertyPixelHeight] as! CGFloat
                
                imgHeight = imgWidth*height/width
                if imgHeight > imgWidth{
                    imgHeight = imgWidth
                    imgWidth = width/height*imgHeight
                }
            }
        }
        return CGSize(width: imgWidth, height: imgHeight)
    }
    
    func getCoverType(urlString:String) -> COVER_TYPE {
        let url = URL(string: urlString)
        let path = url?.path ?? ""
        let fileExtension = path.components(separatedBy: ".").last?.lowercased() ?? ""
        
        switch fileExtension {
        case "jpg", "jpeg", "png", "gif", "heic", "heif":
            return .IMAGE
        case "mp4", "mov", "m4v", "avi", "mpg", "mpeg":
            return .VIDEO
        default:
            return .IMAGE
        }
    }
    func getVideoDuration(from url: URL, completion: @escaping (Result<Double, Error>) -> Void) {
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            var error: NSError?
            let status = asset.statusOfValue(forKey: "duration", error: &error)
            
            switch status {
            case .loaded:
                let duration = asset.duration
                let seconds = CMTimeGetSeconds(duration)
                DispatchQueue.main.async(execute: {
                    completion(.success(seconds))
                })
            case .failed:
                DispatchQueue.main.async(execute: {
                    completion(.failure(error ?? NSError(domain: "AVAssetError", code: -1, userInfo: nil)))
                })
            default:
                DispatchQueue.main.async(execute: {
                    completion(.failure(NSError(domain: "AVAssetError", code: -2, userInfo: [NSLocalizedDescriptionKey: "未知错误"])))
                })
            }
        }
    }
}


extension ForumModel{
    func dictionaryRepresentation() -> [String:String] {
        return ["id":self.id,
                "commentCount":self.commentCount,
                "upvoteCount":self.upvoteCount,
                "content":self.content,
                "title":self.title,
                "webLink":self.webLink,
                "headImgUrl":self.headImgUrl,
                "authorUid":self.authorUid,
                "createBy":self.createBy,
                "postViewCount":self.postViewCount,
                "showTime":self.showTime,
                "subTitle":self.subTitle,
                "videoUrlContent":self.videoUrlContent,
                "cTime":self.cTime,
                "coverThumbImgUrl":self.coverThumbImgUrl,
                "eTime":self.eTime,
                "serverTime":self.serverTime,
                "sn":self.sn,
                "tag":self.tag,
                "updateBy":self.updateBy,
                "totalCommentCount":self.totalCommentCount]
    }
}
