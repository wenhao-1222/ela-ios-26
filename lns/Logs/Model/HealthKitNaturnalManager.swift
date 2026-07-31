//HealthKitNaturnalManager
//
//  HealthKitNaturnalManager.swift
//  lns
//
//  Created by Elavatine on 2025/4/17.
//

import HealthKit

/// 统一维护本 App 需要读写的 Apple 健康权限类型，确保不同入口请求的是同一份权限全集。
enum HealthKitPermissionTypesProvider {
    /// 本 App 会读写的身体数据类型标识。
    private static let bodyQuantityIdentifiers: [HKQuantityTypeIdentifier] = [
        .bodyMass,
        .waistCircumference,
        .bodyFatPercentage
    ]

    /// 本 App 会读写的运动相关数量类型标识。
    private static let workoutQuantityIdentifiers: [HKQuantityTypeIdentifier] = [
        .activeEnergyBurned
    ]

    /// 本 App 会读写的基础饮食类型标识。
    private static let baseNutritionQuantityIdentifiers: [HKQuantityTypeIdentifier] = [
        .dietaryWater,
        .dietaryEnergyConsumed,
        .dietaryCarbohydrates,
        .dietaryProtein,
        .dietaryFatTotal
    ]

    /// 本 App 会读写的扩展营养类型标识；反式脂肪、嘌呤、肌酸暂无 HealthKit 标准类型。
    private static let additionalNutritionQuantityIdentifiers: [HKQuantityTypeIdentifier] = [
        .dietaryFiber,
        .dietarySugar,
        .dietaryFatSaturated,
        .dietaryCholesterol,
        .dietarySodium,
        .dietaryPotassium,
        .dietaryCalcium,
        .dietaryIron,
        .dietaryVitaminA,
        .dietaryVitaminC,
        .dietaryCaffeine
    ]

    /// 本 App 当前已接入读写逻辑的所有 HealthKit 数量类型标识。
    private static var allQuantityIdentifiers: [HKQuantityTypeIdentifier] {
        bodyQuantityIdentifiers + workoutQuantityIdentifiers + baseNutritionQuantityIdentifiers + additionalNutritionQuantityIdentifiers
    }

    /// 本 App 当前已接入读写逻辑的所有 HealthKit 数量类型。
    private static var allQuantityTypes: [HKQuantityType] {
        allQuantityIdentifiers.compactMap { HKQuantityType.quantityType(forIdentifier: $0) }
    }

    /// 请求 Apple 健康写入权限时使用的完整类型集合。
    static var allShareTypes: Set<HKSampleType> {
        var shareTypes = Set<HKSampleType>()
        allQuantityTypes.forEach { shareTypes.insert($0) }
        shareTypes.insert(HKObjectType.workoutType())
        return shareTypes
    }

    /// 请求 Apple 健康读取权限时使用的完整类型集合。
    static var allReadTypes: Set<HKObjectType> {
        var readTypes = Set<HKObjectType>()
        allQuantityTypes.forEach { readTypes.insert($0) }
        readTypes.insert(HKObjectType.workoutType())
        return readTypes
    }

    /// 是否存在尚未弹窗询问过的 HealthKit 写入类型，用来补齐新增权限且避免用户拒绝后反复请求。
    static func hasNotDeterminedShareType(in healthStore: HKHealthStore) -> Bool {
        allShareTypes.contains { healthStore.authorizationStatus(for: $0) == .notDetermined }
    }

    /// 一次性请求本 App 当前所有已接入的 Apple 健康读写权限。
    static func requestAllKnownHealthDataAuthorization(in healthStore: HKHealthStore, completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        healthStore.requestAuthorization(toShare: allShareTypes, read: allReadTypes) { success, error in
            completion(success, error)
        }
    }
}

