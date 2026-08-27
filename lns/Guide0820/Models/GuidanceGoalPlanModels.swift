//
//  GuidanceGoalPlanModels.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit

enum GuidanceGoalPlanTarget: String {
    case muscleGain
    case fatLoss

    var title: String {
        switch self {
        case .muscleGain: return "增肌"
        case .fatLoss: return "减脂"
        }
    }

    var accentColor: UIColor {
        switch self {
        case .muscleGain:
            return GuidanceGoalPlanStyle.muscleGainColor
        case .fatLoss:
            return GuidanceGoalPlanStyle.fatLossColor
        }
    }
}

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
}

struct GuidanceGoalPlanOption {
    let title: String
    let detail: String?
    let value: String
    let iconName: String?

    init(title: String, detail: String?, value: String, iconName: String? = nil) {
        self.title = title
        self.detail = detail
        self.value = value
        self.iconName = iconName
    }
}

final class GuidanceGoalPlanFlowState {
    var target: GuidanceGoalPlanTarget?
    var muscleGainBarrier = ""
    var muscleGainMode = ""
    var muscleGainDurationWeeks = 12
    var muscleGainProfile = ""
    var muscleGainProteinHabit = ""
    var fatLossFoodFluctuation = ""
    var fatLossMode = ""
    var fatLossDurationWeeks = 12
    var fatLossProfile = ""
    var fatLossProteinHabit = ""

    var steps: [GuidanceGoalPlanStep] {
        switch target {
        case .muscleGain:
            return [.goal, .profile, .muscleGainBarrier, .muscleGainProteinHabit, .muscleGainMode, .muscleGainDuration]
        case .fatLoss:
            return [.goal, .profile, .fatLossFoodFluctuation, .fatLossMode, .fatLossDuration, .fatLossProteinHabit]
        case .none:
            return [.goal]
        }
    }

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
        }
    }
}

enum GuidanceGoalPlanStyle {
    static let muscleGainColor = WHColor_16(colorStr: "1677F2")
    static let fatLossColor = WHColor_16(colorStr: "FF8725")
    static let titleColor = UIColor.COLOR_TEXT_TITLE_0f1214
    static let detailColor = UIColor.COLOR_TEXT_TITLE_0f1214_50
    static let cardBackgroundColor = UIColor.COLOR_CARD_BG_WHITE
    static let pageBackgroundColor = UIColor.COLOR_BG_F2
    static let unselectedBorderColor = UIColor.COLOR_TEXT_TITLE_0f1214_05.cgColor
}
