//
//  SimpleAVPlayerView.swift
//  lns
//
//  Created by Elavatine on 2025/6/26.
//

import UIKit
import AVFoundation

/// Simple AVPlayer based video view to replace ZFPlayer for better performance.
class SimpleAVPlayerView: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    /// URL of the video to play
    var url: URL? {
        didSet {
            guard let url = url else { return }
            let playerItem = AVPlayerItem(url: url)
            if player == nil {
                player = AVPlayer(playerItem: playerItem)
                playerLayer = AVPlayerLayer(player: player)
                playerLayer?.videoGravity = .resizeAspect
                if let layer = playerLayer {
                    layer.frame = bounds
                    layer.backgroundColor = UIColor.black.cgColor
                    layer.needsDisplayOnBoundsChange = true
                    self.layer.addSublayer(layer)
                }
            } else {
                player?.replaceCurrentItem(with: playerItem)
            }
        }
    }

    /// Start playback
    func play() {
        player?.play()
    }

    /// Pause playback
    func pause() {
        player?.pause()
    }

    /// Stop playback and reset
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
    }

    /// Current playback time in seconds
    var currentTime: TimeInterval {
        return player?.currentTime().seconds ?? 0
    }

    /// Total duration of the video in seconds
    var totalTime: TimeInterval {
        return player?.currentItem?.duration.seconds ?? 0
    }
}
