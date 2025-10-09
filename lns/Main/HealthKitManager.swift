//
//  HealthKitManager.swift
//  lns
//
//  Created by LNS2 on 2024/8/6.
//
import HealthKit

class HealthKitManager: NSObject, ObservableObject {
    let healthStore = HKHealthStore()
    
    let healthKitTypesToRead = HKObjectType.workoutType()
    let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)
    let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater)//饮水
    let activeEnergyBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
    let waistType = HKObjectType.quantityType(forIdentifier: .waistCircumference)//腰围
    let bodyFatType = HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)//体脂率
    let carboType = HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)
    let caloriesType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)
    var hkWorkouts: [HKWorkoutActivityType] = [HKWorkoutActivityType]()
    
    override init() {
        super.init()
        var shareType = Set<HKSampleType>()
        
        if HKHealthStore.isHealthDataAvailable() {
//            if healthStore.authorizationStatus(for: weightType!) == HKAuthorizationStatus.sharingAuthorized &&
//                healthStore.authorizationStatus(for: waistType!) == HKAuthorizationStatus.sharingAuthorized &&
//                healthStore.authorizationStatus(for: carboType!) == HKAuthorizationStatus.sharingAuthorized &&
//                healthStore.authorizationStatus(for: caloriesType!) == HKAuthorizationStatus.sharingAuthorized &&
//                healthStore.authorizationStatus(for: waterType!) == HKAuthorizationStatus.sharingAuthorized &&
//                healthStore.authorizationStatus(for: activeEnergyBurnedType!) == HKAuthorizationStatus.sharingAuthorized{
////                &&
////                healthStore.authorizationStatus(for: healthKitTypesToRead) == HKAuthorizationStatus.sharingAuthorized{
//                
//            }else{
//                let bodyData_Weight_Authori = UserDefaults.getString(forKey: .bodyData_Weight_Authori)
//                if bodyData_Weight_Authori == "" || bodyData_Weight_Authori == nil{
//                    shareType.insert(weightType!)
//                }
//                let health_waist_Authori = UserDefaults.getString(forKey: .health_waist_Authori)
//                if health_waist_Authori == "" || health_waist_Authori == nil{
//                    shareType.insert(waistType!)
//                    shareType.insert(bodyFatType!)
//                }
//                let natural_Authori = UserDefaults.getString(forKey: .health_sport_natural)
//                if natural_Authori == "" || natural_Authori == nil{
//                    shareType.insert(caloriesType!)
//                    shareType.insert(carboType!)
//                    shareType.insert(HKObjectType.quantityType(forIdentifier: .dietaryProtein)!)
//                    shareType.insert(HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!)
//                }
//                let natural_Authori_calories = UserDefaults.getString(forKey: .health_sport_natural_calories)
//                if natural_Authori_calories == "" || natural_Authori_calories == nil && !shareType.contains(caloriesType!){
//                    shareType.insert(caloriesType!)
//                }
//                let sport_isAuthori = UserDefaults.getString(forKey: .health_sport_Authori)
//                if sport_isAuthori == "" || sport_isAuthori == nil{
//                    shareType.insert(healthKitTypesToRead)
//                }
//                let water_isAuthori = UserDefaults.getString(forKey: .health_water_Authori)
//                if water_isAuthori == "" || water_isAuthori == nil{
//                    shareType.insert(waterType!)
//                }
//            }
            if let weightType = weightType,
               healthStore.authorizationStatus(for: weightType) != .sharingAuthorized {
                shareType.insert(weightType)
            }
            if let waistType = waistType,
               healthStore.authorizationStatus(for: waistType) != .sharingAuthorized {
                shareType.insert(waistType)
            }
            if let bodyFatType = bodyFatType,
               healthStore.authorizationStatus(for: bodyFatType) != .sharingAuthorized {
                shareType.insert(bodyFatType)
            }
            if let caloriesType = caloriesType,
               healthStore.authorizationStatus(for: caloriesType) != .sharingAuthorized {
                shareType.insert(caloriesType)
            }
            if let carboType = carboType,
               healthStore.authorizationStatus(for: carboType) != .sharingAuthorized {
                shareType.insert(carboType)
            }
            if let proteinType = HKObjectType.quantityType(forIdentifier: .dietaryProtein),
               healthStore.authorizationStatus(for: proteinType) != .sharingAuthorized {
                shareType.insert(proteinType)
            }
            if let fatType = HKObjectType.quantityType(forIdentifier: .dietaryFatTotal),
               healthStore.authorizationStatus(for: fatType) != .sharingAuthorized {
                shareType.insert(fatType)
            }
            if let waterType = waterType,
               healthStore.authorizationStatus(for: waterType) != .sharingAuthorized {
                shareType.insert(waterType)
            }
            if let activeEnergyBurnedType = activeEnergyBurnedType,
               healthStore.authorizationStatus(for: activeEnergyBurnedType) != .sharingAuthorized {
                shareType.insert(activeEnergyBurnedType)
            }
            if healthStore.authorizationStatus(for: healthKitTypesToRead) != .sharingAuthorized {
                shareType.insert(healthKitTypesToRead)
            }
            if shareType.count > 0 {
                UserDefaults.set(value: "1", forKey: .bodyData_Weight_Authori)
                UserDefaults.set(value: "1", forKey: .health_waist_Authori)
                UserDefaults.set(value: "1", forKey: .health_sport_natural)
                UserDefaults.set(value: "1", forKey: .health_sport_natural_calories)
                UserDefaults.set(value: "1", forKey: .health_sport_Authori)
                UserDefaults.set(value: "1", forKey: .health_water_Authori)
                
                healthStore.requestAuthorization(toShare: shareType, read: shareType) { success, error in
                    if let error = error {
                        print("Error requesting health authorization: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func getLatestWeightSample(completion: @escaping (HKQuantity?) -> Void) {
        guard let weightType = weightType else { return }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let monthsAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: monthsAgo, end: Date(), options: .strictStartDate)
        
        let sampleQuery = HKSampleQuery(sampleType: weightType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, results, error in
            guard let results = results, !results.isEmpty, error == nil else {
                completion(nil)
                return
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
            dateFormatter.calendar = Calendar.init(identifier: .gregorian)
            dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone.current//TimeZone(secondsFromGMT: 0)
            
            DispatchQueue.global(qos: .userInitiated).async {
                var sDate = ""
                let deleteSdates = UserDefaults.getWeightSdate()
                for i in 0..<results.count{
                    let result = results[i] as? HKQuantitySample
                    let value = result?.quantity.doubleValue(for: HKUnit(from: "kg"))
                    
                    let time = Date().changeZeroAreaToZHTimeZone(dateString: dateFormatter.string(from: result?.startDate ?? Date()))
                    
                    DLLog(message: "HealthKitManager:\(time)  -------   \(value)")
                    if time != sDate && !deleteSdates.contains(time){
                        var weight = String(format: "%.2f", value ?? 0)
                        weight = weight.replacingOccurrences(of: ",", with: ".")
                        DLLog(message: "HealthKitManager:\(time)  --   \(weight)")
                        
                        if weight.floatValue > 0 {
//                            BodyDataSQLiteManager.getInstance().updateWeightDataFromHealthKit(cTime: time, weightData: weight)
//                            BodyDataSQLiteManager.getInstance().updateUploadStatus(cTime: time, uploadStatus: false)
//                            BodyDataUploadManager().sendWeightDataRequest(sDate: time, weightData: weight)
                            let info = BodyDataSQLiteManager.getInstance().queryWeightInfo(sDate: time)
                            if info == nil || !(info!.isUpload && info!.weight == weight) {
                                BodyDataSQLiteManager.getInstance().updateWeightDataFromHealthKit(cTime: time, weightData: weight)
                                BodyDataSQLiteManager.getInstance().updateUploadStatus(cTime: time, uploadStatus: false)
                                BodyDataUploadManager().sendWeightDataRequest(sDate: time, weightData: weight)
                            }
                        }
                    }
                    sDate = time
                }
            }
        }
        healthStore.execute(sampleQuery)
    }
 
    func saveWeight(weight: HKQuantity,sdate:String, completion: @escaping (Bool, Error?) -> Void) {
        guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else { return }
        
        let currentTimeString = Date().currentSeconds
        let dateString = currentTimeString.replacingOccurrences(of: Date().todayDate, with: sdate)
        
        let date = Date().changeDateStringToDate(dateString: dateString,formatter: "yyyy-MM-dd HH:mm:ss")
        let weightSample = HKQuantitySample(type: weightType, quantity: weight, start: date, end: date)
 
        healthStore.save(weightSample) { (success, error) in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    func getTrainingData(completion: @escaping (Double) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
 
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
 
        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let activeEnergy = result.sumQuantity() else {
                completion(0.0)
                return
            }
            
            let activeEnergyBurned = activeEnergy.doubleValue(for: HKUnit.largeCalorie())
            
            completion(activeEnergyBurned)
        }
 
        healthStore.execute(query)
    }
//    
//   func getLatestActiveEnergyBurnedTypeSample(completion: @escaping (HKQuantity?) -> Void) {
//       guard let weightType = activeEnergyBurnedType else { return }
//       let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
//       
//       let monthsAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
//       let predicate = HKQuery.predicateForSamples(withStart: monthsAgo, end: Date(), options: .strictStartDate)
//       
//       let sampleQuery = HKSampleQuery(sampleType: weightType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, results, error in
//           guard let results = results, !results.isEmpty, error == nil else {
//               completion(nil)
//               return
//           }
//           let dateFormatter = DateFormatter()
//           dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
//           dateFormatter.calendar = Calendar.init(identifier: .gregorian)
//           dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
//           dateFormatter.timeZone = TimeZone.current//TimeZone(secondsFromGMT: 0)
//           
//           DispatchQueue.global(qos: .userInitiated).async {
//               var sDate = ""
//               for i in 0..<results.count{
//                   let result = results[i] as? HKQuantitySample
////                   DLLog(message: "getLatestActiveEnergyBurnedTypeSample:      \(result)")
//                   let quantity = result?.quantity
////                   DLLog(message: "getLatestActiveEnergyBurnedTypeSample:(quantity)      \(quantity)")
//                   let startTime = Date().changeZeroAreaToZHTimeZone(dateString: dateFormatter.string(from: result?.startDate ?? Date()),targetFormatter: "yyyy-MM-dd HH:mm:ss")
//                   let endTime = Date().changeZeroAreaToZHTimeZone(dateString: dateFormatter.string(from: result?.endDate ?? Date()),targetFormatter: "yyyy-MM-dd HH:mm:ss")
////                   DLLog(message: "getLatestActiveEnergyBurnedTypeSample:      \(startTime)  ~  \(endTime)")
//               }
//           }
//       }
//       healthStore.execute(sampleQuery)
//   }
    func authorizeHealthKitWorkouts(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            completion(false, nil)
            return
        }
        let typesToShare: Set<HKSampleType> = [healthKitTypesToRead]
                var typesToRead: Set<HKObjectType> = [healthKitTypesToRead]
                if let activeEnergyBurnedType {
                    typesToRead.insert(activeEnergyBurnedType)
                }
        if healthStore.authorizationStatus(for: healthKitTypesToRead) == HKAuthorizationStatus.sharingAuthorized{
            completion(true, nil)
//        }else{
//            let isAuthori = UserDefaults.getString(forKey: .health_sport_Authori)
//            if isAuthori == "" || isAuthori == nil{
//                completion(false, nil)
////                UserDefaults.set(value: "1", forKey: .health_sport_Authori)
////                healthStore.requestAuthorization(toShare: [healthKitTypesToRead,activeEnergyBurnedType!], read: [healthKitTypesToRead,activeEnergyBurnedType!]) { success, error in
////                    completion(success, error)
////                }
//            }else{
//                completion(true, nil)
        } else {
//            completion(false, nil)
            healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
                if success {
                    UserDefaults.set(value: "1", forKey: .health_sport_Authori)
                }
                completion(success, error)
            }
        }
    }
    func getWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        let workoutType = HKObjectType.workoutType()
//        let predicate =  HKQuery.predicateForWorkouts(with: workoutType)
        let monthsAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        
//        let calendar = Calendar.current
//        var dateComponents = calendar.dateComponents([.year,.month,.day], from: Date())
//        dateComponents.hour = 0
//        dateComponents.minute = 0
//        dateComponents.second = 0
        
        let predicateTime = HKQuery.predicateForSamples(withStart: monthsAgo, end: Date(), options: .strictStartDate)
        
//        let predicateQuere = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate,predicateTime])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
 
        let sampleQuery = HKSampleQuery(sampleType: workoutType, predicate: predicateTime, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, results, error in
            guard let workouts = results as? [HKWorkout] else {
                completion(nil, error)
                DLLog(message: "getWorkouts:   error")
                return
            }
            DLLog(message: "getWorkouts:   \(workouts)")
            completion(workouts, nil)
        }
 
        healthStore.execute(sampleQuery)
    }
    func getAllRunningWorkOutsData() {
        var didWorkOuts:[HKWorkoutActivityType] = [HKWorkoutActivityType]()
        for workout in hkWorkouts {
//            let workout = hkWorkouts.first
            
            if didWorkOuts.contains(workout){
                continue
            }else{
                didWorkOuts.append(workout)
                readRunningWorkOuts(workoutType: workout) { results, error in
                    if error == nil{
                        self.dealRunningData(results: results, workType: workout)
                    }
                }
            }
        }
    }
    func readRunningWorkOuts(workoutType:HKWorkoutActivityType,completion: (([HKSample]?, NSError?) -> Void)!) {
            // 1. Predicate to read only running workouts
        let predicate =  HKQuery.predicateForWorkouts(with: workoutType)
        let monthsAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let predicateTime = HKQuery.predicateForSamples(withStart: monthsAgo, end: Date(), options: .strictStartDate)
        
        let predicateQuere = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate,predicateTime])
            // 2. Order the workouts by date
            let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending:false)
        
            // 3. Create the query
            let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: predicateQuere, limit: 0, sortDescriptors: [sortDescriptor]){ (sampleQuery, results, error ) -> Void in
                if let queryError = error {
                    DLLog(message: "There was an error while reading the samples: \(queryError.localizedDescription)")
                }
                completion(results,error as NSError?)
            }
            // 4. Execute the query
        healthStore.execute(sampleQuery)
    }
    
    func dealRunningData(results:[HKSample]?,workType:HKWorkoutActivityType) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        dateFormatter.calendar = Calendar.init(identifier: .gregorian)
        dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current//TimeZone(secondsFromGMT: 0)
        
        let deleteUUidsArray = UserDefaults.getSportUUID()
        DLLog(message: "dealRunningData (results):\(results)")
        for i in 0..<(results?.count ?? 0){
            let result = results?[i] as? HKWorkout
            
            if deleteUUidsArray.contains(result?.uuid.uuidString ?? "uuids") || result?.workoutActivityType != workType{
                continue
            }
            
//            let metadata = result?.metadata as? NSDictionary ?? [:]
            let sourceRevision = result?.sourceRevision.source.name
            let time = Date().changeZeroAreaToZHTimeZone(dateString: dateFormatter.string(from: result?.startDate ?? Date()))
            DLLog(message: "dealRunningData (result):\(result)")
            DLLog(message: "dealRunningData (卡路里):\(result?.totalEnergyBurned?.doubleValue(for: HKUnit(from: "kcal")) ?? 0)")
            DLLog(message: "dealRunningData (开始时间):\(time)")
            DLLog(message: "dealRunningData (来源):\(sourceRevision ?? "数据来源")")
//            if metadata.stringValueForKey(key: "HKWasUserEntered") == "1" && time.contains(Date().todayDate){
            if sourceRevision?.contains("Elavatine") == false{
//                if (time.contains(Date().todayDate) || time.contains(Date().nextDay(days: -1))) && (sourceRevision?.contains("Elavatine") == false){
                    
                var prancerciseWorkout = PrancerciseWorkout(calories: "0")
                prancerciseWorkout.id = result?.uuid.uuidString ?? ""
                prancerciseWorkout.name = SportCatogaryItemModel().dealTypeName(type: HKWorkoutActivityType(rawValue: (result?.workoutActivityType)!.rawValue) ?? HKWorkoutActivityType.other)
                
                let durationSeconds = Int(result?.duration ?? 0)
                prancerciseWorkout.duration = WHUtils.convertStringToStringOneDigit("\(Float(durationSeconds/60).rounded())") ?? "0"
                prancerciseWorkout.start = result?.startDate ?? Date()
                prancerciseWorkout.end = result?.endDate ?? Date()
                prancerciseWorkout.calories = WHUtils.convertStringToString("\(result?.totalEnergyBurned?.doubleValue(for: HKUnit(from: "kcal")) ?? 0)") ?? "0"
                self.sendAddSportRequest(prancerciseWorkout: prancerciseWorkout,sdate: time)
            }
        }
    }
    //将运动消耗，存储到健康APP
    func saveRunningDataToHealthKitApp(workoutType:HKWorkoutActivityType,prancerciseWorkout:PrancerciseWorkout) {
//        let prancerciseWorkout = PrancerciseWorkout(start: Date().getFirstHourOfCurrentDate(minute: 1)!, end: Date())
        //1. Setup the Calorie Quantity for total energy burned
        let calorieQuantity = HKQuantity(unit: HKUnit.kilocalorie(),
                                         doubleValue: prancerciseWorkout.calories.doubleValue)

        //2. Build the workout using data from your Prancercise workout
        let workout = HKWorkout(activityType: workoutType,
                                start: prancerciseWorkout.start,
                                end: prancerciseWorkout.end,
                                duration: prancerciseWorkout.second,
                                totalEnergyBurned: calorieQuantity,
                                totalDistance: nil,
                                device: HKDevice.local(),
                                metadata: nil)
        //3. Save your workout to HealthKit
//        let healthStore = HKHealthStore()
        healthStore.save(workout) { (success, error) in
            DLLog(message: "saveRunningData:\(success)      -    \(error)")
        }
//        DispatchQueue.main.asyncAfter(deadline: .now()+20, execute: {
//            self.healthStore.delete(workout) { success, error in
//                DLLog(message: "saveRunningData(delete):\(success)      -    \(error)")
//            }
//        })
        
    }
    func deleteRunningDataForHealthKitApp(workoutType:HKWorkoutActivityType,prancerciseWorkout:PrancerciseWorkout) {
        let calorieQuantity = HKQuantity(unit: HKUnit.kilocalorie(),
                                         doubleValue: prancerciseWorkout.calories.doubleValue)
        
        //2. Build the workout using data from your Prancercise workout
        let workout = HKWorkout(activityType: workoutType,
                                start: prancerciseWorkout.start,
                                end: prancerciseWorkout.end,
                                duration: prancerciseWorkout.second,
                                totalEnergyBurned: calorieQuantity,
                                totalDistance: nil,
                                device: HKDevice.local(),
                                metadata: nil)
        self.healthStore.delete(workout) { success, error in
            DLLog(message: "saveRunningData(delete):\(success)      -    \(error)")
        }
    }
    func sendAddSportRequest(prancerciseWorkout:PrancerciseWorkout,sdate:String) {
//        let sportCaloriesInTarget = UserInfoModel.shared.statSportDataFromHealth == "2" ? "1": "0"
        let sportCaloriesInTarget = UserInfoModel.shared.statSportDataToTarget// == "1" ? "1": "0"

        let param = ["sdate":"\(sdate)",
//                     "sdate":"\(Date().todayDate)",
                     "sportItemId":"\(prancerciseWorkout.id)",
                     "sportItemName":"\(prancerciseWorkout.name)",
                     "duration":"\(prancerciseWorkout.duration)".replacingOccurrences(of: ",", with: "."),
                     "weight":"",
//                     "sportCaloriesInTarget":sportCaloriesInTarget,
                     "source":"\(prancerciseWorkout.source)",
                     "calories":"\(prancerciseWorkout.calories)".replacingOccurrences(of: ",", with: ".")]
        DLLog(message: "sendAddSportRequest By HealthKit APP (param) :\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_sport_add, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: "sendAddSportRequest By HealthKit APP :\(responseObject)")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        }
    }
}