///当添加餐食这种多个食物的时候，由于分很多次加入到日志，会触发多次同步数据到健康APP
///用这个属性，来标记添加的食物数量，cell里面调用同步方法不便，在同步方法里面统一控制
///每次调用同步方法，这个值 减 1， 等于 0 的时候，同步数据到健康APP，同时重置为 1
public var ADD_FOODS_FOR_HEALTHKIT_NATURAL = 1

class HealthKitNaturnalManager {

    /// HealthKit 数据读写入口。
    let healthStore = HKHealthStore()
    /// 膳食能量 HealthKit 类型。
    let caloriesType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
    /// 碳水 HealthKit 类型。
   let carbsType = HKQuantityType.quantityType(forIdentifier: .dietaryCarbohydrates)!
    /// 蛋白质 HealthKit 类型。
   let proteinType = HKQuantityType.quantityType(forIdentifier: .dietaryProtein)!
    /// 总脂肪 HealthKit 类型。
   let fatType = HKQuantityType.quantityType(forIdentifier: .dietaryFatTotal)!
    /// 饮水 HealthKit 类型。
    let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater)//饮水

    /// HealthKit 可写入营养素的配置项。
    private struct HealthKitNutritionSyncItem {
        /// 项目内部使用的营养素字段名，用于从日志字典读取数值。
        let key: String
        /// Apple 健康中的营养素类型标识。
        let identifier: HKQuantityTypeIdentifier
        /// 写入 Apple 健康时使用的单位。
        let unit: HKUnit
        /// 日志中展示用的中文名称，便于排查同步问题。
        let title: String

        /// 当前配置对应的 HealthKit 数量类型。
        var quantityType: HKQuantityType? {
            HKQuantityType.quantityType(forIdentifier: identifier)
        }
    }

    /// 已解析出 HKQuantityType 的同步配置，避免写入过程中反复解包。
    private struct ResolvedHealthKitNutritionSyncItem {
        /// 项目内部使用的营养素字段名。
        let key: String
        /// Apple 健康中的营养素类型标识。
        let identifier: HKQuantityTypeIdentifier
        /// HealthKit 数量类型。
        let quantityType: HKQuantityType
        /// 写入 Apple 健康时使用的单位。
        let unit: HKUnit
        /// 日志中展示用的中文名称。
        let title: String
    }

    /// 现有的核心营养素同步配置，保持原有热量、碳水、蛋白质、脂肪同步口径不变。
    private static let baseNutritionSyncItems: [HealthKitNutritionSyncItem] = [
        HealthKitNutritionSyncItem(key: "calories", identifier: .dietaryEnergyConsumed, unit: .kilocalorie(), title: "膳食能量"),
        HealthKitNutritionSyncItem(key: "carbohydrate", identifier: .dietaryCarbohydrates, unit: .gram(), title: "碳水"),
        HealthKitNutritionSyncItem(key: "protein", identifier: .dietaryProtein, unit: .gram(), title: "蛋白质"),
        HealthKitNutritionSyncItem(key: "fat", identifier: .dietaryFatTotal, unit: .gram(), title: "总脂肪")
    ]

    /// Apple 健康支持的其他营养素同步配置；反式脂肪、嘌呤、肌酸没有标准 HealthKit 类型，第一版不写入。
    private static let additionalNutritionSyncItems: [HealthKitNutritionSyncItem] = [
        HealthKitNutritionSyncItem(key: "fibre", identifier: .dietaryFiber, unit: .gram(), title: "纤维"),
        HealthKitNutritionSyncItem(key: "sugar", identifier: .dietarySugar, unit: .gram(), title: "糖"),
        HealthKitNutritionSyncItem(key: "saturatedFat", identifier: .dietaryFatSaturated, unit: .gram(), title: "饱和脂肪"),
        HealthKitNutritionSyncItem(key: "cholesterol", identifier: .dietaryCholesterol, unit: HKUnit.gramUnit(with: .milli), title: "胆固醇"),
        HealthKitNutritionSyncItem(key: "sodium", identifier: .dietarySodium, unit: HKUnit.gramUnit(with: .milli), title: "钠"),
        HealthKitNutritionSyncItem(key: "potassium", identifier: .dietaryPotassium, unit: HKUnit.gramUnit(with: .milli), title: "钾"),
        HealthKitNutritionSyncItem(key: "calcium", identifier: .dietaryCalcium, unit: HKUnit.gramUnit(with: .milli), title: "钙"),
        HealthKitNutritionSyncItem(key: "iron", identifier: .dietaryIron, unit: HKUnit.gramUnit(with: .milli), title: "铁"),
        HealthKitNutritionSyncItem(key: "vitaminA", identifier: .dietaryVitaminA, unit: HKUnit.gramUnit(with: .micro), title: "维生素 A"),
        HealthKitNutritionSyncItem(key: "vitaminC", identifier: .dietaryVitaminC, unit: HKUnit.gramUnit(with: .milli), title: "维生素 C"),
        HealthKitNutritionSyncItem(key: "caffeine", identifier: .dietaryCaffeine, unit: HKUnit.gramUnit(with: .milli), title: "咖啡因")
    ]

    /// 所有本次同步会处理的营养素配置。
    private static var nutritionSyncItems: [HealthKitNutritionSyncItem] {
        baseNutritionSyncItems + additionalNutritionSyncItems
    }

    /// 其他营养素同步支持的项目 key 集合，用于从日志中聚合每日总量。
    private static var additionalNutritionSyncKeys: Set<String> {
        Set(additionalNutritionSyncItems.map { $0.key })
    }

    /// 队列用于按顺序保存营养数据，避免并发写入导致重复
    private let nutritionSaveQueue = DispatchQueue(label: "com.lns.healthkit.nutritionSaveQueue")
    /// 营养同步状态串行队列，用于合并同一天的多次同步请求。
    private static let nutritionSyncQueue = DispatchQueue(label: "com.lns.healthkit.nutritionSyncQueue")
    /// 等待执行的每日营养同步请求，key 为日期。
    private static var pendingNutritionRequests: [String: NutritionSyncRequest] = [:]
    /// 当前日期正在等待去抖执行的任务，key 为日期。
    private static var debounceWorkItems: [String: DispatchWorkItem] = [:]
    /// 当前日期去抖任务的版本号，用于丢弃过期任务。
    private static var debounceGenerations: [String: Int] = [:]
    /// 正在执行 HealthKit 删除/保存的日期集合。
    private static var syncingDates: Set<String> = []
    /// 最近成功同步的指纹缓存，用于后续恢复跳过重复同步时复用。
    private static var lastSyncedFingerprints: [String: String] = [:]
    /// 同一天多次日志变更合并的等待时长。
    private static let debounceInterval: TimeInterval = 0.8

    /// 每日营养同步请求，values 中既包含原有四项，也可以包含 Apple 健康支持的其他营养素。
    private struct NutritionSyncRequest {
        /// 同步日期，格式为 yyyy-MM-dd。
        let cTime: String
        /// 各营养素的每日总量，key 使用项目内部字段名。
        let values: [String: Double]

        /// 当前请求是否包含任何大于 0 的营养素。
        var hasValue: Bool {
            values.values.contains { $0 > 0 }
        }

        /// 当前请求的去重指纹，保证同一天同数值不会被重复处理。
        var fingerprint: String {
            let valueText = Self.fingerprintText(from: values)
            return "\(cTime)|\(valueText)"
        }

        /// 将营养素字典转成稳定排序的指纹内容。
        private static func fingerprintText(from values: [String: Double]) -> String {
            values.keys.sorted().map { key in
                let value = values[key] ?? 0
                return "\(key):\(String(format: "%.3f", value))"
            }.joined(separator: "|")
        }
    }

