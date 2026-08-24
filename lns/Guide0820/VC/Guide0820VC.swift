//
//  Guide0820VC.swift
//  lns
//
//  Created by Codex on 2026/8/21.
//

import UIKit
import SnapKit

/// Guide0820 引导流程控制器。
final class Guide0820VC: WHBaseViewVC {
    /// Guide0820 是否已展示的本地标记。
    static let hasShownKey = "guide_0820_has_shown"

    /// 引导完成回调。
    var finishBlock: (() -> Void)?

    /// 引导流程状态。
    private let flowState = Guide0820FlowState()
    /// 引导流程根视图。
    private var rootView: Guide0820RootView?
    /// 是否已经完成引导。
    private var didFinish = false
    /// 左上角返回按钮。
    private lazy var backButton: ElaLiquidGlassCloseButton = {
        let button = ElaLiquidGlassCloseButton()
        button.iconImage = UIImage(named: "guide_back_button")
        button.iconColor = .COLOR_TEXT_TITLE_0f1214
        button.iconSize = kFitWidth(20)
        button.showsOuterStroke = true
        button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return button
    }()

    /// 页面加载完成后初始化 UI。
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    /// 页面出现后恢复系统侧滑手势。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

private extension Guide0820VC {
    /// 初始化页面 UI。
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
            make.left.equalTo(kFitWidth(6))
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(kFitWidth(4.5))
            make.width.height.equalTo(kFitWidth(35))
        }
    }

    /// 处理返回按钮逻辑。
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

    /// 返回按钮点击事件。
    @objc func backButtonAction() {
        handleBackAction()
    }

    /// 打开协议页面。
    /// - Parameter type: 协议类型。
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

    /// 完成 Guide0820 引导流程。
    func finishGuide() {
        guard didFinish == false else { return }
        didFinish = true
        Guide0820SourceStorage.save(flowState.sourceVM.selectedItemID)
        UserDefaults.standard.set(true, forKey: Self.hasShownKey)
        if let finishBlock = finishBlock {
            finishBlock()
            return
        }

        showStartVC()
    }

    /// 展示 Guide0820 之后的开始页。
    func showStartVC() {
        let startVC = VCStart()
        if let navigationController = navigationController {
            navigationController.pushViewController(startVC, animated: true)
        } else {
            startVC.modalPresentationStyle = .fullScreen
            present(startVC, animated: true)
        }
    }
}
