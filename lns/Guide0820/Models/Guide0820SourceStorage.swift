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
        Guide0820Model.shared.sourceID = sourceID
        Guide0820Model.shared.acquisitionSource = acquisitionSource(for: sourceID)
        Guide0820DefaultsFlusher.flush()
    }

    /// 将页面来源 ID 映射为 savePart/v3 的 acquisitionSource。
    /// AI 聊天工具暂按已确认的临时枚举 7 上传，待服务端契约更新后再统一调整。
    static func acquisitionSource(for sourceID: String?) -> Int? {
        switch sourceID {
        case "friend": return 1
        case "coach": return 2
        case "douyin": return 3
        case "xiaohongshu": return 4
        case "app_market": return 5
        case "other": return 6
        case "ai_chat_tool": return 7
        default: return nil
        }
    }

    /// 将已持久化的来源恢复到 Guide0820 唯一业务模型。
    static func restoreToGuide0820Model() {
        let sourceID = storedValueForDisplay
        Guide0820Model.shared.sourceID = sourceID
        Guide0820Model.shared.acquisitionSource = acquisitionSource(for: sourceID)
    }

    /// 清除当前阶段唯一需要删除的 Guide0820SourceVM 来源问卷数据。
    static func clear() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        Guide0820Model.shared.sourceID = nil
        Guide0820Model.shared.acquisitionSource = nil
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
        static let directionProfileFoodAdjustment = "guide_0820_direction_profile_food_adjustment"

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

        // 最终营养目标。calories 是最终摄入目标，必须与 lifeCaloriesNumber（TDEE）分开保存。
        static let finalCarbohydrate = "guide_0820_final_carbohydrate"
        static let finalProtein = "guide_0820_final_protein"
        static let finalFat = "guide_0820_final_fat"
        static let finalCalories = "guide_0820_final_calories"
        // 完成态和上传态仅服务 Guide0820，不复用旧问卷 surveytype。
        static let pendingDataReady = "guide_0820_pending_data_ready"
        static let nutritionGoalSaved = "guide_0820_nutrition_goal_saved"
        static let surveyV3Pending = "guide_0820_survey_v3_pending"
        static let pendingOwnerUID = "guide_0820_pending_owner_uid"
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
        // FlowState 仅组织页面流程；Guide0820Model 始终保留可供登录上传的完整业务值。
        let model = Guide0820Model.shared
        model.guidanceGoalTarget = flowState.target
        model.muscleGainBarrier = flowState.muscleGainBarrier
        model.muscleGainMode = flowState.muscleGainMode
        model.muscleGainDurationWeeks = flowState.muscleGainDurationWeeks
        model.muscleGainProfile = flowState.muscleGainProfile
        model.muscleGainProteinHabit = flowState.muscleGainProteinHabit
        model.fatLossFoodFluctuation = flowState.fatLossFoodFluctuation
        model.fatLossMode = flowState.fatLossMode
        model.fatLossDurationWeeks = flowState.fatLossDurationWeeks
        model.fatLossProfile = flowState.fatLossProfile
        model.fatLossProteinHabit = flowState.fatLossProteinHabit
        model.foodAdjustment = flowState.foodAdjustment

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
        setString(flowState.foodAdjustment, forKey: Key.directionProfileFoodAdjustment)
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
        flowState.foodAdjustment = storedString(forKey: Key.directionProfileFoodAdjustment) ?? flowState.foodAdjustment
        // 恢复页面状态后立即同步到唯一业务模型，避免上传端再依赖 VC/FlowState 生命周期。
        let model = Guide0820Model.shared
        model.guidanceGoalTarget = flowState.target
        model.muscleGainBarrier = flowState.muscleGainBarrier
        model.muscleGainMode = flowState.muscleGainMode
        model.muscleGainDurationWeeks = flowState.muscleGainDurationWeeks
        model.muscleGainProfile = flowState.muscleGainProfile
        model.muscleGainProteinHabit = flowState.muscleGainProteinHabit
        model.fatLossFoodFluctuation = flowState.fatLossFoodFluctuation
        model.fatLossMode = flowState.fatLossMode
        model.fatLossDurationWeeks = flowState.fatLossDurationWeeks
        model.fatLossProfile = flowState.fatLossProfile
        model.fatLossProteinHabit = flowState.fatLossProteinHabit
        model.foodAdjustment = flowState.foodAdjustment
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

    /// 保存用户最终确认的营养目标。最终 calories 与生活资料阶段的 TDEE 分开持久化。
    static func saveFinalNutritionGoals(carbohydrate: Double,
                                        protein: Double,
                                        fat: Double,
                                        calories: Int) {
        let model = Guide0820Model.shared
        model.carbohydrate = carbohydrate
        model.protein = protein
        model.fat = fat
        model.calories = calories

        UserDefaults.standard.set(carbohydrate, forKey: Key.finalCarbohydrate)
        UserDefaults.standard.set(protein, forKey: Key.finalProtein)
        UserDefaults.standard.set(fat, forKey: Key.finalFat)
        UserDefaults.standard.set(calories, forKey: Key.finalCalories)
        // 结果页确认后才是可进入登录绑定流程的完整 Guide0820 数据。
        UserDefaults.standard.set(true, forKey: Key.pendingDataReady)
        UserDefaults.standard.set(false, forKey: Key.nutritionGoalSaved)
        UserDefaults.standard.set(false, forKey: Key.surveyV3Pending)
        Guide0820DefaultsFlusher.flush()
    }

    /// 将身体、生活、目标、最终营养目标和来源完整恢复到 Guide0820Model。
    static func restoreAllToGuide0820Model() {
        restoreBodyProfileToGuide0820Model()
        restoreLifeProfileToGuide0820Model()
        let flowState = GuidanceGoalPlanFlowState()
        restoreDirectionProfile(flowState: flowState)
        Guide0820SourceStorage.restoreToGuide0820Model()

        let defaults = UserDefaults.standard
        let model = Guide0820Model.shared
        if defaults.object(forKey: Key.finalCarbohydrate) != nil {
            model.carbohydrate = defaults.double(forKey: Key.finalCarbohydrate)
        }
        if defaults.object(forKey: Key.finalProtein) != nil {
            model.protein = defaults.double(forKey: Key.finalProtein)
        }
        if defaults.object(forKey: Key.finalFat) != nil {
            model.fat = defaults.double(forKey: Key.finalFat)
        }
        if defaults.object(forKey: Key.finalCalories) != nil {
            model.calories = defaults.integer(forKey: Key.finalCalories)
        }
    }

    /// 已确认完整结果，登录页应优先执行 Guide0820 的 custom_save，而不是旧 surveytype 分支。
    static var hasPendingCompletedData: Bool {
        UserDefaults.standard.bool(forKey: Key.pendingDataReady)
    }

    static var hasSavedNutritionGoal: Bool {
        UserDefaults.standard.bool(forKey: Key.nutritionGoalSaved)
    }

    static var hasPendingSurveyV3Upload: Bool {
        UserDefaults.standard.bool(forKey: Key.surveyV3Pending)
    }

    /// custom_save 成功后才允许 v3 进入后台待上传状态。
    static func markNutritionGoalSavedAndSurveyV3Pending(ownerUID: String) {
        UserDefaults.standard.set(true, forKey: Key.nutritionGoalSaved)
        UserDefaults.standard.set(true, forKey: Key.surveyV3Pending)
        UserDefaults.standard.set(ownerUID, forKey: Key.pendingOwnerUID)
        Guide0820DefaultsFlusher.flush()
    }

    static var pendingOwnerUID: String? {
        storedString(forKey: Key.pendingOwnerUID)
    }

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
            Key.directionProfileFatLossProteinHabit,
            Key.directionProfileFoodAdjustment
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
        clearStoredData(includePresentationState: true)
    }

    /// v3 绑定成功后清除全部问卷业务数据，但保留“引导已展示”标记，避免影响启动路由。
    static func clearUploadedData() {
        clearStoredData(includePresentationState: false)
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
    static var storedDataKeys: [String] {
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
            Key.directionProfileFoodAdjustment,
            Key.finalCarbohydrate,
            Key.finalProtein,
            Key.finalFat,
            Key.finalCalories,
            Key.pendingDataReady,
            Key.nutritionGoalSaved,
            Key.surveyV3Pending,
            Key.pendingOwnerUID
        ]
    }

    static func clearStoredData(includePresentationState: Bool) {
        Guide0820SourceStorage.clear()
        var keys = storedDataKeys
        if includePresentationState {
            keys.append(Guide0820VC.hasShownKey)
        }
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        Guide0820DefaultsFlusher.flush()
        Guide0820Model.shared.clear()
    }

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

