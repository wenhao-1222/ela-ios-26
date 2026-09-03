//
//  ElaNaturalThreeMealsWidget.swift
//  ElaNaturalThreeMealsWidget
//
//  Created by LNS2 on 2024/8/22.

import WidgetKit
import SwiftUI

private struct LegacyElaNaturalThreeMealsWidgetEntryView: View {
    var entry: Provider.Entry
    var isRefresh = true
    
    var body: some View {
        
        let dict = entry.isSnap ? WidgetUtils().readNaturalDataDefault() : WidgetUtils().readNaturalData()
        
        let mealsArray = entry.isSnap ? WidgetUtils().readCurrentDayMealsMsgDefault() : WidgetUtils().readCurrentDayMealsMsg()
        
        GeometryReader { geometry in
            let geoWidth = geometry.size.width - 30
            let geoHeight = geometry.size.height - 20
            HStack(content: {
                GeometryReader { progressSize in
                    VStack( content: {
                            let progressWidth = progressSize.size.width
                        let sportCalories = WidgetUtils().readSportInTargetStatus() == "0" ? 0 : dict.doubleValueForKeyWidget(key: "sportCalories").rounded()
                        ProgressKcalView(naturalType: "卡路里",
                                         numberTarget: dict.doubleValueForKeyWidget(key: "caloriTar").rounded()+sportCalories,
                                         number: dict.doubleValueForKeyWidget(key: "calori").rounded(),
                                         sportCalories: sportCalories,
                                         progressColor: Color("color_natural_calories", bundle: .main),
                                         fillColor: Color(red: 85.0/255.0, green: 41.0/255.0, blue: 143.0/255.0))
                            .frame(width: progressWidth,height: geoHeight*0.23)
                        
                        Spacer()
                            .frame(width: progressWidth,height: 25)
                            ProgressView(naturalType: "碳水",
                                         numberTarget: dict.doubleValueForKeyWidget(key: "carboTar").rounded(),
                                         number: dict.doubleValueForKeyWidget(key: "carbohydrates").rounded(),
                                         progressColor: Color("color_natural_carbo", bundle: .main),
                                         fillColor: Color(red: 85.0/255.0, green: 41.0/255.0, blue: 143.0/255.0))
                            .frame(width: progressWidth,height: geoHeight*0.2)
                            .padding(EdgeInsets(top: -4, leading: 0, bottom: 0, trailing: 0))

                            ProgressView(naturalType: "蛋白质",
                                         numberTarget: dict.doubleValueForKeyWidget(key: "proteinTar").rounded(),
                                         number: dict.doubleValueForKeyWidget(key: "protein").rounded(),
                                         progressColor: Color("color_natural_protein", bundle: .main),
                                         fillColor: Color(red: 135.0/255.0, green: 102.0/255.0, blue: 13.0/255.0))
                                .frame(width: progressWidth,height: geoHeight*0.2)
                                .padding(EdgeInsets(top: -4, leading: 0, bottom: 0, trailing: 0))
        //                                        .background(Color.green)
                        
                            ProgressView(naturalType: "脂肪",
                                         numberTarget: dict.doubleValueForKeyWidget(key: "fatsTar").rounded(),
                                         number: dict.doubleValueForKeyWidget(key: "fats").rounded(),
                                         progressColor: Color("color_natural_fat", bundle: .main),
                                         fillColor: Color(red: 85.0/255.0, green: 41.0/255.0, blue: 143.0/255.0))
                            .frame(width: progressWidth,height: geoHeight*0.2)
                            .padding(EdgeInsets(top: -4, leading: 0, bottom: 0, trailing: 0))
                    })
                    .frame(width: progressSize.size.width,height: progressSize.size.height)
//                    .onAppear{
//                        NSLog("WidgetUtils().readNaturalData()(ElaNaturalThreeMealsWidget):%@", dict)
//                        WidgetUtils().sendNaturalDataRequest(meals: 3)
//                    }
                }
                .frame(width: geoWidth*0.6,height: geoHeight)
//                .background(Color.orange)
                
                GeometryReader(content: { mealsFrame in
                    /**
                     *   第 几 餐  按钮
                     **/
                    VStack(alignment: .trailing, content: {
                        let mealsWidth = min(mealsFrame.size.height*0.3, mealsFrame.size.width)
//                        let mealsHeight = mealsFrame*0.3
                        
                        Link(destination: URL(string: "elavatinelns://mealsIndex_1")!, label: {
                            MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                      calories:0,
                                      mealsIndex: 1,
                                      mealsImgName: "meals_eat_add_icon",
                                      mealsMsgDict: mealsArray[0] as? NSDictionary ?? [:])
                                .frame(width: mealsWidth,height: mealsWidth)
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
                                .frame(width: mealsWidth,height: mealsWidth)
//                                .background(Color.blue)
                        })
    //                    Spacer()
                        Link(destination: URL(string: "elavatinelns://mealsIndex_3")!, label: {
                            MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                      calories:3,
                                      mealsIndex: 3,
                                      mealsImgName: "meals_eat_right_icon",
                                      mealsMsgDict: mealsArray[2] as? NSDictionary ?? [:])
                                .frame(width: mealsWidth,height: mealsWidth)
//                                .background(Color.green)
//                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        })
                    })
                    .frame(width: geoWidth*0.4,height: geoHeight)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                    .background(Color.green)
                })
                .frame(width: geoWidth*0.4,height: geoHeight)
//                .background(Color.yellow)
            })
            .frame(width: geoWidth,height: geoHeight)
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 10))
//            .background(Color(red: 250.0/255.0, green: 250.0/255.0, blue: 248.0/255.0,opacity: 0.1))
         }
    }
}

