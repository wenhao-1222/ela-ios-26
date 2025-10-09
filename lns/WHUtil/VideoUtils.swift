//
//  VideoUtils.swift
//  lns
//
//  Created by Elavatine on 2024/11/5.
//

import AVFoundation

class VideoUtils: NSObject {
    static func getVideoSizeAsync(url: URL?,
                      completion: @escaping (CGSize) -> Void) {
        // 后台队列，避免阻塞主线程
        DispatchQueue.global(qos: .userInitiated).async {
            var size: CGSize = .zero
            guard let url = url else {
                // 回到主线程回调
                DispatchQueue.main.async {
                    completion(size)
                }
                return
            }
            let asset = AVAsset(url: url)
            let tracks = asset.tracks(withMediaType: AVMediaType.video)
            guard let track = tracks.first else {
                // 回到主线程回调
                DispatchQueue.main.async {
                    completion(size)
                }
                return
            }

            let t = track.preferredTransform
            size = CGSize(width: track.naturalSize.height, height: track.naturalSize.width)

            if t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0 {
                size = CGSize(width: track.naturalSize.height, height: track.naturalSize.width)
            } else if t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0 {
                // PortraitUpsideDown
                size = CGSize(width: track.naturalSize.height, height: track.naturalSize.width)
            } else if t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0 {
                // LandscapeRight
                size = CGSize(width: track.naturalSize.width, height: track.naturalSize.height)
            }else if t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0 {
                // LandscapeLeft
                size = CGSize(width: track.naturalSize.width, height: track.naturalSize.height)
            }
            // 回到主线程回调
            DispatchQueue.main.async {
                completion(size)
            }
        }
    }
    
    func gp_getVideoPreViewImage(path: URL) -> UIImage {
        var videoImage:UIImage!
        let asset = AVURLAsset.init(url: path, options: nil)
        let assetGen = AVAssetImageGenerator.init(asset: asset)
        assetGen.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        let pointer = UnsafeMutablePointer<CMTime>.allocate(capacity: 1);
        do {
            let image = try assetGen.copyCGImage(at: time, actualTime: pointer)
            videoImage = UIImage.init(cgImage: image)
            return videoImage
        } catch {}
        return videoImage
    }
    ///获取视频size
    static func getVideoSize(by url: URL?) -> CGSize {
       var size: CGSize = .zero
       guard let url = url else {
           return size
       }
       let asset = AVAsset(url: url)
       let tracks = asset.tracks(withMediaType: AVMediaType.video)
       guard let track = tracks.first else {
           return size
       }

       let t = track.preferredTransform
       size = CGSize(width: track.naturalSize.height, height: track.naturalSize.width)

       if t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0 {
           size = CGSize(width: track.naturalSize.height, height: track.naturalSize.width)
       } else if t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0 {
           // PortraitUpsideDown
           size = CGSize(width: track.naturalSize.height, height: track.naturalSize.width)
       } else if t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0 {
           // LandscapeRight
           size = CGSize(width: track.naturalSize.width, height: track.naturalSize.height)
       }else if t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0 {
           // LandscapeLeft
           size = CGSize(width: track.naturalSize.width, height: track.naturalSize.height)
       }
       return size
   }
    ///获取视频文件大小
    func wm_getFileSize(_ url:URL) -> Double {
        if let fileData:Data = try? Data.init(contentsOf: url) {
            let size = Double(fileData.count) / (1024.00 * 1024.00)
            return size
        }
        return 0.00
    }
    
