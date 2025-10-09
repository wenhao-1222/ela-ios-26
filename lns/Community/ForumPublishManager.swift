//
//  ForumPublishManager.swift
//  lns
//  帖子发布Manager
//  Created by Elavatine on 2025/2/21.
//

import MCToast
import Photos

class ForumPublishManager {
    
    static let shared = ForumPublishManager()
    ///本地发帖的id    用timestamp做为id
    ///这个值会存到userdefault里
    ///根据userdefault里面是否有这个值，来判断是否有待发布的帖子
    var forumLocalId = ""
    
    var cTime = ""
    
    var forumVideoUrl = ""
    
    var forumImagesPath:[String] = [String]()
    
    var isUpload = false
    
    var coverImg : UIImage?
    
    var group = DispatchGroup()
    var publishModel = ForumPublishModel()
    var publshMsgDict = NSDictionary()
    
    let fileManager = FileManager.default
    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    
    private init(){
        
    }
    
    func saveData(title:String,content:String,type:String) {
        
    }
    
    func saveForumContentImages(imgs:[UIImage]) {
        let dict = ForumPublishSqlite.getInstance().queryContentImgsPath()
        let imagesPaths = dict.stringValueForKey(key: "images")
        if imagesPaths.count > 6 {
            let imagesFilePath = WHUtils.getArrayFromJSONString(jsonString: imagesPaths)
            for i in 0..<imagesFilePath.count{
                let filePath = imagesFilePath[i]as? String ?? ""
                let oldFilePath = documentsUrl.appendingPathComponent(filePath).path
                self.removeFile(filePath: oldFilePath) { t in
                    
                }
            }
        }
        self.saveImageToLocal(imgs: imgs, imgType: "content",index: 0)
    }
    
