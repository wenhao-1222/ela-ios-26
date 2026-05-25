//
//  AICoachPreDayItemView.swift
//  lns
//
//  Created by LNS2 on 2026/4/17.
//

class AICoachPreDayItemView: UIView {

    var tapBlock: (() -> Void)?
    private let iconSweepLayer = CAGradientLayer()
    private var isIconSweepAnimating = false
    private let todayBorderInset = kFitWidth(2)

    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = kFitWidth(5)
        view.clipsToBounds = true
        return view
    }()

    private lazy var todayBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = kFitWidth(7)
        view.layer.borderColor = UIColor(hex: "007AFF").withAlphaComponent(0.5).cgColor
//        view.backgroundColor = UIColor(hex: "007AFF").withAlphaComponent(0.5)
        view.isHidden = true
        view.layer.borderWidth = kFitWidth(2.2)
//        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()

    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ai_progress_complete_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 11, weight: .regular)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupIconSweepLayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(item: AICoachPreDaysVM.DayItem,isFirstReport:Bool=false,completeDays:Int,index:Int) {
        updateTodayBorder(isVisible: !isFirstReport && item.state == .current)

        if isFirstReport{
            titleLabel.text = ""
            if completeDays >= 7{
                iconContainerView.backgroundColor = .THEME
                checkImageView.isHidden = false
            }else{
                checkImageView.isHidden = item.completeStatus == 0
                iconContainerView.backgroundColor = ((item.completeStatus > 0) ? UIColor.THEME : UIColor.COLOR_TEXT_TITLE_0f1214_05)
//                checkImageView.isHidden = completeDays < index
//                iconContainerView.backgroundColor = completeDays >= index ? .THEME : UIColor.COLOR_TEXT_TITLE_0f1214_05
            }
            return
        }
        titleLabel.text = item.title

        switch item.completeStatus {
        case 2:
            iconContainerView.backgroundColor = .THEME
            checkImageView.isHidden = false
//            titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        case 1:
            iconContainerView.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_50
            checkImageView.isHidden = false
//            titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        default:
            iconContainerView.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
            checkImageView.isHidden = true
//            titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_25
        }
        
        switch item.state{
        case .pending:
            titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_25
        default :
            titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateIconSweepLayerFrame()
    }

    func startIconSweepAnimation() {
        guard isIconSweepAnimating == false else { return }
        isIconSweepAnimating = true
        layoutIfNeeded()
        updateIconSweepLayerFrame()

        if iconSweepLayer.superlayer == nil {
            iconContainerView.layer.addSublayer(iconSweepLayer)
        }

        let translation = iconContainerView.bounds.width * 2.1
        iconSweepLayer.transform = CATransform3DMakeTranslation(-translation, 0, 0)

        let moveAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        moveAnimation.fromValue = -translation
        moveAnimation.toValue = translation
        moveAnimation.duration = AICoachPreDaySweepAnimation.duration
        moveAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        moveAnimation.repeatCount = .infinity
        moveAnimation.isRemovedOnCompletion = false
        iconSweepLayer.add(moveAnimation, forKey: "ai.pre.days.iconSweep")
    }

    func stopIconSweepAnimation() {
        isIconSweepAnimating = false
        iconSweepLayer.removeAnimation(forKey: "ai.pre.days.iconSweep")
        iconSweepLayer.transform = CATransform3DIdentity
        iconSweepLayer.removeFromSuperlayer()
    }
}

private extension AICoachPreDayItemView {
    func setupIconSweepLayer() {
        iconSweepLayer.startPoint = CGPoint(x: 0, y: 0.35)
        iconSweepLayer.endPoint = CGPoint(x: 1, y: 0.65)
        iconSweepLayer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.18).cgColor,
            UIColor.white.withAlphaComponent(0.52).cgColor,
            UIColor.white.withAlphaComponent(0.18).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        iconSweepLayer.locations = [0, 0.38, 0.5, 0.62, 1]
    }

    func updateIconSweepLayerFrame() {
        let bounds = iconContainerView.bounds
        guard bounds.isEmpty == false else { return }
        iconSweepLayer.frame = bounds.insetBy(dx: -bounds.width, dy: 0)
    }

    func updateTodayBorder(isVisible: Bool) {
        todayBorderView.isHidden = !isVisible
//        todayBorderView.layer.borderColor = isVisible ? UIColor(hex: "007AFF").withAlphaComponent(0.5).cgColor : UIColor.clear.cgColor
    }

    func setupUI() {
        addSubview(todayBorderView)
        addSubview(iconContainerView)
        addSubview(titleLabel)
        iconContainerView.addSubview(checkImageView)

        todayBorderView.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(-todayBorderInset)
            make.center.equalToSuperview()
            make.width.height.equalTo(kFitWidth(30) + todayBorderInset * 2)
        }

        iconContainerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(kFitWidth(30))
        }

        checkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(kFitWidth(14))
            make.height.equalTo(kFitWidth(9))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(iconContainerView.snp.bottom).offset(kFitWidth(6))
//            make.bottom.equalToSuperview()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(itemTapAction))
        addGestureRecognizer(tapGesture)
    }

    @objc
    func itemTapAction() {
        tapBlock?()
    }
}
