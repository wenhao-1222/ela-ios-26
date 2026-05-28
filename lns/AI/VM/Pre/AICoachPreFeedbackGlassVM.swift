//
//  AICoachPreFeedbackGlassVM.swift
//  lns
//
//  Created by Codex on 2026/5/25.
//

import UIKit
import SnapKit

private var aiCoachPressGenerator = UIImpactFeedbackGenerator(style: .rigid)
private var aiCoachPressLastFeedbackTime: TimeInterval = 0
private let aiCoachPressMinimumFeedbackInterval: TimeInterval = 0.2

final class AICoachPreFeedbackGlassVM: UIView {

    let selfHeight = kFitWidth(198)
    var buttonTapBlock: (() -> Void)?
    var goalTapBlock: (() -> Void)?
    var intensityTapBlock: (() -> Void)?

    private lazy var containerGlassView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: makeContainerEffect())
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.cornerRadius = kFitWidth(30)
        view.layer.cornerCurve = .continuous
        view.isUserInteractionEnabled = true
        return view
    }()

    private lazy var backgroundGlassView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: makeBackgroundGlassEffect())
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.cornerRadius = kFitWidth(30)
        view.layer.cornerCurve = .continuous
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var fallbackTintView: UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor(red: 0.66, green: 0.69, blue: 0.75, alpha: 0.18)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        if #available(iOS 26.0, *) {
            view.isHidden = true
        }
        return view
    }()

    private lazy var highlightLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.18, y: 0)
        layer.endPoint = CGPoint(x: 0.82, y: 1)
        layer.isHidden = true
        layer.colors = [
            UIColor.white.withAlphaComponent(0.26).cgColor,
            UIColor.white.withAlphaComponent(0.06).cgColor,
            UIColor.clear.cgColor
        ]
        layer.locations = [0, 0.42, 1]
        return layer
    }()

    private lazy var strokeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.withAlphaComponent(0.58).cgColor
        layer.lineWidth = 1
        return layer
    }()

    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [goalItemView, intensityItemView])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = kFitWidth(16)
        return stackView
    }()

    private lazy var goalItemView: AICoachPreFeedbackInfoItemView = {
        let view = AICoachPreFeedbackInfoItemView(title: "目标")
        view.addTarget(self, action: #selector(goalItemTapAction), for: .touchUpInside)
        return view
    }()

    private lazy var intensityItemView: AICoachPreFeedbackInfoItemView = {
        let view = AICoachPreFeedbackInfoItemView(title: "强度")
        view.addTarget(self, action: #selector(intensityItemTapAction), for: .touchUpInside)
        return view
    }()

    private lazy var feedbackButton: AICoachPreFeedbackThemeGlassButton = {
        let button = AICoachPreFeedbackThemeGlassButton(title: "查看教练反馈")
        button.addTarget(self, action: #selector(feedbackButtonTapAction), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        backgroundColor = .clear
        isOpaque = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.16
        layer.shadowOffset = CGSize(width: 0, height: kFitWidth(10))
        layer.shadowRadius = kFitWidth(24)
        initUI()
        configure(userGoal: 1, aiCoachIntensityPreference: 1)
        setButtonEnabled(false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        highlightLayer.frame = bounds.insetBy(dx: -bounds.width * 0.12, dy: -bounds.height * 0.14)
        let strokeRect = bounds.insetBy(dx: 0.5, dy: 0.5)
        strokeLayer.path = UIBezierPath(roundedRect: strokeRect,
                                        cornerRadius: kFitWidth(30)).cgPath
        layer.shadowPath = UIBezierPath(roundedRect: bounds,
                                        cornerRadius: kFitWidth(30)).cgPath
    }
}

extension AICoachPreFeedbackGlassVM {
    func configure(userGoal: Int, aiCoachIntensityPreference: Int) {
        goalItemView.updateValue(text: displayGoalText(for: userGoal))
        intensityItemView.updateValue(text: displayIntensityText(for: aiCoachIntensityPreference))
    }

    func setButtonEnabled(_ isEnabled: Bool) {
        feedbackButton.isEnabled = isEnabled
//        feedbackButton.alpha = isEnabled ? 1 : 0.55
    }

    func prepareEntranceAnimation() {
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: -kFitWidth(12))
    }

    func applyFinalPresentationState() {
        alpha = 1
        transform = .identity
    }

    func playEntranceAnimation(duration: TimeInterval,
                               completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveLinear) {
            self.applyFinalPresentationState()
        } completion: { _ in
            completion?()
        }
    }
}

private extension AICoachPreFeedbackGlassVM {
    func initUI() {
        addSubview(containerGlassView)
        containerGlassView.contentView.addSubview(backgroundGlassView)
        backgroundGlassView.contentView.addSubview(fallbackTintView)
        containerGlassView.contentView.addSubview(topStackView)
        containerGlassView.contentView.addSubview(feedbackButton)
        layer.addSublayer(highlightLayer)
        layer.addSublayer(strokeLayer)

        containerGlassView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backgroundGlassView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        fallbackTintView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        topStackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(22))
            make.height.equalTo(kFitWidth(78))
        }

        feedbackButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
//            make.top.equalTo(topStackView.snp.bottom).offset(kFitWidth(22))
            make.bottom.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(52))
        }
    }

    func makeContainerEffect() -> UIVisualEffect {
        if #available(iOS 26.0, *) {
            let effect = UIGlassContainerEffect()
            effect.spacing = kFitWidth(14)
            return effect
        } else {
            return UIBlurEffect(style: .systemThinMaterialLight)
        }
    }

    func makeBackgroundGlassEffect() -> UIVisualEffect {
        if #available(iOS 26.0, *) {
            let effect = UIGlassEffect(style: .clear)
            effect.tintColor = UIColor.white.withAlphaComponent(0.08)
            effect.isInteractive = true
            return effect
        } else {
            return UIBlurEffect(style: .systemThinMaterialLight)
        }
    }

    func displayGoalText(for value: Int) -> String {
        switch value {
        case 2:
            return "增肌"
        default:
            return "减脂"
        }
    }

    func displayIntensityText(for value: Int) -> String {
        switch value {
        case 2:
            return "轻松"
        case 3:
            return "正常"
        case 4:
            return "健身爱好者"
        case 5:
            return "职业运动员"
        default:
            return "非常轻松"
        }
    }

    @objc func feedbackButtonTapAction() {
        buttonTapBlock?()
    }

    @objc func goalItemTapAction() {
        goalTapBlock?()
    }

    @objc func intensityItemTapAction() {
        intensityTapBlock?()
    }
}

