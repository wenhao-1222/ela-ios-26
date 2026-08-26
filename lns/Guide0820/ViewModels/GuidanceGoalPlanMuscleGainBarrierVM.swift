//
//  GuidanceGoalPlanMuscleGainBarrierVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

final class GuidanceGoalPlanMuscleGainBarrierVM: GuidanceGoalPlanChoicePageVM {
    private let flowState: GuidanceGoalPlanFlowState

    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        super.init(
            title: "你在增肌时更容易遇到哪种饮食阻碍？",
            subtitle: "每个人的消化和进食能力不同，了解你的情况，有助于更合理地安排热量目标",
            options: [
                GuidanceGoalPlanOption(title: "消化较慢", detail: "进食后饱腹感会持续较长时间", value: "slow_digestion"),
                GuidanceGoalPlanOption(title: "单餐食量较小", detail: "一次吃不下太多食物", value: "small_meal_capacity"),
                GuidanceGoalPlanOption(title: "不确定", detail: nil, value: "uncertain")
            ],
            accentColor: GuidanceGoalPlanStyle.muscleGainColor
        )
        selectedValue = flowState.muscleGainBarrier
        valueChanged = { [weak self] _ in
            self?.flowState.muscleGainBarrier = self?.selectedValue ?? ""
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
