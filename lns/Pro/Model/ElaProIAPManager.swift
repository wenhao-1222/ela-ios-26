//
//  ElaProIAPManager.swift
//  lns
//
//  Created by LNS2 on 2026/3/3.
//

import Foundation
import Security
import StoreKit
import UIKit

enum ElaProIAPConfig {
    // App Store Connect: 订阅群组「Pro」，订阅群组 ID「21956560」
    static let subscriptionGroupName = "Pro"
    static let subscriptionGroupID = "21956560"
    static var monthProductID = ""
    static var annualProductID = "annual_yeal_new"
    static var lifetimeProductID = ""
}

enum ElaProIAPError: LocalizedError {
    case paymentsDisabled
    case productUnavailable
    case purchaseBusy
    case cancelled
    case pendingApproval
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .paymentsDisabled:
            return "当前设备不支持内购"
        case .productUnavailable:
            return "未获取到可购买商品"
        case .purchaseBusy:
            return "正在处理上一笔订单"
        case .cancelled:
            return "已取消购买"
        case .pendingApproval:
            return "订单待批准，请稍后"
        case .unknown(let message):
            return message
        }
    }
}

enum ElaProSubscriptionHistoryState {
    case subscribed
    case notSubscribed
    case unknown
}

final class ElaProIAPManager: NSObject {
    static let shared = ElaProIAPManager()
    static let localEntitlementUpdatedNotification = NSNotification.Name("ela_pro_local_entitlement_updated")
    static let refundDebugLogUpdatedNotification = NSNotification.Name("ela_pro_refund_debug_log_updated")

    private enum PurchaseQueryBizType: String {
        case pendingBind = "1"
        case aiGuidance = "2"
        case standard = "3"
    }
    
    private var productsRequest: SKProductsRequest?
    private var cachedProducts: [String: SKProduct] = [:]
    private var fetchCompletions: [(Result<[SKProduct], Error>) -> Void] = []
    
    private var purchaseCompletion: ((Result<SKPaymentTransaction, Error>) -> Void)?
    private var purchasingProductID: String?
    private var isObservingQueue = false
    private var refundDebugSession: RefundDebugSession?
    
    private enum LocalUnlockKeys {
        static let isUnlocked = "ela_pro_local_is_unlocked"
        static let uid = "ela_pro_local_uid"
        static let productID = "ela_pro_local_product_id"
        static let transactionID = "ela_pro_local_transaction_id"
        static let unlockAtMs = "ela_pro_local_unlock_at_ms"
        static let expireAtMs = "ela_pro_local_expire_at_ms"
        static let source = "ela_pro_local_source"
        static let pendingVerifyPayload = "ela_pro_pending_verify_payload"
        static let refundDebugLogs = "ela_pro_refund_debug_logs"
    }

    private enum KeychainKeys {
        static let pendingTransactionService = "com.elavatine.pro.iap"
        static let pendingTransactionAccount = "pending_transaction_id"
    }
    
    private override init() {
        super.init()
        startObservingQueue()
        startObservingRefundLifecycle()
    }
    
    deinit {
        stopObservingQueue()
    }
    
    func startObservingQueue() {
        guard !isObservingQueue else { return }
        SKPaymentQueue.default().add(self)
        isObservingQueue = true
    }
    
    func stopObservingQueue() {
        guard isObservingQueue else { return }
        SKPaymentQueue.default().remove(self)
        isObservingQueue = false
    }
    
