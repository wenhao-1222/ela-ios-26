//
//  LogsSQLiteUploadManager.swift
//  lns
//
//  Created by LNS2 on 2024/8/9.
//

import Foundation
import WidgetKit

class LogsSQLiteUploadManager {
    private static let uploadSyncQueue = DispatchQueue(label: "com.lns.logs.upload.sync")
    private static var pendingUploadWorkItems: [String: DispatchWorkItem] = [:]
    private static var uploadingDates = Set<String>()
    private static var queuedDates = Set<String>()
    private static var uploadQueueGeneration = 0
    
    ///检查本地日志   饮水量上传状态
    func checkWaterDataUploadStatus() {
        let logsWaterDataArray = LogsSQLiteManager.getInstance().queryTableAllWaterData()
        for i in 0..<logsWaterDataArray.count{
            let dict = logsWaterDataArray[i]as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "waterUpload") != "1"{
                sendWaterSynRequest(dict: dict)
            }
        }
    }
    ///检查本地日志上传状态
    func checkDataUploadStatus() {
        let logsDataArray = LogsSQLiteManager.getInstance().queryTableAll()
        
        for i in 0..<logsDataArray.count{
            let dict = logsDataArray[i]as? NSDictionary ?? [:]
            if dict["isUpload"]as? Bool ?? true == false{
                DLLog(message: "checkDataUploadStatus:\(dict.stringValueForKey(key: "sdate"))")
                dealLogsDataForUpload(dict: dict)
            }
        }
    }
    
    func scheduleUploadLogsBySDate(sdate: String, delay: TimeInterval = 1.0) {
        Self.uploadSyncQueue.async {
            Self.queuedDates.insert(sdate)
            Self.pendingUploadWorkItems[sdate]?.cancel()
            let generation = Self.uploadQueueGeneration
            
            let workItem = DispatchWorkItem { [self] in
                self.startQueuedUploadIfNeededOnSyncQueue(sdate: sdate, generation: generation)
            }
            
            Self.pendingUploadWorkItems[sdate] = workItem
            Self.uploadSyncQueue.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }
    
    func clearUploadQueue() {
        Self.uploadSyncQueue.async {
            Self.uploadQueueGeneration += 1
            Self.pendingUploadWorkItems.values.forEach { $0.cancel() }
            Self.pendingUploadWorkItems.removeAll()
            Self.queuedDates.removeAll()
            Self.uploadingDates.removeAll()
        }
    }

    func uploadLogsBySDate(sdate:String, shouldRefreshTodayJournal: Bool = true, completion: (() -> Void)? = nil) {
        let logsDict = LogsSQLiteManager.getInstance().queryLogsData(sdata: sdate)
        if logsDict["isUpload"]as? Bool ?? true == false{
            dealLogsDataForUpload(dict: logsDict, shouldRefreshTodayJournal: shouldRefreshTodayJournal, completion: completion)
        } else {
            completion?()
        }
    }

    private func startQueuedUploadIfNeededOnSyncQueue(sdate: String, generation: Int) {
        Self.pendingUploadWorkItems.removeValue(forKey: sdate)

        guard generation == Self.uploadQueueGeneration else {
            return
        }
        
        guard Self.queuedDates.contains(sdate) else {
            return
        }
        
        guard Self.uploadingDates.contains(sdate) == false else {
            return
        }
        
        Self.queuedDates.remove(sdate)
        Self.uploadingDates.insert(sdate)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.uploadLogsBySDate(sdate: sdate) {
                self.finishQueuedUpload(sdate: sdate)
            }
        }
    }
    
    private func finishQueuedUpload(sdate: String) {
        Self.uploadSyncQueue.async {
            Self.uploadingDates.remove(sdate)
            
            guard Self.queuedDates.contains(sdate) else {
                return
            }
            
            Self.pendingUploadWorkItems[sdate]?.cancel()
            let generation = Self.uploadQueueGeneration
            
            let workItem = DispatchWorkItem { [self] in
                self.startQueuedUploadIfNeededOnSyncQueue(sdate: sdate, generation: generation)
            }
            
            Self.pendingUploadWorkItems[sdate] = workItem
            Self.uploadSyncQueue.asyncAfter(deadline: .now() + 0.2, execute: workItem)
        }
    }

    func dealLogsDataForUpload(dict:NSDictionary, shouldRefreshTodayJournal: Bool = true, completion: (() -> Void)? = nil) {
        let serialQueue = DispatchQueue(label: "com.logs.calculate")
         
        let uploadDict = NSMutableDictionary(dictionary: dict)
        let mealsArray = NSMutableArray(array: WHUtils.getArrayFromJSONString(jsonString: dict["foods"]as? String ?? "[]"))
        let dataArray = NSMutableArray()
        
//        WidgetUtils().dealNaturalData(dataDict: dict)
        serialQueue.async {
            DLLog(message: "checkDataUploadStatus  计算 第一步")
            var caloriTotal = Double(0)
            var carboTotal = Double(0)
            var proteinTotal = Double(0)
            var fatTotal = Double(0)
            
            for i in 0..<mealsArray.count{
                var isEat = "0"
                let mealPerArr = mealsArray[i]as? NSMutableArray ?? []
                for j in 0..<mealPerArr.count{
                    let dictTemp = mealPerArr[j]as? NSMutableDictionary ?? [:]
                    if dictTemp.stringValueForKey(key: "state") == "1"{
                        let calori = WHUtils.fixedFractionString(dictTemp.doubleValueForKey(key: "calories"), fractionDigits: 3).doubleValue
                        let carbohydrate = WHUtils.fixedFractionString(dictTemp.doubleValueForKey(key: "carbohydrate"), fractionDigits: 3).doubleValue
                        let protein = WHUtils.fixedFractionString(dictTemp.doubleValueForKey(key: "protein"), fractionDigits: 3).doubleValue
                        let fat = WHUtils.fixedFractionString(dictTemp.doubleValueForKey(key: "fat"), fractionDigits: 3).doubleValue
                        
                        caloriTotal = caloriTotal + calori
                        carboTotal = carboTotal + carbohydrate
                        proteinTotal = proteinTotal + protein
                        fatTotal = fatTotal + fat
                        
                        dictTemp.setValue(WHUtils.fixedFractionString(calori, fractionDigits: 3), forKey: "calories")
                        dictTemp.setValue(WHUtils.fixedFractionString(carbohydrate, fractionDigits: 3), forKey: "carbohydrate")
                        dictTemp.setValue(WHUtils.fixedFractionString(protein, fractionDigits: 3), forKey: "protein")
                        dictTemp.setValue(WHUtils.fixedFractionString(fat, fractionDigits: 3), forKey: "fat")
                        
                        mealPerArr.replaceObject(at: j, with: dictTemp)
                        isEat = "1"
                    }
                }
                mealsArray.replaceObject(at: i, with: mealPerArr)
                
                let natuDict = ["calories":"\(Int(caloriTotal.rounded()))",
                                "carbohydrate":"\(Int(carboTotal.rounded()))",
                                "protein":"\(Int(proteinTotal.rounded()))",
                                "fat":"\(Int(fatTotal.rounded()))",
                                "isEat":"\(isEat)"]
                
                dataArray.add(natuDict)
            }
            WidgetUtils().saveCurrentDayMealsNaturalMsg(dataArray: dataArray)
            uploadDict.setValue(WHUtils.fixedFractionString(proteinTotal, fractionDigits: 3), forKey: "totalProteins")
            uploadDict.setValue(WHUtils.fixedFractionString(carboTotal, fractionDigits: 3), forKey: "totalCarbohydrates")
            uploadDict.setValue(WHUtils.fixedFractionString(fatTotal, fractionDigits: 3), forKey: "totalFats")
            uploadDict.setValue(WHUtils.fixedFractionString(caloriTotal, fractionDigits: 0), forKey: "totalCalories")
        }
        
        serialQueue.async {
            DLLog(message: "checkDataUploadStatus  上传 第二步")
            DispatchQueue.main.sync {
                self.sendUpdateLogsRequest(dict: uploadDict, meals: mealsArray, shouldRefreshTodayJournal: shouldRefreshTodayJournal, completion: completion)
                NutritionDefaultModel.shared.getDefaultGoal(weekDay: Date().getWeekdayIndex(from: Date().nextDay(days: 0)))
                if uploadDict.stringValueForKey(key: "sdate") == Date().nextDay(days: 0){
                    self.saveNaturalData(dict: uploadDict,isServerData:false)
                }else{
                    WidgetUtils.isManual = true
                    WidgetUtils.lastRefreshTimeStamp = (Int(Date().timeStamp)!)-10*60
//                    WidgetUtils().sendNaturalLast7Days(forNaturalType: 10)
                    DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                        WidgetUtils().sendNaturalLast7Days(forNaturalType: 10)
                        WidgetCenter.shared.reloadAllTimelines()
                    })
                }
            }
        }
    }
    func refreshWidgetSportData() {
        WidgetUtils.isManual = true
        WidgetUtils.lastRefreshTimeStamp = (Int(Date().timeStamp)!)-10*60
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
            WidgetCenter.shared.reloadAllTimelines()
        })
    }
    //MARK: 上传日志每餐用餐时间
    func sendUpdateLogsMealsTimeRequest(sDate:String) {
        let logsDict = NSMutableDictionary(dictionary: LogsSQLiteManager.getInstance().getMealsTimeForUpload(sDate: sDate))
        logsDict.setValue("\(sDate)", forKey: "sdate")
        DLLog(message: "sendUpdateLogsMealsTimeRequest:\(logsDict)")
        WHNetworkUtil.shareManager().POST(urlString: URL_User_logs_update_meal_time, parameters: logsDict as? [String : AnyObject]) { responseObject in
            DLLog(message: "sendUpdateLogsMealsTimeRequest:\(responseObject)")
        }
    }
    func sendUpdateLogsRequest(dict:NSDictionary,meals:NSArray, shouldRefreshTodayJournal: Bool = true, completion: (() -> Void)? = nil) {
        let logsDict = NSMutableDictionary(dictionary: LogsSQLiteManager.getInstance().getMealsTimeForUpload(sDate: "\(dict.stringValueForKey(key: "sdate"))"))
        
        logsDict.setValue("\(dict.stringValueForKey(key: "sdate"))", forKey: "sdate")
        logsDict.setValue("\(dict.stringValueForKey(key: "notes"))", forKey: "notes")
//        logsDict.setValue("\(dict.stringValueForKey(key: "notesTag"))", forKey: "notesLabel")
        logsDict.setValue(WHUtils.getArrayFromJSONString(jsonString: dict.stringValueForKey(key: "notesTag")), forKey: "notesLabel")
        logsDict.setValue("", forKey: "fitnessLabel")
//        if dict.stringValueForKey(key: "fitnessLabel").count > 0{
            logsDict.setValue(WHUtils.getArrayFromJSONString(jsonString: dict.stringValueForKey(key: "fitnessLabel")), forKey: "fitnessLabelArray")
//        }else{
//            logsDict.setValue(["[]"], forKey: "fitnessLabelArray")
//        }
        
        logsDict.setValue("\(dict.stringValueForKey(key: "carbLabel"))", forKey: "carbLabel")

        logsDict.setValue("\(uploadNumberString(dict.stringValueForKey(key: "totalProteins")))", forKey: "totalProteins")
        logsDict.setValue("\(uploadNumberString(dict.stringValueForKey(key: "totalCarbohydrates")))", forKey: "totalCarbohydrates")
        logsDict.setValue("\(uploadNumberString(dict.stringValueForKey(key: "totalFats")))", forKey: "totalFats")
        logsDict.setValue("\(uploadNumberString(dict.stringValueForKey(key: "totalCalories")))", forKey: "totalCalories")
//        logsDict.setValue("\(dict.stringValueForKey(key: "totalCarbohydrates"))", forKey: "totalCarbohydrates")
//        logsDict.setValue("\(dict.stringValueForKey(key: "totalFats"))", forKey: "totalFats")
//        logsDict.setValue("\(dict.stringValueForKey(key: "totalCalories"))", forKey: "totalCalories")
        logsDict.setValue("\(WHUtils.getJSONStringFromArray(array: meals))", forKey: "meals")
        
        let sn = dealMealsData(meals: meals)
        if shouldRefreshTodayJournal {
//        if logsDict.stringValueForKey(key: "sdate") == Date().todayDate && (sn >= 4 || sn == 0){
            UserDefaults.set(value: [:], forKey: .jounal_meal_advice)
            NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_TODAY_JOUNAL, object: nil)
//        }
        }
        
        DLLog(message: "sendUpdateLogsRequest(param):\(logsDict)")
        WHNetworkUtil.shareManager().POST(urlString: URL_User_logs_update_details, parameters: logsDict as? [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            if shouldRefreshTodayJournal {
                self.sendNextMealAdviceRequest(logsDict: logsDict, sn: sn)
            }
            LogsSQLiteManager.getInstance().updateUploadStatus(sDate: dict.stringValueForKey(key: "sdate"), update: true)
            LogsSQLiteManager.getInstance().updateLogsEtime(sDate: dict.stringValueForKey(key: "sdate"), endTime: dataObj["etime"]as? String ?? "\(Date().currentSeconds)")
            completion?()
        } failure: { _ in
            completion?()
        }
    }
    ///获取下餐饮食建议
    func sendNextMealAdviceRequest(logsDict:NSDictionary,sn:Int) {
        if logsDict.stringValueForKey(key: "sdate") != Date().todayDate || sn >= 4 || sn == 0 || UserInfoModel.shared.show_next_advice == false{
            return
        }
        let param = ["sdate":"\(logsDict.stringValueForKey(key: "sdate"))",
                     "sn":"\(sn)"]
        DLLog(message: "sendNextMealAdviceRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_User_logs_next_meal_advice, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendNextMealAdviceRequest:\(dataObj)")
            
            UserDefaults.set(value: ["sn":"\(sn)",
                                     "uid":"\(UserInfoModel.shared.uId)",
                                     "sdate":"\(logsDict.stringValueForKey(key: "sdate"))",
                                     "advice":"\(dataObj.stringValueForKey(key: "advice"))"], forKey: .jounal_meal_advice)
            NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_TODAY_JOUNAL, object: nil)
        }
    }
    ///上传喝水数据
    func sendWaterSynRequest(dict:NSDictionary) {
        let param = ["sdate":dict.stringValueForKey(key: "sdate"),
                     "qty":dict.stringValueForKey(key: "waterNum")]
        WHNetworkUtil.shareManager().POST(urlString: URL_User_logs_update_water, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendWaterSynRequest:\(dataObj)")
            
//            LogsSQLiteManager.shared.updateWaterUploadStatus(status: "1",
//                                                            cTime: dict.stringValueForKey(key: "sdate"),
//                                                            eTime: dataObj.stringValueForKey(key: "etime").replacingOccurrences(of: "T", with: " "))
            LogsSQLiteManager.shared.updateWaterUploadStatus(sDate: dict.stringValueForKey(key: "sdate"),
                                                             update: true,
                                                             eTime: dataObj.stringValueForKey(key: "etime").replacingOccurrences(of: "T", with: " "))
        }
    }
    func saveNaturalData(dict:NSDictionary,isServerData:Bool) {
        if dict.stringValueForKey(key: "sdate") != Date().nextDay(days: 0){
            WidgetUtils.isManual = true
            WidgetUtils.lastRefreshTimeStamp = (Int(Date().timeStamp)!)-10*60
//            WidgetUtils().sendNaturalLast7Days(forNaturalType: 10)
            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                WidgetUtils().sendNaturalLast7Days(forNaturalType: 10)
                WidgetCenter.shared.reloadAllTimelines()
            })
            return
        }
        if isServerData{
            self.updateWidgetUI(dict:["caloriTar":dict.stringValueForKey(key: "caloriesden"),
                                      "proteinTar":dict.stringValueForKey(key: "proteinden"),
                                      "carboTar":dict.stringValueForKey(key: "carbohydrateden"),
                                      "fatsTar":dict.stringValueForKey(key: "fatden"),
                                      "calori":dict.stringValueForKey(key: "calories"),
                                      "protein":dict.stringValueForKey(key: "protein"),
                                      "carbohydrates":dict.stringValueForKey(key: "carbohydrate"),
                                      "fats":dict.stringValueForKey(key: "fat"),
                                      "sdate":"\(Date().nextDay(days: 0))"])
        }else{
            let logsModel = LogsSQLiteManager.getInstance().getLogsByDate(sDate: Date().nextDay(days: 0))
            let goalDict = NutritionDefaultModel.shared.getTodayGoal()
            
            self.updateWidgetUI(dict:["caloriTar":"\(logsModel?.caloriTarget ?? goalDict.stringValueForKey(key: "calories"))",
                                      "proteinTar":"\(logsModel?.proteinTarget ?? goalDict.stringValueForKey(key: "carbohydrates"))",
                                      "carboTar":"\(logsModel?.carbohydrateTarget ?? goalDict.stringValueForKey(key: "proteins"))",
                                      "fatsTar":"\(logsModel?.fatTarget ?? goalDict.stringValueForKey(key: "fats"))",
                                      "calori":"\(dict.stringValueForKey(key: "totalCalories"))",
                                      "protein":"\(dict.stringValueForKey(key: "totalProteins"))",
                                      "carbohydrates":"\(dict.stringValueForKey(key: "totalCarbohydrates"))",
                                      "fats":"\(dict.stringValueForKey(key: "totalFats"))",
                                      "sdate":"\(Date().nextDay(days: 0))"])
        }
    }
    func saveLocalNaturalData(dict:NSDictionary) {
        if dict.stringValueForKey(key: "sdate") != Date().nextDay(days: 0){
            return
        }
        self.updateWidgetUI(dict: ["caloriTar":"\(dict.stringValueForKey(key: "caloriesden"))",
                                   "proteinTar":"\(dict.stringValueForKey(key: "proteinden"))",
                                   "carboTar":"\(dict.stringValueForKey(key: "carbohydrateden"))",
                                   "fatsTar":"\(dict.stringValueForKey(key: "fatden"))",
                                   "calori":"\(dict.stringValueForKey(key: "calories"))",
                                   "protein":"\(dict.stringValueForKey(key: "protein"))",
                                   "carbohydrates":"\(dict.stringValueForKey(key: "carbohydrate"))",
                                   "fats":"\(dict.stringValueForKey(key: "fat"))",
                                   "sdate":"\(Date().nextDay(days: 0))"])
    }
    //更新小组件的数据
    //更新了当天的目标
    func updateNaturalGoalForWidget() {
        let goalDict = NutritionDefaultModel.shared.getTodayGoal()
        
        let dict = NSMutableDictionary(dictionary: WidgetUtils().readNaturalData())
        dict.setValue(goalDict.stringValueForKey(key: "calories"), forKey: "caloriTar")
        dict.setValue(goalDict.stringValueForKey(key: "carbohydrates"), forKey: "carboTar")
        dict.setValue(goalDict.stringValueForKey(key: "proteins"), forKey: "proteinTar")
        dict.setValue(goalDict.stringValueForKey(key: "fats"), forKey: "fatsTar")
        
        self.updateWidgetUI(dict: dict)
    }
    //更新小组件的数据
    //清空了当天的日志
    func clearNaturalData() {
        let goalDict = NutritionDefaultModel.shared.getTodayGoal()
        
        let dict = NSMutableDictionary(dictionary: WidgetUtils().readNaturalData())
        dict.setValue(goalDict.stringValueForKey(key: "calories"), forKey: "caloriTar")
        dict.setValue(goalDict.stringValueForKey(key: "carbohydrates"), forKey: "carboTar")
        dict.setValue(goalDict.stringValueForKey(key: "proteins"), forKey: "proteinTar")
        dict.setValue(goalDict.stringValueForKey(key: "fats"), forKey: "fatsTar")
        dict.setValue("0", forKey: "calori")
        dict.setValue("0", forKey: "protein")
        dict.setValue("0", forKey: "carbohydrates")
        dict.setValue("0", forKey: "fats")
        dict.setValue("\(Date().nextDay(days: 0))", forKey: "sdate")
        
        self.updateWidgetUI(dict: dict)
    }
    
    func updateWidgetUI(dict: NSDictionary) {
        WidgetUtils().saveNaturalData(dict: dict)
//        WidgetUtils.neesPostRequest = true
        WidgetUtils.isManual = true
        WidgetUtils.lastRefreshTimeStamp = (Int(Date().timeStamp)!)-10*60
//        WidgetUtils().sendNaturalLast7Days(forNaturalType: 10)
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
            WidgetUtils().sendNaturalLast7Days(forNaturalType: 10)
            WidgetCenter.shared.reloadAllTimelines()
        })
    }
}

extension LogsSQLiteUploadManager{
    func dealMealsData(meals:NSArray) -> Int{
        var snArr:[Int] = [Int]()
        
        for i in 0..<meals.count{
            let foodsArray = meals[i]as? NSArray ?? []
            if foodsArray.count > 0 {
                for j in 0..<foodsArray.count{
                    let foodsMsg = foodsArray[j]as? NSDictionary ?? [:]
                    if foodsMsg.stringValueForKey(key: "state") == "1"{
                        snArr.append(i+1)
                        break
                    }
                }
            }
        }
        
        if !snArr.contains(1){
            return 0
        }
        
        if let maxValue = snArr.max() {
            return maxValue
        }else{
            return 0
        }
    }
    private func uploadNumberString(_ value: String) -> String {
        return value.replacingOccurrences(of: ",", with: ".")
    }
}
