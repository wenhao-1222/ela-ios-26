//
//  ElaWeekProteinWidget.swift
//  ElaWeekProteinWidget
//
//  Created by LNS2 on 2024/8/19.
//

import WidgetKit
import SwiftUI

struct ElaWeekProteinWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                let frame = CGSize(width: geometry.size.width - 8,
                                   height: geometry.size.height - 20)
                let dataOBj =  entry.isSnap ? WidgetUtils().getNaturalDataArrayDefault(type: .protein) : WidgetUtils().getNaturalDataArray(type: .protein)
                
                let totalNumber = dataOBj.doubleValueForKeyWidget(key: "maxValue")
                let dataArray = dataOBj["data"]as? NSArray ?? []
                let numbers = [(dataArray[0]as? NSDictionary ?? [:]).doubleValueForKeyWidget(key: "value"),
                               (dataArray[1]as? NSDictionary ?? [:]).doubleValueForKeyWidget(key: "value"),
                               (dataArray[2]as? NSDictionary ?? [:]).doubleValueForKeyWidget(key: "value"),
                               (dataArray[3]as? NSDictionary ?? [:]).doubleValueForKeyWidget(key: "value"),
                               (dataArray[4]as? NSDictionary ?? [:]).doubleValueForKeyWidget(key: "value"),
                               (dataArray[5]as? NSDictionary ?? [:]).doubleValueForKeyWidget(key: "value"),
                               (dataArray[6]as? NSDictionary ?? [:]).doubleValueForKeyWidget(key: "value")]
                
                HStack(alignment: .bottom, content: {
//                    Spacer()
                    Text("蛋白质")
//                        .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                        .foregroundColor(Color(UIColor(named: "text_color_85") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                        .font(Font.system(size: 12,weight: .bold))
//                    Spacer()
                    Text("（克）")
//                        .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_45))
                        .foregroundColor(Color(UIColor(named: "text_color_45") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_45))
                        .font(Font.system(size: 10,weight: .medium))
                        .padding(EdgeInsets(top: 0, leading: -6, bottom: 0, trailing: 0))
                    Spacer()
                })
                .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 0))
//                Spacer()
                
                let barWidth = frame.width*0.13
                let barHeight = frame.height*0.8
                let spaceWidth = frame.width*0.015
                
                HStack{
                    ElaWeekWidgetBarChartView(number: Int(numbers[0]),percent: numbers[0]/totalNumber,weekDay: (dataArray[0]as? NSDictionary ?? [:]).stringValueForKeyWidget(key: "weekday"),themeColor: Color(UIColor.COLOR_PROTEIN))
                        .frame(width: barWidth,height: barHeight)
                    Spacer()
                        .frame(width: spaceWidth,height: barHeight)
                    ElaWeekWidgetBarChartView(number: Int(numbers[1]),percent: numbers[1]/totalNumber,weekDay: (dataArray[1]as? NSDictionary ?? [:]).stringValueForKeyWidget(key: "weekday"),themeColor: Color(UIColor.COLOR_PROTEIN))
                        .frame(width: barWidth,height: barHeight)
                    Spacer()
                        .frame(width: spaceWidth,height: barHeight)
                    ElaWeekWidgetBarChartView(number: Int(numbers[2]),percent: numbers[2]/totalNumber,weekDay: (dataArray[2]as? NSDictionary ?? [:]).stringValueForKeyWidget(key: "weekday"),themeColor: Color(UIColor.COLOR_PROTEIN))
                        .frame(width: barWidth,height: barHeight)
                    Spacer()
                        .frame(width: spaceWidth,height: barHeight)
                    ElaWeekWidgetBarChartView(number: Int(numbers[3]),percent: numbers[3]/totalNumber,weekDay: (dataArray[3]as? NSDictionary ?? [:]).stringValueForKeyWidget(key: "weekday"),themeColor: Color(UIColor.COLOR_PROTEIN))
                        .frame(width: barWidth,height: barHeight)
                    Spacer()
                        .frame(width: spaceWidth,height: barHeight)
                    ElaWeekWidgetBarChartView(number: Int(numbers[4]),percent: numbers[4]/totalNumber,weekDay: (dataArray[4]as? NSDictionary ?? [:]).stringValueForKeyWidget(key: "weekday"),themeColor: Color(UIColor.COLOR_PROTEIN))
                        .frame(width: barWidth,height: barHeight)
                    Spacer()
                        .frame(width: spaceWidth,height: barHeight)
                    ElaWeekWidgetBarChartView(number: Int(numbers[5]),percent: numbers[5]/totalNumber,weekDay: (dataArray[5]as? NSDictionary ?? [:]).stringValueForKeyWidget(key: "weekday"),themeColor: Color(UIColor.COLOR_PROTEIN))
                        .frame(width: barWidth,height: barHeight)
                    Spacer()
                        .frame(width: spaceWidth,height: barHeight)
                    ElaWeekWidgetBarChartView(number: Int(numbers[6]),percent: numbers[6]/totalNumber,weekDay: (dataArray[6]as? NSDictionary ?? [:]).stringValueForKeyWidget(key: "weekday"),themeColor: Color(UIColor.COLOR_PROTEIN))
                        .frame(width: barWidth,height: barHeight)
                }
            }
            .padding(EdgeInsets(top: 10, leading: 4, bottom: 10, trailing: 4))
        })
    }
}

struct ElaWeekProteinWidget: Widget {
    let kind: String = "ElaWeekProteinWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ElaWeekProteinWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color(WHColorWithAlpha(colorStr: "007AFF", alpha: 0.02)))
//                    .background(Color(WHColor_16(colorStr: "EFEFEF")))
//                    .background(UIColor.isDarkModeEnabled ? Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.85) : Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.2))
            } else {
                ElaWeekProteinWidgetEntryView(entry: entry)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color(WHColorWithAlpha(colorStr: "007AFF", alpha: 0.02)))
//                    .background(Color(WHColor_16(colorStr: "EFEFEF")))
//                    .background(UIColor.isDarkModeEnabled ? Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.85) : Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0,opacity: 0.2))
            }
        }
        .configurationDisplayName("蛋白质")
        .description("过去7天摄入：蛋白质")
        .supportedFamilies([.systemSmall])
        .disableContentMarginsIfNeeded()
    }
}
