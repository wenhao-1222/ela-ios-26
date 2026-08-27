//
//  GuidanceGoalPlanDurationPageVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit
import SnapKit

/// GuidanceGoalPlanDurationPageVM 类型，封装 Guide0820 引导流程中的相关功能。
class GuidanceGoalPlanDurationPageVM: UIView, GuidanceGoalPlanPageVM {
    /// ControlStyle 类型，封装 Guide0820 引导流程中的相关功能。
    enum ControlStyle {
        case stepper
        case customPicker
    }

    /// `selectionChanged` 属性，保存该类型对外提供或内部使用的状态与配置。
    var selectionChanged: (() -> Void)?
    /// `weeksChanged` 属性，保存该类型对外提供或内部使用的状态与配置。
    var weeksChanged: ((Int) -> Void)?

    // `titleText` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let titleText: String
    // `accentColor` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let accentColor: UIColor
    // `controlStyle` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let controlStyle: ControlStyle
    // `recommendedWeeks` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var recommendedWeeks: Int
    // `recommendationTitle` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var recommendationTitle: String
    // `recommendationDetail` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var recommendationDetail: String
    // `weekLabel` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let weekLabel = UILabel()
    // `recommendationTitleLabel` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let recommendationTitleLabel = UILabel()
    // `recommendationDetailLabel` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let recommendationDetailLabel = UILabel()
    // `pickerView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var pickerView: CustomPickerView = {
        // CustomPickerView lays out its internal UIPickerView from the frame it
        // receives during initialization, so give it its final design size here.
        let view = CustomPickerView(frame: CGRect(
            x: 0,
            y: 0,
            width: guide0820Design(656),
            height: kFitWidth(80)
        ))
        view.numberOfRows = 60
        view.delegate = self
        return view
    }()

    /// `weeks` 属性，保存该类型对外提供或内部使用的状态与配置。
    var weeks: Int {
        didSet {
            let maximumWeeks = controlStyle == .customPicker ? 60 : 52
            weeks = min(max(weeks, 1), maximumWeeks)
            weekLabel.text = "\(weeks)"
            weeksChanged?(weeks)
            selectionChanged?()
        }
    }

    /// `hasSelection` 属性，保存该类型对外提供或内部使用的状态与配置。
    var hasSelection: Bool {
        weeks > 0
    }

    /// 初始化当前类型实例。
    init(title: String,
         accentColor: UIColor,
         defaultWeeks: Int,
         recommendationTitle: String,
         recommendationDetail: String,
         controlStyle: ControlStyle = .stepper) {
        self.titleText = title
        self.accentColor = accentColor
        self.controlStyle = controlStyle
        self.recommendedWeeks = defaultWeeks
        self.recommendationTitle = recommendationTitle
        self.recommendationDetail = recommendationDetail
        self.weeks = min(max(defaultWeeks, 1), controlStyle == .customPicker ? 60 : 52)
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        initUI()
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 执行 `layoutSubviews` 操作，完成当前引导页面的状态更新或交互处理。
    override func layoutSubviews() {
        super.layoutSubviews()
        guard controlStyle == .customPicker else { return }
        let pickerWidth = guide0820Design(656)
        pickerView.frame = CGRect(
            x: (bounds.width - pickerWidth) / 2.0,
            y: guide0820Design(752) - kFitWidth(40),
            width: pickerWidth,
            height: kFitWidth(80)
        )
    }

    /// 执行 `updateRecommendation` 操作，完成当前引导页面的状态更新或交互处理。
    func updateRecommendation(defaultWeeks: Int, title: String, detail: String) {
        recommendedWeeks = defaultWeeks
        recommendationTitle = title
        recommendationDetail = detail
        weeks = defaultWeeks
        recommendationTitleLabel.text = title
        recommendationDetailLabel.text = detail
    }

    /// 执行 `pageWillAppear` 操作，完成当前引导页面的状态更新或交互处理。
    func pageWillAppear() {
        weekLabel.text = "\(weeks)"
        recommendationTitleLabel.text = recommendationTitle
        recommendationDetailLabel.text = recommendationDetail
        syncPickerSelection()
    }
}

// GuidanceGoalPlanDurationPageVM 扩展，提供 Guide0820 流程相关的辅助能力。
private extension GuidanceGoalPlanDurationPageVM {
    // 执行 `initUI` 操作，完成当前引导页面的状态更新或交互处理。
    func initUI() {
        backgroundColor = GuidanceGoalPlanStyle.pageBackgroundColor

        switch controlStyle {
        case .stepper:
            initStepperUI()
        case .customPicker:
            initCustomPickerUI()
        }
    }

