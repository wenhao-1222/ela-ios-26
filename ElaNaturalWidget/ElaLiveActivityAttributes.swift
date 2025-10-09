//
//  ElaLiveActivityAttributes.swift
//  lns
//
//  Created by Elavatine on 2025/5/28.
//

import ActivityKit

struct ElaLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var message: String
        var calories: Int
        var caloriesTarget: Int
//        var sportCalories: Int
        var carbs: Int
        var carbsTarget: Int
        var protein: Int
        var proteinTarget: Int
        var fat: Int
        var fatTarget: Int
//        var water: Int
    }

    var title: String
    /// Whether to display water record
//    var showWater: Bool
}
