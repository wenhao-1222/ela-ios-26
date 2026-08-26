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
    private let flowState: Guide0820FlowState
    /// 已保存来源时是否自动跳到恢复栈。
    private let shouldRedirectStoredSource: Bool
    /// 引导流程根视图。
    private var rootView: Guide0820RootView?
    /// 是否已经完成引导。
    private var didFinish = false
    /// 是否已经根据本地来源选择跳过引导页。
    private var didRedirectStoredSource = false
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

    init(initialPageIndex: Int = 0, shouldRedirectStoredSource: Bool = true) {
        self.flowState = Guide0820FlowState(initialPageIndex: initialPageIndex)
        self.shouldRedirectStoredSource = shouldRedirectStoredSource
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.flowState = Guide0820FlowState()
        self.shouldRedirectStoredSource = true
        super.init(coder: coder)
    }

    /// 页面加载完成后初始化 UI。
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enforceInteractivePopGestureDisabled()
    }

    /// 页面出现后禁用系统侧滑和全屏侧滑返回。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enforceInteractivePopGestureDisabled()
        redirectToStartIfSourceStored()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        restoreFullscreenInteractivePopGesture()
    }
}

private extension Guide0820VC {
    func enforceInteractivePopGestureDisabled() {
        updateInteractivePopGestureBlocked(true)
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  self.navigationController?.topViewController === self else {
                return
            }
            self.updateInteractivePopGestureBlocked(true)
        }
    }

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

    /// 已保存过来源选择时，跳过 Guide0820 来源引导，直接进入 Guide0820StartVC。
    func redirectToStartIfSourceStored() {
        guard shouldRedirectStoredSource,
              didRedirectStoredSource == false,
              didFinish == false,
              Guide0820ProgressStorage.shouldResumeGuide0820 else { return }
        didRedirectStoredSource = true

        let resumeViewControllers = Guide0820StartVC.makeResumeViewControllers(includingLaunchEntry: false)
        if let navigationController = navigationController {
            var viewControllers = navigationController.viewControllers
            if let index = viewControllers.firstIndex(where: { $0 === self }) {
                viewControllers.replaceSubrange(index...index, with: resumeViewControllers)
                navigationController.setViewControllers(viewControllers, animated: false)
            } else {
                navigationController.setViewControllers(viewControllers + resumeViewControllers, animated: false)
            }
        } else {
            let nav = UINavigationController()
            nav.setViewControllers(resumeViewControllers, animated: false)
            nav.setNavigationBarHidden(true, animated: false)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
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
        let startVC = Guide0820StartVC()
        if let navigationController = navigationController {
            navigationController.pushViewController(startVC, animated: true)
        } else {
            startVC.modalPresentationStyle = .fullScreen
            present(startVC, animated: true)
        }
    }
}