    func saveImageToLocal(imgs:[UIImage],imgType:String,index:Int?=0) {
        if index ?? 0 == 0 {
            forumImagesPath.removeAll()
        }
        DLLog(message: "saveImageToLocal: \(index ?? 0)")
        if imgs.count > index ?? 0{
            if let data = imgs[index ?? 0].pngData() {
                do{
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileName = "\(UserInfoModel.shared.phone)_\(self.cTime)_\(imgType)_\(index ?? 0).png"
                    let filePath = documentsPath.appendingPathComponent(fileName)
                    try data.write(to: filePath)
                    
                    forumImagesPath.append(fileName)
                }catch{
                    DLLog(message:"file write Error :\(error)")
                }
            }
            self.saveImageToLocal(imgs: imgs, imgType: imgType,index: (index ?? 0)+1)
        }else{
            DLLog(message: "saveImageToLocal:  success!")
            ForumPublishSqlite.getInstance().updateSingleData(columnName: "images", data: WHUtils.getJSONStringFromArray(array: forumImagesPath as NSArray))
        }
    }
    ///将视频保存到本地目录
    func saveVideo(asset: AVAsset, named: String) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsPath.appendingPathComponent("\(named).mp4")
        self.forumVideoUrl = destinationURL.absoluteString
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset1280x720)
        exportSession?.outputURL = destinationURL
        exportSession?.outputFileType = AVFileType.mp4
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.exportAsynchronously { [weak self] in
            switch exportSession?.status {
            case .completed:
                DLLog(message: "Video saved successfully")
                DLLog(message: "\(self?.forumVideoUrl ?? "")")
                ForumPublishSqlite.getInstance().updateSingleData(columnName: "video", data: "\(named).mp4", cTime: ForumPublishManager.shared.cTime)
//                ForumPublishSqlite.getInstance().updateSingleData(columnName: "video", data: "\(self?.forumVideoUrl ?? "")", cTime: ForumPublishManager.shared.cTime)
            case .failed, .cancelled, .waiting, .exporting, .unknown:
                DLLog(message: "Video saved failed with status \(String(describing: exportSession?.status))")
            case .none:
                DLLog(message: "Video saved none")
            @unknown default:
                DLLog(message: "Video saved nknown status")
            }
        }
    }
    func removeLocalVideo() {
        let dict = ForumPublishSqlite.getInstance().queryVideoCoverPath(ctime: nil)
        let oldFilePath = dict.stringValueForKey(key: "videoCoverFilePath")
        let filePath = documentsUrl.appendingPathComponent(oldFilePath).path
        self.removeFile(filePath: filePath) { t in
            
        }
    }
    ///将图片存到本地
    func saveImage(image: UIImage, named: String) {
        if let data = image.pngData() {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let filePath = documentsPath.appendingPathComponent("\(named).png")
            try? data.write(to: filePath)
        }
    }
    ///从本地读取图片
    func loadImage(named: String) -> UIImage? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsPath.appendingPathComponent("\(named).png")
        guard let data = try? Data(contentsOf: filePath) else { return nil }
        return UIImage(data: data)
    }
    func getImage(filePath:String) -> UIImage? {
        guard let data = try? Data(contentsOf: URL(string: filePath)!) else { return nil }
        return UIImage(data: data)
    }
    ///删除本地文件
    func removeFile(filePath:String,completion: @escaping (Bool?) -> Void) {
        if filePath.count < 3 || filePath == documentsUrl.path{
            completion(false)
            return
        }
        let fileRouteArray = filePath.components(separatedBy: "Documents/")
        if fileRouteArray.last == "" || fileRouteArray.count <= 1{
            completion(false)
            return
        }
        
        DLLog(message: "removeFile -- filePath:\(filePath)")
        if FileManager.default.fileExists(atPath: filePath){
            do{
                try FileManager.default.removeItem(atPath: filePath)
            }catch{
                DLLog(message: "MRVueUpdateLog: Remove [\(filePath)] fail:[\(error)]")
                completion(false)
                return
            }
            completion(true)
            return
        }else{
            completion(true)
        }
    }
    func saveVideoCoverImg(image:UIImage?) {
        let dict = ForumPublishSqlite.getInstance().queryVideoCoverPath(ctime: nil)
        let oldFilePath = dict.stringValueForKey(key: "videoCoverFilePath")
        if oldFilePath.count > 0 {
            let filePath = documentsUrl.appendingPathComponent(oldFilePath).path
            self.removeFile(filePath: filePath) { t in
                if let data = image?.pngData() {
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileName = "\(UserInfoModel.shared.phone)_\(ForumPublishManager.shared.cTime)_video_cover.png"
                    let filePath = documentsPath.appendingPathComponent(fileName)
                    try? data.write(to: filePath)
                    
                    ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_cover_img", data: fileName)
                    ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_cover_img_w", data: "\(image?.size.width ?? 1)")
                    ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_cover_img_h", data: "\(image?.size.height ?? 1)")
                }else{
                    ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_cover_img", data: "")
                    ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_cover_img_w", data: "")
                    ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_cover_img_h", data: "")
                }
            }
        }else{
            if let data = image?.pngData() {
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileName = "\(UserInfoModel.shared.phone)_\(ForumPublishManager.shared.cTime)_video_cover.png"
                let filePath = documentsPath.appendingPathComponent(fileName)
                try? data.write(to: filePath)
                
                ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_cover_img", data: fileName)
                ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_cover_img_w", data: "\(image?.size.width ?? 1)")
                ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_cover_img_h", data: "\(image?.size.height ?? 1)")
            }else{
                ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_cover_img", data: "")
                ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_cover_img_w", data: "")
                ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_cover_img_h", data: "")
            }
        }
    }
    func removeVideoCoverFile() {
        let dict = ForumPublishSqlite.getInstance().queryVideoCoverPath(ctime: nil)
        let oldFilePath = dict.stringValueForKey(key: "videoCoverFilePath")
        let filePath = documentsUrl.appendingPathComponent(oldFilePath).path
        self.removeFile(filePath: filePath) { t in
            
        }
    }
    func checkForumUploadStatus() {
        if isUpload == true{
            return
        }
        let dataArray = ForumPublishSqlite.getInstance().queryTableAll()
        DLLog(message: "checkForumUploadStatus:(dataArray) -- \(dataArray)")
        for i in 0..<dataArray.count{
            let dict = dataArray[i]as? NSDictionary ?? [:]
            DLLog(message: "checkForumUploadStatus:\(dict)")
            
            if dict.stringValueForKey(key: "isUpload") == "1" && isUpload == false{//待上传,且目前没有正在上传的帖子
                
//                if dict.stringValueForKey(key: "title") == "拿视频封面宽高信息" && isUpload == false{//待上传,且目前没有正在上传的帖子
                isUpload = true
                publishModel = ForumPublishModel()
                publishModel.ctime = dict.stringValueForKey(key: "ctime")
                self.publshMsgDict = dict
//                self.dealDataForUpload(dict: dict)
                self.judgeVideoResut(dict: dict)
            }else if dict.stringValueForKey(key: "isUpload") == "2" || dict.stringValueForKey(key: "isUpload") == "0"{//已发布的帖子，删除本地文件
                self.removeLocaleFileByForumMsg(dict: dict)
            }
        }
    }
}

