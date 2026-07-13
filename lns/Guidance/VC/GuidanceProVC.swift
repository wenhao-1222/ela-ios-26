//
//  GuidanceProVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/19.
//

import UIKit
import SnapKit
import MCToast
import UserNotifications

class GuidanceProVC: WHBaseViewVC {

    enum ContentStep {
        case intro
        case trial
        case promise
        case subscribe
    }

    enum TransitionDirection {
        case forward
        case backward
    }

    var nextBlock: (() -> Void)?

    private let topBackgroundView = GuidanceProFlowBackgroundView()
    private let contentContainerView = UIView()
    private let topContentVM = GuidanceProTopVM()
    private let dietRecordContentVM = GuidanceProDietRecordVM()
    private let trialContentVM = GuidanceProTrialVM()
    private let promiseContentVM = GuidanceProPromiseVM()
    private let subscribeContentVM = GuidanceProSubscribeTimelineVM()
    private var currentStep: ContentStep = .intro
    private var isPurchasing = false
    private var isRequestingNotificationPermission = false
    private var isContentTransitionAnimating = false
    private var isSwipeBackInteractionInProgress = false
    private var swipeBackStartStep: ContentStep?
    var hasFreeTrialPermission = true
    var guidanceV2BizType = "自动"
    private var didTrackGuidanceV2IntroPage = false
    private var didTrackGuidanceV2SubscribePage = false
    private var shouldUseDietRecordIntro: Bool {
        UserInfoModel.shared.abTestModel.diet_important == .B
    }
    private var introContentVM: UIView {
        shouldUseDietRecordIntro ? dietRecordContentVM : topContentVM
    }

    private lazy var contentSwipeBackPanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleContentSwipeBackPan(_:)))
        gesture.maximumNumberOfTouches = 1
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        return gesture
    }()
    
    lazy var backButton: UIButton = {
        let img = UIButton.init(type: .custom)
        img.frame = CGRect.init(x: kFitWidth(12.5), y: statusBarHeight+kFitWidth(5), width: kFitWidth(35), height: kFitWidth(35))
        img.alpha = 0
        img.setImage(UIImage(named: "habit_guide_back_icon"), for: .normal)
        img.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        
        return img
    }()
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        button.layer.cornerRadius = kFitWidth(24)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        VIPModel.shared.updateSubscriptionBizType("1")
        initUI()
        
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is GuidanceVC }){
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enforceFullscreenPopGestureDisabled()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enforceFullscreenPopGestureDisabled()
        trackGuidanceV2IntroPageIfNeeded()
//        topBackgroundView.startAnimatingIfNeeded()
//        if currentStep == .intro {
//            topContentVM.startBubbleFloatingAnimationIfNeeded()
//        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        restoreFullscreenInteractivePopGesture()
//        topBackgroundView.pauseAnimating()
        topContentVM.stopBubbleFloatingAnimation()
    }
}
extension GuidanceProVC {
    func initUI() {
        view.backgroundColor = .COLOR_BG_WHITE
        navigationController?.view.backgroundColor = .COLOR_BG_WHITE
        addELAFlowingBackground()
        
//        view.addSubview(topBackgroundView)
        view.addSubview(contentContainerView)
        view.addSubview(backButton)
        view.addSubview(nextButton)
        contentContainerView.addGestureRecognizer(contentSwipeBackPanGesture)

        contentContainerView.addSubview(topContentVM)
        contentContainerView.addSubview(dietRecordContentVM)
        contentContainerView.addSubview(trialContentVM)
        contentContainerView.addSubview(promiseContentVM)
        view.addSubview(subscribeContentVM)

//        topBackgroundView.snp.makeConstraints { make in
//            make.left.right.top.equalToSuperview()
//            make.height.equalTo(SCREEN_HEIGHT * 0.46)
//        }

        contentContainerView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
//            make.top.equalTo(statusBarHeight)
//            make.top.equalTo(kFitWidth(126) + statusBarHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        topContentVM.snp.makeConstraints { make in
//            make.left.right.top.equalToSuperview()
//            make.height.equalTo(kFitWidth(434))
            make.edges.equalToSuperview()
        }
        dietRecordContentVM.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        trialContentVM.snp.makeConstraints { make in
//            make.left.right.top.equalToSuperview()
//            make.height.equalTo(kFitWidth(520))
            make.edges.equalToSuperview()
        }

        promiseContentVM.snp.makeConstraints { make in
//            make.left.right.top.equalToSuperview()
//            make.height.equalTo(kFitWidth(520))
            make.edges.equalToSuperview()
        }

