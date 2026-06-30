//
//  NetworkMonitor.swift
//  lns
//
//  Created by Elavatine on 2025/4/29.
//
import Foundation
import Alamofire

class NetworkMonitor {
    static let shared = NetworkMonitor()

    private var reachabilityManager: NetworkReachabilityManager?
    private(set) var isConnected: Bool = true

    private struct PendingRequest {
        var retryCount: Int
        var request: () -> Void
        var allowRetry: Bool
        var timestamp: Date
        var msgDict: [String: Any]
        var ownerUid: String?
    }

    private var pendingRequests: [PendingRequest] = []
    private var retryGenerationByOwnerUid: [String: Int] = [:]
    private var retryGenerationForAll = 0

    private let maxRetryCount = 3
    private let baseDelay: TimeInterval = 1.0 // 初始延迟1秒
    private let maxPendingTime: TimeInterval = 30.0 // 最多挂起30秒

    // 不允许自动重试的接口关键词
    private let nonRetryRequestKeywords = ["pay","ai_identify_image"]//["login", "pay", "支付", "登录"]

    private init() {
        reachabilityManager = NetworkReachabilityManager()
        startMonitoring()
    }

    private func startMonitoring() {
        guard let reachabilityManager = reachabilityManager else { return }

        reachabilityManager.listener = { [weak self] status in
            self?.handleNetworkChange(status: status)
        }
        reachabilityManager.startListening()
    }

    private func handleNetworkChange(status: NetworkReachabilityManager.NetworkReachabilityStatus) {
        switch status {
        case .reachable(_):
            print("[NetworkMonitor] 网络可用")
            if !isConnected {
                isConnected = true
                retryPendingRequests()
            }
        case .notReachable, .unknown:
            print("[NetworkMonitor] 网络不可用")
            isConnected = false
        }
    }

    func addRequest(_ request: @escaping () -> Void, allowRetry: Bool = true, msgDict: [String: Any] = [:], ownerUid: String? = nil) {
        if isConnected || !allowRetry {
            request()
        } else {
            print("[NetworkMonitor] 无网络，挂起请求")
            let pending = PendingRequest(retryCount: 0, request: request, allowRetry: allowRetry, timestamp: Date(), msgDict: msgDict, ownerUid: normalizedOwnerUid(ownerUid))
            pendingRequests.append(pending)
        }
    }

    func retryLater(_ request: @escaping () -> Void, retryCount: Int, msgDict: [String: Any] = [:], ownerUid: String? = nil) {
        if retryCount < maxRetryCount {
            let delay = baseDelay * pow(2.0, Double(retryCount))
            print("[NetworkMonitor] 延迟 \(delay)s 后重试，第 \(retryCount + 1) 次")
            let requestOwnerUid = normalizedOwnerUid(ownerUid)
            let globalGeneration = retryGenerationForAll
            let ownerGeneration = retryGeneration(ownerUid: requestOwnerUid)

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self else { return }
                if self.retryGenerationForAll != globalGeneration || self.retryGeneration(ownerUid: requestOwnerUid) != ownerGeneration {
                    print("[NetworkMonitor] 账号已切换，丢弃旧账号重试请求")
                    return
                }
                if self.isConnected == true {
                    request()
                } else {
                    self.retryLater(request, retryCount: retryCount + 1,msgDict:msgDict, ownerUid: requestOwnerUid)
                }
            }
        } else {
            print("[NetworkMonitor] 超过最大重试次数，丢弃请求")
            reportRequestEvent(reason: "max_retry_exceeded", info: msgDict, retryCount: retryCount)
        }
    }

    func clearPendingRequests(ownerUid: String? = nil) {
        guard let ownerUid = normalizedOwnerUid(ownerUid) else {
            pendingRequests.removeAll()
            retryGenerationForAll += 1
            retryGenerationByOwnerUid.removeAll()
            return
        }

        pendingRequests.removeAll { pending in
            pending.ownerUid == ownerUid
        }
        retryGenerationByOwnerUid[ownerUid] = retryGeneration(ownerUid: ownerUid) + 1
    }

    private func retryPendingRequests() {
        guard !pendingRequests.isEmpty else { return }

        print("[NetworkMonitor] 网络恢复，准备重试 \(pendingRequests.count) 个挂起请求")

        let now = Date()
        var validRequests: [PendingRequest] = []
        
        for pending in pendingRequests {
            let elapsed = now.timeIntervalSince(pending.timestamp)
            if elapsed <= maxPendingTime {
                validRequests.append(pending)
            } else {
                print("[NetworkMonitor] 请求挂起超过\(maxPendingTime)秒，丢弃！")
                reportRequestEvent(reason: "pending_timeout  \(maxPendingTime)秒", info: pending.msgDict)
            }
        }
        
        pendingRequests = [] // 清空

        for item in validRequests {
            if item.allowRetry {
                retryLater(item.request, retryCount: item.retryCount,msgDict: item.msgDict, ownerUid: item.ownerUid)
            }
        }
    }

    private func normalizedOwnerUid(_ ownerUid: String?) -> String? {
        let uid = ownerUid?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return uid.isEmpty ? nil : uid
    }

    private func retryGeneration(ownerUid: String?) -> Int {
        guard let ownerUid = ownerUid else { return 0 }
        return retryGenerationByOwnerUid[ownerUid] ?? 0
    }

    func shouldAllowRetry(for urlString: String) -> Bool {
        for keyword in nonRetryRequestKeywords {
            if urlString.contains(keyword) {
                return false
            }
        }
        return true
    }
    private func reportRequestEvent(reason: String, info: [String: Any], retryCount: Int? = nil) {
        if info["url"]as? String ?? "" == URL_error_msg{
            return
        }
        var msg = info
        msg["reason"] = reason
        if let retryCount = retryCount {
            msg["retryCount"] = retryCount
        }
//        let param = ["message":"\(WHUtils.getJSONStringFromDictionary(dictionary: msg as NSDictionary))"]
//        WHNetworkUtil.shareManager().POST(urlString: URL_error_msg, parameters: param as [String : AnyObject]) { responseObject in
//            
//        }
//        
        if let utilsClass = NSClassFromString("WHUtils") as? NSObject.Type {
            let utils = utilsClass.init()
            let selector = NSSelectorFromString("sendErrorMsgRequestWithMsgDict:")
            if utils.responds(to: selector) {
                _ = utils.perform(selector, with: msg as NSDictionary)
            }
        }
//        WHUtils().sendErrorMsgRequest(msgDict: msg as NSDictionary)
    }
}
