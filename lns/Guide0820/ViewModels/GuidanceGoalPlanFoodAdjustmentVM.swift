//
//  GuidanceGoalPlanFoodAdjustmentVM.swift
//  lns
//
//  Created by Codex on 2026/8/27.
//

import UIKit

/// Final question shared by both the muscle-gain and fat-loss branches.
/// Users can select multiple ways of judging progress; “不调整” is exclusive.
final class GuidanceGoalPlanFoodAdjustmentVM: GuidanceGoalPlanChoicePageVM {
    private let flowState: GuidanceGoalPlanFlowState

    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        super.init(
            title: "你平时主要根据什么调整饮食？",
            options: [
                GuidanceGoalPlanOption(
                    title: "体测仪",
                    detail: nil,
                    value: "body_scale",
                    iconName: "guide0820_food_adjustment_body_scale_icon"
                ),
                GuidanceGoalPlanOption(
                    title: "看体重",
                    detail: nil,
                    value: "weight",
                    iconName: "guide0820_food_adjustment_weight_icon"
                ),
                GuidanceGoalPlanOption(
                    title: "照镜子",
                    detail: nil,
                    value: "mirror",
                    iconName: "guide0820_food_adjustment_mirror_icon"
                ),
                GuidanceGoalPlanOption(
                    title: "不调整",
                    detail: nil,
                    value: "none",
                    iconName: "guide0820_goal_fat_loss_icon"
                )
            ],
            accentColor: GuidanceGoalPlanStyle.muscleGainColor,
            layout: .goal,
            allowsMultipleSelection: true,
            mutuallyExclusiveValue: "none"
        )
        selectedValue = flowState.foodAdjustment
        valueChanged = { [weak self] _ in
            self?.flowState.foodAdjustment = self?.selectedValue ?? ""
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
