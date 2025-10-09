//
//  CachingPlayerItemLoader.swift
//  lns
//
//  Created by Elavatine on 2025/4/1.
//

import AVFoundation

protocol CachingLoaderDelegate: AnyObject {
    func loader(_ loader: CachingPlayerItemLoader, didFailWithError error: Error?)
    func loaderDidFinishPreloading(_ loader: CachingPlayerItemLoader)
}

class CachingPlayerItemLoader: NSObject {
    // MARK: - 配置参数
    private let customScheme: String
    private let originalScheme: String
    private let cacheQueue = DispatchQueue(label: "com.cachingloader.queue")
    
    // MARK: - 数据存储
    private var mediaData = Data()
    private var pendingRequests = [AVAssetResourceLoadingRequest]()
    private var dataTask: URLSessionDataTask?
    private var session: URLSession?
    
    // MARK: - 状态跟踪
    private var contentInfo = ContentInfo()
    private var isCancelled = false
    weak var delegate: CachingLoaderDelegate?
    
    init(customScheme: String = "cachingstream", originalScheme: String = "http") {
        self.customScheme = customScheme
        self.originalScheme = originalScheme
        super.init()
    }
    
    // MARK: - 公开方法
    func preload(url: URL, startOffset: Int64, length: Int64) {
        cancelCurrentLoading()
        
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            DLLog(message: "start cache request bytes \(startOffset)-\(startOffset + length) url:\(url)")
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 15
            self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            
            var request = URLRequest(url: self.originalURL(from: url))
            request.cachePolicy = .reloadIgnoringLocalCacheData
//            request.addValue("bytes=\(startOffset)-\(startOffset + length)", forHTTPHeaderField: "Range")
            let endOffset = startOffset + length - 1
            request.addValue("bytes=\(startOffset)-\(endOffset)", forHTTPHeaderField: "Range")
            
            self.dataTask = self.session?.dataTask(with: request)
            self.dataTask?.resume()
        }
    }
    
    func cancelCurrentLoading() {
        cacheQueue.async { [weak self] in
            self?.isCancelled = true
            self?.dataTask?.cancel()
            self?.session?.invalidateAndCancel()
            self?.mediaData.removeAll()
            self?.pendingRequests.removeAll()
        }
    }
    
    // MARK: - URL处理
    private func originalURL(from requestURL: URL) -> URL {
        let urlString = requestURL.absoluteString
            .replacingOccurrences(of: "\(customScheme)://", with: "\(originalScheme)://")
        return URL(string: urlString)!
    }
    
    private func interceptedURL(from originalURL: URL) -> URL {
        let urlString = originalURL.absoluteString
            .replacingOccurrences(of: "\(originalScheme)://", with: "\(customScheme)://")
        return URL(string: urlString)!
    }
}

// MARK: - AVAssetResourceLoaderDelegate
extension CachingPlayerItemLoader: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        cacheQueue.async { [weak self] in
            self?.handleLoadingRequest(loadingRequest)
        }
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        cacheQueue.async { [weak self] in
            self?.pendingRequests.removeAll { $0 == loadingRequest }
        }
    }
    
    private func handleLoadingRequest(_ request: AVAssetResourceLoadingRequest) {
        pendingRequests.append(request)
        processPendingRequests()
    }
}

// MARK: - 请求处理核心逻辑
extension CachingPlayerItemLoader {
    private func processPendingRequests() {
        var finishedRequests = Set<AVAssetResourceLoadingRequest>()
        
        for request in pendingRequests {
            if isCancelled {
                request.finishLoading(with: NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil))
                finishedRequests.insert(request)
                continue
            }
            
            // 填充内容信息
            if let infoRequest = request.contentInformationRequest, contentInfo.contentType == nil {
                fillContentInfo(request: infoRequest)
            }
            
            // 响应数据请求
            if let dataRequest = request.dataRequest {
                let requestedOffset = Int(dataRequest.requestedOffset)
                let requestedLength = dataRequest.requestedLength
                let responseData = mediaData.subdata(in: requestedOffset..<requestedOffset + requestedLength)
                dataRequest.respond(with: responseData)
                
                if dataRequest.currentOffset >= dataRequest.requestedOffset + Int64(dataRequest.requestedLength) {
                    request.finishLoading()
                    finishedRequests.insert(request)
                }
            }
        }
        
        pendingRequests.removeAll { finishedRequests.contains($0) }
    }
    
    private func fillContentInfo(request: AVAssetResourceLoadingContentInformationRequest) {
        request.contentType = contentInfo.contentType
        request.contentLength = contentInfo.contentLength
        request.isByteRangeAccessSupported = contentInfo.isByteRangeAccessSupported
    }
}

// MARK: - URLSession数据处理
extension CachingPlayerItemLoader: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let httpResponse = response as? HTTPURLResponse else {
            completionHandler(.cancel)
            return
        }
        
        // 解析Content-Range头部获取总长度
        if let contentRange = httpResponse.allHeaderFields["Content-Range"] as? String,
           let totalLength = contentRange.split(separator: "/").last.flatMap({ Int64($0) }) {
            contentInfo.contentLength = totalLength
        }
        
        contentInfo.contentType = httpResponse.mimeType ?? AVFileType.mp4.rawValue
        contentInfo.isByteRangeAccessSupported = true
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        mediaData.append(data)
        DLLog(message: "preload received \(data.count) bytes")
        processPendingRequests()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            DLLog(message: "preload failed: \(error)")
            delegate?.loader(self, didFailWithError: error)
        } else {
            DLLog(message: "preload finished")
            delegate?.loaderDidFinishPreloading(self)
        }
    }
}

// MARK: - 辅助结构体
private struct ContentInfo {
    var contentType: String?
    var contentLength: Int64 = 0
    var isByteRangeAccessSupported = false
}

// MARK: - 与ZFPlayer的集成扩展
extension CachingPlayerItemLoader {
    /// 创建带缓存代理的AVURLAsset
    func createCachedAsset(with originalURL: URL) -> AVURLAsset {
        let interceptedURL = interceptedURL(from: originalURL)
        let asset = AVURLAsset(url: interceptedURL)
        asset.resourceLoader.setDelegate(self, queue: cacheQueue)
        return asset
    }
    
    /// 动态码率计算（关键优化）
    func calculatePreloadLength(for asset: AVURLAsset, duration: TimeInterval) -> Int64 {
        guard let videoTrack = asset.tracks(withMediaType: .video).first else { return 10_000_000 }
        
        let bitRate = videoTrack.estimatedDataRate
        let bytesPerSecond = bitRate / 8
        return Int64(Float64(bytesPerSecond) * Float64(duration))
    }
}
