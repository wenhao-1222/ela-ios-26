//
//  BodyDataSQLiteManager.swift
//  lns
//
//  Created by LNS2 on 2024/5/15.
//

import Foundation
import SQLite
//import HealthKit

enum QUERY_TYPE {
    case week
    case moneth
    case two_moneth
    case three_moneth
    case six_moneth
    case one_year
    case all
}

struct BodyDataModel{
    var uid   : String
    var ctime  : String
    var imgurl  : String
    var hips  : String        //臀围
    var waistline  : String   //腰围
    var weight  : String      //体重
    var armcircumference  : String   //臂围
    var shoulder : String
    var bust : String
    var thight : String
    var calf : String
    var bfp : String
    var isUpload : Bool
    
    func dictToModel(dict:NSDictionary) -> BodyDataModel {
        var model = BodyDataModel(uid: UserInfoModel.shared.uId,
                                  ctime: "",
                                  imgurl: "",
                                  hips: "",
                                  waistline: "",
                                  weight: "",
                                  armcircumference: "",
                                  shoulder: "",
                                  bust: "",
                                  thight: "",
                                  calf: "",
                                  bfp: "",
                                  isUpload: false)
        
        model.ctime = dict.stringValueForKey(key: "ctime")
        model.imgurl = dict.stringValueForKey(key: "imgurl")
        model.hips  = dict.stringValueForKey(key: "hips")
        model.waistline  = dict.stringValueForKey(key: "waistline")
        model.weight  = dict.stringValueForKey(key: "weight")
        model.armcircumference  = dict.stringValueForKey(key: "armcircumference")
        model.shoulder = dict.stringValueForKey(key: "shoulder")
        model.bust = dict.stringValueForKey(key: "bust")
        model.thight = dict.stringValueForKey(key: "thight")
        model.calf = dict.stringValueForKey(key: "calf")
        model.bfp = dict.stringValueForKey(key: "bfp")
        
        return model
    }
    func printMsg() {
        DLLog(message: "\(ctime)  -- \(hips)  - \(waistline)  -\(weight)  -\(armcircumference)")
    }
}


class BodyDataSQLiteManager {
    
    static let shared = BodyDataSQLiteManager()
    
    private var db: Connection?
    //    let db = try! Connection("/path/to/db.sqlite3")
    private let table = Table("bodydata")
    private let uid   = Expression<String>("uid")
    private let ctime = Expression<String>("ctime")
    private let imgUrl = Expression<String>("imgurl")
    private let hips = Expression<String>("hips")
    private let waistline = Expression<String>("waistline")
    private let weight = Expression<String>("weight")
    private let armcircumference = Expression<String>("armcircumference")
    private let isUpload = Expression<Bool>("isUpload")
    private let isUploadString = Expression<Bool>("isUploadString")
    private let shoulder = Expression<String>("shoulder")
    private let bust = Expression<String>("bust")
    private let thigh = Expression<String>("thigh")
    private let calf = Expression<String>("calf")
    private let bfp = Expression<String>("bfp")
    private let images = Expression<String>("images")
    private let localImages = Expression<String>("images_local_paths")
        
