//
//  ElaNaturalFiveMealsWidget.swift
//  ElaNaturalFiveMealsWidget
//
//  Created by LNS2 on 2024/8/14.
//

import WidgetKit
import SwiftUI

enum FiveMealsWidgetStyle {
    static let designSize = CGSize(width: 326, height: 154)
    static let topAreaRatio: CGFloat = 109.0 / 154.0

    static let themeBlue = Color(red: 0.0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0)
    // Equivalent to rgba(15, 18, 20, 0.5) composited over the #007AFF intake ring.
    static let calorieOverflow = Color(red: 7.5 / 255.0, green: 70.0 / 255.0, blue: 137.5 / 255.0)
    static let overflowRed = Color(red: 253.0 / 255.0, green: 44.0 / 255.0, blue: 33.0 / 255.0)
    static let macroOverflow = Color(red: 15.0 / 255.0, green: 18.0 / 255.0, blue: 20.0 / 255.0).opacity(0.5)

    static let carbohydrate = Color(red: 155.0 / 255.0, green: 81.0 / 255.0, blue: 255.0 / 255.0)
    static let protein = Color(red: 255.0 / 255.0, green: 219.0 / 255.0, blue: 37.0 / 255.0)
    static let fat = Color(red: 255.0 / 255.0, green: 135.0 / 255.0, blue: 37.0 / 255.0)

    static func primaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.white
            : Color(red: 15.0 / 255.0, green: 18.0 / 255.0, blue: 20.0 / 255.0)
    }

    static func secondaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.white.opacity(0.5)
            : Color(red: 15.0 / 255.0, green: 18.0 / 255.0, blue: 20.0 / 255.0).opacity(0.5)
    }

    static func track(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.white.opacity(0.06)
            : Color(red: 15.0 / 255.0, green: 18.0 / 255.0, blue: 20.0 / 255.0).opacity(0.06)
    }

    static func ringTrack(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.white.opacity(0.06)
            : Color(red: 15.0 / 255.0, green: 18.0 / 255.0, blue: 20.0 / 255.0).opacity(0.06)
    }

    static func divider(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white.opacity(0.14) : .black.opacity(0.10)
    }

    static func addIcon(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 88.0 / 255.0, green: 121.0 / 255.0, blue: 171.0 / 255.0)
            : Color(red: 197.0 / 255.0, green: 197.0 / 255.0, blue: 197.0 / 255.0)
    }
}

struct FiveMealsWidgetBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if colorScheme == .dark {
            LinearGradient(
                colors: [
                    Color(red: 0.027, green: 0.11, blue: 0.231),
                    Color(red: 0.09, green: 0.31, blue: 0.675)
                ],
                startPoint: UnitPoint(x: 0.62, y: 0.5),
                endPoint: UnitPoint(x: 1.03, y: 1.24)
            )
        } else {
            Color.white
        }
    }
}

