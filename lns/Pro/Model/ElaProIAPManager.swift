//
//  ElaProIAPManager.swift
//  lns
//
//  Created by LNS2 on 2026/3/3.
//

import Foundation
import StoreKit

enum ElaProIAPConfig {
    // App Store Connect: 订阅群组「Pro」，订阅群组 ID「21956560」
    static let subscriptionGroupName = "Pro"
    static let subscriptionGroupID = "21956560"
    static let annualProductID = "annual"
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
    
    private var productsRequest: SKProductsRequest?
    private var cachedProducts: [String: SKProduct] = [:]
    private var fetchCompletions: [(Result<[SKProduct], Error>) -> Void] = []
    
    private var purchaseCompletion: ((Result<SKPaymentTransaction, Error>) -> Void)?
    private var purchasingProductID: String?
    private var isObservingQueue = false
    
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
    
    func localizedPriceString(for product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? "\(product.price)"
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

