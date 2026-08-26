//
//  Guide0820LifeProfileMealsAdjustVM.swift
//  lns
//
//  Created by Codex on 2026/8/25.
//

import UIKit
import SnapKit

/// “如果你想做出调整”页面，选项内容复用 GuidanceMealsAdjustVM，页面布局按 MasterGo 重新实现。
final class Guide0820LifeProfileMealsAdjustVM: Guide0820LifeProfilePageVM {
    struct Item {
        let title: String
        let value: String
        let bulking: String
        let cutting: String
        let advantages: [String]
        let disadvantages: [String]
        let targetGroup: String
    }

    private let dataArray: [Item] = [
        Item(
            title: "A. 每日 1-2 餐",
            value: "2",
            bulking: "不适合",
            cutting: "一般",
            advantages: ["更省时间", "每餐饱腹感更强"],
            disadvantages: ["血糖波动较大", "两餐之间更容易饿，可能诱发暴食", "可能影响训练质量", "难以摄入充足营养"],
            targetGroup: "时间紧张、胃功能正常的上班族和学生党"
        ),
        Item(
            title: "B. 每日 3 餐",
            value: "3",
            bulking: "一般",
            cutting: "适合",
            advantages: ["相对省时间", "能满足大部分人的健身需求"],
            disadvantages: ["两餐之间可能更容易饿", "增肌效果上限相对有限"],
            targetGroup: "对训练结果没有特别高要求的大多数人"
        ),
        Item(
            title: "C. 每日 4 餐",
            value: "4",
            bulking: "适合",
            cutting: "适合",
            advantages: ["能较好平衡生活与训练效果", "增肌期更有利于摄入足够营养", "减脂期更容易维持肌肉量"],
            disadvantages: ["相对更耗时间"],
            targetGroup: "对训练结果有较高要求的人"
        ),
        Item(
            title: "D. 每日 5 餐",
            value: "5",
            bulking: "非常适合",
            cutting: "非常适合",
            advantages: ["增肌期更容易吃够总量与营养", "减脂期更有利于维持肌肉量", "不容易暴饮暴食", "对肠胃更友好"],
            disadvantages: ["更耗时间", "没有备餐时更难执行", "需要一定自律能力"],
            targetGroup: "对训练结果有较高要求的人；有胃炎、功能性消化不良史的人"
        ),
        Item(
            title: "E. 每日 6 餐",
            value: "6+",
            bulking: "最适合",
            cutting: "最适合",
            advantages: ["更容易获得最佳增肌效果", "能最大化减脂期的肌肉保留", "不容易暴饮暴食", "对肠胃更友好"],
            disadvantages: ["非常耗时间", "没有备餐时几乎无法执行", "需要极强的自律能力", "对大部分人来说很难长期坚持"],
            targetGroup: "对训练结果有极高要求的人；运动员、有胃炎、功能性消化不良史的人"
        )
    ]

    private var selectedIndex = -1
    private var itemViews: [Guide0820LifeProfileMealsAdjustItemView] = []
    private var hasAppliedInitialCenteredSelection = false
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let topGradientView = UIView()
    private let bottomGradientView = UIView()
    private let topGradientLayer = CAGradientLayer()
    private let bottomGradientLayer = CAGradientLayer()

    var selectedAdjustValue: String? {
        guard dataArray.indices.contains(selectedIndex) else { return nil }
        return dataArray[selectedIndex].value
    }

