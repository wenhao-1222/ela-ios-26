//
//  PlayerControlCenterToolVM.swift
//  lns
//
//  Created by Elavatine on 2025/8/8.
//


import UIKit

class PlayerControlCenterToolVM: GradientView {
    
    private var centerToolAnimator: UIViewPropertyAnimator?
    private(set) var isToolHidden = false
    private var originalFrame: CGRect = .zero
    
    private var playBtnWidth = kFitWidth(54)
    private var btnGap = kFitWidth(5)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = UIColor.black.withAlphaComponent(0.1)
//        self.addGradientBackground(startColor: UIColor.black.withAlphaComponent(0.05),
//                                   endColor: UIColor.black.withAlphaComponent(0.05))
        self.isUserInteractionEnabled = true
        self.originalFrame = self.frame
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var tenForwardButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "tutorial_forward_10_seconds"), for: .normal)
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        
        return btn
    }()
    lazy var tenBackButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "tutorial_back_10_seconds"), for: .normal)
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        
        return btn
    }()
    lazy var playButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "video_play_icon_1"), for: .normal)
        btn.setImage(UIImage(named: "video_pause_icon_1"), for: .selected)
        
        return btn
    }()
}

extension PlayerControlCenterToolVM{
    func setHidden(_ hidden: Bool) {
        if let animator = centerToolAnimator, animator.isRunning {
            animator.pauseAnimation()
            if let present = self.layer.presentation() {
                self.transform = CATransform3DGetAffineTransform(present.transform)
            }
            animator.stopAnimation(true)
        }
        
        guard hidden != isToolHidden else { return }
        isToolHidden = hidden

        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
            if hidden {
                self.backgroundColor = UIColor.black.withAlphaComponent(0)
                self.playButton.alpha = 0
                self.tenBackButton.alpha = 0
                self.tenForwardButton.alpha = 0
            } else {
                self.backgroundColor = UIColor.black.withAlphaComponent(0.15)
                self.playButton.alpha = 1
                self.tenBackButton.alpha = 1
                self.tenForwardButton.alpha = 1
            }
        }
        animator.addCompletion { _ in
            self.centerToolAnimator = nil
        }
        centerToolAnimator = animator
        animator.startAnimation()
    }
}

extension PlayerControlCenterToolVM{
    func initUI() {
        addSubview(playButton)
        addSubview(tenBackButton)
        addSubview(tenForwardButton)
        tenBackButton.layer.cornerRadius = (playBtnWidth-btnGap)*0.5
        tenForwardButton.layer.cornerRadius = (playBtnWidth-btnGap)*0.5
        setConstrait()
    }
    func setConstrait() {
        playButton.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.height.equalTo(playBtnWidth)
        }
        tenBackButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(playButton.snp.left).offset(kFitWidth(-48))
            make.width.height.equalTo(playButton).offset(-btnGap)
        }
        tenForwardButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(playButton.snp.right).offset(kFitWidth(48))
            make.width.height.equalTo(playButton).offset(-btnGap)
        }
    }
    func updateFrame(isFull: Bool){
        if isFull{
            playBtnWidth = kFitWidth(70)
            btnGap = kFitWidth(6)
            self.originalFrame = self.frame
            self.frame = CGRect(x: 0, y: 0, width: SCREEN_HEIGHT, height: SCREEN_WIDHT)
            playButton.setImage(UIImage.init(named: "video_play_icon_landscap_1"), for: .normal)
            playButton.setImage(UIImage.init(named: "video_pause_icon_landscap_1"), for: .selected)
            playButton.snp.remakeConstraints { make in
                make.center.lessThanOrEqualToSuperview()
                make.width.height.equalTo(playBtnWidth)
            }
            tenBackButton.snp.remakeConstraints { make in
                make.centerY.lessThanOrEqualToSuperview()
                make.right.equalTo(playButton.snp.left).offset(kFitWidth(-80))
                make.width.height.equalTo(playButton).offset(-btnGap)
            }
            tenForwardButton.snp.remakeConstraints { make in
                make.centerY.lessThanOrEqualToSuperview()
                make.left.equalTo(playButton.snp.right).offset(kFitWidth(80))
                make.width.height.equalTo(playButton).offset(-btnGap)
            }
//            tenBackButton.layer.cornerRadius = kFitWidth(32)
//            tenForwardButton.layer.cornerRadius = kFitWidth(32)
        }else{
            playBtnWidth = kFitWidth(54)
            btnGap = kFitWidth(4)
//            self.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
            self.frame = originalFrame
            playButton.setImage(UIImage(named: "video_play_icon_1"), for: .normal)
            playButton.setImage(UIImage(named: "video_pause_icon_1"), for: .selected)
            playButton.snp.makeConstraints { make in
                make.center.lessThanOrEqualToSuperview()
                make.width.height.equalTo(kFitWidth(54))
            }
            tenBackButton.snp.remakeConstraints { make in
                make.centerY.lessThanOrEqualToSuperview()
                make.right.equalTo(playButton.snp.left).offset(kFitWidth(-48))
                make.width.height.equalTo(playButton).offset(-btnGap)
            }
            tenForwardButton.snp.remakeConstraints { make in
                make.centerY.lessThanOrEqualToSuperview()
                make.left.equalTo(playButton.snp.right).offset(kFitWidth(48))
                make.width.height.equalTo(playButton).offset(-btnGap)
            }
//            tenBackButton.layer.cornerRadius = kFitWidth(24)
//            tenForwardButton.layer.cornerRadius = kFitWidth(24)
        }
        tenBackButton.layer.cornerRadius = (playBtnWidth-btnGap)*0.5
        tenForwardButton.layer.cornerRadius = (playBtnWidth-btnGap)*0.5
    }
}
