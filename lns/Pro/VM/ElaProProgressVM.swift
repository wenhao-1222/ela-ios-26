//
//  ElaProProgressVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/3.
//

import UIKit
import SnapKit

class ElaProProgressVM: UIView {
    var backTapBlock: (() -> ())?
    var progressCompleteBlock: (() -> ())?
    /// 进度变化回调，供外部做阈值判断。
    var progressDidChangeBlock: ((Int) -> ())?
    /// 自动进度上限。默认 nil 表示不限制，保持原有最多走到 100% 的行为。
    var automaticProgressLimit: Int? {
        get {
            automaticProgressLimitValue
        }
        set {
            automaticProgressLimitValue = newValue.map { max(0, min($0, 100)) }
            guard let limit = automaticProgressLimitValue,
                  limit < 100,
                  displayedProgress > CGFloat(limit) else {
                return
            }
            displayedProgress = CGFloat(limit)
            currentProgress = limit
            updateProgressUI(animated: false)
        }
    }
    /// 达到自动进度上限后，是否继续慢速递增。默认 nil 表示到上限后停止。
    var automaticProgressSlowIntervalAfterLimit: TimeInterval? {
        get {
            automaticProgressSlowIntervalAfterLimitValue
        }
        set {
            automaticProgressSlowIntervalAfterLimitValue = newValue.map { max(0.1, $0) }
        }
    }
    /// 指定整体进度时长。默认 nil 时沿用原来的随机假进度节奏。
    var progressAnimationDuration: TimeInterval? {
        get {
            progressAnimationDurationValue
        }
        set {
            if let duration = newValue {
                let clampedDuration = max(0.3, duration)
                progressAnimationDurationValue = clampedDuration
                timedProgressElapsed = clampedDuration * TimeInterval(displayedProgress / 100.0)
            } else {
                progressAnimationDurationValue = nil
                timedProgressElapsed = 0
            }
            if progressTimer != nil && currentProgress < 100 {
                stopFakeProgress()
                startFakeProgress()
            }
        }
    }
    /// 是否展示 stepTexts 对应的阶段文案与条目文案。
    var showsStepTexts: Bool = true {
        didSet {
            updateStepTextsVisibility()
        }
    }
    /// 生成中的标题文案，默认沿用原样式。
    var generatingTitleText: String = "正在生成食谱" {
        didSet {
            generatingTitleLabel.text = generatingTitleText
        }
    }
    // 进度节奏系数：1.0 为默认；>1 更快，<1 更慢
    var progressTempo: CGFloat = 3.3 {//2.8 {
        didSet {
            if progressTempo < 0.2 { progressTempo = 0.2 }
            if progressTempo > 8.0 { progressTempo = 8.0 }
            if abs(progressTempo - oldValue) < 0.0001 { return }
            if progressTimer != nil && currentProgress < 100 {
                stopFakeProgress()
                startFakeProgress()
            }
        }
    }
    // 总时长缩放：1.0=当前基准时长，0.5=基准一半时长，2.0=基准两倍时长
    var totalDurationScale: CGFloat = 0.93 {//1.15 {
        didSet {
            if totalDurationScale < 0.2 { totalDurationScale = 0.2 }
            if totalDurationScale > 3.0 { totalDurationScale = 3.0 }
            if abs(totalDurationScale - oldValue) < 0.0001 { return }
            if progressTimer != nil && currentProgress < 100 {
                stopFakeProgress()
                startFakeProgress()
            }
        }
    }
    
    private var progressTimer: Timer?
    private var currentProgress = 0
    private var displayedProgress: CGFloat = 0
    private var progressWidthConstraint: Constraint?
    private var wavePhase: CGFloat = 0
    private var stallRemaining: TimeInterval = 0
    private var finishHoldRemaining: TimeInterval = 0
    private var timedProgressElapsed: TimeInterval = 0
    private var progressAnimationDurationValue: TimeInterval?
    private var automaticProgressLimitValue: Int?
    private var automaticProgressSlowIntervalAfterLimitValue: TimeInterval?
    private var automaticProgressSlowElapsed: TimeInterval = 0
    private var lastTickTime: CFTimeInterval = CACurrentMediaTime()
    private var hasNotifiedComplete = false
    
    private let stepTexts = [
        "分析你的饮食习惯",
        "匹配你的口味偏好",
        "识别潜在的执行阻碍",
        "选择最适合你的饮食策略",
        "生成最终计划"
    ]
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopFakeProgress()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            stopFakeProgress()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_progress_bg")
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()
    
