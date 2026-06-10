//
//  DietPlanFakeProgressLoadingVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/13.
//

import SnapKit


class DietPlanFakeProgressLoadingVM: UIView {
    struct Config {
        var fakeDuration: TimeInterval = 3.0
        var maxProgressBeforeSuccess: CGFloat = 0.92
        var tickInterval: TimeInterval = 0.05
        var appearDuration: TimeInterval = 0.22
        var finishDuration: TimeInterval = 0.24
        var dismissDelay: TimeInterval = 0.08
        var statusText: String = "创建食谱中..."
        var snapshotBlurRadius: CGFloat = 18
        var tintAlpha: CGFloat = 0.18
        
        func normalized() -> Config {
            var config = self
            config.fakeDuration = max(0.2, config.fakeDuration)
            config.maxProgressBeforeSuccess = min(max(config.maxProgressBeforeSuccess, 0.6), 0.99)
            config.tickInterval = max(0.016, config.tickInterval)
            config.appearDuration = max(0.08, config.appearDuration)
            config.finishDuration = max(0.12, config.finishDuration)
            config.dismissDelay = max(0, config.dismissDelay)
            config.snapshotBlurRadius = max(0, config.snapshotBlurRadius)
            config.tintAlpha = min(max(config.tintAlpha, 0), 0.45)
            return config
        }
    }
    
    private static let ciContext = CIContext(options: nil)
    
    private(set) var config = Config()
    
    private var timer: Timer?
    private var finishTimer: Timer?
    private var startTimestamp: CFTimeInterval = 0
    private var displayedPercent: Int = 0
    private var progressWidthConstraint: Constraint?
    private var successCompletion: (() -> Void)?
    
    private lazy var snapshotImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        return view
    }()
    
    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.COLOR_BG_WHITE.withAlphaComponent(config.tintAlpha)
        return view
    }()
    
    private lazy var progressPercentLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 60, weight: .semibold)
        return lab
    }()
    
    private lazy var progressTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        view.layer.cornerRadius = kFitWidth(4.5)
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var progressFillView: UIView = {
        let view = UIView()
        view.backgroundColor = .THEME
        view.layer.cornerRadius = kFitWidth(4.5)
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var statusLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = config.statusText
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = true
        initUI()
        updateProgressUI(animated: false, animationDuration: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopTimer()
        stopFinishTimer()
    }
    
    func updateConfig(_ config: Config) {
        self.config = config.normalized()
        statusLabel.text = self.config.statusText
        dimView.backgroundColor = UIColor.COLOR_BG_WHITE.withAlphaComponent(self.config.tintAlpha)
    }
    
    func start(on hostView: UIView) {
        let captureView = hostView.window ?? hostView
        snapshotImageView.image = makeBlurredSnapshot(from: captureView)
        
        if superview !== hostView {
            removeFromSuperview()
            hostView.addSubview(self)
            snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        hostView.bringSubviewToFront(self)
        alpha = 0
        displayedPercent = 0
        stopFinishTimer()
        successCompletion = nil
        startTimestamp = CACurrentMediaTime()
        statusLabel.text = config.statusText
        updateProgressUI(animated: false, animationDuration: 0)
        startTimer()
        
        UIView.animate(withDuration: config.appearDuration,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState]) {
            self.alpha = 1
        }
    }
    
    func completeSuccess(completion: (() -> Void)? = nil) {
        stopTimer()
        stopFinishTimer()
        successCompletion = completion
        startFinishTimer()
    }
    
    func completeFailure(completion: (() -> Void)? = nil) {
        stopTimer()
        stopFinishTimer()
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.alpha = 0
        }, completion: { [weak self] _ in
            self?.dismiss()
            completion?()
        })
    }
}

extension DietPlanFakeProgressLoadingVM {
    func initUI() {
        addSubview(snapshotImageView)
        addSubview(blurView)
        addSubview(dimView)
        addSubview(progressPercentLabel)
        addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)
        addSubview(statusLabel)
        
        snapshotImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        progressPercentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-kFitWidth(80))
        }
        
        progressTrackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(progressPercentLabel.snp.bottom).offset(kFitWidth(30))
            make.height.equalTo(kFitWidth(9))
        }
        
        progressFillView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            progressWidthConstraint = make.width.equalTo(0).constraint
        }
        
        statusLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(progressTrackView.snp.bottom).offset(kFitWidth(24))
        }
    }
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: fakeTickInterval(), repeats: true) { [weak self] _ in
            self?.tick()
        }
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func startFinishTimer() {
        stopFinishTimer()
        let remainingSteps = max(100 - displayedPercent, 1)
        let acceleratedTotalDuration = min(max(Double(remainingSteps) * fakeTickInterval() * 0.7, 0.45), 3.5)
        let interval = max(0.016, acceleratedTotalDuration / Double(remainingSteps))
        finishTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.finishTick(animationDuration: min(max(interval * 0.8, 0.02), 0.08))
        }
        if let finishTimer = finishTimer {
            RunLoop.main.add(finishTimer, forMode: .common)
        }
    }

    func stopFinishTimer() {
        finishTimer?.invalidate()
        finishTimer = nil
    }

    func fakeTickInterval() -> TimeInterval {
        let maxPercent = maxPreSuccessPercent
        guard maxPercent > 0 else {
            return config.tickInterval
        }
        let sequentialInterval = config.fakeDuration / Double(maxPercent)
        return max(0.016, min(config.tickInterval, sequentialInterval))
    }

    var maxPreSuccessPercent: Int {
        return min(max(Int((config.maxProgressBeforeSuccess * 100).rounded(.down)), 1), 99)
    }
    
    func tick() {
        guard startTimestamp > 0 else { return }
        let elapsed = CACurrentMediaTime() - startTimestamp
        let progressRatio = min(1, max(0, elapsed / config.fakeDuration))
        let easedRatio = 1 - pow(1 - progressRatio, 2.2)
        let targetPercent = min(Int((CGFloat(maxPreSuccessPercent) * CGFloat(easedRatio)).rounded(.down)),
                                maxPreSuccessPercent)

        guard targetPercent > displayedPercent else {
            if progressRatio >= 1 && displayedPercent >= maxPreSuccessPercent {
                stopTimer()
            }
            return
        }

        displayedPercent += 1
        updateProgressUI(animated: true, animationDuration: min(max(fakeTickInterval() * 0.75, 0.02), 0.08))

        if progressRatio >= 1 && displayedPercent >= maxPreSuccessPercent {
            stopTimer()
        }
    }

    func finishTick(animationDuration: TimeInterval) {
        guard displayedPercent < 100 else {
            stopFinishTimer()
            finishSuccessIfNeeded()
            return
        }

        displayedPercent += 1
        updateProgressUI(animated: true, animationDuration: animationDuration)

        if displayedPercent >= 100 {
            stopFinishTimer()
            finishSuccessIfNeeded()
        }
    }

    func finishSuccessIfNeeded() {
        let completion = successCompletion
        successCompletion = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + config.dismissDelay) { [weak self] in
            self?.dismiss()
            completion?()
        }
    }
    
    func updateProgressUI(animated: Bool, animationDuration: TimeInterval) {
        let percent = min(max(displayedPercent, 0), 100)
        let progressValue = CGFloat(percent) / 100
        progressPercentLabel.text = "\(percent)%"
        
        layoutIfNeeded()
        let trackWidth = max(progressTrackView.bounds.width, SCREEN_WIDHT - kFitWidth(64))
        progressWidthConstraint?.update(offset: trackWidth * progressValue)
        
        if animated {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }
    
    func dismiss() {
        stopTimer()
        stopFinishTimer()
        startTimestamp = 0
        displayedPercent = 0
        successCompletion = nil
        snapshotImageView.image = nil
        removeFromSuperview()
        alpha = 1
    }
    
    func makeBlurredSnapshot(from sourceView: UIView) -> UIImage? {
        sourceView.layoutIfNeeded()
        let renderer = UIGraphicsImageRenderer(bounds: sourceView.bounds)
        let image = renderer.image { _ in
            sourceView.drawHierarchy(in: sourceView.bounds, afterScreenUpdates: false)
        }
        
        guard config.snapshotBlurRadius > 0 else {
            return image
        }
        
        guard let ciImage = CIImage(image: image) else {
            return image
        }
        
        guard let filter = CIFilter(name: "CIGaussianBlur") else {
            return image
        }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(config.snapshotBlurRadius, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter.outputImage else {
            return image
        }
        
        let cropRect = ciImage.extent
        guard let cgImage = Self.ciContext.createCGImage(outputImage, from: cropRect) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