/// Guide0820 登录后绑定协调器。
/// custom_save 必须成功后才继续登录；savePart/v3 始终静默执行，不阻塞登录和首页切换。
enum Guide0820PendingUploadManager {
    private static let stateLock = NSLock()
    private static var isSavingNutritionGoal = false
    private static var isUploadingSurveyV3 = false

    /// 如果当前是完整的 Guide0820 登录流程，则按现有 custom_save 逻辑保存正式目标并阻塞后续登录。
    /// - Returns: true 表示已接管本次登录完成动作，调用方不应继续执行旧问卷分支。
    @discardableResult
    static func handleLoginIfNeeded(controller: WHBaseViewVC,
                                    completion: @escaping () -> Void) -> Bool {
        Guide0820ProgressStorage.restoreAllToGuide0820Model()
        guard Guide0820ProgressStorage.hasPendingCompletedData else { return false }

        // custom_save 已成功但登录回调重复到达时，不重复设置目标，直接继续公共登录流程。
        if Guide0820ProgressStorage.hasSavedNutritionGoal {
            completion()
            return true
        }

        guard let parameters = customGoalParameters() else {
            controller.presentAlertVcNoAction(title: "请先完善营养目标", viewController: controller)
            return true
        }

        stateLock.lock()
        guard isSavingNutritionGoal == false else {
            stateLock.unlock()
            return true
        }
        isSavingNutritionGoal = true
        stateLock.unlock()

        WHNetworkUtil.shareManager().POST(
            urlString: URL_question_custom_save,
            parameters: parameters,
            isNeedToast: true,
            vc: controller
        ) { responseObject in
            setNutritionGoalSaving(false)
            guard responseObject["code"] as? Int == 200 else {
                let message = responseObject["message"] as? String ?? "营养目标保存失败，请重试"
                controller.presentAlertVcNoAction(title: message, viewController: controller)
                return
            }

            // 先持久化所属用户和 v3 pending，再继续登录，保证进程中断后仍可静默重试。
            let ownerUID = UserInfoModel.shared.uId.trimmingCharacters(in: .whitespacesAndNewlines)
            Guide0820ProgressStorage.markNutritionGoalSavedAndSurveyV3Pending(ownerUID: ownerUID)
            completion()
        } failure: { _ in
            // 失败保持所有 Guide0820 数据；当前 custom_save 按现有业务语义继续阻塞登录。
            setNutritionGoalSaving(false)
        }
        return true
    }