private final class AICoachPreFeedbackInfoItemView: UIControl {

    private let title: String

    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            updateHighlightedState(animated: true)
        }
    }

    private lazy var glassView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: makeInfoGlassEffect())
        view.backgroundColor = .clear
        if #available(iOS 26.0, *) {
            view.isUserInteractionEnabled = true
        } else {
            view.isUserInteractionEnabled = false
        }
        view.clipsToBounds = true
        view.layer.cornerRadius = kFitWidth(14)
        view.layer.cornerCurve = .continuous
        return view
    }()

    private lazy var tintView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        view.isUserInteractionEnabled = false
        if #available(iOS 26.0, *) {
            view.isHidden = true
        }
        return view
    }()

    private lazy var highlightLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.12, y: 0)
        layer.endPoint = CGPoint(x: 0.88, y: 1)
        layer.colors = [
            UIColor.white.withAlphaComponent(0.22).cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor,
            UIColor.clear.cgColor
        ]
        layer.locations = [0, 0.5, 1]
        return layer
    }()

    private lazy var strokeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.withAlphaComponent(0.52).cgColor
        layer.lineWidth = 1
        return layer
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.74
        return label
    }()

    func updateValue(text: String) {
        valueLabel.text = text
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        highlightLayer.frame = bounds.insetBy(dx: -bounds.width * 0.08, dy: -bounds.height * 0.18)
        strokeLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
                                        cornerRadius: kFitWidth(14)).cgPath
    }
}

private final class AICoachPreFeedbackThemeGlassButton: UIControl {

