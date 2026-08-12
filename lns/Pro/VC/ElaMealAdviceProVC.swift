//
//  ElaMealAdviceProVC.swift
//  lns
//
//  Created by Codex on 2026/8/12.
//

import UIKit
import SnapKit
import MCToast

class ElaMealAdviceProVC: WHBaseViewVC {
    private enum ProIapStatusState {
        case idle
        case loading
        case subscribable
        case unsubscribable(message: String)
    }

    private var currentIndex = 0
    private var isStepScrollAnimating = false
    private var proIapStatusState: ProIapStatusState = .idle
    private var shouldProceedPurchaseAfterIapStatusLoaded = false
    private var agreementAlertVm: ElaProAgreementAlertVM?
    private var purchaseConfirmAlertVm: GuidanceProPurchasedConfirmAlertVM?
    private var backButtonLeftConstraint: Constraint?
    private var backButtonTopConstraint: Constraint?

    var priceBizType = "6"
    var purchaseSuccessBlock: (() -> Void)?

    private lazy var introVm = ElaMealAdviceProIntroVM(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))

    private lazy var priceVm: ElaProPriceVM = {
        let vm = ElaProPriceVM(frame: CGRect(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vm.bizType = self.priceBizType
        vm.purchaseQueryBizType = (self.priceBizType == "2" || self.priceBizType == "4") ? self.priceBizType : "3"
        vm.displayMode = .mealAdvice
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

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "habit_guide_back_icon"), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapAction), for: .touchUpInside)
        return button
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("继续", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        button.layer.cornerRadius = kFitWidth(24)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)
        return button
    }()

    private lazy var purchaseLoadingMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.isUserInteractionEnabled = true
        view.isHidden = true
        return view
    }()

    private lazy var purchaseLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = false
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        VIPModel.shared.updateSubscriptionBizType(priceBizType)
        initUI()
        requestProIapStatusIfNeeded(showLoading: false)
        priceVm.loadProductsOnViewDidLoad()
        EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW, scenarioType: .ela_pro_view, text: priceBizType)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInteractivePopGestureBlocked(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateInteractivePopGestureBlocked(false)
    }
}

private extension ElaMealAdviceProVC {
    func initUI() {
        addELAFlowingBackground()

        view.addSubview(scrollViewBase)
        view.addSubview(backButton)
        view.addSubview(nextButton)
        view.addSubview(purchaseLoadingMaskView)
        purchaseLoadingMaskView.addSubview(purchaseLoadingIndicator)

        scrollViewBase.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT * 2, height: 0)
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.showsHorizontalScrollIndicator = false
        scrollViewBase.isScrollEnabled = false
        scrollViewBase.bounces = false
        scrollViewBase.delegate = self
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.addSubview(introVm)
        scrollViewBase.addSubview(priceVm)

        backButton.snp.makeConstraints { make in
            backButtonLeftConstraint = make.left.equalTo(kFitWidth(12.5)).constraint
            backButtonTopConstraint = make.top.equalTo(statusBarHeight + kFitWidth(5)).constraint
            make.width.height.equalTo(kFitWidth(35))
        }

        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(10))
        }

        purchaseLoadingMaskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        purchaseLoadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        updateChromeForCurrentStep(animated: false)
    }

    @objc func nextButtonTapAction() {
        guard !isStepScrollAnimating, currentIndex == 0 else { return }
        currentIndex = 1
        showCurrentStep(animated: true)
    }

    @objc func backButtonTapAction() {
        guard !isStepScrollAnimating else { return }
        if currentIndex == 1 {
            currentIndex = 0
            showCurrentStep(animated: true)
        } else {
            backTapAction()
        }
    }

    func showCurrentStep(animated: Bool) {
        let offset = CGPoint(x: CGFloat(currentIndex) * SCREEN_WIDHT, y: 0)
        isStepScrollAnimating = animated && abs(scrollViewBase.contentOffset.x - offset.x) > 0.5
        scrollViewBase.setContentOffset(offset, animated: animated)
        updateChromeForCurrentStep(animated: animated)
        if !isStepScrollAnimating {
            finishStepScrollTransitionIfNeeded()
        }
    }

    func updateChromeForCurrentStep(animated: Bool) {
        let isPriceStep = currentIndex == 1
        let backImageName = isPriceStep ? "ela_pro_close_icon" : "habit_guide_back_icon"
        let backLeft = isPriceStep ? SCREEN_WIDHT - kFitWidth(12.5) - kFitWidth(35) : kFitWidth(12.5)
        let backTop = statusBarHeight + kFitWidth(5)
        let nextTransform = isPriceStep ? CGAffineTransform(translationX: 0, y: kFitWidth(90) + WHUtils().getBottomSafeAreaHeight()) : .identity
        let nextAlpha: CGFloat = isPriceStep ? 0 : 1

        let apply = {
            self.backButton.setImage(UIImage(named: backImageName), for: .normal)
            self.backButtonLeftConstraint?.update(offset: backLeft)
            self.backButtonTopConstraint?.update(offset: backTop)
            self.nextButton.transform = nextTransform
            self.nextButton.alpha = nextAlpha
            self.view.layoutIfNeeded()
        }

        nextButton.isUserInteractionEnabled = !isPriceStep && !isStepScrollAnimating

        if animated {
            UIView.animate(withDuration: 0.22) {
                apply()
            }
        } else {
            apply()
        }
    }

    func finishStepScrollTransitionIfNeeded() {
        guard isStepScrollAnimating else { return }
        isStepScrollAnimating = false
        updateChromeForCurrentStep(animated: false)
    }

    func setPurchaseLoadingVisible(_ visible: Bool) {
        purchaseLoadingMaskView.isHidden = !visible
        if visible {
            view.bringSubviewToFront(purchaseLoadingMaskView)
            purchaseLoadingIndicator.startAnimating()
        } else {
            purchaseLoadingIndicator.stopAnimating()
        }
    }

    func handlePurchaseSuccess() {
        requestLatestVipInfo()
        NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_DIET_PLAN_STATUS, object: nil)
        purchaseSuccessBlock?()
        backTapAction()
    }

    func requestLatestVipInfo() {
        WHNetworkUtil.shareManager().POST(urlString: URL_pro_info, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            _ = VIPModel.shared.update(with: dataDict)
            NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_DIET_PLAN_STATUS, object: nil)
        } failure: { _ in }
    }

    func showAgreementAlert() {
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
}

private extension ElaMealAdviceProVC {
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
            switch type {
            case .membershipAgreement:
                self?.showAgreementAlert()
            }
        }
        view.bringSubviewToFront(alertVm)
        alertVm.showSelf()
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
}

extension ElaMealAdviceProVC: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView === scrollViewBase else { return }
        finishStepScrollTransitionIfNeeded()
    }
}