//    旧的 NutritionSyncRequest 只保存 calories / carbs / protein / fat 四项；
//    当前结构改为 values 字典，以便在不影响旧入口的前提下扩展更多营养素。

//    /// 用于去抖动保存营养数据，key 为日期字符串
//    private static var saveWorkItems: [String: DispatchWorkItem] = [:]
//    /// 去抖动时间，单位秒
//    private static let debounceInterval: TimeInterval = 1.0

    /// 请求 Apple 健康读写权限；实际请求本 App 当前全部已接入的健康数据类型。
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

//        旧逻辑：这里只请求营养和饮水相关权限，可能导致首次弹窗只展示一部分健康权限。
//        // 设置我们需要读取和写入的数据类型
//        var readTypes: Set = [
//            caloriesType,
//            carbsType,
//            proteinType,
//            fatType
//        ]
//
//        var writeTypes: Set = [
//            caloriesType,
//            carbsType,
//            proteinType,
//            fatType
//        ]
//        for quantityType in Self.additionalNutritionSyncItems.compactMap({ $0.quantityType }) {
//            writeTypes.insert(quantityType)
//            readTypes.insert(quantityType)
//        }
//
//        let water_isAuthori = UserDefaults.getString(forKey: .health_water_Authori)
//        if water_isAuthori == "" || water_isAuthori == nil{
//            writeTypes.insert(waterType!)
//            readTypes.insert(waterType!)
//        }

        let natural_Authori = UserDefaults.getString(forKey: .health_sport_natural_calories)
        let needsAllHealthAuthorization = natural_Authori == "" || natural_Authori == nil || HealthKitPermissionTypesProvider.hasNotDeterminedShareType(in: healthStore)
        if needsAllHealthAuthorization{
            HealthKitPermissionTypesProvider.requestAllKnownHealthDataAuthorization(in: healthStore) { success, error in
                if success {
                    DLLog(message: "HealthKitNaturnalManager:健康APP  --  全部健康数据授权请求成功！")
                } else {
                    DLLog(message: "HealthKitNaturnalManager:健康APP  --  全部健康数据授权请求失败！\(error?.localizedDescription ?? "")")
                }
            }
        }
        UserDefaults.set(value: "1", forKey: .health_water_Authori)
        UserDefaults.set(value: "1", forKey: .health_sport_natural)
        UserDefaults.set(value: "1", forKey: .health_sport_natural_calories)
    }
    
    /// 请求 Apple 健康读写权限并通过回调返回结果；实际请求本 App 当前全部已接入的健康数据类型。
    func requestAuthorization(completeHandler: @escaping (Bool) -> ()) {
        let bodyData_Weight_Authori = UserDefaults.getString(forKey: .health_sport_natural_calories)
        let needsAllHealthAuthorization = bodyData_Weight_Authori == "" || bodyData_Weight_Authori == nil || HealthKitPermissionTypesProvider.hasNotDeterminedShareType(in: healthStore)
        if needsAllHealthAuthorization{
            UserDefaults.set(value: "1", forKey: .health_sport_natural_calories)
            guard HKHealthStore.isHealthDataAvailable() else { return }

//            旧逻辑：这里只请求本次营养同步类型，可能和运动/身体数据入口的权限弹窗拆开。
//            // 设置我们需要读取和写入的数据类型
//            let readTypes: Set = [
//                caloriesType,
//                carbsType,
//                proteinType,
//                fatType
//            ]
//
//            let writeTypes: Set = [
//                caloriesType,
//                carbsType,
//                proteinType,
//                fatType
//            ]
//            var allReadTypes = readTypes
//            var allWriteTypes = writeTypes
//            for quantityType in Self.additionalNutritionSyncItems.compactMap({ $0.quantityType }) {
//                allWriteTypes.insert(quantityType)
//                allReadTypes.insert(quantityType)
//            }
//            healthStore.requestAuthorization(toShare: allWriteTypes, read: allReadTypes) { success, error in
            HealthKitPermissionTypesProvider.requestAllKnownHealthDataAuthorization(in: healthStore) { success, error in
                if success {
                    DLLog(message: "HealthKitNaturnalManager:健康APP  --  全部健康数据授权请求成功！")
                    completeHandler(true)
                } else {
                    DLLog(message: "HealthKitNaturnalManager:健康APP  --  全部健康数据授权请求失败！\(error?.localizedDescription ?? "")")
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
    /// 保存原有四项每日营养数据到 Apple 健康，保留旧调用方式不变。
    func saveNutritionData(calories: Double,carbs: Double, protein: Double, fat: Double,cTime:String) {
        saveNutritionData(calories: calories,
                          carbs: carbs,
                          protein: protein,
                          fat: fat,
                          cTime: cTime,
                          additionalNutritionValues: [:])
    }

    /// 保存每日营养数据到 Apple 健康，包含原有四项和 Apple 健康支持的其他营养素。
    func saveNutritionData(calories: Double,carbs: Double, protein: Double, fat: Double,cTime:String,additionalNutritionValues: [String: Double]) {
        var values = additionalNutritionValues
        values["calories"] = calories
        values["carbohydrate"] = carbs
        values["protein"] = protein
        values["fat"] = fat
        let request = NutritionSyncRequest(cTime: cTime, values: normalizedNutritionValues(values))
        Self.nutritionSyncQueue.async {
            let existingWorkItem = Self.debounceWorkItems[cTime]
            existingWorkItem?.cancel()
            Self.pendingNutritionRequests[cTime] = request
            let generation = (Self.debounceGenerations[cTime] ?? 0) + 1
            Self.debounceGenerations[cTime] = generation

            let workItem = DispatchWorkItem {
                Self.nutritionSyncQueue.async {
                    guard Self.debounceGenerations[cTime] == generation else {
                        return
                    }
                    Self.debounceWorkItems.removeValue(forKey: cTime)
                    self.startNextNutritionSyncIfNeeded(for: cTime)
                }
            }
            Self.debounceWorkItems[cTime] = workItem
            DispatchQueue.global().asyncAfter(deadline: .now() + Self.debounceInterval, execute: workItem)
        }
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
//
//        nutritionSaveQueue.async {
//            let semaphore = DispatchSemaphore(value: 0)
//            self.performSaveNutritionData(calories: calories, carbs: carbs, protein: protein, fat: fat, cTime: cTime) {
//                semaphore.signal()
//            }
//            semaphore.wait()
//        }
    }

    /// 如果指定日期没有正在同步的任务，则开始处理最新的一次待同步请求。
    private func startNextNutritionSyncIfNeeded(for cTime: String) {
        guard !Self.syncingDates.contains(cTime),
              let request = Self.pendingNutritionRequests.removeValue(forKey: cTime) else {
            return
        }

//        if Self.lastSyncedFingerprints[cTime] == request.fingerprint {
//            DLLog(message: "HealthKitNaturnalManager:\(cTime) 营养数据未变化，跳过重复同步")
//            if Self.pendingNutritionRequests[cTime] != nil {
//                startNextNutritionSyncIfNeeded(for: cTime)
//            }
//            return
//        }
        
        Self.syncingDates.insert(cTime)
        performSaveNutritionData(request: request) { saveSucceeded in
            Self.nutritionSyncQueue.async {
                Self.syncingDates.remove(cTime)
                if request.hasValue && saveSucceeded {
                    Self.lastSyncedFingerprints[cTime] = request.fingerprint
                } else if !request.hasValue {
                    Self.lastSyncedFingerprints.removeValue(forKey: cTime)
                }
                self.startNextNutritionSyncIfNeeded(for: cTime)
            }
        }
    }

    /// 将每日同步请求交给实际写入流程处理。
    private func performSaveNutritionData(request: NutritionSyncRequest, completion: @escaping (Bool) -> Void) {
        performSaveNutritionData(values: request.values,
                                 cTime: request.cTime,
                                 completion: completion)
    }

        /// 兼容旧的固定四项同步方法，内部转成新的字典同步模型。
        private func performSaveNutritionData(calories: Double,carbs: Double, protein: Double, fat: Double,cTime:String, completion: @escaping (Bool) -> Void) {
            let values = normalizedNutritionValues([
                "calories": calories,
                "carbohydrate": carbs,
                "protein": protein,
                "fat": fat
            ])
            performSaveNutritionData(values: values, cTime: cTime, completion: completion)
        }

        /// 真正执行每日营养同步：校验日期、确认授权、删除旧样本、保存新样本。
        private func performSaveNutritionData(values: [String: Double],cTime:String, completion: @escaping (Bool) -> Void) {
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
            completion(false)
            return
        }
        DLLog(message: "HealthKitNaturnalManager:\(cTime) 的数据存入健康APP----------")

        var date = Date()
        if cTime != Date().nextDay(days: 0){//如果不是修改的今日数据，则修改添加时间为当天的 18:00
            date = Date().changeDateStringToDate(dateString: "\(cTime) 20:00:00",formatter: "yyyy-MM-dd HH:mm:ss")
        }

        let requestedItems = resolvedNutritionSyncItems(for: values)
        requestNutritionAuthorizationIfNeeded(for: requestedItems) { authorizedItems in
            guard authorizedItems.isEmpty == false else {
                DLLog(message: "HealthKitNaturnalManager:\(cTime) 没有可写入的营养授权")
                completion(false)
                return
            }

            let samples = self.nutritionSamples(from: values, items: authorizedItems, date: date, cTime: cTime)
            DLLog(message: "HealthKitNaturnalManager:\(cTime) - 同步营养数据 \(values)")
            // 删除旧的样本数据，确保不会累加
            self.deleteOldNutritionData(sDate: cTime, values: values, items: authorizedItems) { success ,hasData in
                if samples.isEmpty == false {
                    // 在删除成功后保存新数据
                    self.healthStore.save(samples) { (success, error) in
                        if success {
                            DLLog(message: "HealthKitNaturnalManager:\(cTime) -成功保存营养数据！")
                        } else {
                            DLLog(message: "HealthKitNaturnalManager:\(cTime) -保存失败：\(String(describing: error))")
                        }
                        completion(success)
                    }
                } else {
                    if success {
                        DLLog(message: "HealthKitNaturnalManager:\(cTime) -营养数据已清空，不写入 0 样本")
                    } else {
                        DLLog(message: "HealthKitNaturnalManager:\(cTime) -清空营养数据失败")
                    }
                    completion(success)
                }
            }
       }
   }
   // 删除旧的营养数据
    /// 删除旧版固定四项营养数据，保留旧调用方式不变。
    func deleteOldNutritionData(sDate:String,calories: Double,carbs: Double, protein: Double, fat: Double,completion: @escaping (Bool,Bool) -> Void) {
        let values = normalizedNutritionValues([
            "calories": calories,
            "carbohydrate": carbs,
            "protein": protein,
            "fat": fat
        ])
        deleteOldNutritionData(sDate: sDate, values: values, items: resolvedNutritionSyncItems(for: values), completion: completion)
    }

   /// 删除指定日期、指定营养素类型中由本 App 写入的旧样本。
    private func deleteOldNutritionData(sDate:String,values: [String: Double],items: [ResolvedHealthKitNutritionSyncItem],completion: @escaping (Bool,Bool) -> Void) {
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
        if items.isEmpty {
            completion(true, false)
            return
        }

        for item in items {
            group.enter()
            let query = HKSampleQuery(sampleType: item.quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
                if let results = results {
                    let value = values[item.key] ?? 0
                    DLLog(message: "HealthKitNaturnalManager:\(item.title)数据\(sDate) - \(results)")
                    self.filterAndDeleteSamples(results, data: value, group: group){ d in
                        hasData = true
                    }
                    group.leave()
                }else{
                    group.leave()
                }
            }
            // 执行查询删除数据
            healthStore.execute(query)
        }

       group.notify(queue: .global()) {
           // 通过闭包回调，通知删除操作完成
           completion(true,hasData)
       }
   }

   /// 从日志日期字典中聚合 Apple 健康支持的其他营养素每日总量。
    static func additionalNutritionValues(from dayDict: NSDictionary) -> [String: Double] {
        var values: [String: Double] = [:]
        for key in additionalNutritionSyncKeys {
            if let topLevelValue = topLevelNutritionValue(forKey: key, in: dayDict) {
                values[key] = topLevelValue
            } else {
                values[key] = foodsNutritionTotal(forKey: key, in: dayDict)
            }
        }
        return normalizedNutritionValues(values)
    }

   /// 从日志 foods 数组中聚合 Apple 健康支持的其他营养素每日总量。
    static func additionalNutritionValues(fromFoods mealsArray: NSArray) -> [String: Double] {
        var values: [String: Double] = [:]
        for key in additionalNutritionSyncKeys {
            values[key] = foodsNutritionTotal(forKey: key, inFoods: mealsArray)
        }
        return normalizedNutritionValues(values)
    }

   /// 将营养素数值统一成 HealthKit 可接受的非负有限值。
    private static func normalizedNutritionValues(_ values: [String: Double]) -> [String: Double] {
        var normalizedValues: [String: Double] = [:]
        for (key, value) in values {
            if value.isFinite && value > 0 {
                normalizedValues[key] = value
            } else {
                normalizedValues[key] = 0
            }
        }
        return normalizedValues
    }

   /// 将实例方法中传入的营养素数值统一成 HealthKit 可接受的非负有限值。
    private func normalizedNutritionValues(_ values: [String: Double]) -> [String: Double] {
        Self.normalizedNutritionValues(values)
    }

   /// 优先读取当天字典里的顶层营养素总量，支持 keyDouble 和 key 两种字段名。
    private static func topLevelNutritionValue(forKey key: String, in dayDict: NSDictionary) -> Double? {
        let doubleKey = "\(key)Double"
        let doubleRawValue = dayDict.rawStringValueForKey(key: doubleKey)
        if doubleRawValue.count > 0 {
            return max(dayDict.doubleValueForKey(key: doubleKey), 0)
        }

        let rawValue = dayDict.rawStringValueForKey(key: key)
        if rawValue.count > 0 {
            return max(dayDict.doubleValueForKey(key: key), 0)
        }
        return nil
    }

   /// 遍历当天 foods，累加 state 为 1 的食物营养素数值。
    private static func foodsNutritionTotal(forKey key: String, in dayDict: NSDictionary) -> Double {
        let mealsArray = dayDict["foods"] as? NSArray ?? []
        return foodsNutritionTotal(forKey: key, inFoods: mealsArray)
    }

   /// 遍历指定 foods 数组，累加 state 为 1 的食物营养素数值。
    private static func foodsNutritionTotal(forKey key: String, inFoods mealsArray: NSArray) -> Double {
        var total = Double(0)
        for i in 0..<mealsArray.count {
            let mealFoodsArray = mealsArray[i] as? NSArray ?? []
            for j in 0..<mealFoodsArray.count {
                let foodDict = mealFoodsArray[j] as? NSDictionary ?? [:]
                guard foodDict.stringValueForKey(key: "state") == "1" else { continue }
                total += foodDict.doubleValueForKey(key: key)
            }
        }
        return max(total, 0)
    }

   /// 根据本次同步 values 解析出存在 HealthKit 标准类型的营养素配置。
    private func resolvedNutritionSyncItems(for values: [String: Double]) -> [ResolvedHealthKitNutritionSyncItem] {
        Self.nutritionSyncItems.compactMap { item in
            guard values[item.key] != nil,
                  let quantityType = item.quantityType else { return nil }
            return ResolvedHealthKitNutritionSyncItem(key: item.key,
                                                      identifier: item.identifier,
                                                      quantityType: quantityType,
                                                      unit: item.unit,
                                                      title: item.title)
        }
    }

   /// 保存营养前补齐 Apple 健康权限请求，并只返回用户已允许写入的营养项目。
    private func requestNutritionAuthorizationIfNeeded(for items: [ResolvedHealthKitNutritionSyncItem],completion: @escaping ([ResolvedHealthKitNutritionSyncItem]) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion([])
            return
        }

        let quantityTypes = items.map { $0.quantityType }
        let unauthorizedTypes = quantityTypes.filter { healthStore.authorizationStatus(for: $0) != .sharingAuthorized }
        guard unauthorizedTypes.isEmpty == false else {
            completion(items)
            return
        }

//        旧逻辑：只为本次需要保存的营养素请求权限，首次弹窗可能只出现营养权限。
//        let shareTypes = Set<HKSampleType>(quantityTypes)
//        let readTypes = Set<HKObjectType>(quantityTypes)
//        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { success, error in
        HealthKitPermissionTypesProvider.requestAllKnownHealthDataAuthorization(in: healthStore) { success, error in
            if success {
                DLLog(message: "HealthKitNaturnalManager:健康APP  --  全部健康数据授权请求成功！")
            } else {
                DLLog(message: "HealthKitNaturnalManager:健康APP  --  全部健康数据授权请求失败！\(error?.localizedDescription ?? "")")
            }
            let authorizedItems = items.filter { self.healthStore.authorizationStatus(for: $0.quantityType) == .sharingAuthorized }
            completion(authorizedItems)
        }
    }

   /// 根据营养素数值和 HealthKit 配置生成要保存的新样本，0 值不写入样本。
    private func nutritionSamples(from values: [String: Double],items: [ResolvedHealthKitNutritionSyncItem],date: Date,cTime: String) -> [HKQuantitySample] {
        return items.compactMap { item in
            let value = values[item.key] ?? 0
            guard value > 0 else { return nil }
            let quantity = HKQuantity(unit: item.unit, doubleValue: value)
            return HKQuantitySample(type: item.quantityType,
                                    quantity: quantity,
                                    start: date,
                                    end: date,
                                    metadata: nutritionSampleMetadata(cTime: cTime, item: item))
        }
    }

    /// 生成营养同步样本的元数据，用于 HealthKit 按日期和营养素类型识别同一条每日总量样本。
    private func nutritionSampleMetadata(cTime: String, item: ResolvedHealthKitNutritionSyncItem) -> [String: Any] {
        [
            HKMetadataKeySyncIdentifier: nutritionSyncIdentifier(cTime: cTime, item: item),
            HKMetadataKeySyncVersion: healthKitSyncVersion(),
            "lns.healthkit.syncType": "dailyNutritionTotal",
            "lns.healthkit.sdate": cTime,
            "lns.healthkit.nutritionKey": item.key
        ]
    }

    private func nutritionSyncIdentifier(cTime: String, item: ResolvedHealthKitNutritionSyncItem) -> String {
        let userId = UserInfoModel.shared.id.count > 0 ? UserInfoModel.shared.id : "anonymous"
        return "ela.\(userId).\(item.identifier.rawValue).\(cTime)"
    }

    private func healthKitSyncVersion() -> Int {
        Int(Date().timeIntervalSince1970 * 1000)
    }
}

extension HealthKitNaturnalManager{
   // 过滤和删除来自你应用的数据
    func filterAndDeleteSamples(_ samples: [HKSample],data:Double,group:DispatchGroup,completion: @escaping (Bool) -> Void) {
//       let group = DispatchGroup()
       for sample in samples {
           // 判断是否为你应用的数据源
           DLLog(message: "HealthKitNaturnalManager:(filterAndDeleteSamples) \(sample)")
           if isSampleWrittenByCurrentApp(sample){
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

    /// 判断 HealthKit 样本是否由当前 App 写入，避免误删其他 App 的健康数据。
    private func isSampleWrittenByCurrentApp(_ sample: HKSample) -> Bool {
        let currentBundleIdentifier = Bundle.main.bundleIdentifier ?? "com.lns.elavatine"
        return sample.sourceRevision.source.bundleIdentifier == currentBundleIdentifier
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
