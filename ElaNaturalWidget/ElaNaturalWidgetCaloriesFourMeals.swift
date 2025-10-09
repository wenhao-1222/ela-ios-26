//
//  ElaNaturalWidgetCaloriesFourMeals.swift
//  ElaNaturalWidgetCaloriesFourMeals
//
//  Created by LNS2 on 2024/8/27.
//

import WidgetKit
import SwiftUI

struct ElaNaturalWidgetCaloriesFourMealsEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        let dict = entry.isSnap ? WidgetUtils().readNaturalDataDefault() : WidgetUtils().readNaturalData()
        
        let mealsArray = entry.isSnap ? WidgetUtils().readCurrentDayMealsMsgDefault() : WidgetUtils().readCurrentDayMealsMsg()
        
        GeometryReader(content: { geometry in
            let geoWidth = geometry.size.width - 30
            let geoHeight = geometry.size.height - 20
            HStack{
//
                let progressViewWidth = geoWidth*0.6
                VStack{
                    let caloriesCircleWidth = progressViewWidth*0.25
                    let sportCalories = WidgetUtils().readSportInTargetStatus() == "0" ? 0 : dict.doubleValueForKeyWidget(key: "sportCalories").rounded()
                    ElaNaturalWidgetCaloriesProgressView(numberTarget: dict.doubleValueForKeyWidget(key: "caloriTar").rounded() + sportCalories,
                                                         number: dict.doubleValueForKeyWidget(key: "calori").rounded(),
                                                         sportCalories: sportCalories)
                    .frame(width: progressViewWidth,height: geoHeight*0.4)
                    HStack(alignment: .center, content: {
                        VStack(alignment: .center, content: {
                            ElaNaturalWidgetCaloriesCircleView(caloriesTarget: Int(dict.doubleValueForKeyWidget(key: "carboTar").rounded()),
                                       calories: Int(dict.doubleValueForKeyWidget(key: "carbohydrates").rounded()),
                                       themeColor: Color(UIColor.COLOR_CARBOHYDRATE),
                                       fillColor: Color(UIColor.COLOR_CARBOHYDRATE_FILL))
                                .frame(width: caloriesCircleWidth,height: caloriesCircleWidth)
//                                .background(Color(WHColor_ARC()))
                            Text("碳水")
//                                .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                                .foregroundColor(Color(UIColor(named: "text_color_85") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                                .frame(width: caloriesCircleWidth)
                                .font(.system(size: 12,weight: .medium))
                        })
//                        .background(Color(WHColor_ARC()))
                        Spacer()
                            .frame(width: progressViewWidth*0.125,height: 80)
                        VStack(alignment: .center, content: {
                            ElaNaturalWidgetCaloriesCircleView(caloriesTarget: Int(dict.doubleValueForKeyWidget(key: "proteinTar").rounded()),
                                       calories: Int(dict.doubleValueForKeyWidget(key: "protein").rounded()),
                                       themeColor: Color(UIColor.COLOR_PROTEIN),
                                       fillColor: Color(UIColor.COLOR_PROTEIN_FILL))
                                .frame(width: caloriesCircleWidth,height: caloriesCircleWidth)
//                                .background(Color(WHColor_ARC()))
                            Text("蛋白质")
//                                .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                                .foregroundColor(Color(UIColor(named: "text_color_85") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                                .frame(width: caloriesCircleWidth)
                                .font(.system(size: 12,weight: .medium))
                        })
//                        .background(Color(WHColor_ARC()))
                        Spacer()
                            .frame(width: progressViewWidth*0.125,height: 80)
                        VStack(alignment: .center, content: {
                            ElaNaturalWidgetCaloriesCircleView(caloriesTarget: Int(dict.doubleValueForKeyWidget(key: "fatsTar").rounded()),
                                       calories: Int(dict.doubleValueForKeyWidget(key: "fats").rounded()),
                                       themeColor: Color(UIColor.COLOR_FAT),
                                       fillColor: Color(UIColor.COLOR_FAT_FILL))
                                .frame(width: caloriesCircleWidth,height: caloriesCircleWidth)
//                                .background(Color(WHColor_ARC()))
                            Text("脂肪")
//                                .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                                .foregroundColor(Color(UIColor(named: "text_color_85") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                            
                                .frame(width: caloriesCircleWidth)
                                .font(.system(size: 12,weight: .medium))
                        })
//                        .background(Color(WHColor_ARC()))
                    })
                    .frame(width: progressViewWidth*0.8,height: geoHeight*0.6)
                    .padding(EdgeInsets(top: -10, leading: 0, bottom: 0, trailing: 0))
//                    .background(Color(WHColor_ARC()))
                    
                    Spacer()
                }
                .frame(width: progressViewWidth,height: geoHeight)
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
//                .background(Color(WHColor_ARC()))
                
                let mealsWidth = min(geoWidth*0.2, geoHeight*0.45)
                VStack(alignment: .trailing, content: {
                    Spacer()
                    Link(destination: URL(string: "elavatinelns://mealsIndex_1")!, label: {
                        MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                  calories:0,
                                  mealsIndex: 1,
                                  mealsImgName: "meals_eat_add_icon",
                                  mealsMsgDict: mealsArray[0] as? NSDictionary ?? [:],
                                  imgScale: 1.4)
                            .frame(width: mealsWidth,height: mealsWidth)
//                                .background(Color.red)
                    })
                    Spacer()
                    Link(destination: URL(string: "elavatinelns://mealsIndex_3")!, label: {
                        MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                  calories:0,
                                  mealsIndex: 3,
                                  mealsImgName: "meals_eat_add_icon",
                                  mealsMsgDict: mealsArray[2] as? NSDictionary ?? [:],
                                  imgScale: 1.4)
                            .frame(width: mealsWidth,height: mealsWidth)
//                                .background(Color.red)
                    })
                    Spacer()
                })
                .frame(width: mealsWidth,height: geoHeight)
//                .background(Color(WHColor_ARC()))
                
                VStack(alignment: .leading, content: {
                    Spacer()
                    Link(destination: URL(string: "elavatinelns://mealsIndex_2")!, label: {
                        MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                  calories:0,
                                  mealsIndex: 2,
                                  mealsImgName: "meals_eat_add_icon",
                                  mealsMsgDict: mealsArray[1] as? NSDictionary ?? [:],
                                  imgScale: 1.4)
                            .frame(width: mealsWidth,height: mealsWidth)
//                                .background(Color.red)
                    })
                    Spacer()
                    Link(destination: URL(string: "elavatinelns://mealsIndex_4")!, label: {
                        MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                  calories:0,
                                  mealsIndex: 4,
                                  mealsImgName: "meals_eat_add_icon",
                                  mealsMsgDict: mealsArray[3] as? NSDictionary ?? [:],
                                  imgScale: 1.4)
                            .frame(width: mealsWidth,height: mealsWidth)
//                                .background(Color.red)
                    })
                    Spacer()
                })
                .frame(width: mealsWidth,height: geoHeight)
