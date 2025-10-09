//
//  ProgressView.swift
//  lns
//
//  Created by LNS2 on 2024/8/15.
//

import SwiftUI

struct ProgressView: View {
    
    var naturalType:String
    var numberTarget:Double
    var number:Double
    
    var progressColor:Color
    var fillColor:Color
    
    let progressHeight = CGFloat(6)
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                
                HStack{
                    Text("\(naturalType)")
//                        .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                        .foregroundColor(Color(UIColor(named: "text_color_85") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                        .font(.system(size: 10,weight: .regular))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
//                Text("\(Date().nextDay(days: 0))")
//                    .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_85))
//                    .font(.system(size: 12,weight: .medium))
//                    .minimumScaleFactor(0.3)
//                    .lineLimit(1)
                    Spacer()
                    if number > numberTarget{
                        Text("\(Int(number.rounded()))".replacingOccurrences(of: ",", with: ""))
                            .foregroundColor(Color.red)
                            .font(.system(size: 10,weight: .medium))
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                    }else{
                        Text("\(Int(number.rounded()))".replacingOccurrences(of: ",", with: ""))
//                            .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                            .foregroundColor(Color(UIColor(named: "text_color_85") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                            .font(.system(size: 10,weight: .medium))
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                    }
                    
                    Text("/\(Int(numberTarget.rounded()))g".replacingOccurrences(of: ",", with: ""))
//                        .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                        .foregroundColor(Color(UIColor(named: "text_color_45") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                        .font(.system(size: 8,weight: .regular))
                        .padding(EdgeInsets(top: 0, leading: -5, bottom: 0, trailing: 0))
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)
                    
//                    Spacer()
                }
//                Spacer()
                
                ZStack(alignment: .leading, content: {
                    let percent = number/numberTarget
                    Progress(percent: 1.0)
//                        .stroke(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_06),
//                                style: StrokeStyle(lineWidth: progressHeight,lineCap: .round))
                        .stroke(Color(UIColor(named: "text_color_06") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_06),
                                style: StrokeStyle(lineWidth: progressHeight,lineCap: .round))
                    
                        .frame(width: geometry.size.width,height: progressHeight)
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
                })
                .padding(EdgeInsets(top: -2, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
}

//背景Progress
struct Progress: Shape {
    
    var percent: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint.init(x: 0, y: rect.minY))
        path.addLine(to: CGPoint.init(x: rect.width, y: rect.minY))
        
        return path
    }
}

//背景Progress
struct ProgressSport: Shape {
    
    var percent: Double
    var percentSport: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint.init(x: 0, y: rect.minY))
        path.addLine(to: CGPoint.init(x: rect.width, y: rect.minY))
        
        return path
    }
}
