//
//  PlayerTestVC.swift
//  lns
//
//  Created by Elavatine on 2025/4/7.
//
import AVKit

class PlayerTestVC: WHBaseViewVC {
    
    var playerViewController = AVPlayerViewController()
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    // 添加时间观察者
    var timeObserver: Any?
    // 缓冲控制参数
    let targetBufferDuration: Double = 10 // 目标缓冲时长（秒）
    let bufferHighWaterMark: Double = 12  // 暂停下载阈值
    let bufferLowWaterMark: Double = 5    // 恢复下载阈值
    deinit {
        // 确保移除所有观察者
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player?.pause()
        player = nil
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
            guard let playerItem = object as? AVPlayerItem else { return }
//            self.updateBufferProgress(playerItem: playerItem)
            self.checkBufferStatus(playerItem: playerItem)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        setupPlayer()
    }
}

extension PlayerTestVC {
    func initUI() {
        initNavi(titleStr: "AVPlayer 缓存调试")
    }
    
    func setupPlayer() {
        guard let url = URL(string: "https://lnsapp-static-o.oss-cn-shenzhen.aliyuncs.com/forum/post/material/video_a201a534c610b309cfdfab10b06485bd202504062267.mp4") else {
            print("Invalid URL")
            return
        }
        
        // 创建带策略的 AVURLAsset
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": ["User-Agent": "YourCustomUserAgent"]])
        
        // 关键修改 1：设置资源加载策略
//        asset.resourceLoader.setDelegate(self, queue: .main)
        
        playerItem = AVPlayerItem(asset: asset)
        
        // 关键修改 2：正确设置缓冲策略
        playerItem?.preferredForwardBufferDuration = 10
        playerItem?.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges),
                               options: .new,
                               context: nil)
        
        player = AVPlayer(playerItem: playerItem)
        
        // 关键修改 3：调整播放策略
        player?.automaticallyWaitsToMinimizeStalling = false
        playerViewController.player = player
        
        // 添加播放时间观察者
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTimeMake(value: 1, timescale: 1),
            queue: .main) { [weak self] time in
                self?.checkBufferProgress()
        }
        
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.view.frame = view.bounds
        
        player?.play()
    }
    
    func updateBufferProgress(playerItem: AVPlayerItem) {
        let loadedTimeRanges = playerItem.loadedTimeRanges
        guard let timeRange = loadedTimeRanges.first?.timeRangeValue else { return }
        
        let bufferEnd = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration)
        let currentTime = CMTimeGetSeconds(playerItem.currentTime())
        
        // 计算剩余缓冲时间
        let remainingBuffer = bufferEnd - currentTime
        DLLog(message: "剩余缓冲时间：\(remainingBuffer) 秒")
        
        // 当剩余缓冲超过 10 秒时暂停加载
//        if remainingBuffer > 15 { // 设置稍大于目标值的阈值
//            player?.currentItem?.suspendLoading()
//            player?.currentItem.
//        } else if remainingBuffer < 5 { // 当缓冲不足时恢复加载
//            player?.currentItem?.resumeLoading()
//        }
    }
    
    func checkBufferProgress() {
        let bufferedDuration = calculateBufferedDuration()
//        guard let playerItem = player?.currentItem else { return }
//        
//        let currentTime = CMTimeGetSeconds(playerItem.currentTime())
//        let bufferedTime = getBufferEndTime() - currentTime
        
        DLLog(message: "当前缓冲时长：\(bufferedDuration) 秒   ---  \(availableDuration)")
        
    }
    
    private func getBufferEndTime() -> Double {
        guard let playerItem = player?.currentItem,
              let firstRange = playerItem.loadedTimeRanges.first?.timeRangeValue else {
            return 0
        }
        return CMTimeGetSeconds(firstRange.start) + CMTimeGetSeconds(firstRange.duration)
    }
}

extension PlayerTestVC{
    private func checkBufferStatus(playerItem: AVPlayerItem) {
        let bufferedDuration = calculateBufferedDuration()
        let currentTime = CMTimeGetSeconds(playerItem.currentTime())
        let bufferEndTime = getBufferEndTime()
        
        // 计算剩余缓冲时间
        let remainingBuffer = bufferEndTime - currentTime
        DLLog(message: "剩余缓冲: \(remainingBuffer) 秒")
        
        // 动态控制网络请求
        if remainingBuffer > bufferHighWaterMark {
            // 暂停网络请求（通过替换播放器实例实现）
            pauseLoading()
        } else if remainingBuffer < bufferLowWaterMark {
            // 恢复网络请求
            resumeLoading()
        }
    }
    
    private func pauseLoading() {
        guard let currentItem = player?.currentItem else { return }
        
        // 通过替换播放器项暂停加载
        let newPlayerItem = AVPlayerItem(asset: currentItem.asset)
        newPlayerItem.preferredForwardBufferDuration = 0 // 禁用自动缓冲
        player?.replaceCurrentItem(with: newPlayerItem)
        player?.pause()
    }
    
    private func resumeLoading() {
        guard let currentItem = player?.currentItem else { return }
        
        // 恢复原始配置
        let newPlayerItem = AVPlayerItem(asset: currentItem.asset)
        newPlayerItem.preferredForwardBufferDuration = targetBufferDuration
        player?.replaceCurrentItem(with: newPlayerItem)
        player?.play()
    }
    
    private func calculateBufferedDuration() -> Double {
        guard let playerItem = player?.currentItem,
              let firstRange = playerItem.loadedTimeRanges.first?.timeRangeValue else {
            return 0
        }
        return CMTimeGetSeconds(firstRange.duration)
    }
    var availableDuration: TimeInterval {
        guard let playerItem = playerItem else { return 0 }
        
        let timeRangeArray = playerItem.loadedTimeRanges
        let currentTime = player?.currentTime() ?? CMTime.zero
        
        for value in timeRangeArray {
            let timeRange = value.timeRangeValue
            if CMTimeRangeContainsTime(timeRange, time: currentTime) {
                let maxTime = CMTimeRangeGetEnd(timeRange)
                let playableDuration = CMTimeGetSeconds(maxTime)
                return playableDuration > 0 ? playableDuration : 0
            }
        }
        return 0
    }
//    private func getBufferEndTime() -> Double {
//        guard let playerItem = player?.currentItem,
//              let firstRange = playerItem.loadedTimeRanges.first?.timeRangeValue else {
//            return 0
//        }
//        return CMTimeGetSeconds(firstRange.start) + CMTimeGetSeconds(firstRange.duration)
//    }
    
    private func checkPlaybackStatus() {
        guard let player = player else { return }
        
        if player.rate == 0 {
            DLLog(message: "播放暂停，当前时间：\(CMTimeGetSeconds(player.currentTime()))")
        } else {
            DLLog(message: "播放中，当前时间：\(CMTimeGetSeconds(player.currentTime()))")
        }
    }
}

// 关键修改 4：实现资源加载控制
extension PlayerTestVC: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        // 这里可以添加自定义的缓存控制逻辑
        return false // 返回 false 使用默认加载策略
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        // 处理取消的请求
    }
}
