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
    static let knownSubscriptionProductIDs: Set<String> = ["annual", "month", "annual_yeal_new"]
    static let guidanceAnnualProductID = "annual_yeal_new"
    static var monthProductID = ""
    static var annualProductID = "annual_yeal_new"
    static var lifetimeProductID = ""
}

enum ElaProIAPError: LocalizedError {
    case productUnavailable
    case purchaseBusy
    case cancelled
    case pendingApproval
    case invalidAppAccountToken
    case identityUnavailable
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .productUnavailable:
            return "未获取到可购买商品"
        case .purchaseBusy:
            return "正在处理上一笔订单"
        case .cancelled:
            return "已取消购买"
        case .pendingApproval:
            return "订单待批准，请稍后"
        case .invalidAppAccountToken:
            return "订阅身份异常，请稍后重试"
        case .identityUnavailable:
            return "未获取到订阅身份，请稍后重试"
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

enum ElaProRestorePurchaseOutcome {
    case restored
    case notFound
    case boundToOtherAccount
    case pendingLoginBind
    case pendingServerSync
}

final class ElaProIAPManager: NSObject {
    static let shared = ElaProIAPManager()
    static let localEntitlementUpdatedNotification = NSNotification.Name("ela_pro_local_entitlement_updated")
    static let refundDebugLogUpdatedNotification = NSNotification.Name("ela_pro_refund_debug_log_updated")

    enum PurchasePostActionOutcome {
        case activated
        case boundToOtherAccount
        case pendingLoginBind
        case pendingServerSync
    }

    private enum PurchaseQueryBizType: String {
        case pendingBind = "1"
        case aiGuidance = "2"
        case standard = "3"
        case aiFoodRecognition = "4"
        case nutritionElements = "5"
    }

    private enum BackendSyncOutcome {
        case success
        case boundToOtherAccount
        case failed
    }

    private struct AnonymousIdentity {
        let anonymousUid: String
        let appAccountToken: String
        let expiresAt: String?
        let boundUID: String?

        var isBoundToCurrentUser: Bool {
            let currentUID = UserInfoModel.shared.uId.trimmingCharacters(in: .whitespacesAndNewlines)
            let storedUID = boundUID?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return !currentUID.isEmpty && currentUID == storedUID
        }
    }

    private var cachedProducts: [String: Product] = [:]
    private let productCacheQueue = DispatchQueue(label: "com.elavatine.pro.iap.productCache")
    private var purchaseTask: Task<Void, Never>?
    private var identityRefreshTask: Task<Void, Never>?
    private var transactionUpdatesTask: Task<Void, Never>?
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
        static let deviceInstallID = "ela_pro_device_install_id"
        static let anonymousUID = "ela_pro_anonymous_uid"
        static let appAccountToken = "ela_pro_app_account_token"
        static let anonymousIdentityExpiresAt = "ela_pro_anonymous_identity_expires_at"
        static let anonymousIdentityBoundUID = "ela_pro_anonymous_identity_bound_uid"
        static let pendingIdentityRefreshAfterDeletion = "ela_pro_pending_identity_refresh_after_deletion"
    }

    private enum KeychainKeys {
        static let pendingTransactionService = "com.elavatine.pro.iap"
        static let pendingTransactionAccount = "pending_transaction_id"
        static let pendingPayloadAccount = "pending_purchase_payload"
    }

