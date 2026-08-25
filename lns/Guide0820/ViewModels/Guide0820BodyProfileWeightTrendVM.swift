//
//  Guide0820BodyProfileWeightTrendVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 近四周体重趋势页 VM。
final class Guide0820BodyProfileWeightTrendVM: Guide0820BodyProfilePageVM {
    /// 页面中的趋势选项卡集合。
    private var cards: [Guide0820BodyProfileOptionCard] = []

    /// 当前选择值，变化时同步卡片选中态和页面有效性。
    private var selectedValue: String? {
        didSet {
            cards.forEach { $0.isSelected = $0.value == selectedValue }
            validityChanged?(isStepValid)
        }
    }

    /// 当前选择值。
    var selectedTrendValue: String? { selectedValue }

    /// 只有选择趋势后才允许继续。
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

    /// 将当前选择写入问卷模型。
    override func commitCurrentValue() {
        QuestinonaireMsgModel.shared.guidanceRecentWeightTrendType = selectedValue ?? ""
    }

    /// 恢复本地保存的选择。
    func restore(selectedValue: String?) {
        self.selectedValue = selectedValue
        commitCurrentValue()
    }

    /// 按 MasterGo 设计稿创建标题和趋势选项卡。
    private func initUI() {
        let titleLabel = makeTitleLabel("过去 4 周，\n你的体重整体如何变化？")
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(42))
            make.right.equalTo(guide0820Design(-42))
            make.top.equalTo(guide0820Design(262))
        }

        let items = [
            Guide0820BodyProfileOption(title: "基本稳定", subtitle: "上下变化不大", iconText: "=", iconName: "guide0820_weight_trend_stable_icon", value: "stable"),
            Guide0820BodyProfileOption(title: "持续上升", subtitle: "整体呈上升趋势", iconText: "↑", iconName: "guide0820_weight_trend_up_icon", value: "up"),
            Guide0820BodyProfileOption(title: "持续下降", subtitle: "整体呈下降趋势", iconText: "↓", iconName: "guide0820_weight_trend_down_icon", value: "down"),
            Guide0820BodyProfileOption(title: "经常反复", subtitle: "下降或上升后又很快回到原位", iconText: "~", iconName: "guide0820_weight_trend_fluctuate_icon", value: "fluctuate")
        ]

        var previous: UIView = titleLabel
        items.forEach { item in
            let card = Guide0820BodyProfileOptionCard(item: item)
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

    /// 处理趋势卡点击并更新选择值。
    @objc private func optionCardAction(_ sender: Guide0820BodyProfileOptionCard) {
        selectedValue = sender.value
    }
}
