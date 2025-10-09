//
//  NutritionDefaultModel.swift
//  lns
//
//  Created by LNS2 on 2024/8/5.
//

import Foundation

class NutritionDefaultModel {
    
    static let shared = NutritionDefaultModel()
    
    private init(){
        
    }
    
    var weekday = ""
    var calories = ""
    var carbohydrate = ""
    var fat = ""
    var protein = ""
}

extension NutritionDefaultModel{
    func getDefaultGoal(weekDay:Int) {
        let msgString = UserDefaults.getString(forKey: .nutritionDefaultArray) ?? ""
        var dict = NSDictionary()
        if msgString.count > 4{
            let msgArray = NSMutableArray.init(array: WHUtils.getArrayFromJSONString(jsonString: msgString))
            
            if msgArray.count > weekDay-1{
                dict = msgArray[weekDay-1]as? NSDictionary ?? [:]
            }else{
                let msgStr = UserDefaults.getString(forKey: .nutritionDefault) ?? ""
                dict = WHUtils.getDictionaryFromJSONString(jsonString: msgStr)
            }
        }else{
            let msgStr = UserDefaults.getString(forKey: .nutritionDefault) ?? ""
            dict = WHUtils.getDictionaryFromJSONString(jsonString: msgStr)
        }
        self.calories = "\(Int(dict.doubleValueForKey(key: "calories")))"
        self.carbohydrate = "\(Int(dict.doubleValueForKey(key: "carbohydrates")))"
        self.protein = "\(Int(dict.doubleValueForKey(key: "proteins")))"
        self.fat = "\(Int(dict.doubleValueForKey(key: "fats")))"
    }
    func getTodayGoal() -> NSDictionary{
        let weekDay = Date().getWeekdayIndex(from: Date().nextDay(days: 0))
        let msgString = UserDefaults.getString(forKey: .nutritionDefaultArray) ?? ""
        var dict = NSDictionary()
        if msgString.count > 4{
            let msgArray = NSMutableArray.init(array: WHUtils.getArrayFromJSONString(jsonString: msgString))
            
            if msgArray.count > weekDay-1{
                dict = msgArray[weekDay-1]as? NSDictionary ?? [:]
            }else{
                let msgStr = UserDefaults.getString(forKey: .nutritionDefault) ?? ""
                dict = WHUtils.getDictionaryFromJSONString(jsonString: msgStr)
            }
        }else{
            let msgStr = UserDefaults.getString(forKey: .nutritionDefault) ?? ""
            dict = WHUtils.getDictionaryFromJSONString(jsonString: msgStr)
        }
        
        return dict
    }
    func saveGoal(dict:NSDictionary,weekDay:Int){
        let msgString = UserDefaults.getString(forKey: .nutritionDefaultArray) ?? ""
        
        if msgString.count > 0 {
            let msgArray = NSMutableArray.init(array: WHUtils.getArrayFromJSONString(jsonString: msgString))
            
            if msgArray.count > weekDay-1{
                msgArray.replaceObject(at: weekDay-1, with: dict)
            }
            UserDefaults.set(value: WHUtils.getJSONStringFromArray(array: msgArray), forKey: .nutritionDefaultArray)
        }else{
            let msgStr = UserDefaults.getString(forKey: .nutritionDefault) ?? ""

            if msgStr.count > 0 {
                let msgDict = WHUtils.getDictionaryFromJSONString(jsonString: msgStr)
                let dataArray = NSMutableArray()
                for i in 0..<7{
                    if i == weekDay - 1{
                        dataArray.add(dict)
                    }else{
                        let dictDefault = ["weekday":"\(i+1)",
                                    "calories":"\(msgDict.stringValueForKey(key: "calories"))",
                                    "carbohydrates":"\(msgDict.stringValueForKey(key: "carbohydrates"))",
                                    "proteins":"\(msgDict.stringValueForKey(key: "proteins"))",
                                    "fats":"\(msgDict.stringValueForKey(key: "fats"))"]
                        dataArray.add(dictDefault)
                    }
                }
                UserDefaults.set(value: WHUtils.getJSONStringFromArray(array: dataArray), forKey: .nutritionDefaultArray)
            }else{
                saveGoals(dict: dict)
            }
        }
    }
    func saveGoals(dict:NSDictionary) {
        let dataArray = NSMutableArray()
        for i in 0..<7{
            let dictDefault = ["weekday":"\(i+1)",
                        "calories":"\(dict.stringValueForKey(key: "calories"))",
                        "carbohydrates":"\(dict.stringValueForKey(key: "carbohydrates"))",
                        "proteins":"\(dict.stringValueForKey(key: "proteins"))",
                        "fats":"\(dict.stringValueForKey(key: "fats"))"]
            dataArray.add(dictDefault)
        }
        UserDefaults.set(value: WHUtils.getJSONStringFromArray(array: dataArray), forKey: .nutritionDefaultArray)
    }
}