    ///获取视频文件时长
    func wm_getFileDuration(_ videoURL:URL) -> String {
        let asset11 = AVURLAsset(url: videoURL) as AVURLAsset
        let totalSeconds = Int(CMTimeGetSeconds(asset11.duration))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let mediaTime = String(format:"%02i:%02i",minutes, seconds)
        DLLog(message: "打印视频的时长：\(totalSeconds) 秒 == \(minutes):\(seconds)")
        return mediaTime
    }
    static func splitVideoFileUrlFps(splitFileUrl: URL, fps: Float, splitCompleteClosure: @escaping (Bool, [UIImage]) -> Void) {
        var splitImages = [UIImage]()
        let optDict = NSDictionary(object: NSNumber(value: false), forKey: AVURLAssetPreferPreciseDurationAndTimingKey as NSCopying)
        let urlAsset = AVURLAsset(url: splitFileUrl, options: optDict as? [String: Any])

        let cmTime = urlAsset.duration
        let durationSeconds: Float64 = CMTimeGetSeconds(cmTime) //视频总秒数

        var times = [NSValue]()
        let totalFrames: Float64 = durationSeconds * Float64(fps) //获取视频的总帧数
        var timeFrame: CMTime

        for i in 0...Int(totalFrames) {
            timeFrame = CMTimeMake(value: Int64(i), timescale: Int32(fps)) //第i帧， 帧率
            let timeValue = NSValue(time: timeFrame)

            times.append(timeValue)
        }

        let imgGenerator = AVAssetImageGenerator(asset: urlAsset)
        imgGenerator.requestedTimeToleranceBefore = CMTime.zero //防止时间出现偏差
        imgGenerator.requestedTimeToleranceAfter = CMTime.zero
        imgGenerator.appliesPreferredTrackTransform = true //不知道是什么属性，不写true视频帧图方向不对

        let timesCount = times.count

        //获取每一帧的图片
        imgGenerator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, image, actualTime, result, error) in

            //times有多少次body就循环多少次。。。

