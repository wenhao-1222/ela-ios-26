//
//  GuidanceGoalPlanMuscleGainDurationVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

/// GuidanceGoalPlanMuscleGainDurationVM 类型，封装 Guide0820 引导流程中的相关功能。
final class GuidanceGoalPlanMuscleGainDurationVM: GuidanceGoalPlanDurationPageVM {
    // `flowState` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let flowState: GuidanceGoalPlanFlowState

    /// 初始化当前类型实例。
    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        let recommendation = Self.recommendation(for: flowState.muscleGainMode)
        super.init(
            title: "你准备为这个增肌期规划多长时间？",
            accentColor: GuidanceGoalPlanStyle.muscleGainColor,
            defaultWeeks: flowState.muscleGainDurationWeeks,
            recommendationTitle: recommendation.title,
            recommendationDetail: recommendation.detail,
            recommendationDetailLineHeight: guide0820Design(36),
            controlStyle: .customPicker
        )
        weeksChanged = { [weak self] weeks in
            self?.flowState.muscleGainDurationWeeks = weeks
        }
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 执行 `pageWillAppear` 操作，完成当前引导页面的状态更新或交互处理。
    override func pageWillAppear() {
        let recommendation = Self.recommendation(for: flowState.muscleGainMode)
        updateRecommendation(defaultWeeks: flowState.muscleGainDurationWeeks, title: recommendation.title, detail: recommendation.detail)
        super.pageWillAppear()
    }
}

// GuidanceGoalPlanMuscleGainDurationVM 扩展，提供 Guide0820 流程相关的辅助能力。
private extension GuidanceGoalPlanMuscleGainDurationVM {
    // 执行 `recommendation` 操作，完成当前引导页面的状态更新或交互处理。
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
