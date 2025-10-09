//
//  PersonalTopItemVM.swift
//  lns
//
//  Created by Elavatine on 2025/8/20.
//


class PersonalTopItemVM: UIView {
    
    let selfWidth = kFitWidth(76)
    let selfHeight = kFitWidth(97)
    
    var tapBlock:(()->())?
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let feedbackWeight: CGFloat = 0.6
    private var lastFeedbackTime: TimeInterval = 0
    private let minimumFeedbackInterval: TimeInterval = 0.1

    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: frame.origin.x, y: 0, width: selfWidth, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
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
        img.isUserInteractionEnabled = false
        
        return img
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.isUserInteractionEnabled = false
        lab.adjustsFontSizeToFitWidth = true
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
}

extension PersonalTopItemVM{
    @objc func tapAction() {
        self.tapBlock?()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let scale: CGFloat = 0.97
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        showPressRippleEffect()
        triggerImpact(feedbackGenerator, intensity: feedbackWeight)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
        if let touch = touches.first, self.bounds.contains(touch.location(in: self)) {
            triggerImpact(UIImpactFeedbackGenerator(style: .medium), intensity: 0.9)
            tapAction()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
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

extension PersonalTopItemVM{
    func initUI() {
        addSubview(themeBgView)
        themeBgView.addSubview(iconImgView)
        themeBgView.addSubview(titleLab)
     
        setConstrait()
    }
    func setConstrait() {
        themeBgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        iconImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(23))
            make.width.height.equalTo(kFitWidth(30))
        }
        titleLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(iconImgView.snp.bottom).offset(kFitWidth(10))
        }
    }
}
