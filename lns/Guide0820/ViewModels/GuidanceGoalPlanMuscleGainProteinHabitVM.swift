//
//  GuidanceGoalPlanMuscleGainProteinHabitVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

final class GuidanceGoalPlanMuscleGainProteinHabitVM: GuidanceGoalPlanChoicePageVM {
    private let flowState: GuidanceGoalPlanFlowState

    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        super.init(
            title: "你习惯高蛋白饮食吗？",
            subtitle: "通过了解你的蛋白质摄入习惯，为你安排更合适、更容易执行的蛋白质目标",
            options: [
                GuidanceGoalPlanOption(title: "比较习惯", detail: "蛋白质摄入较高", value: "high", iconName: "guide0820_protein_habit_icon"),
                GuidanceGoalPlanOption(title: "一般", detail: "蛋白质摄入适中", value: "medium", iconName: "guide0820_protein_habit_icon"),
                GuidanceGoalPlanOption(title: "不太习惯", detail: "蛋白质摄入较低", value: "low", iconName: "guide0820_protein_habit_icon")
            ],
            accentColor: GuidanceGoalPlanStyle.muscleGainColor,
            layout: .proteinHabit
        )
        selectedValue = flowState.muscleGainProteinHabit
        valueChanged = { [weak self] _ in
            self?.flowState.muscleGainProteinHabit = self?.selectedValue ?? ""
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