    class func getInstance() -> BodyDataSQLiteManager
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
                t.column(ctime)
                t.column(imgUrl)
                t.column(hips)
                t.column(weight)
                t.column(waistline)
                t.column(armcircumference)
                t.column(shoulder)
                t.column(bust)
                t.column(thigh)
                t.column(calf)
//                t.column(isUpload)
                t.column(isUploadString)
                t.column(images)
                t.column(localImages)
                t.column(bfp)
                t.primaryKey(uid,ctime)
            })
        } catch {
            DLLog(message:"Unable to create table <bodydata>")
//            isShoulderExist()
            isNewColumnExist(columnNames: "bfp")
            isNewColumnExist(columnNames: "shoulder")
            isNewColumnExist(columnNames: "bust")
            isNewColumnExist(columnNames: "thigh")
            isNewColumnExist(columnNames: "calf")
            isNewColumnExist(columnNames: "isUploadString")
            isNewColumnExist(columnNames: "images_local_paths")
        }
        
    }
    func isNewColumnExist(columnNames:String) {
        do {
            var isExist = false
            let expression = table.expression
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
                    try db?.execute("alter table bodydata add column '\(columnNames)' TEXT DEFAULT ''")
                    print("add----success")
                } catch {
                    print("add----Error")
                }
            }
        } catch {
            
        }
    }
    func isShoulderExist() {
        do {
            var isExist = false
            let expression = table.expression
            let colunmnNames = try db?.prepare(expression.template,expression.bindings).columnNames
            if colunmnNames?.count ?? 0 > 0 {
                for i in 0..<(colunmnNames?.count ?? 0) {
                    let colName = colunmnNames?[i]as? String ?? ""
                    if colName == "bust" {
                        isExist = true
                        break
                    }
                }
            }
            
            if !isExist {
                do {
                    try db?.execute("alter table bodydata add column 'shoulder' TEXT DEFAULT ''")
                    try db?.execute("alter table bodydata add column 'bust' TEXT DEFAULT ''")
                    try db?.execute("alter table bodydata add column 'thigh' TEXT DEFAULT ''")
                    try db?.execute("alter table bodydata add column 'calf' TEXT DEFAULT ''")
                    print("add----success")
                } catch {
                    print("add----Error")
                }
            }
        } catch {
            
        }
    }
    func isUploaderStringExist() {
        do {
            var isExist = false
            let expression = table.expression
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
                    try db?.execute("alter table bodydata add column 'isUploadString' TEXT DEFAULT ''")
                    print("add----success")
                } catch {
                    print("add----Error")
                }
            }
        } catch {
            
        }
    }
    
    private func insertData(cTime: String,
                            imgurl: String,
                            hipsData:String,
                            weightData:String,
                            waistlineData:String,
                            armcircumferenceData:String,
                            shoulderData:String,
                            bustData:String,
                            thighData:String,
                            calfData:String,
                            bfpData:String,
                            images:String,
                            upload:Bool) {
        do {
            let insert = table.insert(self.ctime <- cTime,
                                      self.uid <- UserInfoModel.shared.uId,
                                     self.imgUrl <- imgurl,
                                      self.hips <- hipsData,
                                      self.weight <- weightData,
                                      self.waistline <- waistlineData,
                                      self.armcircumference <- armcircumferenceData,
                                      shoulder<-shoulderData,
                                      bust<-bustData,
                                      thigh<-thighData,
                                      calf<-calfData,
                                      bfp<-bfpData,
                                      self.images<-images,
                                      self.localImages<-"",
                                      isUploadString<-upload)
            try db?.run(insert)
            DLLog(message:"更新身体数据成功(不存在数据) \(cTime)")
        } catch {
            DLLog(message:"更新身体数据失败 \(cTime)")
            insertDataUseSql(cTime: cTime, imgurl: imgurl, hipsData: hipsData, weightData: weightData, waistlineData: waistlineData, armcircumferenceData: armcircumferenceData, shoulderData: shoulderData, bustData: bustData, thighData: thighData, calfData: calfData, bfpData: bfpData,images:images, upload: upload)
        }
    }
    //MARK: SQL语句插入数据
    func insertDataUseSql(cTime: String,
                          imgurl: String,
                          hipsData:String,
                          weightData:String,
                          waistlineData:String,
                          armcircumferenceData:String,
                          shoulderData:String,
                          bustData:String,
                          thighData:String,
                          calfData:String,
                          bfpData:String,
                          images:String,
                          upload:Bool) {
        do {
            try db?.execute("INSERT INTO bodydata (uid,ctime,imgurl,hips,weight,waistline,armcircumference,shoulder,bust,thigh,calf,isUploadString,images,images_local_paths,bfp) VALUES ('\(UserInfoModel.shared.uId)','\(cTime)','\(imgurl)','\(hipsData)','\(weightData)','\(waistlineData)','\(armcircumferenceData)','\(shoulderData)','\(bustData)','\(thighData)','\(calfData)','\(upload ? 1 : 0)','\(images)','','\(bfpData)')")
            DLLog(message: "SQL语句插入  ----  success")
        }catch{
            DLLog(message: "SQL语句插入  ----  执行失败")
        }
    }
    //MARK: 更新单条身体数据
    func updateSingleData(columnName:String,data:String,cTime:String) {
//        saveSqlQueue.async {
        let dateReal = data.floatValue == 0 ? "" : data
            do {
                if data.floatValue > 0 || dateReal == "" || columnName == "images" || columnName == "images_local_paths"{
                    let updateSql = "UPDATE bodydata SET"
                    + " \(columnName) = '\(data)'"
                    + ", isUploadString = '0'"
                    + " WHERE (uid == '\(UserInfoModel.shared.uId)' AND ctime == '\(cTime)');"
                    
                    try self.db?.execute(updateSql)
                    
                    DLLog(message: "更新单条身体数据成功(\(cTime)) -- (\(columnName))  :  \(data)")
                }
            } catch {
            DLLog(message: "更新单条身体数据Fail :   (\(cTime)) -- (\(columnName))  :  \(data)")
            }
//        }怕
    }
    func updateLocalImgData(localImgString:String,cTime:String) {
//        saveSqlQueue.async {
            do {
                let updateSql = "UPDATE bodydata SET"
                + " images_local_paths = '\(localImgString)'"
                + " WHERE (uid == '\(UserInfoModel.shared.uId)' AND ctime == '\(cTime)');"
                
                try self.db?.execute(updateSql)
            } catch {
            DLLog(message: "更新身体数据本地图片Fail :   (\(cTime)) -- (images_local_paths)  :  \(localImgString)")
            }
//        }怕
    }
    /**
        更新身体数据
     */
    public func updateData(cTime: String,
                           imgurl: String,
                           hipsData:String,
                           weightData:String,
                           waistlineData:String,
                           shoulderData:String,
                           bustData:String,
                           thighData:String,
                           calfData:String,
                           bfpData:String,
                           images:String,
                           armcircumferenceData:String){
        //CREATE TABLE "bodydata" ('uid' TEXT NOT NULL, 'ctime' TEXT NOT NULL, 'imgurl' TEXT NOT NULL, 'hips' TEXT NOT NULL, 'weight' TEXT NOT NULL, 'waistline' TEXT NOT NULL, 'armcircumference' TEXT NOT NULL, 'shoulder' TEXT NOT NULL, 'bust' TEXT NOT NULL, 'thigh' TEXT NOT NULL, 'calf' TEXT NOT NULL, 'isUploadString' TEXT NOT NULL, 'images' TEXT NOT NULL, PRIMARY KEY ('uid', 'ctime'))
        if queryTable(sDate: cTime){
            let saveSqlQueue = DispatchQueue(label: "com.bodydata.saveToSql")
            if imgurl.count > 0{
                saveSqlQueue.async {
                    self.updateSingleData(columnName: "imgurl", data: imgurl, cTime: cTime)
                }
            }
            saveSqlQueue.async {
                if images.count > 0{
                    self.updateSingleData(columnName: "images", data: images, cTime: cTime)
                }else if images == ""{
                    self.updateSingleData(columnName: "images", data: "", cTime: cTime)
                }
            }
            
            saveSqlQueue.async {
                if hipsData.count > 0{
                    self.updateSingleData(columnName: "hips", data: hipsData, cTime: cTime)
                }else if hipsData == "0" || hipsData == ""{
                    self.updateSingleData(columnName: "hips", data: "", cTime: cTime)
                }
            }
                
            saveSqlQueue.async {
                if weightData.count > 0{
                    self.updateSingleData(columnName: "weight", data: "\(weightData)", cTime: cTime)
                }else if weightData == "0" || weightData == ""{
                    self.updateSingleData(columnName: "weight", data: "", cTime: cTime)
                }
            }
            
            saveSqlQueue.async {
                if waistlineData.count > 0{
                    self.updateSingleData(columnName: "waistline", data: "\(waistlineData)", cTime: cTime)
                }else if waistlineData == "0" || waistlineData == ""{
                    self.updateSingleData(columnName: "waistline", data: "", cTime: cTime)
                }
            }
            
            saveSqlQueue.async {
                if armcircumferenceData.count > 0{
                    self.updateSingleData(columnName: "armcircumference", data: "\(armcircumferenceData)", cTime: cTime)
                }else if armcircumferenceData == "0" || armcircumferenceData == ""{
                    self.updateSingleData(columnName: "armcircumference", data: "", cTime: cTime)
                }
            }
                
            saveSqlQueue.async {
                if shoulderData.count > 0{
                    self.updateSingleData(columnName: "shoulder", data: "\(shoulderData)", cTime: cTime)
                }else if shoulderData == "0" || shoulderData == ""{
                    self.updateSingleData(columnName: "shoulder", data: "", cTime: cTime)
                }
            }
                
            saveSqlQueue.async {
                if thighData.count > 0{
                    self.updateSingleData(columnName: "thigh", data: "\(thighData)", cTime: cTime)
                }else if thighData == "0" || thighData == ""{
                    self.updateSingleData(columnName: "thigh", data: "", cTime: cTime)
                }
            }
            
            saveSqlQueue.async {
                if bustData.count > 0{
                    self.updateSingleData(columnName: "bust", data: "\(bustData)", cTime: cTime)
                }else if bustData == "0" || bustData == ""{
                    self.updateSingleData(columnName: "bust", data: "", cTime: cTime)
                }
            }
            
            saveSqlQueue.async {
                if calfData.count > 0{
                    self.updateSingleData(columnName: "calf", data: "\(calfData)", cTime: cTime)
                }else if calfData == "0" || calfData == ""{
                    self.updateSingleData(columnName: "calf", data: "", cTime: cTime)
                }
            }
            saveSqlQueue.async {
                if bfpData.count > 0{
                    self.updateSingleData(columnName: "bfp", data: "\(bfpData)", cTime: cTime)
                }else if bfpData == "0" || bfpData == ""{
                    self.updateSingleData(columnName: "bfp", data: "", cTime: cTime)
                }
            }
        }else{
            insertData(cTime: cTime,
                       imgurl: imgurl,
                       hipsData: hipsData,
                       weightData: weightData,
                       waistlineData: waistlineData,
                       armcircumferenceData: armcircumferenceData,
                       shoulderData: shoulderData,
                       bustData: bustData,
                       thighData: thighData,
                       calfData: calfData,
                       bfpData: bfpData,
                       images:images,
                       upload: false)
        }
    }
    /**
        保存身体数据，从网络请求的
     */
    public func saveData(cTime: String,
                           imgurl: String,
                           hipsData:String,
                           weightData:String,
                           waistlineData:String,
                         shoulderData:String,
                         bustData:String,
                         thighData:String,
                         calfData:String,
                         bfpData:String,
                         images:String?,
                           armcircumferenceData:String){
        self.updateData(cTime: cTime, imgurl: imgurl, hipsData: hipsData, weightData: weightData, waistlineData: waistlineData, shoulderData: shoulderData, bustData: bustData, thighData: thighData, calfData: calfData, bfpData: bfpData, images: images ?? "", armcircumferenceData: armcircumferenceData)
    }
    //MARK: 从HealthKit更新体重数据
    func updateWeightDataFromHealthKit(cTime: String,weightData:String) {
        if queryTable(sDate: cTime){//如果存在数据
            if weightData.count > 0 && weightData.floatValue > 0{
                self.updateSingleData(columnName: "weight", data: weightData, cTime: cTime)
            }else if weightData == "0" || weightData == ""{
                self.updateSingleData(columnName: "weight", data: "", cTime: cTime)
            }
        }else{
            insertData(cTime: cTime,
                       imgurl: "",
                       hipsData: "",
                       weightData: weightData,
                       waistlineData: "",
                       armcircumferenceData: "",
                       shoulderData: "",
                       bustData: "",
                       thighData: "",
                       calfData: "",
                       bfpData: "",
                       images:"",
                       upload: false)
        }
    }
    /**
         更新身体数据上传状态
     */
    func updateUploadStatus(cTime: String,uploadStatus:Bool) {
        if queryTable(sDate: cTime){//如果存在数据
            do {
                try db?.run(table.filter(ctime == cTime)
                    .filter(uid == UserInfoModel.shared.uId)
                    .update(isUploadString <- uploadStatus))
                
//                DLLog(message:"更新身体数据状态成功 \(cTime)")
            }catch{
//                DLLog(message:"更新身体数据状态失败(SQLite)  \(cTime)")
                do {
                    let updateSql = "UPDATE bodydata SET "
                    + " isUploadString = '\(uploadStatus ? "1" : "0")'"
                    + " WHERE ((uid == '\(UserInfoModel.shared.uId)') AND (ctime == '\(cTime)'));"
                    try db?.execute(updateSql)
                    DLLog(message: "SQL语句 更新身体数据状态  success")
                }catch{
                    DLLog(message: "SQL语句 更新身体数据状态  失败")
                }
            }
        }
    }
    func queryBodyData(sDate:String) -> NSDictionary{
        var dataDict = NSDictionary()
        do {
            if let rows = try db?.prepare("SELECT * FROM bodydata WHERE (uid == '\(UserInfoModel.shared.uId)' AND ctime == '\(sDate)')"){
                DLLog(message: "---- \(rows)")
                for row in rows{
                    dataDict = ["ctime":row[1]as? String ?? "",
                                "uid":UserInfoModel.shared.uId,
                                "imgurl":row[2]as? String ?? "",
                                "images":row[12]as? String ?? "",
                                "localImages":row[13]as? String ?? "",
                                "hips":row[3]as? String ?? "",
                                "weight":row[4]as? String ?? "",
                                "waistline":row[5]as? String ?? "",
                                "armcircumference":row[6]as? String ?? "",
                                "shoulder":row[7]as? String ?? "",
                                "bust":row[8]as? String ?? "",
                                "thigh":row[9]as? String ?? "",
                                "calf":row[10]as? String ?? "",
//                                "bfp":row[14]as? String ?? ""
                                "bfp":row[14]as? String ?? "",
                                "isUpload":row[11]as? String ?? "" == "1" ? true : false]
                    return dataDict
                }
            }
        }catch {
            DLLog(message:"查询错误")
        }
        return dataDict
    }
    ///查询某一天的数据，是否有本地图片，这是本地数据未上传的时候，才会有。上传完数据后，会删除本地的身体图片
    ///2025年04月09日10:53
    func queryLocalImgs(sDate:String) -> NSArray{
       do {
           if let rows = try db?.prepare("SELECT * FROM bodydata WHERE ctime == '\(sDate)' AND uid == '\(UserInfoModel.shared.uId)'"){
               DLLog(message: "---- \(rows)")
               for row in rows{
                   let imgs = row[13]as? String ?? ""
                   let imgsArr = WHUtils.getArrayFromJSONString(jsonString: imgs)
                   return imgsArr.count == 3 ? imgsArr : ["","",""]
               }
           }
       }catch {
           DLLog(message:"查询错误")
       }
       return ["","",""]
   }
    /**
     查询某一天是否存在身体数据
     */
    func queryTable(sDate:String) -> Bool{
        DLLog(message: "UserInfoModel.shared.uId:\(UserInfoModel.shared.uId)")
        
        do {
            if let rows = try db?.prepare("SELECT * FROM bodydata WHERE ctime == '\(sDate)' AND uid == '\(UserInfoModel.shared.uId)'"){
                DLLog(message: "---- \(rows)")
                for row in rows{
                    return true
                }
            }
        }catch {
            DLLog(message:"查询错误")
        }
        return false
    }
    
    /// 查询某一天体重和上传状态
    func queryWeightInfo(sDate:String) -> (weight:String, isUpload:Bool)? {
        do {
            if let rows = try db?.prepare("SELECT weight,isUploadString FROM bodydata WHERE ctime == '\(sDate)' AND uid == '\(UserInfoModel.shared.uId)'"){
                for row in rows{
                    let weight = row[0] as? String ?? ""
                    let status = (row[1] as? String ?? "") == "1"
                    return (weight,status)
                }
            }
        }catch {
            DLLog(message:"查询错误")
        }
        return nil
    }
    func queryTableAll() -> NSArray {
        let models = NSMutableArray()
        do {
            if let rows = try db?.prepare("SELECT * FROM bodydata WHERE uid == '\(UserInfoModel.shared.uId)' ORDER BY ctime"){
                DLLog(message: "---- \(rows)")
                for row in rows{
                    let dict = ["ctime":row[1]as? String ?? "",
                                "imgurl":row[2]as? String ?? "",
                                "images":row[12]as? String ?? "",
                                "localImages":row[13]as? String ?? "",
                                "hips":row[3]as? String ?? "",
                                "weight":row[4]as? String ?? "",
                                "waistline":row[5]as? String ?? "",
                                "armcircumference":row[6]as? String ?? "",
                                "shoulder":row[7]as? String ?? "",
                                "bust":row[8]as? String ?? "",
                                "thigh":row[9]as? String ?? "",
                                "calf":row[10]as? String ?? "",
                                "bfp":row[14]as? String ?? "",
                                "isUpload":row[11]as? String ?? "" == "1" ? true : false] as [String : Any]
                    models.add(dict)
                }
            }
        }catch {
            DLLog(message:"查询错误")
        }
        return models
    }
    func queryLast14Datas() -> NSArray {
        let arr = NSMutableArray.init(array: queryTableAll())
        
        let weightArr = NSMutableArray()
        let dimensionalityArray = NSMutableArray()
        
        for i in 0..<arr.count{
            let dict = arr[i]as? NSDictionary ?? [:]
            if dict.doubleValueForKey(key: "weight") > 0 {
                weightArr.add(dict)
            }
            if dict.doubleValueForKey(key: "waistline") > 0 || dict.doubleValueForKey(key: "hips") > 0 || dict.doubleValueForKey(key: "armcircumference") > 0{
                dimensionalityArray.add(dict)
            }
        }
        
        var reWeightArr = NSArray.init(array: weightArr)
        var reDimensionalityArray = NSArray.init(array: dimensionalityArray)
        
        if weightArr.count > 14 {
            reWeightArr = weightArr.subarray(with: NSRange.init(location: weightArr.count-14, length: 14)) as NSArray
        }
        if dimensionalityArray.count > 14 {
            reDimensionalityArray = dimensionalityArray.subarray(with: NSRange.init(location: dimensionalityArray.count-14, length: 14)) as NSArray
        }
        return [reWeightArr,reDimensionalityArray]
    }
    func queryData(type:QUERY_TYPE) -> NSArray {
        let models = NSMutableArray()
        let today = Date().nextDay(days: 0)
        
        var firstDay = today
        
        switch type {
        case .all:
            return queryTableAll()
        case .week:
            firstDay = Date().getAdjustedDateString(offset: .days(7))
//            firstDay = Date().nextDay(days: -7, baseDate: today)
        case .moneth:
            firstDay = Date().getAdjustedDateString(offset: .months(1))
//            firstDay = Date().nextDay(days: -30, baseDate: today)
        case .two_moneth:
            firstDay = Date().getAdjustedDateString(offset: .months(2))
//            firstDay = Date().nextDay(days: -30*2, baseDate: today)
        case .three_moneth:
            firstDay = Date().getAdjustedDateString(offset: .months(3))
//            firstDay = Date().nextDay(days: -30*3, baseDate: today)
        case .six_moneth:
            firstDay = Date().getAdjustedDateString(offset: .months(6))
//            firstDay = Date().nextDay(days: -30*6, baseDate: today)
        case .one_year:
            firstDay = Date().getAdjustedDateString(offset: .years(1))
//            firstDay = Date().nextDay(days: -365, baseDate: today)
        }
        
        do {
            if let rows = try db?.prepare("SELECT * FROM bodydata WHERE ((uid == '\(UserInfoModel.shared.uId)') AND (ctime >= '\(firstDay)')) ORDER BY ctime"){
                DLLog(message: "---- \(rows)")
                for row in rows{
                    let dict = ["ctime":row[1]as? String ?? "",
                                "imgurl":row[2]as? String ?? "",
                                "images":row[12]as? String ?? "",
                                "hips":row[3]as? String ?? "",
                                "weight":row[4]as? String ?? "",
                                "waistline":row[5]as? String ?? "",
                                "armcircumference":row[6]as? String ?? "",
                                "shoulder":row[7]as? String ?? "",
                                "bust":row[8]as? String ?? "",
                                "thigh":row[9]as? String ?? "",
                                "calf":row[10]as? String ?? "",
                                "bfp":row[14]as? String ?? "",
                                "isUpload":row[11]as? String ?? "" == "1" ? true : false] as [String : Any]
                    models.add(dict)
                }
            }
        }catch {
            DLLog(message:"查询错误")
        }
        
        return models
    }
    func saveBodyDataToDataBase(dataArray:NSArray) {
        let serialQueue = DispatchQueue(label: "com.bodydata.save")
        
//        DispatchQueue.global(qos: .userInitiated).async { [self] in
            for i in 0..<dataArray.count{
                serialQueue.async {
                    let dict = dataArray[i]as? NSDictionary ?? [:]
//                    let imageString = dict.stringValueForKey(key: "images")
                    let imagesArray = dict["image"]as? NSArray ?? [[],[],[]]
                    self.updateData(cTime: dict["ctime"]as? String ?? "",
                               imgurl: dict["imgurl"]as? String ?? "",
                               hipsData: dict.stringValueForKey(key: "hips"),
                               weightData: dict.stringValueForKey(key: "weight"),
                               waistlineData: dict.stringValueForKey(key: "waistline"),
                               shoulderData: dict.stringValueForKey(key: "shoulder"),
                               bustData: dict.stringValueForKey(key: "bust"),
                               thighData: dict.stringValueForKey(key: "thigh"),
                                    calfData: dict.stringValueForKey(key: "calf"),
                                    bfpData: dict.stringValueForKey(key: "bfp"),
                                    images: WHUtils.getJSONStringFromArray(array: imagesArray),
                               armcircumferenceData: dict.stringValueForKey(key: "armcircumference"))
                    DLLog(message: "从后台获取的数据，更新到本地 \(dict)")
                    self.updateUploadStatus(cTime: dict["ctime"]as? String ?? "", uploadStatus: true)
                }
            }
//        }
    }
    
    /// 导出所有体重数据到 CSV 文件，返回文件路径
    func exportWeightDataCSV() -> URL? {
        let array = queryTableAll()
        var csv = "日期,体重(\(UserInfoModel.shared.weightUnitName))\n"
        for case let dict as NSDictionary in array {
            let date = dict.stringValueForKey(key: "ctime")
            let weight = dict.stringValueForKey(key: "weight")
            csv.append("\(date),\(weight)\n")
        }

        let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = docUrl.appendingPathComponent("weight_data.csv")
        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            DLLog(message: "导出体重CSV失败 \(error)")
            return nil
        }
    }
    func deleteTableData(cTime:String) {
        if queryTable(sDate: cTime){
            let del = table.filter(ctime == cTime).filter(uid == UserInfoModel.shared.uId)
            try! db?.run(del.delete())
            try! db?.execute("DELETE FROM bodydata WHERE ((uid == '\(UserInfoModel.shared.uId)') AND (ctime == '\(cTime)'))")
        }
    }
    func deleteAllData(){
        do {
            try db?.run(table.delete())
            try db?.execute("DELETE FROM bodydata WHERE uid == '\(UserInfoModel.shared.uId)'")
        }catch{
            
        }
        
    }
}
