//
//  GuidanceGoalPlanProfileVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

final class GuidanceGoalPlanProfileVM: GuidanceGoalPlanChoicePageVM {
    private let flowState: GuidanceGoalPlanFlowState
    private let target: GuidanceGoalPlanTarget

    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        self.target = flowState.target ?? .muscleGain
        super.init(
            title: "以下哪种描述最符合你？",
            options: Self.options(for: target),
            accentColor: target.accentColor,
            layout: .profile
        )
        selectedValue = selectedValueFromState()
        valueChanged = { [weak self] _ in
            self?.syncToState()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension GuidanceGoalPlanProfileVM {
    func selectedValueFromState() -> String {
        switch target {
        case .muscleGain:
            return flowState.muscleGainProfile
        case .fatLoss:
            return flowState.fatLossProfile
        }
    }

    func syncToState() {
        switch target {
        case .muscleGain:
            flowState.muscleGainProfile = selectedValue
        case .fatLoss:
            flowState.fatLossProfile = selectedValue
        }
    }

    static func options(for target: GuidanceGoalPlanTarget) -> [GuidanceGoalPlanOption] {
        switch target {
        case .muscleGain:
            return [
                GuidanceGoalPlanOption(title: "日常训练者", detail: "我经常运动，也会关注饮食，希望增加肌肉围度，改善身体比例与整体形态", value: "daily_training", iconName: "guide0820_profile_daily_training_icon"),
                GuidanceGoalPlanOption(title: "规律健身者", detail: "我保持规律训练和饮食，希望进一步增加肌肉量，达到个人身材目标", value: "regular_fitness", iconName: "guide0820_profile_regular_fitness_icon"),
                GuidanceGoalPlanOption(title: "健美运动员", detail: "我以比赛为目标，希望提升肌肉量、肌群比例与整体完整度", value: "bodybuilder", iconName: "guide0820_profile_bodybuilder_icon"),
                GuidanceGoalPlanOption(title: "HYROX 运动员", detail: "我需要兼顾跑步、力量耐力与体重管理，希望提升 HYROX 综合成绩", value: "hyrox", iconName: "guide0820_profile_hyrox_icon"),
                GuidanceGoalPlanOption(title: "力量运动员", detail: "我以提升力量为主要目标，需要通过充足的能量与营养支持训练表现和恢复", value: "strength_athlete", iconName: "guide0820_profile_strength_athlete_icon")
            ]
        case .fatLoss:
            return [
                GuidanceGoalPlanOption(title: "日常训练者", detail: "我经常运动，也会关注饮食，希望改善健康以及面部和身体线条", value: "daily_training", iconName: "guide0820_profile_daily_training_icon"),
                GuidanceGoalPlanOption(title: "规律健身者", detail: "我保持规律训练和饮食，希望降低体脂，达到个人身材目标", value: "regular_fitness", iconName: "guide0820_profile_regular_fitness_icon"),
                GuidanceGoalPlanOption(title: "健美运动员", detail: "我以比赛为目标，希望提升肌肉清晰度、分离度与整体状态", value: "bodybuilder", iconName: "guide0820_profile_bodybuilder_icon"),
                GuidanceGoalPlanOption(title: "HYROX 运动员", detail: "我希望优化体重与能量供给，提升跑步效率、力量耐力和恢复能力", value: "hyrox", iconName: "guide0820_profile_hyrox_icon"),
                GuidanceGoalPlanOption(title: "耐力运动员", detail: "我希望减少不必要的体重负担，提高骑行、越野跑等项目的运动效率", value: "endurance_athlete", iconName: "Image 60")
            ]
        }
    }
}
