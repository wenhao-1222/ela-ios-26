//
//  VCStartRootView.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// “让我们开始吧”页面根视图。
final class VCStartRootView: UIView {
    /// 页面视图模型。
    private let vm: VCStartVM
    /// 点击开始按钮回调。
    private let onStart: () -> Void
    /// 标题标签。
    private let titleLabel = UILabel()
    /// 副标题标签。
    private let subtitleLabel = UILabel()
    /// 步骤列表容器。
    private let stepsContainerView = UIView()
    /// 底部开始按钮。
    private lazy var startButton = Guide0820PrimaryButton(title: vm.buttonTitle, action: onStart)

    /// 创建开始页根视图。
    /// - Parameters:
    ///   - vm: 页面视图模型。
    ///   - onStart: 点击开始按钮回调。
    init(vm: VCStartVM, onStart: @escaping () -> Void) {
        self.vm = vm
        self.onStart = onStart
        super.init(frame: .zero)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 刷新步骤状态。
    func reloadSteps() {
        stepsContainerView.subviews.forEach { $0.removeFromSuperview() }
        stepsContainerView.snp.updateConstraints { make in
            make.height.equalTo(stepsContainerHeight())
        }
        buildStepRows()
    }
}

// VCStartRootView 扩展，提供 Guide0820 流程相关的辅助能力。
private extension VCStartRootView {
    /// 初始化页面布局。
    func initUI() {
        backgroundColor = .COLOR_BG_F2

        titleLabel.text = vm.title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: kFitWidth(24), weight: .medium)
        titleLabel.guide0820SetLineHeight(kFitWidth(36))

        subtitleLabel.text = vm.subtitle
        subtitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        subtitleLabel.font = .systemFont(ofSize: kFitWidth(14), weight: .regular)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.guide0820SetLineHeight(kFitWidth(21))

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(stepsContainerView)
        addSubview(startButton)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(40))
            make.top.equalToSuperview().offset(kFitWidth(165.5))
            make.height.equalTo(kFitWidth(36))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            make.right.equalTo(kFitWidth(-32))
            make.height.equalTo(kFitWidth(21))
        }

        stepsContainerView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(40))
            make.top.equalToSuperview().offset(kFitWidth(273.5))
            make.width.equalTo(kFitWidth(295))
            make.height.equalTo(stepsContainerHeight())
        }

        startButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(16))
            make.height.equalTo(kFitWidth(52))
            make.bottom.equalToSuperview().offset(-max(WHUtils().getBottomSafeAreaHeight(), kFitWidth(26)))
        }

        buildStepRows()
    }

    /// 创建步骤行。
    func buildStepRows() {
        let steps = vm.steps
        let activeIndex = steps.firstIndex { $0.isActive } ?? 0
        let layout = stepLayout(activeIndex: activeIndex)

        buildStepLines(activeIndex: activeIndex, layout: layout)

        steps.enumerated().forEach { index, step in
            let row = VCStartStepRow(vm: step, showsBottomLine: false)
            stepsContainerView.addSubview(row)
            row.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview().offset(layout.rowTopOffsets[index])
                make.height.equalTo(rowContentHeight(isActive: step.isActive))
            }
        }
    }

    /// 当前步骤列表总高度。
    func stepsContainerHeight() -> CGFloat {
        let activeIndex = vm.steps.firstIndex { $0.isActive } ?? 0
        return stepLayout(activeIndex: activeIndex).containerHeight
    }

    /// 绘制步骤之间的连接线。
    func buildStepLines(activeIndex: Int, layout: StepLayout) {
        layout.lineFrames.enumerated().forEach { index, frame in
            let lineView = UIView()
            lineView.backgroundColor = index < activeIndex
                ? .THEME
                : UIColor.COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.05)
            stepsContainerView.addSubview(lineView)
            lineView.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(frame.minX)
                make.top.equalToSuperview().offset(frame.minY)
                make.width.equalTo(frame.width)
                make.height.equalTo(frame.height)
            }
        }
    }

    /// 单个步骤行的内容高度。
    func rowContentHeight(isActive: Bool) -> CGFloat {
        isActive ? kFitWidth(77) : kFitWidth(34)
    }

    /// 根据当前主步骤匹配 MasterGo 三个状态的固定布局。
    func stepLayout(activeIndex: Int) -> StepLayout {
        let lineX = kFitWidth(16.5)
        let lineWidth = kFitWidth(2)

        switch activeIndex {
        case 1:
            return StepLayout(
                rowTopOffsets: [kFitWidth(0), kFitWidth(52.5), kFitWidth(148)],
                lineFrames: [
                    CGRect(x: lineX, y: kFitWidth(33), width: lineWidth, height: kFitWidth(41)),
                    CGRect(x: lineX, y: kFitWidth(108), width: lineWidth, height: kFitWidth(40))
                ],
                containerHeight: kFitWidth(182)
            )
        case 2:
            return StepLayout(
                rowTopOffsets: [kFitWidth(0), kFitWidth(74), kFitWidth(128)],
                lineFrames: [
                    CGRect(x: lineX, y: kFitWidth(33), width: lineWidth, height: kFitWidth(41)),
                    CGRect(x: lineX, y: kFitWidth(108), width: lineWidth, height: kFitWidth(40))
                ],
                containerHeight: kFitWidth(205)
            )
        default:
            return StepLayout(
                rowTopOffsets: [kFitWidth(0), kFitWidth(105.5), kFitWidth(169.5)],
                lineFrames: [
                    CGRect(x: lineX, y: kFitWidth(54.5), width: lineWidth, height: kFitWidth(51)),
                    CGRect(x: lineX, y: kFitWidth(139.5), width: lineWidth, height: kFitWidth(30))
                ],
                containerHeight: kFitWidth(203.5)
            )
        }
    }
}

// StepLayout 类型，封装 Guide0820 引导流程中的相关功能。
private struct StepLayout {
    // `rowTopOffsets` 属性，保存该类型对外提供或内部使用的状态与配置。
    let rowTopOffsets: [CGFloat]
    // `lineFrames` 属性，保存该类型对外提供或内部使用的状态与配置。
    let lineFrames: [CGRect]
    // `containerHeight` 属性，保存该类型对外提供或内部使用的状态与配置。
    let containerHeight: CGFloat
}
