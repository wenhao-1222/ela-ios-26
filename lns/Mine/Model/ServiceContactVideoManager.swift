//
//  ServiceContactVideoUtil.swift
//  lns
//
//  Created by Elavatine on 2025/9/25.
//

import AVFoundation
import MCToast
import Photos

class ServiceContactVideoManager {
    
    static let shared = ServiceContactVideoManager()
    // 创建 PHCachingImageManager 实例
    let imageManager = PHCachingImageManager.default()
    let option = PHImageRequestOptions.init()
    let optionVideo = PHVideoRequestOptions()
    var videoAsset : AVAsset?
    
    let fileManager = FileManager.default
    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    private init(){
        
    }
}

extension ServiceContactVideoManager{
    func dealVideoAsset(asset: PHAsset,
                        retry: Int = 0,
                        completion: @escaping (URL?) -> Void) {

        imageManager.requestAVAsset(forVideo: asset, options: optionVideo) { avAsset, _, _ in
            if let urlAsset = avAsset as? AVURLAsset {
                self.videoAsset = urlAsset
                
                let videoUrl = urlAsset.url
                completion(videoUrl)
            } else {
                // AirDrop / iCloud 正在写文件：再等等，最多重试 10 次（约 5 秒）
                if retry < 10 {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                        self.dealVideoAsset(asset: asset,
                                            retry: retry + 1,
                                            completion: completion)
                    }
                } else {
                    DispatchQueue.main.async {
                        MCToast.mc_failure("视频仍在导入中，请稍后再试")
                    }
                    completion(nil)                      // ❌ 放弃，本次不降级
                }
            }
        }
    }
    
    func exportVideoToSandbox(asset: AVAsset,
                              outputFileName: String,
                              completion: @escaping (URL?) -> Void) {
        let destinationURL = documentsUrl.appendingPathComponent("\(outputFileName).mp4")
        if fileManager.fileExists(atPath: destinationURL.path) {
            try? fileManager.removeItem(at: destinationURL)
        }

        guard let exportSession = AVAssetExportSession(asset: asset,
                                                        presetName: AVAssetExportPreset1280x720) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        exportSession.outputURL = destinationURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    completion(destinationURL)
                default:
                    completion(nil)
                }
            }
        }
    }

    func removeFileIfExists(at url: URL) {
        if fileManager.fileExists(atPath: url.path) {
            try? fileManager.removeItem(at: url)
        }
    }
}
