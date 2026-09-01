//
//  GuidanceGoalPlanFatLossModeVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

/// GuidanceGoalPlanFatLossModeVM 类型，封装 Guide0820 引导流程中的相关功能。
final class GuidanceGoalPlanFatLossModeVM: GuidanceGoalPlanChoicePageVM {
    // `flowState` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let flowState: GuidanceGoalPlanFlowState

    /// 初始化当前类型实例。
    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        super.init(
            title: "你更倾向于哪种减脂方式？",
            subtitle: "不同的减脂方式，不仅会影响你每天需要摄入多少热量，也会影响蛋白质、碳水和脂肪如何分配",
            options: [
                GuidanceGoalPlanOption(title: "最快速度减脂", detail: "适合希望在短时间内达到身材目标，例如拍摄写真、参加活动等。反弹风险较高", value: "fast", iconName: "guide0820_fat_loss_mode_fast_icon"),
                GuidanceGoalPlanOption(title: "相对快速减脂", detail: "适合希望在较短时间内达到身材目标，或准备健美比赛的运动员、健身爱好者等。有一定反弹风险", value: "moderate", iconName: "guide0820_fat_loss_mode_moderate_icon"),
                GuidanceGoalPlanOption(title: "平稳持续减脂", detail: "适合希望长期改善身材与健康的人群。反弹风险较低", value: "steady", iconName: "guide0820_fat_loss_mode_steady_icon")
            ],
            accentColor: GuidanceGoalPlanStyle.muscleGainColor,
            detailOnlyWhenSelected: true,
            infoNoticeText: nil
        )
        selectedValue = flowState.fatLossMode
        valueChanged = { [weak self] _ in
            self?.syncToState()
        }
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// GuidanceGoalPlanFatLossModeVM 扩展，提供 Guide0820 流程相关的辅助能力。
private extension GuidanceGoalPlanFatLossModeVM {
    // 执行 `syncToState` 操作，完成当前引导页面的状态更新或交互处理。
    func syncToState() {
        flowState.fatLossMode = selectedValue
        switch selectedValue {
        case "fast":
            flowState.fatLossDurationWeeks = 3
        case "moderate":
            flowState.fatLossDurationWeeks = 12
        case "steady":
            flowState.fatLossDurationWeeks = 18
        default:
            flowState.fatLossDurationWeeks = 12
        }
    }
}
