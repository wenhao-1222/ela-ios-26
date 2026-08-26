//
//  GuidanceGoalPlanFatLossFoodFluctuationVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

final class GuidanceGoalPlanFatLossFoodFluctuationVM: GuidanceGoalPlanChoicePageVM {
    private let flowState: GuidanceGoalPlanFlowState

    init(flowState: GuidanceGoalPlanFlowState) {
        self.flowState = flowState
        super.init(
            title: "通常吃完哪类食物后你的体重波动会更明显？",
            subtitle: "每个人对碳水和脂肪的反应存在差异，了解你的情况，有助于更合理地安排减脂目标",
            options: [
                GuidanceGoalPlanOption(title: "高碳水食物", detail: "面食、米饭等", value: "high_carb"),
                GuidanceGoalPlanOption(title: "高脂食物", detail: "烤肉、油炸食物等", value: "high_fat"),
                GuidanceGoalPlanOption(title: "不确定", detail: nil, value: "uncertain")
            ],
            accentColor: GuidanceGoalPlanStyle.fatLossColor
        )
        selectedValue = flowState.fatLossFoodFluctuation
        valueChanged = { [weak self] _ in
            self?.flowState.fatLossFoodFluctuation = self?.selectedValue ?? ""
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
