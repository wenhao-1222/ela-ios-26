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
//    var vipType = VIP_TYPE.none
    var startTime = ""
    var expireTime = ""
    var status: VIP_STATUS?
    var isLifetime = false
    
    // 后台当前也会返回这两个时间，先一起保留，避免后续再补字段
    var ctime = ""
    var etime = ""
    
//    var isVip: Bool {
//        return self.vipType != .none
//    }
    
    var isValidVip: Bool {
        return self.status == .valid
//        return self.isVip && self.status == .valid
    }
    
    func reset() {
        uid = ""
        startTime = ""
        expireTime = ""
        status = .invalid
        isLifetime = false
        ctime = ""
        etime = ""
    }
    
    @discardableResult
    func update(with dict:NSDictionary) -> VIPModel {
        reset()
        
        uid = dict.stringValueForKey(key: "uid")
        startTime = dict.stringValueForKey(key: "startTime")
        expireTime = dict.stringValueForKey(key: "expireTime")
        ctime = dict.stringValueForKey(key: "ctime")
        etime = dict.stringValueForKey(key: "etime")
        
//        let vipTypeValue = Int(dict.stringValueForKey(key: "vipType")) ?? 0
//        vipType = VIP_TYPE(rawValue: vipTypeValue) ?? .none
        
        let statusValue = Int(dict.stringValueForKey(key: "status")) ?? 0
        if statusValue > 0 {
            status = VIP_STATUS(rawValue: statusValue)
        }else{
            status = .invalid
        }
        
        let lifetimeValue = dict.stringValueForKey(key: "isLifetime")
//        isLifetime = lifetimeValue == "1" || vipType == .lifetime
        _ = lifetimeValue
        
        if isLifetime {
            expireTime = ""
        }
        
        return self
    }
    
    func initWithDict(dict:NSDictionary) -> VIPModel {
        return update(with: dict)
    }
}
