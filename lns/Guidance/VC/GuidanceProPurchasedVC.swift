//
//  GuidanceProPurchasedVC.swift
//  lns
//
//  Created by LNS2 on 2026/4/3.
//

import UIKit
import SnapKit

class GuidanceProPurchasedVC: WHBaseViewVC {

    private enum ContentStep {
        case intro
        case subscribe
    }

    var nextBlock: (() -> Void)?

    private let topBackgroundView = GuidanceProFlowBackgroundView()
    private let contentContainerView = UIView()
    private let topContentVM = GuidanceProTopVM()
    private let dietRecordContentVM = GuidanceProDietRecordVM()
    private var currentStep: ContentStep = .intro
    private var agreementAlertVm: ElaProAgreementAlertVM?
    var guidanceV2BizType = "自动"
    private var didTrackGuidanceV2IntroPage = false
    private var didTrackGuidanceV2SubscribePage = false
    private var isPreparingSubscribeContent = false
    private var shouldUseDietRecordIntro: Bool {
        UserInfoModel.shared.abTestModel.diet_important == .B
    }
    private var introContentVM: UIView {
        shouldUseDietRecordIntro ? dietRecordContentVM : topContentVM
    }

    private lazy var priceVm: ElaProPriceVM = {
        let vm = ElaProPriceVM(frame: .zero)
        vm.bizType = "1"
        vm.purchaseQueryBizType = "1"
        vm.isPurchased = "1"
        vm.displayMode = .guidance
        vm.purchaseSuccessBlock = { [weak self] in
            self?.nextBlock?()
        }
        vm.purchasePendingLoginBlock = { [weak self] in
            self?.changeRootVcToLogin(shouldSyncGuidanceProSubscriptionAfterLogin: true)
        }
        vm.protocalTapBlock = { [weak self] in
            self?.showAgreementAlert()
        }
        vm.purchaseLoadingStateChangeBlock = { [weak self] visible in
            self?.setPurchaseLoadingVisible(visible)
        }
        return vm
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        button.layer.cornerRadius = kFitWidth(22)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)
        return button
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "ela_pro_close_icon"), for: .normal)
        button.enablePressEffect()
        button.isHidden = true
        button.addTarget(self, action: #selector(closeButtonTapAction), for: .touchUpInside)
        return button
    }()

    private lazy var purchaseLoadingMaskView: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        vi.isUserInteractionEnabled = true
        vi.isHidden = true
        return vi
    }()

    private lazy var purchaseLoadingIndicator: UIActivityIndicatorView = {
        let vi = UIActivityIndicatorView(style: .large)
        vi.color = .white
        vi.hidesWhenStopped = false
        return vi
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        VIPModel.shared.updateSubscriptionBizType("1")
        initUI()

        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is GuidanceVC }) {
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

private extension GuidanceProPurchasedVC {
    func initUI() {
        view.backgroundColor = .white
        addELAFlowingBackground()
        scrollViewBase.removeFromSuperview()

//        view.addSubview(topBackgroundView)
        view.addSubview(contentContainerView)
        view.addSubview(priceVm)
        view.addSubview(nextButton)
        view.addSubview(closeButton)
        view.addSubview(purchaseLoadingMaskView)
        purchaseLoadingMaskView.addSubview(purchaseLoadingIndicator)

        contentContainerView.addSubview(topContentVM)
        contentContainerView.addSubview(dietRecordContentVM)

//        topBackgroundView.snp.makeConstraints { make in
//            make.left.right.top.equalToSuperview()
//            make.height.equalTo(SCREEN_HEIGHT * 0.46)
//        }

//        contentContainerView.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
//            make.top.equalTo(kFitWidth(126) + statusBarHeight)
//            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
//        }
        contentContainerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(statusBarHeight)
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

        priceVm.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-kFitWidth(22))
        }

        closeButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-12.5))
            make.top.equalTo(statusBarHeight + kFitWidth(5))
            make.width.height.equalTo(kFitWidth(35))
        }

        purchaseLoadingMaskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        purchaseLoadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        priceVm.isHidden = true
        priceVm.alpha = 0
        priceVm.startLoadingIfNeeded()

        topContentVM.isHidden = shouldUseDietRecordIntro
        topContentVM.alpha = shouldUseDietRecordIntro ? 0 : 1
        dietRecordContentVM.isHidden = !shouldUseDietRecordIntro
        dietRecordContentVM.alpha = shouldUseDietRecordIntro ? 1 : 0
        dietRecordContentVM.nextButton.isHidden = true
    }

    func disableFullscreenPopGesture() {
        navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        canEdgeBack = false
        fd_forceDisableInteractivePopGesture = true
        fd_interactivePopDisabled = true
        navigationController?.fd_interactivePopDisabled = true
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    func enforceFullscreenPopGestureDisabled() {
        disableFullscreenPopGesture()
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  self.navigationController?.topViewController === self else {
                return
            }
            self.disableFullscreenPopGesture()
        }
    }

    @objc func nextButtonTapAction() {
        switch currentStep {
        case .intro:
            showSubscribeContent()
        case .subscribe:
            nextBlock?()
        }
    }

    @objc func closeButtonTapAction() {
        guard purchaseLoadingMaskView.isHidden else { return }
        nextBlock?()
    }

    func showSubscribeContent() {
        guard currentStep == .intro, !isPreparingSubscribeContent else { return }

        isPreparingSubscribeContent = true
        nextButton.isEnabled = false
        ElaProPriceVM.preloadProducts(bizType: "1", isPurchased: "1") { [weak self] _ in
            DispatchQueue.main.async {
                self?.showPreparedSubscribeContent()
            }
        }
    }

    func showPreparedSubscribeContent() {
        isPreparingSubscribeContent = false
        nextButton.isEnabled = true
        guard currentStep == .intro else { return }

        currentStep = .subscribe
        nextButton.isHidden = true
        closeButton.isHidden = false
        topContentVM.stopBubbleFloatingAnimation()
        priceVm.startLoadingIfNeeded()
        transition(from: introContentVM, to: priceVm)
        trackGuidanceV2SubscribePageIfNeeded()
    }

    func transition(from currentView: UIView, to nextView: UIView) {
        nextView.isHidden = false
        nextView.alpha = 0
        nextView.transform = CGAffineTransform(translationX: kFitWidth(28), y: 0)

        UIView.animate(
            withDuration: 0.32,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState]
        ) {
            currentView.alpha = 0
            currentView.transform = CGAffineTransform(translationX: -kFitWidth(28), y: 0)
            nextView.alpha = 1
            nextView.transform = .identity
        } completion: { _ in
            currentView.isHidden = true
            currentView.alpha = 1
            currentView.transform = .identity
        }
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

    func setPurchaseLoadingVisible(_ visible: Bool) {
        purchaseLoadingMaskView.isHidden = !visible
        if visible {
            view.bringSubviewToFront(purchaseLoadingMaskView)
            purchaseLoadingIndicator.startAnimating()
        } else {
            purchaseLoadingIndicator.stopAnimating()
        }
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
}
