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
    private var currentStep: ContentStep = .intro
    private var agreementAlertVm: ElaProAgreementAlertVM?

    private lazy var priceVm: ElaProPriceVM = {
        let vm = ElaProPriceVM(frame: .zero)
        vm.bizType = "1"
        vm.isPurchased = "1"
        vm.purchaseSuccessBlock = { [weak self] in
            self?.nextBlock?()
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
        initUI()

        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is GuidanceVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topBackgroundView.startAnimatingIfNeeded()
//        if currentStep == .intro {
//            topContentVM.startBubbleFloatingAnimationIfNeeded()
//        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        topBackgroundView.pauseAnimating()
        topContentVM.stopBubbleFloatingAnimation()
    }
}

private extension GuidanceProPurchasedVC {
    func initUI() {
        view.backgroundColor = .white
        scrollViewBase.removeFromSuperview()

        view.addSubview(topBackgroundView)
        view.addSubview(contentContainerView)
        view.addSubview(priceVm)
        view.addSubview(nextButton)
        view.addSubview(closeButton)
        view.addSubview(purchaseLoadingMaskView)
        purchaseLoadingMaskView.addSubview(purchaseLoadingIndicator)

        contentContainerView.addSubview(topContentVM)

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
        guard currentStep == .intro else { return }

        currentStep = .subscribe
        nextButton.isHidden = true
        closeButton.isHidden = false
        topContentVM.stopBubbleFloatingAnimation()
        transition(from: topContentVM, to: priceVm)
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
}
