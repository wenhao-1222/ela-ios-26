//
//  AICoachPreFeedbackGlassVM.swift
//  lns
//
//  Created by Codex on 2026/5/25.
//

//
//  AICoachPreFeedbackGlassVM.swift
//  lns
//

import UIKit
import SnapKit

private var aiCoachPressGenerator = UIImpactFeedbackGenerator(style: .rigid)
private var aiCoachPressLastFeedbackTime: TimeInterval = 0
private let aiCoachPressMinimumFeedbackInterval: TimeInterval = 0.2

private enum AICoachLiquidGlassRuntime {
    static var isNativeAvailable: Bool {
        if #available(iOS 26.0, *) {
            return true
        } else {
            return false
        }
    }
}

final class AICoachPreFeedbackGlassVM: UIView {

    let selfHeight = kFitWidth(198)

    var buttonTapBlock: (() -> Void)?
    var goalTapBlock: (() -> Void)?
    var intensityTapBlock: (() -> Void)?
    var toneTapBlock: (() -> Void)?

    // MARK: - Native Liquid Glass background panel

    private lazy var panelGlassView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: makePanelGlassEffect())
        view.backgroundColor = .clear
        view.isOpaque = false
        view.isUserInteractionEnabled = false
        view.clipsToBounds = true
        view.layer.cornerRadius = kFitWidth(30)
        view.layer.cornerCurve = .continuous
        return view
    }()

    // MARK: - Native glass container for interactive elements

    private lazy var elementsContainerView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: makeElementsContainerEffect())
        view.backgroundColor = .clear
        view.isOpaque = false
        view.isUserInteractionEnabled = true
        view.clipsToBounds = false
        return view
    }()

    private lazy var fallbackPanelTintView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var fallbackPanelHighlightLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.18, y: 0)
        layer.endPoint = CGPoint(x: 0.82, y: 1)
        layer.colors = [
            UIColor.white.withAlphaComponent(0.24).cgColor,
            UIColor.white.withAlphaComponent(0.06).cgColor,
            UIColor.clear.cgColor
        ]
        layer.locations = [0, 0.42, 1]
        return layer
    }()

    private lazy var fallbackPanelStrokeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.withAlphaComponent(0.26).cgColor
        layer.lineWidth = 1
        return layer
    }()

    private lazy var goalItemView: AICoachPreFeedbackInfoItemView = {
        let view = AICoachPreFeedbackInfoItemView(title: "目标")
        view.tapBlock = { [weak self] in
            self?.goalTapBlock?()
        }
        return view
    }()

    private lazy var intensityItemView: AICoachPreFeedbackInfoItemView = {
        let view = AICoachPreFeedbackInfoItemView(title: "强度")
        view.tapBlock = { [weak self] in
            self?.intensityTapBlock?()
        }
        return view
    }()

    private lazy var toneItemView: AICoachPreFeedbackInfoItemView = {
        let view = AICoachPreFeedbackInfoItemView(title: "风格")
        view.tapBlock = { [weak self] in
            self?.toneTapBlock?()
        }
        return view
    }()

    private lazy var feedbackButton: AICoachPreFeedbackThemeGlassButton = {
        let button = AICoachPreFeedbackThemeGlassButton(title: "查看教练反馈")
        button.tapBlock = { [weak self] in
            self?.buttonTapBlock?()
        }
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0,
                                  y: frame.origin.y,
                                  width: SCREEN_WIDHT,
                                  height: selfHeight))
        setupBase()
        initUI()
        configure(userGoal: 1, aiCoachIntensityPreference: 1, aiCoachTone: 1)
        setButtonEnabled(false)
        applyCurrentAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else {
            return
        }

        applyCurrentAppearance()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        panelGlassView.layer.cornerRadius = kFitWidth(30)

        fallbackPanelHighlightLayer.frame = panelGlassView.bounds.insetBy(
            dx: -panelGlassView.bounds.width * 0.12,
            dy: -panelGlassView.bounds.height * 0.14
        )

        fallbackPanelStrokeLayer.path = UIBezierPath(
            roundedRect: panelGlassView.bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: kFitWidth(30)
        ).cgPath

        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: kFitWidth(30)
        ).cgPath
    }
}

// MARK: - Public API

extension AICoachPreFeedbackGlassVM {

    func configure(userGoal: Int, aiCoachIntensityPreference: Int, aiCoachTone: Int) {
        goalItemView.updateValue(text: displayGoalText(for: userGoal))
        intensityItemView.updateValue(text: displayIntensityText(for: aiCoachIntensityPreference))
        toneItemView.updateValue(text: displayToneText(for: aiCoachTone))
    }

