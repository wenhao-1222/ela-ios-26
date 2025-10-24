//
//  TutorialVideoControlView.swift
//  lns
//
//  Created by Elavatine on 2025/8/7.
//

import UIKit
import AliyunPlayer

class TutorialVideoSwiftControlView: UIView {
    weak var player: AliPlayer?
    var videoHeight = kFitWidth(200)
    var tutorialId = ""
    private var isPlaying = false
    private var isFullScreen = false
    private var hasCompleted = false
    private var timer: Timer?
    
    private var hideToolWorkItem: DispatchWorkItem?
    private var isToolHidden = false
    
    private var initialBrightness: CGFloat = UIScreen.main.brightness
    private var initialVolume: Float = 1.0
    private var originalRate: Float = 1.0
    private var isAdjustingBrightness = false
    private var isVerticalPan = false
    private var hasDeterminedPanDirection = false
    private var isAwaitingSeekCompletion = false
    private var pendingSeekValue: Float?
    private var pendingSeekPosition: Double?
    private var needsAdditionalSeek = false
    private var isSliderTracking = false
    private var shouldResumeAfterSeek = false
    private var lastExecutedSeekPosition: Double?
    private let seekRequestTolerance: Double = 200
    
    var fullTapBlock:((Bool)->())?
    var backTapBlock:(()->())?
    var shareBlock:(()->())?
    var nextVideoBlock:(()->())?
    var playStatusChanged:((Bool)->())?
    var positionDidUpdate: ((Double, Double) -> Void)?
    var playbackCompleted: (() -> Void)?
    var toolVisibilityChanged: ((Bool) -> Void)?
    var heightChanged:((CGFloat)->())?

