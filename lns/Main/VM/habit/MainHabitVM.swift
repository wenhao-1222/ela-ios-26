//
//  MainHabitVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/23.
//



class MainHabitVM: UIView {
    
    let selfHeight = kFitWidth(60)
    private let pressScale: CGFloat = 0.97
    private let pressFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let releaseFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let minimumFeedbackInterval: TimeInterval = 0.2
    private var lastFeedbackTime: TimeInterval = 0
    private var isPressingInside = false
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(0), width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        vi.clipsToBounds = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(selfTapAction))
        vi.addGestureRecognizer(tap)
        
        let press = UILongPressGestureRecognizer(target: self, action: #selector(handlePressGesture(_:)))
        press.minimumPressDuration = 0
        press.cancelsTouchesInView = false
        vi.addGestureRecognizer(press)
//        
        return vi
    }()
    lazy var betaBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(12)
        
        return vi
    }()
    lazy var betaLabel: UILabel = {
        let lab = UILabel()
        lab.text = "Beta"
        lab.textAlignment = .center
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 9, weight: .medium)
//        lab.backgroundColor = .THEME
        
        return lab
    }()
    lazy var titleLab : UILabel = {
        let lab = UILabel()
        lab.text = "自律习惯养成"
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var arrowImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "plan_arrow_theme")
        img.isUserInteractionEnabled = true
        return img
    }()
}

extension MainHabitVM{
    @objc func selfTapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    
    @objc private func handlePressGesture(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: whiteView)
        let isInside = whiteView.bounds.contains(point)
        
        switch gesture.state {
        case .began:
            isPressingInside = true
            animatePressDown()
            triggerImpact(pressFeedbackGenerator, intensity: 0.6)
        case .changed:
            guard isInside != isPressingInside else { return }
            isPressingInside = isInside
            if isInside {
                animatePressDown()
            } else {
                animatePressUp()
            }
            triggerImpact(pressFeedbackGenerator, intensity: 0.6)
        case .cancelled, .failed:
            isPressingInside = false
            animatePressUp()
        case .ended:
            isPressingInside = false
            animatePressUp()
            guard isInside else { return }
//            triggerImpact(releaseFeedbackGenerator, intensity: 0.9)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                self.tapBlock?()
            })
            
        default:
            break
        }
    }
    
    private func animatePressDown() {
        UIView.animate(withDuration: 0.08, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
            self.whiteView.transform = CGAffineTransform(scaleX: self.pressScale, y: self.pressScale)
        }
    }
    
    private func animatePressUp() {
        UIView.animate(withDuration: 0.12, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
            self.whiteView.transform = .identity
        }
    }
    
    private func triggerImpact(_ generator: UIImpactFeedbackGenerator, intensity: CGFloat) {
        let now = Date().timeIntervalSince1970
        guard now - lastFeedbackTime > minimumFeedbackInterval else { return }
        generator.impactOccurred(intensity: intensity)
        lastFeedbackTime = now
    }
}

extension MainHabitVM{
    
    func initUI() {
        addSubview(whiteView)
        
        whiteView.addSubview(titleLab)
        whiteView.addSubview(betaBgView)
        whiteView.addSubview(betaLabel)
        whiteView.addSubview(arrowImgView)
        
        setConstrait()
        
//        betaLabel.layer.cornerRadius = kFitWidth(12)
//        betaLabel.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner]
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        betaBgView.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(-12))
            make.right.bottom.equalTo(betaLabel)
        }
        betaLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalTo(kFitWidth(37))
            make.height.equalTo(kFitWidth(15))
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-11))
            make.width.height.equalTo(kFitWidth(25))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}
