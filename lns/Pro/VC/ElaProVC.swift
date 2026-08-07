//
//  ElaProVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/3.
//

import MCToast

class ElaProVC: WHBaseViewVC {
    private enum ProIapStatusState {
        case idle
        case loading
        case subscribable
        case unsubscribable(message: String)
    }

    private var currentIndex: Int = 0
    private var isBackButtonCoolingDown = false
    private var isCreatingPendingDietPlan = false
    private var isStepScrollAnimating = false
    private var scrollDragStartIndex: Int?
    private var proIapStatusState: ProIapStatusState = .idle
    private var shouldProceedPurchaseAfterIapStatusLoaded = false
    
    var param = [String : Any]()
    var showPriceOnly = false
    var priceBizType = "3"
    var priceDisplayMode: ElaProPriceVM.DisplayMode = .default
    var popToRootOnClose = false
    var enterAICoachPreOnClose = false
    var enterAICoachPreOnPurchaseSuccess = false
    var shouldClearDietPlanCreateDraftOnPurchaseSuccess = false
    var shouldShowDietPlanNoneStateOnPurchaseSuccess = false
    var shouldTrackDietPlanCreateLoadingPage = false
    var shouldReturnToDietPlanSecondOnClose = false
    var pendingDietPlanCreateParameters: [String: Any]?
    private var hasTrackedDietPlanCreateLoadingPage = false
    private var agreementAlertVm: ElaProAgreementAlertVM?
    private var purchaseConfirmAlertVm: GuidanceProPurchasedConfirmAlertVM?
    
    lazy var purchaseLoadingMaskView: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        vi.isUserInteractionEnabled = true
        vi.isHidden = true
        return vi
    }()
    lazy var purchaseLoadingIndicator: UIActivityIndicatorView = {
        let vi = UIActivityIndicatorView(style: .large)
        vi.color = .white
        vi.hidesWhenStopped = false
        return vi
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VIPModel.shared.updateSubscriptionBizType(priceBizType)
        initUI()
        applyInitialDisplayMode()
        updateScrollBackGestureState()
        requestProIapStatusIfNeeded(showLoading: false)
        priceVm.startLoadingIfNeeded()
//        
//        if showPriceOnly == false {
//            self.sendDietUpsertRequest()
//        }
        
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is DietPlanCreateVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }else if let index = controllers.firstIndex(where: { $0 is DietPlanCreateSecondVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
        
        EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW, scenarioType: .ela_pro_view, text: priceBizType)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateScrollBackGestureState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateScrollBackGestureState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreFullscreenInteractivePopGesture()
    }
    
    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