        subscribeContentVM.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

//        nextButton.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(20))
//            make.right.equalTo(kFitWidth(-20))
//            make.height.equalTo(kFitWidth(44))
//            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-kFitWidth(22))
//        }
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(50))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }

        subscribeContentVM.startTrialTapBlock = { [weak self] in
            self?.startSubscriptionFlow()
        }
        subscribeContentVM.updateFreeTrialPermission(hasFreeTrialPermission)
        fetchAnnualDisplayProduct()

        topContentVM.isHidden = shouldUseDietRecordIntro
        topContentVM.alpha = shouldUseDietRecordIntro ? 0 : 1
        dietRecordContentVM.isHidden = !shouldUseDietRecordIntro
        dietRecordContentVM.alpha = shouldUseDietRecordIntro ? 1 : 0
        dietRecordContentVM.nextButton.isHidden = true
        trialContentVM.isHidden = true
        trialContentVM.alpha = 0
        promiseContentVM.isHidden = true
        promiseContentVM.alpha = 0
        subscribeContentVM.isHidden = true
        subscribeContentVM.alpha = 0
        
        subscribeContentVM.closeTapBlock = { [weak self] in
            guard let self = self, !self.isPurchasing else { return }
            self.nextBlock?()
        }

        updateBackButtonVisibility(animated: false)
        updateNextButtonInteractionState()
    }

    @objc func nextButtonTapAction() {
        guard canRespondToNextButton else { return }
        switch currentStep {
        case .intro:
            if hasFreeTrialPermission {
                showTrialContent()
            } else {
                showSubscribeContent()
            }
        case .trial:
            showPromiseContent()
        case .promise:
            requestNotificationPermissionBeforeSubscribeIfNeeded()
        case .subscribe:
            nextBlock?()
        }
    }

    @objc func backAction() {
        guard !isPurchasing, !isContentTransitionAnimating, !isSwipeBackInteractionInProgress else { return }
        showPreviousContent()
    }

    func showTrialContent() {
        guard hasFreeTrialPermission else {
            showSubscribeContent()
            return
        }
        guard currentStep == .intro else { return }

        currentStep = .trial
        topContentVM.stopBubbleFloatingAnimation()
        nextButton.isHidden = false
        updateNextButtonInteractionState()
        updateBackButtonVisibility(animated: true)
        transition(from: introContentVM, to: trialContentVM, direction: .forward)
    }

    func showPromiseContent() {
        guard currentStep == .trial else { return }

        currentStep = .promise
        nextButton.isHidden = false
        updateNextButtonInteractionState()
        updateBackButtonVisibility(animated: true)
        transition(from: trialContentVM, to: promiseContentVM, direction: .forward)
    }

    func showSubscribeContent() {
        let previousStep = currentStep
        guard previousStep == .promise || previousStep == .intro else { return }

        currentStep = .subscribe
        nextButton.isHidden = true
        updateNextButtonInteractionState()
        topContentVM.stopBubbleFloatingAnimation()
        updateBackButtonVisibility(animated: true)

        if !hasFreeTrialPermission && !trialContentVM.isHidden {
            trialContentVM.isHidden = true
            trialContentVM.alpha = 0
        }

        if !hasFreeTrialPermission && !promiseContentVM.isHidden {
            promiseContentVM.isHidden = true
            promiseContentVM.alpha = 0
        }

        let fromView = previousStep == .promise ? promiseContentVM : introContentVM
        transition(from: fromView, to: subscribeContentVM, direction: .forward)
        trackGuidanceV2SubscribePageIfNeeded()
    }

    func showPreviousContent() {
        guard let previousStep = previousStep(for: currentStep) else { return }

        let fromView = view(for: currentStep)
        let toView = view(for: previousStep)

        currentStep = previousStep
        nextButton.isHidden = false
        updateNextButtonInteractionState()
        updateBackButtonVisibility(animated: true)
        transition(from: fromView, to: toView, direction: .backward)
    }

    func previousStep(for step: ContentStep) -> ContentStep? {
        switch step {
        case .intro:
            return nil
        case .trial:
            return .intro
        case .promise:
            return .trial
        case .subscribe:
            return hasFreeTrialPermission ? .promise : .intro
        }
    }

    func view(for step: ContentStep) -> UIView {
        switch step {
        case .intro:
            return introContentVM
        case .trial:
            return trialContentVM
        case .promise:
            return promiseContentVM
        case .subscribe:
            return subscribeContentVM
        }
    }

    func updateBackButtonVisibility(animated: Bool) {
        let shouldShow = currentStep == .trial || currentStep == .promise
        backButton.isUserInteractionEnabled = shouldShow && !isContentTransitionAnimating && !isSwipeBackInteractionInProgress

        if animated == false {
            backButton.isHidden = !shouldShow
            backButton.alpha = shouldShow ? 1 : 0
            return
        }

        if shouldShow {
            backButton.isHidden = false
            UIView.animate(
                withDuration: 0.22,
                delay: 0,
                options: [.curveEaseInOut, .beginFromCurrentState]
            ) {
                self.backButton.alpha = 1
            }
            return
        }

        guard backButton.isHidden == false else {
            backButton.alpha = 0
            return
        }

        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState]
        ) {
            self.backButton.alpha = 0
        } completion: { _ in
            self.backButton.isHidden = true
        }
    }

    func transition(from currentView: UIView, to nextView: UIView, direction: TransitionDirection) {
        isContentTransitionAnimating = true
        updateNextButtonInteractionState()
        backButton.isUserInteractionEnabled = false
        let offset = kFitWidth(28)
        let nextTranslationX = direction == .forward ? offset : -offset
        let currentTranslationX = direction == .forward ? -offset : offset

        nextView.isHidden = false
        nextView.alpha = 0
        nextView.transform = CGAffineTransform(translationX: nextTranslationX, y: 0)

//        UIView.animate(
//            withDuration: 0.15,
//            delay: 0,
//            options: [.curveEaseInOut, .beginFromCurrentState]
//        ) {
//            currentView.alpha = 0
//            currentView.transform = CGAffineTransform(translationX: currentTranslationX, y: 0)
//        } completion: { _ in
//            currentView.isHidden = true
//            currentView.alpha = 1
//            currentView.transform = .identity
//        }
        
        UIView.animate(
            withDuration: 0.32,
            delay: 0.05,
            options: [.curveEaseInOut, .beginFromCurrentState]
        ) {
            currentView.alpha = 0
            currentView.transform = CGAffineTransform(translationX: currentTranslationX, y: 0)
            nextView.alpha = 1
            nextView.transform = .identity
        } completion: { _ in
            currentView.isHidden = true
//            currentView.alpha = 1
            currentView.transform = .identity
            self.isContentTransitionAnimating = false
            self.updateNextButtonInteractionState()
            self.updateBackButtonVisibility(animated: true)
        }
    }

    private var canRespondToNextButton: Bool {
        !isPurchasing && !isRequestingNotificationPermission && !isContentTransitionAnimating && !isSwipeBackInteractionInProgress
    }

    private var canSwipeBackCurrentStep: Bool {
        currentStep == .trial || currentStep == .promise
    }

    private func updateNextButtonInteractionState() {
        updateNextButtonTitle()
        nextButton.isUserInteractionEnabled = !nextButton.isHidden && canRespondToNextButton
    }

    private func updateNextButtonTitle() {
        let title = currentStep == .promise ? "开始免费试用" : "下一步"
        nextButton.setTitle(title, for: .normal)
    }

    private func disableFullscreenPopGesture() {
        navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        canEdgeBack = false
        fd_forceDisableInteractivePopGesture = true
        fd_interactivePopDisabled = true
        navigationController?.fd_interactivePopDisabled = true
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    private func enforceFullscreenPopGestureDisabled() {
        disableFullscreenPopGesture()
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  self.navigationController?.topViewController === self else {
                return
            }
            self.disableFullscreenPopGesture()
        }
    }

    @objc private func handleContentSwipeBackPan(_ gesture: UIPanGestureRecognizer) {
        let translationX = max(gesture.translation(in: contentContainerView).x, 0)
        let progress = min(translationX / max(SCREEN_WIDHT, 1), 1)

        switch gesture.state {
        case .began:
            guard canSwipeBackCurrentStep,
                  !isPurchasing,
                  !isContentTransitionAnimating,
                  !isSwipeBackInteractionInProgress,
                  let previousStep = previousStep(for: currentStep) else {
                return
            }
            swipeBackStartStep = currentStep
            isSwipeBackInteractionInProgress = true
            disableFullscreenPopGesture()
            updateNextButtonInteractionState()
            updateBackButtonVisibility(animated: false)

            let currentView = view(for: currentStep)
            let previousView = view(for: previousStep)
            previousView.isHidden = false
            previousView.alpha = 0
            previousView.transform = CGAffineTransform(translationX: -kFitWidth(28), y: 0)
            contentContainerView.bringSubviewToFront(currentView)

        case .changed:
            guard let startStep = swipeBackStartStep,
                  let previousStep = previousStep(for: startStep) else {
                return
            }
            let currentView = view(for: startStep)
            let previousView = view(for: previousStep)
            currentView.transform = CGAffineTransform(translationX: translationX, y: 0)
            currentView.alpha = 1 - progress
            previousView.alpha = progress
            previousView.transform = CGAffineTransform(translationX: -kFitWidth(28) * (1 - progress), y: 0)

        case .ended, .cancelled, .failed:
            guard let startStep = swipeBackStartStep,
                  let previousStep = previousStep(for: startStep) else {
                finishSwipeBackInteraction()
                return
            }
            let velocityX = gesture.velocity(in: contentContainerView).x
            let shouldComplete = gesture.state == .ended && (velocityX > 260 || progress > 0.35)
            finishSwipeBack(from: startStep, to: previousStep, shouldComplete: shouldComplete)

        default:
            break
        }
    }

    private func finishSwipeBack(from startStep: ContentStep,
                                 to previousStep: ContentStep,
                                 shouldComplete: Bool) {
        let currentView = view(for: startStep)
        let previousView = view(for: previousStep)

        UIView.animate(
            withDuration: 0.24,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState]
        ) {
            if shouldComplete {
                currentView.transform = CGAffineTransform(translationX: SCREEN_WIDHT, y: 0)
                currentView.alpha = 0
                previousView.transform = .identity
                previousView.alpha = 1
            } else {
                currentView.transform = .identity
                currentView.alpha = 1
                previousView.transform = CGAffineTransform(translationX: -kFitWidth(28), y: 0)
                previousView.alpha = 0
            }
        } completion: { _ in
            if shouldComplete {
                self.currentStep = previousStep
                currentView.isHidden = true
                currentView.transform = .identity
                currentView.alpha = 0
                previousView.isHidden = false
                previousView.transform = .identity
                previousView.alpha = 1
            } else {
                previousView.isHidden = true
                previousView.transform = .identity
                previousView.alpha = 1
                currentView.isHidden = false
                currentView.transform = .identity
                currentView.alpha = 1
            }
            self.finishSwipeBackInteraction()
        }
    }

    private func finishSwipeBackInteraction() {
        swipeBackStartStep = nil
        isSwipeBackInteractionInProgress = false
        nextButton.isHidden = currentStep == .subscribe
        updateNextButtonInteractionState()
        updateBackButtonVisibility(animated: true)
        disableFullscreenPopGesture()
    }

    func fetchAnnualDisplayProduct() {
        let parameters: [String: AnyObject] = [
            "bizType": "1" as NSString,
            "isPurchased": "0" as NSString
        ]
        WHNetworkUtil.shareManager().POST(urlString: URL_pro_product,
                                          parameters: parameters,
                                          success: { [weak self] responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            let productDict = self?.guidanceTrialAnnualProduct(from: dataDict)
            DispatchQueue.main.async {
                guard let self = self, let productDict = productDict else { return }
                self.subscribeContentVM.updateAnnualProductInfo(productDict)
            }
        }, failure: { _ in
//            ElaProIAPManager.shared.fetchGuidanceAnnualProduct { [weak self] result in
//                DispatchQueue.main.async {
//                    guard let self = self else { return }
//                    guard case .success(let product) = result else { return }
//                    self.subscribeContentVM.updateAnnualProduct(product)
//                }
//            }
        })
    }

    private func guidanceTrialAnnualProduct(from dataDict: NSDictionary) -> NSDictionary? {
        let rawProducts = (dataDict["productInfoList"] as? NSArray) ?? (dataDict["product"] as? NSArray) ?? []
        let products = rawProducts.compactMap { $0 as? NSDictionary }
        if let trialAnnual = products.first(where: { dict in
            let productType = Int(dict.stringValueForKey(key: "productType")) ?? Int(dict.stringValueForKey(key: "type")) ?? -1
            return productType == 0
        }) {
            return trialAnnual
        }
        if let guidanceAnnual = products.first(where: { $0.stringValueForKey(key: "productId") == ElaProIAPConfig.guidanceAnnualProductID }) {
            return guidanceAnnual
        }
        if let trialProduct = products.first(where: { $0.stringValueForKey(key: "productName").contains("试用") }) {
            return trialProduct
        }
        return products.first(where: { dict in
            let productType = Int(dict.stringValueForKey(key: "productType")) ?? Int(dict.stringValueForKey(key: "type")) ?? -1
            return productType == 2
        })
    }

    func startSubscriptionFlow() {
        guard !isPurchasing else { return }

        isPurchasing = true
        subscribeContentVM.setLoading(true)

        ElaProIAPManager.shared.checkGuidanceAnnualIntroOfferEligibility { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(true):
                self.purchaseGuidanceAnnual()
            case .success(false), .failure:
                self.isPurchasing = false
                self.subscribeContentVM.setLoading(false)
                self.showIntroOfferUnavailableConfirmAlert()
            }
        }
    }

    private func purchaseGuidanceAnnual() {
        ElaProIAPManager.shared.purchaseGuidanceAnnual { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let transaction):
                    ElaProIAPManager.shared.handlePurchaseSuccessPostAction(transaction: transaction, queryBizType: "1") { outcome in
                        DispatchQueue.main.async {
                            self.isPurchasing = false
                            self.subscribeContentVM.setLoading(false)
                            switch outcome {
                            case .activated:
                                MCToast.mc_text("订阅成功")
                                self.nextBlock?()
                            case .boundToOtherAccount:
                                self.showIAPBoundToOtherAccountAlert()
                            case .pendingLoginBind:
                                MCToast.mc_text("支付成功，请登录后领取会员")
                                self.nextBlock?()
                            case .pendingServerSync:
                                MCToast.mc_text("支付成功，正在同步订单，请登录后查看会员状态")
                                self.nextBlock?()
                            }
                        }
                    }
                case .failure(let error):
                    self.isPurchasing = false
                    self.subscribeContentVM.setLoading(false)
                    if let iapError = error as? ElaProIAPError {
                        MCToast.mc_text(iapError.localizedDescription)
                    } else {
                        MCToast.mc_text(error.localizedDescription)
                    }
                }
            }
        }
    }

    private func showIntroOfferUnavailableConfirmAlert() {
        guard !(presentedViewController is UIAlertController) else { return }
        let alert = UIAlertController(title: "订阅确认",
                                      message: "当前 Apple 账号可能暂不可领取免费试用，请以 App Store 确认页显示的价格为准。是否继续？",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "继续", style: .default) { [weak self] _ in
            guard let self = self, !self.isPurchasing else { return }
            self.isPurchasing = true
            self.subscribeContentVM.setLoading(true)
            self.purchaseGuidanceAnnual()
        })
        present(alert, animated: true)
    }

    private func showIAPBoundToOtherAccountAlert() {
        guard !(presentedViewController is UIAlertController) else { return }
        let alert = UIAlertController(title: "该APPLE账户订阅已绑定其他账号",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }

    func trackGuidanceV2IntroPageIfNeeded() {
        guard !didTrackGuidanceV2IntroPage else { return }
        didTrackGuidanceV2IntroPage = true
        EventLogUtils().sendGuidanceV2PageView(
            pageIndex: guidanceV2BizType == "手动" ? "18" : "27",
            pageTitle: "ela给你完整支持",
            bizType: guidanceV2BizType
        )
    }

    func trackGuidanceV2SubscribePageIfNeeded() {
        guard !didTrackGuidanceV2SubscribePage else { return }
        didTrackGuidanceV2SubscribePage = true
        EventLogUtils().sendGuidanceV2PageView(
            pageIndex: guidanceV2BizType == "手动" ? "19" : "28",
            pageTitle: "付费墙",
            bizType: guidanceV2BizType
        )
        EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW, scenarioType: .ela_pro_view, text: "1")
    }

    private func requestNotificationPermissionBeforeSubscribeIfNeeded() {
        guard !isRequestingNotificationPermission else { return }
        isRequestingNotificationPermission = true
        updateNextButtonInteractionState()

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self = self else { return }

            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                    DispatchQueue.main.async {
                        self.isRequestingNotificationPermission = false
                        self.updateNextButtonInteractionState()
                        self.showSubscribeContent()
                    }
                }
            case .authorized, .provisional, .ephemeral, .denied:
                DispatchQueue.main.async {
                    self.isRequestingNotificationPermission = false
                    self.updateNextButtonInteractionState()
                    self.showSubscribeContent()
                }
            @unknown default:
                DispatchQueue.main.async {
                    self.isRequestingNotificationPermission = false
                    self.updateNextButtonInteractionState()
                    self.showSubscribeContent()
                }
            }
        }
    }
}

extension GuidanceProVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === contentSwipeBackPanGesture,
              canSwipeBackCurrentStep,
              !isPurchasing,
              !isContentTransitionAnimating,
              !isSwipeBackInteractionInProgress,
              let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        let velocity = panGesture.velocity(in: contentContainerView)
        let translation = panGesture.translation(in: contentContainerView)
        let isHorizontal = abs(velocity.x) > abs(velocity.y) || abs(translation.x) > abs(translation.y)
        return isHorizontal && (velocity.x > 0 || translation.x > 0)
    }
}
