//
//  VideoViewController.swift
//  lns
//
//  Created by Elavatine on 2025/3/25.
//

import UIKit
//import VdoFramework
//
//class VideoViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupVdoCipherPlayer()
//    }
//
//    func setupVdoCipherPlayer() {
//        // 替换为你的 API Key 和 Video ID
//        let apiKey = "YOUR_API_KEY"
//        let videoId = "YOUR_VIDEO_ID"
//        
//        // 配置播放器参数
//        let playerConfig = VdoPlayerConfig(apiKey: apiKey, videoId: videoId)
//        
//        // 设置水印配置
//        let watermarkConfig = VdoWatermarkConfig(
//            text: "User123",  // 动态水印文字（如用户名）
//            fontSize: 20,
//            color: UIColor.white.withAlphaComponent(0.7),
//            position: .topRight
//        )
//        playerConfig.watermarkConfig = watermarkConfig
//        
//        // 初始化播放器
//        player = VdoPlayer(config: playerConfig)
//        player?.delegate = self
//        
//        // 添加播放器视图
//        if let playerView = player?.view {
//            playerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 300)
//            view.addSubview(playerView)
//        }
//        
//        // 开始播放
//        player?.play()
//    }
//}
//
//// MARK: - VdoPlayerDelegate 处理事件
//extension VideoViewController: VdoPlayerDelegate {
//    func vdoPlayer(_ player: VdoPlayer, didFailWithError error: Error) {
//        print("播放失败: \(error.localizedDescription)")
//    }
//    
//    func vdoPlayerDidFinishPlayback(_ player: VdoPlayer) {
//        print("播放完成")
//    }
//}
