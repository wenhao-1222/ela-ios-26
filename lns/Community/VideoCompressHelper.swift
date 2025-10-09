//
//  VideoCompressHelper.swift
//  lns
//
//  Created by Elavatine on 2025/2/27.
//

import UIKit
import AVFoundation

public class VideoCompressHelper {
    
    private let expectedWidth: CGFloat = 960
    private let expectedHeight: CGFloat = 540
    private let expectedBitRate: Int = 1500 * 1024
    private let expectedFrameRate: Int = 30
    
    private var asset: AVAsset!
    private var degrees: Int = 0
    private var outputURL: URL!
    private var reader: AVAssetReader?
    private var writer: AVAssetWriter?
    private var videoOutput: AVAssetReaderVideoCompositionOutput!
    private var audioOutput: AVAssetReaderAudioMixOutput!
    private var videoInput: AVAssetWriterInput!
    private var audioInput: AVAssetWriterInput!
    private var completionHandler: ((_ isSuccess: Bool) -> Void)?
    
    private lazy var videoCompressProperties: [String: Any] = [
        AVVideoAverageBitRateKey: expectedBitRate,
        AVVideoExpectedSourceFrameRateKey: expectedFrameRate,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
    ]
    
    private lazy var videoCompressSettings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: (degrees == 0 || degrees == 180) ? expectedWidth : expectedHeight,
        AVVideoHeightKey: (degrees == 0 || degrees == 180) ? expectedHeight : expectedWidth,
        AVVideoCompressionPropertiesKey: videoCompressProperties,
        AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
    ]
    
    private lazy var audioCompressSettings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 44100,
        AVEncoderBitRateKey: 96000
    ]
    
    public func compressVideo(sourceURL: URL, outputURL: URL, completionHandler: @escaping (_ isSuccess: Bool) -> Void) {
        
        self.asset = AVAsset(url: sourceURL)
        self.outputURL = outputURL
        self.completionHandler = completionHandler
        self.degrees = degressFromVideoFile(with: asset)
        DLLog(message: "Video compression degrees : \(degrees)")
        
        do {
            self.reader = try AVAssetReader(asset: self.asset)
        } catch {
            completionHandler(false)
            return
        }
        
        do {
            self.writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        } catch {
            completionHandler(false)
            return
        }
        
        let videoTracks = asset.tracks(withMediaType: .video)
        
        if !videoTracks.isEmpty {
            let videoOutputSettings: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_422YpCbCr8),
                kCVPixelBufferIOSurfacePropertiesKey as String: NSDictionary()
            ]
            videoOutput = AVAssetReaderVideoCompositionOutput(videoTracks: videoTracks, videoSettings: videoOutputSettings)
            videoOutput.alwaysCopiesSampleData = false
            
            videoOutput.videoComposition = getVideoComposition(videoAsset: asset)
            
            if let reader = self.reader, reader.canAdd(self.videoOutput) {
                reader.add(self.videoOutput)
            }
            
            self.videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoCompressSettings)

            if let videoInput = self.videoInput, self.writer?.canAdd(videoInput) ?? false {
                self.writer?.add(videoInput)
            }
        }
        
        let audioTracks = asset.tracks(withMediaType: .audio)
        
        if !audioTracks.isEmpty {
            self.audioOutput = AVAssetReaderAudioMixOutput(audioTracks: audioTracks, audioSettings: nil)
            self.audioOutput.alwaysCopiesSampleData = false
            
            if let reader = self.reader, reader.canAdd(self.audioOutput) {
                reader.add(self.audioOutput)
            }
            
            self.audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioCompressSettings)
            
            if let audioInput = self.audioInput, self.writer?.canAdd(audioInput) ?? false {
                self.writer?.add(audioInput)
            }
        }
        
        writer?.startWriting()
        reader?.startReading()
        writer?.startSession(atSourceTime: CMTime.zero)
        
        let group = DispatchGroup()
        let videoQueue = DispatchQueue(label: "videoQueue")
        let audioQueue = DispatchQueue(label: "audioQueue")
        
        group.enter()
        videoInput.requestMediaDataWhenReady(on: videoQueue) {
            var isCompleted = false
            while self.videoInput.isReadyForMoreMediaData && !isCompleted {
                if let sampleBuffer = self.videoOutput.copyNextSampleBuffer() {
                    self.videoInput.append(sampleBuffer)
                } else {
                    isCompleted = true
                    self.videoInput.markAsFinished()
                    group.leave()
                }
            }
        }
        
        group.enter()
        audioInput.requestMediaDataWhenReady(on: audioQueue) {
            var isCompleted = false
            while (self.audioInput.isReadyForMoreMediaData && !isCompleted) {
                if let sampleBuffer = self.audioOutput.copyNextSampleBuffer() {
                    let success = self.audioInput.append(sampleBuffer)
                    isCompleted = !success
                } else {
                    isCompleted = true
                }
            }
            if isCompleted {
                self.audioInput.markAsFinished()
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            
            if self.reader?.status == .reading {
                self.reader?.cancelReading()
            }
            switch self.writer?.status {
            case .writing, .completed:
                self.writer?.finishWriting(completionHandler: {
                    completionHandler(true)
                })
                
            default:
                completionHandler(false)
            }
        }
    }
    
    private func getVideoComposition(videoAsset: AVAsset) -> AVMutableVideoComposition {
        
        let videoComposition = AVMutableVideoComposition()
        
        var translateToCenter = CGAffineTransform()
        var mixedTransform = CGAffineTransform()
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: videoAsset.duration.timescale)
        
        let videoTrack = videoAsset.tracks(withMediaType: .video).first!
        
        let roateInstruction = AVMutableVideoCompositionInstruction()
        roateInstruction.timeRange = CMTimeRangeMake(start: .zero, duration: videoAsset.duration)
        let roateLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        if degrees == 90 {
            // 顺时针旋转90°
            translateToCenter = CGAffineTransform(translationX: videoTrack.naturalSize.height, y: 0.0)
            mixedTransform = translateToCenter.rotated(by: .pi / 2)
            videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
            roateLayerInstruction.setTransform(mixedTransform, at: .zero)
        } else if degrees == 180 {
            // 顺时针旋转180°
            translateToCenter = CGAffineTransform(translationX: videoTrack.naturalSize.width, y: videoTrack.naturalSize.height)
            mixedTransform = translateToCenter.rotated(by: .pi)
            videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.height)
            roateLayerInstruction.setTransform(mixedTransform, at: .zero)
        } else if degrees == 270 {
            // 顺时针旋转270°
            translateToCenter = CGAffineTransform(translationX: 0.0, y: videoTrack.naturalSize.width)
            mixedTransform = translateToCenter.rotated(by: .pi / 2 * 3.0)
            videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
            roateLayerInstruction.setTransform(mixedTransform, at: .zero)
        } else {
            videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.height)
        }
        
        roateInstruction.layerInstructions = [roateLayerInstruction]
        videoComposition.instructions = [roateInstruction]
        
        return videoComposition
    }
    
    private func degressFromVideoFile(with asset: AVAsset) -> Int {
        var degrees = 0
        let tracks = asset.tracks(withMediaType: .video)
        if let videoTrack = tracks.first {
            let t = videoTrack.preferredTransform
            
            if t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0 {
                // Portrait
                degrees = 90
            } else if t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0 {
                // PortraitUpsideDown
                degrees = 270
            } else if t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0 {
                // LandscapeRight
                degrees = 0
            } else if t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0 {
                // LandscapeLeft
                degrees = 180
            }
        }
        return degrees
    }
    
    deinit {
        DLLog(message: "VideoCompressHelper deinit")
    }
}
