//
//  PersonalTopFuncItemVM.swift
//  lns
//
//  Created by Elavatine on 2025/8/20.
//


class PersonalTopFuncItemVM: UIView {
    
    let selfHeight = kFitWidth(50)
    
    var tapBlock:(()->())?
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let feedbackWeight: CGFloat = 0.6
    private var lastFeedbackTime: TimeInterval = 0
    private let minimumFeedbackInterval: TimeInterval = 0.1
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var themeBgView : UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.clipsToBounds = true
        v.layer.cornerRadius = kFitWidth(4)
        v.isUserInteractionEnabled = false

        return v
    }()
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var redView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .systemRed
        vi.layer.cornerRadius = kFitWidth(2.5)
        vi.clipsToBounds = true
        vi.isHidden = true
        return vi
    }()
    lazy var unreadNumLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.layer.cornerRadius = kFitWidth(9)
        lab.clipsToBounds = true
        lab.backgroundColor = .systemRed
        lab.textAlignment = .center
        lab.isHidden = true
        lab.textInsets = UIEdgeInsets(top: kFitWidth(0), left: kFitWidth(1), bottom: kFitWidth(0), right: kFitWidth(1))

        return lab
    }()
    lazy var arrowImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "mine_func_arrow_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
//        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
        return vi
    }()
}

extension PersonalTopFuncItemVM{
    @objc func tapAction() {
        self.tapBlock?()
    }
}

extension PersonalTopFuncItemVM{
    func initUI() {
        addSubview(iconImgView)
        addSubview(titleLab)
        addSubview(arrowImgView)
        addSubview(redView)
        addSubview(unreadNumLabel)
        addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(8.5))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(42.5))
            make.centerY.lessThanOrEqualToSuperview()
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.width.height.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualToSuperview()
        }
        redView.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-16))
            make.right.equalTo(arrowImgView.snp.left).offset(kFitWidth(-3))
            make.width.height.equalTo(kFitWidth(5))
            make.centerY.lessThanOrEqualToSuperview()
        }
        unreadNumLabel.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-16))
            make.right.equalTo(arrowImgView.snp.left).offset(kFitWidth(-3))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(18))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(titleLab)
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(0.5))
        }
    }
}

extension PersonalTopFuncItemVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        changeBgColor(color: .COLOR_TEXT_TITLE_0f1214_03)
//        let scale: CGFloat = 0.98
//        UIView.animate(withDuration: 0.1) {
//            self.transform = CGAffineTransform(scaleX: scale, y: scale)
//        }
//        showPressRippleEffect()
////        feedbackGenerator.impactOccurred(intensity: feedbackWeight)
//        triggerImpact(feedbackGenerator, intensity: feedbackWeight)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
//        UIView.animate(withDuration: 0.1) {
//            self.transform = .identity
//        }
        changeBgColor(color: .COLOR_BG_WHITE)
        if let touch = touches.first, self.bounds.contains(touch.location(in: self)) {
//            triggerImpact(UIImpactFeedbackGenerator(style: .medium), intensity: 0.9)
            tapAction()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        changeBgColor(color: .COLOR_BG_WHITE)
//        UIView.animate(withDuration: 0.1) {
//            self.transform = .identity
//        }
    }
    private func changeBgColor(color:UIColor){
        self.backgroundColor = color
    }

    private func showPressRippleEffect() {
        let size = max(bounds.width, bounds.height)
        guard size > 0 else { return }
        let frame = CGRect(x: (bounds.width - size) / 2,
                           y: (bounds.height - size) / 2,
                           width: size,
                           height: size)

        let rippleLayer = CALayer()
        rippleLayer.frame = frame
        rippleLayer.cornerRadius = size / 2
        rippleLayer.backgroundColor = UIColor.THEME.withAlphaComponent(0.2).cgColor
        layer.insertSublayer(rippleLayer, at: 0)

        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 0.3
        scaleAnim.toValue = 1.4

        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 0.5
        opacityAnim.toValue = 0.0

        let group = CAAnimationGroup()
        group.animations = [scaleAnim, opacityAnim]
        group.duration = 0.5
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            rippleLayer.removeFromSuperlayer()
        }
        rippleLayer.add(group, forKey: "ripple")
        CATransaction.commit()
    }
    
    private func triggerImpact(_ generator: UIImpactFeedbackGenerator, intensity: CGFloat) {
        let now = Date().timeIntervalSince1970
        guard now - lastFeedbackTime > minimumFeedbackInterval else { return }
        generator.impactOccurred(intensity: intensity)
        lastFeedbackTime = now
    }
}
