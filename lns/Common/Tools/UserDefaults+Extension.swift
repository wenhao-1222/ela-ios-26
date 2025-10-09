//
//  UserDefaults+Extension.swift
//  MCAPI
//
//  Created by MC on 2018/11/26.
//

import Foundation
import UIKit
public extension UserDefaults {
    enum AccountKeys: String {
        case hidsoryFoodsAdd
        case nutritionDefault
        case nutritionDefaultArray
        case circleGoalArray//碳循环目标
        case myFoodsList
        case bodyDataSetting
        case bodyData_Weight_Authori //是否请求过健康APP 体重的权限
        case health_sport_Authori //是否请求过健康APP 体能训练的权限
        case health_sport_natural //是否请求过健康APP 营养元素的权限
        case health_sport_natural_calories //是否请求过健康APP 膳食能量的权限
        case health_waist_Authori //是否请求过健康APP 体重的权限
        case health_water_Authori //是否请求过健康APP 饮水的权限
        
        case delete_sport_uuids  //APP内删除过的体能训练数据uuid
        case delete_weight_date  //APP内删除过的体重数据sdate
        case mealsNumber
        case isShowSurveryButton
        case isShowLogsTime
        case isShowLogsRemainCalories
        case weightUnit
        case todayGoal
        case sportData
        case forumListData
        case forumNoticeListData
        case canChoiceVideo
        case forumLocalId
        case isShowAiTipsAlert //是否展示过Ai识别的功能介绍
        case aiFoodsSyn   //AI识别的食物，是否保存到我的食物
        case noticeTapIds //已点击过的公告id
        case water_history_array //最近添加过的饮水量  3个数据
        case water_alert_times //喝水提醒时间列表
        case push_authori_second_foods //已提示过第二餐推送权限
        case isTapTodayNutrion //是否点击过今日营养分析按钮
        case jounal_meal_advice//日志-下一餐饮食建议
        case fitness_label_array//训练部位数据
        case splash_material_list //启动页广告物料列表
    }
}

class NutritionModel: NSObject {
    var calories = "0"
    var carbohydrates = "0"
    var fats = "0"
    var proteins = "0"
}

public protocol UserDefaultsSettable {
    associatedtype defaultKeys: RawRepresentable
}

extension UserDefaults {
    static public func set(value: Any, forKey key: AccountKeys) {
        let aKey = key.rawValue
        UserDefaults.standard.set(value, forKey: aKey)
    }
    
    func getNutritionModel() -> NutritionModel{
        let model = NutritionModel()
        
        let msgString = UserDefaults.getString(forKey: .nutritionDefault) ?? ""
//        DLLog(message: "msgString:\(msgString)")
        if msgString.count > 0 {
            let msgDict = WHUtils.getDictionaryFromJSONString(jsonString: msgString)
            model.calories = msgDict.stringValueForKey(key: "calories")
            model.carbohydrates = msgDict.stringValueForKey(key: "carbohydrates")
            model.proteins = msgDict.stringValueForKey(key: "proteins")
            model.fats = msgDict.stringValueForKey(key: "fats")
        }
        
        return model
    }
    func updateBodyDataSetting(type:DATA_TYPE,isSelect:String) {
        let bodyDataDict = UserDefaults.getDictionary(forKey: .bodyDataSetting)
        var dic:[String:String] = ["shoulder":"0",
                                   "bust":"0",
                                   "thigh":"0",
                                   "calf":"0",
                                   "bfp":"0"]
        
        if (bodyDataDict?["shoulder"]as? String ?? "").count > 0 {
            dic = bodyDataDict as! [String:String]
        }
        switch type {
        case DATA_TYPE.shoulder:
            dic.updateValue("\(isSelect)", forKey: "shoulder")
        case DATA_TYPE.bust:
            dic.updateValue("\(isSelect)", forKey: "bust")
        case DATA_TYPE.thigh:
            dic.updateValue("\(isSelect)", forKey: "thigh")
        case DATA_TYPE.calf:
            dic.updateValue("\(isSelect)", forKey: "calf")
        case DATA_TYPE.bfp:
            dic.updateValue("\(isSelect)", forKey: "bfp")
        default:
            break
        }
        UserDefaults.set(value: dic, forKey: .bodyDataSetting)
    }
    func getBodyDataSetting() -> NSDictionary {
        let bodyDataDict = UserDefaults.getDictionary(forKey: .bodyDataSetting)
        var dic:[String:String] = ["shoulder":"0",
                                   "bust":"0",
                                   "thigh":"0",
                                   "calf":"0",
                                   "bfp":"0"]
        
        if (bodyDataDict?["shoulder"]as? String ?? "").count > 0 {
            dic = bodyDataDict as! [String:String]
        }
        
        return dic as NSDictionary
    }
    static public func getString(forKey key: AccountKeys) -> String? {
        let aKey = key.rawValue
        let value = UserDefaults.standard.string(forKey: aKey)
        return value
    }
    