    override var isStepValid: Bool { selectedIndex >= 0 }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        refreshSelectionFromModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
        if hasAppliedInitialCenteredSelection == false, selectedIndex >= 0 {
            hasAppliedInitialCenteredSelection = true
            centerSelectedItemIfNeeded(animated: false)
        }
    }

    override func commitCurrentValue() {
        if let selectedAdjustValue {
            Guide0820Model.shared.guidanceMealsPerDayType = selectedAdjustValue
            Guide0820Model.shared.guidanceMealsAdjustType = selectedAdjustValue
        }
    }

    func refreshSelectionFromModel() {
        let selectedValue = Guide0820Model.shared.guidanceMealsAdjustType.isEmpty
            ? Guide0820Model.shared.guidanceMealsPerDayType
            : Guide0820Model.shared.guidanceMealsAdjustType
        if let index = dataArray.firstIndex(where: { $0.value == selectedValue }) {
            applySelection(index: index, notify: false)
        } else {
            applySelection(index: -1, notify: false)
        }
    }

    private func initUI() {
        let titleLabel = UILabel()
        titleLabel.text = "如果你想做出调整"
        titleLabel.textAlignment = .left
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: guide0820Design(48), weight: .medium)
        titleLabel.setLineHeight(textString: titleLabel.text ?? "", lineHeight: guide0820Design(72))
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(42))
            make.top.equalTo(guide0820Design(262))
        }

        let subTitleLabel = UILabel()
        subTitleLabel.numberOfLines = 2
        subTitleLabel.textAlignment = .left
        subTitleLabel.text = "我们会根据你的进餐习惯，调整后续的餐次设置与饮食建议"
        subTitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        subTitleLabel.font = .systemFont(ofSize: guide0820Design(28), weight: .regular)
        subTitleLabel.setLineHeight(textString: subTitleLabel.text ?? "", lineHeight: guide0820Design(42))
        addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(guide0820Design(12))
        }

        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(subTitleLabel.snp.bottom).offset(guide0820Design(44))
            make.bottom.equalToSuperview().offset(-(WHUtils().getBottomSafeAreaHeight() + guide0820Design(136)))
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        stackView.axis = .vertical
        stackView.spacing = guide0820Design(24)
        stackView.alignment = .fill
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(42))
            make.right.equalTo(guide0820Design(-21))
            make.top.bottom.equalToSuperview()
        }

        dataArray.enumerated().forEach { index, item in
            let itemView = Guide0820LifeProfileMealsAdjustItemView()
            itemView.tag = index
            itemView.update(item: item)
            itemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemTapAction(_:))))
            stackView.addArrangedSubview(itemView)
            itemViews.append(itemView)
        }

        configureGradient(topGradientLayer, from: .COLOR_BG_F2, to: .COLOR_BG_F2.withAlphaComponent(0))
        configureGradient(bottomGradientLayer, from: .COLOR_BG_F2.withAlphaComponent(0), to: .COLOR_BG_F2)
        topGradientView.isUserInteractionEnabled = false
        bottomGradientView.isUserInteractionEnabled = false
        topGradientView.layer.addSublayer(topGradientLayer)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(scrollView)
            make.height.equalTo(guide0820Design(72))
        }
        bottomGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(scrollView)
            make.height.equalTo(guide0820Design(144))
        }
    }

    private func configureGradient(_ layer: CAGradientLayer, from: UIColor, to: UIColor) {
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.colors = [from.cgColor, to.cgColor]
        layer.locations = [0, 1]
    }

    @objc private func itemTapAction(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        applySelection(index: view.tag, notify: true)
    }

    private func applySelection(index: Int, notify: Bool) {
        selectedIndex = index
        for (idx, itemView) in itemViews.enumerated() {
            itemView.updateSelection(isSelected: idx == index)
        }
        commitCurrentValue()
        validityChanged?(isStepValid)
        centerSelectedItemIfNeeded(animated: notify)
    }

    private func centerSelectedItemIfNeeded(animated: Bool) {
        guard itemViews.indices.contains(selectedIndex) else { return }
        scrollView.layoutIfNeeded()
        contentView.layoutIfNeeded()
        let targetView = itemViews[selectedIndex]
        let targetFrame = targetView.convert(targetView.bounds, to: contentView)
        let visibleHeight = scrollView.bounds.height
        guard visibleHeight > 0 else { return }

        let desiredOffsetY = targetFrame.midY - visibleHeight * 0.5
        let minOffsetY = -scrollView.adjustedContentInset.top
        let maxOffsetY = max(scrollView.contentSize.height - visibleHeight + scrollView.adjustedContentInset.bottom, minOffsetY)
        scrollView.setContentOffset(CGPoint(x: 0, y: min(max(desiredOffsetY, minOffsetY), maxOffsetY)), animated: animated)
        updateGradientVisibility()
    }

    private func updateGradientVisibility() {
        let visibleHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let offsetY = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        let maxOffsetY = max(contentHeight - visibleHeight, 0)
        topGradientView.alpha = offsetY > 4 ? 1 : 0
        bottomGradientView.alpha = offsetY < maxOffsetY - 4 ? 1 : 0
    }
}

