//
//  HealthKitManager+bodyFatPercentage.swift
//  lns
//  体脂率
//  Created by Elavatine on 2025/4/21.
//

import HealthKit

extension HealthKitManager{
    ///保存体脂率数据到HealthKit
    func saveBodyFatPercentage(value: Double, sdate:String) {
        guard let bodyFatType = HKObjectType.quantityType(forIdentifier: .bodyFatPercentage) else { return }
        let currentTimeString = Date().currentSeconds
        let dateString = currentTimeString.replacingOccurrences(of: Date().todayDate, with: sdate)
        
        let date = Date().changeDateStringToDate(dateString: dateString,formatter: "yyyy-MM-dd HH:mm:ss")
        let bodyFatQuantity = HKQuantity(unit: HKUnit.percent(), doubleValue: value)
        let bodyFatSample = HKQuantitySample(type: bodyFatType, quantity: bodyFatQuantity, start: date, end: date)

        deleteOldHealthData(sDate: sdate, sampleType: bodyFatType) { success ,hasData in
            if value > 0 {
                self.healthStore.save(bodyFatSample) { (success, error) in
                    if success {
                        DLLog(message: "HealthKitNaturnalManager:体脂率数据保存成功  ---   \(sdate) - \(value)")
                    } else {
                        DLLog(message: "HealthKitNaturnalManager:体脂率数据保存失败  **---**   \(sdate) - \(value)")
                    }
                }
            }
        }
    }
///保存腰围数据到HealthKit
    func saveWaistCircumference(value: Double, sdate: String) {
        guard let waistCircumferenceType = HKObjectType.quantityType(forIdentifier: .waistCircumference) else { return }
        let currentTimeString = Date().currentSeconds
        let dateString = currentTimeString.replacingOccurrences(of: Date().todayDate, with: sdate)
        
        let date = Date().changeDateStringToDate(dateString: dateString,formatter: "yyyy-MM-dd HH:mm:ss")
        
        let waistCircumferenceQuantity = HKQuantity(unit: HKUnit.meterUnit(with: .centi), doubleValue: value)
        let waistCircumferenceSample = HKQuantitySample(type: waistCircumferenceType, quantity: waistCircumferenceQuantity, start: date, end: date)

        deleteOldHealthData(sDate: sdate, sampleType: waistCircumferenceType) { success ,hasData in
            if value > 0 {
                self.healthStore.save(waistCircumferenceSample) { (success, error) in
                    if success {
                        DLLog(message: "HealthKitNaturnalManager:腰围数据保存成功  ---   \(sdate) - \(value)")
                    } else {
                        DLLog(message: "HealthKitNaturnalManager:腰围数据保存失败  **---**   \(sdate) - \(value)")
                    }
                }
            }
        }
    }
    ///保存体重数据到HealthKit
    func saveWeight(value: Double, sdate: String) {
        guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else { return }
        let currentTimeString = Date().currentSeconds
        let dateString = currentTimeString.replacingOccurrences(of: Date().todayDate, with: sdate)
        
        let date = Date().changeDateStringToDate(dateString: dateString,formatter: "yyyy-MM-dd HH:mm:ss")
        
        let weight = HKQuantity(unit: HKUnit(from: "kg"), doubleValue: value)
        let weightSample = HKQuantitySample(type: weightType, quantity: weight, start: date, end: date)

        deleteOldHealthData(sDate: sdate, sampleType: weightType) { success ,hasData in
            if value > 0 {
                self.healthStore.save(weightSample) { (success, error) in
                    if success {
                        DLLog(message: "HealthKitNaturnalManager:体重数据保存成功  ---   \(sdate) - \(value)")
                    } else {
                        DLLog(message: "HealthKitNaturnalManager:体重数据保存失败  **---**   \(sdate) - \(value)")
                    }
                }
            }
        }
    }
    ///从HealthKit APP同步体脂率数据 ，近一个月数据
    func fetchBodyFatPercentage() {
        guard let bodyFatType = HKObjectType.quantityType(forIdentifier: .bodyFatPercentage) else { return }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let monthsAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: monthsAgo, end: Date(), options: .strictStartDate)
//        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: bodyFatType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard let results = results, !results.isEmpty, error == nil else {
                DLLog(message: "Failed to fetch body fat percentage: \(error)")
                return
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
            dateFormatter.calendar = Calendar.init(identifier: .gregorian)
            dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone.current//TimeZone(secondsFromGMT: 0)
            
