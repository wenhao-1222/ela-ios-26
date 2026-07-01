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
            return storedStatus
        }
        set {
            storedStatus = newValue
        }
    }
    private(set) var isMembershipStatusConfirmed = false
    private var hasAnimatedJournalAICoachProBadge = false
    var isLifetime = false
    
    // 后台当前也会返回这两个时间，先一起保留，避免后续再补字段
    var ctime = ""
    var etime = ""
    
    var isAiCoachSurveyFinished = false
    var aiCoachProcessStatus = 0
    var mealPlanProcessStatus = -1
    var bizType = "3"
    
//    var isVip: Bool {
//        return self.vipType != .none
//    }
    
    var isValidVip: Bool {
        return status == .valid
//        return self.isVip && self.status == .valid
    }
    
    var isMembershipStatusValid: Bool {
        return storedStatus == .valid
    }

    func updateSubscriptionBizType(_ value: String) {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard ["1", "2", "3", "4"].contains(trimmedValue) else { return }
        bizType = trimmedValue
    }
    
    func reset() {
        uid = ""
        vipType = .none
        startTime = ""
        expireTime = ""
        expireTimeUtc = 0
        status = .invalid
        isMembershipStatusConfirmed = false
        hasAnimatedJournalAICoachProBadge = false
        isLifetime = false
        isAiCoachSurveyFinished = false
        aiCoachProcessStatus = 0
        mealPlanProcessStatus = -1
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
        aiCoachProcessStatus = VIPModel.parseIntValue(from: dict["aiCoachProcessStatus"])
        mealPlanProcessStatus = VIPModel.parseIntValue(from: dict["mealPlanProcessStatus"])
        
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

        isMembershipStatusConfirmed = true
        if status == .valid {
            hasAnimatedJournalAICoachProBadge = false
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

    private static func parseIntValue(from value: Any?) -> Int {
        if let number = value as? NSNumber {
            return number.intValue
        }
        if let string = value as? String {
            return Int(string) ?? 0
        }
        return 0
    }

    func consumeJournalAICoachProBadgeAnimationFlag() -> Bool {
        guard isMembershipStatusConfirmed, !isValidVip else {
            hasAnimatedJournalAICoachProBadge = false
            return false
        }

        if hasAnimatedJournalAICoachProBadge {
            return false
        }

        hasAnimatedJournalAICoachProBadge = true
        return true
    }
}
