//
//  QuestinonaireMsgModel.swift
//  lns
//
//  Created by LNS2 on 2024/3/29.
//

import Foundation

class QuestinonaireMsgModel{
    
    static let shared = QuestinonaireMsgModel()
    
    private init(){
        
    }
    
    var name = ""
    var surveytype = ""
    
    var sex = ""//性别  1 男  2  女
    var birthDay = ""//出生年份
    var goal = ""//目标
    var height = ""//身高
    var weight = ""//体重
    var targetWeight = ""//目标体重
    var paceLevel = "steady"//计划节奏档位
    var chartStartDate = Date()//折线图开始日期
    var chartEndDate = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()//折线图结束日期（最多间隔14天）
    var foodAllergy = ""//过敏/忌口
    var foodBarrier = ""//饮食阻碍
    var foodTasteType = ""//食物口味偏好
    var dietHistoryType = ""//高蛋白/低碳/生酮饮食尝试情况
    var events = ""//日常活动量
    var bodyFat = ""//体脂肪
    var mealsPerDay = ""
    var planWeeks = ""
    var dailyfoodsqty = "2"
    
    var foodsMsgProteins = NSMutableArray()
    var foodsMsgFats   = NSMutableArray()
    var foodsMsgCarbohydrates   = NSMutableArray()
    var foodsMsgVegetables  = NSMutableArray()
    var foodsMsgFrutis   = NSMutableArray()
    
    //自定义目标的时候，三个参数
    var calories = ""
    var protein = ""
    var carbohydrates = ""
    var fats = ""
    
    var proteinNumber = ""
    var carbohydratesNumber = ""
    var fatsNumber = ""
    var caloriesNumber = ""
    var caloriesNumberFromServer = ""
    
    func printModelMsg() {
        DLLog(message: "性别：\(sex)")
        DLLog(message: "出生年份：\(birthDay)")
        DLLog(message: "目标：\(goal)")
        DLLog(message: "身高：\(height)")
        DLLog(message: "体重：\(weight)")
        DLLog(message: "目标体重：\(targetWeight)")
        DLLog(message: "节奏：\(paceLevel)")
        DLLog(message: "折线图开始日期：\(chartStartDate)")
        DLLog(message: "折线图结束日期：\(chartEndDate)")
        DLLog(message: "过敏忌口：\(foodAllergy)")
        DLLog(message: "饮食阻碍：\(foodBarrier)")
        DLLog(message: "食物偏好：\(foodTasteType)")
        DLLog(message: "饮食历史：\(dietHistoryType)")
        DLLog(message: "活动量：\(events)")
        DLLog(message: "体脂肪：\(bodyFat)")
        DLLog(message: "每日餐数：\(mealsPerDay)")
        DLLog(message: "计划时长：\(planWeeks)周")
        DLLog(message: "单日食物种类：\(dailyfoodsqty)")
        DLLog(message: "************   食物   ***************")
        DLLog(message: "蛋白质：\(foodsMsgProteins)")
        DLLog(message: "碳水：\(foodsMsgCarbohydrates)")
        DLLog(message: "脂肪：\(foodsMsgFats)")
        DLLog(message: "蔬菜：\(foodsMsgVegetables)")
        DLLog(message: "水果：\(foodsMsgFrutis)")
    }
    func dealFoodsMsg(dataArr:NSArray) {
        foodsMsgProteins.removeAllObjects()
        foodsMsgCarbohydrates.removeAllObjects()
        foodsMsgFats.removeAllObjects()
        foodsMsgVegetables.removeAllObjects()
        foodsMsgFrutis.removeAllObjects()
        for i in 0..<dataArr.count{
            let dict = dataArr[i]as? NSDictionary ?? [:]
            
            if dict["type"]as? String ?? "" == "1"{//蛋白质
                foodsMsgProteins.add(dict)
            }else if dict["type"]as? String ?? "" == "2"{//碳水
                foodsMsgCarbohydrates.add(dict)
            }else if dict["type"]as? String ?? "" == "3"{//脂肪
                foodsMsgFats.add(dict)
            }else if dict["type"]as? String ?? "" == "4"{//蔬菜
                foodsMsgVegetables.add(dict)
            }else if dict["type"]as? String ?? "" == "5"{//水果
                foodsMsgFrutis.add(dict)
            }
        }
    }
    func clearMsg() {
        self.name = ""
        self.sex = ""
        self.birthDay = ""
        self.goal = ""
        self.height = ""
        self.weight = ""
        self.targetWeight = ""
        self.paceLevel = "steady"
        self.chartStartDate = Date()
        self.chartEndDate = Calendar.current.date(byAdding: .day, value: 14, to: self.chartStartDate) ?? self.chartStartDate
        self.foodAllergy = ""
        self.foodBarrier = ""
        self.foodTasteType = ""
        self.dietHistoryType = ""
        self.events = ""
        self.bodyFat = ""
        self.mealsPerDay = ""
        self.planWeeks = ""
        self.dailyfoodsqty = "2"
        self.foodsMsgProteins.removeAllObjects()
        self.foodsMsgCarbohydrates.removeAllObjects()
        self.foodsMsgFats.removeAllObjects()
        self.foodsMsgVegetables.removeAllObjects()
        self.foodsMsgFrutis.removeAllObjects()
    }
}
