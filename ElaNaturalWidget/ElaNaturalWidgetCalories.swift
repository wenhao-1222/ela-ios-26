//
//  ElaNaturalWidgetCalories.swift
//  ElaNaturalWidgetExtension
//
//  Created by LNS2 on 2024/9/6.
//

import WidgetKit
import SwiftUI

private enum CaloriesMealsWidgetStyle {
    static let designSize = CGSize(width: 326, height: 154)
    static let contentHeight: CGFloat = 123.5

    static func contentWidth(for mealCount: Int) -> CGFloat {
        mealCount == 3 ? 225 : 200
    }

    static func macroSpacing(for mealCount: Int) -> CGFloat {
        mealCount == 3 ? 29.5 : 17.5
    }

    static func actionAreaWidth(for mealCount: Int) -> CGFloat {
        mealCount == 3 ? 55 : 96
    }

    static func actionColumnWidth(for mealCount: Int) -> CGFloat {
        mealCount == 3 ? 55 : 48
    }

    static func divider(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
    }
}

struct CaloriesMealsWidgetBackground: View {
    var body: some View {
        FiveMealsWidgetBackground()
    }
}

struct ElaNaturalCaloriesMealsWidgetEntryView: View {
    let entry: Provider.Entry
    let mealCount: Int

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let dict = entry.isSnap ? WidgetUtils().readNaturalDataDefault() : WidgetUtils().readNaturalData()
        let mealsArray = entry.isSnap ? WidgetUtils().readCurrentDayMealsMsgDefault() : WidgetUtils().readCurrentDayMealsMsg()
        let sportCalories = WidgetUtils().readSportInTargetStatus() == "0"
            ? 0
            : Int(dict.doubleValueForKeyWidget(key: "sportCalories").rounded())
        let caloriesTarget = Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) + sportCalories
        let calories = Int(dict.doubleValueForKeyWidget(key: "calori").rounded())
        let completionStates = (0..<mealCount).map { index in
            index < mealsArray.count && FiveMealsMealStateResolver.isRecorded(mealsArray[index])
        }
        let highestCompletedIndex = completionStates.lastIndex(where: { $0 })
        let nextMealIndex: Int? = {
            guard let highestCompletedIndex else { return 0 }
            let candidate = highestCompletedIndex + 1
            return candidate < completionStates.count ? candidate : nil
        }()

        GeometryReader { geometry in
            let scale = min(
                geometry.size.width / CaloriesMealsWidgetStyle.designSize.width,
                geometry.size.height / CaloriesMealsWidgetStyle.designSize.height
            )
            let dividerWidth = max(0.5, 0.5 * scale)
            let isThreeMealLayout = mealCount == 3
            let contentWidth = CaloriesMealsWidgetStyle.contentWidth(for: mealCount) * scale
            let actionAreaWidth = CaloriesMealsWidgetStyle.actionAreaWidth(for: mealCount) * scale
            let actionColumnWidth = CaloriesMealsWidgetStyle.actionColumnWidth(for: mealCount) * scale
            let rowCount = mealCount / 2
            let rowHeight = isThreeMealLayout ? 0 : geometry.size.height / CGFloat(rowCount)

            ZStack(alignment: .topLeading) {
                CaloriesMealsWidgetBackground()

                VStack(alignment: .leading, spacing: 18 * scale) {
                    CaloriesMealsHeaderProgress(
                        calories: calories,
                        target: caloriesTarget,
                        scale: scale
                    )

                    HStack(spacing: CaloriesMealsWidgetStyle.macroSpacing(for: mealCount) * scale) {
                        CaloriesMealsMacroRing(
                            title: "碳水",
                            value: Int(dict.doubleValueForKeyWidget(key: "carbohydrates").rounded()),
                            target: Int(dict.doubleValueForKeyWidget(key: "carboTar").rounded()),
                            progressColor: FiveMealsWidgetStyle.carbohydrate,
                            scale: scale
                        )

                        CaloriesMealsMacroRing(
                            title: "蛋白质",
                            value: Int(dict.doubleValueForKeyWidget(key: "protein").rounded()),
                            target: Int(dict.doubleValueForKeyWidget(key: "proteinTar").rounded()),
                            progressColor: FiveMealsWidgetStyle.protein,
                            scale: scale
                        )

                        CaloriesMealsMacroRing(
                            title: "脂肪",
                            value: Int(dict.doubleValueForKeyWidget(key: "fats").rounded()),
                            target: Int(dict.doubleValueForKeyWidget(key: "fatsTar").rounded()),
                            progressColor: FiveMealsWidgetStyle.fat,
                            scale: scale
                        )
                    }
                }
                .frame(
                    width: contentWidth,
                    height: CaloriesMealsWidgetStyle.contentHeight * scale,
                    alignment: .topLeading
                )
                .offset(x: 15 * scale, y: 15 * scale)

                Rectangle()
                    .fill(CaloriesMealsWidgetStyle.divider(for: colorScheme))
                    .frame(width: dividerWidth, height: geometry.size.height)
                    .offset(x: geometry.size.width - actionAreaWidth)

                if isThreeMealLayout {
                    VStack(spacing: 17 * scale) {
                        ForEach(0..<3, id: \.self) { index in
                            let actionState: FiveMealsActionState = completionStates[index]
                                ? .recorded
                                : (nextMealIndex == index ? .next : .inactive)

                            Link(destination: URL(string: "elavatinelns://mealsIndex_\(index + 1)")!) {
                                CaloriesThreeMealsActionCell(state: actionState, scale: scale)
                            }
                            .frame(width: actionAreaWidth, height: 30 * scale)
                        }
                    }
                    .frame(width: actionAreaWidth, alignment: .top)
                    .offset(x: geometry.size.width - actionAreaWidth, y: 15 * scale)

                    Rectangle()
                        .fill(CaloriesMealsWidgetStyle.divider(for: colorScheme))
                        .frame(width: actionAreaWidth, height: dividerWidth)
                        .offset(x: geometry.size.width - actionAreaWidth, y: 53.5 * scale)

                    Rectangle()
                        .fill(CaloriesMealsWidgetStyle.divider(for: colorScheme))
                        .frame(width: actionAreaWidth, height: dividerWidth)
                        .offset(x: geometry.size.width - actionAreaWidth, y: 100.5 * scale)
                } else {
                    Rectangle()
                        .fill(CaloriesMealsWidgetStyle.divider(for: colorScheme))
                        .frame(width: dividerWidth, height: geometry.size.height)
                        .offset(x: geometry.size.width - actionColumnWidth)

                    VStack(spacing: 0) {
                        ForEach(0..<rowCount, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<2, id: \.self) { column in
                                    let index = row * 2 + column
                                    let actionState: FiveMealsActionState = completionStates[index]
                                        ? .recorded
                                        : (nextMealIndex == index ? .next : .inactive)

                                    Link(destination: URL(string: "elavatinelns://mealsIndex_\(index + 1)")!) {
                                        FiveMealsActionCell(state: actionState, scale: scale)
                                    }
                                    .frame(width: actionColumnWidth, height: rowHeight)
                                }
                            }
                            .overlay(alignment: .bottom) {
                                if row < rowCount - 1 {
                                    Rectangle()
                                        .fill(CaloriesMealsWidgetStyle.divider(for: colorScheme))
                                        .frame(height: dividerWidth)
                                }
                            }
                        }
                    }
                    .frame(width: actionAreaWidth, height: geometry.size.height)
                    .offset(x: geometry.size.width - actionAreaWidth)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

private struct CaloriesThreeMealsActionCell: View {
    let state: FiveMealsActionState
    let scale: CGFloat

    private var iconSize: CGFloat {
        switch state {
        case .recorded:
            return 25
        case .next, .inactive:
            return 30
        }
    }

    var body: some View {
        Image(ImageResource(name: state.iconName, bundle: .main))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: iconSize * scale, height: iconSize * scale)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
    }
}

