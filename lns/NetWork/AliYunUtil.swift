//
//  AliYunUtil.swift
//  lns
//
//  Created by LNS2 on 2024/4/19.
//

import Foundation
import AliyunOSSiOS
import MCToast

enum IMAGE_TYPE {
    case bodyData
    case avatar
    case meals
    case common
    case forum_post
    case ai_photo
    case after_sale
    case suggestion
    case other
}
enum AliYunDownloadError: LocalizedError {
    case invalidURL
    case unsupportedURL
    case missingBucketOrObject

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的下载链接"
        case .unsupportedURL:
            return "暂不支持的下载地址"
        case .missingBucketOrObject:
            return "缺少下载文件信息"
        }
    }
}
typealias StringBoolCallback = (_ text:String, _ value:Bool) -> Void

typealias UploadCallback = (_ percen:String) -> Void


class DSImageUploader {
    
}

extension DSImageUploader {
    func sendOssStsRequest(completion: @escaping (Bool) -> Void) {
        WHNetworkUtil.shareManager().GET(urlString: URL_OSS_sts) { responseObject in
            DLLog(message: "\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            UserInfoModel.shared.updateOssParams(dict: WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? ""))
            completion(true)
        }
    }
    
    func uploadImage(imageData:Data,imgType:IMAGE_TYPE,imgSuffix:String?="png",completion:@escaping StringBoolCallback) {
        if !UserInfoModel.shared.ossParamIsValid(){
            DLLog(message: "oss参数校验无效  ---  重新请求OSS参数")
            sendOssStsRequest { t in
                DLLog(message: "oss参数校验无效  ---  重新请求OSS参数成功后，重新上传图片")
                self.uploadImage(imageData: imageData, imgType: imgType, imgSuffix: imgSuffix, completion: completion)
            }
            return
        }
        // 后台队列，避免阻塞主线程
        DispatchQueue.global(qos: .userInitiated).async {
            let day = Date().currentDay
            let arcNum = Int.random(in: 1000...9999)
            
            let config = OSSClientConfiguration()
            config.maxRetryCount = 2
            config.timeoutIntervalForRequest = 10
            config.timeoutIntervalForResource = 120
            
            let ossProvider = OSSStsTokenCredentialProvider.init(accessKeyId: UserInfoModel.shared.ossAccessKeyId,
                                                                 secretKeyId: UserInfoModel.shared.ossAccessKeySecret,
                                                                 securityToken: UserInfoModel.shared.ossSecurityToken)
            let ossClient = OSSClient.init(endpoint: UserInfoModel.shared.ossEndpoint,
                                           credentialProvider: ossProvider,
                                           clientConfiguration: config)
            
            let put = OSSPutObjectRequest()
            
            let URL_Type       = WHGetInterface_javaWithType()
            
            if URL_Type == "https://api.leungnutritionsciences.cn:8443/"{
                put.bucketName = "lnsapp-static-o"//生产环境
            }else{
                put.bucketName = "ela-test"//测试环境
            }
//            put.bucketName = UserInfoModel.shared.ossBucketName
            switch imgType {
                case .bodyData:
                put.objectKey="bodydata/body_data_\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
                case .avatar:
                    put.objectKey="avatar/user_avatar_\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
                case .meals:
                    put.objectKey="meals/meals_\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
                case .ai_photo:
                    put.objectKey="ai_identify_img_temp/ai__\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
                case .common:
                    put.objectKey = "avatar/user_avatar_\(arcNum).\(imgSuffix ?? "png")"
                case .forum_post:
                    put.objectKey = "forum/post/material/forum_\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
                case .after_sale:
                    put.objectKey = "after_sale/after_sale_\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
                case .suggestion:
                    put.objectKey = "suggestion/suggestion_\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
                case .other:
                    put.objectKey = "images/image_\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
            }
            put.uploadingData = imageData
            put.uploadProgress = { bytesSent, totalByteSent, totalByteExpectedToSend in
               print(bytesSent, totalByteSent, totalByteExpectedToSend)
    //            MCToast.mc_success("\(bytesSent/totalByteSent)%")
            }
            
            let putTask = ossClient.putObject(put)

            putTask.continue({ (task:OSSTask) ->Any?in
                if task.error == nil{
                    print("upload object success!")
                    let str = UserInfoModel.shared.ossEndpoint.components(separatedBy:CharacterSet.init(charactersIn:"//")).last
                    let url = String(format:"https://%@.%@/%@", put.bucketName, str!, put.objectKey)
                    print("上传图片成功：", url)
                    DispatchQueue.main.async{
                       completion(url, true)
                    }
                }else{
                    let error:NSError = (task.error)! as NSError
                    print("图片上传错误：",error.description)
                    DispatchQueue.main.async{
                        completion("", false)
                    }
                }
                return nil
                }).waitUntilFinished()
        }
    }
    
    func uploadMovie(fileUrl:URL,targetPath:String="forum/post/material",uploadProgress: @escaping (Float) -> Void,completion:@escaping StringBoolCallback) {
        if !UserInfoModel.shared.ossParamIsValid(){
            DLLog(message: "oss参数校验无效  ---  重新请求OSS参数")
            sendOssStsRequest { t in
                DLLog(message: "oss参数校验无效  ---  重新请求OSS参数成功后，重新上传视频")
                self.uploadMovie(fileUrl: fileUrl, uploadProgress: uploadProgress, completion: completion)
            }
            return
        }
        
        
        // 后台队列，避免阻塞主线程
        DispatchQueue.global(qos: .userInitiated).async {
            let ossProvider = OSSStsTokenCredentialProvider.init(accessKeyId: UserInfoModel.shared.ossAccessKeyId,
                                                                 secretKeyId: UserInfoModel.shared.ossAccessKeySecret,
                                                                 securityToken: UserInfoModel.shared.ossSecurityToken)
            
            // 初始化OSS客户端
            let ossClient = OSSClient(endpoint: UserInfoModel.shared.ossEndpoint,
                                      credentialProvider: ossProvider)
            
            let URL_Type       = WHGetInterface_javaWithType()
            var bucketName = "ela-test"
            if URL_Type == "https://api.leungnutritionsciences.cn:8443/"{
                bucketName = "lnsapp-static-o"//生产环境
            }
//            bucketName = "ela-test-private"
            let day = Date().currentDay
            let arcNum = Int.random(in: 1000...9999)
            let objectKey = "\(targetPath)/video_\(UserInfoModel.shared.uId)\(day)\(arcNum).mp4"
            
            let put = OSSPutObjectRequest()
            put.bucketName = bucketName//UserInfoModel.shared.ossBucketName
            put.uploadingFileURL = fileUrl
            put.objectKey = objectKey
            put.uploadProgress = { bytesSent, totalByteSent, totalByteExpectedToSend in
               print(bytesSent, totalByteSent, totalByteExpectedToSend)
                DLLog(message: "\(totalByteExpectedToSend) / \(totalByteSent)      \(bytesSent)")
    //            MCToast.mc_success("\(bytesSent/totalByteSent)%")
                DispatchQueue.main.async {
                    uploadProgress(Float(totalByteSent)/Float(totalByteExpectedToSend))
                }
            }
            
            let putTask = ossClient.putObject(put)
            putTask.continue({ (task:OSSTask) ->Any?in
                if task.error == nil{
                    print("upload object success!   \(task.result)")
                    let str = UserInfoModel.shared.ossEndpoint.components(separatedBy:CharacterSet.init(charactersIn:"//")).last
                    let url = String(format:"http://%@.%@/%@", put.bucketName, str!, put.objectKey)
                    print("上传视频成功：", url)
                    DispatchQueue.main.async{
                       completion(url, true)
                    }
                }else{
                    let error:NSError = (task.error)! as NSError
                    print("视频上传错误：",error.description)
                    DispatchQueue.main.async{
                        completion("", false)
                    }
                }
                return nil
                }).waitUntilFinished()
        }
    }
    func uploadMovie(fileData:Data,uploadProgress: @escaping (Float) -> Void,completion:@escaping StringBoolCallback) {
        if !UserInfoModel.shared.ossParamIsValid(){
            DLLog(message: "oss参数校验无效  ---  重新请求OSS参数")
            sendOssStsRequest { t in
                DLLog(message: "oss参数校验无效  ---  重新请求OSS参数成功后，重新上传视频")
                self.uploadMovie(fileData: fileData, uploadProgress: uploadProgress, completion: completion)
            }
            return
        }
        
        
        // 后台队列，避免阻塞主线程
        DispatchQueue.global(qos: .userInitiated).async {
            let ossProvider = OSSStsTokenCredentialProvider.init(accessKeyId: UserInfoModel.shared.ossAccessKeyId,
                                                                 secretKeyId: UserInfoModel.shared.ossAccessKeySecret,
                                                                 securityToken: UserInfoModel.shared.ossSecurityToken)
            
            // 初始化OSS客户端
            let ossClient = OSSClient(endpoint: UserInfoModel.shared.ossEndpoint,
                                      credentialProvider: ossProvider)
            
            let URL_Type       = WHGetInterface_javaWithType()
            var bucketName = "ela-test"
            if URL_Type == "https://api.leungnutritionsciences.cn:8443/"{
                bucketName = "lnsapp-static-o"//生产环境
            }
            
            let day = Date().currentDay
            let arcNum = Int.random(in: 1000...9999)
            let objectKey = "forum/post/material/video_\(UserInfoModel.shared.uId)\(day)\(arcNum).mp4"
            
            let put = OSSPutObjectRequest()
            put.bucketName = bucketName//UserInfoModel.shared.ossBucketName
            put.uploadingData = fileData
            put.objectKey = objectKey
            put.uploadProgress = { bytesSent, totalByteSent, totalByteExpectedToSend in
               print(bytesSent, totalByteSent, totalByteExpectedToSend)
                DLLog(message: "\(totalByteExpectedToSend) / \(totalByteSent)      \(bytesSent)")
    //            MCToast.mc_success("\(bytesSent/totalByteSent)%")
                DispatchQueue.main.async {
                    uploadProgress(Float(totalByteSent/totalByteExpectedToSend))
                }
            }
            
            let putTask = ossClient.putObject(put)
            putTask.continue({ (task:OSSTask) ->Any?in
                if task.error == nil{
                    print("upload object success!   \(task.result)")
                    let str = UserInfoModel.shared.ossEndpoint.components(separatedBy:CharacterSet.init(charactersIn:"//")).last
                    let url = String(format:"https://%@.%@/%@", put.bucketName, str!, put.objectKey)
                    print("上传视频成功：", url)
                    DispatchQueue.main.async{
                       completion(url, true)
                    }
                }else{
                    let error:NSError = (task.error)! as NSError
                    print("视频上传错误：",error.description)
                    DispatchQueue.main.async{
                        completion("", false)
                    }
                }
                return nil
                }).waitUntilFinished()
        }
    }
    func uploadImage(imageData:Data,imgType:IMAGE_TYPE,timeoutIntervalForRequest:Int?=30,imgSuffix:String?="png",put:OSSPutObjectRequest=OSSPutObjectRequest(),upload:@escaping OSSNetworkingUploadProgressBlock,completion:@escaping StringBoolCallback) {
        if !UserInfoModel.shared.ossParamIsValid(){
            DLLog(message: "oss参数校验无效  ---  重新请求OSS参数")
            sendOssStsRequest { t in
                DLLog(message: "oss参数校验无效  ---  重新请求OSS参数成功后，重新上传图片--发帖")
                self.uploadImage(imageData: imageData, imgType: imgType, imgSuffix: imgSuffix,put: put, upload: upload, completion: completion)
            }
            return
        }
        
        // 后台队列，避免阻塞主线程
        DispatchQueue.global(qos: .userInitiated).async {
            let day = Date().currentDay
            let arcNum = Int.random(in: 1000...9999)
            
            let config = OSSClientConfiguration()
            config.maxRetryCount = 2
            config.timeoutIntervalForRequest = TimeInterval(timeoutIntervalForRequest ?? 15)
            config.timeoutIntervalForResource = 120
            
            let ossProvider = OSSStsTokenCredentialProvider.init(accessKeyId: UserInfoModel.shared.ossAccessKeyId,
                                                                 secretKeyId: UserInfoModel.shared.ossAccessKeySecret,
                                                                 securityToken: UserInfoModel.shared.ossSecurityToken)
            let ossClient = OSSClient.init(endpoint: UserInfoModel.shared.ossEndpoint,
                                           credentialProvider: ossProvider,
                                           clientConfiguration: config)
            
            let put = OSSPutObjectRequest()
            
            let URL_Type       = WHGetInterface_javaWithType()
            
            if URL_Type == "https://api.leungnutritionsciences.cn:8443/"{
                put.bucketName = "lnsapp-static-o"//生产环境
            }else{
                put.bucketName = "ela-test"//测试环境
            }
//            put.bucketName = bucketName//UserInfoModel.shared.ossBucketName
            switch imgType {
                case .bodyData:
                put.objectKey="bodydata/body_data_\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
                case .avatar:
                    put.objectKey="avatar/user_avatar_\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
                case .meals:
                    put.objectKey="meals/meals_\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
                case .ai_photo:
                    put.objectKey="ai_identify_img_temp/ai_\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
                case .common:
                    put.objectKey = "avatar/user_avatar_\(arcNum).\(imgSuffix ?? "png")"
                case .forum_post:
                    put.objectKey = "forum/post/material/forum_\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
                case .after_sale:
                    put.objectKey = "after_sale/after_sale_\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
                case .suggestion:
                    put.objectKey = "suggestion/suggestion_\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
                case .other:
                    put.objectKey = "images/image_\(UserInfoModel.shared.uId)\(day)\(arcNum).\(imgSuffix ?? "png")"
            }
            put.uploadingData = imageData
            put.uploadProgress = { bytesSent, totalByteSent, totalByteExpectedToSend in
               print(bytesSent, totalByteSent, totalByteExpectedToSend)
    //            MCToast.mc_success("\(bytesSent/totalByteSent)%")
                upload(bytesSent, totalByteSent, totalByteExpectedToSend)
            }
            
            let putTask = ossClient.putObject(put)
//            put.cancel()
            putTask.continue({ (task:OSSTask) ->Any?in
                if task.error == nil{
                    print("upload object success!")
                    let str = UserInfoModel.shared.ossEndpoint.components(separatedBy:CharacterSet.init(charactersIn:"//")).last
                    let url = String(format:"https://%@.%@/%@", put.bucketName, str!, put.objectKey)
                    print("上传图片成功：", url)
                    DispatchQueue.main.async{
                       completion(url, true)
                    }
                }else{
                    let error:NSError = (task.error)! as NSError
                    print("图片上传错误：",error.description)
                    if error.domain == OSSClientErrorDomain && error.code == OSSClientErrorCODE.codeTaskCancelled.rawValue{
                        DLLog(message: "取消图片上传")
                    }else{
                        DispatchQueue.main.async{
                            completion("", false)
                        }
                    }
                }
                return nil
                }).waitUntilFinished()
           
        }
    }
    
    func dealImgUrlSignForOss(urlStr:String,completion: @escaping (String) -> Void){
        let disGroup = DispatchGroup()
        
        if !UserInfoModel.shared.ossParamIsValid(){
            disGroup.enter()
            sendOssStsRequest { t in
                disGroup.leave()
            }
        }
        var bucketName = "ela-test"
        if !urlStr.contains("aliyuncs.com") || urlStr.judgeIncludeChineseWord(){
            completion(urlStr)
            return
        }
//        let endPoint = UserInfoModel.shared.ossEndpoint
        let urlArr = urlStr.components(separatedBy: ".oss-cn-shenzhen.aliyuncs.com")
        let bucketMsg = urlArr[0]
        let bucketArr = bucketMsg.components(separatedBy: "//")
        bucketName = bucketArr.last ?? "lnsapp-static-o"
        
        disGroup.notify(queue: .main) {
            let config = OSSClientConfiguration()
            config.maxRetryCount = 2
            config.timeoutIntervalForRequest = 10
            config.timeoutIntervalForResource = 120
            
            let ossProvider = OSSStsTokenCredentialProvider.init(accessKeyId: UserInfoModel.shared.ossAccessKeyId,
                                                                 secretKeyId: UserInfoModel.shared.ossAccessKeySecret,
                                                                 securityToken: UserInfoModel.shared.ossSecurityToken)
            let ossClient = OSSClient.init(endpoint: UserInfoModel.shared.ossEndpoint,
                                           credentialProvider: ossProvider,
                                           clientConfiguration: config)
            
            let urlParams = urlStr.components(separatedBy: "\(UserInfoModel.shared.ossEndpoint.components(separatedBy:CharacterSet.init(charactersIn:"//")).last ?? "")/")
            let objectKey = "\(urlParams.last ?? "")"
            let URL_Type       = WHGetInterface_javaWithType()
//            DLLog(message: "OSS预签名 bucketName ：\(bucketName)    objectKey:\(objectKey)")
            let task = ossClient.presignConstrainURL(withBucketName: bucketName, withObjectKey: objectKey, withExpirationInterval: 60*60)//30分钟
            DLLog(message: "OSS预签名： 前 \(urlStr)   -    后：\(task.result as? String ?? "签名失败")")
            completion(task.result as? String ?? urlStr)
        }
    }
    func downloadOSSFile(urlStr: String,
                         destinationURL: URL,
                         progress: ((Float) -> Void)? = nil,
                         completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = URL(string: urlStr) else {
            DispatchQueue.main.async {
                completion(.failure(AliYunDownloadError.invalidURL))
            }
            return
        }

        guard let host = url.host, host.contains(".oss-") else {
            DispatchQueue.main.async {
                completion(.failure(AliYunDownloadError.unsupportedURL))
            }
            return
        }

        let directoryURL = destinationURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        let bucketName = host.components(separatedBy: ".").first ?? ""
        var objectKey = url.path
        if objectKey.hasPrefix("/") {
            objectKey.removeFirst()
        }
        objectKey = objectKey.removingPercentEncoding ?? objectKey

        guard !bucketName.isEmpty, !objectKey.isEmpty else {
            DispatchQueue.main.async {
                completion(.failure(AliYunDownloadError.missingBucketOrObject))
            }
            return
        }

        let disGroup = DispatchGroup()
        if !UserInfoModel.shared.ossParamIsValid() {
            disGroup.enter()
            sendOssStsRequest { _ in
                disGroup.leave()
            }
        }

        disGroup.notify(queue: .global(qos: .userInitiated)) {
            let config = OSSClientConfiguration()
            config.maxRetryCount = 2
            config.timeoutIntervalForRequest = 15
            config.timeoutIntervalForResource = 300

            let credentialProvider = OSSStsTokenCredentialProvider(accessKeyId: UserInfoModel.shared.ossAccessKeyId,
                                                                   secretKeyId: UserInfoModel.shared.ossAccessKeySecret,
                                                                   securityToken: UserInfoModel.shared.ossSecurityToken)
            let client = OSSClient(endpoint: UserInfoModel.shared.ossEndpoint,
                                   credentialProvider: credentialProvider,
                                   clientConfiguration: config)

            let request = OSSGetObjectRequest()
            request.bucketName = bucketName
            request.objectKey = objectKey
            request.downloadToFileURL = destinationURL
            request.downloadProgress = { _, totalByteSent, totalByteExpectedToSend in
                guard totalByteExpectedToSend > 0 else { return }
                let progressValue = Float(totalByteSent) / Float(totalByteExpectedToSend)
                DispatchQueue.main.async {
                    progress?(progressValue)
                }
            }

            let task = client.getObject(request)
            task.continue({ task -> Any? in
                DispatchQueue.main.async {
                    if let error = task.error {
                        completion(.failure(error))
                    } else {
                        completion(.success(destinationURL))
                    }
                }
                return nil
            }).waitUntilFinished()
        }
    }
}
