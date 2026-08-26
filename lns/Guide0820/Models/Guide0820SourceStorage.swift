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
        static let directionProfileTarget = "guide_0820_direction_profile_target"
        static let directionProfileMuscleGainBarrier = "guide_0820_direction_profile_muscle_gain_barrier"
        static let directionProfileMuscleGainMode = "guide_0820_direction_profile_muscle_gain_mode"
        static let directionProfileMuscleGainDurationWeeks = "guide_0820_direction_profile_muscle_gain_duration_weeks"
        static let directionProfileMuscleGainProfile = "guide_0820_direction_profile_muscle_gain_profile"
        static let directionProfileMuscleGainProteinHabit = "guide_0820_direction_profile_muscle_gain_protein_habit"
        static let directionProfileFatLossFoodFluctuation = "guide_0820_direction_profile_fat_loss_food_fluctuation"
        static let directionProfileFatLossMode = "guide_0820_direction_profile_fat_loss_mode"
        static let directionProfileFatLossDurationWeeks = "guide_0820_direction_profile_fat_loss_duration_weeks"
        static let directionProfileFatLossProfile = "guide_0820_direction_profile_fat_loss_profile"
        static let directionProfileFatLossProteinHabit = "guide_0820_direction_profile_fat_loss_protein_habit"

        static let bodySex = "guide_0820_body_profile_sex"
        static let bodyBirthYear = "guide_0820_body_profile_birth_year"
        static let bodyHeight = "guide_0820_body_profile_height"
        static let bodyWeight = "guide_0820_body_profile_weight"
        static let bodyWeightExceeded = "guide_0820_body_profile_weight_exceeded"
        static let bodyWeightTrend = "guide_0820_body_profile_weight_trend"
        static let bodyFat = "guide_0820_body_profile_body_fat"
        static let lifeTakeoutFrequency = "guide_0820_life_profile_takeout_frequency"
        static let lifeMealsPerDay = "guide_0820_life_profile_meals_per_day"
        static let lifeMealsAdjust = "guide_0820_life_profile_meals_adjust"
        static let lifeExerciseCaloriesRecord = "guide_0820_life_profile_exercise_calories_record"
        static let lifeCardioFrequency = "guide_0820_life_profile_cardio_frequency"
        static let lifeStrengthTrainingFrequency = "guide_0820_life_profile_strength_training_frequency"
        static let lifeCaloriesNumber = "guide_0820_life_profile_calories_number"
    }

    static var currentMainStep: MainStep {
        if isStepCompleted(.lifeProfile) {
            return .directionProfile
        }
        if isStepCompleted(.bodyProfile) {
            return .lifeProfile
        }
        return MainStep(rawValue: completedMainStepCount) ?? .directionProfile
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

    static var lifeProfileTakeoutFrequency: String? { storedString(forKey: Key.lifeTakeoutFrequency) }
    static var lifeProfileMealsPerDay: String? { storedString(forKey: Key.lifeMealsPerDay) }
    static var lifeProfileMealsAdjust: String? { storedString(forKey: Key.lifeMealsAdjust) }
    static var lifeProfileExerciseCaloriesRecord: String? { storedString(forKey: Key.lifeExerciseCaloriesRecord) }
    static var lifeProfileCardioFrequency: String? { storedString(forKey: Key.lifeCardioFrequency) }
    static var lifeProfileStrengthTrainingFrequency: String? { storedString(forKey: Key.lifeStrengthTrainingFrequency) }
    static var lifeProfileCaloriesNumber: String? { storedString(forKey: Key.lifeCaloriesNumber) }

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

    static var shouldResumeGuide0820: Bool {
        Guide0820SourceStorage.hasStoredSelection ||
        (hasBodyProfileProgress && isStepCompleted(.bodyProfile) == false) ||
        (hasLifeProfileProgress && isStepCompleted(.lifeProfile) == false) ||
        (hasDirectionProfileProgress && isStepCompleted(.directionProfile) == false)
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
