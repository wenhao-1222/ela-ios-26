//
//  ElaWeekCaloriesWidget.swift
//  ElaWeekCaloriesWidget
//
//  Created by LNS2 on 2024/8/19.
//

import WidgetKit
import SwiftUI

enum WeekRemainingMetric: Equatable {
    case calories
    case carbohydrate
    case protein
    case fat

    var title: String {
        switch self {
        case .calories:
            return "卡路里剩余"
        case .carbohydrate:
            return "碳水剩余"
        case .protein:
            return "蛋白质剩余"
        case .fat:
            return "脂肪剩余"
        }
    }

    var unit: String {
        self == .calories ? "千卡" : "g"
    }

    var accent: Color {
        switch self {
        case .calories:
            return Color("color_natural_calories", bundle: .main)
        case .carbohydrate:
            return Color("color_natural_carbo", bundle: .main)
        case .protein:
            return Color("color_natural_protein", bundle: .main)
        case .fat:
            return Color("color_natural_fat", bundle: .main)
        }
    }

    /// Opaque equivalent of rgba(15, 18, 20, 0.5) composited over the
    /// corresponding light-mode progress color.
    var lightOpaqueOverflowColor: Color {
        switch self {
        case .calories:
            return Color(
                red: 7.5 / 255.0,
                green: 70.0 / 255.0,
                blue: 137.5 / 255.0
            )
        case .carbohydrate:
            return Color(
                red: 64.0 / 255.0,
                green: 36.5 / 255.0,
                blue: 105.5 / 255.0
            )
        case .protein:
            return Color(
                red: 130.0 / 255.0,
                green: 102.0 / 255.0,
                blue: 22.0 / 255.0
            )
        case .fat:
            return Color(
                red: 121.0 / 255.0,
                green: 66.5 / 255.0,
                blue: 22.0 / 255.0
            )
        }
    }

    var lightBackgroundTint: Color {
        switch self {
        case .calories:
            return Color(red: 0.0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0).opacity(0.12)
        case .carbohydrate:
            return Color(red: 155.0 / 255.0, green: 81.0 / 255.0, blue: 255.0 / 255.0).opacity(0.12)
        case .protein:
            return Color(red: 255.0 / 255.0, green: 219.0 / 255.0, blue: 37.0 / 255.0).opacity(0.12)
        case .fat:
            return Color(red: 255.0 / 255.0, green: 135.0 / 255.0, blue: 37.0 / 255.0).opacity(0.12)
        }
    }

    var darkGradientColors: [Color] {
        switch self {
        case .calories:
            return [
                Color(red: 0.11, green: 0.208, blue: 0.369),
                Color(red: 0.192, green: 0.337, blue: 0.604)
            ]
        case .carbohydrate:
            return [
                Color(red: 0.231, green: 0.208, blue: 0.455),
                Color(red: 0.361, green: 0.31, blue: 0.62)
            ]
        case .protein:
            return [
                Color(red: 0.306, green: 0.216, blue: 0.059),
                Color(red: 0.459, green: 0.325, blue: 0.137)
            ]
        case .fat:
            return [
                Color(red: 0.341, green: 0.204, blue: 0.149),
                Color(red: 0.478, green: 0.306, blue: 0.216)
            ]
        }
    }

    /// Equivalent to the dark widget background with the former 8% white
    /// track composited on top, but expressed as fully opaque colors so the
    /// overlay ring can actually cover the progress layers below it.
    var darkOpaqueTrackGradientColors: [Color] {
        switch self {
        case .calories:
            return [
                Color(red: 0.1812, green: 0.27136, blue: 0.41948),
                Color(red: 0.25664, green: 0.39004, blue: 0.63568)
            ]
        case .carbohydrate:
            return [
                Color(red: 0.29252, green: 0.27136, blue: 0.4986),
                Color(red: 0.41212, green: 0.3652, blue: 0.6504)
            ]
        case .protein:
            return [
                Color(red: 0.36152, green: 0.27872, blue: 0.13428),
                Color(red: 0.50228, green: 0.379, blue: 0.20604)
            ]
        case .fat:
            return [
                Color(red: 0.39372, green: 0.26768, blue: 0.21708),
                Color(red: 0.51976, green: 0.36152, blue: 0.27872)
            ]
        }
    }

    /// Equivalent to the light widget tint with the former 6% black track
    /// composited on top. The lower endpoint is shared because the widget's
    /// gray background gradient is fully opaque at its end.
    var lightOpaqueTrackGradientColors: [Color] {
        let bottomColor = Color(red: 0.89208, green: 0.89208, blue: 0.89208)

        switch self {
        case .calories:
            return [
                Color(red: 0.8272, green: 0.8812, blue: 0.94),
                bottomColor
            ]
        case .carbohydrate:
            return [
                Color(red: 0.89576, green: 0.86303, blue: 0.94),
                bottomColor
            ]
        case .protein:
            return [
                Color(red: 0.94, green: 0.92408, blue: 0.84356),
                bottomColor
            ]
        case .fat:
            return [
                Color(red: 0.94, green: 0.88692, blue: 0.84356),
                bottomColor
            ]
        }
    }

