//
//  PlayerControlBottomToolVM.swift
//  lns
//
//  Created by Elavatine on 2025/8/8.
//


import UIKit

class PlayerControlBottomToolVM: GradientView {

    var selfHeight = kFitWidth(64)//+WHUtils().getBottomSafeAreaHeight()
    var bottomSafe = kFitWidth(0)
    let leftGap = kFitWidth(10)
    
    private var originalFrame: CGRect = .zero

    private(set) var isToolHidden = false
    private var bottomToolAnimator: UIViewPropertyAnimator?

    var sliderValueChanged: ((Float)->Void)?
    var rateChanged: ((Float)->Void)?
    var fullTapBlock:(()->())?
    var nextTapBlock:(()->())?
    var sliderTouchDownBlock:(()->())?
    var sliderTouchUpBlock:(()->())?

    private let rates: [Float] = [1.0, 1.25, 1.5, 2.0]
    private var rateIndex = 0
    private var totalDuration: Double = 0

    init(frame:CGRect,bottomSafeArea:CGFloat?=kFitWidth(0)) {
        bottomSafe = bottomSafeArea ?? kFitWidth(0)
        selfHeight = kFitWidth(64) //+ bottomSafe
        super.init(frame: CGRect(x: 0, y: frame.size.height-selfHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.addGradientBackground(startColor: UIColor.black.withAlphaComponent(0),
                                   endColor: UIColor.black.withAlphaComponent(0.1))
        self.isUserInteractionEnabled = true
        originalFrame = self.frame
        initUI()
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var bottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    lazy var currentTimeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = UIFont.systemFont(ofSize: kFitWidth(14))
        lab.text = "00:00"
        return lab
    }()
    lazy var slider: PlayerSlider = {
        let s = PlayerSlider()
        s.minimumTrackTintColor = .THEME
        s.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        
        let image = UIImage(systemName: "circle.fill")?.withTintColor(.THEME, renderingMode: .alwaysOriginal)

        s.setThumbImage(image, for: .normal)
        s.addTarget(self, action: #selector(sliderValueChangingAction(_:)), for: .valueChanged)
        s.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        s.addTarget(self, action: #selector(sliderTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return s
    }()

    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "tutorial_next_icon"), for: .normal)
        
        btn.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        return btn
    }()
    lazy var rateButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("1.0x", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: kFitWidth(14))
        btn.addTarget(self, action: #selector(rateButtonTapped), for: .touchUpInside)
        return btn
    }()

    lazy var fullScreenButton: UIButton = {
        let btn = UIButton()
//        btn.setTitle("Full", for: .normal)
        btn.setImage(UIImage.init(named: "tutorial_full_screen_icon"), for: .normal)
//        btn.titleLabel?.font = UIFont.systemFont(ofSize: kFitWidth(14))
        btn.addTarget(self, action: #selector(fullScreenTapped), for: .touchUpInside)
        return btn
    }()
}

extension PlayerControlBottomToolVM{
    func initUI(){
        addSubview(bottomView)
        addSubview(currentTimeLabel)
//        addSubview(totalTimeLabel)
        addSubview(slider)
        addSubview(nextButton)
        addSubview(rateButton)
        addSubview(fullScreenButton)
        
        setConstraint()
    }

    func setConstraint(){
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(currentTimeLabel)
        }
        currentTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(leftGap)
            make.top.equalTo(kFitWidth(18))
        }
        fullScreenButton.snp.makeConstraints { make in
            make.right.equalTo(-leftGap)
//            make.top.equalTo(kFitWidth(64))
            make.centerY.lessThanOrEqualTo(currentTimeLabel)
            make.width.equalTo(kFitWidth(32))
            make.height.equalTo(kFitWidth(32))
        }
        nextButton.snp.makeConstraints { make in
            make.right.equalTo(rateButton.snp.left).offset(-leftGap*0.3)
            make.centerY.lessThanOrEqualTo(currentTimeLabel)
            make.width.equalTo(kFitWidth(36.4))
            make.height.equalTo(kFitWidth(32))
        }
        rateButton.snp.makeConstraints { make in
            make.right.equalTo(fullScreenButton.snp.left).offset(-leftGap*0.3)
//            make.top.equalTo(fullScreenButton)
            make.centerY.lessThanOrEqualTo(currentTimeLabel)
            make.width.equalTo(kFitWidth(36.4))
            make.height.equalTo(kFitWidth(32))
        }
        slider.snp.makeConstraints { make in
            make.left.equalTo(currentTimeLabel)
            make.right.equalTo(fullScreenButton)
            make.top.equalTo(kFitWidth(38))
        }
    }
}

