//
//  Guide0820StartVC.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// Guide0820 完成后的“让我们开始吧”页面。
final class Guide0820StartVC: WHBaseViewVC {
    /// 开始页视图模型。
    private let vm = VCStartVM()
    /// 页面根视图。
    private var rootView: VCStartRootView?
    /// 底部弹层容器。
    private lazy var bottomSheetView = Guide0820BottomSheetView()
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
    /// 右上角操作按钮。
    private lazy var operationButton: Guide0820MoreButton = {
        let button = Guide0820MoreButton()
        button.addTarget(self, action: #selector(operationButtonAction), for: .touchUpInside)
        return button
    }()

    /// 页面加载完成后初始化 UI。
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    /// 执行 `viewWillAppear` 操作，完成当前引导页面的状态更新或交互处理。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enforceInteractivePopGestureDisabled()
        rootView?.reloadSteps()
    }

    /// 页面出现后禁用系统侧滑和全屏侧滑返回。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enforceInteractivePopGestureDisabled()
    }

    /// 执行 `viewDidDisappear` 操作，完成当前引导页面的状态更新或交互处理。
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        restoreFullscreenInteractivePopGesture()
    }
}

/// Guide0820StartVC 扩展，提供 Guide0820 流程相关的辅助能力。
extension Guide0820StartVC {
    /// Guide0820 冷启动恢复用导航栈；子流程未完成时停留在开始页，由开始页展示当前主步骤。
    static func makeResumeViewControllers(includingLaunchEntry: Bool = false) -> [UIViewController] {
        var viewControllers: [UIViewController] = []
        if includingLaunchEntry {
            viewControllers.append(FirstLaunchVC(skipAnimation: true, forceNeedBuildPlanOnConfirm: true))
        }
        viewControllers.append(Guide0820VC(initialPageIndex: 2, shouldRedirectStoredSource: false))
        viewControllers.append(Guide0820StartVC())
        return viewControllers
    }
}

// Guide0820StartVC 扩展，提供 Guide0820 流程相关的辅助能力。
private extension Guide0820StartVC {
    // 执行 `enforceInteractivePopGestureDisabled` 操作，完成当前引导页面的状态更新或交互处理。
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

    /// 初始化页面结构。
    func initUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .COLOR_BG_F2

        let rootView = VCStartRootView(vm: vm) { [weak self] in
            self?.startButtonAction()
        }
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

