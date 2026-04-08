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

    // Cut a little bit deeper into the source edge, and overscan the video layer,
    // so the dark matte pixels from the source MP4 stay outside the visible circle.
    private static let maskInsetRatio: CGFloat = 7.0 / 142.0
    private static let overscanRatio: CGFloat = 1.08

    // Display-time crossfade. The actual source overlap is scaled by playback rate.
    private static let displayCrossfadeDuration: Double = 0.55

    private let orbMaskLayer = CAShapeLayer()
    private let playerLayers = [AVPlayerLayer(), AVPlayerLayer()]
    private var players = [AVPlayer(), AVPlayer()]
    private var timeObservers: [Any?] = [nil, nil]

    private var sourceLoopDuration: Double = 20.0
    private var playbackRate: Float = 1.0
    private var activeIndex = 0
    private var isCrossfading = false
    private var hasStarted = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configurePlayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
        configurePlayers()
    }

    deinit {
        for (index, observer) in timeObservers.enumerated() {
            if let observer {
                players[index].removeTimeObserver(observer)
            }
        }
        players.forEach { player in
            player.pause()
            player.replaceCurrentItem(with: nil)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutLayersAndMask()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil else {
            players.forEach { $0.pause() }
            return
        }

        if hasStarted {
            updatePlaybackRate()
        } else {
            startPlaybackFromBeginning()
        }
    }
}

private extension AICoachRotatingPearlOrbView {
    func configureView() {
        backgroundColor = .clear
        isOpaque = false

        for (index, playerLayer) in playerLayers.enumerated() {
            playerLayer.backgroundColor = UIColor.clear.cgColor
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.opacity = (index == activeIndex) ? 1.0 : 0.0
            layer.addSublayer(playerLayer)
        }

        orbMaskLayer.fillColor = UIColor.black.cgColor
        orbMaskLayer.contentsScale = UIScreen.main.scale
        layer.mask = orbMaskLayer
    }

    func configurePlayers() {
        guard let url = referenceVideoURL() else {
            assertionFailure("Missing \(Self.assetName).\(Self.assetExtension) in the app bundle.")
            return
        }

        let asset = AVURLAsset(url: url)
        let durationSeconds = asset.duration.seconds
        if durationSeconds.isFinite, durationSeconds > 0 {
            sourceLoopDuration = durationSeconds
        }

        for index in 0 ..< players.count {
            let item = AVPlayerItem(asset: asset)
            item.preferredForwardBufferDuration = 0

            let player = players[index]
            player.replaceCurrentItem(with: item)
            player.isMuted = true
            player.actionAtItemEnd = .pause
            player.automaticallyWaitsToMinimizeStalling = false
            player.preventsDisplaySleepDuringVideoPlayback = false

            playerLayers[index].player = player

            let observer = player.addPeriodicTimeObserver(
                forInterval: CMTime(value: 1, timescale: 60),
                queue: .main
            ) { [weak self] _ in
                self?.handlePlaybackTick(for: index)
            }
            timeObservers[index] = observer
        }

        updatePlaybackRate()
    }

    func layoutLayersAndMask() {
        let side = min(bounds.width, bounds.height)
        let visibleFrame = CGRect(
            x: (bounds.width - side) * 0.5,
            y: (bounds.height - side) * 0.5,
            width: side,
            height: side
        )

        let overscannedSide = side * Self.overscanRatio
        let playerFrame = CGRect(
            x: visibleFrame.midX - overscannedSide * 0.5,
            y: visibleFrame.midY - overscannedSide * 0.5,
            width: overscannedSide,
            height: overscannedSide
        ).integral

        playerLayers.forEach { $0.frame = playerFrame }

        let inset = side * Self.maskInsetRatio
        orbMaskLayer.frame = bounds
        orbMaskLayer.path = UIBezierPath(ovalIn: visibleFrame.insetBy(dx: inset, dy: inset)).cgPath
    }

    func startPlaybackFromBeginning() {
        hasStarted = true
        isCrossfading = false
        activeIndex = 0

        playerLayers[0].opacity = 1.0
        playerLayers[1].opacity = 0.0

        let inactive = players[1]
        inactive.pause()
        inactive.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)

        let active = players[0]
        active.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            self?.updatePlaybackRate()
        }
    }

    func updatePlaybackRate() {
        let desiredDuration = max(rotationDuration, 0.1)
        playbackRate = Float(sourceLoopDuration / desiredDuration)

        guard window != nil else {
            players.forEach { $0.pause() }
            return
        }

        let activePlayer = players[activeIndex]
        activePlayer.playImmediately(atRate: playbackRate)

        if isCrossfading {
            players[1 - activeIndex].playImmediately(atRate: playbackRate)
        }
    }

    func handlePlaybackTick(for playerIndex: Int) {
        guard window != nil else { return }
        guard playerIndex == activeIndex else { return }
        guard !isCrossfading else { return }

        let currentSeconds = players[playerIndex].currentTime().seconds
        guard currentSeconds.isFinite else { return }

        let displayOverlap = Self.displayCrossfadeDuration
        let sourceOverlap = min(
            sourceLoopDuration * 0.25,
            max(0.08, displayOverlap * Double(max(playbackRate, 0.01)))
        )
        let triggerTime = sourceLoopDuration - sourceOverlap

        if currentSeconds >= triggerTime {
            beginCrossfade(displayDuration: displayOverlap)
        }
    }

    func beginCrossfade(displayDuration: Double) {
        guard !isCrossfading else { return }
        isCrossfading = true

        let outgoingIndex = activeIndex
        let incomingIndex = 1 - outgoingIndex

        let outgoingPlayer = players[outgoingIndex]
        let incomingPlayer = players[incomingIndex]
        let outgoingLayer = playerLayers[outgoingIndex]
        let incomingLayer = playerLayers[incomingIndex]

        incomingLayer.opacity = 0.0
        layer.insertSublayer(incomingLayer, above: outgoingLayer)

        incomingPlayer.pause()
        incomingPlayer.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            guard let self else { return }
            incomingPlayer.playImmediately(atRate: self.playbackRate)

            CATransaction.begin()
            CATransaction.setDisableActions(false)
            CATransaction.setAnimationDuration(displayDuration)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .linear))
            incomingLayer.opacity = 1.0
            outgoingLayer.opacity = 0.0
            CATransaction.commit()

            DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) { [weak self] in
                guard let self else { return }

                outgoingPlayer.pause()
                outgoingPlayer.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                outgoingLayer.opacity = 0.0

                self.activeIndex = incomingIndex
                self.isCrossfading = false
            }
        }
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