    private override init() {
        super.init()
        startObservingRefundLifecycle()
        startObservingTransactionUpdates()
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    func fetchAnnualProduct(completion: @escaping (Result<Product, Error>) -> Void) {
        let annualID = ElaProIAPConfig.annualProductID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !annualID.isEmpty else {
            completion(.failure(ElaProIAPError.productUnavailable))
            return
        }
        fetchProducts(ids: [annualID], forceRefresh: false) { result in
            switch result {
            case .success(let products):
                if let product = products.first(where: { $0.id == annualID }) {
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

    func fetchGuidanceAnnualProduct(completion: @escaping (Result<Product, Error>) -> Void) {
        let annualID = ElaProIAPConfig.guidanceAnnualProductID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !annualID.isEmpty else {
            completion(.failure(ElaProIAPError.productUnavailable))
            return
        }
        fetchProducts(ids: [annualID], forceRefresh: false) { result in
            switch result {
            case .success(let products):
                if let product = products.first(where: { $0.id == annualID }) {
                    self.logProductInfo(product, source: "guidanceAnnualProductID")
                    completion(.success(product))
                } else {
                    completion(.failure(ElaProIAPError.productUnavailable))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func checkGuidanceAnnualIntroOfferEligibility(completion: @escaping (Result<Bool, Error>) -> Void) {
        let annualID = ElaProIAPConfig.guidanceAnnualProductID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !annualID.isEmpty else {
            completion(.failure(ElaProIAPError.productUnavailable))
            return
        }

        Task {
            do {
                let products = try await Product.products(for: [annualID])
                guard let product = products.first(where: { $0.id == annualID }),
                      let subscription = product.subscription else {
                    DispatchQueue.main.async {
                        completion(.failure(ElaProIAPError.productUnavailable))
                    }
                    return
                }

                let isEligible = await subscription.isEligibleForIntroOffer
                DispatchQueue.main.async {
                    completion(.success(isEligible))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func fetchMonthProduct(completion: @escaping (Result<Product, Error>) -> Void) {
        let monthID = ElaProIAPConfig.monthProductID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !monthID.isEmpty else {
            completion(.failure(ElaProIAPError.productUnavailable))
            return
        }
        fetchProducts(ids: [monthID], forceRefresh: false) { result in
            switch result {
            case .success(let products):
                if let product = products.first(where: { $0.id == monthID }) {
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
                          completion: @escaping (Result<[Product], Error>) -> Void) {
        let requestedProductIDs = (productIDs?.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } ?? [
            ElaProIAPConfig.monthProductID,
            ElaProIAPConfig.annualProductID,
            ElaProIAPConfig.lifetimeProductID
        ]).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        guard !requestedProductIDs.isEmpty else {
            completion(.failure(ElaProIAPError.productUnavailable))
            return
        }

        fetchProducts(ids: requestedProductIDs, forceRefresh: false) { result in
            if case .success(let products) = result {
                if requestedProductIDs.contains(ElaProIAPConfig.monthProductID),
                   let month = products.first(where: { $0.id == ElaProIAPConfig.monthProductID }) {
                    self.logProductInfo(month, source: "monthProductID")
                }
                if requestedProductIDs.contains(ElaProIAPConfig.annualProductID),
                   let annual = products.first(where: { $0.id == ElaProIAPConfig.annualProductID }) {
                    self.logProductInfo(annual, source: "annualProductID")
                }
                if requestedProductIDs.contains(ElaProIAPConfig.lifetimeProductID),
                   let lifetime = products.first(where: { $0.id == ElaProIAPConfig.lifetimeProductID }) {
                    self.logProductInfo(lifetime, source: "lifetimeProductID")
                }
            }
            completion(result)
        }
    }

    func fetchLifetimeProduct(completion: @escaping (Result<Product, Error>) -> Void) {
        let lifetimeID = ElaProIAPConfig.lifetimeProductID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !lifetimeID.isEmpty else {
            completion(.failure(ElaProIAPError.productUnavailable))
            return
        }
        fetchProducts(ids: [lifetimeID], forceRefresh: false) { result in
            switch result {
            case .success(let products):
                if let product = products.first(where: { $0.id == lifetimeID }) {
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

    func purchaseAnnual(completion: @escaping (Result<Transaction, Error>) -> Void) {
        purchase(productID: ElaProIAPConfig.annualProductID, completion: completion)
    }

    func purchaseGuidanceAnnual(completion: @escaping (Result<Transaction, Error>) -> Void) {
        purchase(productID: ElaProIAPConfig.guidanceAnnualProductID, completion: completion)
    }

    func purchaseMonth(completion: @escaping (Result<Transaction, Error>) -> Void) {
        purchase(productID: ElaProIAPConfig.monthProductID, completion: completion)
    }

    func purchaseLifetime(completion: @escaping (Result<Transaction, Error>) -> Void) {
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

        DLLog(message: "[ElaProIAP][HISTORY] start check, productID=\(trimmedProductID)")
        Task {
            let state = await self.subscriptionHistoryStateStoreKit2(productID: trimmedProductID)
            DispatchQueue.main.async {
                DLLog(message: "[ElaProIAP][HISTORY] finish check, productID=\(trimmedProductID), state=\(self.debugDescription(for: state))")
                completion(state)
            }
        }
    }

    func checkSubscriptionHistoryState(subscriptionGroupID: String,
                                       productIDs: [String],
                                       completion: @escaping (ElaProSubscriptionHistoryState) -> Void) {
        let trimmedSubscriptionGroupID = subscriptionGroupID.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedProductIDs = productIDs
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !trimmedSubscriptionGroupID.isEmpty || !trimmedProductIDs.isEmpty else {
            DLLog(message: "[ElaProIAP][HISTORY] skip group check: empty subscriptionGroupID and productIDs")
            completion(.unknown)
            return
        }

        DLLog(message: "[ElaProIAP][HISTORY] start group check, subscriptionGroupID=\(trimmedSubscriptionGroupID), productIDs=\(trimmedProductIDs.joined(separator: ","))")
        Task {
            let state = await self.subscriptionHistoryStateStoreKit2(subscriptionGroupID: trimmedSubscriptionGroupID,
                                                                     productIDs: trimmedProductIDs)
            DispatchQueue.main.async {
                DLLog(message: "[ElaProIAP][HISTORY] finish group check, subscriptionGroupID=\(trimmedSubscriptionGroupID), productIDs=\(trimmedProductIDs.joined(separator: ",")), state=\(self.debugDescription(for: state))")
                completion(state)
            }
        }
    }

    func localizedPriceString(for product: Product) -> String {
        return priceTextRemovingUSPrefix(product.displayPrice)
    }

    private func priceTextRemovingUSPrefix(_ text: String) -> String {
        guard text.hasPrefix("US") else {
            return text
        }

        let prefixEnd = text.index(text.startIndex, offsetBy: 2)
        let remainingText = text[prefixEnd...]
        let spaces = remainingText.prefix { $0.isWhitespace }
        let symbolStart = remainingText.index(remainingText.startIndex, offsetBy: spaces.count)
        guard symbolStart < remainingText.endIndex, remainingText[symbolStart] == "$" else {
            return text
        }

        return "$" + String(remainingText[remainingText.index(after: symbolStart)...])
    }

    func updateProductIDs(month: String, annual: String, lifetime: String) {
        let trimmedMonth = month.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnnual = annual.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLifetime = lifetime.trimmingCharacters(in: .whitespacesAndNewlines)
        guard ElaProIAPConfig.monthProductID != trimmedMonth ||
                ElaProIAPConfig.annualProductID != trimmedAnnual ||
                ElaProIAPConfig.lifetimeProductID != trimmedLifetime else {
            return
        }

        ElaProIAPConfig.monthProductID = trimmedMonth
        ElaProIAPConfig.annualProductID = trimmedAnnual
        ElaProIAPConfig.lifetimeProductID = trimmedLifetime
        clearCachedProducts()
    }

    func handlePurchaseSuccessPostAction(transaction: Transaction,
                                         queryBizType: String = PurchaseQueryBizType.standard.rawValue,
                                         completion: ((PurchasePostActionOutcome) -> Void)? = nil) {
        let fallbackQueryBizType = resolveQueryBizType(queryBizType, defaultType: .standard)
        let effectiveQueryBizType = fallbackQueryBizType
        let localUnlockExpireAt = applyLocalTemporaryUnlock(transaction: transaction)
        let payload = makePurchaseVerifyPayload(transaction: transaction,
                                                localUnlockExpireAt: localUnlockExpireAt,
                                                bizType: effectiveQueryBizType)
        appendRefundDebugLog("购买成功，已生成验单载荷", payload: payload)
        cachePendingVerifyPayload(payload: payload)
        storePendingTransactionID(String(transaction.id))
        storePendingVerifyPayloadInKeychain(payload: payload)

        Task {
            await transaction.finish()
        }

        if canBindPurchaseToCurrentUser() {
            bindPendingPurchaseIfNeededDetailed(queryBizType: effectiveQueryBizType) { outcome in
                switch outcome {
                case .success:
                    completion?(.activated)
                case .boundToOtherAccount:
                    completion?(.boundToOtherAccount)
                case .failed:
                    completion?(.pendingServerSync)
                }
            }
        } else {
            DLLog(message: "[ElaProIAP][QUERY] deferred until login: user not ready")
            completion?(.pendingLoginBind)
        }
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
        clearPendingVerifyPayloadKeychainCache()
        clearPendingTransactionIDCache(defaults: defaults)
    }

    func resetAnonymousIdentityAfterAccountDeletion(delaySeconds: TimeInterval = 3) {
        clearAnonymousIdentity()
        UserDefaults.standard.set(true, forKey: LocalUnlockKeys.pendingIdentityRefreshAfterDeletion)
        refreshAnonymousIdentityAfterDeletionIfNeeded(delaySeconds: delaySeconds)
    }

    func refreshAnonymousIdentityAfterDeletionIfNeeded(delaySeconds: TimeInterval = 0) {
        guard UserDefaults.standard.bool(forKey: LocalUnlockKeys.pendingIdentityRefreshAfterDeletion) else {
            return
        }
        guard identityRefreshTask == nil else {
            return
        }

        identityRefreshTask = Task {
            defer { self.identityRefreshTask = nil }

            let delayNanoseconds = UInt64(max(delaySeconds, 0) * 1_000_000_000)
            if delayNanoseconds > 0 {
                try? await Task.sleep(nanoseconds: delayNanoseconds)
            }

            do {
                let identity = try await requestAnonymousIdentity()
                UserDefaults.standard.removeObject(forKey: LocalUnlockKeys.pendingIdentityRefreshAfterDeletion)
                DLLog(message: [
                    "tag": "[ElaProIAP][IDENTITY] refreshed after account deletion",
                    "anonymousUid": identity.anonymousUid,
                    "appAccountToken": identity.appAccountToken
                ])
            } catch {
                DLLog(message: [
                    "tag": "[ElaProIAP][IDENTITY] refresh after account deletion failed",
                    "error": error.localizedDescription
                ])
            }
        }
    }

    func bindPendingPurchaseIfNeeded(queryBizType: String = PurchaseQueryBizType.pendingBind.rawValue,
                                     completion: ((Bool) -> Void)? = nil) {
        bindPendingPurchaseIfNeededDetailed(queryBizType: queryBizType) { outcome in
            completion?(outcome == .success)
        }
    }

    func hasPendingPurchaseToBind() -> Bool {
        let transactionID = readPendingTransactionID()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return !transactionID.isEmpty
    }

    func bindPendingPurchaseBeforeEnterApp(queryBizType: String = PurchaseQueryBizType.pendingBind.rawValue,
                                           completion: ((Bool) -> Void)? = nil) {
        guard canBindPurchaseToCurrentUser() else {
            completion?(false)
            return
        }

        bindAnonymousIdentityIfNeeded { bindSuccess in
            guard bindSuccess else {
                completion?(false)
                return
            }

            guard let transactionID = self.readPendingTransactionID(),
                  !transactionID.isEmpty else {
                completion?(true)
                return
            }

            let resolvedQueryBizType = self.resolvePendingPurchaseQueryBizType(transactionID: transactionID,
                                                                               fallbackQueryBizType: queryBizType)
            self.queryPurchaseOrder(transactionID: transactionID, bizType: resolvedQueryBizType) { queryOutcome in
                switch queryOutcome {
                case .success:
                    completion?(true)
                case .boundToOtherAccount, .failed:
                    completion?(false)
                }
            }
        }
    }

    private func bindPendingPurchaseIfNeededDetailed(queryBizType: String = PurchaseQueryBizType.pendingBind.rawValue,
                                                     completion: ((BackendSyncOutcome) -> Void)? = nil) {
        guard canBindPurchaseToCurrentUser() else {
            completion?(.failed)
            return
        }

        bindAnonymousIdentityIfNeeded { bindSuccess in
            guard let transactionID = self.readPendingTransactionID(),
                  !transactionID.isEmpty else {
                completion?(bindSuccess ? .success : .failed)
                return
            }

            let resolvedQueryBizType = self.resolvePendingPurchaseQueryBizType(transactionID: transactionID,
                                                                               fallbackQueryBizType: queryBizType)
            self.queryPurchaseOrder(transactionID: transactionID, bizType: resolvedQueryBizType) { queryOutcome in
                switch queryOutcome {
                case .success, .boundToOtherAccount:
                    completion?(queryOutcome)
                case .failed:
                    completion?(bindSuccess ? .success : .failed)
                }
            }
        }
    }

    func restorePurchases(completion: @escaping (Result<ElaProRestorePurchaseOutcome, Error>) -> Void) {
        Task {
            do {
                DLLog(message: "[ElaProIAP][RESTORE] start AppStore.sync")
                try await AppStore.sync()
                DLLog(message: "[ElaProIAP][RESTORE] AppStore.sync finished")

                let transactions = await activeRestorableEntitlementTransactions()
                guard let transaction = latestTransaction(from: transactions) else {
                    DispatchQueue.main.async {
                        completion(.success(.notFound))
                    }
                    return
                }

                handleRestorePurchasePostAction(transaction: transaction,
                                                restoredTransactions: transactions) { outcome in
                    completion(.success(outcome))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    private func fetchProducts(ids: [String],
                               forceRefresh: Bool,
                               completion: @escaping (Result<[Product], Error>) -> Void) {
        let idSet = Set(ids.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty })
        guard !idSet.isEmpty else {
            performOnMain {
                completion(.failure(ElaProIAPError.productUnavailable))
            }
            return
        }

        if !forceRefresh, let cachedProductList = cachedProductList(for: idSet) {
            performOnMain {
                completion(.success(cachedProductList))
            }
            return
        }

        Task {
            do {
                let products = try await Product.products(for: Array(idSet))
                self.cacheProducts(products)
                self.performOnMain {
                    completion(products.isEmpty ? .failure(ElaProIAPError.productUnavailable) : .success(products))
                }
            } catch {
                self.performOnMain {
                    completion(.failure(error))
                }
            }
        }
    }

    private func cachedProductList(for ids: Set<String>) -> [Product]? {
        productCacheQueue.sync {
            let products = ids.compactMap { cachedProducts[$0] }
            return products.count == ids.count ? products : nil
        }
    }

    private func cacheProducts(_ products: [Product]) {
        productCacheQueue.sync {
            for product in products {
                cachedProducts[product.id] = product
            }
        }
    }

    private func clearCachedProducts() {
        productCacheQueue.sync {
            cachedProducts.removeAll()
        }
    }

    private func performOnMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }

    private func purchase(productID: String,
                          completion: @escaping (Result<Transaction, Error>) -> Void) {
        let trimmedProductID = productID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedProductID.isEmpty else {
            completion(.failure(ElaProIAPError.productUnavailable))
            return
        }

        guard purchaseTask == nil else {
            completion(.failure(ElaProIAPError.purchaseBusy))
            return
        }

        purchaseTask = Task {
            defer { self.purchaseTask = nil }

            do {
                let identity = try await ensurePurchaseIdentity()
                guard let appAccountUUID = normalizedAppAccountUUID(from: identity.appAccountToken) else {
                    DLLog(message: [
                        "tag": "[ElaProIAP][IDENTITY] purchase invalid appAccountToken",
                        "anonymousUid": identity.anonymousUid,
                        "appAccountToken": identity.appAccountToken
                    ])
                    clearAnonymousIdentity()
                    completion(.failure(ElaProIAPError.invalidAppAccountToken))
                    return
                }

                let products = try await Product.products(for: [trimmedProductID])
                guard let product = products.first(where: { $0.id == trimmedProductID }) else {
                    completion(.failure(ElaProIAPError.productUnavailable))
                    return
                }
                self.cacheProducts([product])

                let result = try await product.purchase(options: [.appAccountToken(appAccountUUID)])
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        logAppleTransaction(transaction, source: "purchase verified")
                        completion(.success(transaction))
                    case .unverified(let transaction, let error):
                        DLLog(message: [
                            "tag": "[ElaProIAP][APPLE_TRANSACTION] purchase unverified",
                            "error": error.localizedDescription,
                            "transaction": appleTransactionLogPayload(transaction)
                        ])
                        completion(.failure(error))
                    }
                case .userCancelled:
                    completion(.failure(ElaProIAPError.cancelled))
                case .pending:
                    completion(.failure(ElaProIAPError.pendingApproval))
                @unknown default:
                    completion(.failure(ElaProIAPError.unknown("交易状态异常")))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func ensurePurchaseIdentity() async throws -> AnonymousIdentity {
        if let cachedIdentity = currentAnonymousIdentity() {
            if normalizedAppAccountUUID(from: cachedIdentity.appAccountToken) != nil {
                return cachedIdentity
            }
            DLLog(message: "[ElaProIAP][IDENTITY] cached appAccountToken invalid, clear and refetch. token=\(cachedIdentity.appAccountToken)")
            clearAnonymousIdentity()
        }
        return try await requestAnonymousIdentity()
    }

    private func requestAnonymousIdentity() async throws -> AnonymousIdentity {
        try await withCheckedThrowingContinuation { continuation in
            let params: [String: AnyObject] = [
                "device_install_id": deviceInstallID() as AnyObject,
                "app_version": appVersion() as AnyObject,
                "app_build": appBuild() as AnyObject
            ]

            WHNetworkUtil.shareManager().POST(urlString: URL_iap_dientity, parameters: params, success: { responseObject in
                let code = responseObject["code"] as? Int ?? -1
                let dataEncString = responseObject["data"]as? String ?? ""
                let dataDecString = AESEncyptUtil.aesDecrypt(hexString: dataEncString)
                let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataDecString ?? "")
                
                DLLog(message: "URL_iap_dientity:\(dataObj)")
                
                guard code == 200 else {
                    let message = responseObject["message"] as? String ?? "订阅身份初始化失败"
                    continuation.resume(throwing: ElaProIAPError.unknown(message))
                    return
                }

                let decodedPayload = self.decodedIdentityPayload(from: responseObject)
                DLLog(message: [
                    "tag": "[ElaProIAP][IDENTITY] identity/init decoded payload",
                    "payload": decodedPayload ?? "nil"
                ])

                guard let identity = self.parseAnonymousIdentity(from: responseObject) else {
                    continuation.resume(throwing: ElaProIAPError.identityUnavailable)
                    return
                }

                guard let normalizedUUID = self.normalizedAppAccountUUID(from: identity.appAccountToken) else {
                    DLLog(message: [
                        "tag": "[ElaProIAP][IDENTITY] identity/init invalid appAccountToken",
                        "anonymousUid": identity.anonymousUid,
                        "appAccountToken": identity.appAccountToken
                    ])
                    continuation.resume(throwing: ElaProIAPError.invalidAppAccountToken)
                    return
                }

                let normalizedIdentity = AnonymousIdentity(anonymousUid: identity.anonymousUid,
                                                           appAccountToken: normalizedUUID.uuidString.lowercased(),
                                                           expiresAt: identity.expiresAt,
                                                           boundUID: identity.boundUID)
                self.storeAnonymousIdentity(normalizedIdentity)
                self.appendRefundDebugLog("订阅匿名身份初始化成功", payload: [
                    "anonymousUid": normalizedIdentity.anonymousUid,
                    "appAccountToken": normalizedIdentity.appAccountToken
                ])
                continuation.resume(returning: normalizedIdentity)
            }, failure: { failed in
                continuation.resume(throwing: ElaProIAPError.unknown("订阅身份初始化失败"))
                self.appendRefundDebugLog("订阅匿名身份初始化失败", payload: [
                    "failed": failed
                ])
            })
        }
    }

    private func parseAnonymousIdentity(from responseObject: [AnyHashable: Any]) -> AnonymousIdentity? {
        let rawData = decodedIdentityPayload(from: responseObject)
        let payload: [String: Any]?
        if let array = rawData as? [[String: Any]], let first = array.first {
            payload = first
        } else if let dict = rawData as? [String: Any] {
            payload = dict
        } else if let array = rawData as? NSArray, let first = array.firstObject as? [String: Any] {
            payload = first
        } else if let dict = rawData as? NSDictionary {
            payload = dict as? [String: Any]
        } else {
            payload = nil
        }

        guard let payload else { return nil }

        let anonymousUid = (payload["anonymousUid"] as? String)
        ?? (payload["anonymous_user_id"] as? String)
        ?? (payload["anonymousUserId"] as? String)
        ?? ""

        let appAccountToken = (payload["appAccountToken"] as? String)
        ?? (payload["app_account_token"] as? String)
        ?? ""

        guard !anonymousUid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !appAccountToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        let expiresAt = (payload["expiresAt"] as? String) ?? (payload["expires_at"] as? String)
        let boundUID = (payload["boundUid"] as? String) ?? (payload["bound_uid"] as? String)
        return AnonymousIdentity(anonymousUid: anonymousUid,
                                 appAccountToken: appAccountToken,
                                 expiresAt: expiresAt,
                                 boundUID: boundUID)
    }

    private func decodedIdentityPayload(from responseObject: [AnyHashable: Any]) -> Any? {
        if let encryptedPayload = responseObject["data"] as? String {
            let trimmedPayload = encryptedPayload.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedPayload.isEmpty else { return nil }

            if let decryptedString = AESEncyptUtil.aesDecrypt(hexString: trimmedPayload)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
               let payload = jsonObject(from: decryptedString) {
                return payload
            }

            if let payload = jsonObject(from: trimmedPayload) {
                return payload
            }

            return nil
        }

        return responseObject["data"]
    }

    private func jsonObject(from jsonString: String) -> Any? {
        guard !jsonString.isEmpty, let data = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: [.mutableContainers])
    }

    private func normalizedAppAccountUUID(from rawToken: String) -> UUID? {
        let trimmedToken = rawToken.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedToken.isEmpty else { return nil }

        let normalizedToken = trimmedToken
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return UUID(uuidString: normalizedToken)
    }

    private func currentAnonymousIdentity() -> AnonymousIdentity? {
        let defaults = UserDefaults.standard
        let anonymousUid = defaults.string(forKey: LocalUnlockKeys.anonymousUID)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let appAccountToken = defaults.string(forKey: LocalUnlockKeys.appAccountToken)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !anonymousUid.isEmpty, !appAccountToken.isEmpty else {
            return nil
        }
        let expiresAt = defaults.string(forKey: LocalUnlockKeys.anonymousIdentityExpiresAt)
        let boundUID = defaults.string(forKey: LocalUnlockKeys.anonymousIdentityBoundUID)
        return AnonymousIdentity(anonymousUid: anonymousUid,
                                 appAccountToken: appAccountToken,
                                 expiresAt: expiresAt,
                                 boundUID: boundUID)
    }

    private func storeAnonymousIdentity(_ identity: AnonymousIdentity) {
        let defaults = UserDefaults.standard
        defaults.set(identity.anonymousUid, forKey: LocalUnlockKeys.anonymousUID)
        defaults.set(identity.appAccountToken, forKey: LocalUnlockKeys.appAccountToken)
        defaults.set(identity.expiresAt, forKey: LocalUnlockKeys.anonymousIdentityExpiresAt)
        defaults.set(identity.boundUID, forKey: LocalUnlockKeys.anonymousIdentityBoundUID)
    }

    private func clearAnonymousIdentity() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: LocalUnlockKeys.anonymousUID)
        defaults.removeObject(forKey: LocalUnlockKeys.appAccountToken)
        defaults.removeObject(forKey: LocalUnlockKeys.anonymousIdentityExpiresAt)
        defaults.removeObject(forKey: LocalUnlockKeys.anonymousIdentityBoundUID)
    }

    private func markAnonymousIdentityBoundToCurrentUser() {
        let currentUID = currentUserID()
        guard !currentUID.isEmpty else { return }
        UserDefaults.standard.set(currentUID, forKey: LocalUnlockKeys.anonymousIdentityBoundUID)
    }

    private func bindAnonymousIdentityIfNeeded(completion: @escaping (Bool) -> Void) {
        guard let identity = currentAnonymousIdentity() else {
            completion(true)
            return
        }
        guard !identity.isBoundToCurrentUser else {
            completion(true)
            return
        }

        let params: [String: AnyObject] = [
            "anonymousUid": identity.anonymousUid as AnyObject,
            "appAccountToken": identity.appAccountToken as AnyObject
        ]

        WHNetworkUtil.shareManager().POST(urlString: URL_iap_dientity_bind, parameters: params, success: { responseObject in
            let code = responseObject["code"] as? Int ?? -1
            let dataEncString = responseObject["data"]as? String ?? ""
            let dataDecString = AESEncyptUtil.aesDecrypt(hexString: dataEncString)
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataDecString ?? "")
            
            DLLog(message: "URL_iap_dientity:\(dataObj)")
            self.appendRefundDebugLog("匿名身份绑定返回", payload: [
                "code": code,
                "response": responseObject
            ])
            if code == 200 {
                self.markAnonymousIdentityBoundToCurrentUser()
                NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_VIP_STATUS, object: nil)
                completion(true)
            } else if self.isBoundToOtherAccountResponse(responseObject, decodedData: dataObj) {
                DLLog(message: "[ElaProIAP][IDENTITY] anonymous identity bind conflict, continue login flow")
                completion(false)
            } else {
                completion(false)
            }
        }, failure: { failed in
            self.appendRefundDebugLog("匿名身份绑定失败", payload: [
                "failed": failed
            ])
            completion(false)
        })
    }

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

    private func subscriptionHistoryStateStoreKit2(subscriptionGroupID: String,
                                                   productIDs: [String]) async -> ElaProSubscriptionHistoryState {
        let cleanSubscriptionGroupID = subscriptionGroupID.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanProductIDs = Set(productIDs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty })

        if !cleanSubscriptionGroupID.isEmpty {
            let isEligibleForIntroOffer = await Product.SubscriptionInfo.isEligibleForIntroOffer(for: cleanSubscriptionGroupID)
            DLLog(message: "[ElaProIAP][HISTORY] group intro eligibility, subscriptionGroupID=\(cleanSubscriptionGroupID), isEligible=\(isEligibleForIntroOffer)")
            if !isEligibleForIntroOffer {
                return .subscribed
            }
        }

        let hasTransactionHistory = await hasVerifiedSubscriptionHistory(subscriptionGroupID: cleanSubscriptionGroupID,
                                                                         productIDs: cleanProductIDs)
        if hasTransactionHistory {
            return .subscribed
        }

        return cleanSubscriptionGroupID.isEmpty ? .unknown : .notSubscribed
    }

    private func hasVerifiedSubscriptionHistory(subscriptionGroupID: String,
                                                productIDs: Set<String>) async -> Bool {
        for await result in Transaction.all {
            switch result {
            case .verified(let transaction):
                let transactionGroupID = transaction.subscriptionGroupID?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let transactionProductID = transaction.productID.trimmingCharacters(in: .whitespacesAndNewlines)
                let isMatchedGroup = !subscriptionGroupID.isEmpty && transactionGroupID == subscriptionGroupID
                let isMatchedProduct = productIDs.contains(transactionProductID)
                if isMatchedGroup || isMatchedProduct {
                    DLLog(message: "[ElaProIAP][HISTORY] transaction history matched, subscriptionGroupID=\(transactionGroupID), productID=\(transaction.productID), transactionID=\(transaction.id)")
                    return true
                }
            case .unverified:
                DLLog(message: "[ElaProIAP][HISTORY] skip unverified transaction while scanning group history")
            }
        }
        DLLog(message: "[ElaProIAP][HISTORY] no matched transaction history, subscriptionGroupID=\(subscriptionGroupID), productIDs=\(productIDs.joined(separator: ","))")
        return false
    }

    private func activeRestorableEntitlementTransactions() async -> [Transaction] {
        let restorableProductIDs = configuredIAPProductIDs()
        guard !restorableProductIDs.isEmpty else {
            DLLog(message: "[ElaProIAP][RESTORE] no configured product ids")
            return []
        }

        var transactions: [Transaction] = []
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                logAppleTransaction(transaction, source: "restore currentEntitlements verified")
                guard restorableProductIDs.contains(transaction.productID),
                      isActiveRestorableTransaction(transaction) else {
                    DLLog(message: [
                        "tag": "[ElaProIAP][RESTORE] skip entitlement",
                        "reason": "product not configured or inactive",
                        "transaction": appleTransactionLogPayload(transaction)
                    ])
                    continue
                }

                transactions.append(transaction)
            case .unverified(let transaction, let error):
                DLLog(message: [
                    "tag": "[ElaProIAP][RESTORE] unverified entitlement",
                    "error": error.localizedDescription,
                    "transaction": appleTransactionLogPayload(transaction)
                ])
            }
        }

        if transactions.isEmpty {
            DLLog(message: "[ElaProIAP][RESTORE] no active entitlement found")
        } else {
            DLLog(message: [
                "tag": "[ElaProIAP][RESTORE] active entitlement transactions",
                "count": transactions.count,
                "transactions": transactions.map { appleTransactionLogPayload($0) }
            ])
        }
        return transactions
    }

    private func latestTransaction(from transactions: [Transaction]) -> Transaction? {
        return transactions.max { $0.purchaseDate < $1.purchaseDate }
    }

    private func isActiveRestorableTransaction(_ transaction: Transaction) -> Bool {
        guard transaction.revocationDate == nil, !transaction.isUpgraded else {
            return false
        }

        if let expirationDate = transaction.expirationDate {
            return expirationDate > Date()
        }
        return true
    }

    private func handleRestorePurchasePostAction(transaction: Transaction,
                                                 restoredTransactions: [Transaction],
                                                 completion: @escaping (ElaProRestorePurchaseOutcome) -> Void) {
        let localUnlockExpireAt = applyLocalTemporaryUnlock(transaction: transaction)
        let payload = makePurchaseVerifyPayload(transaction: transaction, localUnlockExpireAt: localUnlockExpireAt)
        appendRefundDebugLog("恢复购买，已生成验单载荷", payload: payload)
        cachePendingVerifyPayload(payload: payload)
        storePendingTransactionID(String(transaction.id))
        storePendingVerifyPayloadInKeychain(payload: payload)

        guard canBindPurchaseToCurrentUser() else {
            DispatchQueue.main.async {
                completion(.pendingLoginBind)
            }
            return
        }

        reportRestoredTransactionsToServer(transactions: restoredTransactions) { restoreOutcome in
            let defaults = UserDefaults.standard
            DispatchQueue.main.async {
                switch restoreOutcome {
                case .success:
                    self.clearPendingPurchaseLocalState(defaults: defaults, shouldNotify: true)
                    completion(.restored)
                case .boundToOtherAccount:
                    self.clearLocalUnlock(defaults: defaults, shouldNotify: true)
                    completion(.boundToOtherAccount)
                case .failed:
                    self.clearLocalUnlock(defaults: defaults, shouldNotify: true)
                    completion(.pendingServerSync)
                }
            }
        }
    }

    private func configuredIAPProductIDs() -> Set<String> {
        let currentProductIDs = [
            ElaProIAPConfig.monthProductID,
            ElaProIAPConfig.annualProductID,
            ElaProIAPConfig.lifetimeProductID
        ]
        let configuredProductIDs = Set(currentProductIDs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty })
        return configuredProductIDs.union(ElaProIAPConfig.knownSubscriptionProductIDs)
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

    private func applyLocalTemporaryUnlock(transaction: Transaction) -> Date {
        let now = Date()
        let productID = transaction.productID
        let expireAt = now.addingTimeInterval(localUnlockDuration(productID: productID))
        let defaults = UserDefaults.standard

        defaults.set(true, forKey: LocalUnlockKeys.isUnlocked)
        defaults.set(currentUserID(), forKey: LocalUnlockKeys.uid)
        defaults.set(productID, forKey: LocalUnlockKeys.productID)
        defaults.set(String(transaction.id), forKey: LocalUnlockKeys.transactionID)
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
        if configuredIAPProductIDs().contains(productID) {
            return 7 * 24 * 60 * 60
        }
        return 3 * 24 * 60 * 60
    }

    private func makePurchaseVerifyPayload(transaction: Transaction,
                                           localUnlockExpireAt: Date,
                                           bizType: String = PurchaseQueryBizType.standard.rawValue) -> [String: Any] {
        let now = Date()
        let identity = currentAnonymousIdentity()
        let resolvedBizType = resolveQueryBizType(bizType, defaultType: .standard)

        return [
            "userId": UserInfoModel.shared.uId,
            "bizType": resolvedBizType,
            "anonymousUid": identity?.anonymousUid ?? "",
            "appAccountToken": identity?.appAccountToken ?? transaction.appAccountToken?.uuidString.lowercased() ?? "",
            "productId": transaction.productID,
            "transactionId": String(transaction.id),
            "originalTransactionId": String(transaction.originalID),
            "transactionDateMs": Int64(transaction.purchaseDate.timeIntervalSince1970 * 1000),
            "originalTransactionDateMs": Int64(transaction.originalPurchaseDate.timeIntervalSince1970 * 1000),
            "subscriptionGroupName": ElaProIAPConfig.subscriptionGroupName,
            "subscriptionGroupId": ElaProIAPConfig.subscriptionGroupID,
            "receiptBase64": loadReceiptBase64(),
            "receiptEnvironmentHint": receiptEnvironmentHint(),
            "appBundleId": Bundle.main.bundleIdentifier ?? "",
            "appVersion": appVersion(),
            "appBuild": appBuild(),
            "deviceInstallID": deviceInstallID(),
            "clientTimestampMs": Int64(now.timeIntervalSince1970 * 1000),
            "localUnlockExpireAtMs": Int64(localUnlockExpireAt.timeIntervalSince1970 * 1000)
        ]
    }

    private func cachePendingVerifyPayload(payload: [String: Any]) {
        let json = WHUtils.getJSONStringFromDictionary(dictionary: payload as NSDictionary)
        UserDefaults.standard.set(json, forKey: LocalUnlockKeys.pendingVerifyPayload)
    }

    private func storePendingVerifyPayloadInKeychain(payload: [String: Any]) {
        let json = WHUtils.getJSONStringFromDictionary(dictionary: payload as NSDictionary)
        guard let data = json.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainKeys.pendingTransactionService,
            kSecAttrAccount as String: KeychainKeys.pendingPayloadAccount,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            DLLog(message: "[ElaProIAP][KEYCHAIN] save payload failed: \(status)")
        }
    }

    private func readPendingVerifyPayload() -> [String: Any]? {
        if let json = UserDefaults.standard.string(forKey: LocalUnlockKeys.pendingVerifyPayload),
           let payload = dictionaryFromJSONString(json) {
            return payload
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainKeys.pendingTransactionService,
            kSecAttrAccount as String: KeychainKeys.pendingPayloadAccount,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let json = String(data: data, encoding: .utf8) else {
            return nil
        }
        return dictionaryFromJSONString(json)
    }

    private func queryPurchaseOrder(transactionID: String,
                                    bizType: String,
                                    completion: ((BackendSyncOutcome) -> Void)? = nil) {
        let identity = currentAnonymousIdentity()
        var params: [String: AnyObject] = [
            "transactionId": transactionID as AnyObject,
            "bizType": bizType as AnyObject
        ]
        if let identity {
            params["anonymousUid"] = identity.anonymousUid as AnyObject
            params["appAccountToken"] = identity.appAccountToken as AnyObject
        }
        let uid = currentUserID()
        if !uid.isEmpty {
            params["uid"] = uid as AnyObject
        }

        WHNetworkUtil.shareManager().POST(urlString: URL_pro_iap_query,
                                          parameters: params,
                                          success: { responseObject in
            let code = responseObject["code"] as? Int ?? -1
            DLLog(message: "[ElaProIAP][QUERY] success: \(responseObject), transactionId=\(transactionID), bizType=\(bizType)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            let canBind = self.restoreCanBindValue(responseObject: responseObject, decodedData: dataObj)
            DLLog(message: "[ElaProIAP][QUERY] success:\(dataObj)")
            self.appendRefundDebugLog("后台订单查询返回", payload: [
                "transactionId": transactionID,
                "bizType": bizType,
                "code": code,
                "canBind": canBind.map { $0 ? 1 : 0 } ?? "nil",
                "decodedData": dataObj,
                "response": responseObject
            ])
            if code == 200, canBind == false {
                self.clearLocalUnlock(defaults: UserDefaults.standard, shouldNotify: true)
                completion?(.boundToOtherAccount)
            } else if code == 200, canBind == true {
                self.clearPendingPurchaseLocalState(defaults: UserDefaults.standard, shouldNotify: true)
                NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_VIP_STATUS, object: nil)
                completion?(.success)
            } else if self.isBoundToOtherAccountResponse(responseObject, decodedData: dataObj) {
                completion?(.boundToOtherAccount)
            } else {
                completion?(.failed)
            }
        }, failure: { failed in
            DLLog(message: "[ElaProIAP][QUERY] failure: \(failed), tractionId=\(transactionID), bizType=\(bizType)")
            self.appendRefundDebugLog("后台订单查询失败", payload: [
                "transactionId": transactionID,
                "bizType": bizType,
                "failed": failed
            ])
            completion?(.failed)
        })
    }

    private func reportRestoredTransactionsToServer(transactions: [Transaction],
                                                    completion: @escaping (BackendSyncOutcome) -> Void) {
        let transactionArray = NSMutableArray()
        transactions.forEach { transaction in
            var transactionPayload: [String: Any] = [
                "transactionId": String(transaction.id),
                "originalTransactionId": String(transaction.originalID),
                "productId": transaction.productID
            ]
            if let appAccountToken = transaction.appAccountToken?.uuidString.lowercased() {
                transactionPayload["appAccountToken"] = appAccountToken
            }
            transactionArray.add(transactionPayload)
        }

        guard transactionArray.count > 0 else {
            DLLog(message: "[ElaProIAP][RESTORE] skip URL_iap_dientity_restore: empty transactions")
            completion(.failed)
            return
        }

        let identity = currentAnonymousIdentity()
        var params: [String: AnyObject] = [
            "transactions": transactionArray
        ]
        let uid = currentUserID()
        if !uid.isEmpty {
            params["uid"] = uid as AnyObject
        }
        if let identity {
            params["anonymousUid"] = identity.anonymousUid as AnyObject
            params["appAccountToken"] = identity.appAccountToken as AnyObject
        }

        DLLog(message: [
            "tag": "[ElaProIAP][RESTORE] request URL_iap_dientity_restore",
            "url": URL_iap_dientity_restore,
            "params": params
        ])
        appendRefundDebugLog("恢复购买，上报恢复交易数组", payload: [
            "url": URL_iap_dientity_restore,
            "params": params
        ])

        WHNetworkUtil.shareManager().POST(urlString: URL_iap_dientity_restore,
                                          parameters: params,
                                          success: { responseObject in
            let code = responseObject["code"] as? Int ?? -1
            let decodedData = self.decodedIdentityPayload(from: responseObject)
            DLLog(message: [
                "tag": "[ElaProIAP][RESTORE] URL_iap_dientity_restore success",
                "url": URL_iap_dientity_restore,
                "code": code,
                "decodedData": decodedData ?? "nil",
                "response": responseObject
            ])
            let canBind = self.restoreCanBindValue(responseObject: responseObject, decodedData: decodedData)
            self.appendRefundDebugLog("恢复购买接口返回", payload: [
                "url": URL_iap_dientity_restore,
                "code": code,
                "canBind": canBind.map { $0 ? 1 : 0 } ?? "nil",
                "decodedData": decodedData ?? "nil",
                "response": responseObject
            ])
            if code == 200, canBind == false {
                completion(.boundToOtherAccount)
            } else if code == 200, canBind == true {
                NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_VIP_STATUS, object: nil)
                completion(.success)
            } else if self.isBoundToOtherAccountResponse(responseObject, decodedData: decodedData) {
                completion(.boundToOtherAccount)
            } else {
                completion(.failed)
            }
        }, failure: { failed in
            DLLog(message: [
                "tag": "[ElaProIAP][RESTORE] URL_iap_dientity_restore failure",
                "url": URL_iap_dientity_restore,
                "failed": failed
            ])
            self.appendRefundDebugLog("恢复购买接口失败", payload: [
                "url": URL_iap_dientity_restore,
                "failed": failed
            ])
            completion(.failed)
        })
    }

    private func restoreCanBindValue(responseObject: [AnyHashable: Any], decodedData: Any?) -> Bool? {
        if let value = canBindValue(from: decodedData) {
            return value
        }
        return canBindValue(from: responseObject)
    }

    private func canBindValue(from object: Any?) -> Bool? {
        if let dict = object as? [String: Any] {
            if let value = dict["canBind"] ?? dict["can_bind"] {
                return boolFromCanBindValue(value)
            }
            for value in dict.values {
                if let canBind = canBindValue(from: value) {
                    return canBind
                }
            }
        }

        if let dict = object as? NSDictionary {
            if let value = dict["canBind"] ?? dict["can_bind"] {
                return boolFromCanBindValue(value)
            }
            for value in dict.allValues {
                if let canBind = canBindValue(from: value) {
                    return canBind
                }
            }
        }

        if let array = object as? [Any] {
            for value in array {
                if let canBind = canBindValue(from: value) {
                    return canBind
                }
            }
        }

        if let array = object as? NSArray {
            for value in array {
                if let canBind = canBindValue(from: value) {
                    return canBind
                }
            }
        }

        return nil
    }

    private func boolFromCanBindValue(_ value: Any) -> Bool? {
        if let boolValue = value as? Bool {
            return boolValue
        }
        if let intValue = value as? Int {
            return intValue == 1
        }
        if let numberValue = value as? NSNumber {
            return numberValue.intValue == 1
        }
        if let stringValue = value as? String {
            let normalizedValue = stringValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if normalizedValue == "1" || normalizedValue == "true" {
                return true
            }
            if normalizedValue == "0" || normalizedValue == "false" {
                return false
            }
        }
        return nil
    }

    private func isBoundToOtherAccountResponse(_ responseObject: [AnyHashable: Any],
                                               decodedData: Any?) -> Bool {
        let code = responseObject["code"] as? Int ?? -1
        if code == 409 || code == 100409 || code == 4009 {
            return true
        }

        var searchableTexts: [String] = []
        if let message = responseObject["message"] as? String {
            searchableTexts.append(message)
        }
        if let msg = responseObject["msg"] as? String {
            searchableTexts.append(msg)
        }
        collectStringValues(from: decodedData).forEach { searchableTexts.append($0) }

        return searchableTexts.contains { text in
            let lowercasedText = text.lowercased()
            return text.contains("其他账号") ||
                text.contains("其它账号") ||
                text.contains("其他用户") ||
                text.contains("其它用户") ||
                text.contains("已绑定") && (text.contains("账号") || text.contains("用户")) ||
                lowercasedText.contains("other account") ||
                lowercasedText.contains("another account") ||
                lowercasedText.contains("bound to")
        }
    }

    private func collectStringValues(from object: Any?) -> [String] {
        if let text = object as? String {
            return [text]
        }
        if let dictionary = object as? [String: Any] {
            return dictionary.values.flatMap { collectStringValues(from: $0) }
        }
        if let dictionary = object as? NSDictionary {
            return dictionary.allValues.flatMap { collectStringValues(from: $0) }
        }
        if let array = object as? [Any] {
            return array.flatMap { collectStringValues(from: $0) }
        }
        if let array = object as? NSArray {
            return array.compactMap { $0 }.flatMap { collectStringValues(from: $0) }
        }
        return []
    }

    private func resolveQueryBizType(_ queryBizType: String,
                                     defaultType: PurchaseQueryBizType) -> String {
        let trimmedBizType = queryBizType.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let type = PurchaseQueryBizType(rawValue: trimmedBizType) else {
            return defaultType.rawValue
        }
        return type.rawValue
    }

    private func resolvePendingPurchaseQueryBizType(transactionID: String,
                                                    fallbackQueryBizType: String) -> String {
        let fallback = resolveQueryBizType(fallbackQueryBizType, defaultType: .pendingBind)
        guard let payload = readPendingVerifyPayload() else { return fallback }

        let payloadTransactionID = stringValue(from: payload["transactionId"])
        guard payloadTransactionID.isEmpty || payloadTransactionID == transactionID else {
            return fallback
        }

        let payloadBizType = stringValue(from: payload["bizType"])
        return resolveQueryBizType(payloadBizType,
                                   defaultType: PurchaseQueryBizType(rawValue: fallback) ?? .pendingBind)
    }

    private func dictionaryFromJSONString(_ json: String) -> [String: Any]? {
        guard let data = json.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data),
              let dictionary = object as? [String: Any] else {
            return nil
        }
        return dictionary
    }

    private func stringValue(from value: Any?) -> String {
        if let string = value as? String {
            return string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let number = value as? NSNumber {
            return number.stringValue
        }
        return ""
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

    private func clearPendingPurchaseLocalState(defaults: UserDefaults, shouldNotify: Bool) {
        clearPendingTransactionIDCache(defaults: defaults)
        defaults.removeObject(forKey: LocalUnlockKeys.pendingVerifyPayload)
        clearPendingVerifyPayloadKeychainCache()
        clearLocalUnlock(defaults: defaults, shouldNotify: shouldNotify)
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

    private func clearPendingVerifyPayloadKeychainCache() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainKeys.pendingTransactionService,
            kSecAttrAccount as String: KeychainKeys.pendingPayloadAccount
        ]
        SecItemDelete(query as CFDictionary)
    }

    private func configuredRefundProductIDs() -> [String] {
        let currentProductIDs = [
            ElaProIAPConfig.monthProductID,
            ElaProIAPConfig.annualProductID,
            ElaProIAPConfig.lifetimeProductID
        ].map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return Array(Set(currentProductIDs).union(ElaProIAPConfig.knownSubscriptionProductIDs)).sorted()
    }

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

    private func startObservingTransactionUpdates() {
        transactionUpdatesTask?.cancel()
        transactionUpdatesTask = Task.detached(priority: .background) { [weak self] in
            guard let self else { return }
            for await update in Transaction.updates {
                switch update {
                case .verified(let transaction):
                    self.logAppleTransaction(transaction, source: "Transaction.updates verified")
                    var payload: [String: Any] = [
                        "productID": transaction.productID,
                        "transactionID": String(transaction.id),
                        "originalTransactionID": String(transaction.originalID)
                    ]
                    if let revocationDate = transaction.revocationDate {
                        payload["revocationDate"] = revocationDate.timeIntervalSince1970
                    }
                    self.appendRefundDebugLog("StoreKit2 收到交易更新", payload: payload)
                    self.handleTransactionUpdateSideEffects(transaction)
                case .unverified(let transaction, let error):
                    DLLog(message: [
                        "tag": "[ElaProIAP][APPLE_TRANSACTION] Transaction.updates unverified",
                        "error": error.localizedDescription,
                        "transaction": self.appleTransactionLogPayload(transaction)
                    ])
                    self.appendRefundDebugLog("StoreKit2 收到未校验交易更新", payload: [
                        "productID": transaction.productID,
                        "transactionID": String(transaction.id),
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }

    private func handleTransactionUpdateSideEffects(_ transaction: Transaction) {
        guard configuredIAPProductIDs().contains(transaction.productID) else {
            return
        }

        guard transaction.revocationDate != nil else {
            return
        }

        let defaults = UserDefaults.standard
        let cachedTransactionID = defaults.string(forKey: LocalUnlockKeys.transactionID)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let shouldNotify = defaults.bool(forKey: LocalUnlockKeys.isUnlocked) &&
            (cachedTransactionID.isEmpty || cachedTransactionID == String(transaction.id))

        clearLocalUnlock(defaults: defaults, shouldNotify: shouldNotify)
        appendRefundDebugLog("检测到 Apple 退款/撤销交易，本地临时权益已撤销", payload: refundTransactionPayload(transaction))
        NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_VIP_STATUS, object: nil)
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

    private func logAppleTransaction(_ transaction: Transaction, source: String) {
        DLLog(message: [
            "tag": "[ElaProIAP][APPLE_TRANSACTION]",
            "source": source,
            "transaction": appleTransactionLogPayload(transaction)
        ])
        appendRefundDebugLog("Apple 返回交易信息", payload: [
            "source": source,
            "transaction": appleTransactionLogPayload(transaction)
        ])
    }

    private func appleTransactionLogPayload(_ transaction: Transaction) -> [String: Any] {
        var payload: [String: Any] = [
            "productID": transaction.productID,
            "transactionID": String(transaction.id),
            "originalTransactionID": String(transaction.originalID),
            "purchaseDate": transaction.purchaseDate.timeIntervalSince1970,
            "originalPurchaseDate": transaction.originalPurchaseDate.timeIntervalSince1970,
            "isUpgraded": transaction.isUpgraded,
            "appAccountToken": transaction.appAccountToken?.uuidString.lowercased() ?? ""
        ]
        if let expirationDate = transaction.expirationDate {
            payload["expirationDate"] = expirationDate.timeIntervalSince1970
        }
        if let revocationDate = transaction.revocationDate {
            payload["revocationDate"] = revocationDate.timeIntervalSince1970
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

    private func logProductInfo(_ product: Product, source: String) {
        var lines: [String] = []
        lines.append("[ElaProIAP][\(source)] 拉取成功")
        lines.append("productId=\(product.id)")
        lines.append("price=\(product.displayPrice)")
        lines.append("subscriptionPeriod=\(periodDebugText(product.subscription?.subscriptionPeriod))")
        DLLog(message: lines.joined(separator: " | "))
    }

    private func periodDebugText(_ period: Product.SubscriptionPeriod?) -> String {
        guard let period else { return "<none>" }

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

        return "\(period.value) \(unitText)"
    }

    private func deviceInstallID() -> String {
        let defaults = UserDefaults.standard
        if let cached = defaults.string(forKey: LocalUnlockKeys.deviceInstallID),
           !cached.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return cached
        }
        let generated = UUID().uuidString.lowercased()
        defaults.set(generated, forKey: LocalUnlockKeys.deviceInstallID)
        return generated
    }

    private func appVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    private func appBuild() -> String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
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

enum ElaProRefundDebugError: LocalizedError {
    case noConfiguredProductID
    case noRefundableTransaction([String])
    case userCancelled
    case unknown(String)

    var errorDescription: String? {
        switch self {
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