    /// 登录公共流程、已登录冷启动和 App 回到前台均可调用；无 pending 数据时立即返回。
    static func uploadPendingSurveyV3IfNeeded() {
        let currentUID = UserInfoModel.shared.uId.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentToken = UserInfoModel.shared.token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard currentUID.count >= 4, currentToken.count >= 4,
              Guide0820ProgressStorage.hasPendingSurveyV3Upload,
              Guide0820ProgressStorage.pendingOwnerUID == currentUID else {
            return
        }

        Guide0820ProgressStorage.restoreAllToGuide0820Model()
        guard let parameters = surveyV3Parameters() else {
            DLLog(message: "[Guide0820][savePart/v3] pending 数据不完整，保留本地数据")
            return
        }

        stateLock.lock()
        guard isUploadingSurveyV3 == false else {
            stateLock.unlock()
            return
        }
        isUploadingSurveyV3 = true
        stateLock.unlock()

        let requestOwnerUID = currentUID
        DLLog(message: "[Guide0820][savePart/v3] 业务参数：\(parameters)")
        WHNetworkUtil.shareManager().POST(
            urlString: URL_question_survey_savepart_v3,
            parameters: parameters,
            isNeedToast: false,
            vc: nil
        ) { responseObject in
            setSurveyV3Uploading(false)
            guard responseObject["code"] as? Int == 200 else { return }

            // 只清理由本次登录用户创建的 pending，避免异步响应误删另一轮数据。
            guard Guide0820ProgressStorage.pendingOwnerUID == requestOwnerUID else { return }
            Guide0820ProgressStorage.clearUploadedData()
            DLLog(message: "[Guide0820][savePart/v3] 上传成功，已清理本地待绑定数据")
        } failure: { _ in
            // v3 不影响登录；失败保留 pending，仅由冷启动或回前台再次触发。
            setSurveyV3Uploading(false)
        }
    }
}

