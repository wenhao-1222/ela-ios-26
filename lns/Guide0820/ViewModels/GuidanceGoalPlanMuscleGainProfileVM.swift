//
//  GuidanceGoalPlanMuscleGainProfileVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

final class GuidanceGoalPlanMuscleGainProfileVM: GuidanceGoalPlanChoicePageVM {
    private let flowState: GuidanceGoalPlanFlowState

    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        super.init(
            title: "以下哪种描述最符合你？",
            options: [
                GuidanceGoalPlanOption(title: "日常训练者", detail: "我经常运动，也会关注饮食，希望增加肌肉围度，改善身体比例与整体形态", value: "daily_training"),
                GuidanceGoalPlanOption(title: "规律健身者", detail: "我保持规律训练和饮食，希望进一步增加肌肉量，达到个人身材目标", value: "regular_fitness"),
                GuidanceGoalPlanOption(title: "健美运动员", detail: "我以比赛为目标，希望提升肌肉量、肌群比例与整体完整度", value: "bodybuilder"),
                GuidanceGoalPlanOption(title: "HYROX 运动员", detail: "我需要兼顾跑步、力量耐力与体重管理，希望提升 HYROX 综合成绩", value: "hyrox"),
                GuidanceGoalPlanOption(title: "力量运动员", detail: "我以提升力量为主要目标，需要通过充足的能量与营养支持训练表现和恢复", value: "strength_athlete")
            ],
            accentColor: GuidanceGoalPlanStyle.muscleGainColor
        )
        selectedValue = flowState.muscleGainProfile
        valueChanged = { [weak self] _ in
            self?.flowState.muscleGainProfile = self?.selectedValue ?? ""
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