    init(player: AliPlayer?,frame:CGRect) {
        self.player = player
        videoHeight = frame.size.height
        super.init(frame: frame)
        self.player?.isAutoPlay = false
        self.player?.delegate = self
        setupUI()
        startTimer()
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        scheduleHideTool()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        startTimer()
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }
    lazy var centerToolVm: PlayerControlCenterToolVM = {
        let vm = PlayerControlCenterToolVM.init(frame: self.bounds)
        vm.playButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        vm.tenForwardButton.addTarget(self, action: #selector(forwardTenTapped), for: .touchUpInside)
        vm.tenBackButton.addTarget(self, action: #selector(backTenTapped), for: .touchUpInside)
        return vm
    }()
    lazy var topToolVm: PlayerControlTopToolVM = {
        let vm = PlayerControlTopToolVM.init(frame: .zero,topSafeArea:kFitWidth(0))
        vm.backBlock = {()in
            if self.isFullScreen{
                self.fullScreenTapped()
            }else{
                self.backTapBlock?()
            }
            
        }
        vm.shareBlock = {()in
            self.shareBlock?()
        }
        
        return vm
    }()
    lazy var bottomToolVm: PlayerControlBottomToolVM = {
        let vm = PlayerControlBottomToolVM.init(frame: self.bounds,bottomSafeArea: kFitWidth(0))
        vm.nextButton.isHidden = true
        vm.fullTapBlock = { [weak self] in
            self?.fullScreenTapped()
            self?.scheduleHideTool()
        }
        vm.nextTapBlock = { [weak self] in
            self?.nextVideoTapped()
            self?.scheduleHideTool()
        }
        vm.rateChanged = { [weak self] rate in
            self?.player?.rate = rate
            self?.scheduleHideTool()
        }
        vm.sliderValueChanged = { [weak self] value in
//            guard let self = self, let player = self.player else { return }
            guard let self = self else { return }
            self.scheduleHideTool()
            guard let player = self.player else { return }
            let duration = player.duration
//            let target = Int64(Float(duration) * value)
            guard duration > 0 else { return }

            let targetPosition = Double(Float(duration) * value)
            self.pendingSeekValue = value
//            self.pendingSeekPosition = Double(target)
//            self.isAwaitingSeekCompletion = true
            self.pendingSeekPosition = targetPosition
            self.bottomToolVm.updateSeekPreview(value: value, total: Double(duration))
//            player.seek(toTime: target, seekMode: AVP_SEEKMODE_ACCURATE)
//            self.scheduleHideTool()
            
            if self.isAwaitingSeekCompletion {
                if let lastPosition = self.lastExecutedSeekPosition,
                   abs(targetPosition - lastPosition) <= self.seekRequestTolerance {
                    self.needsAdditionalSeek = false
                } else {
                    self.needsAdditionalSeek = true
                }
                return
            }

            self.seekToPendingPosition()
        }
        vm.sliderTouchDownBlock = { [weak self] in
//            self?.hideToolWorkItem?.cancel()
//            self?.isAwaitingSeekCompletion = true
            guard let self = self else { return }
            self.hideToolWorkItem?.cancel()
            self.needsAdditionalSeek = false
            self.isSliderTracking = true
            self.shouldResumeAfterSeek = self.isPlaying
            
            if self.isPlaying {
                self.player?.pause()
            }
            if let player = self.player {
                self.lastExecutedSeekPosition = Double(player.currentPosition)
            } else {
                self.lastExecutedSeekPosition = nil
            }
        }
        vm.sliderTouchUpBlock = { [weak self] in
//            self?.scheduleHideTool()
            guard let self = self else { return }
            self.isSliderTracking = false
            if !self.isAwaitingSeekCompletion {
                if self.pendingSeekPosition == nil {
                    if self.shouldResumeAfterSeek {
                        self.player?.start()
                        self.shouldResumeAfterSeek = false
                    }
                } else {
                    self.seekToPendingPosition()
                }
            }
            self.scheduleHideTool()
        }
        return vm
    }()
    private lazy var volumeBrightnessView: ZFVolumeBrightnessView = {
        let view = ZFVolumeBrightnessView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.isHidden = true
        return view
    }()
    private lazy var doubleRateLabel: UILabel = {
        let label = UILabel()
        label.text = "2.0倍速播放中"
        label.textAlignment = .center
        label.layer.cornerRadius = 4.0
        label.clipsToBounds = true
        label.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.isHidden = true
        return label
    }()

    private func setupUI() {
        addSubview(centerToolVm)
        addSubview(topToolVm)
        addSubview(bottomToolVm)
        addSubview(volumeBrightnessView)
        addSubview(doubleRateLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        addGestureRecognizer(longPress)
        
        volumeBrightnessView.addSystemVolumeView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let top = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        volumeBrightnessView.frame = CGRect(x: 0, y: top > 20 ? top + 10 : 30, width: 170, height: 35)
        volumeBrightnessView.center.x = bounds.width / 2
        doubleRateLabel.frame = CGRect(x: (bounds.width - 120) / 2, y: 40, width: 120, height: 26)
        
        let oldFrame = self.frame
        if self.isFullScreen{
            self.frame = CGRect.init(x: 0, y: 0, width: SCREEN_HEIGHT, height: SCREEN_WIDHT)
            self.centerToolVm.frame = CGRect.init(x: 0, y: 0, width: SCREEN_HEIGHT, height: SCREEN_WIDHT)
//            if self.isToolHidden{
//                self.bottomToolVm.center = CGPoint.init(x: self.bounds.width*0.5, y: SCREEN_WIDHT+self.bottomToolVm.selfHeight*0.5)
//            }else{
//                self.bottomToolVm.center = CGPoint.init(x: self.bounds.width*0.5, y: SCREEN_WIDHT-self.bottomToolVm.selfHeight*0.5)
//            }
            self.bottomToolVm.center = CGPoint.init(x: self.bounds.width*0.5, y: SCREEN_WIDHT-self.bottomToolVm.selfHeight*0.5)
        }else{
            self.frame = CGRect.init(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.size.width, height: self.videoHeight)
            self.centerToolVm.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.videoHeight)
//            if self.isToolHidden{
//                self.bottomToolVm.center = CGPoint.init(x: self.bounds.width*0.5, y: self.videoHeight+self.bottomToolVm.selfHeight*0.5)
//            }else{
//                self.bottomToolVm.center = CGPoint.init(x: self.bounds.width*0.5, y: self.videoHeight-self.bottomToolVm.selfHeight*0.5)
//            }
            self.bottomToolVm.center = CGPoint.init(x: self.bounds.width*0.5, y: self.videoHeight-self.bottomToolVm.selfHeight*0.5)
        }
    }

    @objc private func playPauseTapped() {
        guard let player = player else { return }
        scheduleHideTool()
        if isPlaying {
            player.pause()
            centerToolVm.playButton.isSelected = false
        } else {
            if hasCompleted {
                player.seek(toTime: 0, seekMode: AVP_SEEKMODE_ACCURATE)
                hasCompleted = false
            }
            player.start()
            centerToolVm.playButton.isSelected = true
        }
        isPlaying.toggle()
        playStatusChanged?(isPlaying)
    }
    @objc private func forwardTenTapped() {
       guard let player = player else { return }
       let current = player.currentPosition
       let duration = player.duration
       let target = min(duration, current + 10000)
       player.seek(toTime: target, seekMode: AVP_SEEKMODE_ACCURATE)
       scheduleHideTool()
   }

   @objc private func backTenTapped() {
       guard let player = player else { return }
       let current = player.currentPosition
       let target = max(Int64(0), current - 10000)
       player.seek(toTime: target, seekMode: AVP_SEEKMODE_ACCURATE)
       scheduleHideTool()
   }
    @objc private func nextVideoTapped() {
        scheduleHideTool()
        self.nextVideoBlock?()
    }
    @objc private func fullScreenTapped() {
        let value = isFullScreen ? UIInterfaceOrientation.portrait.rawValue : UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        isFullScreen.toggle()
        
        if isFullScreen {
            volumeBrightnessView.removeSystemVolumeView()
        } else {
            
            volumeBrightnessView.addSystemVolumeView()
        }

        bottomToolVm.updateFullScreen(isFull: isFullScreen)
        self.bottomToolVm.nextButton.isHidden = !isFullScreen
        self.topToolVm.updateFrame(isFull: self.isFullScreen)
        self.bottomToolVm.updateFrame(isFull: self.isFullScreen)
        self.centerToolVm.updateFrame(isFull: self.isFullScreen)
        self.fullTapBlock?(self.isFullScreen)
    }
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            let duration = player.duration
            if duration > 0 {
                let position = player.currentPosition
                if let targetValue = self.pendingSeekValue, let targetPosition = self.pendingSeekPosition {
                    let currentPosition = Double(position)
                    let tolerance: Double = 2000 // 2 seconds tolerance in milliseconds
                    if self.isAwaitingSeekCompletion || abs(currentPosition - targetPosition) > tolerance {
                        self.bottomToolVm.updateSeekPreview(value: targetValue, total: Double(duration))
                        return
                    } else {
                        self.pendingSeekValue = nil
                        self.pendingSeekPosition = nil
                        self.isAwaitingSeekCompletion = false
                    }
                }
                if self.pendingSeekValue == nil {
                    self.isAwaitingSeekCompletion = false
                }
                self.bottomToolVm.updateProgress(current: Double(position), total: Double(duration))
            }
        }
    }
    
    
    @objc private func handleTap() {
        toggleTool()
    }