            var isSuccess = false
            switch (result) {
            case AVAssetImageGenerator.Result.cancelled:
                print("cancelled------")

            case AVAssetImageGenerator.Result.failed:
                print("failed++++++")

            case AVAssetImageGenerator.Result.succeeded:
                let framImg = UIImage(cgImage: image!)
                splitImages.append(framImg)

                if (Int(requestedTime.value) == (timesCount - 1)) { //最后一帧时 回调赋值
                    isSuccess = true
                    splitCompleteClosure(isSuccess, splitImages)
                    print("completed")
                }
            }
        }
    }
    ///获取视频第一帧
    static func getFirstFrameFromVideo(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let firstFrame = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 1), actualTime: nil)
            let image = UIImage(cgImage: firstFrame)
            return image
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    func generateThumbnailFromVideo(
        videoURL: URL,
        maxSize: CGSize? = nil,
        completion: @escaping (UIImage?, CGSize) -> Void
    ) {
        // 后台队列，避免阻塞主线程
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true

            // 可选：限制生成图像的最大尺寸，提升效率、降低内存
            if let max = maxSize {
                generator.maximumSize = max
            }

            // 取视频的第 0 秒帧
            let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
            var actualTime = CMTime.zero

            do {
                let cgImageRef = try generator.copyCGImage(at: time, actualTime: &actualTime)
                let image = UIImage(cgImage: cgImageRef)
                let width = image.size.width
                let height = image.size.height

                // 回到主线程回调
                DispatchQueue.main.async {
                    completion(image, CGSize(width: width, height: height))
                }
            } catch {
                // 失败时返回nil
                DispatchQueue.main.async {
                    completion(nil, .zero)
                }
            }
        }
    }
    ///获取视频所有的帧
    func fetchFramesFromVideo(url: URL, completion: @escaping ([UIImage]?) -> Void) {
        VideoEditModel.shared.allFramesLoad = false
        VideoEditModel.shared.allFrames.removeAll()
        
        let asset = AVAsset(url: url)
        let reader: AVAssetReader?
        do {
            reader = try AVAssetReader(asset: asset)
        } catch {
            print("Error in creating asset reader: \(error)")
            completion(nil)
            return
        }
        
        guard let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first else {
            print("No video track found")
            completion(nil)
            return
        }
        // 后台队列，避免阻塞主线程
        DispatchQueue.global(qos: .userInitiated).async {
            let videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32ARGB)]
            let output = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoSettings)
            reader?.add(output)
            reader?.startReading()
            
    //        var frames: [UIImage] = []
            var sampleBuffer: CMSampleBuffer? = nil
            while reader?.status == .reading && (output.copyNextSampleBuffer() != nil) {
                sampleBuffer = output.copyNextSampleBuffer()
                if let sampleBuffer = sampleBuffer {
                    if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
                        let context = CIContext()
                        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
                        if cgImage != nil{
                            let uiImage = UIImage(cgImage: cgImage!)
    //                        frames.append(uiImage)
                            VideoEditModel.shared.allFrames.append(uiImage)
                        }
                    }
                    CMSampleBufferInvalidate(sampleBuffer)
                }
            }
            reader?.cancelReading()
            DispatchQueue.main.async {
                VideoEditModel.shared.allFramesLoad = true
                completion(nil)
            }
        }
    }
    //MARK: 获取关键帧，总共10张，步长 = 总时长(秒) /10
    func getKeyFrameFromUrl(videoUrl:URL?, completion: @escaping ([UIImage]?) -> Void) {
        VideoEditModel.shared.keyFrames.removeAll()
        VideoEditModel.shared.keyFramesLoad = false
        VideoEditModel.shared.videoUrl = videoUrl
        if videoUrl == nil{
            VideoEditModel.shared.keyFramesLoad = true
            completion(nil)
            return
        }
        // 后台队列，避免阻塞主线程
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: videoUrl!)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.requestedTimeToleranceBefore = .positiveInfinity
            generator.requestedTimeToleranceAfter = .positiveInfinity
            
            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                print("视频轨道不存在")
                return
            }
            let naturalTimeScale = videoTrack.naturalTimeScale
            
            let step = Int(Float(asset.duration.value)) / (10 * Int(asset.duration.timescale))
            DLLog(message: "getKeyFrameFromUrl:\(asset.duration.value)")
            DLLog(message: "getKeyFrameFromUrl: (step)\(step)")
            for i in 0..<10 {//Int(times) {
                let time = CMTime(seconds: Double(i)*Double(step), preferredTimescale: naturalTimeScale)
                DLLog(message: "getKeyFrameFromUrl:\(time)   ---  \(Double(i)*Double(step))")
                do {
                    let imageRef = try generator.copyCGImage(at: time, actualTime: nil)
                    let uiImage = UIImage(cgImage: imageRef)
                    // 在这里处理每一帧，例如保存或显示图像
                    print("Frame \(i) processed")
//                    frames.append(uiImage)
                    VideoEditModel.shared.keyFrames.append(uiImage)
                    if i == 0 {
                        VideoEditModel.shared.videoCoverImage = uiImage
                        VideoEditModel.shared.videoCoverImageSize = CGSize(width: uiImage.size.width, height: uiImage.size.height)
                    }
                } catch {
                    print("Error generating image: \(error)")
                }
            }
            DispatchQueue.main.async {
                VideoEditModel.shared.keyFramesLoad = true
                completion(nil)
            }
        }
    }
    func generateVideoThumbnail(videoUrl: URL?, at seconds: Double,cmTime:CMTime, completion: @escaping (UIImage?) -> Void) {
        // 1. 安全检查
        guard let videoUrl = videoUrl else {
            print("无效的视频 URL")
            return
        }
        
        // 2. 初始化 Asset 和 Generator
        let asset = AVAsset(url: videoUrl)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        // 3. 配置时间容差（根据场景选择）
        generator.requestedTimeToleranceBefore = cmTime    // 精确模式
        generator.requestedTimeToleranceAfter = cmTime
        
        // 4. 计算时间戳
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            print("视频轨道不存在")
            return
        }
        let naturalTimeScale = videoTrack.naturalTimeScale
        let time = CMTime(seconds: seconds, preferredTimescale: naturalTimeScale)
        
        // 5. 异步生成
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            } catch let error as NSError {
                print("缩略图生成失败: \(error.localizedDescription)")
                if error.domain == AVFoundationErrorDomain && error.code == -11832 {
                    print("时间超出视频范围")
                }
                completion(nil)
            }
        }
    }
    func getFrameForSeconds(seconds:Double,videoUrl:URL?, completion: @escaping (UIImage?) -> Void){
        if videoUrl == nil{
            completion(nil)
            return
        }
        // 后台队列，避免阻塞主线程
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: videoUrl!)
            
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.requestedTimeToleranceBefore = .zero
            generator.requestedTimeToleranceAfter = .zero
            
            let time = CMTime(seconds: seconds, preferredTimescale: asset.duration.timescale)
            do {
                let imageRef = try generator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: imageRef)
                // 在这里处理每一帧，例如保存或显示图像
                DispatchQueue.main.async {
                    completion(uiImage)
                }
            } catch {
                DLLog(message: "Error generating image: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    func getVideoFrameRate(forURL url: URL) -> Float? {
        // 创建 AVAsset 对象
        let asset = AVAsset(url: url)
        
        // 获取视频轨道
        let videoTracks = asset.tracks(withMediaType: .video)
        guard let videoTrack = videoTracks.first else {
            print("No video track found")
            return nil
        }
        
        // 获取帧率属性
        let frameRate = videoTrack.nominalFrameRate
        return frameRate
    }

}
