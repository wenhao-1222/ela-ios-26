//
//  GuidanceGoalPlanFatLossDurationVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

/// GuidanceGoalPlanFatLossDurationVM 类型，封装 Guide0820 引导流程中的相关功能。
final class GuidanceGoalPlanFatLossDurationVM: GuidanceGoalPlanDurationPageVM {
    // `flowState` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let flowState: GuidanceGoalPlanFlowState

    /// 初始化当前类型实例。
    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        let recommendation = Self.recommendation(for: flowState.fatLossMode)
        super.init(
            title: "你准备为这个减脂期规划多长时间？",
            accentColor: GuidanceGoalPlanStyle.muscleGainColor,
            defaultWeeks: flowState.fatLossDurationWeeks,
            recommendationTitle: recommendation.title,
            recommendationDetail: recommendation.detail,
            controlStyle: .customPicker
        )
        weeksChanged = { [weak self] weeks in
            self?.flowState.fatLossDurationWeeks = weeks
        }
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 执行 `pageWillAppear` 操作，完成当前引导页面的状态更新或交互处理。
    override func pageWillAppear() {
        let recommendation = Self.recommendation(for: flowState.fatLossMode)
        updateRecommendation(defaultWeeks: flowState.fatLossDurationWeeks, title: recommendation.title, detail: recommendation.detail)
        super.pageWillAppear()
    }
}

// GuidanceGoalPlanFatLossDurationVM 扩展，提供 Guide0820 流程相关的辅助能力。
private extension GuidanceGoalPlanFatLossDurationVM {
    // 执行 `recommendation` 操作，完成当前引导页面的状态更新或交互处理。
    static func recommendation(for mode: String) -> (title: String, detail: String) {
        switch mode {
        case "fast":
            return ("你的目标是在短时间内降低体脂", "为了尽可能保留肌肉量，并降低过度节食与反弹风险，我们建议你将周期控制在 3 周左右")
        case "moderate":
            return ("我们明白你希望平衡减脂速度和稳定性", "为了降低过快减脂造成平台期的风险，并持续、稳定地降低体脂，建议至少预留 12 周")
        case "steady":
            return ("你希望采取更平稳、更贴近日常生活的减脂方式", "为了让减脂过程更易执行并长期坚持，我们建议你至少预留 18 周")
        default:
            return ("我们明白你希望平衡减脂速度和稳定性", "为了降低过快减脂造成平台期的风险，并持续、稳定地降低体脂，建议至少预留 12 周")
        }
    }
}