//        vm.alpha = 0
        vm.firstStepVm.isHidden = true
        vm.secondStepVm.isHidden = true
        vm.thirdStepVm.isHidden = true
        vm.backTapBlock = {[weak self] in
            guard let self = self else { return }
            guard !self.isBackButtonCoolingDown else { return }
            self.startBackButtonCooldown()
//            self.handleCloseAction()
            if self.currentIndex == 0 || self.currentIndex == 4 {
                self.handleCloseAction()
                return
            }
            self.showPreviousContentStep()
        }
        return vm
    }()
    
    lazy var progressVm: ElaProProgressVM = {
        let vm = ElaProProgressVM.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        vm.progressCompleteBlock = {[weak self] in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                guard self.currentIndex == 0 else { return }
                self.currentIndex = 1
                UIView.animate(withDuration: 0.35, delay: 0) {
                    self.naviVm.alpha = 0
                }
                self.scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT, y: 0), animated: true)
                self.updateNextButtonForCurrentStep(animated: true)
            }
        }
        return vm
    }()
    
    lazy var planVm: ElaProPlanVM = {
        let vm = ElaProPlanVM.init(frame: CGRect(x: SCREEN_WIDHT, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var readyVm: ElaProReadyVM = {
        let vm = ElaProReadyVM.init(frame: CGRect(x: SCREEN_WIDHT*2, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var transformVm: ElaProTransformVM = {
        let vm = ElaProTransformVM.init(frame: CGRect(x: SCREEN_WIDHT*3, y: 0, width: 0, height: 0))
        return vm
    }()
    
    lazy var priceVm: ElaProPriceVM = {
        let vm = ElaProPriceVM.init(frame: CGRect(x: SCREEN_WIDHT * 4, y: 0, width: 0, height: 0))
        vm.bizType = self.priceBizType
        vm.purchaseQueryBizType = (self.priceBizType == "2" || self.priceBizType == "4") ? self.priceBizType : "3"
        vm.displayMode = self.priceDisplayMode
        vm.purchaseSuccessBlock = { [weak self] in
            self?.handlePurchaseSuccess()
        }
        vm.protocalTapBlock = { [weak self] in
            self?.showAgreementAlert()
        }
        vm.purchasePreConfirmBlock = { [weak self] in
            self?.handlePurchasePreConfirmAction()
        }
        vm.purchaseLoadingStateChangeBlock = { [weak self] visible in
            self?.setPurchaseLoadingVisible(visible)
        }
        return vm
    }()
    
    lazy var nextButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)
        return btn
    }()
}

extension ElaProVC{
    func startBackButtonCooldown() {
        isBackButtonCoolingDown = true
        naviVm.backButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            self.isBackButtonCoolingDown = false
            self.naviVm.backButton.isEnabled = true
        }
    }

    @objc func nextButtonTapAction() {
        guard !isStepScrollAnimating, !isScrollBackInteractionInProgress else { return }
        if currentIndex == 1 {
            currentIndex = 2
            showStep(for: currentIndex, animated: true)
        } else if currentIndex == 2 {
            handleReadyStepNextAction()
        } else if currentIndex == 3 {
            currentIndex = 4
            showStep(for: currentIndex, animated: true)
        }
    }

    private func handleReadyStepNextAction() {
        if VIPModel.shared.status == .valid {
            handleCloseAction()
            return
        }

        currentIndex = 3
        showStep(for: currentIndex, animated: true)
    }

    private func showPreviousContentStep() {
        let previousIndex = max(currentIndex - 1, 1)
        currentIndex = previousIndex
        showStep(for: currentIndex, animated: true)
    }

    private func showStep(for index: Int, animated: Bool) {
        updateNavigationStyle(for: index, animated: animated)
        
        self.naviVm.backButton.isHidden = currentIndex <= 1
        let targetOffset: CGPoint
        switch index {
        case 1:
            targetOffset = CGPoint(x: SCREEN_WIDHT, y: 0)
        case 2:
            targetOffset = CGPoint(x: SCREEN_WIDHT * 2, y: 0)
        case 3:
            targetOffset = CGPoint(x: SCREEN_WIDHT * 3, y: 0)
        case 4:
            targetOffset = CGPoint(x: SCREEN_WIDHT * 4, y: 0)
        default:
            targetOffset = .zero
        }

        prepareStepScrollTransition(to: targetOffset, animated: animated)
        scrollViewBase.setContentOffset(targetOffset, animated: animated)
        updateNextButtonForCurrentStep(animated: animated)
        if !isStepScrollAnimating {
            updateScrollBackGestureState()
        }
    }

    private var shouldAllowScrollBackForCurrentStep: Bool {
        currentIndex == 2 || currentIndex == 3
    }

    private var isScrollBackInteractionInProgress: Bool {
        scrollDragStartIndex != nil
    }

    private func updateScrollBackGestureState() {
        disableFullscreenPopGesture()
        scrollViewBase.isScrollEnabled = shouldAllowScrollBackForCurrentStep && !isStepScrollAnimating
    }

    private func disableFullscreenPopGesture() {
        updateInteractivePopGestureBlocked(true)
    }

    private func prepareStepScrollTransition(to targetOffset: CGPoint, animated: Bool) {
        isStepScrollAnimating = animated && abs(scrollViewBase.contentOffset.x - targetOffset.x) > 0.5
        if isStepScrollAnimating {
            disableFullscreenPopGesture()
            scrollViewBase.isScrollEnabled = false
        }
    }

    private func finishStepScrollTransitionIfNeeded() {
        guard isStepScrollAnimating else { return }
        isStepScrollAnimating = false
        updateNextButtonForCurrentStep(animated: false)
        updateScrollBackGestureState()
    }

    private func finishScrollBackDraggingIfNeeded() {
        guard scrollDragStartIndex != nil else { return }
        scrollDragStartIndex = nil
        isStepScrollAnimating = false
        scrollViewBase.setContentOffset(CGPoint(x: CGFloat(currentIndex) * SCREEN_WIDHT, y: 0), animated: false)
        updateNavigationStyle(for: currentIndex, animated: false)
        naviVm.backButton.isHidden = currentIndex <= 1
        updateNextButtonForCurrentStep(animated: false)
        updateScrollBackGestureState()
    }

    private func updateNavigationStyle(for index: Int, animated: Bool) {
        let leftFrame = CGRect.init(x: kFitWidth(12.5), y: statusBarHeight+kFitWidth(5), width: kFitWidth(35), height: kFitWidth(35))
        let rightFrame = CGRect.init(x: SCREEN_WIDHT - kFitWidth(12.5) - kFitWidth(35), y: statusBarHeight+kFitWidth(5), width: kFitWidth(35), height: kFitWidth(35))
        let navAlpha: CGFloat = (index == 0) ? 0 : 1

        let applyStaticStyle = {
            if index == 4 {
//                self.naviVm.backButton.setImage(UIImage(named: "navi_close_icon"), for: .normal)
                self.naviVm.backButton.setImage(UIImage(named: "ela_pro_close_icon"), for: .normal)
                self.naviVm.backButton.frame = rightFrame
            } else {
                self.naviVm.backButton.setImage(UIImage(named: "habit_guide_back_icon"), for: .normal)
                self.naviVm.backButton.frame = leftFrame
            }
            self.naviVm.alpha = navAlpha
        }

        if animated == false {
            applyStaticStyle()
            self.naviVm.backButton.alpha = 1
            return
        }

        if index == 4 {
            UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseIn]) {
                self.naviVm.backButton.alpha = 0
                self.naviVm.alpha = navAlpha
            } completion: { _ in
//                self.naviVm.backButton.setImage(UIImage(named: "navi_close_icon"), for: .normal)
                self.naviVm.backButton.setImage(UIImage(named: "ela_pro_close_icon"), for: .normal)
                self.naviVm.backButton.frame = rightFrame
                UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut]) {
                    self.naviVm.backButton.alpha = 1
                    self.naviVm.alpha = navAlpha
                }
            }
            return
        }

        applyStaticStyle()
        self.naviVm.backButton.alpha = 0
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut]) {
            self.naviVm.backButton.alpha = 1
            self.naviVm.alpha = navAlpha
        }
    }
    
    func updateNextButtonForCurrentStep(animated: Bool) {
        let shouldShow = (currentIndex == 1 || currentIndex == 2 || currentIndex == 3)
        let moveY = kFitWidth(90) + WHUtils().getBottomSafeAreaHeight()
        let targetTransform = shouldShow ? .identity : CGAffineTransform(translationX: 0, y: moveY)
        let targetAlpha: CGFloat = shouldShow ? 1 : 0
        let apply = {
            self.nextButton.transform = targetTransform
            self.nextButton.alpha = targetAlpha
        }
        nextButton.isUserInteractionEnabled = shouldShow && !isStepScrollAnimating && !isScrollBackInteractionInProgress
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                apply()
            }
        } else {
            apply()
        }
    }
    
    private func applyInitialDisplayMode() {
        if showPriceOnly {
            currentIndex = 4
            priceVm.isHidden = false
            priceVm.frame.origin.x = 0
            naviVm.alpha = 1
            naviVm.backButton.setImage(UIImage(named: "ela_pro_close_icon"), for: .normal)
//            naviVm.backButton.setImage(UIImage(named: "navi_close_icon"), for: .normal)
            naviVm.backButton.frame = CGRect.init(x: SCREEN_WIDHT - kFitWidth(12.5) - kFitWidth(35), y: statusBarHeight+kFitWidth(5), width: kFitWidth(35), height: kFitWidth(35))
            scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT, height: 0)
            scrollViewBase.setContentOffset(.zero, animated: false)
            updateNavigationStyle(for: currentIndex, animated: false)
            updateNextButtonForCurrentStep(animated: false)
            
            return
        }
        
        progressVm.isHidden = false
        sendDietPlanCreateLoadingPageViewIfNeeded()
        planVm.isHidden = false
        readyVm.isHidden = false
        transformVm.isHidden = false
        priceVm.isHidden = false
        updateNavigationStyle(for: currentIndex, animated: false)
    }
    
    func initUI() {
//        view.backgroundColor = .COLOR_BG_F2
        addELAFlowingBackground()
        view.addSubview(scrollViewBase)
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.showsHorizontalScrollIndicator = false
        scrollViewBase.isScrollEnabled = false
        scrollViewBase.bounces = false
        scrollViewBase.delegate = self
        scrollViewBase.backgroundColor = .clear
        view.addSubview(naviVm)
        view.addSubview(nextButton)
        view.addSubview(purchaseLoadingMaskView)
        purchaseLoadingMaskView.addSubview(purchaseLoadingIndicator)

        scrollViewBase.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        if showPriceOnly {
            scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT, height: 0)
            scrollViewBase.addSubview(priceVm)
        } else {
            scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT * 5, height: 0)
            scrollViewBase.addSubview(progressVm)
            scrollViewBase.addSubview(planVm)
            scrollViewBase.addSubview(readyVm)
            scrollViewBase.addSubview(transformVm)
            scrollViewBase.addSubview(priceVm)
        }
        
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }
        
        purchaseLoadingMaskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        purchaseLoadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        updateNextButtonForCurrentStep(animated: false)
    }
    
    private func showAgreementAlert() {
        let alertVm: ElaProAgreementAlertVM
        if let existing = agreementAlertVm {
            alertVm = existing
        } else {
            let created = ElaProAgreementAlertVM(frame: .zero)
            agreementAlertVm = created
            view.addSubview(created)
            alertVm = created
        }
        alertVm.showSelf()
    }
    
    private func setPurchaseLoadingVisible(_ visible: Bool) {
        purchaseLoadingMaskView.isHidden = !visible
        if visible {
            view.bringSubviewToFront(purchaseLoadingMaskView)
            purchaseLoadingIndicator.startAnimating()
        } else {
            purchaseLoadingIndicator.stopAnimating()
        }
    }
    
    private func handlePurchaseSuccess() {
        if shouldClearDietPlanCreateDraftOnPurchaseSuccess {
            DietPlanCreateVC.clearStoredDraftForCurrentUser()
        }
        if pendingDietPlanCreateParameters != nil {
            createPendingDietPlanAfterPurchaseSuccess()
            return
        }
        notifyDietPlanNoneStateAfterPurchaseSuccessIfNeeded()
        requestLatestVipInfo()
        NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_DIET_PLAN_STATUS, object: nil)
        if enterAICoachPreOnPurchaseSuccess {
            let vc = AICoachPreVC()
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        handleCloseAction()
    }

    private func notifyDietPlanNoneStateAfterPurchaseSuccessIfNeeded() {
        guard shouldShowDietPlanNoneStateOnPurchaseSuccess else { return }
        NotificationCenter.default.post(name: NOTIFI_NAME_DIET_PLAN_SHOW_NONE_PLAN_AFTER_PRO_SUCCESS, object: nil)
    }
    
    private func handleCloseAction() {
        if enterAICoachPreOnClose {
            let vc = AICoachPreVC()
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        if popToDietPlanSecondIfNeeded() {
            return
        }
        if popToRootOnClose {
            navigationController?.popToRootViewController(animated: true)
        } else {
            backTapAction()
        }
    }
    
    private func requestLatestVipInfo(completion: ((VIPModel) -> Void)? = nil,
                                      failure: (() -> Void)? = nil) {
        WHNetworkUtil.shareManager().POST(urlString: URL_pro_info, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            let vipModel = VIPModel.shared.update(with: dataDict)
            DLLog(message: "ElaProVC requestLatestVipInfo:\(dataDict)")
            DLLog(message: "ElaProVC requestLatestVipInfo model: uid=\(vipModel.uid), status=\(vipModel.status?.rawValue ?? 0), isLifetime=\(vipModel.isLifetime), expireTime=\(vipModel.expireTime)")
            NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_DIET_PLAN_STATUS, object: nil)
            completion?(vipModel)
        } failure: { _ in
            failure?()
        }
    }

    private func createPendingDietPlanAfterPurchaseSuccess() {
        guard !isCreatingPendingDietPlan else { return }
        isCreatingPendingDietPlan = true
        setPurchaseLoadingVisible(true)
        requestLatestVipInfo { [weak self] vipModel in
            guard let self = self else { return }
            guard vipModel.status == .valid else {
                self.handlePendingDietPlanCreateFailure(message: "会员状态同步中，请稍后重试")
                return
            }
            self.sendPendingDietPlanCreateRequest()
        } failure: { [weak self] in
            self?.handlePendingDietPlanCreateFailure(message: "会员状态同步失败，请稍后重试")
        }
    }

    private func sendPendingDietPlanCreateRequest() {
        guard let parameters = pendingDietPlanCreateParameters else {
            handlePendingDietPlanCreateFailure(message: "创建失败，请稍后重试")
            return
        }
        DLLog(message: "ElaProVC sendPendingDietPlanCreateRequest:\(parameters)")
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_create, parameters: parameters as [String : AnyObject]) { [weak self] responseObject in
            guard let self = self else { return }
            let code = responseObject["code"] as? Int ?? -1
            guard code == 200 else {
                let msg = responseObject["message"] as? String ?? "创建失败，请稍后重试"
                self.handlePendingDietPlanCreateFailure(message: msg)
                return
            }

            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "ElaProVC sendPendingDietPlanCreateRequest response:\(dataObj)")
            _ = LogsSQLiteManager.getInstance().applyDietPlanNutrientsTargets(dataObj["nutrientsTarget"] as? NSArray ?? [])
            self.refreshUserCenterAndLogsAfterDietPlanCreate()

            self.handlePendingDietPlanCreateSuccess()
        } failure: { [weak self] isError in
            guard let self = self else { return }
            self.handlePendingDietPlanCreateFailure(message: isError ? "创建失败，请稍后重试" : nil)
        }
    }

    private func handlePendingDietPlanCreateSuccess() {
        isCreatingPendingDietPlan = false
        pendingDietPlanCreateParameters = nil
        setPurchaseLoadingVisible(false)
        if popToDietPlanSecondIfNeeded() {
            NotificationCenter.default.post(name: NOTIFI_NAME_DIET_PLAN_CREATE_SUCCESS, object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dietPlan"), object: nil)
            return
        }
        navigationController?.tabBarController?.selectedIndex = 2
        navigationController?.popToRootViewController(animated: true)
        NotificationCenter.default.post(name: NOTIFI_NAME_DIET_PLAN_CREATE_SUCCESS, object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dietPlan"), object: nil)
    }

    private func handlePendingDietPlanCreateFailure(message: String?) {
        isCreatingPendingDietPlan = false
        setPurchaseLoadingVisible(false)
        if let message = message, !message.isEmpty {
            MCToast.mc_text(message)
        }
    }

    private func sendDietPlanCreateLoadingPageViewIfNeeded() {
        guard shouldTrackDietPlanCreateLoadingPage,
              !hasTrackedDietPlanCreateLoadingPage else {
            return
        }
        hasTrackedDietPlanCreateLoadingPage = true
        EventLogUtils().sendDietPlanCreatePageView(pageIndex: "19", pageTitle: "加载动画")
    }
}

private extension ElaProVC {
    func handlePurchasePreConfirmAction() {
        switch proIapStatusState {
        case .subscribable:
            showPurchaseConfirmAlert()
        case .unsubscribable(let message):
            MCToast.mc_text(message)
        case .loading:
            shouldProceedPurchaseAfterIapStatusLoaded = true
            MCToast.mc_loading()
        case .idle:
            shouldProceedPurchaseAfterIapStatusLoaded = true
            requestProIapStatusIfNeeded(showLoading: true)
        }
    }

    func requestProIapStatusIfNeeded(showLoading: Bool) {
        guard case .loading = proIapStatusState else {
            proIapStatusState = .loading
            if showLoading {
                MCToast.mc_loading()
            }
            fetchProIapStatus()
            return
        }

        if showLoading {
            MCToast.mc_loading()
        }
    }

    func fetchProIapStatus() {
        WHNetworkUtil.shareManager().GET(
            urlString: URL_pro_iap_status,
            vc: nil,
            requestConfig: { [weak self] request in
                request.responseJSON { [weak self] response in
                    guard let self = self else { return }
                    let responseObject = response.result.value as? [String: AnyObject]
                    if let responseObject = responseObject {
                        self.handleProIapStatusResponse(responseObject: responseObject)
                    } else {
                        self.handleProIapStatusRequestFailure()
                    }
                }
            },
            success: { _ in }
        )
    }

    func handleProIapStatusResponse(responseObject: [String: AnyObject]?) {
        guard let responseObject = responseObject else { return }

        let code = intValue(from: responseObject["code"])
        let message = stringValue(from: responseObject["message"]) ?? "网络异常，请稍后重试"
        proIapStatusState = code == 200 ? .subscribable : .unsubscribable(message: message)

        if shouldProceedPurchaseAfterIapStatusLoaded {
            shouldProceedPurchaseAfterIapStatusLoaded = false
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                MCToast.mc_remove()
                switch self.proIapStatusState {
                case .subscribable:
                    self.showPurchaseConfirmAlert()
                case .unsubscribable(let message):
                    MCToast.mc_text(message)
                case .idle, .loading:
                    break
                }
            }
        }
    }

    func handleProIapStatusRequestFailure() {
        proIapStatusState = .idle
        if shouldProceedPurchaseAfterIapStatusLoaded {
            shouldProceedPurchaseAfterIapStatusLoaded = false
            DispatchQueue.main.async {
                MCToast.mc_remove()
                MCToast.mc_text("网络异常，请稍后重试")
            }
        }
    }

    func intValue(from value: AnyObject?) -> Int {
        if let intValue = value as? Int {
            return intValue
        }
        if let stringValue = value as? String, let intValue = Int(stringValue) {
            return intValue
        }
        return -1
    }

    func stringValue(from value: AnyObject?) -> String? {
        if let stringValue = value as? String, !stringValue.isEmpty {
            return stringValue
        }
        return nil
    }

    func showPurchaseConfirmAlert() {
        let alertVm: GuidanceProPurchasedConfirmAlertVM
        if let existing = purchaseConfirmAlertVm {
            alertVm = existing
        } else {
            let created = GuidanceProPurchasedConfirmAlertVM(frame: .zero)
            purchaseConfirmAlertVm = created
            view.addSubview(created)
            created.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            alertVm = created
        }

        alertVm.confirmBlock = { [weak self] in
            self?.priceVm.continuePurchaseAfterIapStatusCheck()
        }
        alertVm.linkTapBlock = { [weak self] type in
            self?.openPurchaseAgreement(type)
        }
        view.bringSubviewToFront(alertVm)
        alertVm.showSelf()
    }

    func openPurchaseAgreement(_ type: GuidanceProPurchasedConfirmAlertVM.LinkType) {
        switch type {
        case .membershipAgreement:
            showAgreementAlert()
        }
    }

    func popToDietPlanSecondIfNeeded() -> Bool {
        guard shouldReturnToDietPlanSecondOnClose,
              let navigationController = navigationController,
              let targetVC = navigationController.viewControllers.last(where: { $0 is DietPlanSecondVC }) else {
            return false
        }
        navigationController.popToViewController(targetVC, animated: true)
        return true
    }
}

