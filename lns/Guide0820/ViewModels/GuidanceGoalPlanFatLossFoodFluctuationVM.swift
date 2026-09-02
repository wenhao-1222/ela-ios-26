//
//  GuidanceGoalPlanFatLossFoodFluctuationVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

/// GuidanceGoalPlanFatLossFoodFluctuationVM 类型，封装 Guide0820 引导流程中的相关功能。
final class GuidanceGoalPlanFatLossFoodFluctuationVM: GuidanceGoalPlanChoicePageVM {
    // `flowState` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let flowState: GuidanceGoalPlanFlowState

    /// 初始化当前类型实例。
    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        super.init(
            title: "通常吃完哪类食物后\n你的体重波动会更明显？",
            subtitle: "每个人对碳水和脂肪的反应存在差异，了解你的情况，有助于更合理地安排减脂目标",
            options: [
                GuidanceGoalPlanOption(title: "高碳水食物", detail: "面食、米饭等", value: "high_carb", iconName: "guide0820_fat_loss_food_fluctuation_high_carb_icon"),
                GuidanceGoalPlanOption(title: "高脂食物", detail: "烤肉、油炸食物等", value: "high_fat", iconName: "guide0820_fat_loss_food_fluctuation_high_fat_icon"),
                GuidanceGoalPlanOption(title: "不确定", detail: nil, value: "uncertain", iconName: "guide0820_answer_unknown_icon")
            ],
            accentColor: GuidanceGoalPlanStyle.muscleGainColor,
            layout: .goal
        )
        selectedValue = flowState.fatLossFoodFluctuation
        valueChanged = { [weak self] _ in
            self?.flowState.fatLossFoodFluctuation = self?.selectedValue ?? ""
        }
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
