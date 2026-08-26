//
//  GuidanceGoalPlanFatLossModeVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

final class GuidanceGoalPlanFatLossModeVM: GuidanceGoalPlanChoicePageVM {
    private let flowState: GuidanceGoalPlanFlowState

    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        super.init(
            title: "你更倾向于哪种减脂方式？",
            subtitle: "不同的减脂方式，不仅会影响你每天需要摄入多少热量，也会影响蛋白质、碳水和脂肪如何分配",
            options: [
                GuidanceGoalPlanOption(title: "最快速度减脂", detail: "适合希望在短时间内达到身材目标，例如拍摄写真、参加活动等。反弹风险较高", value: "fast"),
                GuidanceGoalPlanOption(title: "相对快速减脂", detail: "适合希望在较短时间内达到身材目标，或准备健美比赛的运动员、健身爱好者等。有一定反弹风险", value: "moderate"),
                GuidanceGoalPlanOption(title: "平稳持续减脂", detail: "适合希望长期改善身材与健康的人群。反弹风险较低", value: "steady")
            ],
            accentColor: GuidanceGoalPlanStyle.fatLossColor
        )
        selectedValue = flowState.fatLossMode
        valueChanged = { [weak self] _ in
            self?.syncToState()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension GuidanceGoalPlanFatLossModeVM {
    func syncToState() {
        flowState.fatLossMode = selectedValue
        switch selectedValue {
        case "fast":
            flowState.fatLossDurationWeeks = 3
        case "steady":
            flowState.fatLossDurationWeeks = 18
        default:
            flowState.fatLossDurationWeeks = 12
        }
    }
}