private struct CaloriesMealsHeaderProgress: View {
    let calories: Int
    let target: Int
    let scale: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    private var progress: CGFloat {
        guard target > 0 else { return 0 }
        return max(0, CGFloat(calories) / CGFloat(target))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8 * scale) {
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                HStack(spacing: 3 * scale) {
                    Image(ImageResource(name: "calories_widget_icon", bundle: .main))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16 * scale, height: 16 * scale)

                    Text("卡路里")
                        .foregroundColor(FiveMealsWidgetStyle.primaryText(for: colorScheme))
                        .font(Font.custom("PingFangSC-Regular", size: 13 * scale))
                        .lineLimit(1)
                }

                Spacer(minLength: 4 * scale)

                Text(verbatim: String(calories))
                    .foregroundColor(
                        calories > target
                            ? FiveMealsWidgetStyle.overflowRed
                            : FiveMealsWidgetStyle.primaryText(for: colorScheme)
                    )
                    .font(Font.custom("D-DIN-PRO-SemiBold", size: 16 * scale))
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(verbatim: "/\(target)千卡")
                    .foregroundColor(FiveMealsWidgetStyle.secondaryText(for: colorScheme))
                    .font(Font.custom("PingFangSC-Regular", size: 9 * scale))
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            .frame(height: 19.5 * scale)