private enum ThreeMealsWidgetStyle {
    static let designSize = CGSize(width: 153, height: 153)
    static let contentSize = CGSize(width: 75, height: 123.5)
    static let actionAreaWidth: CGFloat = 39

    static func divider(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
    }
}

private struct ThreeMealsWidgetBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if colorScheme == .dark {
            LinearGradient(
                colors: [
                    Color(red: 7.0 / 255.0, green: 28.0 / 255.0, blue: 59.0 / 255.0),
                    Color(red: 23.0 / 255.0, green: 79.0 / 255.0, blue: 172.0 / 255.0)
                ],
                startPoint: UnitPoint(x: 0.17, y: -0.09),
                endPoint: UnitPoint(x: 0.83, y: 1.09)
            )
        } else {
            Color.white
        }
    }
}

struct ElaNaturalThreeMealsWidgetEntryView: View {
    let entry: Provider.Entry

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let dict = entry.isSnap ? WidgetUtils().readNaturalDataDefault() : WidgetUtils().readNaturalData()
        let mealsArray = entry.isSnap ? WidgetUtils().readCurrentDayMealsMsgDefault() : WidgetUtils().readCurrentDayMealsMsg()
        let sportCalories = WidgetUtils().readSportInTargetStatus() == "0"
            ? 0
            : Int(dict.doubleValueForKeyWidget(key: "sportCalories").rounded())
        let caloriesTarget = Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) + sportCalories
        let calories = Int(dict.doubleValueForKeyWidget(key: "calori").rounded())
        let completionStates = (0..<3).map { index in
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
                geometry.size.width / ThreeMealsWidgetStyle.designSize.width,
                geometry.size.height / ThreeMealsWidgetStyle.designSize.height
            )
            let dividerWidth = max(0.5, scale)
            let actionAreaWidth = ThreeMealsWidgetStyle.actionAreaWidth * scale

            ZStack(alignment: .topLeading) {
                ThreeMealsWidgetBackground()

                VStack(alignment: .leading, spacing: 11.5 * scale) {
                    ThreeMealsCaloriesProgress(
                        calories: calories,
                        target: caloriesTarget,
                        scale: scale
                    )

                    VStack(spacing: 11 * scale) {
                        ThreeMealsMacroProgressRow(
                            title: "碳水",
                            value: dict.doubleValueForKeyWidget(key: "carbohydrates").rounded(),
                            target: dict.doubleValueForKeyWidget(key: "carboTar").rounded(),
                            progressColor: FiveMealsWidgetStyle.carbohydrate,
                            scale: scale
                        )

                        ThreeMealsMacroProgressRow(
                            title: "蛋白质",
                            value: dict.doubleValueForKeyWidget(key: "protein").rounded(),
                            target: dict.doubleValueForKeyWidget(key: "proteinTar").rounded(),
                            progressColor: FiveMealsWidgetStyle.protein,
                            scale: scale
                        )

                        ThreeMealsMacroProgressRow(
                            title: "脂肪",
                            value: dict.doubleValueForKeyWidget(key: "fats").rounded(),
                            target: dict.doubleValueForKeyWidget(key: "fatsTar").rounded(),
                            progressColor: FiveMealsWidgetStyle.fat,
                            scale: scale
                        )
                    }
                }
                .frame(
                    width: ThreeMealsWidgetStyle.contentSize.width * scale,
                    height: ThreeMealsWidgetStyle.contentSize.height * scale,
                    alignment: .topLeading
                )
                .offset(x: 15 * scale, y: 15 * scale)

                Rectangle()
                    .fill(ThreeMealsWidgetStyle.divider(for: colorScheme))
                    .frame(width: dividerWidth, height: geometry.size.height)
                    .offset(x: geometry.size.width - actionAreaWidth)

                VStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { index in
                        let actionState: FiveMealsActionState = completionStates[index]
                            ? .recorded
                            : (nextMealIndex == index ? .next : .inactive)

                        Link(destination: URL(string: "elavatinelns://mealsIndex_\(index + 1)")!) {
                            FiveMealsActionCell(state: actionState, scale: scale)
                        }
                        .frame(width: actionAreaWidth, height: geometry.size.height / 3)
                        .overlay(alignment: .bottom) {
                            if index < 2 {
                                Rectangle()
                                    .fill(ThreeMealsWidgetStyle.divider(for: colorScheme))
                                    .frame(height: dividerWidth)
                            }
                        }
                    }
                }
                .frame(width: actionAreaWidth, height: geometry.size.height)
                .offset(x: geometry.size.width - actionAreaWidth)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

