//
//  AICoachReportAdviceAlertVM.swift
//  lns
//
//  Created by Codex on 2026/4/15.
//

import SnapKit
import UIKit

final class AICoachReportAdviceAlertVM: UIView {

    private let maintainImageAspectRatio: CGFloat = 140.0 / 1292.0
    private let whiteViewTopRadius = kFitWidth(50)

    var primaryActionBlock: ((AICoachReportNextWeekRecommendation) -> Void)?
    var secondaryActionBlock: ((AICoachReportNextWeekRecommendation) -> Void)?

    private var recommendation = AICoachReportNextWeekRecommendation.empty
    private var whiteViewHeightConstraint: Constraint?

    private var maintainImageHeight: CGFloat {
        let imageWidth = SCREEN_WIDHT - kFitWidth(48)
        return imageWidth * maintainImageAspectRatio
    }

    private var whiteViewHeight: CGFloat {
        let safeBottom = WHUtils().getBottomSafeAreaHeight()
        let titleBottomSpacing = recommendation.status == .maintain ? kFitWidth(24) : kFitWidth(36)
        let contentHeight = recommendation.status == .maintain
            ? kFitWidth(30) + maintainImageHeight
            : kFitWidth(160)
        return kFitWidth(36 + 30) + titleBottomSpacing + contentHeight + kFitWidth(96) + safeBottom
    }

    private var targetDimAlpha: CGFloat {
        traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.25
    }

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isHidden = true
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateWhiteViewCornerMask()
        updateWhiteViewBorderFrame()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupWhiteViewBorder()
        bgView.alpha = isHidden ? 0 : targetDimAlpha
    }

    private lazy var bgView: UIView = {
        let view = UIView(frame: bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = .COLOR_ALERT_BG_BLACK
        view.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenSelf))
        view.addGestureRecognizer(tap)
        return view
    }()

    private lazy var whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.addClipCorner(corners: [.topLeft, .topRight], radius: whiteViewTopRadius)
        view.layer.masksToBounds = true
        if #available(iOS 13.0, *) {
            view.layer.cornerCurve = .continuous
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingToDo))
        view.addGestureRecognizer(tap)
        return view
    }()

    private lazy var whiteBlurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: effect)
        view.isUserInteractionEnabled = false
        view.contentView.backgroundColor = UIColor.COLOR_CARD_BG_WHITE_ALERT.withAlphaComponent(0.05)
        return view
    }()

    private let whiteBorderGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.locations = [0, 1]
        return layer
    }()

    private let whiteBorderMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = 1
        return layer
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AICoachReportDemoPalette.textPrimary
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "alert_close_icon"), for: .normal)
        button.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        return button
    }()

    private lazy var metricsContainer: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var caloriesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "热量(kcal)"
        label.textColor = AICoachReportDemoPalette.textTertiary
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private lazy var caloriesValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = AICoachReportDemoPalette.textPrimary
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }()

    private lazy var caloriesArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var nutrientSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "EFEFF1")
        return view
    }()

    private lazy var nutrientStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [carbohydrateView, proteinView, fatView])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var carbohydrateView = AICoachReportAdviceMetricView(title: "碳水(g)", showsSeparator: true)
    private lazy var proteinView = AICoachReportAdviceMetricView(title: "蛋白质(g)", showsSeparator: true)
    private lazy var fatView = AICoachReportAdviceMetricView(title: "脂肪(g)", showsSeparator: false)

    private lazy var maintainIndicatorView: UIView = {
        let view = AICoachReportAdvicePointerView()
        view.isHidden = true
        return view
    }()

    private lazy var maintainTargetImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ai_coach_recommend_maintain_target"))
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    private lazy var primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = AICoachReportDemoPalette.themeBlue
        button.layer.cornerRadius = kFitWidth(28)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.enablePressEffect()
        button.addTarget(self, action: #selector(primaryButtonAction), for: .touchUpInside)
        return button
    }()

    private lazy var secondaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        button.layer.cornerRadius = kFitWidth(28)
        button.layer.borderWidth = 1
        button.layer.borderColor = AICoachReportDemoPalette.themeBlue.cgColor
        button.setTitleColor(AICoachReportDemoPalette.themeBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.enablePressEffect()
        button.addTarget(self, action: #selector(secondaryButtonAction), for: .touchUpInside)
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [secondaryButton, primaryButton])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = kFitWidth(12)
        return stackView
    }()
}

