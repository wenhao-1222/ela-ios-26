//
//  WidgetUtils.swift
//  lns
//
//  Created by LNS2 on 2024/8/14.
//

import Foundation
import UIKit
import WidgetKit

enum natural_type {
    case calories
    case carbo
    case protein
    case fat
}

class WidgetUtils {
//    public static var neesPostRequest = true
    //手动刷新
    public static var isManual = false
    //上次小组件刷新的时间戳   初始化的时候，当前时间往前推10分钟
    public static var lastRefreshTimeStamp = (Int(Date().timeStamp)!)-10*60
    
    func saveMealsData(mealsIndex:Int) {
        let userDefault = UserDefaults(suiteName: "group.ElaNaturalCircleWidget")
        userDefault?.setValue("\(mealsIndex)", forKey: "NaturalMealsIndexForWidget")
        userDefault?.synchronize()
    }
    func readMealsData() -> Int {
        let userDefault = UserDefaults(suiteName: "group.ElaNaturalCircleWidget")
        let mealsString = userDefault?.value(forKey: "NaturalMealsIndexForWidget") as? String ?? "-5"
        return Int(mealsString) ?? -2
    }
    
    func saveNaturalData(dict:NSDictionary) {
        let userDefault = UserDefaults(suiteName: "group.ElaNaturalCircleWidget")
        userDefault?.setValue(dict, forKey: "NaturalDataForWidget")
        userDefault?.synchronize()
    }
    func readNaturalData() -> NSDictionary {
        let userDefault = UserDefaults(suiteName: "group.ElaNaturalCircleWidget")
        return userDefault?.value(forKey: "NaturalDataForWidget") as? NSDictionary ?? [:]
    }
    func saveSportInTargetStatus(status:String) {
        let userDefault = UserDefaults(suiteName: "group.ElaNaturalCircleWidget")
        userDefault?.setValue(status, forKey: "sportInTargetStatus")
        userDefault?.synchronize()
    }
    func readSportInTargetStatus() -> String {
        let userDefault = UserDefaults(suiteName: "group.ElaNaturalCircleWidget")
        return userDefault?.value(forKey: "sportInTargetStatus") as? String ?? ""
    }
    func readNaturalDataDefault() -> NSDictionary {
        return ["caloriTar":"3040",
                "proteinTar":"290",
                "carboTar":"290",
                "fatsTar":"80",
                "calori":"2409",
                "protein":"188",
                "carbohydrates":"241",
                "fats":"77",
                "sdate":Date().nextDay(days: 0)]
    }
    
