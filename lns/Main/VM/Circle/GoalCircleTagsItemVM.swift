//
//  GoalCircleTagsItemVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/18.
//


class GoalCircleTagsItemVM: UIView {
    
    let selfHeight = kFitWidth(73)
    var selfWidth = kFitWidth(73)
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let feedbackWeight: CGFloat = 0.6
    private var lastFeedbackTime: TimeInterval = 0
    private let minimumFeedbackInterval: TimeInterval = 0.1
    
    var isSelect = false
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        selfWidth = (SCREEN_WIDHT-kFitWidth(34) - kFitWidth(10) * CGFloat(4))*0.2
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: selfWidth, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
//        self.clipsToBounds = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        vi.layer.cornerRadius = kFitWidth(14)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        
        
        return vi
    }()
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    
}

extension GoalCircleTagsItemVM{
    func setSelect(select:Bool) {
        self.isSelect = select
        
        if self.isSelect{
            bgView.backgroundColor = .THEME
            contentLabel.textColor = .white
        }else{
            bgView.backgroundColor = .COLOR_BG_F5
            contentLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        }
    }
    @objc func tapAction() {
        isSelect = !isSelect
        self.tapBlock?()
    }
}

extension GoalCircleTagsItemVM{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(contentLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(20))
            make.left.width.equalToSuperview()
            make.height.equalTo(kFitWidth(28))
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(2))
            make.right.equalTo(kFitWidth(2))
            make.height.equalToSuperview()
        }
    }
}
extension GoalCircleTagsItemVM{
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
////        bgView.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
//        TouchGenerator.shared.touchGenerator()
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        bgView.backgroundColor = .white
//    }
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        bgView.backgroundColor = .white
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let scale: CGFloat = 0.98
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        showPressRippleEffect()
//        feedbackGenerator.impactOccurred(intensity: feedbackWeight)
        triggerImpact(feedbackGenerator, intensity: feedbackWeight)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
        if let touch = touches.first, self.bounds.contains(touch.location(in: self)) {
//            UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.9)
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
        let size = max(bgView.bounds.width, bgView.bounds.height)
        guard size > 0 else { return }
        let frame = CGRect(x: (bgView.bounds.width - size) / 2,
                           y: (bgView.bounds.height - size) / 2,
                           width: size,
                           height: size)

        let rippleLayer = CALayer()
        rippleLayer.frame = frame
        rippleLayer.cornerRadius = size / 2
        rippleLayer.backgroundColor = UIColor.THEME.withAlphaComponent(0.2).cgColor
        bgView.layer.insertSublayer(rippleLayer, at: 0)

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
