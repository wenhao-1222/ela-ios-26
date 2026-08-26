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
                isCompleted: Guide0820ProgressStorage.isStepCompleted(.bodyProfile),
                isNumberHighlighted: isNumberHighlighted(for: .bodyProfile, activeStep: activeStep),
                isActive: activeStep == .bodyProfile
            ),
            VCStartStepVM(
                number: "2",
                title: "了解你的生活",
                detail: detail(for: .lifeProfile, activeStep: activeStep),
                isCompleted: Guide0820ProgressStorage.isStepCompleted(.lifeProfile),
                isNumberHighlighted: isNumberHighlighted(for: .lifeProfile, activeStep: activeStep),
                isActive: activeStep == .lifeProfile
            ),
            VCStartStepVM(
                number: "3",
                title: "明确你的方向",
                detail: detail(for: .directionProfile, activeStep: activeStep),
                isCompleted: Guide0820ProgressStorage.isStepCompleted(.directionProfile),
                isNumberHighlighted: isNumberHighlighted(for: .directionProfile, activeStep: activeStep),
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
            return "ELA 会结合你的训练情况估算日常消耗，并了解你的进餐与外卖习惯，让营养目标更贴近真实生活，也更容易执行"
        case .directionProfile:
            return "ELA 会结合你的目标、训练类型、饮食反应和期望速度，确定第一阶段的热量缺口或盈余，以及蛋白质、碳水和脂肪的分配重点。"
        }
    }

    func isNumberHighlighted(for step: Guide0820ProgressStorage.MainStep, activeStep: Guide0820ProgressStorage.MainStep) -> Bool {
        step.rawValue <= activeStep.rawValue
        
    }
}