//                .background(Color(WHColor_ARC()))
                
                Spacer()
                    .frame(width: geoWidth*0.02,height: geoHeight)
            }
            .frame(width: geoWidth,height: geoHeight)
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 10))
//            .background(Color(red: 250.0/255.0, green: 250.0/255.0, blue: 248.0/255.0,opacity: 0.1))
        })
    }
}

struct ElaNaturalWidgetCaloriesFourMeals: Widget {
    let kind: String = "ElaNaturalWidgetCaloriesFourMeals"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ElaNaturalWidgetCaloriesFourMealsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color(WHColorWithAlpha(colorStr: "007AFF", alpha: 0.02)))
//                    .background(Color(WHColor_16(colorStr: "EFEFEF")))
//                    .background(UIColor.isDarkModeEnabled ? Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.85) : Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.2))
            } else {
                ElaNaturalWidgetCaloriesFourMealsEntryView(entry: entry)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color(WHColorWithAlpha(colorStr: "007AFF", alpha: 0.02)))
//                    .background(Color(WHColor_16(colorStr: "EFEFEF")))
//                    .background(UIColor.isDarkModeEnabled ? Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.85) : Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.2))
            }
        }
        .configurationDisplayName("饮食记录")
        .description("今日营养目标 & 快速记录饮食")
        .supportedFamilies([.systemMedium])
        .disableContentMarginsIfNeeded()
    }
}