extension ForumPublishManager{
    //MARK: 判断视频帖，是否压缩完成
    func judgeVideoResut(dict:NSDictionary) {
        //视频帖，视频未完成压缩
        if dict.stringValueForKey(key: "contentType") == "2" && dict.stringValueForKey(key: "video").count < 2{
            if dict.stringValueForKey(key: "contentType") == "2" && dict.stringValueForKey(key: "videoCoverUrl").count < 3{
                publishModel.videoCoverName = dict.stringValueForKey(key: "videoCoverImg")
                self.coverImg = self.loadImage(named: publishModel.videoCoverName.replacingOccurrences(of: ".png", with: ""))
            }
            DLLog(message: "VideoCompress: 视频帖，视频未完成压缩")
            let assetUrlString = dict.stringValueForKey(key:"videoOriginUrl")//本地视频路径
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadForumThreadStart"), object: nil)
            if assetUrlString.count > 0 {
                let result = PHAsset.fetchAssets(withLocalIdentifiers: [assetUrlString], options: nil).firstObject
                if result != nil{
                    self.getAVAssetFromPHAsset(result!) { avAsset in
//                        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let destinationURL = self.documentsUrl.appendingPathComponent("\(UserInfoModel.shared.phone)\(dict.stringValueForKey(key: "ctime")).mp4")
                        if let videoUrlAsset = avAsset as? AVURLAsset{
                            DLLog(message: "VideoCompress:  startTime --- \(Date().currentSeconds)")
                            VideoCompress().exportVideo(from: videoUrlAsset.url, to: destinationURL, ctime: dict.stringValueForKey(key: "ctime")) { percent in
                                DLLog(message: "VideoCompress: progress  \(percent)")
                            } completeHandler: { videoFinalPath in
                                ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_compress_progress", data: "1",cTime: dict.stringValueForKey(key: "ctime"))
                                
                                self.publishModel.videoDuration = ForumPublishSqlite.getInstance().queryVideoDuration(ctime: dict.stringValueForKey(key: "ctime")).intValue
                                DLLog(message: "VideoCompress:  endTime --- \(Date().currentSeconds)")
                                
                                let videoFinalPathArr = videoFinalPath.path.components(separatedBy: "/")
                                
                                let newDict = NSMutableDictionary(dictionary: dict)
                                newDict.setValue("\(videoFinalPathArr.last ?? "")", forKey: "video")
                                self.dealDataForUpload(dict: newDict)
                            }
                        }else{
                            ForumPublishSqlite.getInstance().updateSingleData(columnName: "isUpload", data: "4",cTime: self.publshMsgDict.stringValueForKey(key: "ctime"))
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "compressVideoError"), object: ["code":"400",
                                                                                                                                "message":"未找到视频资源"])
                            DLLog(message: "VideoCompress:  avAsset 转 AVURLAsset  错误")
                        }
                    }
                }else{
                    DLLog(message: "VideoCompress:  获取不到相册视频 --\(assetUrlString)")
                    ForumPublishSqlite.getInstance().updateSingleData(columnName: "isUpload", data: "4",cTime: self.publshMsgDict.stringValueForKey(key: "ctime"))
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "compressVideoError"), object: ["code":"400",
                                                                                                                        "message":"未找到视频资源"])
                }
            }else{
                DLLog(message: "VideoCompress:  没有保存 LocalIdentifiers")
                ForumPublishSqlite.getInstance().updateSingleData(columnName: "isUpload", data: "4",cTime: self.publshMsgDict.stringValueForKey(key: "ctime"))
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "compressVideoError"), object: ["code":"400",
                                                                                                                    "message":"未找到视频资源"])
            }
        }else{
            DLLog(message: "VideoCompress: 视频帖，视频已完成压缩  -----")
            if dict.stringValueForKey(key: "contentType") == "1"{//图文帖
                let images = dict.stringValueForKey(key: "images")
                let imagesArr = WHUtils.getArrayFromJSONString(jsonString: images)
                if imagesArr.count > 0 {
                    let coverString = imagesArr[0]as? String ?? ""
                    self.coverImg = self.loadImage(named: coverString.replacingOccurrences(of: ".png", with: ""))
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadForumThreadStart"), object: nil)
            self.dealDataForUpload(dict: dict)
        }
    }
    //MARK: 处理数据，上传帖子
    func dealDataForUpload(dict:NSDictionary) {
        //如果是视频帖，而且视频未上传
        if dict.stringValueForKey(key: "contentType") == "2" && dict.stringValueForKey(key: "videoUrl").count < 5{
            publishModel.videoName = dict.stringValueForKey(key: "video")
        }
        let imagesString = dict.stringValueForKey(key: "images")
        let imgsArray = WHUtils.getArrayFromJSONString(jsonString: imagesString)
        for i in 0..<imgsArray.count{
            publishModel.imagesArray.append(imgsArray[i]as? String ?? "")
        }
        if dict.stringValueForKey(key: "pollHasImg") == "1"{
            publishModel.pollHasImg = true
            let polls = dict.stringValueForKey(key: "polls")
            let pollsArr = WHUtils.getArrayFromJSONString(jsonString: polls)
            if pollsArr.count > 0 {
                for i in 0..<pollsArr.count{
                    publishModel.pollArray.append(pollsArr[i]as? NSDictionary ?? [:])
                }
            }
        }
        
        if dict.stringValueForKey(key: "contentType") == "2" && dict.stringValueForKey(key: "videoCoverUrl").count < 3{
            publishModel.videoCoverName = dict.stringValueForKey(key: "videoCoverImg")
            self.coverImg = self.loadImage(named: publishModel.videoCoverName.replacingOccurrences(of: ".png", with: ""))
        }
        
        publishModel.calculateVideoPercent()
        publishModel.videoUrl = dict.stringValueForKey(key: "videoUrl")
        publishModel.videoCoverUrl = dict.stringValueForKey(key: "videoCoverUrl")
        
        group = DispatchGroup()
        //投票帖，且
        if dict.stringValueForKey(key: "type") == "2"{
            let polls = dict.stringValueForKey(key: "polls")
            let pollsArray = WHUtils.getArrayFromJSONString(jsonString: polls)
//            投票选项有图片
            if dict.stringValueForKey(key: "pollHasImg") == "1"{
                for i in 0..<pollsArray.count{
                    let pollItem = pollsArray[i]as? NSDictionary ?? [:]
                    if pollItem.stringValueForKey(key: "imagePath").count > 0 {
                        group.enter()
                    }
                }
            }else{
                publishModel.pollItems = pollsArray as? [NSDictionary] ?? [NSDictionary]()
            }
        }
        //1 图片 + 文字  2 视频 + 文字 3 纯文字帖
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadForumThreadStart"), object: nil)
        if dict.stringValueForKey(key: "contentType") == "1"{//图文帖
            for i in 0..<publishModel.imagesArray.count{
                group.enter()
            }
            self.uploadMaterial(index: 0)
        }else if dict.stringValueForKey(key: "contentType") == "2"{//视频帖
            if publishModel.videoName.count > 0 {
                group.enter()//上传视频
            }
            if self.coverImg != nil{
                group.enter()//上传视频封面
            }
            if publishModel.videoCoverName.count > 0 && publishModel.videoName == ""{
                self.sendVideoCoverImg()
            }else{
                self.uploadVideo()
            }
        }else{
            if dict.stringValueForKey(key: "type") == "2" && dict.stringValueForKey(key: "pollHasImg") == "1"{
                self.uploaPollItemImage(index: 0)
            }
        }
        
        group.notify(queue: .main) {
            DLLog(message: "帖子图片、视频上传完成，接下来调用帖子发布接口")
            self.publishModel.printMaterialMsg()
            if self.publishModel.pollHasImg{
                ForumPublishSqlite.getInstance().updateSingleData(columnName: "poll_items", data: WHUtils.getJSONStringFromArray(array: self.publishModel.imageUrls as NSArray),cTime: self.publishModel.ctime)
            }
            self.sendForumAddRequest()
        }
    }
    //上传帖子视频
    func uploadVideo() {
        if publishModel.videoName.count > 0 {
            let filePath = documentsUrl.appendingPathComponent(publishModel.videoName).path
            if FileManager.default.fileExists(atPath: filePath){
                DLLog(message: "FileManager   找到了文件  \(filePath)")
                let videoUrl = URL(fileURLWithPath: filePath)
                
                DSImageUploader().uploadMovie(fileUrl: videoUrl) { percent in
                    DLLog(message: "DSImageUploader().uploadMovie progress:\(percent)")
                    self.publishModel.calculateUploadPercent(videoPercent: percent)
                } completion: { text, value in
                    DLLog(message: "DSImageUploader().uploadMovie(fileUrl:\(text)")
                    DLLog(message: "DSImageUploader().uploadMovie(fileUrl:\(value)")
                    if value == true{
                        self.publishModel.videoUrl = "\(text)"
                        ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_url", data: "\(text)",cTime: self.publishModel.ctime)
                    }
                    self.group.leave()
                    self.sendVideoCoverImg()
                }
            }else{
                DLLog(message: "FileManager   找不到文件   \(filePath)")
                uploadMaterial(index: 0)
            }
        }else{
//            self.group.leave()
            sendVideoCoverImg()
        }
    }
    //上传视频封面图片
    func sendVideoCoverImg() {
        let filePath = documentsUrl.appendingPathComponent(publishModel.videoCoverName).path
        if self.coverImg != nil{
            let imageData = WH_DESUtils.compressImage(toData: self.coverImg)
            DSImageUploader().uploadImage(imageData: imageData!, imgType: .forum_post) { bytesSent, totalByteSent, totalByteExpectedToSend in
                DLLog(message: "\(bytesSent)   ---   \(totalByteSent)  --- \(totalByteExpectedToSend)")
                self.publishModel.calculateUploadPercent(videoCoverPercent: (Float(totalByteSent)/Float(totalByteExpectedToSend)))
            } completion: { text, value in
                DLLog(message: "\(text)")
                DLLog(message: "\(value)")
                self.group.leave()
                if value == true{
                    DLLog(message: "sendVideoCoverImg:\(text)")
                    self.publishModel.videoCoverUrl = "\(text)"
                    ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_cover_url", data: "\(text)",cTime: self.publishModel.ctime)
                }
                self.uploaPollItemImage(index: 0)
            }
        }else{
//            self.group.leave()
            self.uploaPollItemImage(index: 0)
        }
    }
    //上传帖子图片
    func uploadMaterial(index:Int) {
        if publishModel.imagesArray.count > index {
            let imgPath = publishModel.imagesArray[index]
            let image = self.loadImage(named: imgPath.replacingOccurrences(of: ".png", with: ""))
            if image != nil{
                if index == 0{
                    publishModel.coverImageSize = image?.size ?? CGSizeMake(1, 1)
                }
                let imageData = WH_DESUtils.compressImage(toData: image)
                DSImageUploader().uploadImage(imageData: imageData!, imgType: .forum_post) { bytesSent, totalByteSent, totalByteExpectedToSend in
                    DLLog(message: "\(bytesSent)   ---   \(totalByteSent)  --- \(totalByteExpectedToSend)")
                    self.publishModel.calculateUploadPercent(materialPercent: (Float(totalByteSent)/Float(totalByteExpectedToSend)), materialIndex: index)
                } completion: { text, value in
                    DLLog(message: "\(text)")
                    DLLog(message: "\(value)")
                    self.group.leave()
                    if value == true{
                        DLLog(message: "\(text)")
                        self.publishModel.imageUrls.append(["sn":"\(index)",
                                                   "ossUrl":"\(text)"])
                    }
                    self.uploadMaterial(index: index+1)
                }
            }else{
                self.uploadMaterial(index: index+1)
            }
        }else{
            ForumPublishSqlite.getInstance().updateSingleData(columnName: "images_url", data: WHUtils.getJSONStringFromArray(array: publishModel.imageUrls as NSArray),cTime: self.publishModel.ctime)
            if publishModel.pollHasImg{
                self.uploaPollItemImage(index: 0)
            }else{
                
            }
        }
    }
    //上传帖子图片
    func uploaPollItemImage(index:Int) {
        if publishModel.pollArray.count > index {
            let pollDict = NSMutableDictionary(dictionary: publishModel.pollArray[index])
            let image = self.loadImage(named: pollDict.stringValueForKey(key: "imagePath").replacingOccurrences(of: ".png", with: ""))
            if image != nil{
                let imageData = WH_DESUtils.compressImage(toData: image)
                DSImageUploader().uploadImage(imageData: imageData!, imgType: .forum_post) { bytesSent, totalByteSent, totalByteExpectedToSend in
                    DLLog(message: "\(bytesSent)   ---   \(totalByteSent)  --- \(totalByteExpectedToSend)")
                    self.publishModel.calculateUploadPercent(pollPercent: (Float(totalByteSent)/Float(totalByteExpectedToSend)), pollIndex: index)
                } completion: { text, value in
                    DLLog(message: "\(text)")
                    DLLog(message: "\(value)")
                    self.group.leave()
                    if value == true{
                        DLLog(message: "\(text)")
                        pollDict.setValue("\(text)", forKey: "image")
                        self.publishModel.pollItems.append(pollDict)
                    }
                    self.uploaPollItemImage(index: index+1)
                }
            }else{
                self.uploaPollItemImage(index: index+1)
            }
        }
    }
}

