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
    
    func initWithDict(dict:NSDictionary) -> VIPModel {
        let model = VIPModel()
        model.uid = dict.stringValueForKey(key: "uid")
        model.startTime = dict.stringValueForKey(key: "startTime")
        model.expireTime = dict.stringValueForKey(key: "expireTime")
        model.ctime = dict.stringValueForKey(key: "ctime")
        model.etime = dict.stringValueForKey(key: "etime")
        
//        let vipTypeValue = Int(dict.stringValueForKey(key: "vipType")) ?? 0
//        model.vipType = VIP_TYPE(rawValue: vipTypeValue) ?? .none
        
        let statusValue = Int(dict.stringValueForKey(key: "status")) ?? 0
        if statusValue > 0 {
            model.status = VIP_STATUS(rawValue: statusValue)
        }else{
            model.status = .invalid
        }
        
        let lifetimeValue = dict.stringValueForKey(key: "isLifetime")
//        model.isLifetime = lifetimeValue == "1" || model.vipType == .lifetime
        
        if model.isLifetime {
            model.expireTime = ""
        }
        
        return model
    }
}
