//
//  Guide0820BodyProfileSexVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 性别选择页 VM，负责选项卡、说明卡和性别字段提交。
final class Guide0820BodyProfileSexVM: Guide0820BodyProfilePageVM {
    /// 点击说明卡时通知外层 VC 展示弹窗。
    var showTipsBlock: (() -> Void)?

    /// 性别变更通知，用于同步身体资料页的默认身高和体重。
    var sexChangedBlock: ((String) -> Void)?

    /// 当前选择的性别值，变化时同步卡片选中态和页面有效性。
    var selectedSex: String? {
        didSet {
            cards.forEach {
                $0.setSelected($0.value == selectedSex, animated: true)
            }
            commitCurrentValue()
            if let selectedSex {
                sexChangedBlock?(selectedSex)
            }
            validityChanged?(isStepValid)
        }
    }

    /// 页面中的性别选项卡集合。
    private var cards: [Guide0820BodyProfileOptionCard] = []

    /// 只有选择了性别后才允许继续。
    override var isStepValid: Bool { selectedSex != nil }

    /// 初始化并搭建页面 UI。
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    /// Storyboard 初始化入口，本页面不支持。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 将性别选择写入问卷模型。
    override func commitCurrentValue() {
        Guide0820Model.shared.sex = selectedSex ?? ""
    }

    /// 恢复本地保存的性别选择。
    func restore(selectedSex: String?) {
        self.selectedSex = selectedSex
        commitCurrentValue()
    }

    /// 按 MasterGo 设计稿创建标题、选项卡和说明卡。
    private func initUI() {
        let titleLabel = makeTitleLabel("你的性别是？")
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(42))
            make.right.equalTo(guide0820Design(-42))
            make.top.equalTo(guide0820Design(262))
        }

        let items = [
            Guide0820BodyProfileOption(title: "女", iconText: "♀", iconName: "guide0820_sex_female_icon", value: "2"),
            Guide0820BodyProfileOption(title: "男", iconText: "♂", iconName: "guide0820_sex_male_icon", value: "1")
        ]

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

        let infoCard = Guide0820BodyProfileInfoCard(
            title: "荷尔蒙：无法被忽略的变量",
            detail: "在营养与运动生理学中，生理性别并非形式项，而是初始估算的重要变量..."
        )
        infoCard.addTarget(self, action: #selector(infoCardAction), for: .touchUpInside)
        addSubview(infoCard)
        infoCard.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(42))
            make.top.equalTo(previous.snp.bottom).offset(guide0820Design(24))
            make.height.equalTo(guide0820Design(178))
        }
    }

    /// 处理性别卡点击并更新选中值。
    @objc private func optionCardAction(_ sender: Guide0820BodyProfileOptionCard) {
        selectedSex = sender.value
    }

    /// 处理说明卡点击。
    @objc private func infoCardAction() {
        showTipsBlock?()
    }
}
