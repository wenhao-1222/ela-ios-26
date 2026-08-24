//
//  Guide0820SourceStorage.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import Foundation

/// Guide0820 来源问卷本地存储。
enum Guide0820SourceStorage {
    /// 来源问卷在 UserDefaults 中的键。
    static let userDefaultsKey = "guide_0820_source"
    /// 来源问卷上传参数名。
    static let uploadParameterKey = "source"

    /// 当前可用于上传的来源值；用户未选择时返回 nil。
    static var storedValueForUpload: String? {
        guard UserDefaults.standard.object(forKey: userDefaultsKey) != nil else {
            return nil
        }
        return UserDefaults.standard.string(forKey: userDefaultsKey) ?? ""
    }

    /// 保存来源问卷选项。
    /// - Parameter sourceID: 已选择的来源 ID，为 nil 时保存空值。
    static func save(_ sourceID: String?) {
        UserDefaults.standard.set(sourceID ?? "", forKey: userDefaultsKey)
    }

    /// 清除当前阶段唯一需要删除的 Guide0820SourceVM 来源问卷数据。
    static func clear() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