        view.addSubview(operationButton)
        operationButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-18))
            make.centerY.equalTo(backButton)
            make.width.equalTo(kFitWidth(42))
            make.height.equalTo(kFitWidth(40))
        }

        view.addSubview(bottomSheetView)
        bottomSheetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    /// 处理返回按钮点击。
    @objc func backButtonAction() {
        returnToFirstLaunchPage()
    }

    /// 处理右上角操作按钮点击。
    @objc func operationButtonAction() {
        showOperationSheet()
    }

    /// 步骤 1 开始时进入身体信息采集流程。
    func startButtonAction() {
        switch vm.currentStep {
        case .bodyProfile:
            startBodyProfileStep()
        case .lifeProfile:
            startLifeProfileStep()
        case .directionProfile:
            startDirectionProfileStep()
        }
    }

    /// 进入身体信息采集流程。
    func startBodyProfileStep() {
        let vc = Guide0820BodyProfileVC()
        navigationController?.pushViewController(vc, animated: true)
    }

    /// 进入生活习惯采集流程。真实 VC 接入后在这里替换跳转。
    func startLifeProfileStep() {
        let vc = Guide0820LifeProfileVC()
        navigationController?.pushViewController(vc, animated: true)
    }

    /// 进入目标方向采集流程。真实 VC 接入后在这里替换跳转。
    func startDirectionProfileStep() {
        let vc = GuidanceGoalPlanVC()
        vc.finishBlock = { [weak self] flowState in
            guard let self else { return }
            let progressVC = GuidanceNutritionGoalsProgressVC(flowState: flowState)
            progressVC.finishBlock = { [weak progressVC] result in
                guard let navigationController = progressVC?.navigationController else { return }
                let resultVC = GuidanceNutritionGoalsResultVC(goals: result)
                resultVC.completion = { [weak resultVC] in
                    resultVC?.navigationController?.popToViewController(self, animated: true)
                }
                navigationController.pushViewController(resultVC, animated: true)
            }
            self.navigationController?.pushViewController(progressVC, animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    /// 展示操作底部面板。
    func showOperationSheet() {
        let operationView = Guide0820OperationSheetView(
            vm: Guide0820OperationSheetVM(),
            onClose: { [weak self] in
                self?.bottomSheetView.dismiss()
            },
            onSelectItem: { [weak self] item in
                self?.handleOperationItem(item)
            }
        )
        let sheetViewHeight = kFitWidth(239) + getBottomSafeAreaHeight() - kFitWidth(65)
        bottomSheetView.present(contentView: operationView,
                                contentHeight: sheetViewHeight,
                                keyboardAvoidanceEnabled: false)
    }

    /// 处理操作面板点击。
    /// - Parameter item: 被点击的操作项。
    func handleOperationItem(_ item: Guide0820OperationItem) {
        switch item.identifier {
        case .sourceInput:
            showInviteSourceSheet()
        case .clearData:
            showDeleteConfirmationSheet()
        }
    }

    /// 展示“你怎么知道我们的？”输入面板；当前版本仅做页面展示，不接入业务逻辑。
    func showInviteSourceSheet() {
        let sourceView = Guide0820InviteSourceSheetView(
            vm: Guide0820InviteSourceInputVM(),
            onClose: { [weak self] in
                self?.bottomSheetView.dismiss()
            }
        )
        bottomSheetView.present(contentView: sourceView,
                                contentHeight: kFitWidth(272.5),
                                keyboardAvoidanceEnabled: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            sourceView.focusInput()
        }
    }

    /// 展示清空数据确认面板。
    func showDeleteConfirmationSheet() {
        let deleteView = Guide0820DeleteConfirmationSheetView(
            vm: Guide0820DeleteConfirmationVM(),
            onClose: { [weak self] in
                self?.bottomSheetView.dismiss()
            },
            onConfirm: { [weak self] in
                self?.clearGuideSourceDataAndReturn()
            }
        )
        bottomSheetView.present(contentView: deleteView,
                                contentHeight: kFitWidth(272.5),
                                keyboardAvoidanceEnabled: false)
    }

    /// 清除 Guide0820 全流程本地数据并回到首次启动页。
    func clearGuideSourceDataAndReturn() {
        Guide0820ProgressStorage.clearAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.returnToFirstLaunchPage()
        }
    }

    /// 回到 FirstLaunchVC，恢复“从未开始 Guide0820”的入口状态。
    func returnToFirstLaunchPage() {
        let firstLaunchVC = FirstLaunchVC(skipAnimation: true, forceNeedBuildPlanOnConfirm: true)

        if let navigationController = navigationController {
            navigationController.setViewControllers([firstLaunchVC], animated: true)
            return
        }

        let nav = UINavigationController(rootViewController: firstLaunchVC)
        nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

/// Guide0820 开始页右上角更多按钮，按 MasterGo 设计稿绘制 3 个独立圆点。
final class Guide0820MoreButton: UIButton {
    // 初始化当前类型实例。
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        accessibilityLabel = "更多"
    }

    // 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // `isHighlighted` 属性，保存该类型对外提供或内部使用的状态与配置。
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.55 : 1
        }
    }

    // 执行 `draw` 操作，完成当前引导页面的状态更新或交互处理。
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let dotDiameter = kFitWidth(5)
        let dotSpacing = kFitWidth(4)
        let totalWidth = dotDiameter * 3 + dotSpacing * 2
        let startX = bounds.width - totalWidth
        let centerY = bounds.midY

        UIColor.COLOR_TEXT_TITLE_0f1214.setFill()
        for index in 0..<3 {
            let x = startX + CGFloat(index) * (dotDiameter + dotSpacing)
            let dotRect = CGRect(x: x,
                                 y: centerY - dotDiameter * 0.5,
                                 width: dotDiameter,
                                 height: dotDiameter)
            UIBezierPath(ovalIn: dotRect).fill()
        }
    }
}