    // 执行 `makeTitleLabel` 操作，完成当前引导页面的状态更新或交互处理。
    func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = titleText
        label.textColor = GuidanceGoalPlanStyle.titleColor
        label.font = .systemFont(ofSize: guide0820Design(48), weight: .medium)
        label.numberOfLines = 0
        return label
    }

    // 执行 `configureRecommendationLabels` 操作，完成当前引导页面的状态更新或交互处理。
    func configureRecommendationLabels(titleFontSize: CGFloat, detailFontSize: CGFloat) {
        recommendationTitleLabel.text = recommendationTitle
        recommendationTitleLabel.textColor = GuidanceGoalPlanStyle.titleColor
        recommendationTitleLabel.font = .systemFont(ofSize: titleFontSize, weight: .regular)
        recommendationTitleLabel.numberOfLines = 0

        recommendationDetailLabel.text = recommendationDetail
        recommendationDetailLabel.textColor = GuidanceGoalPlanStyle.detailColor
        recommendationDetailLabel.font = .systemFont(ofSize: detailFontSize, weight: .regular)
        recommendationDetailLabel.numberOfLines = 0
    }

    // 执行 `initStepperUI` 操作，完成当前引导页面的状态更新或交互处理。
    func initStepperUI() {
        let titleLabel = makeTitleLabel()

        let cardView = UIView()
        cardView.backgroundColor = GuidanceGoalPlanStyle.cardBackgroundColor
        cardView.layer.cornerRadius = kFitWidth(16)

        let minusButton = makeRoundButton(title: "-", fontSize: 28)
        let plusButton = makeRoundButton(title: "+", fontSize: 24)
        minusButton.addTarget(self, action: #selector(minusTapAction), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusTapAction), for: .touchUpInside)

        weekLabel.text = "\(weeks)"
        weekLabel.textAlignment = .center
        weekLabel.textColor = accentColor
        weekLabel.font = UIFont().DDInFontMedium(fontSize: 46)

        let unitLabel = UILabel()
        unitLabel.text = "周"
        unitLabel.textColor = GuidanceGoalPlanStyle.detailColor
        unitLabel.font = .systemFont(ofSize: 16, weight: .regular)

        configureRecommendationLabels(titleFontSize: 17, detailFontSize: 14)

        addSubview(titleLabel)
        addSubview(cardView)
        cardView.addSubview(minusButton)
        cardView.addSubview(plusButton)
        cardView.addSubview(weekLabel)
        cardView.addSubview(unitLabel)
        cardView.addSubview(recommendationTitleLabel)
        cardView.addSubview(recommendationDetailLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(kFitWidth(22))
        }

        cardView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(42))
        }

        weekLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(kFitWidth(28))
        }

        unitLabel.snp.makeConstraints { make in
            make.left.equalTo(weekLabel.snp.right).offset(kFitWidth(4))
            make.lastBaseline.equalTo(weekLabel.snp.lastBaseline).offset(kFitWidth(-6))
        }

        minusButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(28))
            make.centerY.equalTo(weekLabel)
            make.width.height.equalTo(kFitWidth(44))
        }

        plusButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-28))
            make.centerY.equalTo(weekLabel)
            make.width.height.equalTo(kFitWidth(44))
        }

        recommendationTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(weekLabel.snp.bottom).offset(kFitWidth(30))
        }

        recommendationDetailLabel.snp.makeConstraints { make in
            make.left.right.equalTo(recommendationTitleLabel)
            make.top.equalTo(recommendationTitleLabel.snp.bottom).offset(kFitWidth(8))
            make.bottom.equalTo(kFitWidth(-24))
        }
    }

    // 执行 `initCustomPickerUI` 操作，完成当前引导页面的状态更新或交互处理。
    func initCustomPickerUI() {
        let titleLabel = makeTitleLabel()
        let recommendationView = UIView()
        recommendationView.backgroundColor = GuidanceGoalPlanStyle.titleColor.withAlphaComponent(0.05)
        recommendationView.layer.cornerRadius = guide0820Design(24)
        recommendationView.layer.cornerCurve = .continuous
        recommendationView.clipsToBounds = true

        configureRecommendationLabels(
            titleFontSize: guide0820Design(24),
            detailFontSize: guide0820Design(24)
        )

        addSubview(titleLabel)
        addSubview(pickerView)
        addSubview(recommendationView)
        recommendationView.addSubview(recommendationTitleLabel)
        recommendationView.addSubview(recommendationDetailLabel)
        pickerView.translatesAutoresizingMaskIntoConstraints = true

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(42))
            make.right.equalTo(guide0820Design(-42))
            make.top.equalTo(guide0820Design(262))
        }

        recommendationView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(42))
            make.top.equalTo(guide0820Design(934))
            make.height.equalTo(guide0820Design(178))
        }

        recommendationTitleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(32))
            make.top.equalTo(guide0820Design(32))
        }

        recommendationDetailLabel.snp.makeConstraints { make in
            make.left.right.equalTo(recommendationTitleLabel)
            make.top.equalTo(recommendationTitleLabel.snp.bottom).offset(guide0820Design(6))
            make.bottom.lessThanOrEqualToSuperview().offset(guide0820Design(-24))
        }

        syncPickerSelection()
    }

    // 执行 `syncPickerSelection` 操作，完成当前引导页面的状态更新或交互处理。
    func syncPickerSelection() {
        guard controlStyle == .customPicker else { return }
        pickerView.scrollToIndex = min(max(0, weeks - 1), 59)
    }

    // 执行 `makeRoundButton` 操作，完成当前引导页面的状态更新或交互处理。
    func makeRoundButton(title: String, fontSize: CGFloat) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(accentColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: fontSize, weight: .medium)
        button.backgroundColor = accentColor.withAlphaComponent(0.12)
        button.layer.cornerRadius = kFitWidth(22)
        button.enablePressEffect()
        return button
    }

    // 执行 `minusTapAction` 操作，完成当前引导页面的状态更新或交互处理。
    @objc func minusTapAction() {
        weeks -= 1
    }

    // 执行 `plusTapAction` 操作，完成当前引导页面的状态更新或交互处理。
    @objc func plusTapAction() {
        weeks += 1
    }
}

/// GuidanceGoalPlanDurationPageVM 扩展，提供 Guide0820 流程相关的辅助能力。
extension GuidanceGoalPlanDurationPageVM: MyPickerViewDelegate {
    /// 执行 `pickerView` 操作，完成当前引导页面的状态更新或交互处理。
    func pickerView(_ pickerView: UIPickerView!, didSelectRow row: Int) {
        weeks = row + 1
    }

    /// 执行 `pickerViewBeginScroll` 操作，完成当前引导页面的状态更新或交互处理。
    func pickerViewBeginScroll() {}
}