    static public func getArray(forKey key: AccountKeys) -> [Any]? {
        let aKey = key.rawValue
        
        let value = UserDefaults.standard.array(forKey: aKey)
        
        return value
    }
    
    static public func getDictionary(forKey key: AccountKeys) -> [String:Any]? {
        let aKey = key.rawValue
        
        let value = UserDefaults.standard.dictionary(forKey: aKey)
        return value
    }
    static public func saveFoods(foodsDict:NSDictionary ,forKey key: AccountKeys? = .hidsoryFoodsAdd){
        var foodsArray = NSMutableArray.init(array: getHistoryFoods())
        
        if key == .myFoodsList{
            foodsArray = NSMutableArray.init(array: getMyFoods())
        }
        
//        let num = foodsArray.count >= 20 ? 20 : foodsArray.count
        
        var hasFoods = false
//        for i in 0..<num{
        for i in 0..<foodsArray.count{
            let dict = foodsArray[i]as? NSDictionary ?? [:]
            
            if dict.stringValueForKey(key: "fname").count > 0 {
                if dict.stringValueForKey(key: "fname") == foodsDict.stringValueForKey(key: "fname") {
                    foodsArray.removeObject(at: i)
                    foodsArray.insert(foodsDict, at: 0)
                    hasFoods = true
                    break
                }
            }else{
                let foods = dict["foods"]as? NSDictionary ?? [:]
                if foods.stringValueForKey(key: "fname") == foodsDict.stringValueForKey(key: "fname") {
                    foodsArray.removeObject(at: i)
                    foodsArray.insert(foodsDict, at: 0)
                    hasFoods = true
                    break
                }
            }
        }
        
        if hasFoods == false{
            foodsArray.insert(foodsDict, at: 0)
        }
        
//        if foodsArray.count > 20 {
//            foodsArray.removeLastObject()
//        }
        
        set(value: WHUtils.getJSONStringFromArray(array: foodsArray), forKey: key ?? .hidsoryFoodsAdd)
    }
    
    static public func delFoods(foodsDict:NSDictionary,forKey key: AccountKeys? = .hidsoryFoodsAdd){
        var foodsArray = NSMutableArray.init(array: getHistoryFoods())
        
        if key == .myFoodsList{
            foodsArray = NSMutableArray.init(array: getMyFoods())
        }
        let num = foodsArray.count
        
        var hasFoods = false
        for i in 0..<num{
            let dict = foodsArray[i]as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "fid") == foodsDict.stringValueForKey(key: "fid") {
                foodsArray.removeObject(at: i)
                break
            }
        }
//        if key == .hidsoryFoodsAdd && foodsArray.count > 20 {
//            foodsArray.removeLastObject()
//        }
        
