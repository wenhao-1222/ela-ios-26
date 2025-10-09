//HealthKitNaturnalManager
//
//  HealthKitNaturnalManager.swift
//  lns
//
//  Created by Elavatine on 2025/4/17.
//

import HealthKit

///当添加餐食这种多个食物的时候，由于分很多次加入到日志，会触发多次同步数据到健康APP
///用这个属性，来标记添加的食物数量，cell里面调用同步方法不便，在同步方法里面统一控制
///每次调用同步方法，这个值 减 1， 等于 0 的时候，同步数据到健康APP，同时重置为 1
public var ADD_FOODS_FOR_HEALTHKIT_NATURAL = 1

class HealthKitNaturnalManager {

    let healthStore = HKHealthStore()
    let caloriesType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
   let carbsType = HKQuantityType.quantityType(forIdentifier: .dietaryCarbohydrates)!
   let proteinType = HKQuantityType.quantityType(forIdentifier: .dietaryProtein)!
   let fatType = HKQuantityType.quantityType(forIdentifier: .dietaryFatTotal)!
    let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater)//饮水

    /// 队列用于按顺序保存营养数据，避免并发写入导致重复
    private let nutritionSaveQueue = DispatchQueue(label: "com.lns.healthkit.nutritionSaveQueue")

//    /// 用于去抖动保存营养数据，key 为日期字符串
//    private static var saveWorkItems: [String: DispatchWorkItem] = [:]
//    /// 去抖动时间，单位秒
//    private static let debounceInterval: TimeInterval = 1.0

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        // 设置我们需要读取和写入的数据类型
        var readTypes: Set = [
            caloriesType,
            carbsType,
            proteinType,
            fatType
        ]
        
        var writeTypes: Set = [
            caloriesType,
            carbsType,
            proteinType,
            fatType
        ]
        
        let water_isAuthori = UserDefaults.getString(forKey: .health_water_Authori)
        if water_isAuthori == "" || water_isAuthori == nil{
            writeTypes.insert(waterType!)
            readTypes.insert(waterType!)
        }
        
        let natural_Authori = UserDefaults.getString(forKey: .health_sport_natural_calories)
        if natural_Authori == "" || natural_Authori == nil{
            healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
                if success {
                    DLLog(message: "HealthKitNaturnalManager:健康APP  --  营养元素授权成功！")
                } else {
                    DLLog(message: "HealthKitNaturnalManager:健康APP  --  营养元素授权失败！\(error?.localizedDescription ?? "")")
                }
            }
        }
        UserDefaults.set(value: "1", forKey: .health_water_Authori)
        UserDefaults.set(value: "1", forKey: .health_sport_natural)
        UserDefaults.set(value: "1", forKey: .health_sport_natural_calories)
    }
    
    func requestAuthorization(completeHandler: @escaping (Bool) -> ()) {
        let bodyData_Weight_Authori = UserDefaults.getString(forKey: .health_sport_natural_calories)
        if bodyData_Weight_Authori == "" || bodyData_Weight_Authori == nil{
            UserDefaults.set(value: "1", forKey: .health_sport_natural_calories)
            guard HKHealthStore.isHealthDataAvailable() else { return }
            
            // 设置我们需要读取和写入的数据类型
            let readTypes: Set = [
                caloriesType,
                carbsType,
                proteinType,
                fatType
            ]
            
            let writeTypes: Set = [
                caloriesType,
                carbsType,
                proteinType,
                fatType
            ]
            healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
                if success {
                    DLLog(message: "HealthKitNaturnalManager:健康APP  --  营养元素授权成功！")
                    completeHandler(true)
                } else {
                    DLLog(message: "HealthKitNaturnalManager:健康APP  --  营养元素授权失败！\(error?.localizedDescription ?? "")")
                    completeHandler(false)
                }
            }
        }else{
            completeHandler(true)
        }
    }
}