    var darkGradientPoints: (start: UnitPoint, end: UnitPoint) {
        switch self {
        case .calories, .protein:
            return (
                UnitPoint(x: 0.6, y: 0.39),
                UnitPoint(x: 1, y: 1.11)
            )
        case .carbohydrate, .fat:
            return (
                UnitPoint(x: 0.56, y: 0.42),
                UnitPoint(x: 1, y: 1)
            )
        }
    }

    func intake(from dict: NSDictionary) -> Int {
        let key: String
        switch self {
        case .calories:
            key = "calori"
        case .carbohydrate:
            key = "carbohydrates"
        case .protein:
            key = "protein"
        case .fat:
            key = "fats"
        }
        return max(0, Int(dict.doubleValueForKeyWidget(key: key).rounded()))
    }

    func target(from dict: NSDictionary) -> Int {
        switch self {
        case .calories:
            let sportCalories = WidgetUtils().readSportInTargetStatus() == "0"
                ? 0
                : Int(dict.doubleValueForKeyWidget(key: "sportCalories").rounded())
            return max(0, Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) + sportCalories)
        case .carbohydrate:
            return max(0, Int(dict.doubleValueForKeyWidget(key: "carboTar").rounded()))
        case .protein:
            return max(0, Int(dict.doubleValueForKeyWidget(key: "proteinTar").rounded()))
        case .fat:
            return max(0, Int(dict.doubleValueForKeyWidget(key: "fatsTar").rounded()))
        }
    }
}

struct WeekRemainingWidgetBackground: View {
    let metric: WeekRemainingMetric

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if colorScheme == .dark {
            let points = metric.darkGradientPoints
            LinearGradient(
                colors: metric.darkGradientColors,
                startPoint: points.start,
                endPoint: points.end
            )
        } else {
            ZStack {
                Color.white

                metric.lightBackgroundTint

                LinearGradient(
                    colors: [
                        Color(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0).opacity(0),
                        Color(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0)
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            }
        }
    }
}

struct ElaWeekRemainingWidgetEntryView: View {
    let entry: Provider.Entry
    let metric: WeekRemainingMetric

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let dict = entry.isSnap ? WidgetUtils().readNaturalDataDefault() : WidgetUtils().readNaturalData()
        let intake = metric.intake(from: dict)
        let target = metric.target(from: dict)
        let remaining = target - intake
        let progress = target > 0
            ? max(CGFloat(intake) / CGFloat(target), 0)
            : 0

        GeometryReader { geometry in
            let scale = min(geometry.size.width / 153, geometry.size.height / 153)

            ZStack(alignment: .topLeading) {
                WeekRemainingWidgetBackground(metric: metric)

                WeekRemainingProgressRing(
                    progress: progress,
                    metric: metric,
                    scale: scale
                )
                .frame(width: 72 * scale, height: 72 * scale)
                .offset(x: 15 * scale, y: 15 * scale)

                VStack(alignment: .leading, spacing: 7 * scale) {
                    Text(metric.title)
                        .foregroundColor(
                            colorScheme == .dark
                                ? .white
                                : Color(red: 15.0 / 255.0, green: 18.0 / 255.0, blue: 20.0 / 255.0)
                        )
                        .font(Font.custom("PingFangSC-Regular", size: 10 * scale))
                        .lineLimit(1)
                        .frame(height: 10 * scale)

                    HStack(alignment: .lastTextBaseline, spacing: 1 * scale) {
                        Text(verbatim: remaining.formatted(.number.grouping(.automatic)))
                            .foregroundColor(valueColor(for: remaining))
                            .font(Font.custom("D-DIN-PRO-SemiBold", size: 20 * scale))
                            .monospacedDigit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)

                        Text(metric.unit)
                            .foregroundColor(valueColor(for: remaining))
                            .font(Font.custom("PingFangSC-Regular", size: 8 * scale))
                            .lineLimit(1)
                    }
                    .frame(height: 20 * scale)
                }
                .offset(x: 15 * scale, y: 101 * scale)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func valueColor(for remaining: Int) -> Color {
        // 深浅色模式下，超量（剩余值为负）都只将数值和单位标红；负号保留。
        if remaining < 0 {
            return Color(red: 253.0 / 255.0, green: 44.0 / 255.0, blue: 33.0 / 255.0)
        }

        return colorScheme == .dark ? .white : metric.accent
    }
}

private struct WeekRemainingProgressRing: View {
    let progress: CGFloat
    let metric: WeekRemainingMetric
    let scale: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let normalProgress = min(max(progress, 0), 1)
        let overflowProgress = min(max(progress - 1, 0), 1)
        let lineWidth = 16 * scale
        let progressColor = colorScheme == .dark ? Color.white : metric.accent
        let overflowColor = colorScheme == .dark
            ? Color(
                red: 207.0 / 255.0,
                green: 207.6 / 255.0,
                blue: 208.0 / 255.0
            )
            : metric.lightOpaqueOverflowColor
        let trackGradient = opaqueTrackGradient
        let ringFCoverProgress = CGFloat(30.0 / 360.0)