    func setButtonEnabled(_ isEnabled: Bool) {
        feedbackButton.isEnabled = isEnabled
    }

    func prepareEntranceAnimation() {
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: -kFitWidth(12))
        applyFeedbackButtonVisibleState()
    }

    func applyFinalPresentationState() {
        alpha = 1
        transform = .identity
        applyFeedbackButtonVisibleState()
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

    func prepareFeedbackButtonHiddenState() {
        feedbackButton.layer.removeAllAnimations()
        feedbackButton.alpha = 0
    }

    func applyFeedbackButtonVisibleState() {
        feedbackButton.layer.removeAllAnimations()
        feedbackButton.alpha = 1
    }

    func playFeedbackButtonFadeIn(duration: TimeInterval,
                                  completion: (() -> Void)? = nil) {
        feedbackButton.layer.removeAllAnimations()
        feedbackButton.alpha = 0
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState]) {
            self.feedbackButton.alpha = 1
        } completion: { _ in
            completion?()
        }
    }
}

// MARK: - Setup

private extension AICoachPreFeedbackGlassVM {

    func setupBase() {
        backgroundColor = .clear
        isOpaque = false
        clipsToBounds = false
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: kFitWidth(10))
        layer.shadowRadius = kFitWidth(24)
    }

    func initUI() {
        addSubview(panelGlassView)
        addSubview(elementsContainerView)

        panelGlassView.contentView.addSubview(fallbackPanelTintView)
        panelGlassView.contentView.layer.addSublayer(fallbackPanelHighlightLayer)
        panelGlassView.contentView.layer.addSublayer(fallbackPanelStrokeLayer)

        elementsContainerView.contentView.addSubview(goalItemView)
        elementsContainerView.contentView.addSubview(intensityItemView)
        elementsContainerView.contentView.addSubview(toneItemView)
        elementsContainerView.contentView.addSubview(feedbackButton)

        panelGlassView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        elementsContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        fallbackPanelTintView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        goalItemView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(22))
            make.height.equalTo(kFitWidth(78))
        }

        intensityItemView.snp.makeConstraints { make in
            make.left.equalTo(goalItemView.snp.right).offset(kFitWidth(16))
            make.top.height.equalTo(goalItemView)
            make.width.equalTo(goalItemView)
        }

        toneItemView.snp.makeConstraints { make in
            make.left.equalTo(intensityItemView.snp.right).offset(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.height.equalTo(goalItemView)
            make.width.equalTo(goalItemView)
        }

        feedbackButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(52))
        }
    }

    func applyCurrentAppearance() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        let useNativeGlass = AICoachLiquidGlassRuntime.isNativeAvailable

        panelGlassView.effect = makePanelGlassEffect()
        elementsContainerView.effect = makeElementsContainerEffect()

        fallbackPanelTintView.isHidden = useNativeGlass
        fallbackPanelHighlightLayer.isHidden = useNativeGlass
        fallbackPanelStrokeLayer.isHidden = useNativeGlass

        fallbackPanelTintView.backgroundColor = isDark
            ? UIColor(red: 0.13, green: 0.14, blue: 0.17, alpha: 0.42)
            : UIColor.white.withAlphaComponent(0.12)

        fallbackPanelStrokeLayer.strokeColor = UIColor.white
            .withAlphaComponent(isDark ? 0.20 : 0.30)
            .cgColor

        // iOS 26 交给系统 glass 做主体质感，只保留很轻的浮层阴影。
        // iOS 26 以下保留原有 fallback 的强一点阴影。
        layer.shadowOpacity = useNativeGlass ? 0.10 : 0.16
    }

    func makePanelGlassEffect() -> UIVisualEffect? {
        let isDark = traitCollection.userInterfaceStyle == .dark

        if #available(iOS 26.0, *) {
            let effect = UIGlassEffect(style: .clear)
            effect.tintColor = isDark
                ? UIColor(red: 0.10, green: 0.11, blue: 0.14, alpha: 0.30)
                : UIColor.white.withAlphaComponent(0.16)
            effect.isInteractive = false
            return effect
        } else {
            return UIBlurEffect(style: isDark ? .systemThinMaterialDark : .systemThinMaterialLight)
        }
    }

    func makeElementsContainerEffect() -> UIVisualEffect? {
        if #available(iOS 26.0, *) {
            let effect = UIGlassContainerEffect()

            // 小于两个卡片之间的 16pt 间距，静止状态不糊成一坨；
            // 做入场、靠近、形变动画时又能有系统水滴融合感。
            effect.spacing = kFitWidth(8)
            return effect
        } else {
            return nil
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

    func displayToneText(for value: Int) -> String {
        switch value {
        case 2:
            return "温柔"
        case 3:
            return "毒舌"
        case 4:
            return "诛心"
        default:
            return "专业"
        }
    }
}

