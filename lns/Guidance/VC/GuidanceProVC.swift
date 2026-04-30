//
//  GuidanceProVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/19.
//

import UIKit
import SnapKit
import MCToast

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
    private let trialContentVM = GuidanceProTrialVM()
    private let promiseContentVM = GuidanceProPromiseVM()
    private let subscribeContentVM = GuidanceProSubscribeVM()
    private var currentStep: ContentStep = .intro
    private var isPurchasing = false
    var hasFreeTrialPermission = true
    
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
        initUI()
        
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is GuidanceVC }){
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        topBackgroundView.startAnimatingIfNeeded()
//        if currentStep == .intro {
//            topContentVM.startBubbleFloatingAnimationIfNeeded()
//        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        topBackgroundView.pauseAnimating()
        topContentVM.stopBubbleFloatingAnimation()
    }
}
extension GuidanceProVC {
    func initUI() {
        view.backgroundColor = .clear
        addELAFlowingBackground()
        
//        view.addSubview(topBackgroundView)
        view.addSubview(contentContainerView)
        view.addSubview(backButton)
        view.addSubview(nextButton)

        contentContainerView.addSubview(topContentVM)
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
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }

        subscribeContentVM.startTrialTapBlock = { [weak self] in
            self?.startSubscriptionFlow()
        }
        subscribeContentVM.updateFreeTrialPermission(hasFreeTrialPermission)
        fetchAnnualDisplayProduct()

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
    }

    @objc func nextButtonTapAction() {
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
            showSubscribeContent()
        case .subscribe:
            nextBlock?()
        }
    }

    @objc func backAction() {
        guard !isPurchasing else { return }
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
        updateBackButtonVisibility(animated: true)
        transition(from: topContentVM, to: trialContentVM, direction: .forward)
    }

    func showPromiseContent() {
        guard currentStep == .trial else { return }

        currentStep = .promise
        nextButton.isHidden = false
        updateBackButtonVisibility(animated: true)
        transition(from: trialContentVM, to: promiseContentVM, direction: .forward)
    }

    func showSubscribeContent() {
        let previousStep = currentStep
        guard previousStep == .promise || previousStep == .intro else { return }

        currentStep = .subscribe
        nextButton.isHidden = true
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

        let fromView = previousStep == .promise ? promiseContentVM : topContentVM
        transition(from: fromView, to: subscribeContentVM, direction: .forward)
    }

    func showPreviousContent() {
        guard let previousStep = previousStep(for: currentStep) else { return }

        let fromView = view(for: currentStep)
        let toView = view(for: previousStep)

        currentStep = previousStep
        nextButton.isHidden = false
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
            return topContentVM
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
        backButton.isUserInteractionEnabled = shouldShow

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
        }
    }

    func fetchAnnualDisplayProduct() {
        ElaProIAPManager.shared.fetchAnnualProduct { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard case .success(let product) = result else { return }
                self.subscribeContentVM.updateAnnualProduct(product)
            }
        }
    }

    func startSubscriptionFlow() {
        guard !isPurchasing else { return }

        isPurchasing = true
        subscribeContentVM.setLoading(true)

        ElaProIAPManager.shared.purchaseAnnual { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let transaction):
                    ElaProIAPManager.shared.handlePurchaseSuccessPostAction(transaction: transaction) { outcome in
                        DispatchQueue.main.async {
                            self.isPurchasing = false
                            self.subscribeContentVM.setLoading(false)
                            switch outcome {
                            case .activated:
                                MCToast.mc_text("订阅成功")
                                self.nextBlock?()
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
}
