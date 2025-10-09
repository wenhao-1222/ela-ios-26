//
//  VideoCompress.swift
//  lns
//
//  Created by Elavatine on 2025/2/27.
//

import AVFoundation
import CoreGraphics

class VideoCompress{
    // 进度回调闭包定义 (0.0~1.0)
    typealias CompressionProgressHandler = (Float) -> Void

    func exportVideo(from videoURL: URL,
                     to videoFinalPath: URL,
                     ctime: String,
                     progressHandler: @escaping CompressionProgressHandler,
                     completeHandler: @escaping (URL) -> ()) {
        
        ForumPublishManager.shared.removeFile(filePath: videoFinalPath.path) { t in
            
        }
        // 后台队列，避免阻塞主线程
        DispatchQueue.global(qos: .userInitiated).async {
            // 创建音视频输入asset
            let asset = AVAsset(url: videoURL)
            // 原视频大小，用于测试压缩效果
            let oldfileItem = try? FileManager.default.attributesOfItem(atPath: videoURL.path)
            print("VideoCompress compress oldSize:\([oldfileItem?[FileAttributeKey.size]])") //打印之前视频体积
            // 创建音视频Reader和Writer
            guard let reader = try? AVAssetReader(asset: asset),
                  let writer = try? AVAssetWriter.init(outputURL: videoFinalPath, fileType: AVFileType.mp4) else { return}
            
            //视频输出配置
            let configVideoOutput: [String : Any] = [kCVPixelBufferPixelFormatTypeKey: NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)] as! [String: Any]
    //        let configVideoOutput: [String : Any] = [kCVPixelBufferPixelFormatTypeKey: NSNumber(value: kCVPixelFormatType_422YpCbCr8)] as! [String: Any]
            //音频输出配置
            let configAudioOutput: [String : Any] = [AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM)] as! [String: Any]
            
            let compressionProperties: [String: Any] = [AVVideoAverageBitRateKey: 1600 * 1024,  //码率
                                               AVVideoExpectedSourceFrameRateKey: 30,           //帧率
                                                   AVVideoMaxKeyFrameIntervalKey:30,
                                                          AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel]
    //                                                      AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel]
            
            
            let videoCodeec: String = AVVideoCodecType.h264.rawValue //视频编码
            var videoSettings: [String: Any] = [AVVideoCodecKey: videoCodeec, //视频编码
//                                                AVVideoWidthKey: 1280,           //视频宽（必须填写正确，否则压缩后有问题）
//                                               AVVideoHeightKey: 720,           //视频高（必须填写正确，否则压缩后有问题）
                                      AVVideoColorPropertiesKey:[AVVideoColorPrimariesKey:AVVideoColorPrimaries_ITU_R_709_2,
                                                               AVVideoTransferFunctionKey:AVVideoTransferFunction_ITU_R_709_2,
                                                                    AVVideoYCbCrMatrixKey:AVVideoYCbCrMatrix_ITU_R_709_2],
                                AVVideoCompressionPropertiesKey: compressionProperties,
                                          AVVideoScalingModeKey: AVVideoScalingModeResizeAspect] //设置视频缩放方式
            var stereoChannelLayout = AudioChannelLayout()
            memset(&stereoChannelLayout, 0, MemoryLayout<AudioChannelLayout>.size)
            stereoChannelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo
            let layoutData = Data(bytes: &stereoChannelLayout, count: MemoryLayout<AudioChannelLayout>.size)

            let audioSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVEncoderBitRateKey: 96000,
                AVSampleRateKey: 44100,
                AVChannelLayoutKey: layoutData,
                AVNumberOfChannelsKey: 2
            ]
            
            // video part
            guard let videoTrack: AVAssetTrack = (asset.tracks(withMediaType: .video)).first else {return}
            
            //获取原视频的角度
            let degree = self.degressFromVideoFileWithURL(videoTrack: videoTrack)
            //获取原视频的宽高，如果是手机拍摄，一般是宽大，高小，如果是手机自带录屏，那么是高大，宽小
            //            let naturalSize = videoTrack.naturalSize
            //            let transform = videoTrack.preferredTransform
            //
            //            // 应用变换计算实际尺寸
            //            let rect = CGRect(origin: .zero, size: naturalSize).applying(transform)
            //            if abs(rect.height) <= 720{
            //                videoSettings[AVVideoWidthKey] = abs(rect.width)
            //                videoSettings[AVVideoHeightKey] = abs(rect.height)
            //            }else if naturalSize.height < naturalSize.width {
            //                videoSettings[AVVideoWidthKey] = 1280
            //                videoSettings[AVVideoHeightKey] = 720
            //            }
            
