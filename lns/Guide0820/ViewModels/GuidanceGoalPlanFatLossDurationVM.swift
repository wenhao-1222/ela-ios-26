//
//  GuidanceGoalPlanFatLossDurationVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

final class GuidanceGoalPlanFatLossDurationVM: GuidanceGoalPlanDurationPageVM {
    private let flowState: GuidanceGoalPlanFlowState

    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        let recommendation = Self.recommendation(for: flowState.fatLossMode)
        super.init(
            title: "你准备为这个减脂期规划多长时间？",
            accentColor: GuidanceGoalPlanStyle.fatLossColor,
            defaultWeeks: flowState.fatLossDurationWeeks,
            recommendationTitle: recommendation.title,
            recommendationDetail: recommendation.detail
        )
        weeksChanged = { [weak self] weeks in
            self?.flowState.fatLossDurationWeeks = weeks
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func pageWillAppear() {
        let recommendation = Self.recommendation(for: flowState.fatLossMode)
        updateRecommendation(defaultWeeks: flowState.fatLossDurationWeeks, title: recommendation.title, detail: recommendation.detail)
        super.pageWillAppear()
    }
}

private extension GuidanceGoalPlanFatLossDurationVM {
    static func recommendation(for mode: String) -> (title: String, detail: String) {
        switch mode {
        case "fast":
            return ("你的目标是在短时间内降低体脂", "为了尽可能保留肌肉量，并降低过度节食与反弹风险，我们建议你将周期控制在 3 周左右")
        case "steady":
            return ("你希望采取更平稳、更贴近日常生活的减脂方式", "为了让减脂过程更易执行并长期坚持，我们建议你至少预留 18 周")
        default:
            return ("我们明白你希望平衡减脂速度和稳定性", "为了降低过快减脂造成平台期的风险，并持续、稳定地降低体脂，建议至少预留 12 周")
        }
    }
}

