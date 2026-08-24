//
//  Guide0820FlowState.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import Foundation

/// Guide0820 引导流程的页面状态。
final class Guide0820FlowState {
    /// 当前页面下标。
    private(set) var currentPageIndex = 0
    /// 隐私页视图模型。
    let privacyVM = Guide0820PrivacyVM()
    /// 专业依据页视图模型。
    let professionalBasisVM = Guide0820ProfessionalBasisVM()
    /// 来源问卷页视图模型。
    let sourceVM = Guide0820SourceVM()
    /// 当前流程最后一页下标。
    private let maxPageIndex = 2

    /// 前进到下一页。
    func showNext() {
        currentPageIndex = min(currentPageIndex + 1, maxPageIndex)
    }

    /// 返回到上一页。
    func showPrevious() {
        currentPageIndex = max(currentPageIndex - 1, 0)
    }
}