    lazy var progressPercentLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 72, weight: .semibold)
        return lab
    }()
    
    lazy var progressTrackView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE//WHColor_16(colorStr: "ECECEF")
        vi.layer.cornerRadius = kFitWidth(6)
        vi.clipsToBounds = true
        return vi
    }()
    
    lazy var progressFillView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(6)
        vi.clipsToBounds = true
        return vi
    }()
    
    lazy var currentStageLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .center
        return lab
    }()
    
    lazy var generatingTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = generatingTitleText
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .regular)
        return lab
    }()
    
    lazy var itemLabel1 = makeProgressItemLabel(index: 0)
    lazy var itemLabel2 = makeProgressItemLabel(index: 1)
    lazy var itemLabel3 = makeProgressItemLabel(index: 2)
    lazy var itemLabel4 = makeProgressItemLabel(index: 3)
    lazy var itemLabel5 = makeProgressItemLabel(index: 4)
    
    private func makeProgressItemLabel(index: Int) -> UILabel {
        let lab = UILabel()
        lab.text = "· \(stepTexts[index])"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 18, weight: .regular)
        return lab
    }
}

extension ElaProProgressVM {
    // 提供给外部动态修改整体时长
    func updateTotalDurationScale(_ scale: CGFloat) {
        totalDurationScale = scale
    }
    
    private func effectiveSpeedMultiplier() -> CGFloat {
        return 1.0 / max(totalDurationScale, 0.2)
    }
    
