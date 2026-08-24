//
//  Guide0820InviteSourceInputVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import Foundation

/// “你怎么知道我们的？”邀请码输入面板状态。
final class Guide0820InviteSourceInputVM {
    /// 面板标题。
    let title = "你怎么知道我们的？"
    /// 输入项标题。
    let fieldTitle = "邀请人"
    /// 输入框占位内容。
    let placeholder = "输入邀请人的推荐码"
    /// 确认按钮标题。
    let buttonTitle = "确认"
    /// 错误提示文案。
    let errorText = "未找到该邀请码"
    /// 当前输入的邀请码。
    private(set) var invitationCode: String = ""

    /// 更新邀请码输入内容。
    /// - Parameter text: 用户输入的文本。
    func updateInvitationCode(_ text: String?) {
        invitationCode = text ?? ""
    }
}
