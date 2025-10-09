//
//  LogsLogsSQLiteManager.swift
//  lns
//
//  Created by LNS2 on 2024/5/6.
//

import Foundation
import SQLite
import UMCommon

struct LogsModel{
    let uid   : String
    let sdate : String
    let date  : Date
    let ctime : String
    let etime : String
    let foods : String
    let calori : String
    let protein : String
    let carbohydrate : String
    let fat : String
    let notes : String
    
    let caloriTarget : String
    let proteinTarget : String
    let carbohydrateTarget : String
    let fatTarget : String
    
    var isUpload : Bool
    
    var waterNum:String
    var waterUpload:String
    var waterETime:String
    
    var circleTag : String
    var fitnessTag : String
    
    var notesTag : String
    
    func logMsg() {
        DLLog(message: "\(self.sdate)  --  \(self.calori)  - \(self.protein)  -  \(self.carbohydrate)  - \(self.fat)  | \(self.notes)")
//        DLLog(message: "\(self.foods)")
    }
    func modelToDict() -> NSDictionary {
        return ["sdate":"\(self.sdate)",
                "calories":"\(self.calori)",
                "caloriesden":"\(self.caloriTarget)",
                "carbohydrate":"\(self.carbohydrate)",
                "carbohydrateden":"\(self.carbohydrateTarget)",
                "fat":"\(self.fat)",
                "fatden":"\(self.fatTarget)",
                "protein":"\(self.protein)",
                "proteinden":"\(self.proteinTarget)",
                "notes":"\(self.notes)",
                "notesTag":"\(self.notesTag)",
                "waterNum":self.waterNum,
                "waterUpload":self.waterUpload,
                "waterETime":self.waterETime,
                "carbLabel":self.circleTag,
                "fitnessLabel":self.fitnessTag,
                "foods":WHUtils.getArrayFromJSONString(jsonString: self.foods)]
    }
}

class LogsSQLiteManager {
    
    static let shared = LogsSQLiteManager()
    
    private var db: Connection?
//    let db = try! Connection("/path/to/db.sqlite3")
    private let logs = Table("logs")
//    private let uid   = Expression<String>(value: "uid")
//    private let sdate = Expression<String>(value: "sdate")
//    private let date  = Expression<Date?>(value: "date")
//    private let ctime = Expression<String?>(value: "ctime")
//    private let etime = Expression<String?>(value: "etime")
//    private let foods = Expression<String?>(value: "foods")
//    private let calori = Expression<String?>(value: "calori")
//    private let protein = Expression<String?>(value: "protein")
//    private let carbohydrate = Expression<String?>(value: "carbohydrate")
//    private let fat = Expression<String?>(value: "fat")
//    private let caloriTarget = Expression<String?>(value: "caloriTarget")
//    private let proteinTarget = Expression<String?>(value: "proteinTarget")
//    private let carbohydrateTarget = Expression<String?>(value: "carbohydrateTarget")
//    private let fatTarget = Expression<String?>(value: "fatTarget")
//    private let notes = Expression<String?>(value: "notes")
//    private let isUpload = Expression<Bool?>(value: "isUpload")
//    private let isUploadString = Expression<String?>(value: "isUploadString")
//    private let meal_time_sn1 = Expression<String?>(value: "meal_time_sn1")
//    private let meal_time_sn2 = Expression<String?>(value: "meal_time_sn2")
//    private let meal_time_sn3 = Expression<String?>(value: "meal_time_sn3")
//    private let meal_time_sn4 = Expression<String?>(value: "meal_time_sn4")
//    private let meal_time_sn5 = Expression<String?>(value: "meal_time_sn5")
//    private let meal_time_sn6 = Expression<String?>(value: "meal_time_sn6")
//    private let water_num = Expression<String?>(value: "water_num")
//    private let water_upload = Expression<String?>(value: "water_upload")
//    private let water_etime = Expression<String?>(value: "water_etime")
//    private let circle_tag = Expression<String?>(value: "circle_tag")
//    private let fitness_tag = Expression<String?>(value: "fitness_tag")
//    private let notes_tag = Expression<String?>(value: "notes_tag")
    private let uid   = Expression<String>("uid")
    private let sdate = Expression<String>("sdate")
    private let date  = Expression<Date?>("date")
    private let ctime = Expression<String?>("ctime")
    private let etime = Expression<String?>("etime")
    private let foods = Expression<String?>("foods")
    private let calori = Expression<String?>("calori")
    private let protein = Expression<String?>("protein")
    private let carbohydrate = Expression<String?>("carbohydrate")
    private let fat = Expression<String?>("fat")
    private let caloriTarget = Expression<String?>("caloriTarget")
    private let proteinTarget = Expression<String?>("proteinTarget")
    private let carbohydrateTarget = Expression<String?>("carbohydrateTarget")
    private let fatTarget = Expression<String?>("fatTarget")
    private let notes = Expression<String?>("notes")
    private let isUpload = Expression<Bool?>("isUpload")
    private let isUploadString = Expression<String?>("isUploadString")
    private let meal_time_sn1 = Expression<String?>("meal_time_sn1")
    private let meal_time_sn2 = Expression<String?>("meal_time_sn2")
    private let meal_time_sn3 = Expression<String?>("meal_time_sn3")
    private let meal_time_sn4 = Expression<String?>("meal_time_sn4")
    private let meal_time_sn5 = Expression<String?>("meal_time_sn5")
    private let meal_time_sn6 = Expression<String?>("meal_time_sn6")
    private let water_num = Expression<String?>("water_num")
    private let water_upload = Expression<String?>("water_upload")
    private let water_etime = Expression<String?>("water_etime")
    private let circle_tag = Expression<String?>("circle_tag")
    private let fitness_tag = Expression<String?>("fitness_tag")
    private let notes_tag = Expression<String?>("notes_tag")
    
    class func getInstance() -> LogsSQLiteManager
     {
         if(shared.db == nil)
         {
             do{
                 let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                 let fileUrl = documentDirectory.appendingPathComponent("elavatine").appendingPathExtension("sqlite3")
                 shared.db = try Connection(fileUrl.path)
                 shared.createTable()
             }catch{
                 DLLog(message:"DB Error \(error)")
             }
         }
         return shared
      }
    func createTable() {
        do {
            try db?.run(logs.create { t in
//                t.column(date)
//                t.column(uid)
//                t.column(uid, primaryKey: true)
//                t.column(sdate, primaryKey: true)
                t.column(uid)
                t.column(sdate)
                t.column(ctime)
                t.column(etime)
                t.column(foods)
                t.column(calori)
                t.column(protein)
                t.column(carbohydrate)
                t.column(fat)
                t.column(caloriTarget)
                t.column(proteinTarget)
                t.column(carbohydrateTarget)
                t.column(fatTarget)
                t.column(notes)
                t.column(isUpload)
                t.column(isUploadString)
                t.column(meal_time_sn1)
                t.column(meal_time_sn2)
                t.column(meal_time_sn3)
                t.column(meal_time_sn4)
                t.column(meal_time_sn5)
                t.column(meal_time_sn6)
                t.column(water_num)
                t.column(water_upload)
                t.column(water_etime)
                t.column(circle_tag)
                t.column(fitness_tag)
                t.column(notes_tag)
                t.primaryKey(uid,sdate)
            })
            DLLog(message:"Create table success")
        } catch {
            DLLog(message:"Unable to create table")
            isUploadStatusStringExist()
            isMealsTimeExist(columnNames: "meal_time_sn1")
            isMealsTimeExist(columnNames: "meal_time_sn2")
            isMealsTimeExist(columnNames: "meal_time_sn3")
            isMealsTimeExist(columnNames: "meal_time_sn4")
            isMealsTimeExist(columnNames: "meal_time_sn5")
            isMealsTimeExist(columnNames: "meal_time_sn6")
            isMealsTimeExist(columnNames: "water_num")
            isMealsTimeExist(columnNames: "water_upload")
            isMealsTimeExist(columnNames: "water_etime")
            isMealsTimeExist(columnNames: "circle_tag")
            isMealsTimeExist(columnNames: "fitness_tag")
            isMealsTimeExist(columnNames: "notes_tag")
        }
    }
    func isMealsTimeExist(columnNames:String) {
        do {
            var isExist = false
            let expression = logs.expression
            let colunmnNames = try db?.prepare(expression.template,expression.bindings).columnNames
            if colunmnNames?.count ?? 0 > 0 {
                for i in 0..<(colunmnNames?.count ?? 0) {
                    let colName = colunmnNames?[i]as? String ?? ""
                    if colName == columnNames {
                        isExist = true
                        break
                    }
                }
            }
            
            if !isExist {
                do {
                    try db?.execute("alter table logs add column '\(columnNames)' TEXT DEFAULT ''")
                    print("add----success")
                } catch {
                    print("add----Error")
                }
            }
        } catch {
            
        }
    }
    func isUploadStatusStringExist() {
        do {
            var isExist = false
            let expression = logs.expression
            let colunmnNames = try db?.prepare(expression.template,expression.bindings).columnNames
            if colunmnNames?.count ?? 0 > 0 {
                for i in 0..<(colunmnNames?.count ?? 0) {
                    let colName = colunmnNames?[i]as? String ?? ""
                    if colName == "isUploadString" {
                        isExist = true
                        break
                    }
                }
            }
            
            if !isExist {
                do {
                    try db?.execute("alter table logs add column 'isUploadString' TEXT DEFAULT '0'")
                    print("add----success")
                } catch {
                    print("add----Error")
                }
            }
        } catch {
            
        }
    }
    