    private func toggleTool() {
        isToolHidden.toggle()
        centerToolVm.setHidden(isToolHidden)
        topToolVm.setHidden(isToolHidden)
        bottomToolVm.setHidden(isToolHidden)
        toolVisibilityChanged?(isToolHidden)
        if isToolHidden {
            hideToolWorkItem?.cancel()
        } else {
            scheduleHideTool()
        }
    }
    private func seekToPendingPosition() {
        guard let player = player,
              let pendingSeekPosition = pendingSeekPosition else {
            needsAdditionalSeek = false
            return
        }

        let duration = Double(player.duration)
        guard duration > 0 else { return }

        let clampedPosition = max(0, min(pendingSeekPosition, duration))
        self.pendingSeekValue = Float(clampedPosition / duration)
        self.pendingSeekPosition = clampedPosition

        needsAdditionalSeek = false
        isAwaitingSeekCompletion = true
        lastExecutedSeekPosition = clampedPosition
        player.seek(toTime: Int64(clampedPosition.rounded()), seekMode: AVP_SEEKMODE_ACCURATE)
    }



    private func scheduleHideTool() {
        hideToolWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.setToolHidden(true)
        }
        hideToolWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: work)
    }
    private func setToolHidden(_ hidden: Bool) {
        isToolHidden = hidden
        centerToolVm.setHidden(hidden)
        topToolVm.setHidden(hidden)
        bottomToolVm.setHidden(hidden)
        toolVisibilityChanged?(hidden)
    }
    
    func showControls() {
        hideToolWorkItem?.cancel()
        setToolHidden(false)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        switch gesture.state {
        case .began:
            initialBrightness = UIScreen.main.brightness
            initialVolume = player?.volume ?? 1.0
            isAdjustingBrightness = location.x < bounds.width / 2
//            let progress = isAdjustingBrightness ? initialBrightness : CGFloat(initialVolume)
//            let type: ZFVolumeBrightnessType = isAdjustingBrightness ? ZFVolumeBrightnessType.typeumeBrightness : ZFVolumeBrightnessType.typeVolume
//            volumeBrightnessView.updateProgress(progress, with: type)
            hasDeterminedPanDirection = false
        case .changed:
            let translation = gesture.translation(in: self)
            if !hasDeterminedPanDirection {
                hasDeterminedPanDirection = true
                isVerticalPan = abs(translation.y) > abs(translation.x)
                if isVerticalPan {
                    let progress = isAdjustingBrightness ? initialBrightness : CGFloat(initialVolume)
                    let type: ZFVolumeBrightnessType = isAdjustingBrightness ? ZFVolumeBrightnessType.typeumeBrightness : ZFVolumeBrightnessType.typeVolume
                    volumeBrightnessView.updateProgress(progress, with: type)
                } else {
                    return
                }
            }
            guard isVerticalPan else { return }
            let delta = -translation.y / bounds.height
            if isAdjustingBrightness {
                let value = max(0, min(1, initialBrightness + delta))
                UIScreen.main.brightness = value
                volumeBrightnessView.updateProgress(value, with: ZFVolumeBrightnessType.typeumeBrightness)
            } else {
                let value = max(0, min(1, initialVolume + Float(delta)))
                player?.volume = value
                volumeBrightnessView.updateProgress(CGFloat(value), with: ZFVolumeBrightnessType.typeVolume)
            }
        default:
            hasDeterminedPanDirection = false
            isVerticalPan = false
            break
        }
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let player = player else { return }
        switch gesture.state {
        case .began:
            originalRate = player.rate
            player.rate = 2.0
            doubleRateLabel.isHidden = false
            setToolHidden(true)
        case .changed:
            player.rate = 2.0
            doubleRateLabel.isHidden = false
            setToolHidden(true)
        case .ended, .cancelled, .failed:
            player.rate = originalRate
            doubleRateLabel.isHidden = true
        default:
            break
        }
    }

    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