        set(value: WHUtils.getJSONStringFromArray(array: foodsArray), forKey: key ?? .hidsoryFoodsAdd)
    }
    static public func getSportData() -> NSArray{
        let data = self.getString(forKey: .sportData) ?? ""
        let array = WHUtils.getArrayFromJSONString(jsonString: data)
        
        if array.count > 0 {
            return array
        }
        return NSArray()
    }
    static public func getHistoryFoods() -> NSArray{
        let foods = self.getString(forKey: .hidsoryFoodsAdd) ?? ""
        let foodsArray = WHUtils.getArrayFromJSONString(jsonString: foods)
        
        if foodsArray.count > 0 {
            return foodsArray
        }
        return NSArray()
    }
    static public func getMyFoods() -> NSArray{
        let foods = self.getString(forKey: .myFoodsList) ?? ""
//        let foodsArray = self.getArray(forKey: .myFoodsList) ?? []
        let foodsArray = WHUtils.getArrayFromJSONString(jsonString: foods)
        
        if foodsArray.count > 0 {
            return foodsArray as NSArray
        }
        
        return NSArray()
    }
    static public func getTodayGoal() -> NSDictionary?{
        return self.getDictionary(forKey: .todayGoal) as NSDictionary?
    }
    static public func getMealsNumber() -> Int{
        let num = self.getString(forKey: .mealsNumber) ?? ""
        
        if num == "" || num.count == 0 {
            return 6
        }
        
        return num.intValue
    }
    static public func getSurveryStatus() -> Bool{
        return true
//        let num = self.getString(forKey: .isShowSurveryButton) ?? ""
//        
//        if num == "" || num.count == 0 || num == "1"{
//            return false
//        }
//        
//        return true
    }
    static public func getAISynFoods() -> Bool{
        let num = self.getString(forKey: .aiFoodsSyn) ?? ""
        
        if num == "" || num.count == 0 || num == "1"{
            return true
        }
        
        return false
    }
    
    static public func getLogsTimeStatus() -> Bool{
        let num = self.getString(forKey: .isShowLogsTime) ?? ""
        
        if num == "" || num.count == 0 || num == "1"{
            return false
        }
        
        return true
    }
    static public func initWeightUnit(){
        let num = self.getString(forKey: .weightUnit) ?? ""
        
        if num == "2"{
            UserInfoModel.shared.weightUnit = 2
            UserInfoModel.shared.weightUnitName = "斤"
            UserInfoModel.shared.weightCoefficient = 2.0
        } else if num == "3"{
            UserInfoModel.shared.weightUnit = 3
            UserInfoModel.shared.weightUnitName = "磅"
            UserInfoModel.shared.weightCoefficient = 2.2046226
        }else {
            UserInfoModel.shared.weightUnit = 1
            UserInfoModel.shared.weightUnitName = "kg"
            UserInfoModel.shared.weightCoefficient = 1.0
            
        }
    }
    static public func deleteSportUUID(uuid:String) {
        let uuids = self.getString(forKey: .delete_sport_uuids) ?? ""
        let uuidsArray = NSMutableArray(array: WHUtils.getArrayFromJSONString(jsonString: uuids))
        uuidsArray.add(uuid)
        
        self.set(value: WHUtils.getJSONStringFromArray(array: uuidsArray), forKey: .delete_sport_uuids)
    }
    static public func getSportUUID() -> NSArray{
        let uuids = self.getString(forKey: .delete_sport_uuids) ?? ""

        let uuidsArray = WHUtils.getArrayFromJSONString(jsonString: uuids)
        
        if uuidsArray.count > 0 {
            return uuidsArray as NSArray
        }
        
        return NSArray()
    }
    static public func deleteWeightDate(sdate:String) {
        let dates = self.getString(forKey: .delete_weight_date) ?? ""
        let sdatesArray = NSMutableArray(array: WHUtils.getArrayFromJSONString(jsonString: dates))
        sdatesArray.add(sdate)
        
        self.set(value: WHUtils.getJSONStringFromArray(array: sdatesArray), forKey: .delete_weight_date)
    }
    static public func getWeightSdate() -> NSArray{
        let dates = self.getString(forKey: .delete_weight_date) ?? ""

        let sdatesArray = WHUtils.getArrayFromJSONString(jsonString: dates)
        
        if sdatesArray.count > 0 {
            return sdatesArray as NSArray
        }
        
        return NSArray()
    }
    static func setNoticeTapId(idT:String){
        let ids = NSMutableArray(array: self.getTapNoticeIds())
        for i in 0..<ids.count{
            let id = ids[i]as? String ?? ""
            if id == idT{
                return
            }
        }
        ids.add(idT)
        
        self.set(value: WHUtils.getJSONStringFromArray(array: ids), forKey: .noticeTapIds)
    }
    static func getTapNoticeIds() -> NSArray {
        let idsString = self.getString(forKey: .noticeTapIds) ?? ""
        let ids = WHUtils.getArrayFromJSONString(jsonString: idsString)
        
        if ids.count > 0 {
            return ids as NSArray
        }
        return NSArray()
    }
    ///保存本次课程播放记录
    static func setCourseMsg(dict:NSDictionary){
        let msgArray = NSMutableArray(array: getCourseMsg())
        
        for i in 0..<msgArray.count{
            let lastDict = msgArray[i]as? NSDictionary ?? [:]
            if lastDict.stringValueForKey(key: "parentId") == dict.stringValueForKey(key: "parentId"){
                msgArray.removeObject(at: i)
                break
            }
        }
        msgArray.add(dict)
        
        UserDefaults.standard.set(msgArray, forKey: "\(UserInfoModel.shared.uId)_couseLastMsg")
    }
    static func getCourseMsg() -> NSArray{
        let arr = UserDefaults.standard.array(forKey: "\(UserInfoModel.shared.uId)_couseLastMsg") as? NSArray ?? []
        
        return arr//UserDefaults.standard.array(forKey: "\(UserInfoModel.shared.uId)_couseLastMsg")! as NSArray
    }
    static func setWaterRecord(num:String){//默认值：200 350 550
        let dataArr = NSMutableArray(array: self.getArray(forKey: .water_history_array) ?? ["200","350","550"])
        for i in 0..<dataArr.count{
            let numString = dataArr[i] as? String ?? ""
            if numString == num{
                return
            }
        }
        dataArr.removeLastObject()
        dataArr.insert(num, at: 0)
        UserDefaults.standard.set(dataArr, forKey: "water_history_array")
    }
    static func getWaterRecord() -> [String]{
        return self.getArray(forKey: .water_history_array) as? [String] ?? ["200","350","550"]
    }
    
    static func setWaterAlerts(times:[String]){
        UserDefaults.standard.set(times, forKey: AccountKeys.water_alert_times.rawValue)
    }

    static func getWaterAlerts() -> [String]{
        return UserDefaults.standard.array(forKey: AccountKeys.water_alert_times.rawValue) as? [String] ?? []
    }
    static func getAllBodyDataIsLoad() -> Bool{
        let result = UserDefaults.standard.string(forKey: "\(UserInfoModel.shared.uId)_isLoadAllBodyData")
        if result?.count ?? 0 > 0 {
            return true
        }
        return false
    }
    static func setAllBodyDataIsLoad(){
        UserDefaults.standard.set("1", forKey: "\(UserInfoModel.shared.uId)_isLoadAllBodyData")
    }
    static func removeAllBodyDataLoadFlag(uid:String){
        UserDefaults.standard.removeObject(forKey: "\(uid)_isLoadAllBodyData")
    }
    
    // MARK: - Splash Material
    static func setSplashMaterials(_ array: NSArray){
        let json = WHUtils.getJSONStringFromArray(array: array)
        UserDefaults.set(value: json, forKey: .splash_material_list)
    }

    static func getSplashMaterials() -> NSArray {
        let json = UserDefaults.getString(forKey: .splash_material_list) ?? ""
        return WHUtils.getArrayFromJSONString(jsonString: json)
    }
}

