//
//  GuidanceGoalPlanMuscleGainModeVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

final class GuidanceGoalPlanMuscleGainModeVM: GuidanceGoalPlanChoicePageVM {
    private let flowState: GuidanceGoalPlanFlowState

    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        super.init(
            title: "你更倾向于哪种增肌方式？",
            subtitle: "不同的增肌方式，不仅会影响你每天需要摄入多少热量，也会影响蛋白质、碳水和脂肪如何分配",
            options: [
                GuidanceGoalPlanOption(title: "更注重增肌质量", detail: "适合希望在增肌过程中尽可能控制脂肪增长，并维持较低体脂水平的运动员、健身爱好者等", value: "quality", iconName: "guide0820_muscle_gain_mode_quality_icon"),
                GuidanceGoalPlanOption(title: "平衡增肌质量与速度", detail: "适合希望兼顾肌肉增长速度与脂肪控制，稳步增加肌肉量和身体围度的运动员、健身爱好者等", value: "balanced", iconName: "guide0820_muscle_gain_mode_balanced_icon"),
                GuidanceGoalPlanOption(title: "更注重增肌速度", detail: "适合希望在较短时间内最大化增加体重和肌肉围度的偏瘦人群，通常也会伴随更多脂肪增长", value: "speed", iconName: "guide0820_muscle_gain_mode_speed_icon")
            ],
            accentColor: GuidanceGoalPlanStyle.muscleGainColor,
            detailOnlyWhenSelected: true
        )
        selectedValue = flowState.muscleGainMode
        valueChanged = { [weak self] _ in
            self?.syncToState()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension GuidanceGoalPlanMuscleGainModeVM {
    func syncToState() {
        flowState.muscleGainMode = selectedValue
        switch selectedValue {
        case "speed":
            flowState.muscleGainDurationWeeks = 10
        default:
            flowState.muscleGainDurationWeeks = 12
        }
    }
}
