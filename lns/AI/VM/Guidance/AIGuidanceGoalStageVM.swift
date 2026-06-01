//
//  AIGuidanceGoalStageVM.swift
//  lns
//
//  Created by Codex on 2026/3/24.
//

import UIKit
import SnapKit

class AIGuidanceGoalStageVM: UIView {

    struct Item {
        let title: String
        let value: String
    }

    enum GoalKind {
        case gain
        case fatLoss
    }

    var selectedBlock: (() -> ())?
    private(set) var selectedIndex = -1
    private var currentGoalKind: GoalKind = .gain
    private var dataArray: [Item] = []

    private var itemButtons: [FeedBackButton] = []
    private var titleLabels: [UILabel] = []

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true

        initUI()
        refreshContentForCurrentGoal()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var hasSelection: Bool {
        return selectedIndex >= 0
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = kFitWidth(12)
        return st
    }()
}

extension AIGuidanceGoalStageVM {
    func refreshContentForCurrentGoal() {
        let goalKind = goalKindFromModel()
        let oldGoalKind = currentGoalKind
        currentGoalKind = goalKind
        titleLabel.text = titleText(for: goalKind)
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

        for (index, item) in dataArray.enumerated() {
            applySelectionStyle(index: index, isSelected: index == selectedIndex)
        }
    }

    func rebuildButtons() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        itemButtons.removeAll()
        titleLabels.removeAll()

        for (index, item) in dataArray.enumerated() {
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

    func applySelection(index: Int, notify: Bool) {
        guard index >= 0 && index < dataArray.count else {
            return
        }

        selectedIndex = index
        QuestinonaireMsgModel.shared.aiGuidanceGoalStageType = dataArray[index].value

        for idx in itemButtons.indices {
            applySelectionStyle(index: idx, isSelected: idx == index)
        }

        if notify {
            selectedBlock?()
        }
    }
}

private extension AIGuidanceGoalStageVM {
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

extension AIGuidanceGoalStageVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(stackView)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(59))
        }

        stackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(100))
        }
    }
}