    func fetchAnnualProduct(completion: @escaping (Result<SKProduct, Error>) -> Void) {
        let annualID = ElaProIAPConfig.annualProductID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !annualID.isEmpty else {
            completion(.failure(ElaProIAPError.productUnavailable))
            return
        }
        fetchProducts(ids: [annualID], forceRefresh: false) { result in
            switch result {
            case .success(let products):
                if let product = products.first(where: { $0.productIdentifier == annualID }) {
                    self.logProductInfo(product, source: "annualProductID")
                    completion(.success(product))
                } else {
                    completion(.failure(ElaProIAPError.productUnavailable))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchMonthProduct(completion: @escaping (Result<SKProduct, Error>) -> Void) {
        let monthID = ElaProIAPConfig.monthProductID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !monthID.isEmpty else {
            completion(.failure(ElaProIAPError.productUnavailable))
            return
        }
        fetchProducts(ids: [monthID], forceRefresh: false) { result in
            switch result {
            case .success(let products):
                if let product = products.first(where: { $0.productIdentifier == monthID }) {
                    self.logProductInfo(product, source: "monthProductID")
                    completion(.success(product))
                } else {
                    completion(.failure(ElaProIAPError.productUnavailable))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchProProducts(productIDs: [String]? = nil,
                          completion: @escaping (Result<[SKProduct], Error>) -> Void) {
        let requestedProductIDs = (productIDs?.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } ?? [
            ElaProIAPConfig.monthProductID,
            ElaProIAPConfig.annualProductID,
            ElaProIAPConfig.lifetimeProductID
        ]).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        guard !requestedProductIDs.isEmpty else {
            completion(.failure(ElaProIAPError.productUnavailable))
            return
        }
        
        fetchProducts(ids: requestedProductIDs,
                      forceRefresh: false) { result in
            if case .success(let products) = result {
                if requestedProductIDs.contains(ElaProIAPConfig.monthProductID),
                   let month = products.first(where: { $0.productIdentifier == ElaProIAPConfig.monthProductID }) {
                    self.logProductInfo(month, source: "monthProductID")
                }
                if requestedProductIDs.contains(ElaProIAPConfig.annualProductID),
                   let annual = products.first(where: { $0.productIdentifier == ElaProIAPConfig.annualProductID }) {
                    self.logProductInfo(annual, source: "annualProductID")
                }
                if requestedProductIDs.contains(ElaProIAPConfig.lifetimeProductID),
                   let lifetime = products.first(where: { $0.productIdentifier == ElaProIAPConfig.lifetimeProductID }) {
                    self.logProductInfo(lifetime, source: "lifetimeProductID")
                }
            }
            completion(result)
        }
    }

    func fetchLifetimeProduct(completion: @escaping (Result<SKProduct, Error>) -> Void) {
        let lifetimeID = ElaProIAPConfig.lifetimeProductID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !lifetimeID.isEmpty else {
            completion(.failure(ElaProIAPError.productUnavailable))
            return
        }
        fetchProducts(ids: [lifetimeID], forceRefresh: false) { result in
            switch result {
            case .success(let products):
                if let product = products.first(where: { $0.productIdentifier == lifetimeID }) {
                    self.logProductInfo(product, source: "lifetimeProductID")
                    completion(.success(product))
                } else {
                    completion(.failure(ElaProIAPError.productUnavailable))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func purchaseAnnual(completion: @escaping (Result<SKPaymentTransaction, Error>) -> Void) {
        purchase(productID: ElaProIAPConfig.annualProductID, completion: completion)
    }
    
    func purchaseMonth(completion: @escaping (Result<SKPaymentTransaction, Error>) -> Void) {
        purchase(productID: ElaProIAPConfig.monthProductID, completion: completion)
    }

    func purchaseLifetime(completion: @escaping (Result<SKPaymentTransaction, Error>) -> Void) {
        purchase(productID: ElaProIAPConfig.lifetimeProductID, completion: completion)
    }

    func refundDebugLogText() -> String {
        let logs = UserDefaults.standard.stringArray(forKey: LocalUnlockKeys.refundDebugLogs) ?? []
        if logs.isEmpty {
            return "暂无退款调试日志。\n\n建议顺序：\n1. 先完成一次 Sandbox/TestFlight 订阅购买。\n2. 在“管理订阅”页点“一键发起 Apple 退款申请”。\n3. 回到这里查看客户端日志。\n4. 在仓库根目录运行 iap-refund-simulator/ 里的本地回调脚本观察后台模拟回调。"
        }
        return logs.reversed().joined(separator: "\n\n")
    }

    func refundDebugDiagnosisText() -> String {
        guard let session = refundDebugSession else {
            return "诊断摘要\n- 还没有最近一次退款调试会话。\n- 先点“一键发起 Apple 退款申请”，再回到这里看判断结果。"
        }

        var lines: [String] = []
        lines.append("诊断摘要")
        lines.append("- 最近商品: \(session.productID)")
        lines.append("- 最近交易: \(session.transactionID)")

        switch session.outcome {
        case .submitted:
            lines.append("- 结果判断: Apple 已接受退款请求提交，后续看 Apple 审核和服务端回调。")
        case .userCancelled:
            if session.sawBackgroundRoundtrip {
                lines.append("- 结果判断: 更像 Apple 退款页加载失败或中途被系统打断，不像单纯没命中交易。")
                lines.append("- 依据: 发起退款后 App 发生了后台/前台切换，StoreKit 最终只回了“用户取消”。")
            } else {
                lines.append("- 结果判断: 更像你在 Apple 退款页主动点了取消。")
            }
        case .failed(let message):
            lines.append("- 结果判断: 退款流程启动失败。")
            lines.append("- 错误: \(message)")
        case .inProgress:
            lines.append("- 结果判断: 退款流程刚开始，等待 Apple 返回。")
        }

        if let backgroundAt = session.lastDidEnterBackgroundAt {
            lines.append("- 最近切后台: \(session.format(backgroundAt))")
        }
        if let activeAt = session.lastDidBecomeActiveAt {
            lines.append("- 最近回前台: \(session.format(activeAt))")
        }

        lines.append("- 建议动作: 如果持续白屏，请直接点“打开 Apple 网页退款”，确认同一 Apple 账号在 Safari 能否访问 reportaproblem.apple.com。")
        return lines.joined(separator: "\n")
    }

    func clearRefundDebugLogs() {
        UserDefaults.standard.removeObject(forKey: LocalUnlockKeys.refundDebugLogs)
        NotificationCenter.default.post(name: Self.refundDebugLogUpdatedNotification, object: nil)
    }

    func beginRefundDebugFlow(in scene: UIWindowScene,
                              completion: @escaping (Result<String, Error>) -> Void) {
        guard #available(iOS 15.0, *) else {
            completion(.failure(ElaProRefundDebugError.storeKit2Unavailable))
            return
        }

        let productIDs = configuredRefundProductIDs()
        refundDebugSession = RefundDebugSession(productID: productIDs.first ?? "<unknown>",
                                               transactionID: "<pending>")
        appendRefundDebugLog("准备发起 Apple 退款申请", payload: [
            "productIDs": productIDs,
            "subscriptionGroupID": ElaProIAPConfig.subscriptionGroupID
        ])

        Task { @MainActor in
            do {
                let transaction = try await latestRefundableTransaction(productIDs: productIDs)
                self.refundDebugSession?.productID = transaction.productID
                self.refundDebugSession?.transactionID = String(transaction.id)
                self.refundDebugSession?.outcome = .inProgress
                appendRefundDebugLog("命中可退款交易", payload: refundTransactionPayload(transaction))

                let status = try await transaction.beginRefundRequest(in: scene)
                switch status {
                case .success:
                    self.refundDebugSession?.outcome = .submitted
                    appendRefundDebugLog("Apple 退款申请已提交", payload: refundTransactionPayload(transaction))
                    completion(.success("Apple 退款申请已提交，请在 Apple 弹窗里完成后续操作"))
                case .userCancelled:
                    self.refundDebugSession?.outcome = .userCancelled
                    appendRefundDebugLog("Apple 退款申请被用户取消", payload: refundTransactionPayload(transaction))
                    if self.refundDebugSession?.sawBackgroundRoundtrip == true {
                        self.appendRefundDebugLog("诊断判断：更像 Apple 退款页加载失败或外部页面被中断", payload: [
                            "transactionID": String(transaction.id),
                            "productID": transaction.productID
                        ])
                    }
                    completion(.failure(ElaProRefundDebugError.userCancelled))
                @unknown default:
                    self.refundDebugSession?.outcome = .failed("退款请求返回未知状态")
                    appendRefundDebugLog("Apple 退款申请返回未知状态", payload: refundTransactionPayload(transaction))
                    completion(.failure(ElaProRefundDebugError.unknown("退款请求返回未知状态")))
                }
            } catch {
                self.refundDebugSession?.outcome = .failed(error.localizedDescription)
                self.appendRefundDebugLog("Apple 退款申请失败", payload: [
                    "error": error.localizedDescription,
                    "productIDs": productIDs
                ])
                completion(.failure(error))
            }
        }
    }

    func checkSubscriptionHistoryState(productID: String,
                                       completion: @escaping (ElaProSubscriptionHistoryState) -> Void) {
        let trimmedProductID = productID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedProductID.isEmpty else {
            DLLog(message: "[ElaProIAP][HISTORY] skip check: empty productID")
            completion(.unknown)
            return
        }

        guard #available(iOS 15.0, *) else {
            DLLog(message: "[ElaProIAP][HISTORY] skip check: StoreKit2 unavailable, productID=\(trimmedProductID)")
            completion(.unknown)
            return
        }

        DLLog(message: "[ElaProIAP][HISTORY] start check, productID=\(trimmedProductID)")
        Task {
            let state = await self.subscriptionHistoryStateStoreKit2(productID: trimmedProductID)
            DispatchQueue.main.async {
                DLLog(message: "[ElaProIAP][HISTORY] finish check, productID=\(trimmedProductID), state=\(self.debugDescription(for: state))")
                completion(state)
            }
        }
    }
    
    func localizedPriceString(for product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = max(2, formatter.maximumFractionDigits)
        return formatter.string(from: product.price) ?? "\(product.price)"
    }
    
    func updateProductIDs(month: String, annual: String, lifetime: String) {
        let monthID = month.trimmingCharacters(in: .whitespacesAndNewlines)
        let annualID = annual.trimmingCharacters(in: .whitespacesAndNewlines)
        let lifetimeID = lifetime.trimmingCharacters(in: .whitespacesAndNewlines)
        
        ElaProIAPConfig.monthProductID = monthID
        ElaProIAPConfig.annualProductID = annualID
        ElaProIAPConfig.lifetimeProductID = lifetimeID
        cachedProducts.removeAll()
    }
    
    func handlePurchaseSuccessPostAction(transaction: SKPaymentTransaction,
                                         queryBizType: String = PurchaseQueryBizType.standard.rawValue) {
        let expireAt = applyLocalTemporaryUnlock(transaction: transaction)
        let payload = makePurchaseVerifyPayload(transaction: transaction, localUnlockExpireAt: expireAt)
        appendRefundDebugLog("购买成功，已生成验单载荷", payload: payload)
        cachePendingVerifyPayload(payload: payload)
        storePendingTransactionID(transaction.transactionIdentifier)
        if canBindPurchaseToCurrentUser() {
            let resolvedQueryBizType = resolveQueryBizType(queryBizType, defaultType: .standard)
            bindPendingPurchaseIfNeeded(queryBizType: resolvedQueryBizType)
        } else {
            DLLog(message: "[ElaProIAP][QUERY] deferred until login: user not ready")
        }
        uploadPurchaseVerifyPayloadTODO(payload: payload)
    }

    func isLocalProUnlocked() -> Bool {
        clearExpiredLocalUnlockIfNeeded()
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: LocalUnlockKeys.isUnlocked) else {
            return false
        }
        return isLocalUnlockBoundToCurrentUser(defaults: defaults)
    }

    func clearLocalEntitlementCache() {
        let defaults = UserDefaults.standard
        let shouldNotify = defaults.bool(forKey: LocalUnlockKeys.isUnlocked)
        clearLocalUnlock(defaults: defaults, shouldNotify: shouldNotify)
        defaults.removeObject(forKey: LocalUnlockKeys.pendingVerifyPayload)
        clearPendingTransactionIDCache(defaults: defaults)
    }

    func bindPendingPurchaseIfNeeded(queryBizType: String = PurchaseQueryBizType.pendingBind.rawValue,
                                     completion: ((Bool) -> Void)? = nil) {
        guard canBindPurchaseToCurrentUser() else {
            completion?(false)
            return
        }

        guard let transactionID = readPendingTransactionID(),
              !transactionID.isEmpty else {
            completion?(true)
            return
        }

        let resolvedQueryBizType = resolveQueryBizType(queryBizType, defaultType: .pendingBind)
        queryPurchaseOrder(transactionID: transactionID, bizType: resolvedQueryBizType) { success in
            completion?(success)
        }
    }
    
    private func fetchProducts(ids: [String],
                               forceRefresh: Bool,
                               completion: @escaping (Result<[SKProduct], Error>) -> Void) {
        let idSet = Set(ids.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty })
        guard !idSet.isEmpty else {
            completion(.failure(ElaProIAPError.productUnavailable))
            return
        }
        if !forceRefresh, idSet.allSatisfy({ cachedProducts[$0] != nil }) {
            completion(.success(idSet.compactMap { cachedProducts[$0] }))
            return
        }
        
        fetchCompletions.append(completion)
        if productsRequest != nil { return }
        
        let request = SKProductsRequest(productIdentifiers: idSet)
        productsRequest = request
        request.delegate = self
        request.start()
    }
    
    private func purchase(productID: String,
                          completion: @escaping (Result<SKPaymentTransaction, Error>) -> Void) {
        let trimmedProductID = productID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedProductID.isEmpty else {
            completion(.failure(ElaProIAPError.productUnavailable))
            return
        }
        
        guard SKPaymentQueue.canMakePayments() else {
            completion(.failure(ElaProIAPError.paymentsDisabled))
            return
        }
        
        guard purchaseCompletion == nil else {
            completion(.failure(ElaProIAPError.purchaseBusy))
            return
        }
        
        fetchProducts(ids: [trimmedProductID], forceRefresh: false) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let products):
                guard let product = products.first(where: { $0.productIdentifier == trimmedProductID }) else {
                    completion(.failure(ElaProIAPError.productUnavailable))
                    return
                }
                self.purchaseCompletion = completion
                self.purchasingProductID = trimmedProductID
                
                let payment = SKMutablePayment(product: product)
                SKPaymentQueue.default().add(payment)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func resolveFetch(result: Result<[SKProduct], Error>) {
        let callbacks = fetchCompletions
        fetchCompletions.removeAll()
        callbacks.forEach { $0(result) }
    }
    
    private func resolvePurchase(result: Result<SKPaymentTransaction, Error>) {
        let completion = purchaseCompletion
        purchaseCompletion = nil
        purchasingProductID = nil
        completion?(result)
    }

    @available(iOS 15.0, *)
    private func subscriptionHistoryStateStoreKit2(productID: String) async -> ElaProSubscriptionHistoryState {
        do {
            DLLog(message: "[ElaProIAP][HISTORY] load products from StoreKit2, productID=\(productID)")
            let products = try await Product.products(for: [productID])
            guard let product = products.first(where: { $0.id == productID }) else {
                DLLog(message: "[ElaProIAP][HISTORY] product not found, productID=\(productID)")
                return .unknown
            }

            if let subscription = product.subscription,
               await subscription.isEligibleForIntroOffer {
                DLLog(message: "[ElaProIAP][HISTORY] intro offer eligible, productID=\(productID), state=notSubscribed")
                return .notSubscribed
            }

            if let latestResult = await Transaction.latest(for: productID) {
                switch latestResult {
                case .verified(let transaction):
                    let state: ElaProSubscriptionHistoryState = transaction.productID == productID ? .subscribed : .unknown
                    DLLog(message: "[ElaProIAP][HISTORY] latest verified transaction, queryProductID=\(productID), transactionProductID=\(transaction.productID), transactionID=\(transaction.id), state=\(debugDescription(for: state))")
                    return state
                case .unverified:
                    DLLog(message: "[ElaProIAP][HISTORY] latest transaction unverified, productID=\(productID)")
                    return .unknown
                }
            }

            DLLog(message: "[ElaProIAP][HISTORY] no intro eligibility and no latest transaction, productID=\(productID), state=unknown")
            return .unknown
        } catch {
            DLLog(message: "[ElaProIAP][HISTORY] check failed: \(error.localizedDescription)")
            return .unknown
        }
    }

    private func debugDescription(for state: ElaProSubscriptionHistoryState) -> String {
        switch state {
        case .subscribed:
            return "subscribed"
        case .notSubscribed:
            return "notSubscribed"
        case .unknown:
            return "unknown"
        }
    }
    
    private func applyLocalTemporaryUnlock(transaction: SKPaymentTransaction) -> Date {
        let now = Date()
        let productID = transaction.payment.productIdentifier
        let expireAt = now.addingTimeInterval(localUnlockDuration(productID: productID))
        let defaults = UserDefaults.standard
        
        defaults.set(true, forKey: LocalUnlockKeys.isUnlocked)
        defaults.set(currentUserID(), forKey: LocalUnlockKeys.uid)
        defaults.set(productID, forKey: LocalUnlockKeys.productID)
        defaults.set(transaction.transactionIdentifier ?? "", forKey: LocalUnlockKeys.transactionID)
        defaults.set(Int64(now.timeIntervalSince1970 * 1000), forKey: LocalUnlockKeys.unlockAtMs)
        defaults.set(Int64(expireAt.timeIntervalSince1970 * 1000), forKey: LocalUnlockKeys.expireAtMs)
        defaults.set("iap_purchase_success", forKey: LocalUnlockKeys.source)
        
        NotificationCenter.default.post(name: Self.localEntitlementUpdatedNotification, object: nil)
        return expireAt
    }
    
    private func clearExpiredLocalUnlockIfNeeded() {
        let defaults = UserDefaults.standard
        let expireAtMs = Int64(defaults.double(forKey: LocalUnlockKeys.expireAtMs))
        if expireAtMs <= 0 { return }
        
        let nowMs = Int64(Date().timeIntervalSince1970 * 1000)
        guard nowMs >= expireAtMs else { return }
        
        clearLocalUnlock(defaults: defaults, shouldNotify: true)
    }
    
    private func localUnlockDuration(productID: String) -> TimeInterval {
        // 本地先做临时放行，最终以后台验单结果为准
        if productID == ElaProIAPConfig.monthProductID ||
            productID == ElaProIAPConfig.annualProductID ||
            productID == ElaProIAPConfig.lifetimeProductID {
            return 7 * 24 * 60 * 60
        }
        return 3 * 24 * 60 * 60
    }
    
    private func makePurchaseVerifyPayload(transaction: SKPaymentTransaction,
                                           localUnlockExpireAt: Date) -> [String: Any] {
        let txDate = transaction.transactionDate ?? Date()
        let oriTx = transaction.original ?? transaction
        let oriTxDate = oriTx.transactionDate ?? txDate
        let now = Date()
        
        return [
            "userId": UserInfoModel.shared.uId,
            "productId": transaction.payment.productIdentifier,
            "transactionId": transaction.transactionIdentifier ?? "",
            "originalTransactionId": oriTx.transactionIdentifier ?? "",
            "transactionDateMs": Int64(txDate.timeIntervalSince1970 * 1000),
            "originalTransactionDateMs": Int64(oriTxDate.timeIntervalSince1970 * 1000),
            "subscriptionGroupName": ElaProIAPConfig.subscriptionGroupName,
            "subscriptionGroupId": ElaProIAPConfig.subscriptionGroupID,
            "receiptBase64": loadReceiptBase64(),
            "receiptEnvironmentHint": receiptEnvironmentHint(),
            "appBundleId": Bundle.main.bundleIdentifier ?? "",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            "appBuild": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
            "clientTimestampMs": Int64(now.timeIntervalSince1970 * 1000),
            "localUnlockExpireAtMs": Int64(localUnlockExpireAt.timeIntervalSince1970 * 1000)
        ]
    }
    
    private func cachePendingVerifyPayload(payload: [String: Any]) {
        let json = WHUtils.getJSONStringFromDictionary(dictionary: payload as NSDictionary)
        UserDefaults.standard.set(json, forKey: LocalUnlockKeys.pendingVerifyPayload)
    }
    
    private func queryPurchaseOrder(transactionID: String,
                                    bizType: String,
                                    completion: ((Bool) -> Void)? = nil) {
        let params: [String: AnyObject] = [
            "transactionId": transactionID as AnyObject,
            "bizType": bizType as AnyObject
        ]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_pro_iap_query,
                                          parameters: params,
                                          success: { responseObject in
            let code = responseObject["code"] as? Int ?? -1
            DLLog(message: "[ElaProIAP][QUERY] success: \(responseObject), transactionId=\(transactionID), bizType=\(bizType)")
            self.appendRefundDebugLog("后台订单查询返回", payload: [
                "transactionId": transactionID,
                "bizType": bizType,
                "code": code,
                "response": responseObject
            ])
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "[ElaProIAP][QUERY] success:\(dataDict)")
            if code == 200 {
                self.clearPendingTransactionAfterBindSuccess(transactionID: transactionID)
                completion?(true)
            } else {
                completion?(false)
            }
        }, failure: { failed in
            DLLog(message: "[ElaProIAP][QUERY] failure: \(failed), tractionId=\(transactionID), bizType=\(bizType)")
            self.appendRefundDebugLog("后台订单查询失败", payload: [
                "transactionId": transactionID,
                "bizType": bizType,
                "failed": failed
            ])
            completion?(false)
        })
    }

    private func resolveQueryBizType(_ queryBizType: String,
                                     defaultType: PurchaseQueryBizType) -> String {
        let trimmedBizType = queryBizType.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let type = PurchaseQueryBizType(rawValue: trimmedBizType) else {
            return defaultType.rawValue
        }
        return type.rawValue
    }

    private func canBindPurchaseToCurrentUser() -> Bool {
        let uId = UserInfoModel.shared.uId.trimmingCharacters(in: .whitespacesAndNewlines)
        let token = UserInfoModel.shared.token.trimmingCharacters(in: .whitespacesAndNewlines)
        return !uId.isEmpty && !token.isEmpty
    }

    private func storePendingTransactionID(_ transactionID: String?) {
        guard let transactionID = transactionID?.trimmingCharacters(in: .whitespacesAndNewlines),
              !transactionID.isEmpty,
              let data = transactionID.data(using: .utf8) else {
            return
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainKeys.pendingTransactionService,
            kSecAttrAccount as String: KeychainKeys.pendingTransactionAccount,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            DLLog(message: "[ElaProIAP][KEYCHAIN] save failed: \(status)")
        }
    }

    private func readPendingTransactionID() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainKeys.pendingTransactionService,
            kSecAttrAccount as String: KeychainKeys.pendingTransactionAccount,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let transactionID = String(data: data, encoding: .utf8),
              !transactionID.isEmpty else {
            return nil
        }
        return transactionID
    }

    private func clearPendingTransactionAfterBindSuccess(transactionID _: String) {
        let defaults = UserDefaults.standard
        clearPendingTransactionIDCache(defaults: defaults)
        defaults.removeObject(forKey: LocalUnlockKeys.pendingVerifyPayload)
    }

    private func currentUserID() -> String {
        return UserInfoModel.shared.uId.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func isLocalUnlockBoundToCurrentUser(defaults: UserDefaults) -> Bool {
        let currentUID = currentUserID()
        guard !currentUID.isEmpty else {
            return false
        }
        let storedUID = defaults.string(forKey: LocalUnlockKeys.uid)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !storedUID.isEmpty else {
            return false
        }
        return storedUID == currentUID
    }

    private func clearLocalUnlock(defaults: UserDefaults, shouldNotify: Bool) {
        defaults.set(false, forKey: LocalUnlockKeys.isUnlocked)
        defaults.removeObject(forKey: LocalUnlockKeys.uid)
        defaults.removeObject(forKey: LocalUnlockKeys.productID)
        defaults.removeObject(forKey: LocalUnlockKeys.transactionID)
        defaults.removeObject(forKey: LocalUnlockKeys.unlockAtMs)
        defaults.removeObject(forKey: LocalUnlockKeys.expireAtMs)
        defaults.removeObject(forKey: LocalUnlockKeys.source)
        appendRefundDebugLog("本地临时会员权益已清空", payload: [
            "shouldNotify": shouldNotify
        ])
        if shouldNotify {
            NotificationCenter.default.post(name: Self.localEntitlementUpdatedNotification, object: nil)
        }
    }

    private func clearPendingTransactionIDCache(defaults: UserDefaults) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainKeys.pendingTransactionService,
            kSecAttrAccount as String: KeychainKeys.pendingTransactionAccount
        ]
        SecItemDelete(query as CFDictionary)
        defaults.removeObject(forKey: LocalUnlockKeys.transactionID)
    }
    
    private func uploadPurchaseVerifyPayloadTODO(payload: [String: Any]) {
        // TODO(iap-backend): 对接苹果内购凭证确认接口，接口名先占位为 `URL_pro_iap_purchase_confirm`
        // TODO(iap-backend): 请求体建议至少包含 userId/productId/transactionId/originalTransactionId/receiptBase64
        // TODO(iap-backend): 后台返回最终会员状态后，需覆盖本地临时解锁状态
        DLLog(message: "[ElaProIAP][TODO_UPLOAD] payload=\(payload)")
        appendRefundDebugLog("客户端验单上传占位日志", payload: payload)

        // 预留调用形式（后台接口就绪后放开）：
        // WHNetworkUtil.shareManager().POST(urlString: URL_pro_iap_purchase_confirm,
        //                                  parameters: payload as [String : AnyObject]) { _ in }
    }

    private func configuredRefundProductIDs() -> [String] {
        return [
            ElaProIAPConfig.monthProductID,
            ElaProIAPConfig.annualProductID,
            ElaProIAPConfig.lifetimeProductID
        ].map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    @available(iOS 15.0, *)
    private func latestRefundableTransaction(productIDs: [String]) async throws -> Transaction {
        guard !productIDs.isEmpty else {
            throw ElaProRefundDebugError.noConfiguredProductID
        }

        var latestTransaction: Transaction?
        for productID in productIDs {
            guard let result = await Transaction.latest(for: productID) else {
                appendRefundDebugLog("未找到最近交易", payload: ["productID": productID])
                continue
            }

            switch result {
            case .verified(let transaction):
                guard transaction.revocationDate == nil else {
                    appendRefundDebugLog("交易已撤销，跳过退款申请", payload: refundTransactionPayload(transaction))
                    continue
                }
                if let current = latestTransaction {
                    if transaction.purchaseDate > current.purchaseDate {
                        latestTransaction = transaction
                    }
                } else {
                    latestTransaction = transaction
                }
            case .unverified(_, let error):
                appendRefundDebugLog("交易校验失败，跳过退款申请", payload: [
                    "productID": productID,
                    "error": error.localizedDescription
                ])
            }
        }

        guard let latestTransaction else {
            throw ElaProRefundDebugError.noRefundableTransaction(productIDs)
        }
        return latestTransaction
    }

    private func appendRefundDebugLog(_ title: String, payload: [String: Any]? = nil) {
        let defaults = UserDefaults.standard
        var logs = defaults.stringArray(forKey: LocalUnlockKeys.refundDebugLogs) ?? []
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var segments = ["[\(formatter.string(from: Date()))] \(title)"]
        if let payload,
           JSONSerialization.isValidJSONObject(payload),
           let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]),
           let json = String(data: data, encoding: .utf8) {
            segments.append(json)
        }

        logs.append(segments.joined(separator: "\n"))
        if logs.count > 120 {
            logs = Array(logs.suffix(120))
        }
        defaults.set(logs, forKey: LocalUnlockKeys.refundDebugLogs)
        NotificationCenter.default.post(name: Self.refundDebugLogUpdatedNotification, object: nil)
    }

    private func startObservingRefundLifecycle() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRefundAppDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRefundAppDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    @objc private func handleRefundAppDidEnterBackground() {
        guard refundDebugSession != nil else { return }
        refundDebugSession?.lastDidEnterBackgroundAt = Date()
        appendRefundDebugLog("退款调试期间 App 进入后台")
    }

    @objc private func handleRefundAppDidBecomeActive() {
        guard refundDebugSession != nil else { return }
        refundDebugSession?.lastDidBecomeActiveAt = Date()
        appendRefundDebugLog("退款调试期间 App 回到前台")
    }

    @available(iOS 15.0, *)
    private func refundTransactionPayload(_ transaction: Transaction) -> [String: Any] {
        var payload: [String: Any] = [
            "productID": transaction.productID,
            "transactionID": String(transaction.id),
            "originalTransactionID": String(transaction.originalID),
            "purchaseDate": transaction.purchaseDate.timeIntervalSince1970,
            "revocationDate": transaction.revocationDate?.timeIntervalSince1970 as Any,
            "isUpgraded": transaction.isUpgraded
        ]
        if let expirationDate = transaction.expirationDate {
            payload["expirationDate"] = expirationDate.timeIntervalSince1970
        }
        return payload
    }
    
    private func loadReceiptBase64() -> String {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else {
            return ""
        }
        return receiptData.base64EncodedString()
    }
    
    private func receiptEnvironmentHint() -> String {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else { return "unknown" }
        return receiptURL.lastPathComponent.lowercased().contains("sandbox") ? "sandbox" : "production"
    }
    
    private func logProductInfo(_ product: SKProduct, source: String) {
        var lines: [String] = []
        lines.append("[ElaProIAP][\(source)] 拉取成功")
        lines.append("productId=\(product.productIdentifier)")
        lines.append("price=\(localizedPriceString(for: product))")
        lines.append("subscriptionPeriod=\(periodDebugText(product.subscriptionPeriod))")
        
        if let intro = product.introductoryPrice {
            let introPrice = localizedPriceString(decimal: intro.price, locale: intro.priceLocale)
            lines.append("introPrice=\(introPrice)")
            lines.append("introPeriod=\(periodDebugText(intro.subscriptionPeriod))")
            lines.append("introType=\(intro.paymentMode.rawValue)")
            lines.append("introCycles=\(intro.numberOfPeriods)")
        } else {
            lines.append("introPrice=<none>")
        }
        
        DLLog(message: lines.joined(separator: " | "))
    }
    
    private func localizedPriceString(decimal: NSDecimalNumber, locale: Locale) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = max(2, formatter.maximumFractionDigits)
        return formatter.string(from: decimal) ?? "\(decimal)"
    }
    
    private func periodDebugText(_ period: SKProductSubscriptionPeriod?) -> String {
        guard let period = period else { return "<none>" }
        
        let unitText: String
        switch period.unit {
        case .day:
            unitText = "day"
        case .week:
            unitText = "week"
        case .month:
            unitText = "month"
        case .year:
            unitText = "year"
        @unknown default:
            unitText = "unknown"
        }
        
        return "\(period.numberOfUnits) \(unitText)"
    }
}

private struct RefundDebugSession {
    enum Outcome {
        case inProgress
        case submitted
        case userCancelled
        case failed(String)
    }

