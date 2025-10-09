//
//  ElaNaturalThreeMealsWidget.swift
//  ElaNaturalThreeMealsWidget
//
//  Created by LNS2 on 2024/8/22.

import WidgetKit
import SwiftUI

struct ElaNaturalThreeMealsWidgetEntryView : View {
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
                                         progressColor: Color.init(red: 0, green: 122.0/255.0, blue: 1.0),
                                         fillColor: Color(red: 85.0/255.0, green: 41.0/255.0, blue: 143.0/255.0))
                            .frame(width: progressWidth,height: geoHeight*0.23)
                        
                        Spacer()
                            .frame(width: progressWidth,height: 25)
                            ProgressView(naturalType: "碳水",
                                         numberTarget: dict.doubleValueForKeyWidget(key: "carboTar").rounded(),
                                         number: dict.doubleValueForKeyWidget(key: "carbohydrates").rounded(),
                                         progressColor: Color(red: 113.0/255.0, green: 55.0/255.0, blue: 191.0/255.0),
                                         fillColor: Color(red: 85.0/255.0, green: 41.0/255.0, blue: 143.0/255.0))
                            .frame(width: progressWidth,height: geoHeight*0.2)
                            .padding(EdgeInsets(top: -4, leading: 0, bottom: 0, trailing: 0))

                            ProgressView(naturalType: "蛋白质",
                                         numberTarget: dict.doubleValueForKeyWidget(key: "proteinTar").rounded(),
                                         number: dict.doubleValueForKeyWidget(key: "protein").rounded(),
                                         progressColor: Color(red: 245.0/255.0, green: 186.0/255.0, blue: 24.0/255.0),
                                         fillColor: Color(red: 135.0/255.0, green: 102.0/255.0, blue: 13.0/255.0))
                                .frame(width: progressWidth,height: geoHeight*0.2)
                                .padding(EdgeInsets(top: -4, leading: 0, bottom: 0, trailing: 0))
        //                                        .background(Color.green)
                        
                            ProgressView(naturalType: "脂肪",
                                         numberTarget: dict.doubleValueForKeyWidget(key: "fatsTar").rounded(),
                                         number: dict.doubleValueForKeyWidget(key: "fats").rounded(),
                                         progressColor: Color(red: 226.0/255.0, green: 115.0/255.0, blue: 24.0/255.0),
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

struct ElaNaturalThreeMealsWidget: Widget {
    let kind: String = "ElaNaturalThreeMealsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ElaNaturalThreeMealsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color(WHColorWithAlpha(colorStr: "007AFF", alpha: 0.02)))
//                    .background(Color(WHColor_16(colorStr: "EFEFEF")))
//                    .background(UIColor.isDarkModeEnabled ? Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.85) : Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.2))
            } else {
                ElaNaturalThreeMealsWidgetEntryView(entry: entry)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color(WHColorWithAlpha(colorStr: "007AFF", alpha: 0.02)))
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
