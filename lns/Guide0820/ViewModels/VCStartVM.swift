//
//  VCStartVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import Foundation

/// “让我们开始吧”页面视图模型。
final class VCStartVM {
    /// 页面标题。
    let title = "让我们开始吧！"
    /// 页面副标题。
    let subtitle = "用几分钟，为你确定第一阶段的营养计划"
    /// 底部按钮标题。
    let buttonTitle = "开始"
    /// 页面展示的步骤列表。
    var steps: [VCStartStepVM] {
        let activeStep = Guide0820ProgressStorage.currentMainStep
        return [
            VCStartStepVM(
                number: "1",
                title: "了解你的身体",
                detail: detail(for: .bodyProfile, activeStep: activeStep),
                isActive: activeStep == .bodyProfile
            ),
            VCStartStepVM(
                number: "2",
                title: "了解你的生活",
                detail: detail(for: .lifeProfile, activeStep: activeStep),
                isActive: activeStep == .lifeProfile
            ),
            VCStartStepVM(
                number: "3",
                title: "明确你的方向",
                detail: detail(for: .directionProfile, activeStep: activeStep),
                isActive: activeStep == .directionProfile
            )
        ]
    }

    var currentStep: Guide0820ProgressStorage.MainStep {
        Guide0820ProgressStorage.currentMainStep
    }
}

private extension VCStartVM {
    func detail(for step: Guide0820ProgressStorage.MainStep, activeStep: Guide0820ProgressStorage.MainStep) -> String? {
        guard step == activeStep else { return nil }
        switch step {
        case .bodyProfile:
            return "ELA 会结合你的年龄、性别、身高、体重、体脂和近期变化，建立可靠的身体基线，为估算代谢和确定营养目标提供依据"
        case .lifeProfile:
            return "继续补充生活习惯，让计划更贴近你的真实日常"
        case .directionProfile:
            return "最后明确目标方向，生成更适合当前阶段的营养计划"
        }
    }
}
