//
//  ForumPublishModel.swift
//  lns
//
//  Created by Elavatine on 2025/2/24.
//


class ForumPublishModel: NSObject {
    
    var ctime = ""
    ///原始视频名称，帖子对应的本地视频名称
    var videoName = ""
    ///视频封面名称
    var videoCoverName = ""
    ///原始图片数组，存帖子对应的本地图片名称
    var imagesArray:[String] = [String]()
    ///投票数据，存帖子对应的投票数组
    var pollArray:[NSDictionary] = [NSDictionary]()
    
    var pollHasImg = false
    
    //上传到OSS后的数据
    var coverImageSize = CGSizeMake(1, 1)
    //视频路径
    var videoUrl = ""
    //视频封面路径
    var videoCoverUrl = ""
    //视频时长  单位：毫秒
    var videoDuration = 0
    //帖子内容图片
    var imageUrls:[NSDictionary] = [NSDictionary]()
    //投票内容图片
    var pollItems:[NSDictionary] = [NSDictionary]()
    
    //视频与图片   上传进度所占百分比  有图片的时候，每张图片为1%，剩余的则为视频
    //视频上传时，所占的百分比
    var videoPercent = CGFloat(0)
    //每张图片所占的百分比
    var imgPercent = CGFloat(0)
    
    var uploadProgress = Float(0)
    var videoUploadPercent = Float(0)
    var videoCoverUploadPercent = Float(0)
    var materialUploadPercent = Float(0)
    var pollUploadPercent = Float(0)
    
    func calculateVideoPercent() {
        if videoName.count > 0 {
            if self.pollHasImg{
                self.imgPercent = CGFloat(1)
                self.videoPercent = 100.0 - CGFloat(self.pollArray.count)
            }else{
                self.videoPercent = 100.0
            }
        }else{
            self.imgPercent = CGFloat(1)
            if self.pollHasImg{
                self.imgPercent = 100.0/CGFloat(self.imagesArray.count + self.pollArray.count)
            }else{
                self.imgPercent = 100.0/CGFloat(self.imagesArray.count)
            }
        }
    }
    
    func calculateUploadPercent(videoPercent:Float) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.videoUploadPercent = videoPercent * Float(self.videoPercent) * 0.01
            DLLog(message: "uploadProgress----(videoUploadPercent)\(self.videoUploadPercent)")
            self.calculateTotalPercent()
        }
    }
    func calculateUploadPercent(videoCoverPercent:Float) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.videoCoverUploadPercent = videoCoverPercent * Float(self.imgPercent) * 0.01
            DLLog(message: "uploadProgress----(videoCoverUploadPercent)\(self.videoCoverUploadPercent)")
            self.calculateTotalPercent()
        }
    }
    func calculateUploadPercent(materialPercent:Float,materialIndex:Int) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.materialUploadPercent = materialPercent * Float(self.imgPercent) * 0.01 + Float(materialIndex) * 0.01 * Float(self.imgPercent)
            DLLog(message: "uploadProgress----(materialUploadPercent)\(self.materialUploadPercent)")
            self.calculateTotalPercent()
        }
    }
    func calculateUploadPercent(pollPercent:Float,pollIndex:Int) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.pollUploadPercent = pollPercent * Float(self.imgPercent) * 0.01 + Float(pollIndex) * 0.01 * Float(self.imgPercent)
            DLLog(message: "uploadProgress----(pollUploadPercent)\(self.pollUploadPercent)")
            self.calculateTotalPercent()
        }
    }
    func calculateCompressPercent(percent:Float) {
        
    }
    func calculateTotalPercent() {
        self.uploadProgress = videoUploadPercent + materialUploadPercent + pollUploadPercent
        DLLog(message: "uploadProgress----(totalUploadProgress)\(uploadProgress)")
        let percentDict = ForumPublishSqlite.getInstance().queryProgress(ctime: self.ctime)
        if percentDict.stringValueForKey(key: "progress").floatValue < String(format: "%.2f", self.uploadProgress).floatValue{
            ForumPublishSqlite.getInstance().updateSingleData(columnName: "progress", data: String(format: "%.2f", self.uploadProgress),cTime: self.ctime)
        }
    }
    func printMaterialMsg() {
        DLLog(message: "------------------ 帖子OSS资源 -------------------------")
        DLLog(message: "videoUrl:\(self.videoUrl)")
        DLLog(message: "videoCoverUrl:\(self.videoCoverUrl)")
        DLLog(message: "imageUrls:\(self.imageUrls)")
        DLLog(message: "pollItems:\(self.pollItems)")
        DLLog(message: "videoPercent:\(videoPercent)  - imgPercent:\(imgPercent)")
        DLLog(message: "------------------------------------------------------")
    }
}
