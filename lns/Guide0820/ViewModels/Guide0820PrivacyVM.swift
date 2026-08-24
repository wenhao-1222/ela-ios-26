//
//  Guide0820PrivacyVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import Foundation

/// 隐私确认页视图模型。
final class Guide0820PrivacyVM {
    /// 协议列表项。
    struct AgreementItem {
        /// 协议类型。
        let id: Guide0820AgreementType
        /// 协议标题。
        let title: String
        /// 协议图标资源名。
        let iconName: String
    }

    /// 页面标题。
    let title = "保护你的隐私"
    /// 页面副标题。
    let subtitle = "我们永远不会出售你的健康数据，也绝不会在未经你同意\n的情况下与第三方共享。"
    /// 主按钮标题。
    let buttonTitle = "同意并继续"
    /// 可打开的协议列表。
    let agreements = [
        AgreementItem(id: .userAgreement, title: "用户协议", iconName: "guide0820_user_agreement_icon"),
        AgreementItem(id: .privacyPolicy, title: "隐私政策", iconName: "guide0820_privacy_policy_icon")
    ]
}
