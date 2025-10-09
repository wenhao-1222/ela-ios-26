//
//  ZFCustomResourceLoaderManager.swift
//  lns
//
//  Created by Elavatine on 2025/4/10.
//


import AVFoundation
import UIKit

/// 这类用于存放播放器的逻辑 + ResourceLoaderDelegate
/// 你可以像用 ZFAVPlayerManager 那样去用它，然后把 URL 改为自定义 scheme，走这个 ResourceLoader。
class ZFCustomResourceLoaderManager: NSObject {
    
    /// 播放视图，类似 ZFPlayerPresentView
    private(set) var view: UIView = PlayerContainerView()
    
    /// Asset、PlayerItem、Player
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var asset: AVURLAsset?
    
    /// 用于 ResourceLoader 代理
    private let resourceLoaderDelegate = ZFPartialResourceLoaderDelegate()
    
    /// 用于记录视频总时长（秒）
    private var totalDuration: Double = 0
    
    /// URL：原始 http://xxx
    private(set) var originalURL: URL?
    
    /// 自定义 scheme 后的 URL，比如 myhttp://xxx
    private var customSchemeURL: URL?
    
    /// 是否正在播放
    private(set) var isPlaying = false
    
    /// 准备播放
    func prepareToPlay(url: URL) {
        stop()
        
        // 1) 记录原始 URL + 生成自定义 scheme 的 URL
        self.originalURL = url
        if let customUrl = replaceScheme(url: url, scheme: "myhttp") {
            self.customSchemeURL = customUrl
        } else {
            print("❌ 无法替换 scheme")
            return
        }
        
        // 2) 创建 AVURLAsset，指定 resourceLoader 的代理
        let options: [String:Any] = [:]
        let avURLAsset = AVURLAsset(url: self.customSchemeURL!, options: options)
        avURLAsset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: DispatchQueue.global(qos: .default))
        self.asset = avURLAsset
        
        // 3) 异步加载“时长、大小” 等信息
        avURLAsset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
            guard let self = self else { return }
            var error: NSError?
            let status = avURLAsset.statusOfValue(forKey: "duration", error: &error)
            if status == .loaded {
                let durationSec = CMTimeGetSeconds(avURLAsset.duration)
                if durationSec.isFinite {
                    self.totalDuration = durationSec
                    // 记录给 ResourceLoaderDelegate，用以计算 byte range
                    self.resourceLoaderDelegate.totalDuration = durationSec
                    self.resourceLoaderDelegate.originalURL = url
                }
                DispatchQueue.main.async {
                    // 4) 创建 PlayerItem、Player
                    let item = AVPlayerItem(asset: avURLAsset)
                    self.playerItem = item
                    let p = AVPlayer(playerItem: item)
                    self.player = p
                    // 绑定图层
                    if let container = self.view as? PlayerContainerView {
                        container.setPlayer(player: p)
                    }
                    // 自动播放
                    self.play()
                }
            } else {
                print("❌ 加载时长失败: \(String(describing: error))")
            }
        }
    }
    
    /// 播放
    func play() {
        guard let p = player else { return }
        p.play()
        self.isPlaying = true
    }
    
    /// 暂停
    func pause() {
        player?.pause()
        self.isPlaying = false
    }
    
    /// 停止
    func stop() {
        self.isPlaying = false
        self.player?.pause()
        self.playerItem = nil
        self.player = nil
        self.asset = nil
        self.customSchemeURL = nil
        self.resourceLoaderDelegate.clearResource()
        // 视图也可重置
    }
    
    /// 替换 http -> myhttp (或 https -> myhttps)
    private func replaceScheme(url: URL, scheme: String) -> URL? {
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        comps?.scheme = scheme
        return comps?.url
    }
}
