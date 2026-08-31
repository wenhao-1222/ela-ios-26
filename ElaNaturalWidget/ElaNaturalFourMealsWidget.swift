//
//  ElaNaturalFourMealsWidget.swift
//  ElaNaturalFourMealsWidget
//  Created by LNS2 on 2024/8/14.
//

import WidgetKit
import SwiftUI


private struct LegacyElaNaturalFourMealsWidgetEntryView: View {
    var entry: Provider.Entry
    
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
//                            NSLog("WidgetUtils().readNaturalData()(ElaNaturalFourMealsWidgetEntryView):%@", dict)
//                            WidgetUtils().sendNaturalDataRequest(meals: 4)
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
                                                     progressColor: Color("color_natural_carbo", bundle: .main),
                                                     fillColor: Color(red: 85.0/255.0, green: 41.0/255.0, blue: 143.0/255.0))
                                        .frame(width: progressWidth,height: progressSize.size.height*0.3)
                                        ProgressView(naturalType: "蛋白质",
                                                     numberTarget: dict.doubleValueForKeyWidget(key: "proteinTar").rounded(),
                                                     number: dict.doubleValueForKeyWidget(key: "protein").rounded(),
                                                     progressColor: Color("color_natural_protein", bundle: .main),
                                                     fillColor: Color(red: 135.0/255.0, green: 102.0/255.0, blue: 13.0/255.0))
                                            .frame(width: progressWidth,height: progressSize.size.height*0.3)
    //                                        .background(Color.green)
                                        ProgressView(naturalType: "脂肪",
                                                     numberTarget: dict.doubleValueForKeyWidget(key: "fatsTar").rounded(),
                                                     number: dict.doubleValueForKeyWidget(key: "fats").rounded(),
                                                     progressColor: Color("color_natural_fat", bundle: .main),
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
                        let mealsWidth = min((geoWidth - 20) * 0.24, geoHeight)
                        let mealsHeight = (geoHeight-topFrameHeight)*0.85
                        
                        Link(destination: URL(string: "elavatinelns://mealsIndex_1")!, label: {
                            MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                      calories:0,
                                      mealsIndex: 1,
                                      mealsImgName: "meals_eat_add_icon",
                                      mealsMsgDict: mealsArray[0] as? NSDictionary ?? [:],
                                      imgScale: 1.4)
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
                                      mealsMsgDict: mealsArray[1] as? NSDictionary ?? [:],
                                      imgScale: 1.4)
                                .frame(width: mealsWidth,height: mealsHeight)
//                                .background(Color.blue)
                        })
    //                    Spacer()
                        Link(destination: URL(string: "elavatinelns://mealsIndex_3")!, label: {
                            MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                      calories:3,
                                      mealsIndex: 3,
                                      mealsImgName: "meals_eat_right_icon",
                                      mealsMsgDict: mealsArray[2] as? NSDictionary ?? [:],
                                      imgScale: 1.4)
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
                                      mealsMsgDict: mealsArray[3] as? NSDictionary ?? [:],
                                      imgScale: 1.4)
                                .frame(width: mealsWidth,height: mealsHeight)
//                                .background(Color.yellow)
                        })
                    })
                    .frame(width: geoWidth,height: geoHeight-topFrameHeight)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                    .background(Color.gray)
                }
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 5, trailing: 15))
            }
            .frame(width: geometry.size.width,height: geometry.size.height)
//            .background(Color(red: 250.0/255.0, green: 250.0/255.0, blue: 248.0/255.0,opacity: 0.1))
         }
    }
}

struct ElaNaturalFourMealsWidgetEntryView: View {
    let entry: Provider.Entry

    var body: some View {
        ElaNaturalMealsWidgetEntryView(entry: entry, mealCount: 4)
    }
}

struct ElaNaturalFourMealsWidget: Widget {
    let kind: String = "ElaNaturalFourMealsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ElaNaturalFourMealsWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        FiveMealsWidgetBackground()
                    }
                    .edgesIgnoringSafeArea(.all)
//                    .background(Color(WHColor_16(colorStr: "EFEFEF")))
//                    .background(UIColor.isDarkModeEnabled ? Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.85) : Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.2))
            } else {
                ElaNaturalFourMealsWidgetEntryView(entry: entry)
                    .edgesIgnoringSafeArea(.all)
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
