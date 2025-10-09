//
//  ZFPartialResourceLoaderDelegate.swift
//  lns
//
//  Created by Elavatine on 2025/4/10.
//

import AVFoundation

/// 核心：拦截系统加载，自己发 HTTP Range 请求，只取“当前位置 ~ +10秒”对应的字节。
class ZFPartialResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    
    /// 视频总时长 (秒)，从 AVAsset.duration 获取
    var totalDuration: Double = 0
    
    /// 原始 URL（http/https），用来实际发请求
    var originalURL: URL?
    
    /// 缓存所有正在处理的请求
    private var pendingRequests = [AVAssetResourceLoadingRequest]()
    
    /// 服务器返回的总字节大小
    private var contentLength: Int64 = 0
    
    /// 避免多次 HEAD
    private var hasLoadedInfo = false
    
    /// 清理所有请求
    func clearResource() {
        pendingRequests.forEach { $0.finishLoading() }
        pendingRequests.removeAll()
    }
    
    // MARK: - AVAssetResourceLoaderDelegate
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        // 记录
        pendingRequests.append(loadingRequest)
        // 处理
        processRequest(loadingRequest)
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        if let index = pendingRequests.firstIndex(of: loadingRequest) {
            pendingRequests.remove(at: index)
        }
    }
    
    // MARK: - 核心处理
    private func processRequest(_ loadingRequest: AVAssetResourceLoadingRequest) {
        guard let url = self.originalURL else {
            finishWithError(loadingRequest, error: NSError(domain: "No Original URL", code: -1, userInfo: nil))
            return
        }
        
        // 第一次: 先做 HEAD 请求获取 contentLength (若尚未获取)
        if !hasLoadedInfo {
            if !doHeadRequest(url: url) {
                finishWithError(loadingRequest, error: NSError(domain: "Head Request Failed", code: -2, userInfo: nil))
                return
            }
            hasLoadedInfo = true
        }
        
        // 计算“时间->字节”区间
        // 1) 获取当前播放秒
        //    AVAssetResourceLoadingRequest 并不能直接告诉我们“当前秒”，
        //    需你在外部把“当前播放时间”记录下来, 这里为了演示, 假设是 resourceLoadingRequest.dataRequest?.requestOffset
        //    也可能把“时间->字节”做近似映射。
        guard let dataRequest = loadingRequest.dataRequest else {
            finishWithError(loadingRequest, error: NSError(domain: "No dataRequest", code: -3, userInfo: nil))
            return
        }
        
        // 注意：AVPlayer会请求从 0字节 开始索引, 这时你需要根据 “当前time” + “10秒”来做判断:
        // 比如: (time / totalDuration) * contentLength = currentByte
        //       ((time+10) / totalDuration) * contentLength = endByte
        // 这里演示做一个假设: offset -> byte
        // 也可在外部通过 KVO currentTime, 让 loadingRequest 携带“当前时间”信息, 代码因人而异
        
        // => 下面是最简单写法: 如果 “请求的 endOffset” 大于 “currentByte+10秒对应” 就截断
        let requestedOffset = dataRequest.requestedOffset // ex. 0
        let requestedLength = Int64(dataRequest.requestedLength) // ex. 32768
        let start = requestedOffset
        let end = Double(requestedOffset) + Double(requestedLength) - 1
        
        // 假设我们只有 "10秒后" ~ " currentByte+ chunk" = ...
        // demo：假设把 "10秒" 映射到 contentLength*(10/totalDuration)
        let currentByte = Double(self.contentLength) * approximateCurrentTimeRatio() // <--- 需要你外部实时更新
        let maxOffset = currentByte + Double(self.contentLength) * (10.0 / self.totalDuration)
        
        if Double(end) > maxOffset {
            // 超过我们设定的 10秒字节区间，不再加载，返回空结尾
            let clippedLen = maxOffset - Double(start)
            if clippedLen <= 0 {
                // 代表请求超出范围
                finishWithEmpty(loadingRequest)
                return
            } else {
                // 截断
                let newEnd = Int64(Double(start) + clippedLen - 1)
                doPartialRequest(loadingRequest, url: url, rangeStart: Int64(start), rangeEnd: newEnd)
                return
            }
        } else {
            // 正常范围
            doPartialRequest(loadingRequest, url: url, rangeStart: Int64(start), rangeEnd: Int64(end))
        }
    }
    
    /// 发起 HEAD 请求，获取 contentLength
    private func doHeadRequest(url: URL) -> Bool {
        var req = URLRequest(url: url)
        req.httpMethod = "HEAD"
        
        let semaphore = DispatchSemaphore(value: 0)
        var success = false
        let task = URLSession.shared.dataTask(with: req) { (_, resp, err) in
            defer { semaphore.signal() }
            if let e = err {
                print("Head request err: \(e)")
                success = false
                return
            }
            guard let httpResp = resp as? HTTPURLResponse else {
                success = false
                return
            }
            if let clStr = httpResp.allHeaderFields["Content-Length"] as? String,
               let cl = Int64(clStr) {
                self.contentLength = cl
                success = true
            } else {
                success = false
            }
        }
        task.resume()
        semaphore.wait()
        return success
    }
    
    /// 发起 Range 请求 [start, end]
    private func doPartialRequest(_ loadingRequest: AVAssetResourceLoadingRequest,
                                  url: URL,
                                  rangeStart: Int64,
                                  rangeEnd: Int64) {
        guard rangeEnd > rangeStart else {
            finishWithEmpty(loadingRequest)
            return
        }
        
        let rangeHeader = "bytes=\(rangeStart)-\(rangeEnd)"
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(rangeHeader, forHTTPHeaderField: "Range")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: req) { [weak self] (data, response, error) in
            guard let self = self else { return }
            if let e = error {
                self.finishWithError(loadingRequest, error: e as NSError)
                return
            }
            guard let httpResp = response as? HTTPURLResponse else {
                self.finishWithError(loadingRequest, error: NSError(domain: "No HTTPResp", code: -4, userInfo: nil))
                return
            }
            // 填充 response
            let contentType = httpResp.allHeaderFields["Content-Type"] as? String ?? "video/mp4"
            let cRange = httpResp.allHeaderFields["Content-Range"] as? String ?? ""
            
            // 解析实际 Content-Range length
            let actualData = data ?? Data()
            
            // 填写 contentInformationRequest
            let contentInfo = loadingRequest.contentInformationRequest
            contentInfo?.contentType = contentType
            contentInfo?.contentLength = self.contentLength
            contentInfo?.isByteRangeAccessSupported = true
            
            // 将数据塞入 dataRequest
            let dataRequest = loadingRequest.dataRequest
            dataRequest?.respond(with: actualData)
            
            // 结束
            loadingRequest.finishLoading()
        }
        task.resume()
    }
    
    private func finishWithEmpty(_ loadingRequest: AVAssetResourceLoadingRequest) {
        // 给个空数据，finish
        let contentInfo = loadingRequest.contentInformationRequest
        contentInfo?.contentType = "video/mp4"
        contentInfo?.contentLength = 0
        contentInfo?.isByteRangeAccessSupported = true
        
        loadingRequest.dataRequest?.respond(with: Data())
        loadingRequest.finishLoading()
    }
    
    private func finishWithError(_ loadingRequest: AVAssetResourceLoadingRequest, error: NSError) {
        loadingRequest.finishLoading(with: error)
    }
    
    /// 这里需要你自己写“当前播放时间 / totalDuration”，用来推断 byteOffset
    /// demo 里只是写死 0.3(代表播放到30%)
    private func approximateCurrentTimeRatio() -> Double {
        // TODO: 你可以把“真实当前秒 / totalDuration”传进来
        // 或通过 Notification / KVO 同步过来
        return 0.3
    }
}
