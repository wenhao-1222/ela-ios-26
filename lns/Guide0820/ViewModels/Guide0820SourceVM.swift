//
//  Guide0820SourceVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import Foundation

/// 来源问卷页视图模型。
final class Guide0820SourceVM {
    /// 来源问卷选项。
    struct SourceItem: Equatable {
        /// 来源选项 ID。
        let id: String
        /// 来源选项标题。
        let title: String
        /// 来源选项图标资源名。
        let iconName: String
    }

    /// 当前选择的来源 ID。
    private(set) var selectedItemID: String?
    /// 页面标题。
    let title = "你是怎么知道我们的?"
    /// 所有来源选项。
    let items = [
        SourceItem(id: "friend", title: "朋友", iconName: "guide0820_source_friend_icon"),
        SourceItem(id: "coach", title: "教练", iconName: "guide0820_source_coach_icon"),
        SourceItem(id: "douyin", title: "抖音", iconName: "guide0820_source_douyin_icon"),
        SourceItem(id: "xiaohongshu", title: "小红书", iconName: "guide0820_source_xiaohongshu_icon"),
        SourceItem(id: "app_market", title: "应用市场", iconName: "guide0820_source_app_market_icon"),
        SourceItem(id: "other", title: "其他", iconName: "guide0820_source_other_icon")
    ]
    /// 主按钮标题。
    var buttonTitle: String {
        selectedItemID == nil ? "跳过" : "继续"
    }

    init(selectedItemID: String? = nil) {
        restoreSelection(selectedItemID)
    }

    /// 选中或取消来源选项。
    /// - Parameter item: 用户点击的来源选项。
    func select(_ item: SourceItem) {
        selectedItemID = selectedItemID == item.id ? nil : item.id
    }

    /// 恢复来源选项。
    /// - Parameter itemID: 已保存的来源 ID。
    func restoreSelection(_ itemID: String?) {
        guard let itemID,
              items.contains(where: { $0.id == itemID }) else {
            selectedItemID = nil
            return
        }
        selectedItemID = itemID
    }

    /// 清空当前页面内存态选择。
    func clearSelection() {
        selectedItemID = nil
    }
}