            CaloriesMealsLinearProgress(
                progress: progress,
                progressColor: FiveMealsWidgetStyle.themeBlue,
                scale: scale
            )
        }
        .frame(height: 35.5 * scale, alignment: .top)
    }
}

private struct CaloriesMealsLinearProgress: View {
    let progress: CGFloat
    let progressColor: Color
    let scale: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geometry in
            let normalProgress = min(max(progress, 0), 1)
            let overflowProgress = min(max(progress - 1, 0), 1)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(FiveMealsWidgetStyle.track(for: colorScheme))

                Capsule()
                    .fill(progressColor)
                    .frame(width: geometry.size.width * normalProgress)

                if overflowProgress > 0 {
                    Capsule()
                        .fill(FiveMealsWidgetStyle.macroOverflow)
                        .frame(width: geometry.size.width * overflowProgress)
                }
            }
        }
        .frame(height: 8 * scale)
    }
}

private struct CaloriesMealsMacroRing: View {
    let title: String
    let value: Int
    let target: Int
    let progressColor: Color
    let scale: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    private var progress: CGFloat {
        guard target > 0 else { return 0 }
        return max(0, CGFloat(value) / CGFloat(target))
    }

    var body: some View {
        VStack(spacing: 7 * scale) {
            ZStack {
                let normalProgress = min(progress, 1)
                let overflowProgress = min(max(progress - 1, 0), 1)
                let lineWidth = 5 * scale

                Circle()
                    .inset(by: lineWidth / 2)
                    .stroke(FiveMealsWidgetStyle.ringTrack(for: colorScheme), lineWidth: lineWidth)

                if normalProgress > 0 {
                    Circle()
                        .inset(by: lineWidth / 2)
                        .trim(from: 0, to: normalProgress)
                        .stroke(
                            progressColor,
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }

                if overflowProgress > 0 {
                    Circle()
                        .inset(by: lineWidth / 2)
                        .trim(from: 0, to: overflowProgress)
                        .stroke(
                            FiveMealsWidgetStyle.macroOverflow,
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }

                VStack(spacing: 1 * scale) {
                    Text(verbatim: String(value))
                        .foregroundColor(
                            value > target
                                ? FiveMealsWidgetStyle.overflowRed
                                : FiveMealsWidgetStyle.primaryText(for: colorScheme)
                        )
                        .font(Font.custom("D-DIN-PRO-SemiBold", size: 14 * scale))
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)

                    Text(verbatim: "/\(target)")
                        .foregroundColor(FiveMealsWidgetStyle.secondaryText(for: colorScheme))
                        .font(Font.custom("PingFangSC-Regular", size: 11 * scale))
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
                .padding(.horizontal, 5 * scale)
            }
            .frame(width: 50 * scale, height: 50 * scale)

            Text(title)
                .foregroundColor(FiveMealsWidgetStyle.primaryText(for: colorScheme))
                .font(Font.custom("PingFangSC-Regular", size: 10 * scale))
                .lineLimit(1)
                .frame(width: 55 * scale, height: 10 * scale)
        }
        .padding(.top, 2.5 * scale)
        .frame(width: 55 * scale, height: 70 * scale, alignment: .top)
    }
}

struct ElaNaturalWidgetCaloriesEntryView: View {
    let entry: Provider.Entry

    var body: some View {
        ElaNaturalCaloriesMealsWidgetEntryView(entry: entry, mealCount: 6)
    }
}

struct ElaNaturalWidgetCalories: Widget {
    let kind: String = "ElaNaturalWidgetCalories"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ElaNaturalWidgetCaloriesEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        CaloriesMealsWidgetBackground()
                    }
                    .edgesIgnoringSafeArea(.all)
            } else {
                ElaNaturalWidgetCaloriesEntryView(entry: entry)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .configurationDisplayName("饮食记录")
        .description("今日营养目标 & 快速记录饮食")
        .supportedFamilies([.systemMedium])
        .disableContentMarginsIfNeeded()
    }
}
