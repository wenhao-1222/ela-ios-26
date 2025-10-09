//
//  ElaNaturalWidget.swift
//  ElaNaturalWidget
//
//  Created by LNS2 on 2024/8/14.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),isSnap: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(),isSnap: true)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.calendar = Calendar.init(identifier: .gregorian)
        dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        
        let firstDate = Date.getFirstEntryDate()
        var entries: [SimpleEntry] = []
        entries.append(SimpleEntry(date: firstDate,isSnap: false))
        
        var expireDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        for i in 1...12{
            let entryDate = Date().getFirstHourOfCurrentDate(minute: i*5)!
            let dateString = dateFormatter.string(from: entryDate)
            if Date().judgeMin(firstTime: Date().currentSeconds, secondTime: dateString){
                let entry = SimpleEntry(date: entryDate,isSnap: false)
                entries.append(entry)
                
                expireDate = entryDate
                break
            }
        }
        let timeline = Timeline(entries: entries, policy: .after(expireDate))
        
        for i in 0..<entries.count{
            let entry = entries[i]
            let beijingDateString = dateFormatter.string(from: entry.date)
            print("刷新时间  （\(i)）  ：   \(entry.date)   ---  \(beijingDateString)")
        }
        print("刷新时间  （过期刷新时间）  ：   \(expireDate)  --- \(dateFormatter.string(from: expireDate))")
        print("刷新时间  （当前设备时间）  ：   \(Date())   --- \(dateFormatter.string(from: Date()))")
        
        print("刷新时间  （网络请求 \((Int(Date().timeStamp)!))  \(WidgetUtils.lastRefreshTimeStamp)")
        print("刷新时间  （网络请求 \(WidgetUtils.isManual)")
        //如果是手动修改食物，或者上次刷新的时间，距今大于240秒
        if WidgetUtils.isManual == true || (Int(Date().timeStamp)! - WidgetUtils.lastRefreshTimeStamp > 200) || (Int(Date().timeStamp)! - WidgetUtils.lastRefreshTimeStamp < -240){
            print("刷新时间  （网络请求 ")
            WidgetUtils.isManual = false
            WidgetUtils.lastRefreshTimeStamp = Int(Date().timeStamp)!
            WidgetUtils().sendNaturalLast7Days(forNaturalType: 10)
        }
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let isSnap:Bool
}

struct ElaNaturalWidgetEntryView : View {
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
                                let sportCalories = WidgetUtils().readSportInTargetStatus() == "0" ? 0 : Int(dict.doubleValueForKeyWidget(key: "sportCalories").rounded())
                                