    private func startFakeProgress() {
        if progressTimer != nil || currentProgress >= 100 { return }
        lastTickTime = CACurrentMediaTime()
        let interval = max(0.03, 0.08 / Double(max(progressTempo, 0.2)))
        progressTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.tickFakeProgress()
        }
        RunLoop.main.add(progressTimer!, forMode: .common)
    }
    
    private func stopFakeProgress() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    func startProgressAnimation() {
        updateProgressUI(animated: true)
        startFakeProgress()
    }

    func pauseProgressAnimation() {
        stopFakeProgress()
    }

    func setFakeProgress(_ progress: Int, animated: Bool = true) {
        currentProgress = max(0, min(progress, 100))
        displayedProgress = CGFloat(currentProgress)
        if let duration = progressAnimationDuration {
            timedProgressElapsed = duration * TimeInterval(displayedProgress / 100.0)
        }
        stallRemaining = 0
        finishHoldRemaining = 0
        automaticProgressSlowElapsed = 0
        hasNotifiedComplete = currentProgress >= 100
        updateProgressUI(animated: animated)
        if currentProgress >= 100 {
            stopFakeProgress()
        }
    }

    func finishProgressAnimation(duration: TimeInterval = 0.35) {
        automaticProgressLimit = nil
        if currentProgress >= 100 {
            notifyProgressCompletedIfNeeded()
            return
        }

        let clampedDuration = max(0.1, duration)
        let progressRatio = TimeInterval(max(0, min(displayedProgress, 99.0)) / 100.0)
        let remainingRatio = max(0.01, 1.0 - progressRatio)
        let totalDuration = clampedDuration / remainingRatio
        progressAnimationDurationValue = totalDuration
        timedProgressElapsed = totalDuration * progressRatio
        stallRemaining = 0
        finishHoldRemaining = 0
        automaticProgressSlowElapsed = 0
        stopFakeProgress()
        startFakeProgress()
    }

    func resetProgressState() {
        stopFakeProgress()
        currentProgress = 0
        displayedProgress = 0
        stallRemaining = 0
        finishHoldRemaining = 0
        timedProgressElapsed = 0
        automaticProgressSlowElapsed = 0
        wavePhase = 0
        hasNotifiedComplete = false
        updateProgressUI(animated: false)
    }
    
    private func tickFakeProgress() {
        let now = CACurrentMediaTime()
        let dt = min(max(now - lastTickTime, 0.016), 0.2)
        lastTickTime = now
        
        if let duration = progressAnimationDuration {
            tickTimedProgress(dt: dt, duration: duration)
            return
        }
        
        let speedMultiplier = effectiveSpeedMultiplier()
        let automaticLimit = automaticProgressLimitValue ?? 100
        let maxRunningProgress = CGFloat(min(automaticLimit, 99))

        if automaticLimit < 100, displayedProgress >= CGFloat(automaticLimit) {
            tickSlowProgressAfterLimit(dt: dt, limit: automaticLimit)
            return
        }
        
        if displayedProgress >= 99 {
            if finishHoldRemaining <= 0 {
                finishHoldRemaining = Double.random(in: 0.45...1.1) / Double(max(progressTempo, 0.2) * speedMultiplier)
            }
            finishHoldRemaining -= dt
            if finishHoldRemaining <= 0 {
                displayedProgress = 100
                currentProgress = 100
                updateProgressUI(animated: true)
                stopFakeProgress()
                notifyProgressCompletedIfNeeded()
                return
            }
            updateProgressUI(animated: true)
            return
        }
        
        if stallRemaining > 0 {
            stallRemaining -= dt
            displayedProgress = min(displayedProgress + CGFloat(dt * 0.15) * speedMultiplier, maxRunningProgress)
            updateProgressUI(animated: true)
            stopAtAutomaticLimitIfNeeded()
            return
        }
        
        let baseSpeed = baseSpeedFor(progress: displayedProgress)
        wavePhase += CGFloat(dt) * (2.0 + baseSpeed * 0.07)
        let waveFactor = 0.74 + 0.34 * CGFloat(sin(Double(wavePhase)))
        let jitter = CGFloat.random(in: -0.18...0.24)
        let factor = max(0.2, waveFactor + jitter)
        
        var delta = CGFloat(dt) * baseSpeed * factor
        let maxDelta = CGFloat(dt) * baseSpeed * 1.35
        delta = min(delta, maxDelta)
        displayedProgress = min(displayedProgress + delta, maxRunningProgress)
        
        if shouldPause(progress: displayedProgress) {
            stallRemaining = Double.random(in: 0.18...0.6) / Double(max(progressTempo, 0.2) * speedMultiplier)
        }
        
        updateProgressUI(animated: true)
        stopAtAutomaticLimitIfNeeded()
    }
    
    private func tickTimedProgress(dt: TimeInterval, duration: TimeInterval) {
        timedProgressElapsed += dt
        let automaticLimit = automaticProgressLimitValue ?? 100
        if automaticLimit < 100,
           let slowInterval = automaticProgressSlowIntervalAfterLimitValue {
            let clampedDuration = max(duration, 0.3)
            let limitStartTime = clampedDuration * TimeInterval(CGFloat(automaticLimit) / 100.0)
            if timedProgressElapsed <= limitStartTime {
                displayedProgress = min(CGFloat(timedProgressElapsed / clampedDuration) * 100.0, CGFloat(automaticLimit))
            } else {
                let slowSteps = floor((timedProgressElapsed - limitStartTime) / slowInterval)
                displayedProgress = min(CGFloat(automaticLimit) + CGFloat(slowSteps), 99)
            }
        } else {
            displayedProgress = min(CGFloat(timedProgressElapsed / max(duration, 0.3)) * 100.0, CGFloat(automaticLimit))
        }
        currentProgress = max(0, min(Int(displayedProgress.rounded(.down)), 100))
        updateProgressUI(animated: true)
        
        if displayedProgress >= 100 {
            stopFakeProgress()
            notifyProgressCompletedIfNeeded()
        } else if automaticLimit < 100,
                  automaticProgressSlowIntervalAfterLimitValue != nil,
                  displayedProgress >= 99 {
            stopFakeProgress()
        } else {
            stopAtAutomaticLimitIfNeeded()
        }
    }

    private func stopAtAutomaticLimitIfNeeded() {
        guard let automaticLimit = automaticProgressLimitValue,
              automaticLimit < 100,
              automaticProgressSlowIntervalAfterLimitValue == nil,
              displayedProgress >= CGFloat(automaticLimit) else {
            return
        }
        displayedProgress = CGFloat(automaticLimit)
        currentProgress = automaticLimit
        stopFakeProgress()
    }

    private func tickSlowProgressAfterLimit(dt: TimeInterval, limit: Int) {
        guard let slowInterval = automaticProgressSlowIntervalAfterLimitValue else {
            displayedProgress = CGFloat(limit)
            currentProgress = limit
            updateProgressUI(animated: true)
            stopFakeProgress()
            return
        }

        automaticProgressSlowElapsed += dt
        let slowSteps = floor(automaticProgressSlowElapsed / slowInterval)
        displayedProgress = min(CGFloat(limit) + CGFloat(slowSteps), 99)
        currentProgress = max(0, min(Int(displayedProgress.rounded(.down)), 99))
        updateProgressUI(animated: true)

        if displayedProgress >= 99 {
            stopFakeProgress()
        }
    }
    
    private func baseSpeedFor(progress: CGFloat) -> CGFloat {
        let tempo = max(progressTempo, 0.2) * effectiveSpeedMultiplier()
        switch progress {
        case 0..<20:
            return 6.0 * tempo
        case 20..<45:
            return 5.2 * tempo
        case 45..<70:
            return 4.0 * tempo
        case 70..<85:
            return 2.3 * tempo
        case 85..<95:
            return 1.7 * tempo
        default:
            return 1 * tempo
        }
    }
    
    private func shouldPause(progress: CGFloat) -> Bool {
        let roll = Int.random(in: 0...100)
        switch progress {
        case 0..<25:
            return roll < 6
        case 25..<55:
            return roll < 9
        case 55..<80:
            return roll < 12
        case 80..<95:
            return roll < 15
        default:
            return roll < 25
        }
    }
    
    private func updateProgressUI(animated: Bool) {
        currentProgress = max(0, min(Int(displayedProgress.rounded(.down)), 100))
        progressPercentLabel.text = "\(currentProgress)%"
        
        if showsStepTexts {
            let stageText = stageTextForCurrentProgress()
            currentStageLabel.text = "\(stageText)..."
        }
        
        updateStepTextsVisibility()
        if showsStepTexts {
            let completeCount = completedStepCount()
            let labels = [itemLabel1, itemLabel2, itemLabel3, itemLabel4, itemLabel5]
            for (index, label) in labels.enumerated() {
                label.textColor = index < completeCount ? .COLOR_TEXT_TITLE_0f1214 : .COLOR_TEXT_TITLE_0f1214_50
            }
        }
        
        let targetWidth = (SCREEN_WIDHT - kFitWidth(64)) * displayedProgress / 100.0
        progressWidthConstraint?.update(offset: targetWidth)
        
        if animated {
            UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
        progressDidChangeBlock?(currentProgress)
    }

    var progressValue: Int {
        currentProgress
    }
    
    private func notifyProgressCompletedIfNeeded() {
        guard !hasNotifiedComplete else { return }
        hasNotifiedComplete = true
        progressCompleteBlock?()
    }
    
    private func stageTextForCurrentProgress() -> String {
        switch currentProgress {
        case 0...24:
            return stepTexts[0]
        case 25...44:
            return stepTexts[1]
        case 45...64:
            return stepTexts[2]
        case 65...84:
            return stepTexts[3]
        default:
            return stepTexts[4]
        }
    }
    
    private func completedStepCount() -> Int {
        switch currentProgress {
        case 0..<20:
            return 0
        case 20..<40:
            return 1
        case 40..<60:
            return 2
        case 60..<80:
            return 3
        case 80..<100:
            return 4
        default:
            return 5
        }
    }

    private func updateStepTextsVisibility() {
        let hidden = !showsStepTexts
        itemLabel1.isHidden = hidden
        itemLabel2.isHidden = hidden
        itemLabel3.isHidden = hidden
        itemLabel4.isHidden = hidden
        itemLabel5.isHidden = hidden
    }
}

