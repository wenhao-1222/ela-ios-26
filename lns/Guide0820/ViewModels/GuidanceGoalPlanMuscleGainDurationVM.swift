//
//  GuidanceGoalPlanMuscleGainDurationVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

final class GuidanceGoalPlanMuscleGainDurationVM: GuidanceGoalPlanDurationPageVM {
    private let flowState: GuidanceGoalPlanFlowState

    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        let recommendation = Self.recommendation(for: flowState.muscleGainMode)
        super.init(
            title: "你准备为这个增肌期规划多长时间？",
            accentColor: GuidanceGoalPlanStyle.muscleGainColor,
            defaultWeeks: flowState.muscleGainDurationWeeks,
            recommendationTitle: recommendation.title,
            recommendationDetail: recommendation.detail
        )
        weeksChanged = { [weak self] weeks in
            self?.flowState.muscleGainDurationWeeks = weeks
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func pageWillAppear() {
        let recommendation = Self.recommendation(for: flowState.muscleGainMode)
        updateRecommendation(defaultWeeks: flowState.muscleGainDurationWeeks, title: recommendation.title, detail: recommendation.detail)
        super.pageWillAppear()
    }
}

private extension GuidanceGoalPlanMuscleGainDurationVM {
    static func recommendation(for mode: String) -> (title: String, detail: String) {
        switch mode {
        case "quality":
            return ("我们明白你更注重增肌质量", "为了更稳定地增加肌肉量，并减少不必要的脂肪增长，最好为这个阶段预留至少 12 周")
        case "speed":
            return ("你的目标是更快地增肌", "为了提高肌肉和体重的增长速度，同时避免脂肪增长过快，建议为这个阶段预留 10 周左右")
        default:
            return ("我们明白你希望兼顾增肌速度与脂肪控制", "为了在稳定增加肌肉量的同时控制脂肪增长，建议为这个阶段预留 12 周左右")
        }
    }
}

