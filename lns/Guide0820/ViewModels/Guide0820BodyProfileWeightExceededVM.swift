//
//  Guide0820BodyProfileWeightExceededVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 历史体重是否超过当前体重页 VM。
final class Guide0820BodyProfileWeightExceededVM: Guide0820BodyProfilePageVM {
    /// 页面标题，会根据当前体重动态更新。
    private let titleLabel = UILabel()

    /// 页面中的答案选项卡集合。
    private var cards: [Guide0820BodyProfileOptionCard] = []

    /// 当前选择值，变化时同步卡片选中态和页面有效性。
    private var selectedValue: String? {
        didSet {
            cards.forEach {
                $0.setSelected($0.value == selectedValue, animated: true)
            }
            commitCurrentValue()
            validityChanged?(isStepValid)
        }
    }

    /// 当前选择值。
    var selectedAnswerValue: String? { selectedValue }

    /// 只有选择答案后才允许继续。
    override var isStepValid: Bool { selectedValue != nil }

    /// 初始化并搭建页面 UI。
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    /// Storyboard 初始化入口，本页面不支持。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 根据当前体重刷新标题文案。
    func updateCurrentWeight(_ weight: Double) {
        let exceededWeight = Int(weight / 0.9)
        titleLabel.text = "你的体重是否曾超过 \(exceededWeight) kg？"
        titleLabel.setLineHeight(textString: titleLabel.text ?? "", lineHeight: guide0820Design(72))
    }

    /// 将当前选择写入问卷模型。
    override func commitCurrentValue() {
        Guide0820Model.shared.guidanceBodyWeightExceededType = selectedValue ?? ""
    }

    /// 恢复本地保存的选择。
    func restore(selectedValue: String?) {
        self.selectedValue = selectedValue
        commitCurrentValue()
    }

    /// 按 MasterGo 设计稿创建标题和三张选项卡。
    private func initUI() {
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: guide0820Design(48), weight: .medium)
        titleLabel.numberOfLines = 0
        updateCurrentWeight(60)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(42))
            make.right.equalTo(guide0820Design(-42))
            make.top.equalTo(guide0820Design(262))
        }

        let items = [
            Guide0820BodyProfileOption(title: "是", iconText: "↑", iconName: "guide0820_answer_yes_icon", value: "yes"),
            Guide0820BodyProfileOption(title: "否", iconText: "↓", iconName: "guide0820_answer_no_icon", value: "no"),
            Guide0820BodyProfileOption(title: "不确定", iconText: "?", iconName: "guide0820_answer_unknown_icon", value: "unknown")
        ]
        layoutCards(items: items, below: titleLabel)
    }

    /// 从标题下方依次排布选项卡。
    private func layoutCards(items: [Guide0820BodyProfileOption], below titleLabel: UILabel) {
        var previous: UIView = titleLabel
        items.forEach { item in
            let card = Guide0820BodyProfileOptionCard(item: item, usesCheckStateImages: true)
            card.addTarget(self, action: #selector(optionCardAction(_:)), for: .touchUpInside)
            addSubview(card)
            card.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(guide0820Design(42))
                make.top.equalTo(previous.snp.bottom).offset(previous === titleLabel ? guide0820Design(44) : guide0820Design(24))
                make.height.equalTo(guide0820Design(160))
            }
            cards.append(card)
            previous = card
        }
    }

    /// 处理答案卡点击并更新选择值。
    @objc private func optionCardAction(_ sender: Guide0820BodyProfileOptionCard) {
        selectedValue = sender.value
    }
}
