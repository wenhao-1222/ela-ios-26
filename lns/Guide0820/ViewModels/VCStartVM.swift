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
    let steps = [
        VCStartStepVM(
            number: "1",
            title: "了解你的身体",
            detail: "ELA 会结合你的年龄、性别、身高、体重、体脂和近期变化，建立可靠的身体基线，为估算代谢和确定营养目标提供依据",
            isActive: true
        ),
        VCStartStepVM(
            number: "2",
            title: "了解你的生活",
            detail: nil,
            isActive: false
        ),
        VCStartStepVM(
            number: "3",
            title: "明确你的方向",
            detail: nil,
            isActive: false
        )
    ]
}