extension HealthKitNaturnalManager{
    ///保存喝水数据，是否是修改总饮水量
    func saveWaterData(sdate:String,waterNum:Double,isTotal:Bool=false) {
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else { return }
        
        var date = Date()
        if sdate != Date().nextDay(days: 0){//如果不是修改的今日数据，则修改添加时间为当天的 18:00
            date = Date().changeDateStringToDate(dateString: "\(sdate) 20:00:00",formatter: "yyyy-MM-dd HH:mm:ss")
        }
        let quantity = HKQuantity(unit: HKUnit(from: "ml"), doubleValue: waterNum)
        let sample = HKQuantitySample(type: waterType, quantity: quantity, start: date, end: date)
        
        if isTotal{
//            let date = Date().changeDateStringToDate(dateString: sDate)
           let calendar = Calendar.current
            // 获取今天零点的日期
            let startOfDay = calendar.startOfDay(for: date)
            // 获取明天零点的日期作为结束时间
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)
            let group = DispatchGroup()
            group.enter()
            let queryWater = HKSampleQuery(sampleType: waterType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
                if let results = results {
                    DLLog(message: "HealthKitNaturnalManager:饮水数据\(sdate) - \(results)")
                    if results.count == 0 {
                        group.leave()
                    }else{
                        for i in 0..<results.count{
                            let sample = results[i]
                            if sample.sourceRevision.source.bundleIdentifier == "com.lns.elavatine"{ // 替换为你的应用的bundleIdentifier
                                group.enter()
                                // 删除来自你的应用的样本数据
                                self.healthStore.delete(sample) { (success, error) in
                                    if success {
                                        DLLog(message: "HealthKitNaturnalManager:成功删除来自你应用的数据")
                                    } else {
                                        DLLog(message: "HealthKitNaturnalManager:删除数据失败：\(String(describing: error))")
                                    }
                                    group.leave()
                                }
                            }
                            if i == results.count - 1{
                                group.leave()
                            }
                        }
                    }
                }else{
                    group.leave()
                }
            }
            group.notify(queue: .global()) {
                // 通过闭包回调，通知删除操作完成
                if waterNum > 0 {
                    self.healthStore.save([sample]) { (success, error) in
                        if success {
                            DLLog(message: "HealthKitNaturnalManager:\(sdate) -成功保存饮水量！")
                        } else {
                            DLLog(message: "HealthKitNaturnalManager:\(sdate) -保存失败：\(String(describing: error))")
                        }
                    }
                }
            }
            healthStore.execute(queryWater)
        }else{
            self.healthStore.save([sample]) { (success, error) in
                if success {
                    DLLog(message: "HealthKitNaturnalManager:\(sdate) -成功保存饮水量！")
                } else {
                    DLLog(message: "HealthKitNaturnalManager:\(sdate) -保存失败：\(String(describing: error))")
                }
            }
        }
    }
    /// 清空今日以及未来的饮水数据
    func clearWaterDataFromToday(completion: @escaping (Bool) -> Void) {
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            completion(false)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
//        let calendar = Calendar.current
//        // 获取明天零点的日期作为结束时间
//        let endOfDay = calendar.date(byAdding: .year, value: 1, to: startOfDay)!
//        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: nil)

        let query = HKSampleQuery(sampleType: waterType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (_, results, _) in
            guard let results = results else {
                completion(false)
                return
            }

            let group = DispatchGroup()
            for sample in results {
                if sample.sourceRevision.source.bundleIdentifier == "com.lns.elavatine" {
                    group.enter()
                    self.healthStore.delete(sample) { _, _ in
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) {
                completion(true)
            }
        }
        healthStore.execute(query)
    }
   // 保存营养数据的方法
    //（带去抖动）   2025年07月15日13:38:17
    func saveNutritionData(calories: Double,carbs: Double, protein: Double, fat: Double,cTime:String) {
//        // 取消同一天待执行的任务，只保留最后一次
//        if let work = Self.saveWorkItems[cTime] {
//            work.cancel()
//            Self.saveWorkItems.removeValue(forKey: cTime)
//        }
//
//        let workItem = DispatchWorkItem { [weak self] in
//            Self.saveWorkItems.removeValue(forKey: cTime)
//            self?.performSaveNutritionData(calories: calories, carbs: carbs, protein: protein, fat: fat, cTime: cTime)
//        }
//        Self.saveWorkItems[cTime] = workItem
//        DispatchQueue.main.asyncAfter(deadline: .now() + Self.debounceInterval, execute: workItem)
//    }
//
//    /// 真正执行保存营养数据的方法
//    private func performSaveNutritionData(calories: Double,carbs: Double, protein: Double, fat: Double,cTime:String) {
        
        nutritionSaveQueue.async {
            let semaphore = DispatchSemaphore(value: 0)
            self.performSaveNutritionData(calories: calories, carbs: carbs, protein: protein, fat: fat, cTime: cTime) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

        private func performSaveNutritionData(calories: Double,carbs: Double, protein: Double, fat: Double,cTime:String, completion: @escaping () -> Void) {
//        if ADD_FOODS_FOR_HEALTHKIT_NATURAL >= 1{
//            ADD_FOODS_FOR_HEALTHKIT_NATURAL -= 1
//        }else{
//            ADD_FOODS_FOR_HEALTHKIT_NATURAL = 0
//        }
//        if ADD_FOODS_FOR_HEALTHKIT_NATURAL > 0{
//            return
//        }
//        ADD_FOODS_FOR_HEALTHKIT_NATURAL = 1
//        let logsDate = Date().changeDateStringToDate(dateString: cTime)
        let nextDay = "\(Date().nextDay(days: 1)) 00:00:00"
        if !Date().judgeMin(firstTime: "\(cTime) 23:59:59", secondTime: nextDay){
            DLLog(message: "HealthKitNaturnalManager:\(cTime) 的数据不存入健康APP")
            return
        }
        DLLog(message: "HealthKitNaturnalManager:\(cTime) 的数据存入健康APP----------")
        
       let carloriesQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: calories)
       let carbsQuantity = HKQuantity(unit: HKUnit.gram(), doubleValue: carbs)
       let proteinQuantity = HKQuantity(unit: HKUnit.gram(), doubleValue: protein)
       let fatQuantity = HKQuantity(unit: HKUnit.gram(), doubleValue: fat)
        var date = Date()
        if cTime != Date().nextDay(days: 0){//如果不是修改的今日数据，则修改添加时间为当天的 18:00
            date = Date().changeDateStringToDate(dateString: "\(cTime) 20:00:00",formatter: "yyyy-MM-dd HH:mm:ss")
        }
        DLLog(message: "HealthKitNaturnalManager:\(cTime) - \(calories) - \(carbs) - \(protein) - \(fat)")
       // 创建新的样本
        let caloriesSample = HKQuantitySample(type: caloriesType, quantity: carloriesQuantity, start: date, end: date)
       let carbsSample = HKQuantitySample(type: carbsType, quantity: carbsQuantity, start: date, end: date)
       let proteinSample = HKQuantitySample(type: proteinType, quantity: proteinQuantity, start: date, end: date)
       let fatSample = HKQuantitySample(type: fatType, quantity: fatQuantity, start: date, end: date)
       // 删除旧的样本数据，确保不会累加
        deleteOldNutritionData(sDate: cTime, calories: calories,carbs: carbs, protein: protein, fat: fat) { success ,hasData in
            if carbs > 0 || protein > 0 || fat > 0 || calories > 0{
                // 在删除成功后保存新数据
                self.healthStore.save([caloriesSample,carbsSample, proteinSample, fatSample]) { (success, error) in
                    if success {
                        DLLog(message: "HealthKitNaturnalManager:\(cTime) -成功保存营养数据！")
                    } else {
                        DLLog(message: "HealthKitNaturnalManager:\(cTime) -保存失败：\(String(describing: error))")
                    }
                }
            }
       }
   }
   // 删除旧的营养数据
    func deleteOldNutritionData(sDate:String,calories: Double,carbs: Double, protein: Double, fat: Double,completion: @escaping (Bool,Bool) -> Void) {
//       let now = Date()
        let date = Date().changeDateStringToDate(dateString: sDate)
       let calendar = Calendar.current

       // 获取今天零点的日期
       let startOfDay = calendar.startOfDay(for: date)

       // 获取明天零点的日期作为结束时间
       let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
       let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)

        var hasData = false
       let group = DispatchGroup()
       group.enter()
       group.enter()
       group.enter()
        group.enter()
        let queryCalories = HKSampleQuery(sampleType: caloriesType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            if let results = results {
                DLLog(message: "HealthKitNaturnalManager:膳食能量数据\(sDate) - \(results)")
                self.filterAndDeleteSamples(results, data: calories, group: group){ d in
                    hasData = true
                }
                group.leave()
            }else{
                group.leave()
            }
        }
       let queryCarbs = HKSampleQuery(sampleType: carbsType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
           if let results = results {
               DLLog(message: "HealthKitNaturnalManager:碳水数据\(sDate) - \(results)")
               self.filterAndDeleteSamples(results, data: carbs, group: group){ d in
                   hasData = true
               }
               group.leave()
           }else{
               group.leave()
           }
       }

       let queryProtein = HKSampleQuery(sampleType: proteinType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
           if let results = results {
               DLLog(message: "HealthKitNaturnalManager:蛋白质数据\(sDate) - \(results)")
               // 查询所有蛋白质样本的数据
               self.filterAndDeleteSamples(results, data: protein, group: group){ d in
                   hasData = true
               }
               group.leave()
           }else{
               group.leave()
           }
       }

       let queryFat = HKSampleQuery(sampleType: fatType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
           if let results = results {
               DLLog(message: "HealthKitNaturnalManager:脂肪数据\(sDate) - \(results)")
               self.filterAndDeleteSamples(results, data: fat, group: group){ d in
                   hasData = true
               }
               group.leave()
           }else{
               group.leave()
           }
       }

       // 执行查询删除数据
        healthStore.execute(queryCalories)
       healthStore.execute(queryCarbs)
       healthStore.execute(queryProtein)
       healthStore.execute(queryFat)

       group.notify(queue: .global()) {
           // 通过闭包回调，通知删除操作完成
           completion(true,hasData)
       }
   }
}

extension HealthKitNaturnalManager{
   // 过滤和删除来自你应用的数据
    func filterAndDeleteSamples(_ samples: [HKSample],data:Double,group:DispatchGroup,completion: @escaping (Bool) -> Void) {
//       let group = DispatchGroup()
       for sample in samples {
           // 判断是否为你应用的数据源
           DLLog(message: "HealthKitNaturnalManager:(filterAndDeleteSamples) \(sample)")
           if sample.sourceRevision.source.bundleIdentifier == "com.lns.elavatine"{ // 替换为你的应用的bundleIdentifier
               group.enter()
               completion(true)
               // 删除来自你的应用的样本数据
               healthStore.delete(sample) { (success, error) in
                   if success {
                       DLLog(message: "HealthKitNaturnalManager:成功删除来自你应用的数据")
                   } else {
                       DLLog(message: "HealthKitNaturnalManager:删除数据失败：\(String(describing: error))")
                   }
                   group.leave()
               }
           }
       }
   }
    /// 根据数值过滤并删除样本，避免重复同步造成数值翻倍
//   func filterAndDeleteSamples(_ samples: [HKSample], data: Double, group: DispatchGroup, completion: @escaping (Bool) -> Void) {
//       for sample in samples {
//           guard let quantitySample = sample as? HKQuantitySample else { continue }
//
//           var unit = HKUnit.gram()
//           if quantitySample.quantityType == caloriesType {
//               unit = .kilocalorie()
//           }
//           let value = quantitySample.quantity.doubleValue(for: unit)
//
//           if abs(value - data) < 0.1 || sample.sourceRevision.source.bundleIdentifier == "com.lns.elavatine" {
//               group.enter()
//               completion(true)
//               healthStore.delete(sample) { success, error in
//                   if success {
//                       DLLog(message: "HealthKitNaturnalManager:成功删除来自你应用的数据")
//                   } else {
//                       DLLog(message: "HealthKitNaturnalManager:删除数据失败：\(String(describing: error))")
//                   }
//                   group.leave()
//               }
//           }
//       }
//   }
}
