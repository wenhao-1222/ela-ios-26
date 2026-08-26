//
//  VCStartStepVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import Foundation

/// “让我们开始吧”页面中的步骤行视图模型。
struct VCStartStepVM {
    /// 步骤序号。
    let number: String
    /// 步骤标题。
    let title: String
    /// 步骤详情。
    let detail: String?
    /// 步骤是否已经完成。
    let isCompleted: Bool
    /// 序号圆点是否展示选中态。
    let isNumberHighlighted: Bool
    /// 当前步骤是否高亮。
    let isActive: Bool
}