    private let title: String
    private let enabledBackgroundColor = UIColor.THEME
    private let disabledBackgroundColor = UIColor(red: 196 / 255.0,
                                                  green: 196 / 255.0,
                                                  blue: 196 / 255.0,
                                                  alpha: 1)

    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            updateHighlightedState(animated: true)
        }
    }

    override var isEnabled: Bool {
        didSet {
//            alpha = isEnabled ? 1 : 0.55
            updateGlassInteractionState()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let cornerRadius = bounds.height * 0.5
        layer.cornerRadius = cornerRadius
        glassView.layer.cornerRadius = cornerRadius
        highlightLayer.frame = bounds.insetBy(dx: -bounds.width * 0.08, dy: -bounds.height * 0.22)
        strokeLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
                                        cornerRadius: cornerRadius).cgPath
        if #available(iOS 26.0, *) {
            highlightLayer.isHidden = true
            strokeLayer.isHidden = true
        }
    }

    private lazy var glassView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: makeGlassEffect())
        view.backgroundColor = .clear
        if #available(iOS 26.0, *) {
            view.isUserInteractionEnabled = true
            view.clipsToBounds = false
        } else {
            view.isUserInteractionEnabled = false
            view.clipsToBounds = true
        }
        view.layer.cornerCurve = .continuous
        return view
    }()

    private lazy var themeOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = enabledBackgroundColor
        view.alpha = 0.92
        view.isUserInteractionEnabled = false
        if #available(iOS 26.0, *) {
            view.isHidden = true
        }
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.isUserInteractionEnabled = false
        return label
    }()

    private lazy var highlightLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.08, y: 0)
        layer.endPoint = CGPoint(x: 0.92, y: 1)
        layer.colors = [
            UIColor.white.withAlphaComponent(0.22).cgColor,
            UIColor.white.withAlphaComponent(0.04).cgColor,
            UIColor.clear.cgColor
        ]
        layer.locations = [0, 0.55, 1]
        return layer
    }()

    private lazy var strokeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.withAlphaComponent(0.32).cgColor
        layer.lineWidth = 1
        return layer
    }()
}

private extension AICoachPreFeedbackThemeGlassButton {
    func setupUI() {
        enableAICoachFallbackPressEffect()
        isOpaque = false
        backgroundColor = .clear
        layer.cornerCurve = .continuous
        if #available(iOS 26.0, *) {
            clipsToBounds = false
            layer.masksToBounds = false
        } else {
            clipsToBounds = true
        }

        addSubview(glassView)
        if #available(iOS 26.0, *) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(glassTapAction))
            tapGesture.cancelsTouchesInView = false
            glassView.addGestureRecognizer(tapGesture)
        }
        glassView.contentView.addSubview(themeOverlayView)
        glassView.contentView.layer.addSublayer(highlightLayer)
        glassView.contentView.layer.addSublayer(strokeLayer)
        addSubview(titleLabel)

        glassView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        themeOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        updateGlassInteractionState()
    }

    func makeGlassEffect(backgroundColor: UIColor? = nil) -> UIVisualEffect {
        if #available(iOS 26.0, *) {
            let effect = UIGlassEffect(style: .regular)
            effect.tintColor = (backgroundColor ?? currentBackgroundColor()).withAlphaComponent(0.82)
            effect.isInteractive = true
            return effect
        } else {
            return UIBlurEffect(style: .systemThinMaterialLight)
        }
    }

    func currentBackgroundColor() -> UIColor {
        isEnabled ? enabledBackgroundColor : disabledBackgroundColor
    }

    func currentOverlayAlpha() -> CGFloat {
        if #available(iOS 26.0, *) {
            return isEnabled ? 0 : 0.72
        } else {
            return isHighlighted ? 0.82 : 0.92
        }
    }

    func updateHighlightedState(animated: Bool) {
        let changes = {
            self.themeOverlayView.alpha = self.currentOverlayAlpha()
            self.titleLabel.alpha = self.isHighlighted ? 0.86 : 1
        }

        if animated {
            UIView.animate(withDuration: 0.12, animations: changes)
        } else {
            changes()
        }
    }

    @objc func glassTapAction() {
        guard isEnabled else { return }
        sendActions(for: .touchUpInside)
    }

    func updateGlassInteractionState() {
        let backgroundColor = currentBackgroundColor()
        glassView.effect = makeGlassEffect(backgroundColor: backgroundColor)
        themeOverlayView.backgroundColor = backgroundColor
        themeOverlayView.alpha = currentOverlayAlpha()
        if #available(iOS 26.0, *) {
            glassView.isUserInteractionEnabled = isEnabled
            themeOverlayView.isHidden = isEnabled
        }
    }
}

