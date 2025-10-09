//
//  SportDataSQLiteManager.swift
//  lns
//
//  Created by Elavatine on 2024/11/26.
//


import Foundation
import SQLite

class SportDataSQLiteManager {
    
    static let shared = SportDataSQLiteManager()
    
    private var db: Connection?
    
    private let table = Table("sportData")
    private let uid   = Expression<String>(value: "uid")
    private let sdate = Expression<String>(value: "sdate")
    private let sports = Expression<String>(value: "sports")
    private let sportCalories = Expression<String>(value: "sportCalories")
    private let sportDuration = Expression<String>(value: "sportDuration")
    
    class func getInstance() -> SportDataSQLiteManager
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
            try db?.run(table.create { t in
                t.column(uid)
                t.column(sdate)
                t.column(sports)
                t.column(sportCalories)
                t.column(sportDuration)
                t.primaryKey(uid,sdate)
            })
        } catch {
            DLLog(message:"Unable to create table <sportData>")
        }
        
    }
    //MARK: 更新数据
    func updateSportsData(ctime:String,sportsData:String) {
        if queryTable(sDate: ctime){
            do {
                let updateSql = "UPDATE sportData SET"
                + " sports = '\(sportsData)'"
                + " WHERE (uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(ctime)');"
                
                try self.db?.execute(updateSql)
            }catch{
                DLLog(message: "更新运动数据 ********* 失败 :   (\(ctime)) -- (sports)  :  \(sportsData)")
            }
        }else{
            do {
                try db?.execute("INSERT INTO sportData (uid,sdate,sports,sportCalories,sportDuration) VALUES ('\(UserInfoModel.shared.uId)','\(ctime)','\(sportsData)','','')")
                DLLog(message: "SQL语句插入  ----  success")
            }catch{
                DLLog(message: "SQL语句插入  ----  执行失败")
            }
        }
    }
    func updateSportsNumber(sDate:String,calories:String,duration:String) {
        if queryTable(sDate: sDate){
            do {
                let updateSql = "UPDATE sportData SET"
                + " sportCalories = '\(calories)'"
                + " WHERE (uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)');"
                
                try self.db?.execute(updateSql)
            }catch{
                DLLog(message: "更新运动数据 ********* 失败 :   (\(sDate)) -- (sportCalories)  :  \(calories)")
            }
            do {
                let updateSql = "UPDATE sportData SET"
                + " sportDuration = '\(duration)'"
                + " WHERE (uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)');"
                
                try self.db?.execute(updateSql)
            }catch{
                DLLog(message: "更新运动数据 ********* 失败 :   (\(sDate)) -- (sportDuration)  :  \(duration)")
            }
        }else{
            do {
                try db?.execute("INSERT INTO sportData (uid,sdate,sports,sportCalories,sportDuration) VALUES ('\(UserInfoModel.shared.uId)','\(sDate)','','\(calories)','\(duration)')")
                DLLog(message: "SQL语句插入  ----  success")
            }catch{
                DLLog(message: "SQL语句插入  ----  执行失败")
            }
        }
    }
    func querySportsData(sDate:String) -> NSDictionary{
        var dataDict = NSDictionary()
        do {
            if let rows = try db?.prepare("SELECT * FROM sportData WHERE (uid == '\(UserInfoModel.shared.uId)' AND sdate == '\(sDate)')"){
                DLLog(message: "---- \(rows)")
                for row in rows{
                    dataDict = ["sdate":row[1]as? String ?? "",
                                "sports":row[2]as? String ?? "",
                                "sportCalories":row[3]as? String ?? "",
                                "sportDuration":row[4]as? String ?? ""]
                    return dataDict
                }
            }
        }catch {
            DLLog(message:"查询错误")
        }
        return dataDict
    }
    /**
     查询某一天是否存在数据
     */
    func queryTable(sDate:String) -> Bool{
        do {
            if let rows = try db?.prepare("SELECT * FROM sportData WHERE sdate == '\(sDate)' AND uid == '\(UserInfoModel.shared.uId)'"){
                DLLog(message: "---- \(rows)")
                for _ in rows{
                    return true
                }
            }
        }catch {
            DLLog(message:"查询错误")
        }
        return false
    }
}
