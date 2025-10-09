//
//  ElaWeekWidgetBarChartView.swift
//  lns
//
//  Created by LNS2 on 2024/8/19.
//

import SwiftUI

struct ElaWeekWidgetBarChartView: View {
    
    var number = 0
    var percent = Double(0)
    var weekDay = "一"
    
//    let color = Color.init(red: 194.0/255.0, green: 223.0/255.0, blue: 1.0)
    var themeColor = Color.init(red: 0, green: 122.0/255.0, blue: 1.0)
    let totalNumber = Double(1000)
    
    var body: some View {
        
        GeometryReader(content: { geometry in
            
            let barHeight = geometry.size.height * 0.7 * percent
            
            VStack{
                VStack{
                    Spacer()
                        .frame(width: geometry.size.width,height: geometry.size.height * 0.85 - barHeight - 13)
                    let numberText = number > 0 ? "\(number)" : ""
                    Text("\(numberText)".replacingOccurrences(of: ",", with: ""))
                        .font(.system(size: 8))
//                        .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_65))
                        .foregroundColor(Color(UIColor(named: "text_color_65") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_65))
                        .frame(width: geometry.size.width*1.5,height: geometry.size.height * 0.15,alignment: .center)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: -8, trailing: 0))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    VStack{
                        
                    }
                    .frame(width: geometry.size.width*0.8,height: barHeight)
                    .background(themeColor)
                    .cornerRadius(2)
                }
                .frame(width: geometry.size.width,height: geometry.size.height*0.85)
//                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                
                VStack{
                    Text(weekDay)
                        .font(Font.system(size: 10,weight: .regular))
//                        .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                        .foregroundColor(Color(UIColor(named: "text_color_85") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_85))
                        .frame(width: geometry.size.width,height: 12,alignment: .center)
                }
                .frame(width: geometry.size.width,height: geometry.size.height*0.15)
            }
        })
//        .background(Color.green)
    }
}



