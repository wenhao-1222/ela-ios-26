//
//  Guide0820ProVC.swift
//  lns
//
//  Ela Pro onboarding paywall shown after the 0820 feature introduction.
//

import UIKit
import SnapKit

/// Ela Pro 0820 订阅页。
///
/// 套餐列表和购买行为统一由 `ElaProPriceVM` 提供，页面只负责 0820 的
/// 社会证明内容、导航和流程出口。
final class Guide0820ProVC: WHBaseViewVC {
    private let pageVM = Guide0820ProVM()
    private let bottomSheetView = Guide0820BottomSheetView()

    private lazy var priceVM: ElaProPriceVM = {
        let vm = ElaProPriceVM(frame: .zero)
        vm.bizType = "1"
        vm.purchaseQueryBizType = "1"
        vm.isPurchased = "1"
        vm.displayMode = .guidance
        vm.confirmButton.layer.cornerRadius = kFitWidth(12)
        pageVM.configure(priceVM: vm)
        vm.purchaseSuccessBlock = { [weak self] in
            self?.changeRootVcToLogin(shouldSyncGuidanceProSubscriptionAfterLogin: true)
        }
        vm.purchasePendingLoginBlock = { [weak self] in
            self?.changeRootVcToLogin(shouldSyncGuidanceProSubscriptionAfterLogin: true)
        }
        vm.protocalTapBlock = { [weak self] in
            self?.showAgreementAlert()
        }
        vm.purchaseLoadingStateChangeBlock = { [weak self] visible in
            self?.setPurchaseLoadingVisible(visible)
            if !visible {
                self?.priceVM.confirmButton.setTitle("开始第一阶段", for: .normal)
            }
        }
        return vm
    }()

    private lazy var closeButton: ElaLiquidGlassCloseButton = {
        let button = ElaLiquidGlassCloseButton()
        button.iconImage = UIImage(systemName: "xmark")
        button.iconColor = .COLOR_TEXT_TITLE_0f1214
        button.iconSize = kFitWidth(16)
        button.showsOuterStroke = true
        button.accessibilityLabel = "关闭"
        button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return button
    }()

    private lazy var operationButton: Guide0820MoreButton = {
        let button = Guide0820MoreButton()
        button.addTarget(self, action: #selector(operationAction), for: .touchUpInside)
        return button
    }()

    private var agreementAlertVM: ElaProAgreementAlertVM?
    private var purchaseLoadingMaskView: UIView?
    private var purchaseLoadingIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        VIPModel.shared.updateSubscriptionBizType("1")
        navigationController?.setNavigationBarHidden(true, animated: false)
        addELAFlowingBackground()
        buildInterface()
        priceVM.startLoadingIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enforcePopGesturesDisabled()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enforcePopGesturesDisabled()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        restoreFullscreenInteractivePopGesture()
    }

    deinit { restoreFullscreenInteractivePopGesture() }
}

private extension Guide0820ProVC {
    func buildInterface() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(priceVM)
        priceVM.insertSubview(pageVM, belowSubview: priceVM.agreementConfirmDimView)
        view.addSubview(closeButton)
        view.addSubview(operationButton)
        view.addSubview(bottomSheetView)

        priceVM.snp.makeConstraints { $0.edges.equalToSuperview() }
        pageVM.snp.makeConstraints { $0.edges.equalToSuperview() }
        closeButton.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(16))
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(kFitWidth(4.5))
            $0.width.height.equalTo(kFitWidth(35))
        }
        operationButton.snp.makeConstraints {
            $0.right.equalTo(kFitWidth(-18))
            $0.centerY.equalTo(closeButton)
            $0.width.equalTo(kFitWidth(42))
            $0.height.equalTo(kFitWidth(40))
        }
        bottomSheetView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func enforcePopGesturesDisabled() {
        updateInteractivePopGestureBlocked(true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        DispatchQueue.main.async { [weak self] in
            guard let self, self.navigationController?.topViewController === self else { return }
            self.updateInteractivePopGestureBlocked(true)
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        }
    }

    @objc func closeAction() {
        guard purchaseLoadingMaskView?.isHidden ?? true else { return }
        // 与 GuidanceProPurchasedVC 一致：关闭订阅页后进入登录流程。
        changeRootVcToLogin(shouldSyncGuidanceProSubscriptionAfterLogin: true)
    }

    @objc func operationAction() { showOperationSheet() }

    func showOperationSheet() {
        let operationView = Guide0820OperationSheetView(
            vm: Guide0820OperationSheetVM(),
            onClose: { [weak self] in self?.bottomSheetView.dismiss() },
            onSelectItem: { [weak self] item in self?.handleOperationItem(item) }
        )
        let height = kFitWidth(239) + getBottomSafeAreaHeight() - kFitWidth(65)
        bottomSheetView.present(contentView: operationView, contentHeight: height, keyboardAvoidanceEnabled: false)
    }

    func handleOperationItem(_ item: Guide0820OperationItem) {
        switch item.identifier {
        case .sourceInput: showInviteSourceSheet()
        case .clearData: showDeleteConfirmationSheet()
        }
    }

    func showInviteSourceSheet() {
        let sourceView = Guide0820InviteSourceSheetView(
            vm: Guide0820InviteSourceInputVM(),
            onClose: { [weak self] in self?.bottomSheetView.dismiss() }
        )
        bottomSheetView.present(contentView: sourceView, contentHeight: kFitWidth(272.5), keyboardAvoidanceEnabled: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) { sourceView.focusInput() }
    }

    func showDeleteConfirmationSheet() {
        let deleteView = Guide0820DeleteConfirmationSheetView(
            vm: Guide0820DeleteConfirmationVM(),
            onClose: { [weak self] in self?.bottomSheetView.dismiss() },
            onConfirm: { [weak self] in
                Guide0820ProgressStorage.clearAll()
                self?.bottomSheetView.dismiss()
                self?.returnToFirstLaunchPage()
            }
        )
        bottomSheetView.present(contentView: deleteView, contentHeight: kFitWidth(272.5), keyboardAvoidanceEnabled: false)
    }

    func returnToFirstLaunchPage() {
        let firstLaunchVC = FirstLaunchVC(skipAnimation: true, forceNeedBuildPlanOnConfirm: true)
        navigationController?.setViewControllers([firstLaunchVC], animated: true)
    }

    func showAgreementAlert() {
        let alertVM: ElaProAgreementAlertVM
        if let existing = agreementAlertVM {
            alertVM = existing
        } else {
            let created = ElaProAgreementAlertVM(frame: .zero)
            agreementAlertVM = created
            view.addSubview(created)
            created.snp.makeConstraints { $0.edges.equalToSuperview() }
            alertVM = created
        }
        view.bringSubviewToFront(alertVM)
        alertVM.showSelf()
    }

    func setPurchaseLoadingVisible(_ visible: Bool) {
        if purchaseLoadingMaskView == nil {
            let mask = UIView()
            mask.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            mask.isHidden = true
            view.addSubview(mask)
            mask.snp.makeConstraints { $0.edges.equalToSuperview() }
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.color = .white
            mask.addSubview(indicator)
            indicator.snp.makeConstraints { $0.center.equalToSuperview() }
            purchaseLoadingMaskView = mask
            purchaseLoadingIndicator = indicator
        }
        purchaseLoadingMaskView?.isHidden = !visible
        visible ? purchaseLoadingIndicator?.startAnimating() : purchaseLoadingIndicator?.stopAnimating()
    }
}
