//
//  CourseProgressSQLiteManager.swift
//  lns
//
//  Created by Elavatine on 2025/5/30.
//

import Foundation
import SQLite

struct CourseProgressModel {
    var uid: String
    var tutorialId: String
    var courseId: String
    var progress: Double
    var duration: Double
    var updateTime: String
}

class CourseProgressSQLiteManager {
    static let shared = CourseProgressSQLiteManager()
    private var db: Connection?

    private let table = Table("course_progress")
    private let uid = Expression<String>(value: "uid")
    private let tutorialId = Expression<String>(value:"tutorialId")
    private let courseId = Expression<String>(value:"courseId")
    private let progress = Expression<String>(value:"progress")
    private let duration = Expression<String>(value:"duration")
    private let updateTime = Expression<String>(value:"updateTime")

    class func getInstance() -> CourseProgressSQLiteManager {
        if shared.db == nil {
            do {
                let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileUrl = documentDirectory.appendingPathComponent("elavatine").appendingPathExtension("sqlite3")
                shared.db = try Connection(fileUrl.path)
                shared.createTable()
            } catch {
                DLLog(message:"DB Error \(error)")
            }
        }
        return shared
    }

    private func createTable() {
        do {
            try db?.run(table.create(ifNotExists: true) { t in
                t.column(uid)
                t.column(tutorialId)
                t.column(courseId)
                t.column(progress)
                t.column(duration)
                t.column(updateTime)
                t.primaryKey(uid, tutorialId)
            })
        } catch {
            DLLog(message:"Unable to create table <course_progress>")
        }
    }

    func updateProgress(tutorialId: String, courseId: String, progress: Double, duration: Double) {
        let timeStr = "\(Date().timeIntervalSince1970)"
        if queryTable(tutorialId: tutorialId){
            do {
                let updateSql = "UPDATE course_progress SET"
                + " progress = '\(progress)'"
                + ", duration = '\(duration)'"
                + ", updateTime = '\(timeStr)'"
                + " WHERE (uid == '\(UserInfoModel.shared.uId)' AND tutorialId == '\(tutorialId)');"
                
                try self.db?.execute(updateSql)
            } catch {
                DLLog(message: "更新单条数据Fail <course_progress> ")
            }
        }else{
            do {
                try db?.execute("INSERT INTO course_progress (uid,courseId,tutorialId,progress,duration,updateTime) VALUES ('\(UserInfoModel.shared.uId)','\(courseId)','\(tutorialId)','\(progress)','\(duration)','\(timeStr)')")
                DLLog(message: "SQL语句插入  ----  success")
            }catch{
                DLLog(message: "SQL语句插入  ----  执行失败")
            }
        }
    }

    func queryProgress(tutorialId: String) -> Double {
        do {
            if let rows = try db?.prepare("SELECT * FROM course_progress WHERE tutorialId == '\(tutorialId)' AND uid == '\(UserInfoModel.shared.uId)'"){
//                DLLog(message: "---- \(rows)")
                for row in rows{
                    return (row[3]as? String ?? "0").doubleValue
                }
            }
        }catch {
            
        }
        return 0
    }

    func queryDuration(tutorialId: String) -> Double {
        do {
            if let rows = try db?.prepare("SELECT * FROM course_progress WHERE tutorialId == '\(tutorialId)' AND uid == '\(UserInfoModel.shared.uId)'"){
//                DLLog(message: "---- \(rows)")
                for row in rows{
                    return (row[4]as? String ?? "0").doubleValue
                }
            }
        }catch {
            
        }
        return 0
    }
    func queryTable(tutorialId:String) -> Bool{
        do {
            if let rows = try db?.prepare("SELECT * FROM course_progress WHERE tutorialId == '\(tutorialId)' AND uid == '\(UserInfoModel.shared.uId)'"){
                DLLog(message: "---- \(rows)")
                for row in rows{
                    return true
                }
                return false
            }
        }catch {
            
        }
        return false
    }
    func deleteAllData(){
        do {
            try db?.run(table.delete())
        }catch{
            
        }
    }
}