extension AICoachReportAdviceAlertVM {
    func update(data: AICoachReportNextWeekRecommendation) {
        recommendation = data
        let isMaintain = data.status == .maintain
        let secondaryTitle = data.secondaryButtonTitle

        titleLabel.text = isMaintain ? "下周建议" : "下周建议： \(data.titleText)"
        primaryButton.setTitle(data.primaryButtonTitle, for: .normal)
        secondaryButton.setTitle(secondaryTitle, for: .normal)
        secondaryButton.isHidden = secondaryTitle == nil

        let iconName = data.status.iconName
        caloriesValueLabel.text = data.caloriesText
        caloriesArrowImageView.image = iconName.flatMap { UIImage(named: $0) }

        carbohydrateView.update(value: data.carbohydrateText, iconName: iconName)
        proteinView.update(value: data.proteinText, iconName: iconName)
        fatView.update(value: data.fatText, iconName: iconName)

        metricsContainer.isHidden = isMaintain
        maintainIndicatorView.isHidden = isMaintain == false
        maintainTargetImageView.isHidden = isMaintain == false

        whiteViewHeightConstraint?.update(offset: whiteViewHeight)
        layoutIfNeeded()
    }

    func showSelf() {
        guard recommendation.isValid else { return }

        isHidden = false
        bgView.isUserInteractionEnabled = false
        whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
        bgView.alpha = 0

        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
            self.bgView.alpha = self.targetDimAlpha
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
        }

        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
            self.whiteView.transform = .identity
        }
    }

    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)
            self.bgView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }
}

private extension AICoachReportAdviceAlertVM {
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)

        whiteView.addSubview(whiteBlurView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(closeButton)
        whiteView.addSubview(metricsContainer)
        whiteView.addSubview(maintainIndicatorView)
        whiteView.addSubview(maintainTargetImageView)
        whiteView.addSubview(buttonStackView)

        metricsContainer.addSubview(caloriesTitleLabel)
        metricsContainer.addSubview(caloriesValueLabel)
        metricsContainer.addSubview(caloriesArrowImageView)
        metricsContainer.addSubview(nutrientSeparator)
        metricsContainer.addSubview(nutrientStackView)

        whiteView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            whiteViewHeightConstraint = make.height.equalTo(whiteViewHeight).constraint
        }

        whiteBlurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(kFitWidth(30))
            make.left.greaterThanOrEqualToSuperview().offset(kFitWidth(52))
            make.right.lessThanOrEqualToSuperview().offset(-kFitWidth(52))
        }

        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-kFitWidth(25))
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(kFitWidth(25))
        }

        metricsContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(36))
            make.left.equalToSuperview().offset(kFitWidth(20))
            make.right.equalToSuperview().offset(-kFitWidth(20))
            make.height.equalTo(kFitWidth(160))
        }

        caloriesTitleLabel.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }

        caloriesValueLabel.snp.makeConstraints { make in
            make.top.equalTo(caloriesTitleLabel.snp.bottom).offset(kFitWidth(12))
            make.centerX.equalToSuperview().offset(-kFitWidth(7))
        }

        caloriesArrowImageView.snp.makeConstraints { make in
            make.left.equalTo(caloriesValueLabel.snp.right).offset(kFitWidth(6))
            make.centerY.equalTo(caloriesValueLabel.snp.centerY).offset(kFitWidth(2))
            make.width.equalTo(kFitWidth(10))
            make.height.equalTo(kFitWidth(14))
        }

        nutrientSeparator.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(caloriesValueLabel.snp.bottom).offset(kFitWidth(28))
            make.height.equalTo(0.5)
        }

        nutrientStackView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(nutrientSeparator.snp.bottom)
        }

        maintainIndicatorView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(24))
            make.centerX.equalToSuperview()
            make.width.equalTo(kFitWidth(18))
            make.height.equalTo(kFitWidth(14))
        }

        maintainTargetImageView.snp.makeConstraints { make in
            make.top.equalTo(maintainIndicatorView.snp.bottom).offset(kFitWidth(16))
            make.left.equalToSuperview().offset(kFitWidth(24))
            make.right.equalToSuperview().offset(-kFitWidth(24))
            make.height.equalTo(maintainTargetImageView.snp.width).multipliedBy(maintainImageAspectRatio)
        }

        buttonStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(20))
            make.right.equalToSuperview().offset(-kFitWidth(20))
            make.bottom.equalToSuperview().offset(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(20))
        }

        primaryButton.snp.makeConstraints { make in
            make.height.equalTo(kFitWidth(56))
        }

        secondaryButton.snp.makeConstraints { make in
            make.height.equalTo(kFitWidth(56))
        }

        setupWhiteViewBorder()
    }

    @objc func primaryButtonAction() {
        primaryActionBlock?(recommendation)
    }

    @objc func secondaryButtonAction() {
        secondaryActionBlock?(recommendation)
    }

    @objc func nothingToDo() {}

    func setupWhiteViewBorder() {
        if traitCollection.userInterfaceStyle == .dark {
            whiteBorderGradientLayer.colors = [
                WHColorWithAlpha(colorStr: "D2D3D4", alpha: 0.5).cgColor,
                WHColorWithAlpha(colorStr: "D2D3D4", alpha: 0).cgColor
            ]
        } else {
            whiteBorderGradientLayer.colors = [
                WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.5).cgColor,
                WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.5).cgColor
            ]
        }

        whiteBorderGradientLayer.mask = whiteBorderMaskLayer
        if whiteBorderGradientLayer.superlayer == nil {
            whiteView.layer.addSublayer(whiteBorderGradientLayer)
        }
        updateWhiteViewBorderFrame()
    }

    func updateWhiteViewBorderFrame() {
        whiteBorderGradientLayer.frame = whiteView.bounds

        let inset = whiteBorderMaskLayer.lineWidth / 2
        let pathRect = whiteView.bounds.insetBy(dx: inset, dy: inset)
        let radius = max(0, whiteViewTopRadius - inset)
        whiteBorderMaskLayer.path = UIBezierPath(
            roundedRect: pathRect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath
    }

    func updateWhiteViewCornerMask() {
        whiteView.addClipCorner(corners: [.topLeft, .topRight], radius: whiteViewTopRadius)
    }
}