// MARK: - Target / Intensity native glass card

private final class AICoachPreFeedbackInfoItemView: UIVisualEffectView {

    private let title: String

    var tapBlock: (() -> Void)?

    var isEnabled: Bool = true {
        didSet {
            updateEnabledState()
        }
    }

    private var isPressed: Bool = false {
        didSet {
            guard oldValue != isPressed else { return }
            updatePressedState(animated: true)
        }
    }

    init(title: String) {
        self.title = title
        super.init(effect: nil)
        setupUI()
        applyCurrentAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else {
            return
        }

        applyCurrentAppearance()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = kFitWidth(14)
        layer.cornerCurve = .continuous

        fallbackHighlightLayer.frame = bounds.insetBy(
            dx: -bounds.width * 0.08,
            dy: -bounds.height * 0.18
        )

        fallbackStrokeLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: kFitWidth(14)
        ).cgPath
    }

    func updateValue(text: String) {
        valueLabel.text = text
    }

    func applyCurrentAppearance() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        let useNativeGlass = AICoachLiquidGlassRuntime.isNativeAvailable

        effect = makeInfoGlassEffect()

        fallbackTintView.isHidden = useNativeGlass
        fallbackHighlightLayer.isHidden = useNativeGlass
        fallbackStrokeLayer.isHidden = useNativeGlass

        fallbackTintView.backgroundColor = isDark
            ? UIColor(red: 0.11, green: 0.12, blue: 0.15, alpha: 0.36)
            : UIColor.white.withAlphaComponent(0.10)

        titleLabel.textColor = isDark
            ? UIColor.white.withAlphaComponent(0.46)
            : .COLOR_TEXT_TITLE_0f1214_50

        valueLabel.textColor = isDark
            ? UIColor.white.withAlphaComponent(0.88)
            : .COLOR_TEXT_TITLE_0f1214

        fallbackHighlightLayer.colors = [
            UIColor.white.withAlphaComponent(isDark ? 0.16 : 0.22).cgColor,
            UIColor.white.withAlphaComponent(isDark ? 0.04 : 0.05).cgColor,
            UIColor.clear.cgColor
        ]

        fallbackStrokeLayer.strokeColor = UIColor.white
            .withAlphaComponent(isDark ? 0.38 : 0.52)
            .cgColor

        updateEnabledState()
        updatePressedState(animated: false)
    }

    private lazy var fallbackTintView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var fallbackHighlightLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.12, y: 0)
        layer.endPoint = CGPoint(x: 0.88, y: 1)
        layer.locations = [0, 0.5, 1]
        return layer
    }()

    private lazy var fallbackStrokeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 1
        return layer
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.isUserInteractionEnabled = false
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        return label
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 0.74
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.isUserInteractionEnabled = false
        return label
    }()

    private lazy var pressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(handlePressGesture(_:)))
        gesture.minimumPressDuration = 0
        gesture.cancelsTouchesInView = true
        return gesture
    }()
}

private extension AICoachPreFeedbackInfoItemView {

    func setupUI() {
        isOpaque = false
        backgroundColor = .clear
        clipsToBounds = true
        isUserInteractionEnabled = true
        layer.cornerRadius = kFitWidth(12)
        layer.cornerCurve = .continuous

        addGestureRecognizer(pressGesture)

        contentView.addSubview(fallbackTintView)
        contentView.layer.addSublayer(fallbackHighlightLayer)
        contentView.layer.addSublayer(fallbackStrokeLayer)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)

