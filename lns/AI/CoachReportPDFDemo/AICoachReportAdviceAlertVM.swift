//
//  AICoachReportAdviceAlertVM.swift
//  lns
//
//  Created by Codex on 2026/4/15.
//

import SnapKit
import UIKit

final class AICoachReportAdviceAlertVM: UIView {

    var primaryActionBlock: ((AICoachReportNextWeekRecommendation) -> Void)?

    private var recommendation = AICoachReportNextWeekRecommendation.empty
    private var whiteViewHeightConstraint: Constraint?

    private var whiteViewHeight: CGFloat {
        let safeBottom = WHUtils().getBottomSafeAreaHeight()
        let contentHeight = recommendation.status == .maintain ? kFitWidth(210) : kFitWidth(160)
        return kFitWidth(36 + 30 + 36) + contentHeight + kFitWidth(96) + safeBottom
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
        view.backgroundColor = .white
        view.layer.cornerRadius = kFitWidth(38)
        view.clipsToBounds = true
        if #available(iOS 13.0, *) {
            view.layer.cornerCurve = .continuous
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingToDo))
        view.addGestureRecognizer(tap)
        return view
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
        button.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
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

    private lazy var maintainPlaceholderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "F3F3F4")
        view.layer.cornerRadius = kFitWidth(14)
        view.clipsToBounds = true
        return view
    }()

    private lazy var maintainPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "贴图"
        label.textColor = UIColor(hex: "B4B4B8")
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
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
}

extension AICoachReportAdviceAlertVM {
    func update(data: AICoachReportNextWeekRecommendation) {
        recommendation = data

        titleLabel.text = "下周建议： \(data.titleText)"
        primaryButton.setTitle(data.primaryButtonTitle, for: .normal)

        let iconName = data.status.iconName
        caloriesValueLabel.text = data.caloriesText
        caloriesArrowImageView.image = iconName.flatMap { UIImage(named: $0) }

        carbohydrateView.update(value: data.carbohydrateText, iconName: iconName)
        proteinView.update(value: data.proteinText, iconName: iconName)
        fatView.update(value: data.fatText, iconName: iconName)

        metricsContainer.isHidden = data.status == .maintain
        maintainPlaceholderView.isHidden = data.status != .maintain

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
            self.bgView.alpha = 0.25
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

        whiteView.addSubview(titleLabel)
        whiteView.addSubview(closeButton)
        whiteView.addSubview(metricsContainer)
        whiteView.addSubview(maintainPlaceholderView)
        whiteView.addSubview(primaryButton)

        metricsContainer.addSubview(caloriesTitleLabel)
        metricsContainer.addSubview(caloriesValueLabel)
        metricsContainer.addSubview(caloriesArrowImageView)
        metricsContainer.addSubview(nutrientSeparator)
        metricsContainer.addSubview(nutrientStackView)

        maintainPlaceholderView.addSubview(maintainPlaceholderLabel)

        whiteView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            whiteViewHeightConstraint = make.height.equalTo(whiteViewHeight).constraint
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(kFitWidth(36))
            make.left.greaterThanOrEqualToSuperview().offset(kFitWidth(52))
            make.right.lessThanOrEqualToSuperview().offset(-kFitWidth(52))
        }

        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-kFitWidth(18))
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(kFitWidth(28))
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

        maintainPlaceholderView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(36))
            make.left.equalToSuperview().offset(kFitWidth(20))
            make.right.equalToSuperview().offset(-kFitWidth(20))
            make.height.equalTo(kFitWidth(200))
        }

        maintainPlaceholderLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        primaryButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(20))
            make.right.equalToSuperview().offset(-kFitWidth(20))
            make.bottom.equalToSuperview().offset(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(20))
            make.height.equalTo(kFitWidth(56))
        }
    }

    @objc func primaryButtonAction() {
        primaryActionBlock?(recommendation)
    }

    @objc func nothingToDo() {}
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