        ZStack {
            Circle()
                .inset(by: lineWidth / 2)
                .stroke(
                    trackGradient,
                    style: StrokeStyle(lineWidth: lineWidth)
                )

            if normalProgress >= 1 {
                Circle()
                    .inset(by: lineWidth / 2)
                    .stroke(
                        progressColor,
                        style: StrokeStyle(lineWidth: lineWidth)
                    )
            } else if normalProgress > 0 {
                Circle()
                    .inset(by: lineWidth / 2)
                    .trim(from: 0, to: normalProgress)
                    .stroke(
                        progressColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                    )
                    .rotationEffect(.degrees(-90))

                WeekRemainingRingEndCap(
                    progress: normalProgress,
                    color: progressColor,
                    lineWidth: lineWidth
                )
            }

            if overflowProgress >= 1 {
                Circle()
                    .inset(by: lineWidth / 2)
                    .stroke(
                        overflowColor,
                        style: StrokeStyle(lineWidth: lineWidth)
                    )
            } else if overflowProgress > 0 {
                Circle()
                    .inset(by: lineWidth / 2)
                    .trim(from: 0, to: overflowProgress)
                    .stroke(
                        overflowColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                    )
                    .rotationEffect(.degrees(-90))

                WeekRemainingRingEndCap(
                    progress: overflowProgress,
                    color: overflowColor,
                    lineWidth: lineWidth
                )
            }

            // Ring F: a topmost, counter-clockwise cover arc that repairs the
            // shared start seam for very small and newly-overflowing progress.
            if progress < 0.3 {
                Circle()
                    .inset(by: lineWidth / 2)
                    .trim(from: 1 - ringFCoverProgress, to: 1)
                    .stroke(
                        trackGradient,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                    )
                    .rotationEffect(.degrees(-90))
            } else if progress > 1, progress < 1.3 {
                Circle()
                    .inset(by: lineWidth / 2)
                    .trim(from: 1 - ringFCoverProgress, to: 1)
                    .stroke(
                        progressColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                    )
                    .rotationEffect(.degrees(-90))
            }
        }
    }

    private var opaqueTrackGradient: LinearGradient {
        if colorScheme == .dark {
            let points = metric.darkGradientPoints
            return LinearGradient(
                colors: metric.darkOpaqueTrackGradientColors,
                startPoint: ringLocalPoint(fromWidgetPoint: points.start),
                endPoint: ringLocalPoint(fromWidgetPoint: points.end)
            )
        }

        return LinearGradient(
            colors: metric.lightOpaqueTrackGradientColors,
            startPoint: ringLocalPoint(fromWidgetPoint: UnitPoint(x: 0.5, y: 0)),
            endPoint: ringLocalPoint(fromWidgetPoint: UnitPoint(x: 0.5, y: 1))
        )
    }

    /// The ring occupies a 72×72 area at (15, 15) in the 153×153 widget
    /// design space. Transform widget gradient points into the ring's local
    /// coordinate space so the opaque track preserves the old appearance.
    private func ringLocalPoint(fromWidgetPoint point: UnitPoint) -> UnitPoint {
        let ringOrigin = 15.0 / 153.0
        let ringSize = 72.0 / 153.0
        return UnitPoint(
            x: (point.x - ringOrigin) / ringSize,
            y: (point.y - ringOrigin) / ringSize
        )
    }
}

private struct WeekRemainingRingEndCap: View {
    let progress: CGFloat
    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let radius = (min(geometry.size.width, geometry.size.height) - lineWidth) / 2
            let angle = (2 * CGFloat.pi * progress) - (CGFloat.pi / 2)

            Circle()
                .fill(color, style: FillStyle(antialiased: true))
                .frame(width: lineWidth, height: lineWidth)
                .position(
                    x: centerX + cos(angle) * radius,
                    y: centerY + sin(angle) * radius
                )
        }
        .allowsHitTesting(false)
    }
}

struct ElaWeekCaloriesWidgetEntryView: View {
    let entry: Provider.Entry

    var body: some View {
        ElaWeekRemainingWidgetEntryView(entry: entry, metric: .calories)
    }
}

struct ElaWeekCaloriesWidget: Widget {
    let kind: String = "ElaWeekCaloriesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ElaWeekCaloriesWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        WeekRemainingWidgetBackground(metric: .calories)
                    }
                    .edgesIgnoringSafeArea(.all)
            } else {
                ElaWeekCaloriesWidgetEntryView(entry: entry)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .configurationDisplayName("卡路里")
        .description("今日剩余")
        .supportedFamilies([.systemSmall])
        .disableContentMarginsIfNeeded()
    }
}
