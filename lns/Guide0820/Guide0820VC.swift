//
//  Guide0820VC.swift
//  lns
//
//  Created by Codex on 2026/8/21.
//

import UIKit
import SnapKit

final class Guide0820VC: WHBaseViewVC {
    static let hasShownKey = "guide_0820_has_shown"

    var finishBlock: (() -> Void)?

    private let flowState = Guide0820FlowState()
    private var rootView: Guide0820RootView?
    private var didFinish = false
    private lazy var backButton: ElaLiquidGlassCloseButton = {
        let button = ElaLiquidGlassCloseButton()
        button.iconImage = UIImage(named: "guide_back_button")
        button.iconColor = .COLOR_TEXT_TITLE_0f1214
        button.iconSize = kFitWidth(17)
        button.showsOuterStroke = false
        button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

private extension Guide0820VC {
    func initUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .COLOR_BG_F2

        let rootView = Guide0820RootView(
            flowState: flowState,
            onOpenAgreement: { [weak self] type in
                self?.openAgreement(type)
            },
            onFinish: { [weak self] in
                self?.finishGuide()
            }
        )

        view.addSubview(rootView)
        rootView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.rootView = rootView

        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(10))
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(kFitWidth(7))
            make.width.height.equalTo(kFitWidth(30))
        }
    }

    func handleBackAction() {
        if flowState.currentPageIndex > 0 {
            rootView?.showPreviousPage()
            return
        }

        if let navigationController = navigationController,
           navigationController.viewControllers.first !== self {
            navigationController.popViewController(animated: true)
            return
        }

        if presentingViewController != nil {
            dismiss(animated: true)
            return
        }

        finishGuide()
    }

    @objc func backButtonAction() {
        handleBackAction()
    }

    func openAgreement(_ type: Guide0820AgreementType) {
        let vc = WHCommonH5VC()
        switch type {
        case .userAgreement:
            vc.urlString = URL_agreement as NSString
        case .privacyPolicy:
            vc.urlString = URL_privacy as NSString
        }

        if let navigationController = navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            present(nav, animated: true)
        }
    }

    func finishGuide() {
        guard didFinish == false else { return }
        didFinish = true
        UserDefaults.standard.set(true, forKey: Self.hasShownKey)
        if let finishBlock = finishBlock {
            finishBlock()
            return
        }

        if let navigationController = navigationController,
           navigationController.viewControllers.first !== self {
            navigationController.popViewController(animated: true)
        } else if presentingViewController != nil {
            dismiss(animated: true)
        }
    }
}
