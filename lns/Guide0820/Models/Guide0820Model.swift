//
//  Guide0820Model.swift
//  lns
//
//  Guide0820 引导流程专用问卷模型。
//

import Foundation

/// Guide0820 流程内使用的独立问卷模型，避免与旧问卷流程共享全局状态。
final class Guide0820Model {
    /// `shared` 属性，保存该类型对外提供或内部使用的状态与配置。
    static let shared = Guide0820Model()

    // 初始化当前类型实例。
    private init() {}

    // 身体资料
    /// `sex` 属性，保存该类型对外提供或内部使用的状态与配置。
    var sex = ""
    /// `birthDay` 属性，保存该类型对外提供或内部使用的状态与配置。
    var birthDay = ""
    /// `birthYear` 属性，保存该类型对外提供或内部使用的状态与配置。
    var birthYear = ""
    /// `height` 属性，保存该类型对外提供或内部使用的状态与配置。
    var height = ""
    /// `weight` 属性，保存该类型对外提供或内部使用的状态与配置。
    var weight = ""
    /// `bodyFat` 属性，保存该类型对外提供或内部使用的状态与配置。
    var bodyFat = ""
    /// `guidanceBodyWeightExceededType` 属性，保存该类型对外提供或内部使用的状态与配置。
    var guidanceBodyWeightExceededType = ""
    /// `guidanceRecentWeightTrendType` 属性，保存该类型对外提供或内部使用的状态与配置。
    var guidanceRecentWeightTrendType = ""

    // 生活资料
    /// `guidanceTakeoutFrequencyType` 属性，保存该类型对外提供或内部使用的状态与配置。
    var guidanceTakeoutFrequencyType = ""
    /// `guidanceMealsPerDayType` 属性，保存该类型对外提供或内部使用的状态与配置。
    var guidanceMealsPerDayType = ""
    /// `guidanceMealsAdjustType` 属性，保存该类型对外提供或内部使用的状态与配置。
    var guidanceMealsAdjustType = ""
    /// `guidanceExerciseCaloriesRecordType` 属性，保存该类型对外提供或内部使用的状态与配置。
    var guidanceExerciseCaloriesRecordType = ""
    /// `guidanceCardioFrequencyType` 属性，保存该类型对外提供或内部使用的状态与配置。
    var guidanceCardioFrequencyType = ""
    /// `guidanceStrengthTrainingFrequencyType` 属性，保存该类型对外提供或内部使用的状态与配置。
    var guidanceStrengthTrainingFrequencyType = ""
    /// `events` 属性，保存该类型对外提供或内部使用的状态与配置。
    var events = ""
    /// `caloriesNumber` 属性，保存该类型对外提供或内部使用的状态与配置。
    var caloriesNumber = ""
    /// `caloriesNumberFromServer` 属性，保存该类型对外提供或内部使用的状态与配置。
    var caloriesNumberFromServer = ""

    /// 清空 Guide0820 当前流程内存数据。
    func clear() {
        sex = ""
        birthDay = ""
        birthYear = ""
        height = ""
        weight = ""
        bodyFat = ""
        guidanceBodyWeightExceededType = ""
        guidanceRecentWeightTrendType = ""
        guidanceTakeoutFrequencyType = ""
        guidanceMealsPerDayType = ""
        guidanceMealsAdjustType = ""
        guidanceExerciseCaloriesRecordType = ""
        guidanceCardioFrequencyType = ""
        guidanceStrengthTrainingFrequencyType = ""
        events = ""
        caloriesNumber = ""
        caloriesNumberFromServer = ""
    }

    /// 执行 `printModelMsg` 操作，完成当前引导页面的状态更新或交互处理。
    func printModelMsg() {
        DLLog(message: "Guide0820 性别：\(sex)")
        DLLog(message: "Guide0820 出生年份：\(birthDay.isEmpty ? birthYear : birthDay)")
        DLLog(message: "Guide0820 身高：\(height)")
        DLLog(message: "Guide0820 体重：\(weight)")
        DLLog(message: "Guide0820 体脂率：\(bodyFat)")
        DLLog(message: "Guide0820 历史体重超过当前：\(guidanceBodyWeightExceededType)")
        DLLog(message: "Guide0820 近四周体重趋势：\(guidanceRecentWeightTrendType)")
        DLLog(message: "Guide0820 外食频率：\(guidanceTakeoutFrequencyType)")
        DLLog(message: "Guide0820 每日餐数：\(guidanceMealsPerDayType)")
        DLLog(message: "Guide0820 餐数调整：\(guidanceMealsAdjustType)")
        DLLog(message: "Guide0820 有氧频率：\(guidanceCardioFrequencyType)")
        DLLog(message: "Guide0820 力量训练频率：\(guidanceStrengthTrainingFrequencyType)")
        DLLog(message: "Guide0820 运动消耗记录：\(guidanceExerciseCaloriesRecordType)")
        DLLog(message: "Guide0820 活动量：\(events)")
        DLLog(message: "Guide0820 维持热量：\(caloriesNumber)")
    }
}