extension Guide0820LifeProfileMealsAdjustVM: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateGradientVisibility()
    }
}

private final class Guide0820LifeProfileMealsAdjustItemView: UIView {
    private var isSelectedState = false
    private var isPressedState = false

    private let titleLabel = UILabel()
    private let fitLabel = UILabel()
    private let advantageTitleLabel = Guide0820LifeProfileMealsAdjustItemView.makeSectionTitleLabel(text: "优点：")
    private let disadvantageTitleLabel = Guide0820LifeProfileMealsAdjustItemView.makeSectionTitleLabel(text: "缺点：")
    private let groupTitleLabel = Guide0820LifeProfileMealsAdjustItemView.makeSectionTitleLabel(text: "群体：")
    private let advantageLabel = Guide0820LifeProfileMealsAdjustItemView.makeBodyLabel()
    private let disadvantageLabel = Guide0820LifeProfileMealsAdjustItemView.makeBodyLabel()
    private let groupLabel = Guide0820LifeProfileMealsAdjustItemView.makeBodyLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
        layer.cornerRadius = guide0820Design(24)
        layer.cornerCurve = .continuous
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
        clipsToBounds = true
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initUI() {
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        fitLabel.textAlignment = .right
        fitLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        fitLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)

        [titleLabel, fitLabel, advantageTitleLabel, disadvantageTitleLabel, groupTitleLabel, advantageLabel, disadvantageLabel, groupLabel].forEach {
            addSubview($0)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.top.equalTo(guide0820Design(32))
        }

        fitLabel.snp.makeConstraints { make in
            make.right.equalTo(guide0820Design(-32))
            make.centerY.equalTo(titleLabel)
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(guide0820Design(16))
        }

        advantageTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(32))
            make.top.equalTo(titleLabel.snp.bottom).offset(guide0820Design(32))
        }

        disadvantageTitleLabel.snp.makeConstraints { make in
            make.left.width.equalTo(advantageTitleLabel)
            make.top.equalTo(advantageLabel.snp.bottom).offset(guide0820Design(16))
        }

        groupTitleLabel.snp.makeConstraints { make in
            make.left.width.equalTo(advantageTitleLabel)
            make.top.equalTo(disadvantageLabel.snp.bottom).offset(guide0820Design(24))
        }

        advantageLabel.snp.makeConstraints { make in
            make.left.equalTo(groupTitleLabel.snp.right).offset(guide0820Design(10))
            make.right.equalTo(guide0820Design(-32))
            make.firstBaseline.equalTo(advantageTitleLabel.snp.firstBaseline)
        }

        disadvantageLabel.snp.makeConstraints { make in
            make.left.right.equalTo(advantageLabel)
            make.firstBaseline.equalTo(disadvantageTitleLabel.snp.firstBaseline)
        }

        groupLabel.snp.makeConstraints { make in
            make.left.right.equalTo(advantageLabel)
            make.firstBaseline.equalTo(groupTitleLabel.snp.firstBaseline)
            make.bottom.equalTo(guide0820Design(-32))
        }
    }

    func update(item: Guide0820LifeProfileMealsAdjustVM.Item) {
        titleLabel.attributedText = attributedTitle(for: item.title, color: .COLOR_TEXT_TITLE_0f1214)
        fitLabel.text = "增肌：\(item.bulking)｜减脂：\(item.cutting)"
        advantageLabel.attributedText = attributedSection(items: item.advantages)
        disadvantageLabel.attributedText = attributedSection(items: item.disadvantages)
        groupLabel.attributedText = attributedBody(content: item.targetGroup)
    }

    func updateSelection(isSelected: Bool) {
        isSelectedState = isSelected
        updateAppearance(animated: false)
        let titleColor: UIColor = isSelected ? .THEME : .COLOR_TEXT_TITLE_0f1214
        titleLabel.attributedText = attributedTitle(for: titleLabel.attributedText?.string ?? "", color: titleColor)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPressedState = true
        updateAppearance(animated: true)
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPressedState = false
        updateAppearance(animated: true)
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPressedState = false
        updateAppearance(animated: true)
        super.touchesCancelled(touches, with: event)
    }

    private func updateAppearance(animated: Bool) {
        let applyChanges = {
            self.backgroundColor = self.isSelectedState ? .COLOR_CARD_BG_WHITE : .COLOR_TEXT_TITLE_0f1214_05
            self.layer.borderWidth = self.isSelectedState ? 2 : 0
            self.layer.borderColor = self.isSelectedState ? UIColor.THEME.cgColor : UIColor.clear.cgColor
            self.transform = self.isPressedState ? CGAffineTransform(scaleX: 0.985, y: 0.985) : .identity
            self.alpha = self.isPressedState ? 0.92 : 1
        }
        guard animated else {
            applyChanges()
            return
        }
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
            applyChanges()
        }
    }

    private static func makeSectionTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: guide0820Design(26), weight: .regular)
        return label
    }

    private static func makeBodyLabel() -> LineHeightLabel {
        let label = LineHeightLabel()
        label.numberOfLines = 0
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: guide0820Design(26), weight: .regular)
        return label
    }

    private func attributedTitle(for title: String, color: UIColor) -> NSAttributedString {
        let attributed = NSMutableAttributedString(
            string: title,
            attributes: [
                .font: UIFont.systemFont(ofSize: guide0820Design(32), weight: .medium),
                .foregroundColor: color
            ]
        )
        if let dotIndex = title.firstIndex(of: ".") {
            let prefixLength = title.distance(from: title.startIndex, to: dotIndex) + 1
            attributed.addAttributes([
                .font: UIFont.systemFont(ofSize: guide0820Design(40), weight: .medium),
                .kern: guide0820Design(6)
            ], range: NSRange(location: 0, length: prefixLength))
        }
        applyNumberFont(on: attributed, text: title, fontSize: guide0820Design(32), color: color)
        return attributed
    }

    private func attributedSection(items: [String]) -> NSAttributedString {
        attributedBody(content: items.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
    }

    private func attributedBody(content: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(
            string: content,
            attributes: [
                .font: UIFont.systemFont(ofSize: guide0820Design(26), weight: .regular),
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50
            ]
        )
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = guide0820Design(44.2)
        paragraphStyle.maximumLineHeight = guide0820Design(44.2)
        attributed.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: content.count))
        applyNumberFont(on: attributed, text: content, fontSize: guide0820Design(26), color: .COLOR_TEXT_TITLE_0f1214_50)
        return attributed
    }

    private func applyNumberFont(on attributed: NSMutableAttributedString, text: String, fontSize: CGFloat, color: UIColor) {
        guard let regex = try? NSRegularExpression(pattern: "\\d+", options: []) else { return }
        let nsText = text as NSString
        regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length)).forEach {
            attributed.addAttributes([
                .font: UIFont().DDInFontMedium(fontSize: fontSize),
                .foregroundColor: color
            ], range: $0.range)
        }
    }
}