        fallbackTintView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.right.equalTo(kFitWidth(-6))
            make.top.equalTo(kFitWidth(12))
        }

        valueLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.bottom.equalTo(kFitWidth(-12))
        }
    }

    func makeInfoGlassEffect() -> UIVisualEffect? {
        let isDark = traitCollection.userInterfaceStyle == .dark

        if #available(iOS 26.0, *) {
            let effect = UIGlassEffect(style: .regular)
            effect.tintColor = isDark
                ? UIColor.white.withAlphaComponent(0.05)
                : UIColor.white.withAlphaComponent(0.10)
            effect.isInteractive = isEnabled
            return effect
        } else {
            return UIBlurEffect(style: isDark ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight)
        }
    }

    func updateEnabledState() {
        isUserInteractionEnabled = isEnabled
        alpha = isEnabled ? 1 : 0.55

        if #available(iOS 26.0, *) {
            effect = makeInfoGlassEffect()
        }
    }

    func updatePressedState(animated: Bool) {
        let useNativeGlass = AICoachLiquidGlassRuntime.isNativeAvailable

        let changes = {
            if useNativeGlass {
                // iOS 26 不手动 scale，不手动画玻璃变形；
                // 让 UIGlassEffect(isInteractive: true) 处理原生液态交互。
                self.transform = .identity
                self.titleLabel.alpha = self.isPressed ? 0.76 : 1
                self.valueLabel.alpha = self.isPressed ? 0.86 : 1
            } else {
                self.transform = self.isPressed
                    ? CGAffineTransform(scaleX: 0.98, y: 0.98)
                    : .identity
                self.fallbackTintView.alpha = self.isPressed ? 0.72 : 1
                self.titleLabel.alpha = self.isPressed ? 0.74 : 1
                self.valueLabel.alpha = self.isPressed ? 0.82 : 1
            }
        }

        if animated {
            UIView.animate(withDuration: 0.12, animations: changes)
        } else {
            changes()
        }
    }

    @objc func handlePressGesture(_ gesture: UILongPressGestureRecognizer) {
        guard isEnabled else {
            isPressed = false
            return
        }

        let location = gesture.location(in: self)
        let inside = bounds.insetBy(dx: -kFitWidth(8), dy: -kFitWidth(8)).contains(location)

        switch gesture.state {
        case .began:
            isPressed = true

            if !AICoachLiquidGlassRuntime.isNativeAvailable {
                showAICoachPressRippleEffect(in: contentView.layer)
            }

            triggerAICoachPressImpact(aiCoachPressGenerator, intensity: 0.55)

        case .changed:
            isPressed = inside

        case .ended:
            isPressed = false

            if inside {
                triggerAICoachPressImpact(UIImpactFeedbackGenerator(style: .medium), intensity: 0.85)
                tapBlock?()
            }

        case .cancelled, .failed:
            isPressed = false

        default:
            break
        }
    }
}

// MARK: - Theme glass button

private final class AICoachPreFeedbackThemeGlassButton: UIVisualEffectView {

    private let title: String

    private let enabledBackgroundColor = UIColor.THEME
    private let disabledBackgroundColor = UIColor(red: 196 / 255.0,
                                                  green: 196 / 255.0,
                                                  blue: 196 / 255.0,
                                                  alpha: 1)

    var tapBlock: (() -> Void)?

    var isEnabled: Bool = true {
        didSet {
            updateGlassInteractionState(animated: false)
        }
    }

    private var isPressed: Bool = false {
        didSet {
            guard oldValue != isPressed else { return }
            updatePressedState(animated: true)
        }
    }

    init(title: String) {
        self.title = title
        super.init(effect: nil)
        setupUI()
        updateGlassInteractionState(animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else {
            return
        }

        updateGlassInteractionState(animated: false)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let cornerRadius = bounds.height * 0.5

        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous

        fallbackHighlightLayer.frame = bounds.insetBy(
            dx: -bounds.width * 0.08,
            dy: -bounds.height * 0.22
        )

        fallbackStrokeLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: cornerRadius
        ).cgPath
    }

    private lazy var themeOverlayView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
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

    private lazy var fallbackHighlightLayer: CAGradientLayer = {
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

    private lazy var fallbackStrokeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.withAlphaComponent(0.32).cgColor
        layer.lineWidth = 1
        return layer
    }()

    private lazy var pressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(handlePressGesture(_:)))
        gesture.minimumPressDuration = 0
        gesture.cancelsTouchesInView = true
        return gesture
    }()
}

private extension AICoachPreFeedbackThemeGlassButton {

