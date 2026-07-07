//
//  GuideTotalProGoalStageVM.swift
//  lns
//
//  Created by Codex on 2026/7/7.
//

import UIKit
import SnapKit

class GuideTotalProGoalStageVM: UIView {

    struct Item {
        let title: String
        let value: String
    }

    enum GoalKind {
        case gain
        case fatLoss
    }

    var selectedBlock: (() -> Void)?
    var infoButtonTapBlock: ((AIGuidanceGoalStageInfoContent) -> Void)?
    var nextBlock: (() -> Void)?
    private(set) var selectedIndex = -1
    private var currentGoalKind: GoalKind = .gain
    private var dataArray: [Item] = []

    private var itemButtons: [FeedBackButton] = []
    private var titleLabels: [UILabel] = []

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F5
        isUserInteractionEnabled = true
        clipsToBounds = true

        initUI()
        refreshContentForCurrentGoal()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var hasSelection: Bool {
        selectedIndex >= 0
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var infoButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.addTarget(self, action: #selector(infoButtonTapAction), for: .touchUpInside)
        return btn
    }()

    lazy var stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = kFitWidth(12)
        return st
    }()

    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("下一步", for: .normal)
        btn.setTitle("下一步", for: .disabled)
        btn.setTitleColor(.white, for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        return btn
    }()
}

extension GuideTotalProGoalStageVM {
    func refreshContentForCurrentGoal() {
        let goalKind = goalKindFromModel()
        let oldGoalKind = currentGoalKind
        currentGoalKind = goalKind
        titleLabel.text = titleText(for: goalKind)
        infoButton.setTitle(infoButtonText(for: goalKind), for: .normal)
        dataArray = items(for: goalKind)
        if oldGoalKind != goalKind {
            QuestinonaireMsgModel.shared.aiGuidanceGoalStageType = ""
        }
        refreshSelectionFromModel()
        refreshListUI()
    }

    func refreshSelectionFromModel() {
        let selectedValue = QuestinonaireMsgModel.shared.aiGuidanceGoalStageType
        if let index = dataArray.firstIndex(where: { $0.value == selectedValue }) {
            selectedIndex = index
        } else {
            selectedIndex = -1
            QuestinonaireMsgModel.shared.aiGuidanceGoalStageType = ""
        }
        nextButton.isEnabled = hasSelection
    }

    func infoButtonText(for goalKind: GoalKind) -> String {
        switch goalKind {
        case .gain:
            return "为什么要区分增肌阶段？"
        case .fatLoss:
            return "为什么要区分减脂阶段？"
        }
    }

    func infoContent(for goalKind: GoalKind) -> AIGuidanceGoalStageInfoContent {
        switch goalKind {
        case .gain:
            return AIGuidanceGoalStageInfoContent(
                title: "为什么要区分增肌阶段？",
                message: """
早期力量提升很大一部分来自神经因素，研究显示，训练初期神经因素占更大比例，约 3 到 5 周后肌肥大因素才逐渐变得更主导。

运动训练会提高骨骼肌 GLUT4 表达，并可能增强肌糖原储备。肌糖原具有亲水性，每 1g 糖原会伴随至少约 3g 水分，因此增肌早期体重上升通常会更快，且不一定全是肌肉。

另外，训练经验也会影响增肌速度，系统综述指出未训练者通常有更大的肌肥大提升，而有训练经验的人需要更多训练刺激才能继续进步。
""",
                reference: "参考文献：Moritani & deVries, 1979; Richter & Hargreaves, 2013; Fernandez-Elias et al., 2015; ACSM, 2009; Lopez et al., 2021."
            )
        case .fatLoss:
            return AIGuidanceGoalStageInfoContent(
                title: "为什么要区分减脂阶段？",
                message: """
减脂速度并非线性。早期体重下降常包含糖原和水分变化，因为糖原会以水合形式储存，每 1g 糖原通常伴随约 3 到 4g 水分；短期体重变化也不等同于纯脂肪变化。持续减脂后，体重变化会受到能量摄入、能量消耗和身体成分变化共同影响。到后期，体重降低会减少维持身体所需的能量，热量限制还可能带来一定代谢适应，因此减重速度变慢或进入平台期很常见。
""",
                reference: "参考文献：Kreitzman et al., 1992; Bhutani et al., 2017; Hall et al., 2012; Hall et al., 2011; Most & Redman, 2020; Hall & Kahan, 2018; Nunes et al., 2021."
            )
        }
    }

    func goalKindFromModel() -> GoalKind {
        switch QuestinonaireMsgModel.shared.goal {
        case "4", "5", "7":
            return .gain
        default:
            return .fatLoss
        }
    }

    func titleText(for goalKind: GoalKind) -> String {
        switch goalKind {
        case .gain:
            return "你开始增肌多久了？"
        case .fatLoss:
            return "你开始减脂多久了？"
        }
    }

