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

    private enum ContentStep {
        case intro
        case trial
        case promise
        case subscribe
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

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topBackgroundView.startAnimatingIfNeeded()
        if currentStep == .intro {
            topContentVM.startBubbleFloatingAnimationIfNeeded()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        topBackgroundView.pauseAnimating()
        topContentVM.stopBubbleFloatingAnimation()
    }
}

private extension GuidanceProVC {
    func initUI() {
        view.backgroundColor = .white
        scrollViewBase.removeFromSuperview()

        view.addSubview(topBackgroundView)
        view.addSubview(contentContainerView)
        view.addSubview(nextButton)

        contentContainerView.addSubview(topContentVM)
        contentContainerView.addSubview(trialContentVM)
        contentContainerView.addSubview(promiseContentVM)
        view.addSubview(subscribeContentVM)

        topBackgroundView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT * 0.46)
        }

        contentContainerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kFitWidth(126) + statusBarHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        topContentVM.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(434))
        }

        trialContentVM.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(520))
        }

        promiseContentVM.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(520))
        }

        subscribeContentVM.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-kFitWidth(22))
        }

        subscribeContentVM.startTrialTapBlock = { [weak self] in
            self?.startSubscriptionFlow()
        }

        trialContentVM.isHidden = true
        trialContentVM.alpha = 0
        promiseContentVM.isHidden = true
        promiseContentVM.alpha = 0
        subscribeContentVM.isHidden = true
        subscribeContentVM.alpha = 0
    }

    @objc func nextButtonTapAction() {
        switch currentStep {
        case .intro:
            showTrialContent()
        case .trial:
            showPromiseContent()
        case .promise:
            showSubscribeContent()
        case .subscribe:
            nextBlock?()
        }
    }

    func showTrialContent() {
        guard currentStep == .intro else { return }

        currentStep = .trial
        topContentVM.stopBubbleFloatingAnimation()
        transition(from: topContentVM, to: trialContentVM)
    }

    func showPromiseContent() {
        guard currentStep == .trial else { return }

        currentStep = .promise
        transition(from: trialContentVM, to: promiseContentVM)
    }

    func showSubscribeContent() {
        guard currentStep == .promise else { return }

        currentStep = .subscribe
        nextButton.isHidden = true
        transition(from: promiseContentVM, to: subscribeContentVM)
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

    func startSubscriptionFlow() {
        guard !isPurchasing else { return }

        isPurchasing = true
        subscribeContentVM.setLoading(true)

        ElaProIAPManager.shared.updateProductIDs(
            month: ElaProIAPConfig.monthProductID,
            annual: "annual_yeal_new",
            lifetime: ElaProIAPConfig.lifetimeProductID
        )

        ElaProIAPManager.shared.purchaseAnnual { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isPurchasing = false
                self.subscribeContentVM.setLoading(false)

                switch result {
                case .success(let transaction):
                    ElaProIAPManager.shared.handlePurchaseSuccessPostAction(transaction: transaction)
                    MCToast.mc_text("订阅成功")
                    self.nextBlock?()
                case .failure(let error):
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