extension PlayerControlBottomToolVM{
    func setHidden(_ hidden: Bool){
        if let animator = bottomToolAnimator, animator.isRunning {
            animator.pauseAnimation()
            if let present = self.layer.presentation(){
//                self.transform = CATransform3DGetAffineTransform(present.transform)
                self.alpha = CGFloat(present.opacity)
            }
            animator.stopAnimation(true)
        }
        guard hidden != isToolHidden else { return }
        isToolHidden = hidden
//        let h = self.bounds.height
        self.isUserInteractionEnabled = !hidden
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut){
//            if hidden {
//                self.transform = CGAffineTransform(translationX: 0, y: h)
//            }else{
//                self.transform = .identity
//            }
            self.alpha = hidden ? 0 : 1
        }
        animator.addCompletion{ _ in
            self.bottomToolAnimator = nil
        }
        bottomToolAnimator = animator
        animator.startAnimation()
    }
    func updateProgress(current: Double, total: Double){
        totalDuration = total
        if total > 0 {
            let value = Float(current/total)
            slider.value = value
            currentTimeLabel.text = "\(formatTime(current))/\(formatTime(total))"
        }
    }
    func updateSeekPreview(value: Float, total: Double) {
        guard total > 0 else { return }
        totalDuration = total
        slider.value = value
        let current = Double(value) * total
        currentTimeLabel.text = "\(formatTime(current))/\(formatTime(total))"
    }

    func updateFullScreen(isFull: Bool){
//        let title = isFull ? "Exit" : "Full"
//        fullScreenButton.setTitle(title, for: .normal)
        if isFull{
            self.fullScreenButton.setImage(UIImage.init(named: "tutorial_mini_screen_icon"), for: .normal)
        }else{
            self.fullScreenButton.setImage(UIImage.init(named: "tutorial_full_screen_icon"), for: .normal)
        }
    }

    private func formatTime(_ time: Double) -> String{
        let totalSeconds = Int(time)/1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func updateFrame(isFull: Bool){
        if isFull{
            self.originalFrame = self.frame
            self.fullScreenButton.setImage(UIImage.init(named: "tutorial_mini_screen_icon"), for: .normal)
            self.frame = CGRect(x: 0, y: SCREEN_WIDHT - selfHeight - WHUtils().getTabbarHeight(), width: SCREEN_HEIGHT, height: selfHeight+WHUtils().getTabbarHeight())
            currentTimeLabel.snp.remakeConstraints { make in
                make.left.equalTo(leftGap+WHUtils().getTopSafeAreaHeight())
                make.top.equalTo(kFitWidth(8))
            }
            fullScreenButton.snp.remakeConstraints { make in
                make.right.equalTo(-leftGap-bottomSafe)
                make.centerY.lessThanOrEqualTo(currentTimeLabel)
                make.width.equalTo(kFitWidth(44))
                make.height.equalTo(kFitWidth(44))
            }
        }else{
//            self.frame = CGRect(x: 0, y: self.bounds.height-selfHeight, width: SCREEN_WIDHT, height: selfHeight)
            self.frame = self.originalFrame
            self.fullScreenButton.setImage(UIImage.init(named: "tutorial_full_screen_icon"), for: .normal)
            currentTimeLabel.snp.remakeConstraints { make in
                make.left.equalTo(leftGap)
                make.top.equalTo(kFitWidth(18))
            }
            fullScreenButton.snp.remakeConstraints { make in
                make.right.equalTo(-leftGap)
    //            make.top.equalTo(kFitWidth(64))
                make.centerY.lessThanOrEqualTo(currentTimeLabel)
                make.width.equalTo(kFitWidth(44))
                make.height.equalTo(kFitWidth(44))
            }
        }
    }
    @objc func nothingToDo() {
        
    }
}

extension PlayerControlBottomToolVM{
    @objc private func sliderValueChangingAction(_ sender: UISlider){
        let value = Double(sender.value) * totalDuration
        currentTimeLabel.text = "\(formatTime(value))/\(formatTime(totalDuration))"//formatTime(value)
        sliderValueChanged?(sender.value)
    }

    @objc private func sliderTouchDown(){
        sliderTouchDownBlock?()
    }

    @objc private func sliderTouchUp(_ sender: UISlider){
        sliderValueChanged?(sender.value)
//        sliderTouchDownBlock?()
        sliderTouchUpBlock?()
    }

    @objc private func rateButtonTapped(){
        rateIndex = (rateIndex + 1) % rates.count
        let rate = rates[rateIndex]
        rateButton.setTitle(String(format: "%.1fx", rate), for: .normal)
        rateChanged?(rate)
    }
    func resetRate() {
        rateIndex = 0
        let rate = rates[rateIndex]
        rateButton.setTitle(String(format: "%.1fx", rate), for: .normal)
    }

    @objc private func nextTapped(){
        nextTapBlock?()
    }
    
    @objc private func fullScreenTapped(){
        fullTapBlock?()
    }
}
