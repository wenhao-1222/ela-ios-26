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
    /// MainStep 类型，封装 Guide0820 引导流程中的相关功能。
    enum MainStep: Int, CaseIterable {
        case bodyProfile = 0
        case lifeProfile = 1
        case directionProfile = 2
    }

    // Key 类型，封装 Guide0820 引导流程中的相关功能。
    private enum Key {
        // `completedMainStepCount` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let completedMainStepCount = "guide_0820_completed_main_step_count"
        // 复用旧 key，避免已经保存的身体资料进度丢失。
        // `bodyProfileFurthestPageIndex` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let bodyProfileFurthestPageIndex = "guide_0820_body_profile_current_page_index"
        // `bodyProfileCompleted` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let bodyProfileCompleted = "guide_0820_body_profile_completed"
        // `lifeProfileCurrentPageIndex` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let lifeProfileCurrentPageIndex = "guide_0820_life_profile_current_page_index"
        // `lifeProfileCompleted` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let lifeProfileCompleted = "guide_0820_life_profile_completed"
        // `directionProfileCurrentPageIndex` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let directionProfileCurrentPageIndex = "guide_0820_direction_profile_current_page_index"
        // `directionProfileCompleted` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let directionProfileCompleted = "guide_0820_direction_profile_completed"
        // `directionProfileTarget` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let directionProfileTarget = "guide_0820_direction_profile_target"
        // `directionProfileMuscleGainBarrier` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let directionProfileMuscleGainBarrier = "guide_0820_direction_profile_muscle_gain_barrier"
        // `directionProfileMuscleGainMode` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let directionProfileMuscleGainMode = "guide_0820_direction_profile_muscle_gain_mode"
        // `directionProfileMuscleGainDurationWeeks` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let directionProfileMuscleGainDurationWeeks = "guide_0820_direction_profile_muscle_gain_duration_weeks"
        // `directionProfileMuscleGainProfile` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let directionProfileMuscleGainProfile = "guide_0820_direction_profile_muscle_gain_profile"
        // `directionProfileMuscleGainProteinHabit` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let directionProfileMuscleGainProteinHabit = "guide_0820_direction_profile_muscle_gain_protein_habit"
        // `directionProfileFatLossFoodFluctuation` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let directionProfileFatLossFoodFluctuation = "guide_0820_direction_profile_fat_loss_food_fluctuation"
        // `directionProfileFatLossMode` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let directionProfileFatLossMode = "guide_0820_direction_profile_fat_loss_mode"
        // `directionProfileFatLossDurationWeeks` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let directionProfileFatLossDurationWeeks = "guide_0820_direction_profile_fat_loss_duration_weeks"
        // `directionProfileFatLossProfile` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let directionProfileFatLossProfile = "guide_0820_direction_profile_fat_loss_profile"
        // `directionProfileFatLossProteinHabit` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let directionProfileFatLossProteinHabit = "guide_0820_direction_profile_fat_loss_protein_habit"

        // `bodySex` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let bodySex = "guide_0820_body_profile_sex"
        // `bodyBirthYear` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let bodyBirthYear = "guide_0820_body_profile_birth_year"
        // `bodyHeight` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let bodyHeight = "guide_0820_body_profile_height"
        // `bodyWeight` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let bodyWeight = "guide_0820_body_profile_weight"
        // `bodyWeightExceeded` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let bodyWeightExceeded = "guide_0820_body_profile_weight_exceeded"
        // `bodyWeightTrend` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let bodyWeightTrend = "guide_0820_body_profile_weight_trend"
        // `bodyFat` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let bodyFat = "guide_0820_body_profile_body_fat"
        // `lifeTakeoutFrequency` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let lifeTakeoutFrequency = "guide_0820_life_profile_takeout_frequency"
        // `lifeMealsPerDay` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let lifeMealsPerDay = "guide_0820_life_profile_meals_per_day"
        // `lifeMealsAdjust` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let lifeMealsAdjust = "guide_0820_life_profile_meals_adjust"
        // `lifeExerciseCaloriesRecord` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let lifeExerciseCaloriesRecord = "guide_0820_life_profile_exercise_calories_record"
        // `lifeCardioFrequency` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let lifeCardioFrequency = "guide_0820_life_profile_cardio_frequency"
        // `lifeStrengthTrainingFrequency` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let lifeStrengthTrainingFrequency = "guide_0820_life_profile_strength_training_frequency"
        // `lifeCaloriesNumber` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let lifeCaloriesNumber = "guide_0820_life_profile_calories_number"
    }

    /// `currentMainStep` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var currentMainStep: MainStep {
        if isStepCompleted(.lifeProfile) {
            return .directionProfile
        }
        if isStepCompleted(.bodyProfile) {
            return .lifeProfile
        }
        return MainStep(rawValue: completedMainStepCount) ?? .directionProfile
    }

    /// 执行 `currentPageIndex` 操作，完成当前引导页面的状态更新或交互处理。
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

    /// 执行 `saveCurrentPageIndex` 操作，完成当前引导页面的状态更新或交互处理。
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

    /// 执行 `furthestPageIndex` 操作，完成当前引导页面的状态更新或交互处理。
    static func furthestPageIndex(for step: MainStep) -> Int {
        currentPageIndex(for: step)
    }

    /// 执行 `recordFurthestPageIndex` 操作，完成当前引导页面的状态更新或交互处理。
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

    /// 执行 `isStepCompleted` 操作，完成当前引导页面的状态更新或交互处理。
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

    /// 执行 `markStepCompleted` 操作，完成当前引导页面的状态更新或交互处理。
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

    /// 执行 `saveDirectionProfile` 操作，完成当前引导页面的状态更新或交互处理。
    static func saveDirectionProfile(flowState: GuidanceGoalPlanFlowState) {
        setString(flowState.target?.rawValue, forKey: Key.directionProfileTarget)
        setString(flowState.muscleGainBarrier, forKey: Key.directionProfileMuscleGainBarrier)
        setString(flowState.muscleGainMode, forKey: Key.directionProfileMuscleGainMode)
        if flowState.muscleGainDurationWeeks > 0 {
            UserDefaults.standard.set(flowState.muscleGainDurationWeeks, forKey: Key.directionProfileMuscleGainDurationWeeks)
        }
        setString(flowState.muscleGainProfile, forKey: Key.directionProfileMuscleGainProfile)
        setString(flowState.muscleGainProteinHabit, forKey: Key.directionProfileMuscleGainProteinHabit)
        setString(flowState.fatLossFoodFluctuation, forKey: Key.directionProfileFatLossFoodFluctuation)
        setString(flowState.fatLossMode, forKey: Key.directionProfileFatLossMode)
        if flowState.fatLossDurationWeeks > 0 {
            UserDefaults.standard.set(flowState.fatLossDurationWeeks, forKey: Key.directionProfileFatLossDurationWeeks)
        }
        setString(flowState.fatLossProfile, forKey: Key.directionProfileFatLossProfile)
        setString(flowState.fatLossProteinHabit, forKey: Key.directionProfileFatLossProteinHabit)
        Guide0820DefaultsFlusher.flush()
    }

    /// 执行 `restoreDirectionProfile` 操作，完成当前引导页面的状态更新或交互处理。
    static func restoreDirectionProfile(flowState: GuidanceGoalPlanFlowState) {
        if let target = storedString(forKey: Key.directionProfileTarget) {
            flowState.target = GuidanceGoalPlanTarget(rawValue: target)
        }
        flowState.muscleGainBarrier = storedString(forKey: Key.directionProfileMuscleGainBarrier) ?? flowState.muscleGainBarrier
        flowState.muscleGainMode = storedString(forKey: Key.directionProfileMuscleGainMode) ?? flowState.muscleGainMode
        if UserDefaults.standard.object(forKey: Key.directionProfileMuscleGainDurationWeeks) != nil {
            flowState.muscleGainDurationWeeks = UserDefaults.standard.integer(forKey: Key.directionProfileMuscleGainDurationWeeks)
        }
        flowState.muscleGainProfile = storedString(forKey: Key.directionProfileMuscleGainProfile) ?? flowState.muscleGainProfile
        flowState.muscleGainProteinHabit = storedString(forKey: Key.directionProfileMuscleGainProteinHabit) ?? flowState.muscleGainProteinHabit
        flowState.fatLossFoodFluctuation = storedString(forKey: Key.directionProfileFatLossFoodFluctuation) ?? flowState.fatLossFoodFluctuation
        flowState.fatLossMode = storedString(forKey: Key.directionProfileFatLossMode) ?? flowState.fatLossMode
        if UserDefaults.standard.object(forKey: Key.directionProfileFatLossDurationWeeks) != nil {
            flowState.fatLossDurationWeeks = UserDefaults.standard.integer(forKey: Key.directionProfileFatLossDurationWeeks)
        }
        flowState.fatLossProfile = storedString(forKey: Key.directionProfileFatLossProfile) ?? flowState.fatLossProfile
        flowState.fatLossProteinHabit = storedString(forKey: Key.directionProfileFatLossProteinHabit) ?? flowState.fatLossProteinHabit
    }

    /// 执行 `saveBodyProfile` 操作，完成当前引导页面的状态更新或交互处理。
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

    /// 保存 Guide0820 身体资料模型，保留现有草稿 key 以兼容历史草稿。
    static func saveBodyProfileFromGuide0820Model() {
        let model = Guide0820Model.shared
        saveBodyProfile(
            sex: model.sex,
            birthYear: model.birthYear.isEmpty ? model.birthDay : model.birthYear,
            height: Int(model.height),
            weight: Double(model.weight),
            weightExceeded: model.guidanceBodyWeightExceededType,
            weightTrend: model.guidanceRecentWeightTrendType,
            bodyFat: model.bodyFat
        )
    }

    /// 将现有身体资料草稿恢复到 Guide0820 独立模型。
    static func restoreBodyProfileToGuide0820Model() {
        let model = Guide0820Model.shared
        model.sex = bodyProfileSex ?? model.sex
        model.birthYear = bodyProfileBirthYear ?? model.birthYear
        model.birthDay = model.birthYear
        if let height = bodyProfileHeight { model.height = "\(height)" }
        if let weight = bodyProfileWeight { model.weight = String(format: "%.1f", weight) }
        model.guidanceBodyWeightExceededType = bodyProfileWeightExceeded ?? model.guidanceBodyWeightExceededType
        model.guidanceRecentWeightTrendType = bodyProfileWeightTrend ?? model.guidanceRecentWeightTrendType
        model.bodyFat = bodyProfileBodyFat ?? model.bodyFat
    }

    /// `bodyProfileSex` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var bodyProfileSex: String? { storedString(forKey: Key.bodySex) }
    /// `bodyProfileBirthYear` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var bodyProfileBirthYear: String? { storedString(forKey: Key.bodyBirthYear) }
    /// `bodyProfileHeight` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var bodyProfileHeight: Int? {
        UserDefaults.standard.object(forKey: Key.bodyHeight) == nil ? nil : UserDefaults.standard.integer(forKey: Key.bodyHeight)
    }
    /// `bodyProfileWeight` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var bodyProfileWeight: Double? {
        UserDefaults.standard.object(forKey: Key.bodyWeight) == nil ? nil : UserDefaults.standard.double(forKey: Key.bodyWeight)
    }
    /// `bodyProfileWeightExceeded` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var bodyProfileWeightExceeded: String? { storedString(forKey: Key.bodyWeightExceeded) }
    /// `bodyProfileWeightTrend` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var bodyProfileWeightTrend: String? { storedString(forKey: Key.bodyWeightTrend) }
    /// `bodyProfileBodyFat` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var bodyProfileBodyFat: String? { storedString(forKey: Key.bodyFat) }

    /// 执行 `saveLifeProfile` 操作，完成当前引导页面的状态更新或交互处理。
    static func saveLifeProfile(takeoutFrequency: String?,
                                mealsPerDay: String?,
                                mealsAdjust: String?,
                                exerciseCaloriesRecord: String?,
                                cardioFrequency: String?,
                                strengthTrainingFrequency: String?,
                                caloriesNumber: String?) {
        setString(takeoutFrequency, forKey: Key.lifeTakeoutFrequency)
        setString(mealsPerDay, forKey: Key.lifeMealsPerDay)
        setString(mealsAdjust, forKey: Key.lifeMealsAdjust)
        setString(exerciseCaloriesRecord, forKey: Key.lifeExerciseCaloriesRecord)
        setString(cardioFrequency, forKey: Key.lifeCardioFrequency)
        setString(strengthTrainingFrequency, forKey: Key.lifeStrengthTrainingFrequency)
        setString(caloriesNumber, forKey: Key.lifeCaloriesNumber)
        Guide0820DefaultsFlusher.flush()
    }

    /// 执行 `saveLifeProfileFromGuide0820Model` 操作，完成当前引导页面的状态更新或交互处理。
    static func saveLifeProfileFromGuide0820Model() {
        let model = Guide0820Model.shared
        saveLifeProfile(
            takeoutFrequency: model.guidanceTakeoutFrequencyType,
            mealsPerDay: model.guidanceMealsPerDayType,
            mealsAdjust: model.guidanceMealsAdjustType,
            exerciseCaloriesRecord: model.guidanceExerciseCaloriesRecordType,
            cardioFrequency: model.guidanceCardioFrequencyType,
            strengthTrainingFrequency: model.guidanceStrengthTrainingFrequencyType,
            caloriesNumber: model.caloriesNumber
        )
    }

    /// 执行 `restoreLifeProfileToGuide0820Model` 操作，完成当前引导页面的状态更新或交互处理。
    static func restoreLifeProfileToGuide0820Model() {
        let model = Guide0820Model.shared
        model.guidanceTakeoutFrequencyType = lifeProfileTakeoutFrequency ?? model.guidanceTakeoutFrequencyType
        model.guidanceMealsPerDayType = lifeProfileMealsPerDay ?? model.guidanceMealsPerDayType
        model.guidanceMealsAdjustType = lifeProfileMealsAdjust ?? model.guidanceMealsAdjustType
        model.guidanceExerciseCaloriesRecordType = lifeProfileExerciseCaloriesRecord ?? model.guidanceExerciseCaloriesRecordType
        model.guidanceCardioFrequencyType = lifeProfileCardioFrequency ?? model.guidanceCardioFrequencyType
        model.guidanceStrengthTrainingFrequencyType = lifeProfileStrengthTrainingFrequency ?? model.guidanceStrengthTrainingFrequencyType
        model.caloriesNumber = lifeProfileCaloriesNumber ?? model.caloriesNumber
        model.caloriesNumberFromServer = lifeProfileCaloriesNumber ?? model.caloriesNumberFromServer
    }

    /// `lifeProfileTakeoutFrequency` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var lifeProfileTakeoutFrequency: String? { storedString(forKey: Key.lifeTakeoutFrequency) }
    /// `lifeProfileMealsPerDay` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var lifeProfileMealsPerDay: String? { storedString(forKey: Key.lifeMealsPerDay) }
    /// `lifeProfileMealsAdjust` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var lifeProfileMealsAdjust: String? { storedString(forKey: Key.lifeMealsAdjust) }
    /// `lifeProfileExerciseCaloriesRecord` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var lifeProfileExerciseCaloriesRecord: String? { storedString(forKey: Key.lifeExerciseCaloriesRecord) }
    /// `lifeProfileCardioFrequency` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var lifeProfileCardioFrequency: String? { storedString(forKey: Key.lifeCardioFrequency) }
    /// `lifeProfileStrengthTrainingFrequency` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var lifeProfileStrengthTrainingFrequency: String? { storedString(forKey: Key.lifeStrengthTrainingFrequency) }
    /// `lifeProfileCaloriesNumber` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var lifeProfileCaloriesNumber: String? { storedString(forKey: Key.lifeCaloriesNumber) }

    /// `hasBodyProfileProgress` 属性，保存该类型对外提供或内部使用的状态与配置。
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

    /// `hasLifeProfileProgress` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var hasLifeProfileProgress: Bool {
        [
            Key.lifeProfileCurrentPageIndex,
            Key.lifeTakeoutFrequency,
            Key.lifeMealsPerDay,
            Key.lifeMealsAdjust,
            Key.lifeExerciseCaloriesRecord,
            Key.lifeCardioFrequency,
            Key.lifeStrengthTrainingFrequency,
            Key.lifeCaloriesNumber
        ].contains {
            UserDefaults.standard.object(forKey: $0) != nil
        }
    }

    /// `hasDirectionProfileProgress` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var hasDirectionProfileProgress: Bool {
        [
            Key.directionProfileCurrentPageIndex,
            Key.directionProfileTarget,
            Key.directionProfileMuscleGainBarrier,
            Key.directionProfileMuscleGainMode,
            Key.directionProfileMuscleGainDurationWeeks,
            Key.directionProfileMuscleGainProfile,
            Key.directionProfileMuscleGainProteinHabit,
            Key.directionProfileFatLossFoodFluctuation,
            Key.directionProfileFatLossMode,
            Key.directionProfileFatLossDurationWeeks,
            Key.directionProfileFatLossProfile,
            Key.directionProfileFatLossProteinHabit
        ].contains {
            UserDefaults.standard.object(forKey: $0) != nil
        }
    }

    /// `shouldResumeGuide0820` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var shouldResumeGuide0820: Bool {
        Guide0820SourceStorage.hasStoredSelection ||
        (hasBodyProfileProgress && isStepCompleted(.bodyProfile) == false) ||
        (hasLifeProfileProgress && isStepCompleted(.lifeProfile) == false) ||
        (hasDirectionProfileProgress && isStepCompleted(.directionProfile) == false)
    }

    /// 执行 `clearAll` 操作，完成当前引导页面的状态更新或交互处理。
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
            Key.lifeTakeoutFrequency,
            Key.lifeMealsPerDay,
            Key.lifeMealsAdjust,
            Key.lifeExerciseCaloriesRecord,
            Key.lifeCardioFrequency,
            Key.lifeStrengthTrainingFrequency,
            Key.lifeCaloriesNumber,
            Key.directionProfileTarget,
            Key.directionProfileMuscleGainBarrier,
            Key.directionProfileMuscleGainMode,
            Key.directionProfileMuscleGainDurationWeeks,
            Key.directionProfileMuscleGainProfile,
            Key.directionProfileMuscleGainProteinHabit,
            Key.directionProfileFatLossFoodFluctuation,
            Key.directionProfileFatLossMode,
            Key.directionProfileFatLossDurationWeeks,
            Key.directionProfileFatLossProfile,
            Key.directionProfileFatLossProteinHabit,
            Guide0820VC.hasShownKey
        ].forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
        Guide0820DefaultsFlusher.flush()
        Guide0820Model.shared.clear()
    }
}

// Guide0820DefaultsFlusher 类型，封装 Guide0820 引导流程中的相关功能。
private enum Guide0820DefaultsFlusher {
    // 执行 `flush` 操作，完成当前引导页面的状态更新或交互处理。
    static func flush() {
        UserDefaults.standard.synchronize()
    }
}

// Guide0820ProgressStorage 扩展，提供 Guide0820 流程相关的辅助能力。
private extension Guide0820ProgressStorage {
    // `completedMainStepCount` 属性，保存该类型对外提供或内部使用的状态与配置。
    static var completedMainStepCount: Int {
        min(max(UserDefaults.standard.integer(forKey: Key.completedMainStepCount), 0), MainStep.allCases.count)
    }

    // 执行 `storedString` 操作，完成当前引导页面的状态更新或交互处理。
    static func storedString(forKey key: String) -> String? {
        guard UserDefaults.standard.object(forKey: key) != nil else { return nil }
        return UserDefaults.standard.string(forKey: key)
    }

    // 执行 `setString` 操作，完成当前引导页面的状态更新或交互处理。
    static func setString(_ value: String?, forKey key: String) {
        guard let value else { return }
        UserDefaults.standard.set(value, forKey: key)
    }
}