    func saveUserInfo(uId:String,uToken:String) {
        let userDefault = UserDefaults(suiteName: "group.ElaNaturalCircleWidget")
        userDefault?.setValue(uId, forKey: "user_id")
        userDefault?.setValue(uToken, forKey: "token_lns")
        userDefault?.synchronize()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            WidgetUtils.isManual = true
            WidgetUtils.lastRefreshTimeStamp = (Int(Date().timeStamp)!)-10*60
            WidgetUtils().sendNaturalLast7Days(forNaturalType: 10)
            WidgetCenter.shared.reloadAllTimelines()
        })
    }
    
    func getUserInfoUid() -> String {
        let userDefault = UserDefaults(suiteName: "group.ElaNaturalCircleWidget")
        return userDefault?.value(forKey: "user_id") as? String ?? ""
    }
    func getUserInfoUToken() -> String {
        let userDefault = UserDefaults(suiteName: "group.ElaNaturalCircleWidget")
        return userDefault?.value(forKey: "token_lns") as? String ?? ""
    }
    
    func saveCurrentDayMealsNaturalMsg(dataArray:NSArray) {
        let userDefault = UserDefaults(suiteName: "group.ElaNaturalCircleWidget")
        userDefault?.setValue(dataArray, forKey: "CurrentDayMealsData")
        userDefault?.synchronize()
        
//        print("saveCurrentDayMealsNaturalMsg:\(dataArray)")
    }
    func readCurrentDayMealsMsg() -> NSArray {
        let userDefault = UserDefaults(suiteName: "group.ElaNaturalCircleWidget")
        let arr = userDefault?.value(forKey: "CurrentDayMealsData") as? NSArray ?? []
        
//        print("readCurrentDayMealsMsg:\(arr)")
        if arr.count == 6 {
            return arr
        }else{
            return [[],[],[],[],[],[]]
        }
    }
    func readCurrentDayMealsMsgDefault() -> NSArray {
        return [["isEat":"1"],["isEat":"1"],["isEat":"1"],["isEat":"1"],["isEat":"1"],[]]
    }
    func saveLast7DaysNaturalMsg(dataArray:NSArray) {
        let userDefault = UserDefaults(suiteName: "group.ElaNaturalCircleWidget")
        userDefault?.setValue(dataArray, forKey: "Last7DaysNaturalData")
        userDefault?.synchronize()
    }
    func readLast7DaysNaturalMsg() -> NSArray {
        let userDefault = UserDefaults(suiteName: "group.ElaNaturalCircleWidget")
        let arr = userDefault?.value(forKey: "Last7DaysNaturalData") as? NSArray ?? []
        
//        print("readCurrentDayMealsMsg:\(arr)")
        if arr.count == 7 {
            return arr
        }else{
            return []
        }
    }
    
    func getNaturalDataArrayDefault(type:natural_type) -> NSDictionary {
        let results = NSMutableArray()
        var maxValue = Int(0)
        
        let array = [["calories":3162,"carbohydrate":260,"protein":301,"fat":102],
                     ["calories":2504,"carbohydrate":228,"protein":245,"fat":68],
                     ["calories":3204,"carbohydrate":304,"protein":299,"fat":88],
                     ["calories":2771,"carbohydrate":301,"protein":241,"fat":67],
                     ["calories":2724,"carbohydrate":298,"protein":221,"fat":72],
                     ["calories":4148,"carbohydrate":450,"protein":173,"fat":184],
                     ["calories":2409,"carbohydrate":241,"protein":188,"fat":77]]
        
        for i in 0..<array.count{
            let dict = array[i]as NSDictionary
            var value = Int(0)
            switch type {
            case .calories:
                value = Int(dict.doubleValueForKeyWidget(key: "calories").rounded())
            case .carbo:
                value = Int(dict.doubleValueForKeyWidget(key: "carbohydrate").rounded())
            case .protein:
                value = Int(dict.doubleValueForKeyWidget(key: "protein").rounded())
            case .fat:
                value = Int(dict.doubleValueForKeyWidget(key: "fat").rounded())
            }
            
            var weekdDay = "一"
            
            if i == 1 {
                weekdDay = "二"
            }else if i == 2{
                weekdDay = "三"
            }else if i == 3{
                weekdDay = "四"
            }else if i == 4{
                weekdDay = "五"
            }else if i == 5{
                weekdDay = "六"
            }else if i == 6{
                weekdDay = "日"
            }
            
            results.add(["weekday":"\(weekdDay)",
                         "value":"\(value)"])
//            results.add(["weekday":"\(self.getWeekDaysText(date: Date().nextDay(days: i-6)))",
//                         "value":"\(value)"])
            if value > maxValue {
                maxValue = value
            }
        }
        
        return ["data":results,
                "maxValue":"\(maxValue)"]
    }
    
    func getNaturalDataArray(type:natural_type) -> NSDictionary {
        let array = self.readLast7DaysNaturalMsg()
        let results = NSMutableArray()
        
        //用户退出登录的情况下
        if array.count == 0 {
            for i in 0..<7{
                let dict = ["weekday":"\(self.getWeekDaysText(date: Date().nextDay(days: i-6)))",
                            "value":"0"]
                results.add(dict)
            }
            
            return ["data":results,
                    "maxValue":"100"]
        }
        
        var maxValue = Int(0)
        
        for i in 0..<array.count{
            let dict = array[i]as? NSDictionary ?? [:]
            var value = Int(0)
            
            switch type {
            case .calories:
                value = Int(dict.doubleValueForKeyWidget(key: "calories").rounded())
//                results.add(["weekday":"\(dict.stringValueForKeyWidget(key: "weekday"))",
//                             "value":"\(Int(dict.doubleValueForKeyWidget(key: "calories").rounded()))"])
            case .carbo:
                value = Int(dict.doubleValueForKeyWidget(key: "carbohydrate").rounded())
            case .protein:
                value = Int(dict.doubleValueForKeyWidget(key: "protein").rounded())
//                results.add(["weekday":"\(dict.stringValueForKeyWidget(key: "weekday"))",
//                             "value":"\(Int(dict.doubleValueForKeyWidget(key: "protein").rounded()))"])
            case .fat:
                value = Int(dict.doubleValueForKeyWidget(key: "fat").rounded())
//                results.add(["weekday":"\(dict.stringValueForKeyWidget(key: "weekday"))",
//                             "value":"\(Int(dict.doubleValueForKeyWidget(key: "fat").rounded()))"])
            }
            
            
            results.add(["weekday":"\(dict.stringValueForKeyWidget(key: "weekday"))",
                         "value":"\(value)"])
            
            if value > maxValue {
                maxValue = value
            }
            
            
//            var carboValue = Int(0)
//            var proteinValue = Int(0)
//            var fatValue = Int(0)
//            
//            carboValue = Int(dict.doubleValueForKeyWidget(key: "carbohydrate").rounded())
//            proteinValue = Int(dict.doubleValueForKeyWidget(key: "protein").rounded())
//            fatValue = Int(dict.doubleValueForKeyWidget(key: "fat").rounded())
//            
//            if carboValue > maxValue {
//                maxValue = carboValue
//            }
//            if proteinValue > maxValue {
//                maxValue = proteinValue
//            }
//            if fatValue > maxValue {
//                maxValue = fatValue
//            }
        }
        print("results:\(results)")
        return ["data":results,
                "maxValue":"\(maxValue)"]
    }
    
    func resetNetworkAllows(isAllow:String,mealsIndex:Int){
        let userDefault = UserDefaults(suiteName: "group.ElaNaturalCircleWidget")
        userDefault?.setValue("\(isAllow)", forKey: "resetNetworkAllows\(mealsIndex)")
        userDefault?.synchronize()
    }
    func readNetworkAllows(mealsIndex:Int) -> String {
        let userDefault = UserDefaults(suiteName: "group.ElaNaturalCircleWidget")
        return userDefault?.value(forKey: "resetNetworkAllows\(mealsIndex)") as? String ?? ""
    }
    func dealNaturalDataMeals(dataDict:NSDictionary){
        let dataArray = NSMutableArray()
        let serialQueue = DispatchQueue(label: "com.widget.calculate")
        let mealsArray = NSMutableArray(array: dataDict["foods"]as? NSArray ?? [])
        
        var calories = Double(0)
        var carbohydrates = Double(0)
        var proteins = Double(0)
        var fats = Double(0)
        
        serialQueue.async {
            for i in 0..<mealsArray.count{
                var caloriTotal = Double(0)
                var carboTotal = Double(0)
                var proteinTotal = Double(0)
                var fatTotal = Double(0)
                
                var isEat = "0"
                let mealPerArr = mealsArray[i]as? NSMutableArray ?? []
                for j in 0..<mealPerArr.count{
                    let dictTemp = mealPerArr[j]as? NSMutableDictionary ?? [:]
                    if dictTemp["state"]as? String ?? "\(dictTemp["state"]as? Int ?? 0)" == "1"{
                        let calori = Double(dictTemp["calories"]as? String ?? "\(dictTemp["calories"]as? Double ?? 0)") ?? 0
                        let carbohydrate = Double(dictTemp["carbohydrate"]as? String ?? "\(dictTemp["carbohydrate"]as? Double ?? 0)") ?? 0
                        let protein = Double(dictTemp["protein"]as? String ?? "\(dictTemp["protein"]as? Double ?? 0)") ?? 0
                        let fat = Double(dictTemp["fat"]as? String ?? "\(dictTemp["fat"]as? Double ?? 0)") ?? 0
                        
                        caloriTotal = caloriTotal + calori
                        carboTotal = carboTotal + carbohydrate
                        proteinTotal = proteinTotal + protein
                        fatTotal = fatTotal + fat
                        isEat = "1"
                    }
                    
                }
                let natuDict = ["calories":"\(caloriTotal)",
                                "carbohydrate":"\(carboTotal)",
                                "protein":"\(proteinTotal)",
                                "fat":"\(fatTotal)",
                                "isEat":"\(isEat)"]
                calories = calories + caloriTotal
                carbohydrates = carbohydrates + carboTotal
                proteins = proteins + proteinTotal
                fats = fats + fatTotal
                
                dataArray.add(natuDict)
            }
            
            self.saveCurrentDayMealsNaturalMsg(dataArray: dataArray)
        }
    }
    func dealCurrentMealsDataForWidget(mealsArray:NSArray) {
        let serialQueue = DispatchQueue(label: "com.logs.calculate")
        let dataArray = NSMutableArray()
        
        serialQueue.async {
            var caloriTotal = Double(0)
            var carboTotal = Double(0)
            var proteinTotal = Double(0)
            var fatTotal = Double(0)
            
            for i in 0..<mealsArray.count{
                var isEat = "0"
                let mealPerArr = mealsArray[i]as? NSMutableArray ?? []
                for j in 0..<mealPerArr.count{
                    let dictTemp = mealPerArr[j]as? NSMutableDictionary ?? [:]
                    if dictTemp.stringValueForKeyWidget(key: "state") == "1"{
                        let calori = dictTemp.doubleValueForKeyWidget(key: "calories")
                        let carbohydrate = dictTemp.doubleValueForKeyWidget(key: "carbohydrate")
                        let protein = dictTemp.doubleValueForKeyWidget(key: "protein")
                        let fat = dictTemp.doubleValueForKeyWidget(key: "fat")
                        
                        caloriTotal = caloriTotal + calori
                        carboTotal = carboTotal + carbohydrate
                        proteinTotal = proteinTotal + protein
                        fatTotal = fatTotal + fat
                        
                        dictTemp.setValue("\(String(format: "%.0f", dictTemp.doubleValueForKeyWidget(key: "calories").rounded()))".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                        
                        mealPerArr.replaceObject(at: j, with: dictTemp)
                        isEat = "1"
                    }
                }
                
                let natuDict = ["calories":"\(Int(caloriTotal.rounded()))",
                                "carbohydrate":"\(Int(carboTotal.rounded()))",
                                "protein":"\(Int(proteinTotal.rounded()))",
                                "fat":"\(Int(fatTotal.rounded()))",
                                "isEat":"\(isEat)"]
                
                dataArray.add(natuDict)
            }
            WidgetUtils().saveCurrentDayMealsNaturalMsg(dataArray: dataArray)
        }
        
    }
    func dealNaturalData(dataDict:NSDictionary){
        let dataArray = NSMutableArray()
        let serialQueue = DispatchQueue(label: "com.widget.calculate")
        let mealsArray = NSMutableArray(array: dataDict["foods"]as? NSArray ?? [])
        
        var calories = Double(0)
        var carbohydrates = Double(0)
        var proteins = Double(0)
        var fats = Double(0)
        
        serialQueue.async {
            for i in 0..<mealsArray.count{
                var caloriTotal = Double(0)
                var carboTotal = Double(0)
                var proteinTotal = Double(0)
                var fatTotal = Double(0)
                
                var isEat = "0"
                let mealPerArr = mealsArray[i]as? NSMutableArray ?? []
                for j in 0..<mealPerArr.count{
                    let dictTemp = mealPerArr[j]as? NSMutableDictionary ?? [:]
                    if dictTemp["state"]as? String ?? "\(dictTemp["state"]as? Int ?? 0)" == "1"{
                        let calori = Double(dictTemp["calories"]as? String ?? "\(dictTemp["calories"]as? Double ?? 0)") ?? 0
                        let carbohydrate = Double(dictTemp["carbohydrate"]as? String ?? "\(dictTemp["carbohydrate"]as? Double ?? 0)") ?? 0
                        let protein = Double(dictTemp["protein"]as? String ?? "\(dictTemp["protein"]as? Double ?? 0)") ?? 0
                        let fat = Double(dictTemp["fat"]as? String ?? "\(dictTemp["fat"]as? Double ?? 0)") ?? 0
                        
                        caloriTotal = caloriTotal + calori
                        carboTotal = carboTotal + carbohydrate
                        proteinTotal = proteinTotal + protein
                        fatTotal = fatTotal + fat
                        isEat = "1"
                    }
                    
                }
                let natuDict = ["calories":"\(caloriTotal)",
                                "carbohydrate":"\(carboTotal)",
                                "protein":"\(proteinTotal)",
                                "fat":"\(fatTotal)",
                                "isEat":"\(isEat)"]
                calories = calories + caloriTotal
                carbohydrates = carbohydrates + carboTotal
                proteins = proteins + proteinTotal
                fats = fats + fatTotal
                
                dataArray.add(natuDict)
            }
            
            self.saveCurrentDayMealsNaturalMsg(dataArray: dataArray)
            WidgetUtils().saveNaturalData(dict: ["caloriTar":dataDict.stringValueForKeyWidget(key: "caloriesden"),
                                                 "proteinTar":dataDict.stringValueForKeyWidget(key: "proteinden"),
                                                 "carboTar":dataDict.stringValueForKeyWidget(key: "carbohydrateden"),
                                                 "fatsTar":dataDict.stringValueForKeyWidget(key: "fatden"),
                                                 "calori":"\(Int(calories.rounded()))",
                                                 "protein":"\(Int(proteins.rounded()))",
                                                 "carbohydrates":"\(Int(carbohydrates.rounded()))",
                                                 "fats":"\(Int(fats.rounded()))",
                                                 "sportCalories":dataDict.stringValueForKeyWidget(key: "sportCalories"),
                                                 "sdate":dataDict.stringValueForKeyWidget(key: "sdate")])
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func dealLast7DayData(array:NSArray,type:Int) {
        self.saveLast7DaysNaturalMsg(dataArray: array)
        if type == 10{
            WidgetCenter.shared.reloadTimelines(ofKind: "ElaWeekCaloriesWidget")
        }else if type == 11{
            WidgetCenter.shared.reloadTimelines(ofKind: "ElaWeekCarboWidget")
        }else if type == 12{
            WidgetCenter.shared.reloadTimelines(ofKind: "ElaWeekProteinWidget")
        }else if type == 13{
            WidgetCenter.shared.reloadTimelines(ofKind: "ElaWeekFatWidget")
        }
    }
    
    func reloadWidgetData() {
        WidgetUtils.isManual = true
        WidgetUtils.lastRefreshTimeStamp = (Int(Date().timeStamp)!)-10*60
        WidgetUtils().sendNaturalLast7Days(forNaturalType: 10)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func sendNaturalDataRequest(meals:Int){
        let today = Date().nextDay(days: 0)
        let param = ["sdate":"\(today)"]
//        print("sendNaturalDataRequest param:\(param)")
        WidgetNetWorkUtil.shareManager().POST(urlString: URL_User_logs_detail, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = self.getDictionaryFromJSONString(jsonString: dataString ?? "")
//            print("sendNaturalDataRequest:\(dataObj)")
            
            self.dealNaturalData(dataDict: dataObj)
        }
    }
    func sendNaturalLast7Days(forNaturalType:Int) {
        let uId = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: WidgetUtils().getUserInfoUid())
        print("uId:\(uId ?? "**")**")
        if uId == "" || uId?.count == 0 {
            //退出登录的情况下，数据清零
            print("uId:退出登录的情况下，数据清零")
            self.saveLast7DaysNaturalMsg(dataArray:[])
            self.dealNaturalData(dataDict: [:])
            return
        }
        let meals = forNaturalType
        let today = Date().nextDay(days: 0)
        let param = ["sdate":"\(today)"]
//        print("sendNaturalLast7Days param:\(param)")
        WidgetNetWorkUtil.shareManager().POST(urlString: URL_User_logs_last7Days, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = self.getArrayFromJSONString(jsonString: dataString ?? "")
//            print("sendNaturalLast7Days:\(dataArray)")
            
//            self.dealLast7DayData(array: dataArray,type: meals)
            self.saveLast7DaysNaturalMsg(dataArray: dataArray)
            self.sendNaturalDataRequest(meals:meals)
        }
    }
}

extension WidgetUtils{
    //JSONString转换为字典
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        let jsonData:Data = jsonString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    //JSONString转换为数组
    func getArrayFromJSONString(jsonString:String) ->NSArray{
        if jsonString == "" || !jsonString.contains("["){
            return []
        }
//        DLLog(message: "jsonString : \(jsonString)")
        let jsonData:Data = jsonString.data(using: .utf8)!
        let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if array != nil {
            return array as! NSArray
        }
        return array as! NSArray
    }
    private func getWeekDaysText(date:String) -> String{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"// 自定义时间格式
        dateformatter.calendar = Calendar.init(identifier: .gregorian)
        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")
        let dateT = dateformatter.date(from: date) ?? Date()
        
        let weekIndex = Date().getWeekdayIndex(from: dateT)
//        DLLog(message: "weekIndex:  --- \(weekIndex)")
        if weekIndex == 1 {
            return "一"
        }else if weekIndex == 2 {
            return "二"
        }else if weekIndex == 3 {
            return "三"
        }else if weekIndex == 4 {
            return "四"
        }else if weekIndex == 5 {
            return "五"
        }else if weekIndex == 6 {
            return "六"
        }else{
            return "日"
        }
    }
}
