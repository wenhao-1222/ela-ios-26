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

    /// 当前用于页面回显的来源值；用户跳过或未保存时返回 nil。
    static var storedValueForDisplay: String? {
        guard let value = storedValueForUpload, value.isEmpty == false else {
            return nil
        }
        return value
    }

    /// 本地是否已经保存过来源问卷选择；空字符串代表用户跳过，也视为已经走过来源问卷。
    static var hasStoredSelection: Bool {
        UserDefaults.standard.object(forKey: userDefaultsKey) != nil
    }

    /// 保存来源问卷选项。
    /// - Parameter sourceID: 已选择的来源 ID，为 nil 时保存空值。
    static func save(_ sourceID: String?) {
        UserDefaults.standard.set(sourceID ?? "", forKey: userDefaultsKey)
        Guide0820DefaultsFlusher.flush()
    }

    /// 清除当前阶段唯一需要删除的 Guide0820SourceVM 来源问卷数据。
    static func clear() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        Guide0820DefaultsFlusher.flush()
    }
}

/// Guide0820 三段式引导流程本地进度存储。
enum Guide0820ProgressStorage {
    enum MainStep: Int, CaseIterable {
        case bodyProfile = 0
        case lifeProfile = 1
        case directionProfile = 2
    }

    private enum Key {
        static let completedMainStepCount = "guide_0820_completed_main_step_count"
        // 复用旧 key，避免已经保存的身体资料进度丢失。
        static let bodyProfileFurthestPageIndex = "guide_0820_body_profile_current_page_index"
        static let bodyProfileCompleted = "guide_0820_body_profile_completed"
        static let lifeProfileCurrentPageIndex = "guide_0820_life_profile_current_page_index"
        static let lifeProfileCompleted = "guide_0820_life_profile_completed"
        static let directionProfileCurrentPageIndex = "guide_0820_direction_profile_current_page_index"
        static let directionProfileCompleted = "guide_0820_direction_profile_completed"

        static let bodySex = "guide_0820_body_profile_sex"
        static let bodyBirthYear = "guide_0820_body_profile_birth_year"
        static let bodyHeight = "guide_0820_body_profile_height"
        static let bodyWeight = "guide_0820_body_profile_weight"
        static let bodyWeightExceeded = "guide_0820_body_profile_weight_exceeded"
        static let bodyWeightTrend = "guide_0820_body_profile_weight_trend"
        static let bodyFat = "guide_0820_body_profile_body_fat"
    }

    static var currentMainStep: MainStep {
        MainStep(rawValue: completedMainStepCount) ?? .directionProfile
    }

    static func currentPageIndex(for step: MainStep) -> Int {
        switch step {
        case .bodyProfile:
            return UserDefaults.standard.integer(forKey: Key.bodyProfileFurthestPageIndex)
        case .lifeProfile:
            return UserDefaults.standard.integer(forKey: Key.lifeProfileCurrentPageIndex)
        case .directionProfile:
            return UserDefaults.standard.integer(forKey: Key.directionProfileCurrentPageIndex)
        }
    }

    static func saveCurrentPageIndex(_ index: Int, for step: MainStep) {
        let safeIndex = max(index, 0)
        switch step {
        case .bodyProfile:
            UserDefaults.standard.set(safeIndex, forKey: Key.bodyProfileFurthestPageIndex)
        case .lifeProfile:
            UserDefaults.standard.set(safeIndex, forKey: Key.lifeProfileCurrentPageIndex)
        case .directionProfile:
            UserDefaults.standard.set(safeIndex, forKey: Key.directionProfileCurrentPageIndex)
        }
        Guide0820DefaultsFlusher.flush()
    }

    static func furthestPageIndex(for step: MainStep) -> Int {
        currentPageIndex(for: step)
    }

    static func recordFurthestPageIndex(_ index: Int, for step: MainStep) {
        let safeIndex = max(currentPageIndex(for: step), index, 0)
        switch step {
        case .bodyProfile:
            UserDefaults.standard.set(safeIndex, forKey: Key.bodyProfileFurthestPageIndex)
        case .lifeProfile:
            UserDefaults.standard.set(safeIndex, forKey: Key.lifeProfileCurrentPageIndex)
        case .directionProfile:
            UserDefaults.standard.set(safeIndex, forKey: Key.directionProfileCurrentPageIndex)
        }
        Guide0820DefaultsFlusher.flush()
    }

    static func isStepCompleted(_ step: MainStep) -> Bool {
        switch step {
        case .bodyProfile:
            return UserDefaults.standard.bool(forKey: Key.bodyProfileCompleted)
        case .lifeProfile:
            return UserDefaults.standard.bool(forKey: Key.lifeProfileCompleted)
        case .directionProfile:
            return UserDefaults.standard.bool(forKey: Key.directionProfileCompleted)
        }
    }

