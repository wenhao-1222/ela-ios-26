//
//  GuidanceGoalPlanModels.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

/// GuidanceGoalPlanTarget 类型，封装 Guide0820 引导流程中的相关功能。
enum GuidanceGoalPlanTarget: String {
    case muscleGain
    case fatLoss

    /// `title` 属性，保存该类型对外提供或内部使用的状态与配置。
    var title: String {
        switch self {
        case .muscleGain: return "增肌"
        case .fatLoss: return "减脂"
        }
    }

    /// `accentColor` 属性，保存该类型对外提供或内部使用的状态与配置。
    var accentColor: UIColor {
        switch self {
        case .muscleGain:
            return GuidanceGoalPlanStyle.muscleGainColor
        case .fatLoss:
            return GuidanceGoalPlanStyle.muscleGainColor
        }
    }
}

/// GuidanceGoalPlanStep 类型，封装 Guide0820 引导流程中的相关功能。
enum GuidanceGoalPlanStep: String {
    case goal
    case profile
    case muscleGainBarrier
    case muscleGainMode
    case muscleGainDuration
    case muscleGainProfile
    case muscleGainProteinHabit
    case fatLossFoodFluctuation
    case fatLossMode
    case fatLossDuration
    case fatLossProfile
    case fatLossProteinHabit
    case foodAdjustment
}

/// GuidanceGoalPlanOption 类型，封装 Guide0820 引导流程中的相关功能。
struct GuidanceGoalPlanOption {
    /// `title` 属性，保存该类型对外提供或内部使用的状态与配置。
    let title: String
    /// `detail` 属性，保存该类型对外提供或内部使用的状态与配置。
    let detail: String?
    /// `value` 属性，保存该类型对外提供或内部使用的状态与配置。
    let value: String
    /// `iconName` 属性，保存该类型对外提供或内部使用的状态与配置。
    let iconName: String?

    /// 初始化当前类型实例。
    init(title: String, detail: String?, value: String, iconName: String? = nil) {
        self.title = title
        self.detail = detail
        self.value = value
        self.iconName = iconName
    }
}

/// GuidanceGoalPlanFlowState 类型，封装 Guide0820 引导流程中的相关功能。
final class GuidanceGoalPlanFlowState {
    /// `target` 属性，保存该类型对外提供或内部使用的状态与配置。
    var target: GuidanceGoalPlanTarget?
    /// `muscleGainBarrier` 属性，保存该类型对外提供或内部使用的状态与配置。
    var muscleGainBarrier = ""
    /// `muscleGainMode` 属性，保存该类型对外提供或内部使用的状态与配置。
    var muscleGainMode = ""
    /// `muscleGainDurationWeeks` 属性，保存该类型对外提供或内部使用的状态与配置。
    var muscleGainDurationWeeks = 12
    /// `muscleGainProfile` 属性，保存该类型对外提供或内部使用的状态与配置。
    var muscleGainProfile = ""
    /// `muscleGainProteinHabit` 属性，保存该类型对外提供或内部使用的状态与配置。
    var muscleGainProteinHabit = ""
    /// `fatLossFoodFluctuation` 属性，保存该类型对外提供或内部使用的状态与配置。
    var fatLossFoodFluctuation = ""
    /// `fatLossMode` 属性，保存该类型对外提供或内部使用的状态与配置。
    var fatLossMode = ""
    /// `fatLossDurationWeeks` 属性，保存该类型对外提供或内部使用的状态与配置。
    var fatLossDurationWeeks = 12
    /// `fatLossProfile` 属性，保存该类型对外提供或内部使用的状态与配置。
    var fatLossProfile = ""
    /// `fatLossProteinHabit` 属性，保存该类型对外提供或内部使用的状态与配置。
    var fatLossProteinHabit = ""
    /// Comma-separated values selected on the final food-adjustment page.
    var foodAdjustment = ""

    /// `steps` 属性，保存该类型对外提供或内部使用的状态与配置。
    var steps: [GuidanceGoalPlanStep] {
        switch target {
        case .muscleGain:
            return [.goal, .profile, .muscleGainBarrier, .muscleGainProteinHabit, .muscleGainMode, .muscleGainDuration, .foodAdjustment]
        case .fatLoss:
            return [.goal, .profile, .fatLossFoodFluctuation, .fatLossProteinHabit, .fatLossMode, .fatLossDuration, .foodAdjustment]
        case .none:
            return [.goal]
        }
    }

    /// 执行 `selectedValue` 操作，完成当前引导页面的状态更新或交互处理。
    func selectedValue(for step: GuidanceGoalPlanStep) -> String {
        switch step {
        case .goal:
            return target?.rawValue ?? ""
        case .profile:
            switch target {
            case .muscleGain:
                return muscleGainProfile
            case .fatLoss:
                return fatLossProfile
            case .none:
                return ""
            }
        case .muscleGainBarrier:
            return muscleGainBarrier
        case .muscleGainMode:
            return muscleGainMode
        case .muscleGainDuration:
            return muscleGainDurationWeeks > 0 ? "\(muscleGainDurationWeeks)" : ""
        case .muscleGainProfile:
            return muscleGainProfile
        case .muscleGainProteinHabit:
            return muscleGainProteinHabit
        case .fatLossFoodFluctuation:
            return fatLossFoodFluctuation
        case .fatLossMode:
            return fatLossMode
        case .fatLossDuration:
            return fatLossDurationWeeks > 0 ? "\(fatLossDurationWeeks)" : ""
        case .fatLossProfile:
            return fatLossProfile
        case .fatLossProteinHabit:
            return fatLossProteinHabit
        case .foodAdjustment:
            return foodAdjustment
        }
    }
}

/// GuidanceGoalPlanStyle 类型，封装 Guide0820 引导流程中的相关功能。
enum GuidanceGoalPlanStyle {
    /// `muscleGainColor` 属性，保存该类型对外提供或内部使用的状态与配置。
    static let muscleGainColor = UIColor.THEME
    // Both branches use the same blue theme.
    /// `fatLossColor` 属性，保存该类型对外提供或内部使用的状态与配置。
    static let fatLossColor = muscleGainColor
    /// `titleColor` 属性，保存该类型对外提供或内部使用的状态与配置。
    static let titleColor = UIColor.COLOR_TEXT_TITLE_0f1214
    /// `detailColor` 属性，保存该类型对外提供或内部使用的状态与配置。
    static let detailColor = UIColor.COLOR_TEXT_TITLE_0f1214_50
    /// `cardBackgroundColor` 属性，保存该类型对外提供或内部使用的状态与配置。
    static let cardBackgroundColor = UIColor.COLOR_CARD_BG_WHITE
    /// 减脂模式页底部提示卡的背景色；如需调整提示区域颜色，请修改这里。
    static let infoNoticeBackgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_05
    /// `pageBackgroundColor` 属性，保存该类型对外提供或内部使用的状态与配置。
    static let pageBackgroundColor = UIColor.COLOR_BG_F2
    /// `unselectedBorderColor` 属性，保存该类型对外提供或内部使用的状态与配置。
    static let unselectedBorderColor = UIColor.COLOR_TEXT_TITLE_0f1214_05
}