//            let naturalSize = videoTrack.naturalSize
//            if naturalSize.width < naturalSize.height {
//                videoSettings[AVVideoWidthKey] = 720
//                videoSettings[AVVideoHeightKey] = 1280
//            }
            let originalVideoSize = self.originalVideoSize(for: videoTrack)
                        videoSettings[AVVideoWidthKey] = max(1, Int(originalVideoSize.width.rounded()))
                        videoSettings[AVVideoHeightKey] = max(1, Int(originalVideoSize.height.rounded()))
            
            
            let videoOutput: AVAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: configVideoOutput)
            let videoInput: AVAssetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            //视频写入的旋转（这句很重要）
            if let transform = self.getAffineTransform(degree: degree, videoTrack: videoTrack) {
                videoInput.transform = transform
            }
            
            if reader.canAdd(videoOutput) {
                reader.add(videoOutput)
            }
            if writer.canAdd(videoInput) {
                writer.add(videoInput)
            }
            // audio part
            guard let audioTrack: AVAssetTrack = (asset.tracks(withMediaType: .audio)).first else {return}
            let audioOutput: AVAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: configAudioOutput)
            let audioInput: AVAssetWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            if reader.canAdd(audioOutput) {
                reader.add(audioOutput)
            }
            if writer.canAdd(audioInput) {
                writer.add(audioInput)
            }
            // 开始读写
            reader.startReading()
            writer.startWriting()
            writer.startSession(atSourceTime: .zero)
            
            // 5. 进度跟踪变量
           var lastPresentationTime = CMTime.zero
           let totalDuration = CMTimeGetSeconds(asset.duration)

           let group = DispatchGroup()
            
            group.enter()
            // 6. 处理视频帧
            var progress = Float(0)
            var startTimeStamp = Date().timeStampMill.intValue
            videoInput.requestMediaDataWhenReady(on: DispatchQueue(label: "videoOutQueue"), using: {
                var completedOrFailed = false
                while (videoInput.isReadyForMoreMediaData) && !completedOrFailed {
                    let sampleBuffer: CMSampleBuffer? = videoOutput.copyNextSampleBuffer()
                    if sampleBuffer != nil {//}&& reader.status == .reading {
                        let result = videoInput.append(sampleBuffer!)
                        // 记录当前帧时间戳
                        let currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer!)
                        lastPresentationTime = currentTime
                        
                        // 计算进度
                        let processedSeconds = CMTimeGetSeconds(currentTime)
                        DLLog(message: "VideoCompress: processedSeconds --  \(processedSeconds)")
                        DLLog(message: "VideoCompress: totalDuration --  \(totalDuration)")
                        DLLog(message: "VideoCompress: current --  \(Float(processedSeconds / totalDuration))")
//                        DLLog(message: "VideoCompress: time: \(startTimeStamp) ---- \(Date().timeStampMill.intValue)")
                        if Date().timeStampMill.intValue - startTimeStamp > 300 || progress == 0{
                            progress = Float(processedSeconds / totalDuration)
                            startTimeStamp =  Date().timeStampMill.intValue
                            
                            let percentDict = ForumPublishSqlite.getInstance().queryCompressProgress(ctime: ctime)
                            if percentDict.stringValueForKey(key: "progress").floatValue < String(format: "%.4f", progress).floatValue{
                                ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_compress_progress", data: String(format: "%.4f", progress),cTime: ctime)
                            }
    //                        ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_compress_progress", data: "\(min(progress,1.0))",cTime: ctime)
                            // 主线程回调更新UI（控制频率）
                            DispatchQueue.main.async {
                                progressHandler(min(progress, 1.0)) // 确保不超过100%
                            }
                        }
        //                    if (!result) {
        //                        reader.cancelReading()
        //                        break
        //                    }
                    } else {
                        completedOrFailed = true
                        videoInput.markAsFinished()
                        group.leave()
                        break
                    }
                }
            })
            
            group.enter()
            audioInput.requestMediaDataWhenReady(on: DispatchQueue(label: "audioOutQueue"), using: {
                var completedOrFailed = false
                 while (audioInput.isReadyForMoreMediaData) && !completedOrFailed {
                     let sampleBuffer: CMSampleBuffer? = audioOutput.copyNextSampleBuffer()
                     if sampleBuffer != nil {//}&& reader.status == .reading {
                         let result = audioInput.append(sampleBuffer!)
        //                    if (!result) {
        //                        reader.cancelReading()
        //                        break
        //                    }
                     } else {
                         completedOrFailed = true
                         audioInput.markAsFinished()
                         group.leave()
                         break
                     }
                 }
             })
         
            group.notify(queue: DispatchQueue.main) {
                if reader.status == .reading {
                    reader.cancelReading()
                }
                switch writer.status {
                case .writing:
                    writer.finishWriting(completionHandler: {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
                            let videoFinalPathArr = videoFinalPath.path.components(separatedBy: "/")
                            ForumPublishSqlite.getInstance().updateSingleData(columnName: "video", data: "\(videoFinalPathArr.last ?? "")", cTime: ctime)
                            ForumPublishSqlite.getInstance().updateSingleData(columnName: "video_duration", data: "\(totalDuration*1000)")
                            DLLog(message: "VideoCompress compress totalDuration:\(totalDuration)")
                            let newfileSize = try? FileManager.default.attributesOfItem(atPath: videoFinalPath.path)
                            DLLog(message: "VideoCompress compress newSize \(newfileSize?[FileAttributeKey.size])") //打印压缩后视频的体积
                            completeHandler(videoFinalPath)
                        })
                    })
                case .cancelled:
                    DLLog(message: "VideoCompress compress cancelled")
                case .failed:
                    DLLog(message: "VideoCompress compress failed  \(writer.error)")
                case .completed:
                    DLLog(message: "VideoCompress compress completed")
                case .unknown:
                    DLLog(message: "VideoCompress compress unknown")
                }
            }
        }
    }
    private func originalVideoSize(for videoTrack: AVAssetTrack) -> CGSize {
        let naturalSize = videoTrack.naturalSize
        let transform = videoTrack.preferredTransform
        let transformedRect = CGRect(origin: .zero, size: naturalSize).applying(transform)
        let resolvedWidth = abs(transformedRect.width)
        let resolvedHeight = abs(transformedRect.height)
        if resolvedWidth > 0 && resolvedHeight > 0 {
            return CGSize(width: resolvedWidth, height: resolvedHeight)
        } else {
            return CGSize(width: naturalSize.width, height: naturalSize.height)
        }
    }
    private func getAffineTransform(degree: Int, videoTrack: AVAssetTrack)-> CGAffineTransform? {
        var translateToCenter: CGAffineTransform?
        var mixedTransform: CGAffineTransform?
        if degree == 90 { //视频旋转90度,home按键在左"
            translateToCenter = CGAffineTransform(translationX: videoTrack.naturalSize.height, y: 0.0)
            mixedTransform = translateToCenter!.rotated(by: Double.pi / 2)
        } else if degree == 180 { //视频旋转180度,home按键在上"
            translateToCenter = CGAffineTransform(translationX: videoTrack.naturalSize.width, y: videoTrack.naturalSize.height)
            mixedTransform = translateToCenter!.rotated(by: Double.pi)
        } else if degree == 270 { //视频旋转270度,home按键在右"
            translateToCenter = CGAffineTransform(translationX: 0.0, y: videoTrack.naturalSize.width)
            mixedTransform = translateToCenter!.rotated(by: Double.pi / 2 * 3)
        }
        return mixedTransform
    }
    //获取视频的角度
    private func degressFromVideoFileWithURL(videoTrack: AVAssetTrack)->Int {
        var degress = 0
     
        let t: CGAffineTransform = videoTrack.preferredTransform
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180
        }
        return degress
    }

}
