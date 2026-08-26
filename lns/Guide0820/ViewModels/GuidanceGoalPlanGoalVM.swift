//
//  GuidanceGoalPlanGoalVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

final class GuidanceGoalPlanGoalVM: GuidanceGoalPlanChoicePageVM {
    private let flowState: GuidanceGoalPlanFlowState

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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension GuidanceGoalPlanGoalVM {
    func syncToState() {
        guard let target = GuidanceGoalPlanTarget(rawValue: selectedValue) else { return }
        flowState.target = target
    }
}
