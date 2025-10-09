//
//  BodyDataUploadManager.swift
//  lns
//
//  Created by LNS2 on 2024/5/23.
//

import Foundation

class BodyDataUploadManager {
    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func checkDayaUploadStatus() {
        let bodyDataArray = BodyDataSQLiteManager.getInstance().queryTableAll()
        
        for i in 0..<bodyDataArray.count{
            let dict = bodyDataArray[i]as? NSDictionary ?? [:]
            if dict["isUpload"]as? Bool ?? false != true{
                sendSaveDataRequest(dict: dict)
//                dealBodyLocalImages(dict: dict)
            }
        }
        
        if bodyDataArray.count == 0 {
            self.sendBodyAllStatRequest()
        }
    }
    func sendBodyData(sDate:String) {
        let bodyDict = BodyDataSQLiteManager.getInstance().queryBodyData(sDate: sDate)
        sendSaveDataRequest(dict: bodyDict)
//        dealBodyLocalImages(dict: bodyDict)
    }
    func dealBodyLocalImages(dict:NSDictionary) {
        var imgArray = NSMutableArray()
//        if dict.stringValueForKey(key: "images").count > 5{
//            let arr = WHUtils.getArrayFromJSONString(jsonString: dict.stringValueForKey(key: "images"))
//            imgArray = NSMutableArray(array: arr)
//            sendSaveDataRequest(dict: dict, imgArray: imgArray)
//        }else{
            let localImgs = WHUtils.getArrayFromJSONString(jsonString: dict.stringValueForKey(key: "localImages"))
            if localImgs.count > 0 {
                sendBodyImgRequest(localImgs: localImgs, index: 0, bodyDict: dict, imgArray: imgArray)
            }else{
                sendSaveDataRequest(dict: dict, imgArray: imgArray)
            }
//        }
    }
    func sendBodyImgRequest(localImgs:NSArray,index:Int,bodyDict:NSDictionary,imgArray:NSMutableArray) {
        let dict = NSMutableDictionary(dictionary: localImgs[index]as? NSDictionary ?? [:])
        //["sn":"\(self.imgTapIndex)","localUrl":fileName]
        let localUrl = dict.stringValueForKey(key: "localUrl")
        if localUrl.count > 0 {
            let img = self.loadImage(named: localUrl.replacingOccurrences(of: ".png", with: ""))
            let imageData = WH_DESUtils.compressImage(toData: img)
            DSImageUploader().uploadImage(imageData: imageData!, imgType: .bodyData) { text, value in
                if value == true{
//                    dict.setValue("\(text)", forKey: "ossUrl")
                    let ossDict = ["sn":dict.stringValueForKey(key: "sn"),
                                   "alias":"",
                                   "url":"\(text)"]
                    imgArray.add(ossDict)
                    let filePath = self.documentsUrl.appendingPathComponent(localUrl).path
                    self.removeFile(filePath: filePath) { t in
                        
                    }
                }
                if index < localImgs.count - 1{
                    self.sendBodyImgRequest(localImgs: localImgs, index: index+1, bodyDict: bodyDict, imgArray: imgArray)
                }else{
                    BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "images", data: WHUtils.getJSONStringFromArray(array: imgArray), cTime: dict.stringValueForKey(key: "ctime"))
                    BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "images_local_paths", data:"", cTime: dict.stringValueForKey(key: "ctime"))
                    self.sendSaveDataRequest(dict: bodyDict, imgArray: imgArray)
                }
            }
        }else{
            if index < localImgs.count - 1{
                let ossDict = ["sn":dict.stringValueForKey(key: "sn"),
                               "alias":"",
                               "url":""]
                imgArray.add(ossDict)
                self.sendBodyImgRequest(localImgs: localImgs, index: index+1, bodyDict: bodyDict, imgArray: imgArray)
            }else{
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "images", data: WHUtils.getJSONStringFromArray(array: imgArray), cTime: dict.stringValueForKey(key: "ctime"))
                self.sendSaveDataRequest(dict: bodyDict, imgArray: imgArray)
            }
        }
    }
    func sendSaveDataRequest(dict:NSDictionary,imgArray:NSArray? = []) {
        let imagesArray = WHUtils.getArrayFromJSONString(jsonString: "\(dict.stringValueForKey(key: "images"))")
        let param = ["uid":"\(dict["uid"]as? String ?? "")",
                     "weight":"\(dict.stringValueForKey(key: "weight").replacingOccurrences(of: ",", with: "."))",
                     "waistline":"\(dict.stringValueForKey(key: "waistline").replacingOccurrences(of: ",", with: "."))",
                     "hips":"\(dict.stringValueForKey(key: "hips").replacingOccurrences(of: ",", with: "."))",
                     "armcircumference":"\(dict.stringValueForKey(key: "armcircumference").replacingOccurrences(of: ",", with: "."))",
                     "shoulder":"\(dict.stringValueForKey(key: "shoulder").replacingOccurrences(of: ",", with: "."))",
                     "bust":"\(dict.stringValueForKey(key: "bust").replacingOccurrences(of: ",", with: "."))",
                     "thigh":"\(dict.stringValueForKey(key: "thigh").replacingOccurrences(of: ",", with: "."))",
                     "calf":"\(dict.stringValueForKey(key: "calf").replacingOccurrences(of: ",", with: "."))",
                     "bfp":"\(dict.stringValueForKey(key: "bfp").replacingOccurrences(of: ",", with: "."))",
                     "imgurl":"\(dict.stringValueForKey(key: "imgurl"))",
                     "image":imagesArray,
//                     "image":imgArray,
                     "ctime":"\(dict.stringValueForKey(key: "ctime"))"] as [String : Any]
        DLLog(message: "sendSaveDataRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_bodystat_save, parameters: param as [String:AnyObject]) { responseObject in
            BodyDataSQLiteManager.getInstance().updateUploadStatus(cTime: dict.stringValueForKey(key: "ctime"), uploadStatus: true)
        }
    }
    func sendWeightDataRequest(sDate:String,weightData:String) {
        if weightData.floatValue > 0 {
            
            if let info = BodyDataSQLiteManager.getInstance().queryWeightInfo(sDate: sDate), info.isUpload && info.weight == weightData {
                return
            }
            let param = ["uid":"\(UserInfoModel.shared.uId)",
                         "weight":"\(weightData.replacingOccurrences(of: ",", with: "."))",
                         "ctime":"\(sDate)"]
            DLLog(message: "sendSaveDataRequest:\(param)")
            
            DispatchQueue.main.async {
                WHNetworkUtil.shareManager().POST(urlString: URL_bodystat_save, parameters: param as [String:AnyObject]) { responseObject in
                    BodyDataSQLiteManager.getInstance().updateUploadStatus(cTime: sDate, uploadStatus: true)
                }
            }
        }
    }
    func sendBodyAllStatRequest(){
        //"qtype": "0"// 0-全部；1-一个星期内；2-一个月内；3-两个月内；4-三个月内；5-半年内；6-一年内
        let param = ["uid":"\(UserInfoModel.shared.uId)",
                     "qtype":"0"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_bodystat_query, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendBodyAllStatRequest:\(dataArr)")
//            let dataArr = responseObject["data"]as? NSArray ?? []
            BodyDataSQLiteManager.getInstance().saveBodyDataToDataBase(dataArray: dataArr)
        }
    }
}

extension BodyDataUploadManager{
    ///删除本地文件
    func removeFile(filePath:String,completion: @escaping (Bool?) -> Void) {
        if filePath.count < 3 || filePath == documentsUrl.path{
            completion(false)
            return
        }
        let fileRouteArray = filePath.components(separatedBy: "Documents/")
        if fileRouteArray.last == "" || fileRouteArray.count <= 1{
            completion(false)
            return
        }
        
        DLLog(message: "removeFile -- filePath:\(filePath)")
        if FileManager.default.fileExists(atPath: filePath){
            do{
                try FileManager.default.removeItem(atPath: filePath)
            }catch{
                DLLog(message: "MRVueUpdateLog: Remove [\(filePath)] fail:[\(error)]")
                completion(false)
                return
            }
            completion(true)
            return
        }else{
            completion(true)
        }
    }
    ///从本地读取图片
    func loadImage(named: String) -> UIImage? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsPath.appendingPathComponent("\(named).png")
        guard let data = try? Data(contentsOf: filePath) else { return nil }
        return UIImage(data: data)
    }
}
