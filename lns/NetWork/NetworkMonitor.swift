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
    }

    private var pendingRequests: [PendingRequest] = []

    private let maxRetryCount = 3
    private let baseDelay: TimeInterval = 1.0 // 初始延迟1秒
    private let maxPendingTime: TimeInterval = 30.0 // 最多挂起30秒

    // 不允许自动重试的接口关键词
    private let nonRetryRequestKeywords = ["支付"]//["login", "pay", "支付", "登录"]

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

    func addRequest(_ request: @escaping () -> Void, allowRetry: Bool = true) {
        if isConnected || !allowRetry {
            request()
        } else {
            print("[NetworkMonitor] 无网络，挂起请求")
            let pending = PendingRequest(retryCount: 0, request: request, allowRetry: allowRetry, timestamp: Date())
            pendingRequests.append(pending)
        }
    }

    func retryLater(_ request: @escaping () -> Void, retryCount: Int) {
        if retryCount < maxRetryCount {
            let delay = baseDelay * pow(2.0, Double(retryCount))
            print("[NetworkMonitor] 延迟 \(delay)s 后重试，第 \(retryCount + 1) 次")

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                if self?.isConnected == true {
                    request()
                } else {
                    self?.retryLater(request, retryCount: retryCount + 1)
                }
            }
        } else {
            print("[NetworkMonitor] 超过最大重试次数，丢弃请求")
        }
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
            }
        }
        
        pendingRequests = [] // 清空

        for item in validRequests {
            if item.allowRetry {
                retryLater(item.request, retryCount: item.retryCount)
            }
        }
    }

    func shouldAllowRetry(for urlString: String) -> Bool {
        for keyword in nonRetryRequestKeywords {
            if urlString.contains(keyword) {
                return false
            }
        }
        return true
    }
}
