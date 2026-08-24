//
//  Guide0820BodyProfileWeightVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 当前体重页 VM，负责横向体重刻度尺、体重展示和说明卡。
final class Guide0820BodyProfileWeightVM: Guide0820BodyProfilePageVM {
    /// 点击说明卡时通知外层 VC 展示弹窗。
    var showTipsBlock: (() -> Void)?

    /// 体重变化回调，用于后续页面同步当前体重。
    var weightChangedBlock: ((Double) -> Void)?

    /// 当前体重值，单位为公斤。
    private var currentWeight = 60.0

    /// 顶部显示当前体重的富文本 Label。
    private let valueLabel = UILabel()

    /// 项目内已有的目标体重横向刻度尺。
    private let rulerView = DietPlanTargetWeightRulerView()

    /// 初始化并搭建页面 UI。
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    /// Storyboard 初始化入口，本页面不支持。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 将当前体重写入问卷模型。
    override func commitCurrentValue() {
        QuestinonaireMsgModel.shared.weight = String(format: "%.1f", currentWeight)
    }

    /// 按 MasterGo 设计稿创建标题、体重值、刻度尺和说明卡。
    private func initUI() {
        let titleLabel = makeTitleLabel("你现在的体重是？")
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(42))
            make.right.equalTo(guide0820Design(-42))
            make.top.equalTo(guide0820Design(262))
        }

        valueLabel.textAlignment = .center
        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(guide0820Design(612))
        }

        rulerView.minValue = 30
        rulerView.maxValue = 300
        rulerView.stepValue = 0.1
        rulerView.onValueChanged = { [weak self] value in
            self?.updateWeight(value)
        }
        addSubview(rulerView)
        rulerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(47))
            make.top.equalTo(valueLabel.snp.bottom).offset(guide0820Design(90))
            make.height.equalTo(guide0820Design(170))
        }

        let infoCard = Guide0820BodyProfileInfoCard(
            title: "什么时候称更准？",
            detail: "建议固定在早上起床排空后、进食饮水前称重。食物、水分和排便情况都会让体重短期波动..."
        )
        infoCard.addTarget(self, action: #selector(infoCardAction), for: .touchUpInside)
        addSubview(infoCard)
        infoCard.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(42))
            make.top.equalTo(guide0820Design(976))
            make.height.equalTo(guide0820Design(178))
        }

        updateWeight(currentWeight)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.rulerView.setValue(self.currentWeight, animated: false)
        }
    }

    /// 更新体重富文本、提交模型并通知外部当前体重变化。
    private func updateWeight(_ value: Double) {
        currentWeight = value
        let text = NSMutableAttributedString(string: String(format: "%.1f", value))
        text.addAttributes([
            .foregroundColor: UIColor.THEME,
            .font: UIFont().DDInFontMedium(fontSize: guide0820Design(80))
        ], range: NSRange(location: 0, length: text.length))
        let unit = NSAttributedString(
            string: " 公斤",
            attributes: [
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .font: UIFont.systemFont(ofSize: guide0820Design(24), weight: .regular)
            ]
        )
        text.append(unit)
        valueLabel.attributedText = text
        commitCurrentValue()
        weightChangedBlock?(value)
    }

    /// 处理说明卡点击。
    @objc private func infoCardAction() {
        showTipsBlock?()
    }
}
