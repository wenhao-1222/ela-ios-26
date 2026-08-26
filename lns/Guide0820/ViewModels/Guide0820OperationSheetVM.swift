//
//  Guide0820OperationSheetVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit

/// Guide0820 右上角操作面板状态。
final class Guide0820OperationSheetVM {
    /// 面板标题。
    let title = "操作"

    /// 当前可展示的操作项。
    var items: [Guide0820OperationItem] {
        [
            Guide0820OperationItem(
                identifier: .clearData,
                title: "清空数据 & 进度",
                iconName: "guide0820_delete_icon",
                iconColor: .systemRed,
                titleColor: .systemRed,
                showsDisclosure: false,
                isEnabled: true
            )
        ]
    }
//    var items: [Guide0820OperationItem] {
//        [
//            Guide0820OperationItem(
//                identifier: .sourceInput,
//                title: "你怎么知道我们的？",
//                iconName: "guide0820_source_operation_icon",
//                iconColor: .COLOR_TEXT_TITLE_0f1214,
//                titleColor: .COLOR_TEXT_TITLE_0f1214,
//                showsDisclosure: true,
//                isEnabled: Guide0820FeatureSwitches.isSourceOperationEnabled
//            ),
//            Guide0820OperationItem(
//                identifier: .clearData,
//                title: "清空数据 & 进度",
//                iconName: "guide0820_delete_icon",
//                iconColor: .systemRed,
//                titleColor: .systemRed,
//                showsDisclosure: false,
//                isEnabled: true
//            )
//        ]
//    }
}
