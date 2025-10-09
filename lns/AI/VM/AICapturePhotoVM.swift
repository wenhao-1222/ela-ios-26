//
//  AICapturePhotoVM.swift
//  lns
//  拍完照之后，显示照片的页面
//  Created by Elavatine on 2025/3/7.
//  

class AICapturePhotoVM: UIView {
    
    var closeBlock:(()->())?
    var completeBlock:(()->())?
    
    private var timer: Timer?
    public var currentProgress: CGFloat = 0
    private var maxSimulatedProgress: CGFloat = 0.92 // 最大模拟进度
    public var maxSimulatedProgressPause: CGFloat = 0.92 // 最大模拟进度   弹出取消识别时的最大进度
    
    var currentTaskId = ""
    
    // 配置参数
    private let baseAnimationDuration = 1.5
    private let completionAnimationDuration = 0.3
    
    
    private var cropFrame = CGRect(x: kFitWidth(55), y:WHUtils().getNavigationBarHeight()+kFitWidth(80), width: kFitWidth(265), height: kFitWidth(359)) // 自定义取景框尺寸
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .white.withAlphaComponent(0.5)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        self.isHidden = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
//        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFill
        return img
    }()
    lazy var closeImgView : FeedBackUIImageView = {
        let img = FeedBackUIImageView()
        img.setImgLocal(imgName: "ai_progress_cancel_icon")
        img.isUserInteractionEnabled = true
        img.alpha = 0
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(closeAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var statusLabel: UILabel = {
        let lab = UILabel()
        lab.text = "食物识别中"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    lazy var successIconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ai_progress_complete_icon")
        img.isHidden = true
        return img
    }()
    lazy var progressView: AIGradientProgressView = {
        let vi = AIGradientProgressView.init(frame: CGRect.init(x: kFitWidth(87), y: 0, width: kFitWidth(200), height: kFitHeight(20)))
//        vi.progress = 0.01
        return vi
    }()
    lazy var progressLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 15, weight: .semibold)
        
        return lab
    }()
    lazy var rippleView: SolidRippleView = {
        let vi = SolidRippleView(frame: CGRect.init(x: 0, y: cropFrame.minY+cropFrame.height*0.5, width: SCREEN_WIDHT, height: SCREEN_WIDHT))
//        vi.backgroundColor = .white.withAlphaComponent(0.5)
        return vi
    }()
//    lazy var rippleView: RippleAnimationView = {
//        let vi = RippleAnimationView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_WIDHT))
//        return vi
//    }()
}

extension AICapturePhotoVM{
    func showView(img:UIImage) {
        self.bgImgView.image = img
        self.bgImgView.alpha = 1
        self.successIconImgView.isHidden = true
        self.isHidden = false
        rippleView.startAnimation()
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.closeImgView.alpha = 1
        }
    }
    func hiddenView() {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.closeImgView.alpha = 0.2
            self.bgImgView.alpha = 0.2
        }completion: { t in
            self.isHidden = true
        }
    }
    func calculateComplete() {
        statusLabel.text = "计算完成"
        successIconImgView.isHidden = false
    }
    @objc func closeAction() {
        self.closeBlock?()
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.7, execute: {
//            self.resetProgress()
//        })
    }
}

extension AICapturePhotoVM{
    func initUI() {
        addSubview(bgImgView)
        addSubview(rippleView)
        addSubview(closeImgView)
        addSubview(statusLabel)
        addSubview(successIconImgView)
        addSubview(progressView)
        addSubview(progressLabel)
        
        setConstrait()
//        rippleView.refreshCenter(y: cropFrame.minY)
//        rippleView.center = CGPoint(x: cropFrame.midX, y: cropFrame.midY)
        rippleView.center = CGPoint(x: SCREEN_WIDHT*0.5, y: cropFrame.midY)
    }
    func setConstrait() {
        let bottomGapHeight = (SCREEN_HEIGHT-WHUtils().getBottomSafeAreaHeight()-kFitHeight(26)-kFitHeight(68)) - cropFrame.maxY
        progressView.center = CGPoint(x: SCREEN_WIDHT*0.5, y: cropFrame.maxY+bottomGapHeight*0.65)
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        closeImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitHeight(68))
            make.top.equalTo(SCREEN_HEIGHT-WHUtils().getBottomSafeAreaHeight()-kFitHeight(26)-kFitHeight(68))
        }
        statusLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(cropFrame.maxY+bottomGapHeight*0.3)
        }
        successIconImgView.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(statusLabel)
            make.left.equalTo(statusLabel.snp.right).offset(kFitWidth(4))
        }
        
        progressLabel.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(progressView)
        }
    }
}


