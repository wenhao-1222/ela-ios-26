//
//  ElaNaturalWidgetCaloriesProgressView.swift
//  lns
//
//  Created by LNS2 on 2024/8/27.
//

import SwiftUI

struct ElaNaturalWidgetCaloriesProgressView: View {
    
    var numberTarget:Double
    var number:Double
    var sportCalories:Double
    
    let progressHeight = CGFloat(10)
    let progressColor = Color.init(red: 0, green: 122.0/255.0, blue: 1.0)
    let fillColor = Color(red: 85.0/255.0, green: 41.0/255.0, blue: 143.0/255.0)
    var sportColor = Color.init(red: 1.0, green: 149.0/255.0, blue: 0.0)//FF9500
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                HStack(alignment: .center, content: {
                    Image("calories_widget_icon", bundle: .main)
                        .frame(width: 13,height: 16)
                    Text("卡路里")
                        .foregroundColor(Color(UIColor(named: "text_color_85") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_85))
//                        .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                    
//                        .foregroundColor(Color(UIColor(named: "widget_text_color") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                        .font(.system(size: 12,weight: .medium))
//                    Text("\(Date().nextDay(days: 0))")
//                        .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_85))
//                        .font(.system(size: 12,weight: .medium))
//                        .minimumScaleFactor(0.3)
//                        .lineLimit(1)
                    Spacer()
                    
                    if number > numberTarget{
                        Text("\(Int(number.rounded()))".replacingOccurrences(of: ",", with: ""))
                            .foregroundColor(Color.red)
                            .font(.system(size: 10,weight: .medium))
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -4))
                    }else{
                        Text("\(Int(number.rounded()))".replacingOccurrences(of: ",", with: ""))
//                            .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                            .foregroundColor(Color(UIColor(named: "text_color_85") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                            .font(.system(size: 10,weight: .medium))
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -4))
//                            .minimumScaleFactor(0.5)
//                            .lineLimit(1)
                    }
                    Text("/\(Int(numberTarget.rounded()))千卡".replacingOccurrences(of: ",", with: ""))
//                        .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                        .foregroundColor(Color(UIColor(named: "text_color_85") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                        .font(.system(size: 8,weight: .regular))
                })
                
                ZStack(alignment: .leading, content: {
//                    HStack {
                        let percent = number/numberTarget
                    
                        Progress(percent: 1.0)
                            .stroke(Color(UIColor(named: "text_color_06") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_06),
                                    style: StrokeStyle(lineWidth: progressHeight,lineCap: .round))
    //                        .stroke(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_06),
    //                                style: StrokeStyle(lineWidth: progressHeight,lineCap: .round))
                            .frame(width: geometry.size.width,height: progressHeight)
                    
                    
                    //运动消耗数据  ----------------------
//                        let percentSport = sportCalories/numberTarget
//                        let sportWidth = geometry.size.width * percentSport
//                        
//                        Progress(percent: percentSport)
//                            .stroke(sportColor,
//                                    style: StrokeStyle(lineWidth: progressHeight,lineCap: .round))
//                            .frame(width: sportWidth,height: progressHeight)
//                            .padding(EdgeInsets(top: 0, leading: geometry.size.width*percent, bottom: 0, trailing: 0))
//                            .animation(.linear(duration: 0.3))
                        // ----------------------
                        if percent > 0 {
                            if percent > 1{
                                Progress(percent: 1)
                                    .stroke(progressColor,
                                            style: StrokeStyle(lineWidth: progressHeight,lineCap: .round))
                                    .frame(width: geometry.size.width,height: progressHeight)
                                    .animation(.linear(duration: 0.3))
                                
                                let fillPercent = percent >= 2 ? 1 : percent.truncatingRemainder(dividingBy: 1)
                                
                                Progress(percent: fillPercent)
    //                                .stroke(Color.white,
    //                                        style: StrokeStyle(lineWidth: progressHeight,dash: [1,4]))
                                    .stroke(Color.init(red: 66.0/255.0, green: 66.0/255.0, blue: 66.0/255.0,opacity: 0.7),
                                            style: StrokeStyle(lineWidth: progressHeight,lineCap: .round))
                                    .frame(width: geometry.size.width*fillPercent,height: progressHeight)
                                    .animation(.linear(duration: 0.3))
                            }else{
                                Progress(percent: percent)
                                    .stroke(progressColor,
                                            style: StrokeStyle(lineWidth: progressHeight,lineCap: .round))
                                    .frame(width: geometry.size.width*percent,height: progressHeight)
                                    .animation(.linear(duration: 0.3))
                            }
                        }
//                    }
                })
//                .padding(EdgeInsets(top: -2, leading: 0, bottom: 0, trailing: 0))
                
            }
        }
    }
}
