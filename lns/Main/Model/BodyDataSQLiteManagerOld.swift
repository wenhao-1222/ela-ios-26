//
//  BodyDataSQLiteManagerOld.swift
//  lns
//
//  Created by Elavatine on 2024/10/13.
//


import Foundation
import SQLite

class BodyDataSQLiteManagerOld {
    
    static let shared = BodyDataSQLiteManagerOld()
    
    private var db: Connection?
    //    let db = try! Connection("/path/to/db.sqlite3")
    private let table = Table("bodydata")
    private let uid   = Expression<String>("uid")
    private let ctime = Expression<String>("ctime")
    private let imgUrl = Expression<String>( "imgurl")
    private let hips = Expression<String>( "hips")
    private let waistline = Expression<String>( "waistline")
    private let weight = Expression<String>( "weight")
    private let armcircumference = Expression<String>( "armcircumference")
    private let isUpload = Expression<Bool>( "isUpload")
    private let shoulder = Expression<String>( "shoulder")
    private let bust = Expression<String>( "bust")
    private let thigh = Expression<String>( "thigh")
    private let calf = Expression<String>( "calf")
    private let images = Expression<String>( "images")
    
    class func getInstance() -> BodyDataSQLiteManagerOld
    {
        if(shared.db == nil)
        {
            do{
                let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileUrl = documentDirectory.appendingPathComponent("dbname").appendingPathExtension("sqlite3")
                shared.db = try Connection(fileUrl.path)
                
            }catch{
                DLLog(message:"DB Error \(error)")
            }
        }
        return shared
    }
}

extension BodyDataSQLiteManagerOld{
    func queryTableAll() -> NSArray {
        let models = NSMutableArray()
        do {
            if let rows = try db?.prepare("SELECT * FROM bodydata WHERE uid == '\(UserInfoModel.shared.uId)'"){
                for row in rows{
                    let dict = ["ctime":row[1]as? String ?? "",
                                "imgurl":row[2]as? String ?? "",
                                "hips":row[3]as? String ?? "",
                                "weight":row[4]as? String ?? "",
                                "waistline":row[5]as? String ?? "",
                                "armcircumference":row[6]as? String ?? "",
                                "shoulder":row[7]as? String ?? "",
                                "bust":row[8]as? String ?? "",
                                "thigh":row[9]as? String ?? "",
                                "calf":row[10]as? String ?? ""] as [String : Any]
                    models.add(dict)
                }
            }
        }catch {
            DLLog(message:"查询错误")
        }
        return models
    }
}