private struct LegacyElaNaturalFiveMealsWidgetEntryView: View {
    var entry: Provider.Entry
    var isRefresh = true
    var body: some View {
        
        let dict = entry.isSnap ? WidgetUtils().readNaturalDataDefault() : WidgetUtils().readNaturalData()
        
        let mealsArray = entry.isSnap ? WidgetUtils().readCurrentDayMealsMsgDefault() : WidgetUtils().readCurrentDayMealsMsg()
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width - 30
            let geoHeight = geometry.size.height - 20
            
            let topFrameHeight = geoHeight * 0.6
            
            ZStack{
                VStack{
                    HStack(alignment: .center, content: {
                        Spacer()
                            .frame(width: 10,height: 20)
                        //上方摄入圆形进度条
                        let caloriesCircleWidth = topFrameHeight
                        VStack(alignment: .center, content: {
                            ZStack{
                                let sportCalories = WidgetUtils().readSportInTargetStatus() == "0" ? 0 : dict.doubleValueForKeyWidget(key: "sportCalories").rounded()
//                                CircleView(caloriesTarget: Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()),
//                                           calories: Int(dict.doubleValueForKeyWidget(key: "calori").rounded()))
                                CircleView(caloriesTarget: Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) + Int(sportCalories),
                                           calories: Int(dict.doubleValueForKeyWidget(key: "calori").rounded()),
                                           sportCalories: Int(sportCalories))
                                    .frame(width: caloriesCircleWidth,height: caloriesCircleWidth)
                            }
                        })
                        .frame(width: caloriesCircleWidth,height: caloriesCircleWidth)
    //                    .background(Color.purple)
//                        .onAppear{
//                            NSLog("WidgetUtils().readNaturalData()(ElaNaturalFiveMealsWidgetEntryView):%@", dict)
//                            WidgetUtils().sendNaturalDataRequest(meals: 5)
//                        }
                        
                        Spacer()
                        GeometryReader { progressSize in
                            HStack{
                                Spacer()
                                VStack(alignment: .trailing, content: {
                                        let progressWidth = progressSize.size.width*0.9
                                        ProgressView(naturalType: "碳水",
                                                     numberTarget: dict.doubleValueForKeyWidget(key: "carboTar").rounded(),
                                                     number: dict.doubleValueForKeyWidget(key: "carbohydrates").rounded(),
                                                     progressColor: Color(red: 113.0/255.0, green: 55.0/255.0, blue: 191.0/255.0),
                                                     fillColor: Color(red: 85.0/255.0, green: 41.0/255.0, blue: 143.0/255.0))
                                        .frame(width: progressWidth,height: progressSize.size.height*0.3)
                                        ProgressView(naturalType: "蛋白质",
                                                     numberTarget: dict.doubleValueForKeyWidget(key: "proteinTar").rounded(),
                                                     number: dict.doubleValueForKeyWidget(key: "protein").rounded(),
                                                     progressColor: Color(red: 245.0/255.0, green: 186.0/255.0, blue: 24.0/255.0),
                                                     fillColor: Color(red: 135.0/255.0, green: 102.0/255.0, blue: 13.0/255.0))
                                            .frame(width: progressWidth,height: progressSize.size.height*0.3)
    //                                        .background(Color.green)
                                        ProgressView(naturalType: "脂肪",
                                                     numberTarget: dict.doubleValueForKeyWidget(key: "fatsTar").rounded(),
                                                     number: dict.doubleValueForKeyWidget(key: "fats").rounded(),
                                                     progressColor: Color(red: 226.0/255.0, green: 115.0/255.0, blue: 24.0/255.0),
                                                     fillColor: Color(red: 85.0/255.0, green: 41.0/255.0, blue: 143.0/255.0))
                                        .frame(width: progressWidth,height: progressSize.size.height*0.3)
                                })
    //                            .background(Color.red)
                            }
                            .frame(width: progressSize.size.width,height: topFrameHeight)
                        }
                    })
    //                .background(Color.blue)
                    .frame(width: geoWidth,height: topFrameHeight)
                
                    /**
                     *   第 几 餐  按钮
                     **/
                    HStack(alignment: .bottom, content: {
                        let mealsWidth = min((geoWidth - 20) * 0.19, geoHeight)
                        let mealsHeight = (geoHeight-topFrameHeight)*0.85
                        
                        Link(destination: URL(string: "elavatinelns://mealsIndex_1")!, label: {
                            MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                      calories:0,
                                      mealsIndex: 1,
                                      mealsImgName: "meals_eat_add_icon",
                                      mealsMsgDict: mealsArray[0] as? NSDictionary ?? [:])
                                .frame(width: mealsWidth,height: mealsHeight)
//                                .background(Color.red)
//                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        })
    //                    Spacer()
                        Link(destination: URL(string: "elavatinelns://mealsIndex_2")!, label: {
                            MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                      calories:0,
                                      mealsIndex: 2,
                                      mealsImgName: "meals_eat_add_icon",
                                      mealsMsgDict: mealsArray[1] as? NSDictionary ?? [:])
                                .frame(width: mealsWidth,height: mealsHeight)
//                                .background(Color.blue)
                        })
    //                    Spacer()
                        Link(destination: URL(string: "elavatinelns://mealsIndex_3")!, label: {
                            MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                      calories:3,
                                      mealsIndex: 3,
                                      mealsImgName: "meals_eat_right_icon",
                                      mealsMsgDict: mealsArray[2] as? NSDictionary ?? [:])
                                .frame(width: mealsWidth,height: mealsHeight)
//                                .background(Color.green)
//                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        })
    //                    Spacer()
                        Link(destination: URL(string: "elavatinelns://mealsIndex_4")!, label: {
                            MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                      calories:0,
                                      mealsIndex: 4,
                                      mealsImgName: "meals_eat_right_icon",
                                      mealsMsgDict: mealsArray[3] as? NSDictionary ?? [:])
                                .frame(width: mealsWidth,height: mealsHeight)
//                                .background(Color.yellow)
                        })
    //                    Spacer()
                        Link(destination: URL(string: "elavatinelns://mealsIndex_5")!, label: {
                            MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                      calories:1,
                                      mealsIndex: 5,
                                      mealsImgName: "meals_eat_icon",
                                      mealsMsgDict: mealsArray[4] as? NSDictionary ?? [:])
                                .frame(width: mealsWidth,height: mealsHeight)
//                                .background(Color.purple)
                        })
                    })
                    .frame(width: geoWidth,height: geoHeight-topFrameHeight)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                    .background(Color.gray)
                }
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 5, trailing: 15))
            }
            .frame(width: geometry.size.width,height: geometry.size.height)
