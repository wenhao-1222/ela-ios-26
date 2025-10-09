//
//  CircleLayerView.swift
//  lns
//
//  Created by LNS2 on 2024/8/15.
//

import SwiftUI

struct CircleView: View {
    
    let lineWidth = 6.0
    let lineWidthProgress = 6.0
    
    var caloriesTarget = 0
    var calories = 0
    var sportCalories = 0
//    var percent:Double
    var themeColor = Color.init(red: 0, green: 122.0/255.0, blue: 1.0)
    var sportColor = Color.init(red: 1.0, green: 149.0/255.0, blue: 0.0)//FF9500
    
    var body: some View {
        GeometryReader { geometry in
            Arc(startAngle: .degrees(-90), endAngle: .degrees(270), clockwise: false)
                .stroke(Color(UIColor(named: "text_color_06") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_06), lineWidth: lineWidth)
                        .frame(width: geometry.size.width, height: geometry.size.width)
            
            
            let percent = Double(calories)/Double(caloriesTarget)
            let percentSport = Double(sportCalories)/Double(caloriesTarget)
            
            if percent > 0{
                //进度
                if percentSport > 0 {
                    ArcProgress(startAngle: .degrees(-90), endAngle: .degrees(360)*(1-percentSport)-Angle.degrees(90), clockwise: true, lineWidthProgress: lineWidthProgress)
                        .stroke(sportColor, style: StrokeStyle(lineWidth: lineWidthProgress,lineCap:.round))
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .animation(.linear(duration: 0.3))
                }
                
                ArcProgress(startAngle: .degrees(-90), endAngle: .degrees(360)*(percent)-Angle.degrees(90), clockwise: false, lineWidthProgress: lineWidthProgress)
                    .stroke(themeColor, style: StrokeStyle(lineWidth: lineWidthProgress,lineCap:.round))
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .animation(.linear(duration: 0.3))
                if percent > 1 {//如果  摄入  ＞  目标
                    let percentShow = percent >= 2 ? 2 : percent
                    ArcProgress(startAngle: .degrees(-90), endAngle: .degrees(360)*(percentShow-1)-Angle.degrees(90), clockwise: false, lineWidthProgress: lineWidthProgress)
                        .stroke(Color.init(red: 31.0/255.0, green: 64.0/255.0, blue: 134.0/255.0), style: StrokeStyle(lineWidth: lineWidthProgress,lineCap: .round,lineJoin: .round))
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .animation(.linear(duration: 0.3))
                    ArcProgress(startAngle: .degrees(-90), endAngle: .degrees(360)*(percentShow-1)-Angle.degrees(90), clockwise: false, lineWidthProgress: lineWidthProgress)
                        .stroke(Color.white.opacity(0.55), style: StrokeStyle(lineWidth: lineWidthProgress,dash: [1,3],dashPhase: 2))
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .animation(.linear(duration: 0.3))
                }
            }
         }
        
        VStack{
//            if calories > caloriesTarget{
//                Text("超出 \(calories - caloriesTarget)")
//                    .foregroundColor(Color.red)
//                    .font(Font.system(size: 10))
//            }else{
//                Text("剩余 \(caloriesTarget - calories)")
//                    .foregroundColor(themeColor)
            
//                    .font(Font.system(size: 10))
//            }
//            Spacer()
//            HStack(alignment: .bottom, content: {
//                Spacer()
//                    .frame(width: 5,height: 5)
                Text("\(calories)".replacingOccurrences(of: ",", with: ""))
//                .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                .foregroundColor(Color(UIColor(named: "text_color_85") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                    .font(.system(size: 16,weight: .medium))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
//
//                Text("kcal")
//                    .foregroundColor(Color.black.opacity(0.45))
//                    .font(Font.system(size: 8))
//                    .padding(EdgeInsets(top: 0, leading: -5, bottom: 0, trailing: 0))
//                    .minimumScaleFactor(0.5)
//                    .lineLimit(1)
//                Spacer()
//                    .frame(width: 5,height: 5)
//            })
            Text("/\(caloriesTarget)".replacingOccurrences(of: ",", with: ""))
//                .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_45))
                .foregroundColor(Color(UIColor(named: "text_color_45") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_45))
                .font(Font.system(size: 12))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
    }
}

//背景圆
struct Arc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
//        let radius = min(rect.width, rect.height) / 2
        let radius = rect.width / 2
        
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)

        return path
    }
}
//进度圆
struct ArcProgress: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool
    var lineWidthProgress: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = rect.width / 2 - 0.2
        
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        
        return path
    }
}