private extension Guide0820PendingUploadManager {
    static func customGoalParameters() -> [String: AnyObject]? {
        let model = Guide0820Model.shared
        guard let carbohydrate = model.carbohydrate, carbohydrate >= 0,
              let protein = model.protein, protein > 0,
              let fat = model.fat, fat > 0,
              let calories = model.calories, calories > 0 else {
            return nil
        }

        // 完全沿用项目内 custom_save 的既有参数契约，只替换数据源为 Guide0820Model。
        return [
            "uid": UserInfoModel.shared.uId as NSString,
            "surveytype": "custom" as NSString,
            "calories": String(calories) as NSString,
            "protein": decimalText(protein) as NSString,
            "carbohydrate": decimalText(carbohydrate) as NSString,
            "fat": decimalText(fat) as NSString
        ]
    }

    static func surveyV3Parameters() -> [String: AnyObject]? {
        let model = Guide0820Model.shared
        guard let carbohydrate = model.carbohydrate, carbohydrate >= 0,
              let protein = model.protein, protein > 0,
              let fat = model.fat, fat > 0,
              let calories = model.calories, calories > 0,
              let target = model.guidanceGoalTarget,
              let familiarity = proteinFamiliarity(target: target, model: model) else {
            return nil
        }

        var parameters: [String: AnyObject] = [
            "carbohydrate": NSNumber(value: carbohydrate),
            "protein": NSNumber(value: protein),
            "fat": NSNumber(value: fat),
            "calories": NSNumber(value: calories),
            "fitnessGoal": NSNumber(value: target == .fatLoss ? 1 : 2),
            "highProteinDietFamiliarity": NSNumber(value: familiarity)
        ]

        if let acquisitionSource = model.acquisitionSource {
            parameters["acquisitionSource"] = NSNumber(value: acquisitionSource)
        }
        if let gender = Int(model.sex), gender == 1 || gender == 2 {
            parameters["gender"] = NSNumber(value: gender)
        }

        let birthday = (model.birthYear.isEmpty ? model.birthDay : model.birthYear)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if birthday.isEmpty == false { parameters["birthday"] = birthday as NSString }
        if let height = Int(model.height), height > 0 { parameters["height"] = NSNumber(value: height) }
        if let weight = Double(model.weight), weight > 0 { parameters["weight"] = NSNumber(value: weight) }
        if let value = ["unknown": 0, "yes": 1, "no": 2][model.guidanceBodyWeightExceededType] {
            parameters["hasExceededWeightThreshold"] = NSNumber(value: value)
        }
        if let value = ["stable": 1, "up": 2, "down": 3, "fluctuate": 4][model.guidanceRecentWeightTrendType] {
            parameters["recentWeightTrend"] = NSNumber(value: value)
        }
        let bodyFat = model.bodyFat.trimmingCharacters(in: .whitespacesAndNewlines)
        if bodyFat.isEmpty == false { parameters["bodyFat"] = bodyFat as NSString }

        let takeaway = model.guidanceTakeoutFrequencyType.trimmingCharacters(in: .whitespacesAndNewlines)
        if takeaway.isEmpty == false { parameters["weeklyTakeawayFrequency"] = takeaway as NSString }
        if let dailyMeals = dailyMeals(model.guidanceMealsAdjustType.isEmpty
                                       ? model.guidanceMealsPerDayType
                                       : model.guidanceMealsAdjustType) {
            parameters["dailyMeals"] = NSNumber(value: dailyMeals)
        }
        if let trackCalories = ["no": 0, "yes": 1][model.guidanceExerciseCaloriesRecordType] {
            parameters["trackExerciseCalories"] = NSNumber(value: trackCalories)
        }
        if let aerobic = aerobicFrequency(model.guidanceCardioFrequencyType) {
            parameters["weeklyAerobicExerciseFrequency"] = aerobic as NSString
        }
        let strength = model.guidanceStrengthTrainingFrequencyType.trimmingCharacters(in: .whitespacesAndNewlines)
        if strength.isEmpty == false { parameters["weeklyStrengthTrainingFrequency"] = strength as NSString }

        guard appendTargetParameters(target: target, model: model, parameters: &parameters) else {
            return nil
        }

        let adjustmentValues = model.foodAdjustment
            .split(separator: ",")
            .compactMap { ["none": 0, "body_scale": 1, "weight": 2, "mirror": 3][String($0)] }
        if adjustmentValues.isEmpty == false {
            parameters["dietAdjustmentBasis"] = adjustmentValues.map { NSNumber(value: $0) } as NSArray
        }
        return parameters
    }