extension UIViewController {
    func pushElaProVCWhenReady(_ vc: ElaProVC, animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController?.pushViewController(vc, animated: animated)
        completion?()
    }
}

extension ElaProVC{
    func sendDietUpsertRequest() {
        DLLog(message: "sendDietUpsertRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_upsert, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            
        }
    }
}

extension ElaProVC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === scrollViewBase,
              shouldAllowScrollBackForCurrentStep,
              !isStepScrollAnimating else {
            return
        }
        scrollDragStartIndex = currentIndex
        disableFullscreenPopGesture()
        updateNextButtonForCurrentStep(animated: false)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === scrollViewBase,
              let startIndex = scrollDragStartIndex else {
            return
        }
        let startOffsetX = CGFloat(startIndex) * SCREEN_WIDHT
        let previousOffsetX = CGFloat(max(startIndex - 1, 0)) * SCREEN_WIDHT
        let clampedOffsetX = min(max(scrollView.contentOffset.x, previousOffsetX), startOffsetX)
        guard abs(scrollView.contentOffset.x - clampedOffsetX) > 0.5 else { return }
        scrollView.contentOffset = CGPoint(x: clampedOffsetX, y: scrollView.contentOffset.y)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView === scrollViewBase,
              let startIndex = scrollDragStartIndex else {
            return
        }
        let startOffsetX = CGFloat(startIndex) * SCREEN_WIDHT
        let previousOffsetX = CGFloat(max(startIndex - 1, 0)) * SCREEN_WIDHT
        let shouldReturn = velocity.x < -0.25 || scrollView.contentOffset.x < startOffsetX - SCREEN_WIDHT * 0.35
        let targetIndex = shouldReturn ? max(startIndex - 1, 0) : startIndex
        targetContentOffset.pointee = CGPoint(x: shouldReturn ? previousOffsetX : startOffsetX, y: 0)
        guard currentIndex != targetIndex else { return }
        currentIndex = targetIndex
        updateNavigationStyle(for: currentIndex, animated: true)
        naviVm.backButton.isHidden = currentIndex <= 1
        updateNextButtonForCurrentStep(animated: true)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView === scrollViewBase, !decelerate else { return }
        finishScrollBackDraggingIfNeeded()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === scrollViewBase else { return }
        finishScrollBackDraggingIfNeeded()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView === scrollViewBase else { return }
        finishStepScrollTransitionIfNeeded()
    }
}
