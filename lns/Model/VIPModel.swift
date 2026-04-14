//
//  VIPModel.swift
//  lns
//
//  Created by Codex on 2026/3/24.
//

import Foundation

enum VIP_TYPE: Int {
    case none = 0
    case month = 1
    case year = 2
    case lifetime = 3
}

enum VIP_STATUS: Int {
    case invalid = 0  //从来没买过
    case valid = 1    //有效会员
    case expired = 2  //会员已过期
    case banned = 3   //会员权益已封禁
}

class VIPModel: NSObject {
    static let shared = VIPModel()
    
    private override init() {
        super.init()
        reset()
    }
    
    var uid = ""
    var vipType = VIP_TYPE.none
    var startTime = ""
    var expireTime = ""
    var expireTimeUtc: Int64 = 0
    private var storedStatus: VIP_STATUS?
    var status: VIP_STATUS? {
        get {
            // 订阅/续费成功后，先信任本地已解锁状态，避免服务端会员态未及时同步时拦住权益页。
            if storedStatus != .valid,
               storedStatus != .banned,
               ElaProIAPManager.shared.isLocalProUnlocked() {
                return .valid
            }
            return storedStatus
        }
        set {
            storedStatus = newValue
        }
    }
    var isLifetime = false
    
    // 后台当前也会返回这两个时间，先一起保留，避免后续再补字段
    var ctime = ""
    var etime = ""
    
    var isAiCoachSurveyFinished = false
    
//    var isVip: Bool {
//        return self.vipType != .none
//    }
    
    var isValidVip: Bool {
        return status == .valid
//        return self.isVip && self.status == .valid
    }
    
    func reset() {
        uid = ""
        vipType = .none
        startTime = ""
        expireTime = ""
        expireTimeUtc = 0
        status = .invalid
        isLifetime = false
        isAiCoachSurveyFinished = false
        ctime = ""
        etime = ""
    }
    
    @discardableResult
    func update(with dict:NSDictionary) -> VIPModel {
        reset()
        
        uid = dict.stringValueForKey(key: "uid")
        startTime = dict.stringValueForKey(key: "startTime")
        expireTime = dict.stringValueForKey(key: "expireTime")
        expireTimeUtc = VIPModel.parseInt64Value(from: dict["expireTimeUtc"])
        ctime = dict.stringValueForKey(key: "ctime")
        etime = dict.stringValueForKey(key: "etime")
        isAiCoachSurveyFinished = dict.stringValueForKey(key: "isAiCoachSurveyFinished") == "1"
        
        let vipTypeValue = Int(dict.stringValueForKey(key: "vipType")) ?? 0
        vipType = VIP_TYPE(rawValue: vipTypeValue) ?? .none
        
        let statusValue = Int(dict.stringValueForKey(key: "status")) ?? 0
        if statusValue > 0 {
            status = VIP_STATUS(rawValue: statusValue)
        }else{
            status = .invalid
        }
        
        let lifetimeValue = dict.stringValueForKey(key: "isLifetime")
        isLifetime = lifetimeValue == "1" || vipType == .lifetime
        
        if isLifetime {
            expireTime = ""
            expireTimeUtc = 0
        }
        
        return self
    }
    
    func initWithDict(dict:NSDictionary) -> VIPModel {
        return update(with: dict)
    }

    private static func parseInt64Value(from value: Any?) -> Int64 {
        if let number = value as? NSNumber {
            return number.int64Value
        }
        if let string = value as? String {
            return Int64(string) ?? 0
        }
        return 0
    }
}
