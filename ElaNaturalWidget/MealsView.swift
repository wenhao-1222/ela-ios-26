//
//  MealsView.swift
//  ElaNaturalWidgetExtension
//
//  Created by LNS2 on 2024/8/16.
//

import SwiftUI
import WidgetKit

struct MealsView: View {
    
    var caloriesTarget = 0
    var calories = 0
    
    var mealsIndex = 1
    var mealsImgName = "meals_eat_add_icon"
    
    var mealsMsgDict = NSDictionary()
    let lineWidth = 2.0
    
    var imgScale = 1.0
    
    let themeColor = Color.init(red: 0, green: 122.0/255.0, blue: 1.0)
    
    var body: some View {
    
        GeometryReader(content: { geometry in
//            Button(action: {
//                WidgetUtils().saveMealsData(mealsIndex: mealsIndex)
//                let link = Link(destination: URL(string: "elavatinelns://mealsIndex_\(mealsIndex)")!,label: {
//                    
//                })
////                WidgetCenter.shared.o
//            }, label: {
                    ZStack(alignment: Alignment(horizontal: .center, vertical: .center), content: {
                        RoundedBorderWithShadowView()
                            .frame(width: geometry.size.width*0.98,height: geometry.size.height*0.98)
                        
                        VStack(alignment: .center, content: {
                            let imgWidth = min(16, geometry.size.width * 0.4) * imgScale
                            Spacer()
                                .frame(width: imgWidth,height: 10)
                            if mealsMsgDict["isEat"]as? String ?? "" == "1" {
                                //meals_eat_right_icon  meals_eat_icon
                                Image(ImageResource(name: "meals_eat_icon", bundle: .main))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .scaledToFill()
                                    .frame(width: imgWidth,height: imgWidth)
//                                    .background(Color(WHColor_ARC()))
                            }else{
                                if UIColor.isDarkModeEnabled{
                                    Image(ImageResource(name: "meals_eat_add_icon_theme", bundle: .main))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .scaledToFill()
                                        .frame(width: imgWidth,height: imgWidth)
//                                        .background(Color(WHColor_ARC()))
                                }else{
                                    Image(ImageResource(name: "meals_eat_add_icon_theme", bundle: .main))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .scaledToFill()
                                        .frame(width: imgWidth,height: imgWidth)
//                                        .background(Color(WHColor_ARC()))
                                }
                            }
                            
                            Text("第 \(mealsIndex) 餐")
//                                .foregroundColor(Color(UIColor.WIDGET_COLOR_GRAY_BLACK_65))
                            
                                .foregroundColor(Color(UIColor(named: "text_color_65") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_65))
                                .font(Font.system(size: 10,weight: .medium))
                                .padding(EdgeInsets(top: -5, leading: 0, bottom: 0, trailing: 0))
                            Spacer()
                                .frame(width: 10,height: 4)
                        })
                        .frame(width: geometry.size.width*0.98,height: geometry.size.height*0.98)
                    })
                    .frame(width: geometry.size.width,height: geometry.size.height)
//            })
//            .frame(width: geometry.size.width,height: geometry.size.height)
        })
    }
}

struct RoundedBorderWithShadowView: View {
    var body: some View {
        GeometryReader(content: { geometry in
            
            VStack{
                
            }
            .frame(width: geometry.size.width,height: geometry.size.height)
            .background(Color(UIColor.clear))
//            .background(Color(UIColor(named: "black_color_01") ?? UIColor.WIDGET_COLOR_GRAY_BLACK_01))
            //
            .overlay(
                RoundedRectangle(cornerRadius: 8,style: .continuous)
                    .stroke(Color(UIColor(named: "white_color_85") ?? UIColor(white: 1, alpha: 0.85)),lineWidth: 1)
//                    .stroke(Color.white.opacity(0.85),lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.5),radius: 8,x: 0,y: 4)
        })
    }
}
 