    var startedAt = Date()
    var productID: String
    var transactionID: String
    var lastDidEnterBackgroundAt: Date?
    var lastDidBecomeActiveAt: Date?
    var outcome: Outcome = .inProgress

    var sawBackgroundRoundtrip: Bool {
        guard let backgroundAt = lastDidEnterBackgroundAt,
              let activeAt = lastDidBecomeActiveAt else {
            return false
        }
        return backgroundAt >= startedAt && activeAt >= backgroundAt
    }

    func format(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}

extension ElaProIAPManager: SKProductsRequestDelegate, SKRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.products.forEach { cachedProducts[$0.productIdentifier] = $0 }
        productsRequest = nil
        
        if response.products.isEmpty {
            resolveFetch(result: .failure(ElaProIAPError.productUnavailable))
        } else {
            resolveFetch(result: .success(response.products))
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request === productsRequest {
            productsRequest = nil
            resolveFetch(result: .failure(error))
        }
    }
}

extension ElaProIAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                appendRefundDebugLog("StoreKit1 交易完成", payload: [
                    "state": "purchased",
                    "productID": transaction.payment.productIdentifier,
                    "transactionID": transaction.transactionIdentifier ?? ""
                ])
                SKPaymentQueue.default().finishTransaction(transaction)
                if transaction.payment.productIdentifier == purchasingProductID {
                    resolvePurchase(result: .success(transaction))
                }
            case .failed:
                appendRefundDebugLog("StoreKit1 交易失败", payload: [
                    "state": "failed",
                    "productID": transaction.payment.productIdentifier,
                    "transactionID": transaction.transactionIdentifier ?? "",
                    "error": transaction.error?.localizedDescription ?? ""
                ])
                SKPaymentQueue.default().finishTransaction(transaction)
                guard transaction.payment.productIdentifier == purchasingProductID else { continue }
                let skError = transaction.error as? SKError
                if skError?.code == .paymentCancelled {
                    resolvePurchase(result: .failure(ElaProIAPError.cancelled))
                } else {
                    resolvePurchase(result: .failure(transaction.error ?? ElaProIAPError.unknown("购买失败")))
                }
            case .restored:
                appendRefundDebugLog("StoreKit1 交易恢复", payload: [
                    "state": "restored",
                    "productID": transaction.payment.productIdentifier,
                    "transactionID": transaction.transactionIdentifier ?? ""
                ])
                SKPaymentQueue.default().finishTransaction(transaction)
                if transaction.payment.productIdentifier == purchasingProductID {
                    resolvePurchase(result: .success(transaction))
                }
            case .deferred:
                appendRefundDebugLog("StoreKit1 交易待批准", payload: [
                    "state": "deferred",
                    "productID": transaction.payment.productIdentifier
                ])
                if transaction.payment.productIdentifier == purchasingProductID {
                    resolvePurchase(result: .failure(ElaProIAPError.pendingApproval))
                }
            case .purchasing:
                break
            @unknown default:
                appendRefundDebugLog("StoreKit1 交易状态未知", payload: [
                    "state": "unknown",
                    "productID": transaction.payment.productIdentifier
                ])
                SKPaymentQueue.default().finishTransaction(transaction)
                if transaction.payment.productIdentifier == purchasingProductID {
                    resolvePurchase(result: .failure(ElaProIAPError.unknown("交易状态异常")))
                }
            }
        }
    }
}

enum ElaProRefundDebugError: LocalizedError {
    case storeKit2Unavailable
    case noConfiguredProductID
    case noRefundableTransaction([String])
    case userCancelled
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .storeKit2Unavailable:
            return "当前系统版本不支持退款调试，请使用 iOS 15 及以上系统"
        case .noConfiguredProductID:
            return "未配置可退款的订阅商品 ID"
        case .noRefundableTransaction(let productIDs):
            return "未找到可退款交易，请先用 Sandbox/TestFlight 购买这些商品之一：\(productIDs.joined(separator: ", "))"
        case .userCancelled:
            return "你已取消本次退款申请"
        case .unknown(let message):
            return message
        }
    }
}
