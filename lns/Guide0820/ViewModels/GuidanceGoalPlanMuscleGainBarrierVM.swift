//
//  GuidanceGoalPlanMuscleGainBarrierVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

/// GuidanceGoalPlanMuscleGainBarrierVM 类型，封装 Guide0820 引导流程中的相关功能。
final class GuidanceGoalPlanMuscleGainBarrierVM: GuidanceGoalPlanChoicePageVM {
    // `flowState` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let flowState: GuidanceGoalPlanFlowState

    /// 初始化当前类型实例。
    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        super.init(
            title: "你在增肌时\n更容易遇到哪种饮食阻碍？",
            subtitle: "每个人的消化和进食能力不同，了解你的情况，有助于更合理地安排热量目标",
            options: [
                GuidanceGoalPlanOption(title: "消化较慢", detail: "进食后饱腹感会持续较长时间", value: "slow_digestion", iconName: "guide0820_muscle_gain_barrier_slow_digestion_icon"),
                GuidanceGoalPlanOption(title: "单餐食量较小", detail: "一次吃不下太多食物", value: "small_meal_capacity", iconName: "guide0820_muscle_gain_barrier_small_meal_capacity_icon"),
                GuidanceGoalPlanOption(title: "不确定", detail: nil, value: "uncertain", iconName: "guide0820_answer_unknown_icon")
            ],
            accentColor: GuidanceGoalPlanStyle.muscleGainColor,
            layout: .goal
        )
        selectedValue = flowState.muscleGainBarrier
        valueChanged = { [weak self] _ in
            self?.flowState.muscleGainBarrier = self?.selectedValue ?? ""
        }
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
