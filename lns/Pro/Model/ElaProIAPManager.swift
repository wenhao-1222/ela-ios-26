//
//  ElaProIAPManager.swift
//  lns
//
//  Created by LNS2 on 2026/3/3.
//

import Foundation
import Security
import StoreKit

enum ElaProIAPConfig {
    // App Store Connect: 订阅群组「Pro」，订阅群组 ID「21956560」
    static let subscriptionGroupName = "Pro"
    static let subscriptionGroupID = "21956560"
    static var monthProductID = "month_continue"
    static var annualProductID = "annual"
    static var lifetimeProductID = "LifetimePro"
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

final class ElaProIAPManager: NSObject {
    static let shared = ElaProIAPManager()
    static let localEntitlementUpdatedNotification = NSNotification.Name("ela_pro_local_entitlement_updated")
    
    private var productsRequest: SKProductsRequest?
    private var cachedProducts: [String: SKProduct] = [:]
    private var fetchCompletions: [(Result<[SKProduct], Error>) -> Void] = []
    
    private var purchaseCompletion: ((Result<SKPaymentTransaction, Error>) -> Void)?
    private var purchasingProductID: String?
    private var isObservingQueue = false
    
    private enum LocalUnlockKeys {
        static let isUnlocked = "ela_pro_local_is_unlocked"
        static let productID = "ela_pro_local_product_id"
        static let transactionID = "ela_pro_local_transaction_id"
        static let unlockAtMs = "ela_pro_local_unlock_at_ms"
        static let expireAtMs = "ela_pro_local_expire_at_ms"
        static let source = "ela_pro_local_source"
        static let pendingVerifyPayload = "ela_pro_pending_verify_payload"
    }

    private enum KeychainKeys {
        static let pendingTransactionService = "com.elavatine.pro.iap"
        static let pendingTransactionAccount = "pending_transaction_id"
    }
    