extension ForumPublishManager{
    func sendForumAddRequest() {
        var param = NSMutableDictionary()
        //是否为投票贴
        let isPoll = publshMsgDict.stringValueForKey(key: "type") == "2" ? true : false
        param.setValue(isPoll ? "2" : "1", forKey: "type")
        param.setValue(publshMsgDict.stringValueForKey(key: "title"), forKey: "title")
        param.setValue(publshMsgDict.stringValueForKey(key: "content"), forKey: "content")
        param.setValue("1", forKey: "commentable")
        //1 图片 + 文字  2 视频 + 文字 3 纯文字帖
        if publshMsgDict.stringValueForKey(key: "contentType") == "1"{
            if self.publishModel.imageUrls.count > 0 {
                let coverDict = self.publishModel.imageUrls.first
                param.setValue("1", forKey: "contentType")
                param.setValue([coverDict?.stringValueForKey(key: "ossUrl")], forKey: "cover")
                param.setValue(["image":self.publishModel.imageUrls], forKey: "material")
                let coverInfo = ["ossUrl":coverDict?.stringValueForKey(key: "ossUrl"),
                                 "coverWidth":"\(Int(publishModel.coverImageSize.width))",
                                 "coverHeight":"\(Int(publishModel.coverImageSize.height))"]
                param.setValue(coverInfo, forKey: "coverInfo")
            }else{
                MCToast.mc_failure("未获取到封面图信息")
                return
            }
        }else if publshMsgDict.stringValueForKey(key: "contentType") == "2"{
            publishModel.videoDuration = ForumPublishSqlite.getInstance().queryVideoDuration(ctime: publishModel.ctime).intValue
            param.setValue("2", forKey: "contentType")
            param.setValue([publishModel.videoUrl], forKey: "cover")
            //"http://ela-test.oss-cn-shenzhen.aliyuncs.com/forum/post/material/forum_70422192326ec8ded4ab3074582fdcfd202503312775.png",
            let coverInfo = ["ossUrl":publishModel.videoCoverUrl,//1124  632
                             "videoDuration":publishModel.videoDuration,
                             "coverWidth":String(format: "%.0f", publshMsgDict.doubleValueForKey(key: "videoCoverImgW")),
                             "coverHeight":String(format: "%.0f", publshMsgDict.doubleValueForKey(key: "videoCoverImgH")),
                             "videoWidth":String(format: "%.0f", publshMsgDict.doubleValueForKey(key: "videoW")),
                             "videoHeight":String(format: "%.0f", publshMsgDict.doubleValueForKey(key: "videoH"))] as [String : Any]
            param.setValue(coverInfo, forKey: "coverInfo")
            let materialInfo = ["video":["sn":"1",
                                         "ossUrl":publishModel.videoUrl],
                                "image":[]] as [String : Any]
            param.setValue(materialInfo, forKey: "material")
        }else{//纯文字帖
            param.setValue("3", forKey: "contentType")
        }
        
        if isPoll{
            let pollType = publshMsgDict.doubleValueForKey(key: "pollType") > 1 ? "2" : "1" //投票类型  2 多选   1 单选
            let pollJson = ["pollType":pollType,
                           "pollTitle":publshMsgDict.stringValueForKey(key: "pollTitle"),
                           "haveImage":publshMsgDict.stringValueForKey(key: "pollHasImg"),
                           "showResult":"1",
                           "optionThreshold":publshMsgDict.stringValueForKey(key: "pollOptions"),
                            "pollOption":self.publishModel.pollItems] as [String : Any]
            param.setValue(pollJson, forKey: "pollJson")
        }
        
        DLLog(message: "\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_add, parameters: param as? [String:AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            let code = responseObject["code"]as? Int ?? -1
            self.isUpload = false
            if (code == 200) {
                ForumPublishSqlite.getInstance().updateSingleData(columnName: "isUpload", data: "2",cTime: self.publshMsgDict.stringValueForKey(key: "ctime"))
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadForumThreadFinished"), object: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
                    self.checkForumUploadStatus()
                })
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadForumThreadFailed"), object: responseObject)
            }
        }
    }
    func removeLocaleFileByForumMsg(dict:NSDictionary) {
        if dict.stringValueForKey(key: "video").count > 0 {
            let videoFilePath = documentsUrl.appendingPathComponent(dict.stringValueForKey(key: "video")).path
            removeFile(filePath: videoFilePath) { t in
                
            }
        }
        
        if dict.stringValueForKey(key: "video").count > 0 {
            let videoCoverFilePath = documentsUrl.appendingPathComponent(dict.stringValueForKey(key: "videoCoverImg")).path
            removeFile(filePath: videoCoverFilePath) { t in
                
            }
        }
        
        
        let imagesString = dict.stringValueForKey(key: "images")
        let imgsArray = WHUtils.getArrayFromJSONString(jsonString: imagesString)
        for i in 0..<imgsArray.count{
            if (imgsArray[i]as? String ?? "").count > 0 {
                let materialFilePath = documentsUrl.appendingPathComponent(imgsArray[i]as? String ?? "").path
                removeFile(filePath: materialFilePath) { t in
                    
                }
            }
        }
        if dict.stringValueForKey(key: "type") == "2" && dict.stringValueForKey(key: "pollHasImg") == "1"{
            let polls = dict.stringValueForKey(key: "polls")
            let pollsArray = WHUtils.getArrayFromJSONString(jsonString: polls)
//            投票选项有图片
            for i in 0..<pollsArray.count{
                let pollItem = pollsArray[i]as? NSDictionary ?? [:]
                if (pollItem.stringValueForKey(key: "imagePath")).count > 0 {
                    let pollFilePath = documentsUrl.appendingPathComponent(pollItem.stringValueForKey(key: "imagePath")).path
                    removeFile(filePath: pollFilePath) { t in
                        
                    }
                }
            }
        }
        
        ForumPublishSqlite.getInstance().deleteForum(ctime: dict.stringValueForKey(key: "ctime"))
    }
}
extension ForumPublishManager{
    func checkFunc() {
        // 获取Documents目录中的文件列表
        do {
            let fileUrls = try fileManager.contentsOfDirectory(atPath: documentsUrl.path)
            for file in fileUrls {
                print("checkFunc -- File in Documents: \(file)")
            }
        } catch {
            print("checkFunc -- Error accessing Documents directory: \(error.localizedDescription)")
        }

        // 检查特定文件是否存在
        let fileName = "1368734889720250225110703.mp4"
        let filePath = documentsUrl.appendingPathComponent(fileName).path
        if fileManager.fileExists(atPath: filePath) {
            print("checkFunc --  File '\(fileName)' exists in Documents directory.")
            let videoUrl = URL(fileURLWithPath: filePath)
            
            DSImageUploader().uploadMovie(fileUrl: videoUrl) { percent in
                DLLog(message: "checkFunc --  DSImageUploader().uploadMovie progress:\(percent)")
            } completion: { text, value in
                DLLog(message: "checkFunc --  DSImageUploader().uploadMovie(fileUrl:\(text)")
                DLLog(message: "checkFunc --  DSImageUploader().uploadMovie(fileUrl:\(value)")
                if value == true{
                    self.publishModel.videoUrl = "\(text)"
//                    self.group.leave()
                }else{
                    return
                }
            }
        } else {
            print("checkFunc -- File '\(fileName)' does not exist in Documents directory.")
        }
    }
}

extension ForumPublishManager{
    func getAVAssetFromPHAsset(_ asset: PHAsset, completion: @escaping (AVAsset?) -> Void) {
        let manager = PHImageManager.default()
        let options = PHVideoRequestOptions()
        options.version = .original // 获取原始视频
        
        manager.requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
            DispatchQueue.main.async {
                completion(avAsset)
            }
        }
    }
    func getPHAssetFromVideoURL(_ videoURL: URL, completion: @escaping (PHAsset?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        
        let result = PHAsset.fetchAssets(withALAssetURLs: [videoURL], options: fetchOptions)
        guard let asset = result.firstObject else {
            completion(nil)
            return
        }
        completion(asset)
    }
}