extension AICapturePhotoVM{
    // MARK: - 公开方法
    func startSimulation() {
        statusLabel.text = "食物识别中"
        self.closeImgView.isUserInteractionEnabled = true
        resetProgress()
        startSmartSimulation()
    }
    
    func completeWithSuccess() {
        animateToFullProgress()
        scheduleHide()
    }
    
    func completeWithFailure(failType:String="1") {//1  图片上传失败
        cancelSimulation()
//        progressView.isHidden = true
        progressLabel.text = ""
//        if failType == "1"{
//            statusLabel.text = "网络不佳，AI识别服务错误"
//        }else if failType == "2"{
//            statusLabel.text = "AI识别服务错误"
//        }
        statusLabel.text = "识别失败"
        progressView.updateProgressColor(isFail: true)
    }
    
    private func startSmartSimulation() {
        progressView.isHidden = false
        currentProgress = 0
        
        // 智能分段模拟算法
        //本地最大进度，随机数 0.45 ~  0.9
        let mediumProgressInt = arc4random()%25+25
        let mediumProgress = CGFloat(mediumProgressInt)*0.01
        maxSimulatedProgress = CGFloat((arc4random()%mediumProgressInt+mediumProgressInt))*0.01
        maxSimulatedProgressPause = maxSimulatedProgress
        let phases = [
            (duration: 0.5, target: 0.25),  // 快速初始阶段
            (duration: 1.0, target: mediumProgress),  // 中等速度阶段
            (duration: 1.5, target: maxSimulatedProgress) // 缓慢接近阶段
        ]
        // 智能分段模拟算法
//        let phases = [
//            (duration: 0.5, target: 0.25),  // 快速初始阶段
//            (duration: 1.0, target: 0.65),  // 中等速度阶段
//            (duration: 1.5, target: maxSimulatedProgress) // 缓慢接近阶段
//        ]
        phases.forEach { phase in
            DispatchQueue.main.asyncAfter(deadline: .now() + phase.duration) { [weak self] in
                self?.animateProgress(to: phase.target, duration: phase.duration * 0.95)
            }
        }
    }
    private func animateProgress(to target: CGFloat, duration: TimeInterval) {
        guard currentProgress < maxSimulatedProgressPause else { return }
        DLLog(message: "animateProgress:\(target)   ----   \(maxSimulatedProgress)")
        let clampedTarget = min(target, maxSimulatedProgress)
        progressView.setProgress(clampedTarget, animated: true, duration: duration)
        currentProgress = clampedTarget
        DispatchQueue.main.asyncAfter(deadline: .now()+duration, execute: {
            self.progressLabel.text = String(format: "%.0f%%", self.currentProgress*100)
        })
    }
        
    private func animateToFullProgress() {
        cancelSimulation()
        
        // 最后冲刺动画
        let remaining = 1.0 - currentProgress
        let duration = TimeInterval(remaining) * completionAnimationDuration
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            self.progressView.setProgress(1.0, animated: true)
        }completion: { t in
//            self.currentProgress = 1
            self.progressLabel.text = "100%"
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                self.completeBlock?()
            })
        }
    }
    
    public func cancelSimulation() {
        timer?.invalidate()
        timer = nil
    }
    public func resetProgress() {
        progressView.progress = 0
        progressLabel.text = "0%"
        currentProgress = 0
        progressView.updateProgressColor(isFail: false)
    }
    private func scheduleHide() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIView.animate(withDuration: 0.3) {
                self.progressView.alpha = 0
            } completion: { _ in
                self.progressView.isHidden = true
                self.progressView.alpha = 1
                self.resetProgress()
            }
        }
    }
}