extension ElaProProgressVM {
    func initUI() {
        addSubview(bgImgView)
        addSubview(progressPercentLabel)
        addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)
        addSubview(currentStageLabel)
        addSubview(generatingTitleLabel)
        addSubview(itemLabel1)
        addSubview(itemLabel2)
        addSubview(itemLabel3)
        addSubview(itemLabel4)
        addSubview(itemLabel5)
        
        setConstrait()
    }
    
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        progressPercentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(130))
        }
        
        progressTrackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(progressPercentLabel.snp.bottom).offset(kFitWidth(36))
            make.height.equalTo(kFitWidth(12))
        }
        
        progressFillView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            progressWidthConstraint = make.width.equalTo(0).constraint
        }
        
        currentStageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(progressTrackView.snp.bottom).offset(kFitWidth(32))
        }
        
        generatingTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(50))
            make.top.equalTo(currentStageLabel.snp.bottom).offset(kFitWidth(86))
        }
        
        itemLabel1.snp.makeConstraints { make in
            make.left.equalTo(generatingTitleLabel.snp.left)
            make.top.equalTo(generatingTitleLabel.snp.bottom).offset(kFitWidth(30))
        }
        itemLabel2.snp.makeConstraints { make in
            make.left.equalTo(itemLabel1)
            make.top.equalTo(itemLabel1.snp.bottom).offset(kFitWidth(22))
        }
        itemLabel3.snp.makeConstraints { make in
            make.left.equalTo(itemLabel1)
            make.top.equalTo(itemLabel2.snp.bottom).offset(kFitWidth(22))
        }
        itemLabel4.snp.makeConstraints { make in
            make.left.equalTo(itemLabel1)
            make.top.equalTo(itemLabel3.snp.bottom).offset(kFitWidth(22))
        }
        itemLabel5.snp.makeConstraints { make in
            make.left.equalTo(itemLabel1)
            make.top.equalTo(itemLabel4.snp.bottom).offset(kFitWidth(22))
        }
    }
}
