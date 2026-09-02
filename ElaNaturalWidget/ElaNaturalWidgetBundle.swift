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
        // 两个中号组件根据 App Group 中的个性化设置动态展示 3～6 餐。
        ElaNaturalWidgetCalories()
        ElaNaturalWidget()

        // 小号三餐组件是独立样式，始终保留固定三餐布局。
        ElaNaturalThreeMealsWidget()
        
        ElaWeekCaloriesWidget()
        ElaWeekCarboWidget()
        ElaWeekProteinWidget()
        ElaWeekFatWidget()
//        ElaLockScreenWidget()
    }
}
