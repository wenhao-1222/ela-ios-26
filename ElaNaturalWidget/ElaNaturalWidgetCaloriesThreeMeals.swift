//
//  ElaNaturalWidgetCaloriesThreeMeals.swift
//  ElaNaturalWidgetExtension
//
//  Created by Codex on 2026/8/31.
//

import WidgetKit
import SwiftUI

struct ElaNaturalWidgetCaloriesThreeMealsEntryView: View {
    let entry: Provider.Entry

    var body: some View {
        ElaNaturalCaloriesMealsWidgetEntryView(entry: entry, mealCount: 3)
    }
}

struct ElaNaturalWidgetCaloriesThreeMeals: Widget {
    let kind: String = "ElaNaturalWidgetCaloriesThreeMeals"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ElaNaturalWidgetCaloriesThreeMealsEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        CaloriesMealsWidgetBackground()
                    }
                    .edgesIgnoringSafeArea(.all)
            } else {
                ElaNaturalWidgetCaloriesThreeMealsEntryView(entry: entry)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .configurationDisplayName("饮食记录")
        .description("今日营养目标 & 快速记录饮食")
        .supportedFamilies([.systemMedium])
        .disableContentMarginsIfNeeded()
    }
}
