//
//  GuidanceGoalPlanFatLossProfileVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

final class GuidanceGoalPlanFatLossProfileVM: GuidanceGoalPlanChoicePageVM {
    private let flowState: GuidanceGoalPlanFlowState

    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        super.init(
            title: "以下哪种描述最符合你？",
            options: [
                GuidanceGoalPlanOption(title: "日常训练者", detail: "我经常运动，也会关注饮食，希望改善健康以及面部和身体线条", value: "daily_training"),
                GuidanceGoalPlanOption(title: "规律健身者", detail: "我保持规律训练和饮食，希望降低体脂，达到个人身材目标", value: "regular_fitness"),
                GuidanceGoalPlanOption(title: "健美运动员", detail: "我以比赛为目标，希望提升肌肉清晰度、分离度与整体状态", value: "bodybuilder"),
                GuidanceGoalPlanOption(title: "HYROX 运动员", detail: "我希望优化体重与能量供给，提升跑步效率、力量耐力和恢复能力", value: "hyrox"),
                GuidanceGoalPlanOption(title: "耐力运动员", detail: "我希望减少不必要的体重负担，提高骑行、越野跑等项目的运动效率", value: "endurance_athlete")
            ],
            accentColor: GuidanceGoalPlanStyle.fatLossColor
        )
        selectedValue = flowState.fatLossProfile
        valueChanged = { [weak self] _ in
            self?.flowState.fatLossProfile = self?.selectedValue ?? ""
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
