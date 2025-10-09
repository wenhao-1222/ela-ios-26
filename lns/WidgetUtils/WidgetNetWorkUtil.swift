//
//  WidgetNetWorkUtil.swift
//  lns
//
//  Created by LNS2 on 2024/8/21.
//

import Foundation
import CommonCrypto
import Alamofire

class WidgetNetWorkUtil: SessionManager {
    
    static var instance : WidgetNetWorkUtil? = nil
    
    class func shareManager() -> WidgetNetWorkUtil{
        
        var header : HTTPHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let configration = URLSessionConfiguration.default
        configration.httpAdditionalHeaders = header
        configration.timeoutIntervalForRequest = 10
        
        let manager = SessionManager.default
        manager.delegate.sessionDidReceiveChallenge = {
            session,challenge in
            return    (URLSession.AuthChallengeDisposition.useCredential,URLCredential(trust:challenge.protectionSpace.serverTrust!))
        }
        
        instance = WidgetNetWorkUtil(configuration: configration)
        
        return instance!
    }
    /**
     urlString   接口
     parameters   参数
     isNeedToast  是否需要弹框
     vc   视图控制器
     success  成功回调
     */
    func POST(urlString : String, parameters : [String : AnyObject]?,timeOut:TimeInterval? = 10.0,success : @escaping (_ responseObject : [String : AnyObject]) -> ()) -> () {
        
        var header : HTTPHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        let uId = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: WidgetUtils().getUserInfoUid())
        let uToken = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: WidgetUtils().getUserInfoUToken())
        header["uid"] = "\(uId ?? "")"
        header["token"] = "\(uToken ?? "")"
        
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let buildVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        
        var paraDict:Parameters = ["phonetype":"iOS",
                                   "phonemodel":"iphone Widget",
                                   "phoneos":"iphone Widget",
                                   "vercode":"\(buildVersion)",
                                   "vername":"\(currentVersion)",
                                   "phonetime":"\(Date().currentSeconds)"]
        for key in paraDict.keys{
            let value = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: paraDict[key] as! String)
            paraDict.updateValue(value ?? "", forKey: key)
        }
        
        if parameters != nil {
            for item in parameters!{
                if item.value.isKind(of: NSString.self){
                    let value = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: item.value as! String)
                    paraDict.updateValue(value ?? "", forKey: item.key)
                }else{
                    paraDict.updateValue(item.value, forKey: item.key)
                }
            }
        }
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = timeOut ?? 10.0
//        print("sendNaturalDataRequest paraDict:\(paraDict)")
        manager.request(urlString, method: .post, parameters: paraDict, encoding: JSONEncoding.default,headers: header).responseJSON { (response) in
//            print("\(response)")
            switch response.result{
            case .success:
                if let value = response.result.value as? [String : AnyObject]{
                    let code = value["code"]as? Int ?? -1
                    
                    if (code == 200) {
                        success(value)
                    }
                }
                break
            case .failure:
                break
            }
        }
    }
}