private extension AICoachPreFeedbackInfoItemView {
    func setupUI() {
        enableAICoachFallbackPressEffect()
        addSubview(glassView)
        if #available(iOS 26.0, *) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(glassTapAction))
            tapGesture.cancelsTouchesInView = false
            glassView.addGestureRecognizer(tapGesture)
        }
        glassView.contentView.addSubview(tintView)
        glassView.contentView.layer.addSublayer(highlightLayer)
        glassView.contentView.layer.addSublayer(strokeLayer)
        addSubview(titleLabel)
        addSubview(valueLabel)

        glassView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tintView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.right.equalTo(kFitWidth(-14))
            make.top.equalTo(kFitWidth(16))
        }

        valueLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.bottom.equalTo(kFitWidth(-16))
        }
    }

    func makeInfoGlassEffect() -> UIVisualEffect {
        if #available(iOS 26.0, *) {
            let effect = UIGlassEffect(style: .clear)
            effect.tintColor = UIColor.white.withAlphaComponent(0.12)
            effect.isInteractive = true
            return effect
        } else {
            return UIBlurEffect(style: .systemUltraThinMaterialLight)
        }
    }

    func updateHighlightedState(animated: Bool) {
        let changes = {
            self.tintView.alpha = self.isHighlighted ? 0.7 : 1
            self.titleLabel.alpha = self.isHighlighted ? 0.74 : 1
            self.valueLabel.alpha = self.isHighlighted ? 0.82 : 1
        }

        if animated {
            UIView.animate(withDuration: 0.12, animations: changes)
        } else {
            changes()
        }
    }

    @objc func glassTapAction() {
        guard isEnabled else { return }
        sendActions(for: .touchUpInside)
    }
}

private extension UIControl {
    func enableAICoachFallbackPressEffect() {
        if #available(iOS 26.0, *) {
            return
        }

        addTarget(self, action: #selector(aiCoachPressDown), for: .touchDown)
        addTarget(self, action: #selector(aiCoachPressDragExit), for: .touchDragExit)
        addTarget(self, action: #selector(aiCoachPressDragEnter), for: .touchDragEnter)
        addTarget(self, action: #selector(aiCoachPressUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(aiCoachPressUpOutside), for: .touchUpOutside)
        addTarget(self, action: #selector(aiCoachPressUpCancel), for: .touchCancel)
    }

    @objc func aiCoachPressDown() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
        showAICoachPressRippleEffect()
        triggerAICoachPressImpact(aiCoachPressGenerator, intensity: 0.6)
    }

    @objc func aiCoachPressDragExit() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
        triggerAICoachPressImpact(aiCoachPressGenerator, intensity: 0.6)
    }

    @objc func aiCoachPressDragEnter() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
        triggerAICoachPressImpact(aiCoachPressGenerator, intensity: 0.6)
    }

    @objc func aiCoachPressUpInside() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
        triggerAICoachPressImpact(UIImpactFeedbackGenerator(style: .medium), intensity: 0.9)
    }

    @objc func aiCoachPressUpOutside() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }

    @objc func aiCoachPressUpCancel() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }

    func triggerAICoachPressImpact(_ generator: UIImpactFeedbackGenerator, intensity: CGFloat) {
        let now = Date().timeIntervalSince1970
        guard now - aiCoachPressLastFeedbackTime > aiCoachPressMinimumFeedbackInterval else { return }
        generator.impactOccurred(intensity: intensity)
        aiCoachPressLastFeedbackTime = now
    }

    func showAICoachPressRippleEffect() {
        let size = max(bounds.width, bounds.height)
        let frame = CGRect(x: (bounds.width - size) / 2,
                           y: (bounds.height - size) / 2,
                           width: size,
                           height: size)

        let rippleLayer = CALayer()
        rippleLayer.frame = frame
        rippleLayer.cornerRadius = size / 2
        rippleLayer.backgroundColor = UIColor.white.withAlphaComponent(0.2).cgColor
        if subviews.count > 1 {
            layer.insertSublayer(rippleLayer, below: subviews[1].layer)
        } else {
            layer.addSublayer(rippleLayer)
        }

        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 0.3
        scaleAnim.toValue = 1.4

        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 0.5
        opacityAnim.toValue = 0.0

        let group = CAAnimationGroup()
        group.animations = [scaleAnim, opacityAnim]
        group.duration = 0.5
        group.repeatCount = 0
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
}
