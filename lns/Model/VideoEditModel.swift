//
//  VideoEditModel.swift
//  lns
//
//  Created by Elavatine on 2025/2/19.
//



class VideoEditModel {
    
    static let shared = VideoEditModel()
    
    private init(){
        
    }
    var videoUrl : URL?
    ///所有帧
    var allFrames:[UIImage] = [UIImage]()
    ///所有帧是否已全部获取
    var allFramesLoad = false
    
    var videoCoverImage : UIImage?
    
    var videoCoverImageSize : CGSize?
    
    ///关键帧
    var keyFrames:[UIImage] = [UIImage]()
    ///关键帧是否已全部获取
    var keyFramesLoad = false
    ///所有帧数量
    func totalFramesCount() -> Int {
        return self.allFrames.count
    }
    ///关键帧数量
    func keyFramesCount() -> Int {
        return self.keyFrames.count
    }
}