private struct ThreeMealsCaloriesProgress: View {
    let calories: Int
    let target: Int
    let scale: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    private var progress: CGFloat {
        guard target > 0 else { return 0 }
        return max(0, CGFloat(calories) / CGFloat(target))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 3 * scale) {
                Image(ImageResource(name: "calories_widget_icon", bundle: .main))
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(FiveMealsWidgetStyle.themeBlue)
                    .frame(width: 12 * scale, height: 12 * scale)

                Text("卡路里")
                    .foregroundColor(FiveMealsWidgetStyle.primaryText(for: colorScheme))
                    .font(Font.custom("PingFangSC-Regular", size: 12 * scale))
                    .lineLimit(1)
            }
            .frame(height: 12 * scale)

            Spacer().frame(height: 7 * scale)

            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(verbatim: String(calories))
                    .foregroundColor(
                        calories > target
                            ? FiveMealsWidgetStyle.overflowRed
                            : FiveMealsWidgetStyle.primaryText(for: colorScheme)
                    )
                    .font(Font.custom("D-DIN-PRO-Bold", size: 12 * scale))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(verbatim: "/\(target)")
                    .foregroundColor(FiveMealsWidgetStyle.secondaryText(for: colorScheme))
                    .font(Font.custom("D-DIN-PRO-Regular", size: 8 * scale))
                    .minimumScaleFactor(0.5)
                    .allowsTightening(true)
                    .layoutPriority(1)
                    .lineLimit(1)
            }
            .frame(height: 12 * scale)

            Spacer().frame(height: 3 * scale)

            ThreeMealsProgressBar(
                progress: progress,
                progressColor: FiveMealsWidgetStyle.themeBlue,
                scale: scale
            )
        }
        .frame(height: 39 * scale, alignment: .top)
    }
}

private struct ThreeMealsMacroProgressRow: View {
    let title: String
    let value: Double
    let target: Double
    let progressColor: Color
    let scale: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    private var progress: CGFloat {
        guard target > 0 else { return 0 }
        return max(0, CGFloat(value / target))
    }

    var body: some View {
        VStack(spacing: 5 * scale) {
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(title)
                    .foregroundColor(FiveMealsWidgetStyle.primaryText(for: colorScheme))
                    .font(Font.custom("PingFangSC-Regular", size: 8 * scale))
                    .lineLimit(1)

                Spacer(minLength: 2 * scale)

                Text(verbatim: String("\(Int(value.rounded()))"))
                    .foregroundColor(
                        value > target
                            ? FiveMealsWidgetStyle.overflowRed
                            : FiveMealsWidgetStyle.primaryText(for: colorScheme)
                    )
                    .font(Font.custom("D-DIN-PRO-Medium", size: 8 * scale))
                    .lineLimit(1)

                Text(verbatim: "/\(Int(target.rounded()))g")
                    .foregroundColor(FiveMealsWidgetStyle.secondaryText(for: colorScheme))
                    .font(Font.custom("D-DIN-PRO-Regular", size: 8 * scale))
                    .lineLimit(1)
            }
            .frame(height: 8 * scale)

            ThreeMealsProgressBar(
                progress: progress,
                progressColor: progressColor,
                scale: scale
            )
        }
        .frame(height: 17 * scale, alignment: .top)
    }
}

private struct ThreeMealsProgressBar: View {
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
        .frame(height: 4 * scale)
    }
}

struct ElaNaturalThreeMealsWidget: Widget {
    let kind: String = "ElaNaturalThreeMealsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ElaNaturalThreeMealsWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        ThreeMealsWidgetBackground()
                    }
                    .edgesIgnoringSafeArea(.all)
//                    .background(Color(WHColor_16(colorStr: "EFEFEF")))
//                    .background(UIColor.isDarkModeEnabled ? Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.85) : Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.2))
            } else {
                ElaNaturalThreeMealsWidgetEntryView(entry: entry)
                    .edgesIgnoringSafeArea(.all)
//                    .background(Color(WHColor_16(colorStr: "EFEFEF")))
//                    .background(UIColor.isDarkModeEnabled ? Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.85) : Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.2))
            }
        }
        .configurationDisplayName("饮食记录")
        .description("今日营养目标 & 快速记录饮食")
        .supportedFamilies([.systemSmall])
        .disableContentMarginsIfNeeded()
        
    }
}
