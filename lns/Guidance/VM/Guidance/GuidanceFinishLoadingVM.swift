//
//  GuidanceFinishLoadingVM.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import UIKit
import SnapKit

class GuidanceFinishLoadingVM: UIView {

    var progressCompleteBlock: (() -> ())?
    var progressTempo: CGFloat = 3.3
    var totalDurationScale: CGFloat = 0.93

    private enum ProgressMode {
        case autoComplete
        case waitForExternalCompletion
    }

    private var progressTimer: Timer?
    private var displayedProgress: CGFloat = 0
    private var progressWidthConstraint: Constraint?
    private var wavePhase: CGFloat = 0
    private var finishHoldRemaining: TimeInterval = 0
    private var lastTickTime: CFTimeInterval = CACurrentMediaTime()
    private var hasNotifiedComplete = false
    private var progressMode: ProgressMode = .autoComplete
    private var externalCompletionRequested = false
    private var loadingStartTime: CFTimeInterval = CACurrentMediaTime()
    private var minimumDisplayDuration: TimeInterval = 0
    private var loadingTitleText = "计划生成中..."
    private var completionTitleText: String?
    private var completionNotifyDelay: TimeInterval = 0
    private var delayedCompletionWorkItem: DispatchWorkItem?

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_WHITE
        isUserInteractionEnabled = true
        alpha = 0
        isHidden = true
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        delayedCompletionWorkItem?.cancel()
        stopFakeProgress()
    }

    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_progress_bg")
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()

    lazy var percentLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 72, weight: .semibold)
        lab.text = "0%"
        return lab
    }()

    lazy var progressTrackView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
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

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "计划生成中..."
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 20, weight: .semibold)
        return lab
    }()

    lazy var subTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "你的数据只属于你。"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        return lab
    }()

    lazy var descLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "我们永远不会出售你的健康数据，也绝不会在未经你同意的情况下与第三方共享。\n\n你可随时删除。"
        return lab
    }()
}

extension GuidanceFinishLoadingVM {
    func configureLoading(titleText: String, completionTitleText: String? = nil, completionNotifyDelay: TimeInterval = 0) {
        loadingTitleText = titleText
        self.completionTitleText = completionTitleText
        self.completionNotifyDelay = completionNotifyDelay
        titleLabel.text = titleText
    }