    static func markStepCompleted(_ step: MainStep) {
        switch step {
        case .bodyProfile:
            UserDefaults.standard.set(true, forKey: Key.bodyProfileCompleted)
        case .lifeProfile:
            UserDefaults.standard.set(true, forKey: Key.lifeProfileCompleted)
        case .directionProfile:
            UserDefaults.standard.set(true, forKey: Key.directionProfileCompleted)
        }

        let nextCompletedCount = min(step.rawValue + 1, MainStep.allCases.count)
        UserDefaults.standard.set(max(completedMainStepCount, nextCompletedCount), forKey: Key.completedMainStepCount)
        Guide0820DefaultsFlusher.flush()
    }

    static func saveBodyProfile(sex: String?,
                                birthYear: String?,
                                height: Int?,
                                weight: Double?,
                                weightExceeded: String?,
                                weightTrend: String?,
                                bodyFat: String?) {
        setString(sex, forKey: Key.bodySex)
        setString(birthYear, forKey: Key.bodyBirthYear)
        if let height {
            UserDefaults.standard.set(height, forKey: Key.bodyHeight)
        }
        if let weight {
            UserDefaults.standard.set(weight, forKey: Key.bodyWeight)
        }
        setString(weightExceeded, forKey: Key.bodyWeightExceeded)
        setString(weightTrend, forKey: Key.bodyWeightTrend)
        setString(bodyFat, forKey: Key.bodyFat)
        Guide0820DefaultsFlusher.flush()
    }

    static var bodyProfileSex: String? { storedString(forKey: Key.bodySex) }
    static var bodyProfileBirthYear: String? { storedString(forKey: Key.bodyBirthYear) }
    static var bodyProfileHeight: Int? {
        UserDefaults.standard.object(forKey: Key.bodyHeight) == nil ? nil : UserDefaults.standard.integer(forKey: Key.bodyHeight)
    }
    static var bodyProfileWeight: Double? {
        UserDefaults.standard.object(forKey: Key.bodyWeight) == nil ? nil : UserDefaults.standard.double(forKey: Key.bodyWeight)
    }
    static var bodyProfileWeightExceeded: String? { storedString(forKey: Key.bodyWeightExceeded) }
    static var bodyProfileWeightTrend: String? { storedString(forKey: Key.bodyWeightTrend) }
    static var bodyProfileBodyFat: String? { storedString(forKey: Key.bodyFat) }
    static var hasBodyProfileProgress: Bool {
        [
            Key.bodyProfileFurthestPageIndex,
            Key.bodySex,
            Key.bodyBirthYear,
            Key.bodyHeight,
            Key.bodyWeight,
            Key.bodyWeightExceeded,
            Key.bodyWeightTrend,
            Key.bodyFat
        ].contains {
            UserDefaults.standard.object(forKey: $0) != nil
        }
    }

    static var shouldResumeGuide0820: Bool {
        Guide0820SourceStorage.hasStoredSelection ||
        (hasBodyProfileProgress && isStepCompleted(.bodyProfile) == false)
    }

    static func clearAll() {
        Guide0820SourceStorage.clear()
        [
            Key.completedMainStepCount,
            Key.bodyProfileFurthestPageIndex,
            Key.bodyProfileCompleted,
            Key.lifeProfileCurrentPageIndex,
            Key.lifeProfileCompleted,
            Key.directionProfileCurrentPageIndex,
            Key.directionProfileCompleted,
            Key.bodySex,
            Key.bodyBirthYear,
            Key.bodyHeight,
            Key.bodyWeight,
            Key.bodyWeightExceeded,
            Key.bodyWeightTrend,
            Key.bodyFat,
            Guide0820VC.hasShownKey
        ].forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
        Guide0820DefaultsFlusher.flush()
        QuestinonaireMsgModel.shared.clearMsg()
    }
}

private enum Guide0820DefaultsFlusher {
    static func flush() {
        UserDefaults.standard.synchronize()
    }
}

private extension Guide0820ProgressStorage {
    static var completedMainStepCount: Int {
        min(max(UserDefaults.standard.integer(forKey: Key.completedMainStepCount), 0), MainStep.allCases.count)
    }

    static func storedString(forKey key: String) -> String? {
        guard UserDefaults.standard.object(forKey: key) != nil else { return nil }
        return UserDefaults.standard.string(forKey: key)
    }

    static func setString(_ value: String?, forKey key: String) {
        guard let value else { return }
        UserDefaults.standard.set(value, forKey: key)
    }
}
