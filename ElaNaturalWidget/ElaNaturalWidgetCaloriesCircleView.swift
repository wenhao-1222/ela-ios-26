//
//  ElaNaturalWidgetCaloriesCircleView.swift
//  lns
//
//  Created by LNS2 on 2024/8/27.
//

import SwiftUI

struct ElaNaturalWidgetCaloriesCircleView: View {
    
    let lineWidth = 6.0
    let lineWidthProgress = 6.0
    
    var caloriesTarget = 0
    var calories = 0
//    var percent:Double
    var themeColor = Color.init(red: 0, green: 122.0/255.0, blue: 1.0)
    var fillColor = Color.init(red: 31.0/255.0, green: 64.0/255.0, blue: 134.0/255.0)
    //Color(red: 85.0/255.0, green: 41.0/255.0, blue: 143.0/255.0)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center, content: {
                Arc(startAngle: .degrees(-90), endAngle: .degrees(270), clockwise: false)
//                    .stroke(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_06), lineWidth: lineWidth)
                    .stroke(Color(UIColor(named: "text_color_06") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_06), lineWidth: lineWidth)
                            .frame(width: geometry.size.width, height: geometry.size.width)
                                    .frame(width: geometry.size.width, height: geometry.size.width)
                
                let percent = Double(calories)/Double(caloriesTarget)
                
                if percent > 0{
                    //进度
                    ArcProgress(startAngle: .degrees(-90), endAngle: .degrees(360)*(percent)-Angle.degrees(90), clockwise: false, lineWidthProgress: lineWidthProgress)
                        .stroke(themeColor, style: StrokeStyle(lineWidth: lineWidthProgress,lineCap:.round))
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .animation(.linear(duration: 0.3))
                    if percent > 1 {//如果  摄入  ＞  目标
                        let percentShow = percent >= 2 ? 2 : percent
                        ArcProgress(startAngle: .degrees(-90), endAngle: .degrees(360)*(percentShow-1)-Angle.degrees(90), clockwise: false, lineWidthProgress: lineWidthProgress)
                            .stroke(fillColor, style: StrokeStyle(lineWidth: lineWidthProgress,lineCap: .round,lineJoin: .round))
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .animation(.linear(duration: 0.3))
                        ArcProgress(startAngle: .degrees(-90), endAngle: .degrees(360)*(percentShow-1)-Angle.degrees(90), clockwise: false, lineWidthProgress: lineWidthProgress)
                            .stroke(Color.white.opacity(0.55), style: StrokeStyle(lineWidth: lineWidthProgress,dash: [1,3],dashPhase: 2))
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .animation(.linear(duration: 0.3))
                    }
                }
                
                VStack{
                        Text("\(calories)".replacingOccurrences(of: ",", with: ""))
//                        .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                        .foregroundColor(Color(UIColor(named: "text_color_85") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                            .font(.system(size: 12,weight: .bold))
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    Text("/\(caloriesTarget)".replacingOccurrences(of: ",", with: ""))
//                        .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_45))
                        .foregroundColor(Color(UIColor(named: "text_color_45") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_45))
                    
                        .font(Font.system(size: 8,weight: .medium))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
            })
            .frame(width: geometry.size.width,height: geometry.size.height)
            
         }
    }
}
