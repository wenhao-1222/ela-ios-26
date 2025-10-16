//
//  PlayerControlTopToolVM.swift
//  lns
//
//  Created by Elavatine on 2025/8/8.
//


class PlayerControlTopToolVM: GradientView {
    
    var selfHeight = kFitWidth(64)//+WHUtils().getTopSafeAreaHeight()
    var topSafe = kFitWidth(0)
    let leftGap = kFitWidth(10)
    
    var backBlock:(()->())?
    var shareBlock:(()->())?
    private(set) var isToolHidden = false
    private var topToolAnimator: UIViewPropertyAnimator?
    
    init(frame:CGRect,topSafeArea:CGFloat?=kFitWidth(0)) {
        topSafe = topSafeArea ?? kFitWidth(0)
        selfHeight = kFitWidth(64) + topSafe
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
//        self.addGradientBackground(startColor: UIColor.black.withAlphaComponent(0.35),
//                                   endColor: UIColor.black.withAlphaComponent(0.01))
        self.addGradientBackground(startColor: UIColor.black.withAlphaComponent(0.1),
                                   endColor: UIColor.black.withAlphaComponent(0))
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    
//    override init(frame:CGRect,topSafeArea:CGFloat?=kFitWidth(0)){
//        topSafe = topSafeArea
//        selfHeight = kFitWidth(112) + topSafe
//        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
//        self.addGradientBackground(startColor: UIColor.black.withAlphaComponent(0.5),
//                                   endColor: UIColor.black.withAlphaComponent(0.01))
//        self.isUserInteractionEnabled = true
//        
//        initUI()
//        
//    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "back_arrow_white_icon_max"), for: .normal)
        
        btn.addTarget(self, action: #selector(backTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var shareButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "tutorial_share_icon"), for: .normal)
        
        btn.addTarget(self, action: #selector(shareTapAction), for: .touchUpInside)
        
        return btn
    }()
}

extension PlayerControlTopToolVM{
    @objc func backTapAction() {
        self.backBlock?()
    }
    @objc func shareTapAction() {
        self.shareBlock?()
    }
    
    func setHidden(_ hidden: Bool) {
        if let animator = topToolAnimator, animator.isRunning {
            animator.pauseAnimation()
            if let present = self.layer.presentation() {
//                self.transform = CATransform3DGetAffineTransform(present.transform)
                self.alpha = CGFloat(present.opacity)
            }
            animator.stopAnimation(true)
        }
        
        guard hidden != isToolHidden else { return }
        isToolHidden = hidden
//        let h = self.bounds.height
        self.isUserInteractionEnabled = !hidden
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
//            if hidden {
//                self.transform = CGAffineTransform(translationX: 0, y: -h)
//            } else {
//                self.transform = .identity
//            }
            self.alpha = hidden ? 0 : 1
        }
        animator.addCompletion { _ in
            self.topToolAnimator = nil
        }
        topToolAnimator = animator
        animator.startAnimation()
    }
}

extension PlayerControlTopToolVM{
    func initUI() {
        addSubview(backButton)
        addSubview(shareButton)
        
        setConstrait()
    }
    func setConstrait() {
        backButton.snp.makeConstraints { make in
            make.left.equalTo(leftGap)
            make.bottom.equalTo(kFitWidth(-20))
//            make.bottom.equalTo(kFitWidth(-64))
            make.width.height.equalTo(kFitWidth(44))
        }
        shareButton.snp.makeConstraints { make in
            make.right.equalTo(-leftGap)
//            make.bottom.equalTo(kFitWidth(-64))
            make.centerY.lessThanOrEqualTo(backButton)
            make.width.height.equalTo(kFitWidth(44))
        }
    }
    func updateFrame(isFull:Bool) {
        if isFull{
            self.backButton.alpha = 0
            self.frame = CGRect(x: 0, y: 0, width: SCREEN_HEIGHT, height: selfHeight - topSafe)
//            self.frame = CGRect(x: 0, y: 0, width: SCREEN_HEIGHT, height: selfHeight - WHUtils().getTopSafeAreaHeight())
            backButton.snp.remakeConstraints { make in
                make.left.equalTo(leftGap+topSafe)
                make.bottom.equalTo(kFitWidth(-20))
                make.width.height.equalTo(kFitWidth(44))
            }
            shareButton.snp.remakeConstraints { make in
                make.right.equalTo(-leftGap-WHUtils().getBottomSafeAreaHeight())
                make.centerY.lessThanOrEqualTo(backButton)
                make.width.height.equalTo(kFitWidth(44))
            }
        }else{
            self.backButton.alpha = 1
            self.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight)
            backButton.snp.remakeConstraints { make in
                make.left.equalTo(leftGap)
                make.bottom.equalTo(kFitWidth(-20))
                make.width.height.equalTo(kFitWidth(44))
            }
            shareButton.snp.remakeConstraints { make in
                make.right.equalTo(-leftGap)
                make.centerY.lessThanOrEqualTo(backButton)
                make.width.height.equalTo(kFitWidth(44))
            }
        }
    }
}