    func setupUI() {
        isOpaque = false
        backgroundColor = .clear
        clipsToBounds = true
        isUserInteractionEnabled = true
        layer.cornerCurve = .continuous

        addGestureRecognizer(pressGesture)

        contentView.addSubview(themeOverlayView)
        contentView.layer.addSublayer(fallbackHighlightLayer)
        contentView.layer.addSublayer(fallbackStrokeLayer)
        contentView.addSubview(titleLabel)

        themeOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func makeGlassEffect() -> UIVisualEffect? {
        if #available(iOS 26.0, *) {
            let effect = UIGlassEffect(style: .regular)
            effect.tintColor = currentBackgroundColor()
                .withAlphaComponent(isEnabled ? 0.92 : 0.58)
            effect.isInteractive = isEnabled
            return effect
        } else {
            let isDark = traitCollection.userInterfaceStyle == .dark
            return UIBlurEffect(style: isDark ? .systemThinMaterialDark : .systemThinMaterialLight)
        }
    }

    func currentBackgroundColor() -> UIColor {
        isEnabled ? enabledBackgroundColor : disabledBackgroundColor
    }

    func currentFallbackOverlayAlpha() -> CGFloat {
        if isEnabled {
            return isPressed ? 0.82 : 0.92
        } else {
            return 0.78
        }
    }

    func updateGlassInteractionState(animated: Bool) {
        let useNativeGlass = AICoachLiquidGlassRuntime.isNativeAvailable

        effect = makeGlassEffect()
        isUserInteractionEnabled = isEnabled

        themeOverlayView.backgroundColor = currentBackgroundColor()
        themeOverlayView.alpha = currentFallbackOverlayAlpha()
        themeOverlayView.isHidden = useNativeGlass

        fallbackHighlightLayer.isHidden = useNativeGlass
        fallbackStrokeLayer.isHidden = useNativeGlass

        updatePressedState(animated: animated)
    }

    func updatePressedState(animated: Bool) {
        let useNativeGlass = AICoachLiquidGlassRuntime.isNativeAvailable

        let changes = {
            if useNativeGlass {
                // iOS 26：不要再手动缩放玻璃，让系统 interactive glass 自己表现。
                self.transform = .identity
                self.titleLabel.alpha = self.isEnabled
                    ? (self.isPressed ? 0.86 : 1)
                    : 0.58
            } else {
                self.transform = self.isPressed
                    ? CGAffineTransform(scaleX: 0.98, y: 0.98)
                    : .identity
                self.themeOverlayView.alpha = self.currentFallbackOverlayAlpha()
                self.titleLabel.alpha = self.isEnabled
                    ? (self.isPressed ? 0.86 : 1)
                    : 0.58
            }
        }

        if animated {
            UIView.animate(withDuration: 0.12, animations: changes)
        } else {
            changes()
        }
    }

    @objc func handlePressGesture(_ gesture: UILongPressGestureRecognizer) {
        guard isEnabled else {
            isPressed = false
            return
        }

        let location = gesture.location(in: self)
        let inside = bounds.insetBy(dx: -kFitWidth(8), dy: -kFitWidth(8)).contains(location)

        switch gesture.state {
        case .began:
            isPressed = true

            if !AICoachLiquidGlassRuntime.isNativeAvailable {
                showAICoachPressRippleEffect(in: contentView.layer)
            }

            triggerAICoachPressImpact(aiCoachPressGenerator, intensity: 0.55)

        case .changed:
            isPressed = inside

        case .ended:
            isPressed = false

            if inside {
                triggerAICoachPressImpact(UIImpactFeedbackGenerator(style: .medium), intensity: 0.9)
                tapBlock?()
            }

        case .cancelled, .failed:
            isPressed = false

        default:
            break
        }
    }
}

// MARK: - Fallback press helpers

private extension UIView {

    func triggerAICoachPressImpact(_ generator: UIImpactFeedbackGenerator,
                                   intensity: CGFloat) {
        let now = Date().timeIntervalSince1970

        guard now - aiCoachPressLastFeedbackTime > aiCoachPressMinimumFeedbackInterval else {
            return
        }

        generator.prepare()
        generator.impactOccurred(intensity: intensity)
        aiCoachPressLastFeedbackTime = now
    }

    func showAICoachPressRippleEffect(in hostLayer: CALayer) {
        let size = max(bounds.width, bounds.height)

        guard size > 0 else {
            return
        }

        let rippleLayer = CALayer()
        rippleLayer.frame = CGRect(x: (bounds.width - size) / 2,
                                   y: (bounds.height - size) / 2,
                                   width: size,
                                   height: size)
        rippleLayer.cornerRadius = size / 2
        rippleLayer.backgroundColor = UIColor.white.withAlphaComponent(0.20).cgColor
        hostLayer.addSublayer(rippleLayer)

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
        rippleLayer.add(group, forKey: "aiCoachFallbackRipple")
        CATransaction.commit()
    }
}