    func showLoading(waitForExternalCompletion: Bool = false) {
        layer.removeAllAnimations()
        progressMode = waitForExternalCompletion ? .waitForExternalCompletion : .autoComplete
        minimumDisplayDuration = waitForExternalCompletion ? 3.0 : 0
        resetProgress()
        if isHidden {
            alpha = 0
            isHidden = false
        }
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction]) {
            self.alpha = 1
        }
        startFakeProgress()
    }

    func hideLoadingView() {
        guard !isHidden || alpha > 0 else { return }
        layer.removeAllAnimations()
        stopFakeProgress()
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]) {
            self.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }

    private func resetProgress() {
        delayedCompletionWorkItem?.cancel()
        delayedCompletionWorkItem = nil
        displayedProgress = 0
        wavePhase = 0
        finishHoldRemaining = 0
        hasNotifiedComplete = false
        externalCompletionRequested = false
        loadingStartTime = CACurrentMediaTime()
        lastTickTime = CACurrentMediaTime()
        titleLabel.text = loadingTitleText
        updateProgressUI(animated: false)
    }

    func completeLoading() {
        externalCompletionRequested = true
        if progressTimer == nil {
            startFakeProgress()
        }
    }

    private func startFakeProgress() {
        stopFakeProgress()
        lastTickTime = CACurrentMediaTime()
        let interval = max(0.03, 0.08 / Double(max(progressTempo, 0.2)))
        progressTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.tickFakeProgress()
        }
        if let timer = progressTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func stopFakeProgress() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func tickFakeProgress() {
        let now = CACurrentMediaTime()
        let dt = min(max(now - lastTickTime, 0.016), 0.2)
        lastTickTime = now
        let elapsed = now - loadingStartTime
        let speedMultiplier = effectiveSpeedMultiplier()

        if progressMode == .waitForExternalCompletion && !externalCompletionRequested {
            let waitCap = waitingCapProgress(for: elapsed)
            let nextProgress = min(displayedProgress + nextProgressDelta(dt: dt), waitCap)
            displayedProgress = nextProgress
            updateProgressUI(animated: true)
            return
        }

        if progressMode == .waitForExternalCompletion && externalCompletionRequested {
            if elapsed < minimumDisplayDuration {
                let holdCap = completionHoldCapProgress(for: elapsed)
                let nextProgress = min(displayedProgress + nextProgressDelta(dt: dt), holdCap)
                displayedProgress = nextProgress
                updateProgressUI(animated: true)
                return
            }

            let completionBoost = max(1.25, speedMultiplier * 1.15)
            displayedProgress = min(displayedProgress + nextProgressDelta(dt: dt, multiplier: completionBoost), 100)
            updateProgressUI(animated: true)
            if displayedProgress >= 100 {
                stopFakeProgress()
                handleProgressFinished()
            }
            return
        }

        if displayedProgress >= 99 {
            if finishHoldRemaining <= 0 {
                finishHoldRemaining = Double.random(in: 0.45...1.1) / Double(max(progressTempo, 0.2) * speedMultiplier)
            }
            finishHoldRemaining -= dt
            if finishHoldRemaining <= 0 {
                displayedProgress = 100
                updateProgressUI(animated: true)
                stopFakeProgress()
                handleProgressFinished()
                return
            }
            updateProgressUI(animated: true)
            return
        }

        displayedProgress = min(displayedProgress + nextProgressDelta(dt: dt), 99)
        updateProgressUI(animated: true)
    }

    private func effectiveSpeedMultiplier() -> CGFloat {
        return 1.0 / max(totalDurationScale, 0.2)
    }

    private func nextProgressDelta(dt: CFTimeInterval, multiplier: CGFloat = 1) -> CGFloat {
        let baseSpeed = baseSpeedFor(progress: displayedProgress)
        let speed = baseSpeed * multiplier
        wavePhase += CGFloat(dt) * (2.0 + speed * 0.07)
        let waveFactor = 0.74 + 0.34 * CGFloat(sin(Double(wavePhase)))
        let jitter = CGFloat.random(in: -0.18...0.24)
        let factor = max(0.2, waveFactor + jitter)

        var delta = CGFloat(dt) * speed * factor
        let maxDelta = CGFloat(dt) * speed * 1.35
        delta = min(delta, maxDelta)
        return delta
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

    private func waitingCapProgress(for elapsed: TimeInterval) -> CGFloat {
        switch elapsed {
        case ..<0.7:
            return 32
        case ..<1.5:
            return 56
        case ..<2.3:
            return 74
        case ..<3.0:
            return 88
        default:
            return 88
        }
    }

    private func completionHoldCapProgress(for elapsed: TimeInterval) -> CGFloat {
        switch elapsed {
        case ..<1.0:
            return 58
        case ..<1.8:
            return 72
        case ..<2.5:
            return 84
        case ..<3.0:
            return 92
        default:
            return 92
        }
    }

    private func updateProgressUI(animated: Bool) {
        let progress = max(0, min(Int(displayedProgress.rounded(.down)), 100))
        percentLabel.text = "\(progress)%"
        let targetWidth = (SCREEN_WIDHT - kFitWidth(64)) * displayedProgress / 100.0
        progressWidthConstraint?.update(offset: targetWidth)

        if animated {
            UIView.animate(withDuration: 0.16, delay: 0, options: .curveEaseOut) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }

    private func notifyCompleteIfNeeded() {
        guard !hasNotifiedComplete else { return }
        hasNotifiedComplete = true
        progressCompleteBlock?()
    }

    private func handleProgressFinished() {
        if let completionTitleText {
            titleLabel.text = completionTitleText
        }
        if completionNotifyDelay > 0 {
            delayedCompletionWorkItem?.cancel()
            let workItem = DispatchWorkItem { [weak self] in
                self?.notifyCompleteIfNeeded()
            }
            delayedCompletionWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + completionNotifyDelay, execute: workItem)
        } else {
            notifyCompleteIfNeeded()
        }
    }
}

extension GuidanceFinishLoadingVM {
    func initUI() {
        addSubview(bgImgView)
        addSubview(percentLabel)
        addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(descLabel)

        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        percentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(110))
        }

        progressTrackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(percentLabel.snp.bottom).offset(kFitWidth(34))
            make.height.equalTo(kFitWidth(12))
        }

        progressFillView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            progressWidthConstraint = make.width.equalTo(0).constraint
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(40))
            make.top.equalTo(progressTrackView.snp.bottom).offset(kFitWidth(120))
        }

        subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(54))
        }

        descLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(kFitWidth(-40))
            make.top.equalTo(subTitleLabel.snp.bottom).offset(kFitWidth(42))
        }
    }
}
