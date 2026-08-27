//
//  GuidanceGoalPlanGoalVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

/// GuidanceGoalPlanGoalVM 类型，封装 Guide0820 引导流程中的相关功能。
final class GuidanceGoalPlanGoalVM: GuidanceGoalPlanChoicePageVM {
    // `flowState` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let flowState: GuidanceGoalPlanFlowState

    /// 初始化当前类型实例。
    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        super.init(
            title: "你的目标是什么？",
            subtitle: "你的目标会影响到你的缺口盈余，以及营养素分配",
            options: [
                GuidanceGoalPlanOption(
                    title: "增肌",
                    detail: nil,
                    value: GuidanceGoalPlanTarget.muscleGain.rawValue,
                    iconName: "guide0820_goal_muscle_gain_icon"
                ),
                GuidanceGoalPlanOption(
                    title: "减脂",
                    detail: nil,
                    value: GuidanceGoalPlanTarget.fatLoss.rawValue,
                    iconName: "guide0820_goal_fat_loss_icon"
                )
            ],
            accentColor: .THEME,
            layout: .goal
        )
        selectedValue = flowState.target?.rawValue ?? ""
        valueChanged = { [weak self] _ in
            self?.syncToState()
        }
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// GuidanceGoalPlanGoalVM 扩展，提供 Guide0820 流程相关的辅助能力。
private extension GuidanceGoalPlanGoalVM {
    // 执行 `syncToState` 操作，完成当前引导页面的状态更新或交互处理。
    func syncToState() {
        guard let target = GuidanceGoalPlanTarget(rawValue: selectedValue) else { return }
        flowState.target = target
    }
}
