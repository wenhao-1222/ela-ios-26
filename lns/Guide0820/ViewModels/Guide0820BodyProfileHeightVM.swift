//
//  Guide0820BodyProfileHeightVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 身高页 VM，负责垂直刻度尺、身高数值展示和身高字段提交。
final class Guide0820BodyProfileHeightVM: Guide0820BodyProfilePageVM, rulerDelegate {
    /// 当前身高值，单位为厘米。
    var currentValue = 170

    /// 左侧显示当前身高的富文本 Label。
    private let numberLabel = UILabel()

    /// 项目内已有的垂直刻度尺控件。
    private let rulerView = TTScrollRulerView(frame: .zero)

    /// 刻度变化时的轻触反馈。
    private let feedbackGenerator = UISelectionFeedbackGenerator()

    /// 初始化并搭建页面 UI。
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    /// Storyboard 初始化入口，本页面不支持。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 将当前身高写入问卷模型。
    override func commitCurrentValue() {
        QuestinonaireMsgModel.shared.height = "\(currentValue)"
    }

    /// 按 MasterGo 设计稿创建标题、数值和刻度尺。
    private func initUI() {
        let titleLabel = makeTitleLabel("你的身高是？")
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(42))
            make.right.equalTo(guide0820Design(-42))
            make.top.equalTo(guide0820Design(262))
        }

        addSubview(rulerView)

        numberLabel.textAlignment = .right
        addSubview(numberLabel)
        numberLabel.snp.makeConstraints { make in
            make.right.equalTo(rulerView.snp.left).offset(guide0820Design(-64))
            make.centerY.equalTo(rulerView)
        }

        rulerView.backgroundColor = .clear
        rulerView.rulerBackgroundColor = .clear
        rulerView.rulerDelegate = self
        rulerView.rulerDirection = .vertical
        rulerView.rulerFace = .down_right
        rulerView.lockMax = 240
        rulerView.lockMin = 110
        rulerView.lockDefault = rulerView.lockMax + rulerView.lockMin - currentValue
        rulerView.pointerBackgroundColor = .THEME
        rulerView.h_height = Float(guide0820Design(112))
        rulerView.m_height = Float(guide0820Design(68))
        rulerView.customRuler(with: customColorMake(217.0 / 255.0, 217.0 / 255.0, 217.0 / 255.0),
                              numColor: .COLOR_TEXT_TITLE_0f1214_20,
                              scrollEnable: true)
        rulerView.unitValue = 1
        rulerView.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(371))
            make.top.equalTo(guide0820Design(440))
            make.width.equalTo(guide0820Design(264))
            make.height.equalTo(guide0820Design(712))
        }

        updateHeightText(value: currentValue)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.layoutIfNeeded()
            self.rulerView.classicRuler()
            self.rulerView.scroll(toValue: self.currentValue, animation: false)
        }
        commitCurrentValue()
        feedbackGenerator.prepare()
    }

    /// 更新身高富文本，包含蓝色数字和黑色单位。
    private func updateHeightText(value: Int) {
        let text = NSMutableAttributedString(string: "\(value)")
        text.addAttributes([
            .foregroundColor: UIColor.THEME,
            .font: UIFont().DDInFontMedium(fontSize: guide0820Design(80))
        ], range: NSRange(location: 0, length: text.length))
        let unit = NSAttributedString(
            string: " 厘米",
            attributes: [
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .font: UIFont.systemFont(ofSize: guide0820Design(24), weight: .regular)
            ]
        )
        text.append(unit)
        numberLabel.attributedText = text
    }

    /// 接收刻度尺滚动回调，更新数值、触感和问卷模型。
    func ruler(with value: Int) {
        if currentValue != value {
            feedbackGenerator.selectionChanged()
            feedbackGenerator.prepare()
        }
        currentValue = value
        updateHeightText(value: value)
        commitCurrentValue()
    }
}