            DispatchQueue.global(qos: .userInitiated).async {
                for i in 0..<results.count{
                    let result = results[i] as? HKQuantitySample
                    let value = result?.quantity.doubleValue(for: HKUnit.percent())
                    DLLog(message: "HealthKitManager bodyfat:\(result)")
                    
                    let time = Date().changeZeroAreaToZHTimeZone(dateString: dateFormatter.string(from: result?.startDate ?? Date()))
                    let valueString = "\(value ?? 0)".replacingOccurrences(of: ",", with: ".")
                    DLLog(message: "HealthKitManager:\(time)  --   \(value)")
                    
                    if valueString.floatValue > 0 {
                        if BodyDataSQLiteManager.getInstance().queryTable(sDate: time){
                            BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "bfp", data: "\(valueString.floatValue*100)", cTime: time)
                        }else{
                            BodyDataSQLiteManager.getInstance().updateData(cTime: time,
                                                                           imgurl: "",
                                                                           hipsData: "",
                                                                           weightData: "",
                                                                           waistlineData: "",
                                                                           shoulderData: "",
                                                                           bustData: "",
                                                                           thighData: "",
                                                                           calfData: "",
                                                                           bfpData: "\(valueString.floatValue*100)",
                                                                           images: "",
                                                                           armcircumferenceData: "")
                        }
                        BodyDataSQLiteManager.getInstance().updateUploadStatus(cTime: time, uploadStatus: false)
                    }
                }
            }
        }

        healthStore.execute(query)
    }
    
    ///从HealthKit APP同步腰围数据 ，近一个月数据
    func fetchWaistCircumference() {
        guard let waistCircumferenceType = HKObjectType.quantityType(forIdentifier: .waistCircumference) else { return }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let monthsAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: monthsAgo, end: Date(), options: .strictStartDate)
        
//        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: waistCircumferenceType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard let results = results, !results.isEmpty, error == nil else {
                DLLog(message: "Failed to fetch body fat percentage: \(error)")
                return
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
            dateFormatter.calendar = Calendar.init(identifier: .gregorian)
            dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone.current//TimeZone(secondsFromGMT: 0)
            
            DispatchQueue.global(qos: .userInitiated).async {
                for i in 0..<results.count{
                    let result = results[i] as? HKQuantitySample
                    let value = result?.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
                    
                    let time = Date().changeZeroAreaToZHTimeZone(dateString: dateFormatter.string(from: result?.startDate ?? Date()))
                    let valueString = "\(value ?? 0)".replacingOccurrences(of: ",", with: ".")
                    
                    if valueString.floatValue > 0 {
                        if BodyDataSQLiteManager.getInstance().queryTable(sDate: time){
                            BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "waistline", data: "\(valueString)", cTime: time)
                        }else{
                            BodyDataSQLiteManager.getInstance().updateData(cTime: time,
                                                                           imgurl: "",
                                                                           hipsData: "",
                                                                           weightData: "",
                                                                           waistlineData: "\(valueString)",
                                                                           shoulderData: "",
                                                                           bustData: "",
                                                                           thighData: "",
                                                                           calfData: "",
                                                                           bfpData: "",
                                                                           images: "",
                                                                           armcircumferenceData: "")
                        }
                        
                        BodyDataSQLiteManager.getInstance().updateUploadStatus(cTime: time, uploadStatus: false)
                    }
                }
            }
        }

        healthStore.execute(query)
    }
}

extension HealthKitManager{
    // 删除旧的数据
    func deleteOldHealthData(sDate:String,sampleType:HKQuantityType,completion: @escaping (Bool,Bool) -> Void) {
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
        
        group.notify(queue: .global()) {
            // 通过闭包回调，通知删除操作完成
            completion(true,hasData)
        }
        let queryData = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            if let results = results {
                DLLog(message: "HealthKitNaturnalManager:\(sDate) - \(results)")
                self.filterAndDeleteSamples(results, group: group){ d in
                    hasData = true
                }
                group.leave()
            }else{
                group.leave()
            }
        }

        // 执行查询删除数据
        healthStore.execute(queryData)
    }
    // 过滤和删除来自你应用的数据
     func filterAndDeleteSamples(_ samples: [HKSample],group:DispatchGroup,completion: @escaping (Bool) -> Void) {
 //       let group = DispatchGroup()
        for sample in samples {
            // 判断是否为你应用的数据源
            DLLog(message: "HealthKitNaturnalManager:(filterAndDeleteSamples) \(sample)")
            if sample.sourceRevision.source.bundleIdentifier == "com.lns.elavatine"{ // 替换为你的应用的bundleIdentifier
                completion(true)
                group.enter()
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
}
