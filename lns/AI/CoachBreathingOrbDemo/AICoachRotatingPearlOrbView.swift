//
//  AICoachRotatingPearlOrbView.swift
//  lns
//
//  Created by Codex on 2026/4/8.
//

import UIKit
import AVFoundation

final class AICoachRotatingPearlOrbView: UIView {
    var rotationDuration: CFTimeInterval = 20.0 {
        didSet {
            updatePlaybackRate()
        }
    }

    private static let assetName = "AICoachPearlOrbReferenceCrop"
    private static let assetExtension = "mp4"
    private static let fallbackLoopDuration: Double = 20.0
    private static let maskInsetRatio: CGFloat = 2.35 / 142.0
    private static let contentOverscanRatio: CGFloat = 4.0 / 142.0
    private static let breathingAnimationKey = "aiCoach.orb.breathing"
    private static let breathingDuration: CFTimeInterval = 3.6
    private static let breathingMinScale: CGFloat = 0.985
    private static let breathingMaxScale: CGFloat = 1.02

    private let orbMaskLayer = CAShapeLayer()
    private let playerLayer = AVPlayerLayer()

    private var queuePlayer: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var sourceLoopDuration: Double = 20.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configurePlayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
        configurePlayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutPlayerAndMask()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            queuePlayer?.pause()
            stopBreathingAnimation()
        } else {
            updatePlaybackRate()
            startBreathingAnimationIfNeeded()
        }
    }

    deinit {
        queuePlayer?.pause()
        looper = nil
    }
}

private extension AICoachRotatingPearlOrbView {
    func configureView() {
        backgroundColor = .clear
        isOpaque = false

        playerLayer.backgroundColor = UIColor.clear.cgColor
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        orbMaskLayer.fillColor = UIColor.black.cgColor
        orbMaskLayer.contentsScale = UIScreen.main.scale
        layer.mask = orbMaskLayer
    }

    func configurePlayer() {
        guard let url = referenceVideoURL() else {
            assertionFailure("Missing \(Self.assetName).\(Self.assetExtension) in the app bundle.")
            return
        }

        let asset = AVURLAsset(url: url)
        let seconds = asset.duration.seconds
        if seconds.isFinite, seconds > 0 {
            sourceLoopDuration = seconds
        }

        let item = AVPlayerItem(asset: asset)
        let player = AVQueuePlayer()
        player.actionAtItemEnd = .none
        player.isMuted = true
        player.automaticallyWaitsToMinimizeStalling = false

        looper = AVPlayerLooper(player: player, templateItem: item)
        queuePlayer = player
        playerLayer.player = player
        updatePlaybackRate()
    }

    func layoutPlayerAndMask() {
        let side = min(bounds.width, bounds.height)
        let renderFrame = CGRect(
            x: (bounds.width - side) * 0.5,
            y: (bounds.height - side) * 0.5,
            width: side,
            height: side
        ).integral

        // The source mp4 has a dark matte at the edge, so slightly overscan the
        // video under the circular mask to keep that fringe out of view.
        let overscan = side * Self.contentOverscanRatio
        playerLayer.frame = renderFrame.insetBy(dx: -overscan, dy: -overscan)

        let inset = side * Self.maskInsetRatio
        orbMaskLayer.frame = bounds
        orbMaskLayer.path = UIBezierPath(ovalIn: renderFrame.insetBy(dx: inset, dy: inset)).cgPath
    }

    func updatePlaybackRate() {
        guard let player = queuePlayer else { return }
        guard window != nil else {
            player.pause()
            return
        }

        let desiredDuration = max(rotationDuration, 0.1)
        let rate = Float(sourceLoopDuration / desiredDuration)
        player.playImmediately(atRate: rate)
    }

    func startBreathingAnimationIfNeeded() {
        guard layer.animation(forKey: Self.breathingAnimationKey) == nil else { return }

        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = Self.breathingMinScale
        animation.toValue = Self.breathingMaxScale
        animation.duration = Self.breathingDuration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: Self.breathingAnimationKey)
    }

    func stopBreathingAnimation() {
        layer.removeAnimation(forKey: Self.breathingAnimationKey)
    }

    func referenceVideoURL() -> URL? {
        let bundles = [Bundle.main, Bundle(for: AICoachRotatingPearlOrbView.self)]
        for bundle in bundles {
            if let url = bundle.url(forResource: Self.assetName, withExtension: Self.assetExtension) {
                return url
            }
        }
        return nil
    }
}
