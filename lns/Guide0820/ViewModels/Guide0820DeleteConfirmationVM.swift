//
//  Guide0820DeleteConfirmationVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import Foundation

/// 清空问卷数据确认面板的状态。
final class Guide0820DeleteConfirmationVM {
    /// 面板标题。
    let title = "确认清空数据？"
    /// 确认说明标题。
    let messageTitle = "我已了解，数据删除后将永久丢失且无法恢复。"
    /// 确认说明正文。
    let messageBody = "你的个人信息及所有相关数据都将被永久删除。之后你仍可随时创建新账号，但已删除的数据无法恢复。"
    /// 按钮默认标题。
    let buttonTitle = "确认删除数据"
    /// 是否已勾选确认框。
    private(set) var isAcknowledged = false

    /// 切换确认框状态。
    /// - Returns: 切换后的确认状态。
    @discardableResult
    func toggleAcknowledgement() -> Bool {
        isAcknowledged.toggle()
        return isAcknowledged
    }
}