    private override init() {
        super.init()
        startObservingQueue()
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
        fetchProducts(ids: [ElaProIAPConfig.annualProductID], forceRefresh: false) { result in
            switch result {
            case .success(let products):
                if let product = products.first(where: { $0.productIdentifier == ElaProIAPConfig.annualProductID }) {
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
        fetchProducts(ids: [ElaProIAPConfig.monthProductID], forceRefresh: false) { result in
            switch result {
            case .success(let products):
                if let product = products.first(where: { $0.productIdentifier == ElaProIAPConfig.monthProductID }) {
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
    
    func fetchProProducts(completion: @escaping (Result<[SKProduct], Error>) -> Void) {
        fetchProducts(ids: [ElaProIAPConfig.monthProductID,
                            ElaProIAPConfig.annualProductID,
                            ElaProIAPConfig.lifetimeProductID],
                      forceRefresh: false) { result in
            if case .success(let products) = result {
                if let month = products.first(where: { $0.productIdentifier == ElaProIAPConfig.monthProductID }) {
                    self.logProductInfo(month, source: "monthProductID")
                }
                if let annual = products.first(where: { $0.productIdentifier == ElaProIAPConfig.annualProductID }) {
                    self.logProductInfo(annual, source: "annualProductID")
                }
                if let lifetime = products.first(where: { $0.productIdentifier == ElaProIAPConfig.lifetimeProductID }) {
                    self.logProductInfo(lifetime, source: "lifetimeProductID")
                }
            }
            completion(result)
        }
    }

    func fetchLifetimeProduct(completion: @escaping (Result<SKProduct, Error>) -> Void) {
        fetchProducts(ids: [ElaProIAPConfig.lifetimeProductID], forceRefresh: false) { result in
            switch result {
            case .success(let products):
                if let product = products.first(where: { $0.productIdentifier == ElaProIAPConfig.lifetimeProductID }) {
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
        guard !monthID.isEmpty, !annualID.isEmpty, !lifetimeID.isEmpty else { return }
        
        ElaProIAPConfig.monthProductID = monthID
        ElaProIAPConfig.annualProductID = annualID
        ElaProIAPConfig.lifetimeProductID = lifetimeID
        cachedProducts.removeAll()
    }
    
    func handlePurchaseSuccessPostAction(transaction: SKPaymentTransaction) {
        let expireAt = applyLocalTemporaryUnlock(transaction: transaction)
        let payload = makePurchaseVerifyPayload(transaction: transaction, localUnlockExpireAt: expireAt)
        cachePendingVerifyPayload(payload: payload)
        storePendingTransactionID(transaction.transactionIdentifier)
        if canBindPurchaseToCurrentUser() {
            bindPendingPurchaseIfNeeded()
        } else {
            DLLog(message: "[ElaProIAP][QUERY] deferred until login: user not ready")
        }
        uploadPurchaseVerifyPayloadTODO(payload: payload)
    }

    func isLocalProUnlocked() -> Bool {
        clearExpiredLocalUnlockIfNeeded()
        return UserDefaults.standard.bool(forKey: LocalUnlockKeys.isUnlocked)
    }

    func bindPendingPurchaseIfNeeded(completion: ((Bool) -> Void)? = nil) {
        guard canBindPurchaseToCurrentUser() else {
            completion?(false)
            return
        }

        guard let transactionID = readPendingTransactionID(),
              !transactionID.isEmpty else {
            completion?(true)
            return
        }

        queryPurchaseOrder(transactionID: transactionID) { success in
            completion?(success)
        }
    }
    
    private func fetchProducts(ids: [String],
                               forceRefresh: Bool,
                               completion: @escaping (Result<[SKProduct], Error>) -> Void) {
        let idSet = Set(ids)
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
        guard SKPaymentQueue.canMakePayments() else {
            completion(.failure(ElaProIAPError.paymentsDisabled))
            return
        }
        
        guard purchaseCompletion == nil else {
            completion(.failure(ElaProIAPError.purchaseBusy))
            return
        }
        
        fetchProducts(ids: [productID], forceRefresh: false) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let products):
                guard let product = products.first(where: { $0.productIdentifier == productID }) else {
                    completion(.failure(ElaProIAPError.productUnavailable))
                    return
                }
                self.purchaseCompletion = completion
                self.purchasingProductID = productID
                
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
    
    private func applyLocalTemporaryUnlock(transaction: SKPaymentTransaction) -> Date {
        let now = Date()
        let productID = transaction.payment.productIdentifier
        let expireAt = now.addingTimeInterval(localUnlockDuration(productID: productID))
        let defaults = UserDefaults.standard
        
        defaults.set(true, forKey: LocalUnlockKeys.isUnlocked)
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
        
        defaults.set(false, forKey: LocalUnlockKeys.isUnlocked)
        defaults.removeObject(forKey: LocalUnlockKeys.productID)
        defaults.removeObject(forKey: LocalUnlockKeys.transactionID)
        defaults.removeObject(forKey: LocalUnlockKeys.unlockAtMs)
        defaults.removeObject(forKey: LocalUnlockKeys.expireAtMs)
        defaults.removeObject(forKey: LocalUnlockKeys.source)
        NotificationCenter.default.post(name: Self.localEntitlementUpdatedNotification, object: nil)
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
    
    private func queryPurchaseOrder(transactionID: String, completion: ((Bool) -> Void)? = nil) {
        let params: [String: AnyObject] = [
            "transactionId": transactionID as AnyObject
        ]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_pro_ipa_query,
                                          parameters: params,
                                          success: { responseObject in
            let code = responseObject["code"] as? Int ?? -1
            DLLog(message: "[ElaProIAP][QUERY] success: \(responseObject)")
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
            DLLog(message: "[ElaProIAP][QUERY] failure: \(failed), tractionId=\(transactionID)")
            completion?(false)
        })
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

    private func clearPendingTransactionAfterBindSuccess(transactionID: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainKeys.pendingTransactionService,
            kSecAttrAccount as String: KeychainKeys.pendingTransactionAccount
        ]
        SecItemDelete(query as CFDictionary)

        let defaults = UserDefaults.standard
        if defaults.string(forKey: LocalUnlockKeys.transactionID) == transactionID {
            defaults.removeObject(forKey: LocalUnlockKeys.transactionID)
        }
        defaults.removeObject(forKey: LocalUnlockKeys.pendingVerifyPayload)
    }
    
    private func uploadPurchaseVerifyPayloadTODO(payload: [String: Any]) {
        // TODO(iap-backend): 对接苹果内购凭证确认接口，接口名先占位为 `URL_pro_iap_purchase_confirm`
        // TODO(iap-backend): 请求体建议至少包含 userId/productId/transactionId/originalTransactionId/receiptBase64
        // TODO(iap-backend): 后台返回最终会员状态后，需覆盖本地临时解锁状态
        DLLog(message: "[ElaProIAP][TODO_UPLOAD] payload=\(payload)")
        
        // 预留调用形式（后台接口就绪后放开）：
        // WHNetworkUtil.shareManager().POST(urlString: URL_pro_iap_purchase_confirm,
        //                                  parameters: payload as [String : AnyObject]) { _ in }
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
                SKPaymentQueue.default().finishTransaction(transaction)
                if transaction.payment.productIdentifier == purchasingProductID {
                    resolvePurchase(result: .success(transaction))
                }
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                guard transaction.payment.productIdentifier == purchasingProductID else { continue }
                let skError = transaction.error as? SKError
                if skError?.code == .paymentCancelled {
                    resolvePurchase(result: .failure(ElaProIAPError.cancelled))
                } else {
                    resolvePurchase(result: .failure(transaction.error ?? ElaProIAPError.unknown("购买失败")))
                }
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                if transaction.payment.productIdentifier == purchasingProductID {
                    resolvePurchase(result: .success(transaction))
                }
            case .deferred:
                if transaction.payment.productIdentifier == purchasingProductID {
                    resolvePurchase(result: .failure(ElaProIAPError.pendingApproval))
                }
            case .purchasing:
                break
            @unknown default:
                SKPaymentQueue.default().finishTransaction(transaction)
                if transaction.payment.productIdentifier == purchasingProductID {
                    resolvePurchase(result: .failure(ElaProIAPError.unknown("交易状态异常")))
                }
            }
        }
    }
}
