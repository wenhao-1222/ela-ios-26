//
//  TenSecondCacheLoader.swift
//  lns
//
//  Created by Elavatine on 2025/5/26.
//

import AVFoundation

class TenSecondCacheLoader: NSObject {
    private let originalURL: URL
    private var bytesPerSecond: Int64 = 0
    private var currentTime: CMTime = .zero
    private let cacheWindow: TimeInterval = 10
    private let queue = DispatchQueue(label: "com.tensecond.cache")
    private var cachedData: [NSRange: Data] = [:]
    private var session = URLSession(configuration: .default)

    init(url: URL) {
        self.originalURL = url
        super.init()
    }

    func createAsset() -> AVURLAsset {
        let proxy = URL(string: originalURL.absoluteString.replacingOccurrences(of: "https", with: "tensec"))!
        let asset = AVURLAsset(url: proxy)
        asset.resourceLoader.setDelegate(self, queue: queue)
        if let track = asset.tracks(withMediaType: .video).first {
            bytesPerSecond = Int64(track.estimatedDataRate / 8)
        }
        return asset
    }

    func prefetch(from time: CMTime) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let start = Int64(time.seconds) * self.bytesPerSecond
            let length = Int64(self.cacheWindow) * self.bytesPerSecond
            var request = URLRequest(url: self.originalURL)
            request.addValue("bytes=\(start)-\(start + length - 1)", forHTTPHeaderField: "Range")
            let task = self.session.dataTask(with: request) { [weak self] data, _, _ in
                guard let self = self, let data = data else { return }
                let range = NSRange(location: Int(start), length: data.count)
                self.cachedData[range] = data
                self.trimCache()
            }
            task.resume()
        }
    }

    func updateCurrentTime(_ time: CMTime) {
        queue.async { [weak self] in
            self?.currentTime = time
            self?.trimCache()
        }
    }

    private func trimCache() {
        let startOffset = Int64(currentTime.seconds) * bytesPerSecond
        cachedData = cachedData.filter { range, _ in
            Int64(range.upperBound) > startOffset
        }
    }

    private func storeIfNeeded(range: NSRange, data: Data) {
        let startOffset = Int64(currentTime.seconds) * bytesPerSecond
        let endOffset = startOffset + Int64(cacheWindow) * bytesPerSecond
        if Int64(range.upperBound) <= endOffset {
            cachedData[range] = data
        }
    }

    private func cachedSegment(for range: NSRange) -> Data? {
        for (storedRange, data) in cachedData {
            if NSLocationInRange(range.location, storedRange) && NSMaxRange(range) <= NSMaxRange(storedRange) {
                let offset = range.location - storedRange.location
                return data.subdata(in: offset..<offset + range.length)
            }
        }
        return nil
    }
}

extension TenSecondCacheLoader: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        queue.async { [weak self] in
            self?.handle(request: loadingRequest)
        }
        return true
    }

    private func handle(request: AVAssetResourceLoadingRequest) {
        guard let dataRequest = request.dataRequest,
              let url = request.request.url else {
            request.finishLoading(with: NSError(domain: "Invalid", code: -1))
            return
        }

        let start = Int(dataRequest.requestedOffset)
        let length = dataRequest.requestedLength
        let range = NSRange(location: start, length: length)

        if let cached = cachedSegment(for: range) {
            dataRequest.respond(with: cached)
            request.finishLoading()
            return
        }

        var urlRequest = URLRequest(url: URL(string: url.absoluteString.replacingOccurrences(of: "tensec", with: "https"))!)
        urlRequest.addValue("bytes=\(start)-\(start + length - 1)", forHTTPHeaderField: "Range")

        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
            guard let self = self else { return }
            if let data = data {
                dataRequest.respond(with: data)
                request.finishLoading()
                self.storeIfNeeded(range: range, data: data)
            } else {
                request.finishLoading(with: error)
            }
        }
        task.resume()
    }
}