private final class AICoachReportAdvicePointerView: UIView {

    override class var layerClass: AnyClass {
        CAShapeLayer.self
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: bounds.width, y: 0))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.height))
        path.close()

        guard let shapeLayer = layer as? CAShapeLayer else { return }
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = AICoachReportDemoPalette.themeBlue.cgColor
        shapeLayer.lineJoin = .round
    }
}

private final class AICoachReportAdviceMetricView: UIView {

    private let title: String
    private let showsSeparator: Bool

    init(title: String, showsSeparator: Bool) {
        self.title = title
        self.showsSeparator = showsSeparator
        super.init(frame: .zero)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.textAlignment = .center
        label.textColor = AICoachReportDemoPalette.textTertiary
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = AICoachReportDemoPalette.textPrimary
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var rightSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "EFEFF1")
        return view
    }()
}

private extension AICoachReportAdviceMetricView {
    func initUI() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(iconImageView)
        addSubview(rightSeparator)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kFitWidth(16))
            make.centerX.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(10))
            make.centerX.equalToSuperview().offset(-kFitWidth(6))
        }

        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(valueLabel.snp.right).offset(kFitWidth(4))
            make.centerY.equalTo(valueLabel.snp.centerY).offset(kFitWidth(2))
            make.width.equalTo(kFitWidth(10))
            make.height.equalTo(kFitWidth(14))
        }

        rightSeparator.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kFitWidth(18))
            make.bottom.equalToSuperview().offset(-kFitWidth(18))
            make.right.equalToSuperview()
            make.width.equalTo(0.5)
        }
    }
}

extension AICoachReportAdviceMetricView {
    func update(value: String, iconName: String?) {
        valueLabel.text = value
        iconImageView.image = iconName.flatMap { UIImage(named: $0) }
        iconImageView.isHidden = iconName == nil
        rightSeparator.isHidden = showsSeparator == false
    }
}