    func items(for goalKind: GoalKind) -> [Item] {
        switch goalKind {
        case .gain:
            return [
                Item(title: "还没开始", value: "gain_prepare"),
                Item(title: "不到 1 个月", value: "gain_less_1_month"),
                Item(title: "1 到 3 个月", value: "gain_1_3_months"),
                Item(title: "3 到 12 个月", value: "gain_3_12_months"),
                Item(title: "1 年以上", value: "gain_over_1_year")
            ]
        case .fatLoss:
            return [
                Item(title: "还没开始", value: "fat_prepare"),
                Item(title: "不到 2 周", value: "fat_less_2_weeks"),
                Item(title: "2 到 6 周", value: "fat_2_6_weeks"),
                Item(title: "7 到 12 周", value: "fat_7_12_weeks"),
                Item(title: "12 周以上", value: "fat_over_12_weeks")
            ]
        }
    }

    func refreshListUI() {
        if itemButtons.count != dataArray.count {
            rebuildButtons()
        }

        for index in dataArray.indices {
            applySelectionStyle(index: index, isSelected: index == selectedIndex)
        }
    }

    func rebuildButtons() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        itemButtons.removeAll()
        titleLabels.removeAll()

        for (index, _) in dataArray.enumerated() {
            let button = FeedBackButton()
            button.tag = index
            button.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
            button.layer.cornerRadius = kFitWidth(30)
            button.clipsToBounds = true
            button.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT), for: .highlighted)
            button.addTarget(self, action: #selector(itemTapAction(_:)), for: .touchUpInside)

            let lab = UILabel()
            lab.textAlignment = .center
            lab.textColor = .COLOR_TEXT_TITLE_0f1214
            lab.font = .systemFont(ofSize: 20, weight: .medium)

            button.addSubview(lab)
            lab.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }

            button.snp.makeConstraints { make in
                make.height.equalTo(kFitWidth(60))
            }

            stackView.addArrangedSubview(button)
            itemButtons.append(button)
            titleLabels.append(lab)
        }
    }

    func applySelectionStyle(index: Int, isSelected: Bool) {
        guard index >= 0 && index < itemButtons.count else {
            return
        }
        itemButtons[index].backgroundColor = isSelected ? .THEME : .COLOR_BG_BLACK_04
        let textColor: UIColor = isSelected ? .COLOR_TEXT_WHITE : .COLOR_TEXT_TITLE_0f1214
        titleLabels[index].textColor = textColor
        updateItemLabel(titleLabels[index], text: dataArray[index].title, color: textColor)
    }

    @objc func itemTapAction(_ sender: UIButton) {
        applySelection(index: sender.tag, notify: true)
    }

    @objc func infoButtonTapAction() {
        infoButtonTapBlock?(infoContent(for: currentGoalKind))
    }

    @objc private func nextButtonAction() {
        guard hasSelection else { return }
        nextBlock?()
    }

    func applySelection(index: Int, notify: Bool) {
        guard index >= 0 && index < dataArray.count else {
            return
        }

        selectedIndex = index
        QuestinonaireMsgModel.shared.aiGuidanceGoalStageType = dataArray[index].value

        for idx in itemButtons.indices {
            applySelectionStyle(index: idx, isSelected: idx == index)
        }

        nextButton.isEnabled = hasSelection

        if notify {
            selectedBlock?()
        }
    }
}

private extension GuideTotalProGoalStageVM {
    func updateItemLabel(_ label: UILabel, text: String, color: UIColor) {
        label.attributedText = makeItemAttributedText(text: text, color: color)
    }

    func makeItemAttributedText(text: String, color: UIColor) -> NSAttributedString {
        let fontSize: CGFloat = 20
        let attr = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: fontSize, weight: .medium),
                .foregroundColor: color
            ]
        )

        guard let regex = try? NSRegularExpression(pattern: "\\d+", options: []) else {
            return attr
        }

        let nsText = text as NSString
        let numberFont = UIFont().DDInFontMedium(fontSize: fontSize)
        regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length)).forEach {
            attr.addAttributes([
                .font: numberFont,
                .foregroundColor: color
            ], range: $0.range)
        }
        return attr
    }
}

extension GuideTotalProGoalStageVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(infoButton)
        addSubview(stackView)
        addSubview(nextButton)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(59))
        }

        infoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(10))
            make.height.equalTo(kFitWidth(22))
        }

        stackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(infoButton.snp.bottom).offset(kFitWidth(76))
        }

        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(10))
            make.centerX.equalToSuperview()
            make.width.equalTo(kFitWidth(302))
            make.height.equalTo(kFitWidth(48))
        }
    }
}

extension GuideTotalProGoalStageVM {
    func prepareEntranceAnimation() {
        titleLabel.alpha = 0
        infoButton.alpha = 0
        stackView.alpha = 0
        nextButton.alpha = 0
    }

    func startEntranceAnimation() {
        UIView.animate(withDuration: 0.55, delay: 0, options: .curveLinear) {
            self.titleLabel.alpha = 1
            self.infoButton.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.55, delay: 0.1, options: .curveLinear) {
                self.stackView.alpha = 1
                self.nextButton.alpha = 1
            }
        }
    }
}