extension TutorialVideoSwiftControlView: AVPDelegate {
    func onError(_ player: AliPlayer!, errorModel: AVPErrorModel!) {
        DLLog(message: "AliPlayer error \(errorModel?.code) \(errorModel?.message ?? "")")
        if let message = errorModel?.message, message.contains("ServiceUnavailable") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.player?.prepare()
                self.player?.start()
            }
        }
    }
    func onPlayerEvent(_ player: AliPlayer!, eventType: AVPEventType) {
        DLLog(message: "AliPlayer onPlayerEvent \(eventType)")
        switch eventType {
        case AVPEventPrepareDone:
//            player.start()
            let progress = CourseProgressSQLiteManager.getInstance().queryProgress(tutorialId: self.tutorialId)
//            if progress > 0 {
                self.player?.seek(toTime: Int64(progress * 1000), seekMode: AVP_SEEKMODE_ACCURATE)
//            }else{
//                self.player?.seek(toTime: 0, seekMode: AVP_SEEKMODE_ACCURATE)
//            }
            break
        case AVPEventSeekEnd:
            self.isAwaitingSeekCompletion = false
//            self.player?.start()
            if self.needsAdditionalSeek {
                self.seekToPendingPosition()
            } else {
                if !self.isSliderTracking {
                    if self.shouldResumeAfterSeek {
                        self.player?.start()
                        self.shouldResumeAfterSeek = false
                    }
                }
            }
        case AVPEventFirstRenderedStart:
            isPlaying = true
            centerToolVm.playButton.isSelected = true
            playStatusChanged?(true)
//        case AVPEventFirstRenderedStart:
//            player.pause()
        default:
            break
        }
    }
    func onPlayerStatusChanged(_ player: AliPlayer!, oldStatus: AVPStatus, newStatus: AVPStatus) {
        DLLog(message: "AliPlayer onPlayerStatusChanged \(oldStatus)  ---  \(newStatus)")
        switch newStatus {
        case AVPStatusStarted:
            isPlaying = true
            centerToolVm.playButton.isSelected = true
            hasCompleted = false
//            playStatusChanged?(true)
        case AVPStatusPaused, AVPStatusStopped:
            isPlaying = false
            centerToolVm.playButton.isSelected = false
            playStatusChanged?(false)
        case AVPStatusCompletion:
            isPlaying = false
            centerToolVm.playButton.isSelected = false
            playStatusChanged?(false)
            hasCompleted = true
            playbackCompleted?()
        default:
            break
        }
    }
    func onVideoSizeChanged(_ player: AliPlayer!, width: Int32, height: Int32, rotation: Int32) {
        DLLog(message: "AliPlayer onVideoSizeChanged \(width) - \(height)   ---\(rotation)")
        DispatchQueue.main.async {
            self.videoHeight = CGFloat(CGFloat(height)/CGFloat(width))*SCREEN_WIDHT
            self.heightChanged?(self.videoHeight)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                self.setNeedsLayout()
                self.layoutSubviews()
            })
            
        }
    }
    func onCurrentPositionUpdate(_ player: AliPlayer!, position: Int64) {
        let time = Double(position) / 1000.0
        let duration = Double(player.duration) / 1000.0
        positionDidUpdate?(time, duration)
    }
}
