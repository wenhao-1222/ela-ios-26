//
//  ElaNaturalWidgetBundle.swift
//  ElaNaturalWidget
//
//  Created by LNS2 on 2024/8/14.
//

import WidgetKit
import SwiftUI

@main
struct ElaNaturalWidgetBundle: WidgetBundle {
    var body: some Widget {
        
        ElaNaturalWidgetCalories()//六餐  带卡路里icon
        
        ElaNaturalWidgetCaloriesFourMeals()//四餐  带卡路里icon
        ElaNaturalWidget()//六餐
        ElaNaturalFiveMealsWidget()//五餐
        ElaNaturalFourMealsWidget()//四餐
        ElaNaturalThreeMealsWidget()//三餐
        
        ElaWeekCaloriesWidget()
        ElaWeekCarboWidget()
        ElaWeekProteinWidget()
        ElaWeekFatWidget()
//        ElaLockScreenWidget()
    }
}


