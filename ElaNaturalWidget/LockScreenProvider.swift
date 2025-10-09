//
//  LockScreenProvider.swift
//  lns
//
//  Created by Elavatine on 2025/5/30.
//

import WidgetKit
import SwiftUI

struct LockScreenProvider: TimelineProvider {
    func placeholder(in context: Context) -> LockScreenEntry {
        LockScreenEntry(date: Date(), isSnap: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (LockScreenEntry) -> ()) {
        let entry = LockScreenEntry(date: Date(), isSnap: true)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LockScreenEntry>) -> ()) {
        let entry = LockScreenEntry(date: Date(), isSnap: false)
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }
}

struct LockScreenEntry: TimelineEntry {
    let date: Date
    let isSnap: Bool
}

struct ElaLockScreenWidgetView: View {
    var entry: LockScreenProvider.Entry

    var body: some View {
        let dict = entry.isSnap ? WidgetUtils().readNaturalDataDefault() : WidgetUtils().readNaturalData()
        let sportCalories = WidgetUtils().readSportInTargetStatus() == "0" ? 0 : Int(dict.doubleValueForKeyWidget(key: "sportCalories").rounded())
        let caloriesTarget = Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) + sportCalories
        let calories = Int(dict.doubleValueForKeyWidget(key: "calori").rounded())
        let carbsTarget = Int(dict.doubleValueForKeyWidget(key: "carboTar").rounded())
        let carbs = Int(dict.doubleValueForKeyWidget(key: "carbohydrates").rounded())
        let proteinTarget = Int(dict.doubleValueForKeyWidget(key: "proteinTar").rounded())
        let protein = Int(dict.doubleValueForKeyWidget(key: "protein").rounded())
        let fatTarget = Int(dict.doubleValueForKeyWidget(key: "fatsTar").rounded())
        let fat = Int(dict.doubleValueForKeyWidget(key: "fats").rounded())

        HStack(spacing: 8) {
            CircleView(caloriesTarget: caloriesTarget, calories: calories, sportCalories: sportCalories)
                .frame(width: 40, height: 40)
            HStack(spacing: 4) {
                ElaNaturalWidgetCaloriesCircleView(caloriesTarget: carbsTarget, calories: carbs, themeColor: Color(UIColor.COLOR_CARBOHYDRATE), fillColor: Color(UIColor.COLOR_CARBOHYDRATE_FILL))
                    .frame(width: 24, height: 24)
                ElaNaturalWidgetCaloriesCircleView(caloriesTarget: proteinTarget, calories: protein, themeColor: Color(UIColor.COLOR_PROTEIN), fillColor: Color(UIColor.COLOR_PROTEIN_FILL))
                    .frame(width: 24, height: 24)
                ElaNaturalWidgetCaloriesCircleView(caloriesTarget: fatTarget, calories: fat, themeColor: Color(UIColor.COLOR_FAT), fillColor: Color(UIColor.COLOR_FAT_FILL))
                    .frame(width: 24, height: 24)
            }
        }
    }
}

struct ElaLockScreenWidget: Widget {
    let kind: String = "ElaLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LockScreenProvider()) { entry in
            if #available(iOS 17.0, *) {
                ElaLockScreenWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ElaLockScreenWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("锁屏营养")
        .description("在锁屏上查看卡路里与三大营养素摄入情况")
//        .supportedFamilies([.accessoryRectangular])
        .disableContentMarginsIfNeeded()
    }
}