    static func appendTargetParameters(target: GuidanceGoalPlanTarget,
                                       model: Guide0820Model,
                                       parameters: inout [String: AnyObject]) -> Bool {
        switch target {
        case .fatLoss:
            guard let approach = ["fast": 1, "moderate": 2, "steady": 3][model.fatLossMode],
                  let barrier = ["uncertain": 0, "high_carb": 1, "high_fat": 2][model.fatLossFoodFluctuation] else {
                return false
            }
            parameters["fatLossApproach"] = NSNumber(value: approach)
            parameters["fatLossDietBarrier"] = NSNumber(value: barrier)
            if let profile = profileValue(model.fatLossProfile) {
                parameters["fatLossTrainingProfile"] = NSNumber(value: profile)
            }
            if model.fatLossDurationWeeks > 0 {
                parameters["fatLossDurationWeeks"] = NSNumber(value: model.fatLossDurationWeeks)
            }
        case .muscleGain:
            guard let approach = ["quality": 1, "balanced": 2, "speed": 3][model.muscleGainMode],
                  let barrier = ["uncertain": 0, "slow_digestion": 1, "small_meal_capacity": 2][model.muscleGainBarrier] else {
                return false
            }
            parameters["muscleGainApproach"] = NSNumber(value: approach)
            parameters["muscleGainDietBarrier"] = NSNumber(value: barrier)
            if let profile = profileValue(model.muscleGainProfile) {
                parameters["muscleGainTrainingProfile"] = NSNumber(value: profile)
            }
            if model.muscleGainDurationWeeks > 0 {
                parameters["muscleGainDurationWeeks"] = NSNumber(value: model.muscleGainDurationWeeks)
            }
        }
        return true
    }

    static func proteinFamiliarity(target: GuidanceGoalPlanTarget, model: Guide0820Model) -> Int? {
        let rawValue = target == .muscleGain ? model.muscleGainProteinHabit : model.fatLossProteinHabit
        return ["high": 1, "medium": 2, "low": 3][rawValue]
    }

    static func profileValue(_ rawValue: String) -> Int? {
        [
            "daily_training": 1,
            "regular_fitness": 2,
            "bodybuilder": 3,
            "hyrox": 4,
            "endurance_athlete": 5,
            "strength_athlete": 5
        ][rawValue]
    }

    static func dailyMeals(_ rawValue: String) -> Int? {
        ["2": 2, "3": 3, "4": 4, "5": 5, "6+": 6][rawValue]
    }

    static func aerobicFrequency(_ rawValue: String) -> String? {
        switch rawValue {
        case "never": return "0"
        case "commute": return "1"
        case "2-3", "4-5": return rawValue
        case "6-7", "6+": return "6+"
        default: return nil
        }
    }

    static func decimalText(_ value: Double) -> String {
        value.rounded() == value ? String(Int(value)) : String(format: "%.1f", value)
    }

    static func setNutritionGoalSaving(_ value: Bool) {
        stateLock.lock()
        isSavingNutritionGoal = value
        stateLock.unlock()
    }

    static func setSurveyV3Uploading(_ value: Bool) {
        stateLock.lock()
        isUploadingSurveyV3 = value
        stateLock.unlock()
    }
}
