//
//  Guide0820BodyProfileOption.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import Foundation

/// 身体资料页选项卡的数据模型。
final class Guide0820BodyProfileOption {
    /// 选项主标题。
    let title: String

    /// 选项副标题，没有副标题时为 nil。
    let subtitle: String?

    /// 选项左侧图标文本，缺少图标资源时作为兜底展示。
    let iconText: String

    /// 选项左侧图标资源名。
    let iconName: String?

    /// 选项提交到问卷模型时使用的值。
    let value: String

    /// 初始化选项数据。
    init(title: String, subtitle: String? = nil, iconText: String, iconName: String? = nil, value: String) {
        self.title = title
        self.subtitle = subtitle
        self.iconText = iconText
        self.iconName = iconName
        self.value = value
    }
}
