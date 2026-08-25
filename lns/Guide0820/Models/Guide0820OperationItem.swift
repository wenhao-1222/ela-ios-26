//
//  Guide0820OperationItem.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit

/// 操作面板中展示的一行操作配置。
struct Guide0820OperationItem {
    /// 操作项的唯一标识。
    enum Identifier {
        /// “你怎么知道我们的？”页面入口。
        case sourceInput
        /// 清空问卷数据入口。
        case clearData
    }

    /// 当前操作项的标识。
    let identifier: Identifier
    /// 当前操作项的标题。
    let title: String
    /// 操作项图标资源名。
    let iconName: String
    /// 图标展示颜色。
    let iconColor: UIColor
    /// 文案展示颜色。
    let titleColor: UIColor
    /// 是否展示右侧箭头。
    let showsDisclosure: Bool
    /// 是否允许触发业务逻辑。
    let isEnabled: Bool
}