//            .background(Color.blue.opacity(0.15))
//            .background(Color(red: 248.0/255.0, green: 248.0/255.0, blue: 1.0,opacity: 0.25))
//            .background(Color(red: 250.0/255.0, green: 250.0/255.0, blue: 248.0/255.0,opacity: 0.1))
//            .background(Color(red: 245.0/255.0, green: 240.0/255.0, blue: 240.0/255.0))
         }
    }

}

struct ElaNaturalMealsWidgetEntryView: View {
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
                geometry.size.width / FiveMealsWidgetStyle.designSize.width,
                geometry.size.height / FiveMealsWidgetStyle.designSize.height
            )
            let topAreaHeight = geometry.size.height * FiveMealsWidgetStyle.topAreaRatio
            let dividerWidth = max(0.5, 0.5 * scale)

            ZStack {
                FiveMealsWidgetBackground()

                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 17 * scale) {
                        FiveMealsCaloriesRing(
                            caloriesTarget: caloriesTarget,
                            calories: calories,
                            scale: scale
                        )
                        .frame(width: 69 * scale, height: 69 * scale)

                        VStack(spacing: 8 * scale) {
                            FiveMealsMacroProgressRow(
                                title: "碳水",
                                target: dict.doubleValueForKeyWidget(key: "carboTar").rounded(),
                                value: dict.doubleValueForKeyWidget(key: "carbohydrates").rounded(),
                                progressColor: FiveMealsWidgetStyle.carbohydrate,
                                overflowColor: FiveMealsWidgetStyle.macroOverflow,
                                scale: scale
                            )

                            FiveMealsMacroProgressRow(
                                title: "蛋白质",
                                target: dict.doubleValueForKeyWidget(key: "proteinTar").rounded(),
                                value: dict.doubleValueForKeyWidget(key: "protein").rounded(),
                                progressColor: FiveMealsWidgetStyle.protein,
                                overflowColor: FiveMealsWidgetStyle.macroOverflow,
                                scale: scale
                            )

                            FiveMealsMacroProgressRow(
                                title: "脂肪",
                                target: dict.doubleValueForKeyWidget(key: "fatsTar").rounded(),
                                value: dict.doubleValueForKeyWidget(key: "fats").rounded(),
                                progressColor: FiveMealsWidgetStyle.fat,
                                overflowColor: FiveMealsWidgetStyle.macroOverflow,
                                scale: scale
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 15 * scale)
                    .padding(.top, 16 * scale)
                    .frame(width: geometry.size.width, height: topAreaHeight, alignment: .top)

                    Rectangle()
                        .fill(FiveMealsWidgetStyle.divider(for: colorScheme))
                        .frame(height: dividerWidth)

                    GeometryReader { mealsGeometry in
                        HStack(spacing: 0) {
                            ForEach(0..<mealCount, id: \.self) { index in
                                let actionState: FiveMealsActionState = completionStates[index]
                                    ? .recorded
                                    : (nextMealIndex == index ? .next : .inactive)

                                Link(destination: URL(string: "elavatinelns://mealsIndex_\(index + 1)")!) {
                                    FiveMealsActionCell(
                                        state: actionState,
                                        scale: scale
                                    )
                                }
                                .frame(
                                    width: mealsGeometry.size.width / CGFloat(mealCount),
                                    height: mealsGeometry.size.height
                                )
                                .overlay(alignment: .trailing) {
                                    if index < mealCount - 1 {
                                        Rectangle()
                                            .fill(FiveMealsWidgetStyle.divider(for: colorScheme))
                                            .frame(width: dividerWidth)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

enum FiveMealsMealStateResolver {
    static func isRecorded(_ meal: Any) -> Bool {
        guard let meal = meal as? NSDictionary else { return false }

        if let isEat = meal["isEat"] as? String {
            return isEat == "1" || isEat.lowercased() == "true"
        }

        if let isEat = meal["isEat"] as? NSNumber {
            return isEat.boolValue
        }

        return meal.doubleValueForKeyWidget(key: "calories") > 0
            || meal.doubleValueForKeyWidget(key: "carbohydrate") > 0
            || meal.doubleValueForKeyWidget(key: "protein") > 0
            || meal.doubleValueForKeyWidget(key: "fat") > 0
    }
}

struct ElaNaturalFiveMealsWidgetEntryView: View {
    let entry: Provider.Entry

    var body: some View {
        ElaNaturalMealsWidgetEntryView(entry: entry, mealCount: 5)
    }
}

private struct FiveMealsCaloriesRing: View {
    let caloriesTarget: Int
    let calories: Int
    let scale: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    private var progress: CGFloat {
        guard caloriesTarget > 0 else { return 0 }
        return max(0, CGFloat(calories) / CGFloat(caloriesTarget))
    }

    var body: some View {
        let lineWidth = 5 * scale
        let normalProgress = min(progress, 1)
        let overflowProgress = min(max(progress - 1, 0), 1)
        let normalEndAngle = (2 * CGFloat.pi * normalProgress) - (CGFloat.pi / 2)
        let overflowEndAngle = (2 * CGFloat.pi * overflowProgress) - (CGFloat.pi / 2)

        ZStack {
            Circle()
                .inset(by: lineWidth / 2)
                .stroke(FiveMealsWidgetStyle.ringTrack(for: colorScheme), lineWidth: lineWidth)

            Circle()
                .inset(by: lineWidth / 2)
                .trim(from: 0, to: normalProgress)
                .stroke(
                    FiveMealsWidgetStyle.themeBlue,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                )
                .rotationEffect(.degrees(-90))

            if normalProgress > 0 {
                FiveMealsRingCap(
                    color: FiveMealsWidgetStyle.themeBlue,
                    angle: normalEndAngle,
                    lineWidth: lineWidth
                )
            }

            if overflowProgress > 0 {
                Circle()
                    .inset(by: lineWidth / 2)
                    .trim(from: 0, to: overflowProgress)
                    .stroke(
                        FiveMealsWidgetStyle.calorieOverflow,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                    )
                    .rotationEffect(.degrees(-90))

                if overflowProgress < 1 {
                    FiveMealsRingCap(
                        color: FiveMealsWidgetStyle.calorieOverflow,
                        angle: overflowEndAngle,
                        lineWidth: lineWidth
                    )
                }
            }

            VStack(spacing: 2 * scale) {
                Text(verbatim: String(calories))
                    .foregroundColor(
                        calories > caloriesTarget
                            ? FiveMealsWidgetStyle.overflowRed
                            : FiveMealsWidgetStyle.primaryText(for: colorScheme)
                    )
                    .font(Font.custom("D-DIN-PRO-SemiBold", size: 18 * scale))
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text(verbatim: "/\(caloriesTarget)")
                    .foregroundColor(FiveMealsWidgetStyle.secondaryText(for: colorScheme))
                    .font(Font.custom("D-DIN-PRO-Regular", size: 12 * scale))
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8 * scale)
        }
        .padding(lineWidth / 2)
    }
}

private struct FiveMealsRingCap: View {
    let color: Color
    let angle: CGFloat
    let lineWidth: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let radius = (min(geometry.size.width, geometry.size.height) - lineWidth) / 2

            Circle()
                .fill(color)
                .frame(width: lineWidth, height: lineWidth)
                .position(
                    x: centerX + cos(angle) * radius,
                    y: centerY + sin(angle) * radius
                )
        }
        .allowsHitTesting(false)
    }
}

private struct FiveMealsMacroProgressRow: View {
    let title: String
    let target: Double
    let value: Double
    let progressColor: Color
    let overflowColor: Color
    let scale: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    private var progress: CGFloat {
        guard target > 0 else { return 0 }
        return max(0, CGFloat(value / target))
    }

    var body: some View {
            VStack(spacing: 5 * scale) {
            HStack(alignment: .top, spacing: 0) {
                    Text(title)
                        .foregroundColor(FiveMealsWidgetStyle.primaryText(for: colorScheme))
                    .font(Font.custom("PingFangSC-Regular", size: 8 * scale))
                    .lineLimit(1)

                Spacer(minLength: 4 * scale)

                Text(verbatim: String(Int(value.rounded())))
                    .foregroundColor(
                        value > target
                            ? FiveMealsWidgetStyle.overflowRed
                            : FiveMealsWidgetStyle.primaryText(for: colorScheme)
                    )
                    .font(Font.custom("PingFangSC-Medium", size: 12 * scale))
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Text(verbatim: "/\(Int(target.rounded()))g")
                    .foregroundColor(FiveMealsWidgetStyle.secondaryText(for: colorScheme))
                    .font(Font.custom("PingFangSC-Regular", size: 12 * scale))
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }

            GeometryReader { geometry in
                let normalProgress = min(progress, 1)
                let overflowProgress = min(max(progress - 1, 0), 1)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(FiveMealsWidgetStyle.track(for: colorScheme))

                    Capsule()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * normalProgress)

                    if overflowProgress > 0 {
                        Capsule()
                            .fill(overflowColor)
                            .frame(width: geometry.size.width * overflowProgress)
                    }
                }
            }
            .frame(height: 4 * scale)
        }
        .frame(height: 21 * scale, alignment: .top)
    }
}

enum FiveMealsActionState {
    case recorded
    case next
    case inactive

    var iconName: String {
        switch self {
        case .recorded:
            return "meals_record_icon"
        case .next:
            return "meals_next_icon"
        case .inactive:
            return "meals_inactive_icon"
        }
    }
}

struct FiveMealsActionCell: View {
    let state: FiveMealsActionState
    let scale: CGFloat

    var body: some View {
        Image(ImageResource(name: state.iconName, bundle: .main))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25 * scale, height: 25 * scale)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
    }
}

struct ElaNaturalFiveMealsWidget: Widget {
    let kind: String = "ElaNaturalFiveMealsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ElaNaturalFiveMealsWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        FiveMealsWidgetBackground()
                    }
                    .edgesIgnoringSafeArea(.all)
            } else {
                ElaNaturalFiveMealsWidgetEntryView(entry: entry)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .configurationDisplayName("饮食记录")
        .description("今日营养目标 & 快速记录饮食")
        .supportedFamilies([.systemMedium])
        .disableContentMarginsIfNeeded()
    }
}