                                CircleView(caloriesTarget: Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) + sportCalories,
                                           calories: Int(dict.doubleValueForKeyWidget(key: "calori").rounded()),
                                           sportCalories: sportCalories)
                                    .frame(width: caloriesCircleWidth,height: caloriesCircleWidth)
                            }
                        })
                        .frame(width: caloriesCircleWidth,height: caloriesCircleWidth)
                        
                        Spacer()
                        GeometryReader { progressSize in
                            HStack{
                                Spacer()
                                VStack(alignment: .trailing, content: {
                                        let progressWidth = progressSize.size.width*0.9
                                        ProgressView(naturalType: "碳水",
                                                     numberTarget: dict.doubleValueForKeyWidget(key: "carboTar").rounded(),
                                                     number: dict.doubleValueForKeyWidget(key: "carbohydrates").rounded(),
                                                     progressColor: Color(UIColor.COLOR_CARBOHYDRATE),
                                                     fillColor: Color(UIColor.COLOR_CARBOHYDRATE_FILL))
                                        .frame(width: progressWidth,height: progressSize.size.height*0.3)
                                        ProgressView(naturalType: "蛋白质",
                                                     numberTarget: dict.doubleValueForKeyWidget(key: "proteinTar").rounded(),
                                                     number: dict.doubleValueForKeyWidget(key: "protein").rounded(),
                                                     progressColor: Color(UIColor.COLOR_PROTEIN),
                                                     fillColor: Color(UIColor.COLOR_PROTEIN_FILL))
                                            .frame(width: progressWidth,height: progressSize.size.height*0.3)
    //                                        .background(Color.green)
                                        ProgressView(naturalType: "脂肪",
                                                     numberTarget: dict.doubleValueForKeyWidget(key: "fatsTar").rounded(),
                                                     number: dict.doubleValueForKeyWidget(key: "fats").rounded(),
                                                     progressColor: Color(UIColor.COLOR_FAT),
                                                     fillColor: Color(UIColor.COLOR_FAT_FILL))
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
                    HStack(alignment: .center, content: {
                        let mealsWidth = min(geoWidth * 0.15, geoHeight)
                        Link(destination: URL(string: "elavatinelns://mealsIndex_1")!) {
                            MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                      calories:0,
                                      mealsIndex: 1,
                                      mealsImgName: "meals_eat_add_icon",
                                      mealsMsgDict: mealsArray[0] as? NSDictionary ?? [:])
                                .frame(width: mealsWidth,height: mealsWidth)
                        }
                        Link(destination: URL(string: "elavatinelns://mealsIndex_2")!, label: {
                            MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                      calories:0,
                                      mealsIndex: 2,
                                      mealsImgName: "meals_eat_add_icon",
                                      mealsMsgDict: mealsArray[1] as? NSDictionary ?? [:])
                                .frame(width: mealsWidth,height: mealsWidth)
//                                .background(Color.blue)
//                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        })
    //                    Spacer()
                        
                        Link(destination: URL(string: "elavatinelns://mealsIndex_3")!, label: {
                            MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                      calories:3,
                                      mealsIndex: 3,
                                      mealsImgName: "meals_eat_right_icon",
                                      mealsMsgDict: mealsArray[2] as? NSDictionary ?? [:])
                                .frame(width: mealsWidth,height: mealsWidth)
//                                .background(Color.red)
//                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        })
    //                    Spacer()
                        Link(destination: URL(string: "elavatinelns://mealsIndex_4")!, label: {
                            MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                      calories:0,
                                      mealsIndex: 4,
                                      mealsImgName: "meals_eat_right_icon",
                                      mealsMsgDict: mealsArray[3] as? NSDictionary ?? [:])
                                .frame(width: mealsWidth,height: mealsWidth)
//                                .background(Color.yellow)
//                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        })
    //                    Spacer()
                        Link(destination: URL(string: "elavatinelns://mealsIndex_5")!, label: {
                            MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                      calories:1,
                                      mealsIndex: 5,
                                      mealsImgName: "meals_eat_icon",
                                      mealsMsgDict: mealsArray[4] as? NSDictionary ?? [:])
                                .frame(width: mealsWidth,height: mealsWidth)
//                                .background(Color.blue)
//                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        })
    //                    Spacer()
                        Link(destination: URL(string: "elavatinelns://mealsIndex_6")!, label: {
                            MealsView(caloriesTarget:Int(dict.doubleValueForKeyWidget(key: "caloriTar").rounded()) ,
                                      calories:0,
                                      mealsIndex: 6,
                                      mealsImgName: "meals_eat_icon",
                                      mealsMsgDict: mealsArray[5] as? NSDictionary ?? [:])
                                .frame(width: mealsWidth,height: mealsWidth)
//                                .background(Color.green)
//                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        })
                    })
                    .frame(width: geoWidth,height: geoHeight-topFrameHeight)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    //                .background(Color.blue)
                }
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 5, trailing: 15))
            }
            .frame(width: geometry.size.width,height: geometry.size.height)
//            .background(Color(red: 250.0/255.0, green: 250.0/255.0, blue: 248.0/255.0,opacity: 0.1))
         }
    }
}

struct ElaNaturalWidget: Widget {
    let kind: String = "ElaNaturalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ElaNaturalWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color(WHColorWithAlpha(colorStr: "007AFF", alpha: 0.02)))
//                    .background(Color(WHColor_16(colorStr: "EFEFEF")))
//                    .background(UIColor.isDarkModeEnabled ? Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.85) : Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.2))
            } else {
                ElaNaturalWidgetEntryView(entry: entry)
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

//extension View {
//    func widgetBackground(_ backgroundView: some View) -> some View {
//        if #available(iOSApplicationExtension 17.0, *) {
//            return containerBackground(for: .widget) {
//                backgroundView
//                    .background(UIColor.isDarkModeEnabled ? Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.85) : Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.2))
//            }
//        } else {
//            return background(backgroundView
//                .background(UIColor.isDarkModeEnabled ? Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.85) : Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.2)))
//        }
//    }
//}
extension WidgetConfiguration {
    func disableContentMarginsIfNeeded() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}
