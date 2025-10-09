//
//  ResourceLoaderDelegate.swift
//  lns
//
//  Created by Elavatine on 2025/4/7.
//
import AVFoundation

class DynamicCacheLoader: NSObject, AVAssetResourceLoaderDelegate {
    private let cacheWindow: TimeInterval = 10 // 固定缓存窗口
    private var currentCacheRange: CMTimeRange?
    private var activeRequests = [AVAssetResourceLoadingRequest]()
    private let queue = DispatchQueue(label: "com.cache.loader")
    public var videoTrack: AVAssetTrack?
    
    // 更新缓存窗口
    func updateCacheWindow(currentTime: CMTime, duration: CMTime) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let start = currentTime
            let end = CMTimeAdd(currentTime, CMTime(seconds: self.cacheWindow, preferredTimescale: 600))
            
            self.currentCacheRange = CMTimeRangeFromTimeToTime(start: start, end: min(end, duration))
            
            // 取消范围外的请求
            self.activeRequests.forEach { request in
                if !self.isRequestInCacheRange(request) {
                    request.finishLoading(with: NSError(domain: "Cancelled", code: -998))
                    if let index = self.activeRequests.firstIndex(of: request) {
                        self.activeRequests.remove(at: index)
                    }
                }
            }
        }
    }
    
    private func isRequestInCacheRange(_ request: AVAssetResourceLoadingRequest) -> Bool {
        guard let dataRequest = request.dataRequest,
              let cacheRange = currentCacheRange,
              let track = videoTrack else { return false }
        
        let requestedRange = requestedTimeRange(for: dataRequest, track: track)
        return cacheRange.containsTimeRange(requestedRange)
    }
    
    private func requestedTimeRange(for dataRequest: AVAssetResourceLoadingDataRequest, track: AVAssetTrack) -> CMTimeRange {
        let requestedOffset = dataRequest.requestedOffset
        let requestedLength = dataRequest.requestedLength
        
        let startTime = CMTime(value: requestedOffset, timescale: track.naturalTimeScale)
        let duration = CMTime(value: Int64(requestedLength), timescale: track.naturalTimeScale)
        return CMTimeRange(start: startTime, duration: duration)
    }
    
    // MARK: - AVAssetResourceLoaderDelegate
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        queue.async { [weak self] in
            self?.handleLoadingRequest(loadingRequest)
        }
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        if let index = activeRequests.firstIndex(of: loadingRequest) {
            activeRequests.remove(at: index)
        }
    }
    
    private func handleLoadingRequest(_ request: AVAssetResourceLoadingRequest) {
        guard let dataRequest = request.dataRequest,
              let _ = currentCacheRange,
              let track = videoTrack else {
            request.finishLoading(with: NSError(domain: "NotReady", code: -1))
            return
        }
        
        if isRequestInCacheRange(request) {
            activeRequests.append(request)
            fetchData(request: request, track: track)
        } else {
            request.finishLoading(with: NSError(domain: "OutOfWindow", code: -999))
        }
    }
    
    private func fetchData(request: AVAssetResourceLoadingRequest, track: AVAssetTrack) {
        guard let originalURL = (request.request.url?.absoluteString.replacingOccurrences(of: "cacheloader://", with: "https://")) else {
            request.finishLoading(with: NSError(domain: "InvalidURL", code: -2))
            return
        }
        guard let dataRequest = request.dataRequest else { return}
        
        let totalBytes = Int64(track.totalSampleDataLength)
        let requestedOffset = dataRequest.requestedOffset
        let requestedLength = dataRequest.requestedLength
        DLLog(message: "正在加载字节范围: \(requestedOffset)-\(requestedOffset + Int64(requestedLength))")
        // 实际下载逻辑（示例使用URLSession）
        let urlRequest = URLRequest(url: URL(string: originalURL)!)
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let data = data {
                dataRequest.respond(with: data)
                request.finishLoading()
            } else if let error = error {
                request.finishLoading(with: error)
            }
            
            if let index = self.activeRequests.firstIndex(of: request) {
                self.activeRequests.remove(at: index)
            }
        }
        task.resume()
    }
}
