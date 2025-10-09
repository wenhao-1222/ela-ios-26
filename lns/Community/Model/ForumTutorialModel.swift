//
//  ForumTutorialModel.swift
//  lns
//
//  Created by Elavatine on 2024/12/23.
//

@objc class ForumTutorialModel: NSObject {
    
    var cTime = ""
    
    var id = ""
    
    var parentId = ""
    
    var courseId = ""
    
    var material = NSDictionary()
    
    var sn = 0
    
    var subTitle = ""
    
    var title = ""
    
    var videoUrl = ""
    ///DRM播放的id
    var videoVID = ""
    
    var webLink = ""
    
    var coverImg:UIImage?
    
    var coverUrl = ""
    
    var videoDuration = 0
    
    var videoDurationShow = "00:00"
    
    var isLoadImg = false
    
    //视频的高度
    var contentWidth = SCREEN_WIDHT
    var contentHeight = SCREEN_WIDHT*2/3
    
    func dealDictForModel(dict:NSDictionary) ->  ForumTutorialModel{
        let model = ForumTutorialModel()
        model.cTime = dict.stringValueForKey(key: "ctime")
        model.id = dict.stringValueForKey(key: "id")
        model.parentId = dict.stringValueForKey(key: "parentId")
        model.sn = dict.stringValueForKey(key: "sn").intValue
        model.subTitle = dict.stringValueForKey(key: "subtitle")
        model.title = dict.stringValueForKey(key: "title")
        model.webLink = dict.stringValueForKey(key: "weblink")
        
        let cover = dict["cover"]as? NSArray ?? []
        if cover.count > 0 {
            model.coverUrl = cover[0]as? String ?? ""
        }

        model.material = dict["material"]as? NSDictionary ?? [:]
        
        let videos = model.material["video"]as? NSArray ?? []
        if videos.count > 0 {
            let videoDict = videos[0]as? NSDictionary ?? [:]
            let ossUrl = videoDict.stringValueForKey(key: "ossUrl")
//            if ossUrl.contains("ela-test-private") || ossUrl.contains("ela-prod-private"){
//                DSImageUploader().dealImgUrlSignForOss(urlStr: ossUrl) { str in
//                    DLLog(message: "视频加载地址 私有桶链接：\(str)")
//                    model.videoUrl = str
//                }
//            }else{
            model.videoVID = videoDict.stringValueForKey(key: "vid")
//            model.videoVID = "60993ea3817971f080065017e1e90102"
            model.videoUrl = ossUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if videoDict.stringValueForKey(key: "videoDuration").count > 0 {
                model.videoDuration = videoDict.stringValueForKey(key: "videoDuration").intValue/1000
                let minute = model.videoDuration/60
                let second = model.videoDuration%60
                if minute < 10 {
                    model.videoDurationShow = "0\(minute):"
                }else{
                    model.videoDurationShow = "\(minute):"
                }
                if second < 10 {
                    model.videoDurationShow = model.videoDurationShow + "0\(second)"
                }else{
                    model.videoDurationShow = model.videoDurationShow + "\(second)"
                }
            }
            
//            }
        }
        return model
    }
    func dealMaterialSize(model:ForumTutorialModel) -> CGSize{
        if let videoUrl = URL(string: (model.videoUrl)){
            let videoSize = self.dealCellHeight(videoUrl: videoUrl)
            return videoSize
        }
        return CGSize.init(width: 0, height: 0 )
    }
    
    func dealCellHeight(videoUrl:URL) -> CGSize {
        let imgWidth = SCREEN_WIDHT
        let videoSize = VideoUtils.getVideoSize(by: videoUrl)
        
        if videoSize.width < imgWidth{
            return videoSize
        }else{
            var videoHeight = imgWidth*(videoSize.height)/videoSize.width
            return CGSize.init(width: imgWidth, height: videoHeight)
//            if videoHeight > imgWidth{
//                videoHeight = imgWidth
//                let width = videoSize.width/videoSize.height*videoHeight
//                return CGSize.init(width: width, height: videoHeight)
//            }else{
//                return CGSize.init(width: imgWidth, height: videoHeight)
//            }
        }
    }
    
}