    private func insertLogs(sDate: String, calori: String,protein:String,carbohydrates:String,fats:String,notes:String,foods:String,caloriTar:String,proteinTar:String,carboTar:String,fatsTar:String,upload:Bool,eTime:String,waterNum:String="",waterUpload:String="1",waterEtime:String="",circleTag:String,fitnessTag:String,notesTag:String) {
        
        let foodsString = foods.replacingOccurrences(of: "'", with: "’")
        
        do {
//            let date = Date().changeDateStringToDate(dateString: sDate,formatter: "yyyy-MM-dd")
            
            NutritionDefaultModel.shared.getDefaultGoal(weekDay: Date().getWeekdayIndex(from: sDate))
            
            
            var caloriGoal = caloriTar
            var proteinGoal = proteinTar
            var carboGoal = carboTar
            var fatGoal = fatsTar
            
            if caloriGoal == "" || caloriGoal.count == 0 {
                caloriGoal = NutritionDefaultModel.shared.calories
                proteinGoal = NutritionDefaultModel.shared.protein
                carboGoal = NutritionDefaultModel.shared.carbohydrate
                fatGoal = NutritionDefaultModel.shared.fat
            }
//            
            let insert = logs.insert(self.uid <- UserInfoModel.shared.uId,
                                     self.sdate <- sDate,
//                                     self.date <- "\(date)",
                                     self.ctime <- Date().todaySeconds,
                                     self.etime <- eTime,
                                     self.foods <- foodsString,
                                     self.calori <- calori,
                                     self.protein <- protein,
                                     self.carbohydrate <- carbohydrates,
                                     self.fat <- fats,
                                     self.caloriTarget<-caloriGoal,
                                     self.proteinTarget<-proteinGoal,
                                     self.carbohydrateTarget<-carboGoal,
                                     self.fatTarget<-fatGoal,
                                     self.notes <- notes,
                                     self.isUpload <- upload,//"\(upload ? 1 : 0)",
                                     self.isUploadString<-"\(upload ? 1 : 0)",
                                     self.water_num<-waterNum,
                                     self.water_upload<-waterUpload,
                                     self.water_etime<-waterEtime,
                                     self.circle_tag<-circleTag,
                                     self.fitness_tag<-fitnessTag,
                                     self.notes_tag<-notesTag)
            
            try db?.run(insert)
            DLLog(message:"更新日志成功(不存在数据) \(sDate)")
        } catch {
//            print("Unable to insert logs")
            DLLog(message:"更新日志失败(不存在数据) \(sDate)  --- 下一步，执行SQL语句")
            insertDataUseSql(sDate: sDate, calori: calori, protein: protein, carbohydrates: carbohydrates, fats: fats, notes: notes, foods: foodsString, caloriTar: caloriTar, proteinTar: proteinTar, carboTar: carboTar, fatsTar: fatsTar, upload: upload, eTime: eTime,waterNum:waterNum,waterUpload:waterUpload,waterEtime:waterEtime,circleTag: circleTag,fitnessTag: fitnessTag,notesTag: notesTag)
        }
    }
    //MARK: SQL语句插入数据
    func insertDataUseSql(sDate: String, calori: String,protein:String,carbohydrates:String,fats:String,notes:String,foods:String,caloriTar:String,proteinTar:String,carboTar:String,fatsTar:String,upload:Bool,eTime:String,waterNum:String="",waterUpload:String="1",waterEtime:String="",circleTag:String,fitnessTag:String,notesTag:String) {
        let foodsString = foods.replacingOccurrences(of: "'", with: "‘")
        do {
            var caloriGoal = caloriTar
            var proteinGoal = proteinTar
            var carboGoal = carboTar
            var fatGoal = fatsTar
            
            if caloriGoal == "" || caloriGoal.count == 0 {
                caloriGoal = NutritionDefaultModel.shared.calories
                proteinGoal = NutritionDefaultModel.shared.protein
                carboGoal = NutritionDefaultModel.shared.carbohydrate
                fatGoal = NutritionDefaultModel.shared.fat
            }
            
            try db?.execute("INSERT INTO logs (uid,sdate,ctime,etime,foods,calori,protein,carbohydrate,fat,caloriTarget,proteinTarget,carbohydrateTarget,fatTarget,notes,isUpload,isUploadString,meal_time_sn1,meal_time_sn2,meal_time_sn3,meal_time_sn4,meal_time_sn5,meal_time_sn6,water_num,water_upload,water_etime,circle_tag,fitness_tag,notes_tag) VALUES ('\(UserInfoModel.shared.uId)','\(sDate)','\(Date().todaySeconds)','\(eTime)','\(foodsString)','\(calori)','\(protein)','\(carbohydrates)','\(fats)','\(caloriGoal)','\(proteinGoal)','\(carboGoal)','\(fatGoal)','\(notes)','\(upload ? 1 : 0)','\(upload ? 1 : 0)','','','','','','','\(waterNum)','\(waterUpload)','\(waterEtime)','\(circleTag)','\(fitnessTag)','\(notesTag)')")
            DLLog(message: "SQL语句插入  ----  success")
        }catch{
            DLLog(message: "SQL语句插入  ----  执行失败")
        }
    }
    func updateLogs(sDate: String,eTime:String, foods:String,caloriNum:String,proteinNum:String,carboNum:String,fatsNum:String,caloriTar:String,proteinTar:String,carboTar:String,fatsTar:String) {
        let foodsString = foods.replacingOccurrences(of: "'", with: "’")
        if queryTable(sDate: sDate){//如果存在数据
            do {
                let sql = logs.filter(sdate == sDate).filter(uid == UserInfoModel.shared.uId)
                try db?.run(sql.update(self.foods<-foodsString,
                                       self.calori<-caloriNum,
                                       self.protein<-proteinNum,
                                       self.carbohydrate<-carboNum,
                                       self.fat<-fatsNum,
                                       self.caloriTarget<-caloriTar,
                                       self.proteinTarget<-proteinTar,
                                       self.carbohydrateTarget<-carboTar,
                                       self.etime <- eTime,
                                       self.fatTarget<-fatsTar))
//                DLLog(message:"更新日志成功 \(sDate)")
            } catch {
                DLLog(message:"SQLite 更新日志失败 \(sDate)")
                do {
                    let updateSql = "UPDATE logs SET"
                    + " etime = '\(eTime)'"
                    + ", foods = '\(foodsString)'"
                    + ", calori = '\(caloriNum)'"
                    + ", protein = '\(proteinNum)'"
                    + ", carbohydrate = '\(carboNum)'"
                    + ", fat = '\(fatsNum)'"
                    + ", caloriTarget = '\(caloriTar)'"
                    + ", proteinTarget = '\(proteinTar)'"
                    + ", carbohydrateTarget = '\(carboTar)'"
                    + ", fatTarget = '\(fatsTar)'"
                    + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'));"
                    try db?.execute(updateSql)
                    DLLog(message: "SQL语句更新  ----  success")
                }catch{
                    DLLog(message: "SQL语句更新  ----  执行失败")
                }
            }
        }else{//如果不存在数据
            if foods == "[[],[],[],[],[],[]]"{
                return
            }
            insertLogs(sDate: sDate,
                       calori: caloriNum,
                       protein: proteinNum,
                       carbohydrates: carboNum,
                       fats: fatsNum,
                       notes: "",
                       foods: foodsString,
                       caloriTar:caloriTar,
                       proteinTar:proteinTar,
                       carboTar:carboTar,
                       fatsTar:fatsTar,
                       upload: false,
                       eTime: eTime,
                       circleTag: "",
                       fitnessTag: "",
                       notesTag: "")
        }
    }
    func updateLogs(sDate: String,eTime:String,caloriNum:String,proteinNum:String,carboNum:String,fatsNum:String) {
        if queryTable(sDate: sDate){//如果存在数据
            do {
                let sql = logs.filter(sdate == sDate).filter(uid == UserInfoModel.shared.uId)
                try db?.run(sql.update(self.calori<-caloriNum,
                                       self.protein<-proteinNum,
                                       self.carbohydrate<-carboNum,
                                       self.fat<-fatsNum,
                                       self.etime <- eTime))
//                DLLog(message:"更新日志成功 \(sDate)")
            } catch {
                DLLog(message:"更新日志失败 \(sDate)")
                do {
                    try db?.execute("UPDATE logs SET"
                                    + " etime = '\(eTime)'"
                                    + ", calori = '\(caloriNum)'"
                                    + ", protein = '\(proteinNum)'"
                                    + ", carbohydrate = '\(carboNum)'"
                                    + ", fat = '\(fatsNum)'"
                                    + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'));")
                    DLLog(message: "SQL语句更新  ----  success")
                }catch{
                    DLLog(message: "SQL语句更新  ----  执行失败")
                }
            }
        }else{//如果不存在数据
            NutritionDefaultModel.shared.getDefaultGoal(weekDay: Date().getWeekdayIndex(from: sDate))
            insertLogs(sDate: sDate,
                       calori: caloriNum,
                       protein: proteinNum,
                       carbohydrates: carboNum,
                       fats: fatsNum,
                       notes: "",
                       foods: "[[],[],[],[],[],[]]",
                       caloriTar:NutritionDefaultModel.shared.calories,
                       proteinTar:NutritionDefaultModel.shared.protein,
                       carboTar:NutritionDefaultModel.shared.carbohydrate,
                       fatsTar:NutritionDefaultModel.shared.fat,
                       upload: false,
                       eTime: eTime,
                       circleTag: "",
                       fitnessTag: "",
                       notesTag: "")
        }
    }
    func updateLogs(sDate: String,eTime:String, foods:String,caloriNum:String,proteinNum:String,carboNum:String,fatsNum:String) {
        var foodsString = foods
        foodsString = foodsString.replacingOccurrences(of: "'", with: "’")
        if queryTable(sDate: sDate){//如果存在数据
            do {
                let sql = logs.filter(sdate == sDate).filter(uid == UserInfoModel.shared.uId)
                try db?.run(sql.update(self.foods<-foodsString,
                                       self.calori<-caloriNum,
                                       self.protein<-proteinNum,
                                       self.carbohydrate<-carboNum,
                                       self.fat<-fatsNum,
                                       self.etime <- eTime))
//                DLLog(message:"更新日志成功 \(sDate)")
            } catch {
                DLLog(message:"更新日志失败 \(sDate)")
                do {
                    try db?.execute("UPDATE logs SET"
                                    + " etime = '\(eTime)'"
                                    + ", foods = '\(foodsString)'"
                                    + ", calori = '\(caloriNum)'"
                                    + ", protein = '\(proteinNum)'"
                                    + ", carbohydrate = '\(carboNum)'"
                                    + ", fat = '\(fatsNum)'"
                                    + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'));")
                    DLLog(message: "SQL语句更新  ----  success")
                }catch{
                    DLLog(message: "SQL语句更新  ----  执行失败")
                }
            }
        }else{//如果不存在数据
            if foods == "[[],[],[],[],[],[]]"{
                return
            }
            NutritionDefaultModel.shared.getDefaultGoal(weekDay: Date().getWeekdayIndex(from: sDate))
            insertLogs(sDate: sDate,
                       calori: caloriNum,
                       protein: proteinNum,
                       carbohydrates: carboNum,
                       fats: fatsNum,
                       notes: "",
                       foods: foodsString,
                       caloriTar:NutritionDefaultModel.shared.calories,
                       proteinTar:NutritionDefaultModel.shared.protein,
                       carboTar:NutritionDefaultModel.shared.carbohydrate,
                       fatsTar:NutritionDefaultModel.shared.fat,
                       upload: false,
                       eTime: eTime,
                       circleTag: "",
                       fitnessTag: "",
                       notesTag: "")
        }
    }
    func updateLogs(sDate: String,eTime:String, calori: String,protein:String,carbohydrates:String,fats:String,notes:String,foods:String,caloriTar:String,proteinTar:String,carboTar:String,fatsTar:String,circleTag:String,fitnessTag:String,notesTag:String) {
        var foodsString = foods
        foodsString = foodsString.replacingOccurrences(of: "'", with: "’")
        if queryTable(sDate: sDate){//如果存在数据
            do {
                let sql = logs.filter(sdate == sDate).filter(uid == UserInfoModel.shared.uId)
                try db?.run(sql.update(self.ctime<-Date().todaySeconds,
                                       self.etime<-eTime,
                                       self.calori<-calori,
                                       self.protein<-protein,
                                       self.carbohydrate<-carbohydrates,
                                       self.fat<-fats,
                                       self.caloriTarget<-caloriTar,
                                       self.proteinTarget<-proteinTar,
                                       self.carbohydrateTarget<-carboTar,
                                       self.fatTarget<-fatsTar,
                                       self.foods<-foodsString,
                                       self.isUploadString<-"1",
                                       self.notes<-notes,
                                       self.circle_tag<-circleTag,
                                       self.fitness_tag<-fitnessTag,
                                       self.notes_tag<-notesTag))
                DLLog(message:"update logs success")
            } catch {
                DLLog(message:"Unable to update logs details")
                do {
                    let updateSql = "UPDATE logs SET"
                    + " etime = '\(eTime)'"
                    + ", ctime = '\(Date().todaySeconds)'"
                    + ", foods = '\(foodsString)'"
                    + ", calori = '\(calori)'"
                    + ", protein = '\(protein)'"
                    + ", carbohydrate = '\(carbohydrates)'"
                    + ", fat = '\(fats)'"
                    + ", caloriTarget = '\(caloriTar)'"
                    + ", proteinTarget = '\(proteinTar)'"
                    + ", carbohydrateTarget = '\(carboTar)'"
                    + ", fatTarget = '\(fatsTar)'"
                    + ", notes = '\(notes)'"
                    + ", circle_tag = '\(circleTag)'"
                    + ", fitness_tag = '\(fitnessTag)'"
                    + ", notes_tag = '\(notesTag)'"
                    + ", isUploadString = '1'"
                    + " WHERE (uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)');"
                    try db?.execute(updateSql)
                    DLLog(message: "SQL语句更新  ----  success")
                }catch{
                    DLLog(message: "SQL语句更新  ----  执行失败")
                }
            }
        }else{//如果不存在数据
            if foods == "[[],[],[],[],[],[]]" && notes == "" && notesTag.count < 4{
                return
            }
            insertLogs(sDate: sDate,
                       calori: calori,
                       protein: protein,
                       carbohydrates: carbohydrates,
                       fats: fats,
                       notes: notes,
                       foods: foodsString,
                       caloriTar:caloriTar,
                       proteinTar:proteinTar,
                       carboTar:carboTar,
                       fatsTar:fatsTar,
                       upload: false,
                       eTime: eTime,
                       circleTag: circleTag,
                       fitnessTag: fitnessTag,
                       notesTag: notesTag)
        }
    }
    //MARK: 更新日志每一餐的用餐 时间
    /**
     meal_time_sn1     ~    meal_time_sn6   格式 ： HH:mm
     */
    func updateSingleMealTime(mealsIndex:String,time:String,sDate:String) {
        do {
            try db?.execute("UPDATE logs SET"
                            + " meal_time_sn\(mealsIndex) = '\(time)'"
                            + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'));")
        }catch{
            
        }
    }
    //MARK: 更新单条日志数据
    func updateSingleData(columnName:String,data:String,cTime:String) {
//        saveSqlQueue.async {
            do {
                let updateSql = "UPDATE logs SET"
                + " \(columnName) = '\(data)'"
                + ", isUploadString = '0'"
                + " WHERE (uid == '\(UserInfoModel.shared.uId)' AND ctime == '\(cTime)');"
                
                try self.db?.execute(updateSql)
            } catch {
            DLLog(message: "更新单条日志数据Fail :   (\(cTime)) -- (\(columnName))  :  \(data)")
            }
//        }怕
    }
    func updateMealsTime(logsDict:NSDictionary) {
        for i in 1..<7{
            do {
                try db?.execute("UPDATE logs SET"
                                + " meal_time_sn\(i) = '\(logsDict.stringValueForKey(key:"mealTimeSn\(i)"))'"
                                + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(logsDict.stringValueForKey(key:"sdate"))'));")
            }catch{
                
            }
        }
    }
    func updateMealsTime(foodsArray:NSArray,sDate:String) {
        let logsDict = queryLogsDataForMealsTime(sDate: sDate)
        for i in 0..<foodsArray.count{
            let mealsFoods = foodsArray[i]as? NSArray ?? []
            
            var eatFoods = false
            var sn = "\(i+1)"
            for j in 0..<mealsFoods.count{
                
                let foodsDict = mealsFoods[j]as? NSDictionary ?? [:]
                if foodsDict.stringValueForKey(key: "state") == "1"{
                    sn = foodsDict.stringValueForKey(key: "sn")
                    let logsMealsTime = logsDict.stringValueForKey(key: "mealTimeSn\(sn)")
                    if logsMealsTime.count > 3 {
                        //如果当餐有记录时间，则不处理
                    }else{
                        //当餐没有记录时间，则将当前系统时间存入
                        let time = Date().currentHourMinute
                        do {
                            try db?.execute("UPDATE logs SET"
                                            + " meal_time_sn\(sn) = '\(time)'"
                                            + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'));")
                            DLLog(message: "SQL语句更新（更新用餐时间 meal_time_sn\(sn)）--- \(time)  ----  success")
                        }catch{
                            DLLog(message: "SQL语句更新  ----  执行失败")
                        }
                    }
                    eatFoods = true
                    break
                }
            }
            //如果当餐未记录食物,则将时间置为空
            if eatFoods == false{
                do {
                    try db?.execute("UPDATE logs SET"
                                    + " meal_time_sn\(sn) = ''"
                                    + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'));")
                    DLLog(message: "（更新用餐时间 meal_time_sn\(sn)）--- 清空  ----  success")
                }catch{
                    DLLog(message: "（更新用餐时间 meal_time_sn\(sn)  ----  执行失败")
                }
            }
        }
    }
    func updateLogsEtime(sDate:String,endTime:String) {
        if queryTable(sDate: sDate){//如果存在数据
            do {
                try db?.run(logs.filter(sdate == sDate).filter(uid == UserInfoModel.shared.uId).update(etime <- endTime))
                
//                DLLog(message:"更新笔记成功 \(sDate)")
            }catch{
                DLLog(message:"更新笔记失败  \(sDate) -- \(endTime)")
                
                do {
                    try db?.execute("UPDATE logs SET"
                                    + " etime = '\(endTime)'"
                                    + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'));")
                    DLLog(message: "SQL语句更新  ----  success")
                }catch{
                    DLLog(message: "SQL语句更新  ----  执行失败")
                }
            }
        }else{
            NutritionDefaultModel.shared.getDefaultGoal(weekDay: Date().getWeekdayIndex(from: sDate))
            insertLogs(sDate: sDate,
                       calori: "0",
                       protein: "0",
                       carbohydrates: "0",
                       fats: "0",
                       notes: "",
                       foods: "[[],[],[],[],[],[]]",
                       caloriTar:NutritionDefaultModel.shared.calories,
                       proteinTar:NutritionDefaultModel.shared.protein,
                       carboTar:NutritionDefaultModel.shared.carbohydrate,
                       fatsTar:NutritionDefaultModel.shared.fat,
                       upload: false,
                       eTime:endTime,
                       circleTag: "",
                       fitnessTag: "",
                       notesTag: "")
        }
    }
    //MARK: 饮水
    ///插入饮水记录
    func insertWater(sDate:String , waterNum:String){
        if queryTable(sDate: sDate){//如果存在数据
            do {
                try db?.run(logs.filter(sdate == sDate)
                    .filter(uid == UserInfoModel.shared.uId)
                    .update(water_num <- waterNum,
                            water_upload<-"0",
                            water_etime<-Date().currentSecondsUTC8))
            }catch{
                DLLog(message:"更新饮水记录失败  \(sDate) -- \(waterNum)")
                do {
                    let updateSql = "UPDATE logs SET"
                    + " water_num = '\(waterNum)'"
                    + ", water_upload = '0' "
                    + ", water_etime = '\(Date().currentSecondsUTC8)' "
                    + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'));"
                    try db?.execute(updateSql)
                    DLLog(message: "SQL语句更新  ----  success")
                }catch{
                    DLLog(message: "SQL语句更新  ----  执行失败")
                }
            }
        }else{
            insertLogs(sDate: sDate,
                       calori: "0",
                       protein: "0",
                       carbohydrates: "0",
                       fats: "0",
                       notes: "",
                       foods: "[[],[],[],[],[],[]]",
                       caloriTar:NutritionDefaultModel.shared.calories,
                       proteinTar:NutritionDefaultModel.shared.protein,
                       carboTar:NutritionDefaultModel.shared.carbohydrate,
                       fatsTar:NutritionDefaultModel.shared.fat,
                       upload: false,
                       eTime: Date().currentSecondsUTC8,
                       waterNum: waterNum,
                       waterUpload: "0",
                       waterEtime: Date().currentSecondsUTC8,
                       circleTag: "",
                       fitnessTag: "",
                       notesTag: "")
        }
    }
    ///本地新增饮水，往本地数据库加饮水数据
    func addWaterNumStatus(sDate:String,num:String) -> String {
        let waterDict = queryLogsDataForWater(sDate: sDate)
        let lastWaterNum = waterDict.stringValueForKey(key: "waterNum").intValue
        let waterNum = lastWaterNum + num.intValue
        insertWater(sDate: sDate, waterNum: "\(waterNum)")
        
        return "\(waterNum)"
    }
    ///更新本地饮水时间，顺带更新上传状态
    func updateWaterUploadStatus(sDate:String,update:Bool,eTime:String) {
        if queryTable(sDate: sDate){//如果存在数据
            do {
//                try db?.run(logs.filter(sdate == sDate).filter(uid == UserInfoModel.shared.uId).update(water_upload <- "\(update ? 1 : 0)"))
                let sql = self.logs.filter(self.sdate == sDate).filter(self.uid == UserInfoModel.shared.uId)
                try self.db?.run(sql.update(water_upload<-"\(update ? 1 : 0)",
                                            water_etime<-eTime))
//                DLLog(message:"更新上传状态成功 \(sDate)")
            }catch{
                DLLog(message:"更新上传状态失败  \(sDate) -- \(update)")
                do {
                    let sqlString = "UPDATE logs SET"
                    + " water_upload = '\(update ? 1 : 0)'"
                    + ", water_etime = '\(eTime)' "
                    + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'));"
                    try db?.execute(sqlString)
                    DLLog(message: "SQL语句更新（上传状态）  ----  success")
                }catch{
                    DLLog(message: "SQL语句更新（上传状态）  ----  执行失败:\(error)")
                }
            }
        }
    }
    ///更新本地饮水数据，顺带更新上传状态
    func updateWaterMsgWithServer(sDate:String,waterNum:String,update:Bool,eTime:String) {
        if queryTable(sDate: sDate){//如果存在数据
            do {
//                try db?.run(logs.filter(sdate == sDate).filter(uid == UserInfoModel.shared.uId).update(water_upload <- "\(update ? 1 : 0)"))
                let sql = self.logs.filter(self.sdate == sDate).filter(self.uid == UserInfoModel.shared.uId)
                try self.db?.run(sql.update(water_upload<-"\(update ? 1 : 0)",
                                            water_etime<-eTime))
//                DLLog(message:"更新上传状态成功 \(sDate)")
            }catch{
                DLLog(message:"更新上传状态失败  \(sDate) -- \(update)")
                do {
                    try db?.execute("UPDATE logs SET"
                                    + " water_num = '\(waterNum)'"
                                    + " water_upload = '\(update ? 1 : 0)'"
                                    + ", water_etime = '\(eTime)' "
                                    + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'));")
                    DLLog(message: "SQL语句更新（上传状态）  ----  success")
                }catch{
                    DLLog(message: "SQL语句更新（上传状态）  ----  执行失败")
                }
            }
        }
    }
    ///查询本地饮水数据
    func queryLogsDataForWater(sDate:String) -> NSDictionary {
        var dict = NSDictionary()
        do {
            if let rows = try db?.prepare("SELECT * FROM logs WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'))"){
                DLLog(message: "---- \(rows)")
                for row in rows{
                    DLLog(message: "queryLogsDataForMealsTime SELECT RESULT:\(row)")
                    dict = ["waterNum":row[22]as? String ?? "",
                            "waterUpload":row[23]as? String ?? "",
                            "waterEtime":row[24]as? String ?? ""]
                    
                }
            }
        } catch {
//            return models
        }
        
        return dict
    }
    func queryTableAllWaterData() -> NSArray {
        let dataArray = NSMutableArray()
        do {
            if let rows = try db?.prepare("SELECT * FROM logs WHERE uid == '\(UserInfoModel.shared.uId)' ORDER BY sdate"){
                DLLog(message: "---- \(rows)")
                for row in rows{
                    let dict = ["waterNum":row[22]as? String ?? "",
                                "waterUpload":row[23]as? String ?? "",
                                "waterEtime":row[24]as? String ?? "",
                                "sdate":row[1]as? String ?? ""]
                    dataArray.add(dict)
                }
            }
            
        } catch {
//            return models
        }
        
        return dataArray
    }
    func updateWaterUploadStatus(status:String,cTime:String,eTime:String) {do {
        let updateSql = "UPDATE logs SET"
        + " waterUpload = '\(status)'"
        + ", water_etime = '\(eTime)' "
        + " WHERE (uid == '\(UserInfoModel.shared.uId)' AND ctime == '\(cTime)');"
        
        try self.db?.execute(updateSql)
    } catch {
    }
    }
    //MARK: 注释标签
    func insertNotesTag(sDate:String,notesTag:String) {
        if queryTable(sDate: sDate){//如果存在数据
            do {
                try db?.run(logs.filter(sdate == sDate).filter(uid == UserInfoModel.shared.uId).update(notes_tag <- notesTag))
            }catch{
                do {
                    let updateSql = "UPDATE logs SET"
                    + " notes_tag = '\(notesTag)'"
                    + ", etime = '\(Date().currentSeconds)' "
                    + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'));"
                    try db?.execute(updateSql)
                }catch{
                }
            }
        }else{
            NutritionDefaultModel.shared.getDefaultGoal(weekDay: Date().getWeekdayIndex(from: sDate))
            insertLogs(sDate: sDate,
                       calori: "0",
                       protein: "0",
                       carbohydrates: "0",
                       fats: "0",
                       notes: "",
                       foods: "[[],[],[],[],[],[]]",
                       caloriTar:NutritionDefaultModel.shared.calories,
                       proteinTar:NutritionDefaultModel.shared.protein,
                       carboTar:NutritionDefaultModel.shared.carbohydrate,
                       fatsTar:NutritionDefaultModel.shared.fat,
                       upload: false, eTime: Date().currentSeconds,
                       circleTag: "",
                       fitnessTag: "",
                       notesTag: notesTag)
        }
    }
    //MARK: 注释
    ///插入注释
    func insertNotes(sDate:String , notestr:String){
        if queryTable(sDate: sDate){//如果存在数据
            do {
                try db?.run(logs.filter(sdate == sDate).filter(uid == UserInfoModel.shared.uId).update(notes <- notestr))
                
//                DLLog(message:"更新笔记成功 \(sDate)")
            }catch{
                DLLog(message:"更新笔记失败  \(sDate) -- \(notestr)")
                do {
                    let updateSql = "UPDATE logs SET"
                    + " notes = '\(notestr)'"
                    + ", etime = '\(Date().currentSeconds)' "
                    + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'));"
                    try db?.execute(updateSql)
                    DLLog(message: "SQL语句更新  ----  success")
                }catch{
                    DLLog(message: "SQL语句更新  ----  执行失败")
                }
            }
        }else{
            NutritionDefaultModel.shared.getDefaultGoal(weekDay: Date().getWeekdayIndex(from: sDate))
            insertLogs(sDate: sDate,
                       calori: "0",
                       protein: "0",
                       carbohydrates: "0",
                       fats: "0",
                       notes: notestr,
                       foods: "[[],[],[],[],[],[]]",
                       caloriTar:NutritionDefaultModel.shared.calories,
                       proteinTar:NutritionDefaultModel.shared.protein,
                       carboTar:NutritionDefaultModel.shared.carbohydrate,
                       fatsTar:NutritionDefaultModel.shared.fat,
                       upload: false, eTime: Date().currentSeconds,
                       circleTag: "",
                       fitnessTag: "",
                       notesTag: "")
//            DLLog(message:"更新笔记成功(无历史数据) \(sDate)")
        }
    }
    
    //MARK: 刷新训练部位
    func updateFitnessType(fitnessType:String,sDate:String) {
        if queryTable(sDate: sDate){//如果存在数据
            do {
                try db?.run(logs.filter(sdate == sDate).filter(uid == UserInfoModel.shared.uId).update(fitness_tag <- fitnessType))
            }catch{
                do {
                    let updateSql = "UPDATE logs SET"
                    + " fitness_tag = '\(fitnessType)'"
                    + ", etime = '\(Date().currentSecondsUTC8)' "
                    + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'));"
                    try db?.execute(updateSql)
                    DLLog(message: "SQL语句更新  ----  success")
                }catch{
                    DLLog(message: "SQL语句更新  ----  执行失败")
                }
            }
        }else{
            NutritionDefaultModel.shared.getDefaultGoal(weekDay: Date().getWeekdayIndex(from: sDate))
            insertLogs(sDate: sDate,
                       calori: "0",
                       protein: "0",
                       carbohydrates: "0",
                       fats: "0",
                       notes: "",
                       foods: "[[],[],[],[],[],[]]",
                       caloriTar:NutritionDefaultModel.shared.calories,
                       proteinTar:NutritionDefaultModel.shared.protein,
                       carboTar:NutritionDefaultModel.shared.carbohydrate,
                       fatsTar:NutritionDefaultModel.shared.fat,
                       upload: false, eTime: Date().currentSeconds,
                       circleTag: "",
                       fitnessTag: "\(fitnessType)",
                       notesTag: "")
        }
    }
    ///查询 训练部位
    func queryLogsDataForFitness(sDate:String) -> String {
        var dict = NSDictionary()
        do {
            if let rows = try db?.prepare("SELECT * FROM logs WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'))"){
                DLLog(message: "---- \(rows)")
                for row in rows{
                    DLLog(message: "queryLogsDataForMealsTime SELECT RESULT:\(row)")
                    dict = ["fitnessLabel":row[26]as? String ?? ""]
                }
            }
        } catch {
//            return models
        }
        
        return dict.stringValueForKey(key: "fitnessLabel")
    }
    func updateUploadStatus(sDate:String,update:Bool) {
        if queryTable(sDate: sDate){//如果存在数据
            do {
                try db?.run(logs.filter(sdate == sDate).filter(uid == UserInfoModel.shared.uId).update(isUploadString <- "\(update ? 1 : 0)"))
                
//                DLLog(message:"更新上传状态成功 \(sDate)")
            }catch{
                DLLog(message:"更新上传状态失败  \(sDate) -- \(update)")
                do {
                    try db?.execute("UPDATE logs SET"
                                    + " isUploadString = '\(update ? 1 : 0)'"
                                    + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'));")
                    DLLog(message: "SQL语句更新（上传状态）  ----  success")
                }catch{
                    DLLog(message: "SQL语句更新（上传状态）  ----  执行失败")
                }
            }
        }else{
            NutritionDefaultModel.shared.getDefaultGoal(weekDay: Date().getWeekdayIndex(from: sDate))
            insertLogs(sDate: sDate,
                       calori: "0",
                       protein: "0",
                       carbohydrates: "0",
                       fats: "0",
                       notes: "",
                       foods: "[[],[],[],[],[],[]]",
                       caloriTar:NutritionDefaultModel.shared.calories,
                       proteinTar:NutritionDefaultModel.shared.protein,
                       carboTar:NutritionDefaultModel.shared.carbohydrate,
                       fatsTar:NutritionDefaultModel.shared.fat,
                       upload: false,
                       eTime: Date().currentSeconds,
                       circleTag: "",
                       fitnessTag: "",
                       notesTag: "")
//            DLLog(message:"更新笔记成功(无历史数据) \(sDate)")
        }
    }
    //MARK: 清空往后的数据
    /**
     1、激活计划的时候
     */
    func deleteTableData(sDate:String) {
        do {
            try db?.execute("DELETE FROM logs WHERE uid == '\(UserInfoModel.shared.uId)' AND sdate >= '\(sDate)';")
        }catch{
//            DLLog(message: "")
            MobClick.event("deleteTableData")
        }
        LogsSQLiteUploadManager().clearNaturalData()
        LogsMealsAlertSetManage().refreshClockAlertMsg()
    }
    //MARK: 更新往后数据的目标值
    /**
     2、概览页设置今日目标
     */
    func refreshDataTarget(sDate:String,caloriTar:String,proteinTar:String,carboTar:String,fatsTar:String) {
        let serialQueue = DispatchQueue(label: "com.logs.sqlite")
        
        for i in 0..<400*3{//今日起往后3年的数据，因为担心闰年等年份数据问题，故每年不按365天算
            let sDateTemp = Date().nextDay(days: i, baseDate: sDate)
            if queryTable(sDate: sDateTemp){//如果存在数据
                serialQueue.async {
                    do {
                        let sql = self.logs.filter(self.sdate == sDateTemp).filter(self.uid == UserInfoModel.shared.uId)
                        try self.db?.run(sql.update(self.caloriTarget<-caloriTar,
                                               self.proteinTarget<-proteinTar,
                                               self.carbohydrateTarget<-carboTar,
                                               self.fatTarget<-fatsTar))
//                        DLLog(message:"更改目标值 success")
                    } catch {
                        DLLog(message:"Unable to update logs details")
                        do {
                            try self.db?.execute("UPDATE logs SET"
                                            + " caloriTarget = '\(caloriTar)'"
                                            + ", proteinTarget = '\(proteinTar)'"
                                            + ", carbohydrateTarget = '\(carboTar)'"
                                            + ", fatTarget = '\(fatsTar)'"
                                             + ", circle_tag = ''"
                                            + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDateTemp)'));")
                            DLLog(message: "SQL语句更新  ----  success")
                        }catch{
                            DLLog(message: "SQL语句更新  ----  执行失败")
                        }
                    }
                }
            }
        }
        LogsSQLiteUploadManager().updateNaturalGoalForWidget()
    }
    //MARK: 按周几来更新目标
    func refreshDataTarget(weeksDay:Int,serialQueue:DispatchQueue){
        NutritionDefaultModel.shared.getDefaultGoal(weekDay: weeksDay)
        
        for i in 0..<400*3{//今日起往后3年的数据，因为担心闰年等年份数据问题，故每年不按365天算
            let sDateTemp = Date().nextDay(days: i)
            if Date().getWeekdayIndex(from: sDateTemp) == weeksDay{
                if queryTable(sDate: sDateTemp){//如果存在数据
                    serialQueue.async {
                        do {
                            let sql = self.logs.filter(self.sdate == sDateTemp).filter(self.uid == UserInfoModel.shared.uId)
                            try self.db?.run(sql.update(self.caloriTarget<-NutritionDefaultModel.shared.calories,
                                                        self.proteinTarget<-NutritionDefaultModel.shared.protein,
                                                        self.carbohydrateTarget<-NutritionDefaultModel.shared.carbohydrate,
                                                        self.fatTarget<-NutritionDefaultModel.shared.fat))
//                            DLLog(message:"更改目标值 success")
                        } catch {
                            DLLog(message:"Unable to update logs details")
                            do {
                                try self.db?.execute("UPDATE logs SET"
                                                + " caloriTarget = '\(NutritionDefaultModel.shared.calories)'"
                                                + ", proteinTarget = '\(NutritionDefaultModel.shared.protein)'"
                                                + ", carbohydrateTarget = '\(NutritionDefaultModel.shared.carbohydrate)'"
                                                + ", fatTarget = '\(NutritionDefaultModel.shared.fat)'"
                                                + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDateTemp)'));")
                                DLLog(message: "SQL语句更新  ----  success")
                            }catch{
                                DLLog(message: "SQL语句更新  ----  执行失败")
                            }
                        }
                    }
                }else{
//                    serialQueue.async {
//                        self.insertLogs(sDate: sDateTemp, calori: "", protein: "", carbohydrates: "", fats: "", notes: "", foods: "", caloriTar: NutritionDefaultModel.shared.calories, proteinTar: NutritionDefaultModel.shared.protein, carboTar: NutritionDefaultModel.shared.carbohydrate, fatsTar: NutritionDefaultModel.shared.fat, upload: false, eTime: Date().currentSeconds)
//                    }
                }
            }
        }
        LogsSQLiteUploadManager().updateNaturalGoalForWidget()
    }
    func refreshDataTarget(goalArray:NSArray,startIndex:Int=0) {
        let serialQueue = DispatchQueue(label: "com.logs.sqlite")
        
        //修改本地未来100天内的日志数据
        for i in 0..<100{
            let sDateTemp = Date().nextDay(days: i)
            
            let index = (i+startIndex)%goalArray.count
            let goalDict = goalArray[index]as? NSDictionary ?? [:]
            
            let caloriTar = goalDict.stringValueForKey(key: "calories")
            let carbohydrateTar = goalDict.stringValueForKey(key: "carbohydrates")
            let proteinTar = goalDict.stringValueForKey(key: "proteins")
            let fatTar = goalDict.stringValueForKey(key: "fats")
            let circleTag = goalDict.stringValueForKey(key: "carbLabel")
            
            if queryTable(sDate: sDateTemp){//如果存在数据
                serialQueue.async {
                    do {
                        let sql = self.logs.filter(self.sdate == sDateTemp).filter(self.uid == UserInfoModel.shared.uId)
                        try self.db?.run(sql.update(self.caloriTarget<-caloriTar,
                                                    self.proteinTarget<-proteinTar,
                                                    self.carbohydrateTarget<-carbohydrateTar,
                                                    self.fatTarget<-fatTar,
                                                    self.etime<-Date().currentSecondsUTC8,
                                                    self.circle_tag<-circleTag))
//                            DLLog(message:"更改目标值 success")
                    } catch {
                        DLLog(message:"Unable to update logs details")
                        do {
                            try self.db?.execute("UPDATE logs SET"
                                            + " caloriTarget = '\(caloriTar)'"
                                            + ", proteinTarget = '\(proteinTar)'"
                                            + ", carbohydrateTarget = '\(carbohydrateTar)'"
                                            + ", fatTarget = '\(fatTar)'"
                                            + ", circle_tag = '\(circleTag)'"
                                            + ", etime = '\(Date().currentSecondsUTC8)'"
                                            + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDateTemp)'));")
                            DLLog(message: "SQL语句更新  ----  success")
                        }catch{
                            DLLog(message: "SQL语句更新  ----  执行失败")
                        }
                    }
                }
            }else{
                serialQueue.async {
                    self.insertLogs(sDate: sDateTemp, calori: "", protein: "", carbohydrates: "", fats: "", notes: "", foods: "", caloriTar: caloriTar, proteinTar: proteinTar, carboTar: carbohydrateTar, fatsTar: fatTar, upload: false, eTime: Date().currentSecondsUTC8,circleTag: circleTag,fitnessTag: "", notesTag: "")
                }
            }
        }
    }
    ///更新用户单日目标 +  碳循环标签
    func updateSingelDateGoal(caloriTar:String,carbohydrateTar:String,proteinTar:String,fatTar:String,circleTag:String,sdate:String) {
        if queryTable(sDate: sdate){//如果存在数据
            do {
                let sql = self.logs.filter(self.sdate == sdate).filter(self.uid == UserInfoModel.shared.uId)
                try self.db?.run(sql.update(self.caloriTarget<-caloriTar,
                                            self.proteinTarget<-proteinTar,
                                            self.carbohydrateTarget<-carbohydrateTar,
                                            self.fatTarget<-fatTar,
                                            self.etime<-Date().currentSecondsUTC8,
                                            self.circle_tag<-circleTag))
//                            DLLog(message:"更改目标值 success")
            } catch {
                DLLog(message:"Unable to update logs details")
                do {
                    try self.db?.execute("UPDATE logs SET"
                                    + " caloriTarget = '\(caloriTar)'"
                                    + ", proteinTarget = '\(proteinTar)'"
                                    + ", carbohydrateTarget = '\(carbohydrateTar)'"
                                    + ", fatTarget = '\(fatTar)'"
                                    + ", circle_tag = '\(circleTag)'"
                                    + ", etime = '\(Date().currentSecondsUTC8)'"
                                    + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sdate)'));")
                    DLLog(message: "SQL语句更新  ----  success")
                }catch{
                    DLLog(message: "SQL语句更新  ----  执行失败")
                }
            }
        }else{
            self.insertLogs(sDate: sdate, calori: "", protein: "", carbohydrates: "", fats: "", notes: "", foods: "", caloriTar: caloriTar, proteinTar: proteinTar, carboTar: carbohydrateTar, fatsTar: fatTar, upload: true, eTime: Date().currentSecondsUTC8,circleTag: circleTag,fitnessTag: "", notesTag: "")
        }
    }
    func deleteAllData(){
        do {
            try db?.run(logs.delete())
        }catch{
            
        }
        LogsSQLiteUploadManager().clearNaturalData()
        LogsMealsAlertSetManage().refreshClockAlertMsg()
    }
    //MARK: SQL 语句查询数据
    func queryDataBySQL(sDate:String) -> LogsModel? {
        NutritionDefaultModel.shared.getDefaultGoal(weekDay: Date().getWeekdayIndex(from: sDate))
        let date = Date().changeDateStringToDate(dateString: sDate)
        let modelTemp = LogsModel(uid: UserInfoModel.shared.uId,
                                  sdate: sDate,
                                  date: date,
                                  ctime: Date().todaySeconds,
                                  etime: "2020-05-23 15:15:13",
                              foods: "[[],[],[],[],[],[]]",
                              calori: "0",
                              protein:"0",
                              carbohydrate: "0",
                              fat: "0",
                              notes: "",
                              caloriTarget:NutritionDefaultModel.shared.calories,
                              proteinTarget:NutritionDefaultModel.shared.protein,
                              carbohydrateTarget:NutritionDefaultModel.shared.carbohydrate,
                              fatTarget:NutritionDefaultModel.shared.fat,
                                  isUpload: false,
                                  waterNum:"",
                                  waterUpload:"",
                                  waterETime:"",
                                  circleTag: "",
                                  fitnessTag: "",
                                  notesTag: "")
        
        do {
            if let rows = try db?.prepare("SELECT * FROM logs WHERE sdate == '\(sDate)' AND uid == '\(UserInfoModel.shared.uId)'"){
                DLLog(message: "---- \(rows)")
                for row in rows{
                    let model =  LogsModel(uid: UserInfoModel.shared.uId,
                                           sdate: row[1]as? String ?? "",
                                           date: Date().changeDateStringToDate(dateString: row[1]as? String ?? ""),
                                           ctime: Date().todaySeconds,
                                           etime: row[3]as? String ?? "",
                                           foods: "\(row[4]as? String ?? "[[],[],[],[],[],[]]")".replacingOccurrences(of: "‘", with: "'"),
                                          calori: row[5]as? String ?? "",
                                          protein:row[6]as? String ?? "",
                                          carbohydrate: row[7]as? String ?? "",
                                          fat: row[8]as? String ?? "",
                                          notes: row[13]as? String ?? "",
                                          caloriTarget:row[9]as? String ?? "",
                                          proteinTarget:row[10]as? String ?? "",
                                          carbohydrateTarget:row[11]as? String ?? "",
                                           fatTarget:row[12]as? String ?? "",
                                           isUpload: row[15]as? String ?? "" == "1" ? true : false,
                                           waterNum:row[22]as? String ?? "",
                                           waterUpload:row[23]as? String ?? "",
                                           waterETime:row[24]as? String ?? "",
                                           circleTag: row[25]as? String ?? "",
                                           fitnessTag: row[26]as? String ?? "",
                                           notesTag: row[27]as? String ?? "")
//                    DLLog(message: "SELECT RESULT:\(row)")
                    return model
                }
            }
        }catch {
            DLLog(message:"查询错误")
        }
        
        return modelTemp
    }
    func queryTable(sDate:String) -> Bool{
        let model = queryDataBySQL(sDate: sDate)
        
        if model?.etime == "2020-05-23 15:15:13" && model?.notes == ""{
            return false
        }else{
            return true
        }
    }
    func getLogsByDate(sDate:String) -> LogsModel? {
        let model = queryDataBySQL(sDate: sDate)
        return model
    }
    
    func saveServerDataToDB(dataArray:NSArray) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            for i in 0..<dataArray.count{
                let dict = dataArray[i]as? NSDictionary ?? [:]
                var serverETime = dict.stringValueForKey(key: "etime")
                serverETime = serverETime.replacingOccurrences(of: "T", with: " ")
                let sDate = dict.stringValueForKey(key: "sdate")
                
                let waterDict = dict["dietLogWater"]as? NSDictionary ?? [:]
                let serverWaterETime = waterDict.stringValueForKey(key: "etime").replacingOccurrences(of: "T", with: " ")
                
                let circleTag = dict.stringValueForKey(key: "carbLabel")
                var fitnessLabelArray = NSMutableArray(array: dict["fitnessLabelArray"]as? NSArray ?? [])
                for i in 0..<fitnessLabelArray.count{
                    let str = fitnessLabelArray[i]as? String ?? ""
                    if str == "[]" || str == "-"{
                        fitnessLabelArray.removeObject(at: i)
                        break
                    }
                }
                let fitnessTag = fitnessLabelArray.count > 0 ? WHUtils.getJSONStringFromArray(array: fitnessLabelArray) : ""//dict.stringValueForKey(key: "fitnessLabel")
                
                var notesTag = dict.stringValueForKey(key: "notesLabel")
                if let notesLabelArr = dict["notesLabel"] as? NSArray{
                    notesTag = WHUtils.getJSONStringFromArray(array: notesLabelArr)
                }
                
                var foodsString = WHUtils.getJSONStringFromArray(array: dict["foods"]as? NSArray ?? [])
                foodsString = foodsString.replacingOccurrences(of: "'", with: "’")
                if queryTable(sDate: sDate){//如果存在数据
//                    DLLog(message: "存在数据")
                    let model = LogsSQLiteManager.getInstance().getLogsByDate(sDate: sDate)!
                    
                    if Date().judgeMin(firstTime: model.etime, secondTime: serverETime){
                        do {
                            let sql = logs.filter(sdate == sDate).filter(uid == UserInfoModel.shared.uId)
                            try db?.run(sql.update(self.foods<-foodsString,
                                                   self.calori<-dict.stringValueForKey(key: "calories"),
                                                   self.protein<-dict.stringValueForKey(key: "protein"),
                                                   self.carbohydrate<-dict.stringValueForKey(key: "carbohydrate"),
                                                   self.fat<-dict.stringValueForKey(key: "fat"),
                                                   self.caloriTarget<-dict.stringValueForKey(key: "caloriesden"),
                                                   self.proteinTarget<-dict.stringValueForKey(key: "proteinden"),
                                                   self.carbohydrateTarget<-dict.stringValueForKey(key: "carbohydrateden"),
                                                   self.etime <- (dict.stringValueForKey(key: "etime").pregReplace(pattern: "T", with: " ")),
                                                   self.isUploadString<-"1",
                                                   self.fatTarget<-dict.stringValueForKey(key: "fatden"),
                                                   self.water_num<-waterDict.stringValueForKey(key: "qty"),
                                                   self.water_upload<-"1",
                                                   self.notes<-dict.stringValueForKey(key: "notes"),
                                                   self.notes_tag<-dict.stringValueForKey(key: "notesLabel"),
                                                   self.water_etime<-serverWaterETime,
                                                   self.circle_tag<-circleTag,
                                                   self.fitness_tag<-fitnessTag,
                                                   self.notes_tag<-notesTag))
//                            DLLog(message:"更新日志成功 \(sDate)")
                        } catch {
                            DLLog(message:"更新日志失败 \(sDate)")
                            do {
                                try db?.execute("UPDATE logs SET"
                                                + " etime = '\(dict.stringValueForKey(key: "etime").pregReplace(pattern: "T", with: " "))'"
                                                + ", foods = '\(foodsString)'"
                                                + ", calori = '\(dict.stringValueForKey(key: "calories"))'"
                                                + ", protein = '\(dict.stringValueForKey(key: "protein"))'"
                                                + ", carbohydrate = '\(dict.stringValueForKey(key: "carbohydrate"))'"
                                                + ", fat = '\(dict.stringValueForKey(key: "fat"))'"
                                                + ", caloriTarget = '\(dict.stringValueForKey(key: "caloriesden"))'"
                                                + ", proteinTarget = '\(dict.stringValueForKey(key: "proteinden"))'"
                                                + ", carbohydrateTarget = '\(dict.stringValueForKey(key: "carbohydrateden"))'"
                                                + ", fatTarget = '\(dict.stringValueForKey(key: "fatden"))'"
                                                + ", isUploadString = '1'"
                                                + ", water_num = '\(waterDict.stringValueForKey(key: "qty"))'"
                                                + ", water_upload = '1'"
                                                + ", water_etime = '\(serverWaterETime)'"
                                                + ", circle_tag = '\(circleTag)'"
                                                + ", fitness_tag = '\(fitnessTag)'"
                                                + ", notes_tag = '\(notesTag)'"
                                                + " WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'));")
                                DLLog(message: "SQL语句更新  ----  success")
                            }catch{
                                DLLog(message: "SQL语句更新  ----  执行失败")
                            }
                        }
                    }else{
                        DLLog(message: "不需要更新") 
                    }
                }else{//如果不存在数据
//                    DLLog(message: "不存在数据")
                    DLLog(message: "sendLogsAllDataRequest:\(dict)")
                    insertLogs(sDate: sDate,
                               calori: dict.stringValueForKey(key: "calories"),
                               protein: dict.stringValueForKey(key: "protein"),
                               carbohydrates: dict.stringValueForKey(key: "carbohydrate"),
                               fats: dict.stringValueForKey(key: "fat"),
                               notes: dict.stringValueForKey(key: "notes"),
                               foods: foodsString,
                               caloriTar: dict.stringValueForKey(key: "caloriesden"),
                               proteinTar: dict.stringValueForKey(key: "proteinden"),
                               carboTar: dict.stringValueForKey(key: "carbohydrateden"),
                               fatsTar: dict.stringValueForKey(key: "fatden"),
                               upload: true,
                               eTime: (dict.stringValueForKey(key: "etime").pregReplace(pattern: "T", with: " ")),
                               waterNum: waterDict.stringValueForKey(key: "qty"),
                               waterUpload: "1",
                               waterEtime: serverWaterETime,
                               circleTag: circleTag,
                               fitnessTag: fitnessTag,
                               notesTag: notesTag)
                }
            }
            UserDefaults.standard.setValue("1", forKey: "\(UserInfoModel.shared.uId)LogsData")
        }
    }
    
    //MARK: 检查本地数据上传状态-获取所有数据
    func queryTableAll() -> NSArray {
        let models = NSMutableArray()
        do {
            if let rows = try db?.prepare("SELECT * FROM logs WHERE uid == '\(UserInfoModel.shared.uId)' ORDER BY sdate"){
                DLLog(message: "---- \(rows)")
                for row in rows{
//                    DLLog(message: "SELECT RESULT:\(row)")
                    
                    let dict = ["sdate":row[1]as? String ?? "",
                                "foods":row[4]as? String ?? "[[],[],[],[],[],[]]",
                                "notes":row[13]as? String ?? "",
                                "etime":row[3]as? String ?? "",
                                "carbLabel":row[25]as? String ?? "",
                                "fitnessLabel":row[26]as? String ?? "",
                                "notesTag":row[27]as? String ?? "",
                                "isUpload":row[15]as? String ?? "" == "1" ? true : false] as [String : Any]
                    models.add(dict)
                }
            }
            
        } catch {
//            return models
        }
        
        return models
    }
    func queryLogsDataForMealsTime(sDate:String) -> NSDictionary {
        var dict = NSDictionary()
        do {
            if let rows = try db?.prepare("SELECT * FROM logs WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'))"){
                DLLog(message: "---- \(rows)")
                for row in rows{
                    DLLog(message: "queryLogsDataForMealsTime SELECT RESULT:\(row)")
                    dict = ["mealTimeSn1":row[16]as? String ?? "",
                            "mealTimeSn2":row[17]as? String ?? "",
                            "mealTimeSn3":row[18]as? String ?? "",
                            "mealTimeSn4":row[19]as? String ?? "",
                            "mealTimeSn5":row[20]as? String ?? "",
                            "mealTimeSn6":row[21]as? String ?? ""]
                    
                }
            }
        } catch {
//            return models
        }
        
        return dict
    }
    func getMealsTimeForUpload(sDate:String) -> NSDictionary {
        var dict = NSDictionary()
        do {
            if let rows = try db?.prepare("SELECT * FROM logs WHERE ((uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)'))"){
                DLLog(message: "---- \(rows)")
                for row in rows{
                    DLLog(message: "getMealsTimeForUpload SELECT RESULT:\(row)")
                    dict = ["meal_time_sn1":row[16]as? String ?? "",
                            "meal_time_sn2":row[17]as? String ?? "",
                            "meal_time_sn3":row[18]as? String ?? "",
                            "meal_time_sn4":row[19]as? String ?? "",
                            "meal_time_sn5":row[20]as? String ?? "",
                            "meal_time_sn6":row[21]as? String ?? ""]
                    
                }
            }
        } catch {
//            return models
        }
        
        return dict
    }
    func queryLogsData(sdata:String) -> NSDictionary {
        var dict = NSDictionary()
        do {
            let items = try db!.prepare(logs.filter(uid == UserInfoModel.shared.uId).filter(sdate == sdata))
            for row in items{
                dict = ["sdate":row[sdate],
                            "foods":row[foods],
                            "notes":row[notes],
                        "carbLabel":row[circle_tag],
                        "fitnessLabel":row[fitness_tag],
                        "notesTag":row[notes_tag],
                        "isUpload":row[isUploadString] == "1" ? true : false]
            }
            if let rows = try db?.prepare("SELECT * FROM logs WHERE uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sdata)'"){
                DLLog(message: "---- \(rows)")
                for row in rows{
//                    DLLog(message: "SELECT RESULT:\(row)")
                    
                    dict = ["sdate":row[1]as? String ?? "",
                            "foods":"\(row[4]as? String ?? "[[],[],[],[],[],[]]")".replacingOccurrences(of: "‘", with: "'"),
                            "notes":row[13]as? String ?? "",
                            "etime":row[3]as? String ?? "",
                            "carbLabel":row[25]as? String ?? "",
                            "fitnessLabel":row[26]as? String ?? "",
                            "notesTag":row[27]as? String ?? "",
                            "isUpload":row[15]as? String ?? "" == "1" ? true : false]
                }
            }
        } catch {
//            return models
        }
        
        return dict
    }
}
