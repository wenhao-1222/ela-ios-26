//
//  VCStart.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// Guide0820 完成后的“让我们开始吧”页面。
final class VCStart: WHBaseViewVC {
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
    private lazy var operationButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(systemName: "ellipsis")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .COLOR_TEXT_TITLE_0f1214
        button.addTarget(self, action: #selector(operationButtonAction), for: .touchUpInside)
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

private extension VCStart {
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
            make.right.equalTo(kFitWidth(-20))
            make.centerY.equalTo(backButton)
            make.width.equalTo(kFitWidth(48))
            make.height.equalTo(kFitWidth(40))
        }

        view.addSubview(bottomSheetView)
        bottomSheetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    /// 处理返回按钮点击。
    @objc func backButtonAction() {
        if let navigationController = navigationController,
           navigationController.viewControllers.first !== self {
            navigationController.popViewController(animated: true)
            return
        }

        if presentingViewController != nil {
            dismiss(animated: true)
        }
    }

    /// 处理右上角操作按钮点击。
    @objc func operationButtonAction() {
        showOperationSheet()
    }

    /// 步骤 1 开始时进入身体信息采集流程。
    func startButtonAction() {
        guard vm.steps.first?.isActive == true else { return }
        let vc = Guide0820BodyProfileVC()
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
        bottomSheetView.present(contentView: operationView,
                                contentHeight: kFitWidth(272.5),
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

    /// 清除来源问卷数据并回退到 Guide0820VC 的上一个页面。
    func clearGuideSourceDataAndReturn() {
        Guide0820SourceStorage.clear()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.returnToPreviousPageBeforeGuide()
        }
    }

    /// 回退到导航栈中 Guide0820VC 的上一个页面。
    func returnToPreviousPageBeforeGuide() {
        guard let navigationController = navigationController else {
            dismiss(animated: true)
            return
        }

        guard let guideIndex = navigationController.viewControllers.firstIndex(where: { $0 is Guide0820VC }),
              guideIndex > 0 else {
            navigationController.popViewController(animated: true)
            return
        }

        let previousViewController = navigationController.viewControllers[guideIndex - 1]
        navigationController.popToViewController(previousViewController, animated: true)
    }
}
