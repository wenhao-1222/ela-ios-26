//
//  GuidanceGoalPlanVC.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit
import SnapKit

/// GuidanceGoalPlanVC 类型，封装 Guide0820 引导流程中的相关功能。
final class GuidanceGoalPlanVC: WHBaseViewVC {
    /// `finishBlock` 属性，保存该类型对外提供或内部使用的状态与配置。
    var finishBlock: ((GuidanceGoalPlanFlowState) -> Void)?

    // `flowState` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let flowState = GuidanceGoalPlanFlowState()
    /// The direction flow always contains seven pages, regardless of the
    /// target selected on the first page.
    private let progressTotalStepCount = 7
    // `currentIndex` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var currentIndex = 0
    // `currentPageView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var currentPageView: UIView?
    // `pageCache` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var pageCache: [String: UIView] = [:]

    // `scrollView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isPagingEnabled = true
        view.isScrollEnabled = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.bounces = false
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()

    // `stackView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        return stack
    }()

    // `titleLabel` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "明确你的方向"
        label.textAlignment = .center
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()

    // `progressTrackView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let progressTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.1)
        view.layer.cornerRadius = kFitWidth(2)
        view.clipsToBounds = true
        return view
    }()

    // `progressView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_TEXT_TITLE_0f1214
        view.layer.cornerRadius = kFitWidth(2)
        view.clipsToBounds = true
        return view
    }()

    // `backButton` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var backButton: ElaLiquidGlassCloseButton = {
        let button = ElaLiquidGlassCloseButton()
        button.iconImage = UIImage(named: "guide_back_button")
        button.iconColor = .COLOR_TEXT_TITLE_0f1214
        button.iconSize = kFitWidth(20)
        button.showsOuterStroke = true
        button.addTarget(self, action: #selector(backButtonTapAction), for: .touchUpInside)
        return button
    }()

    // `nextButton` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(.COLOR_TEXT_WHITE, for: .normal)
        button.setTitleColor(.COLOR_TEXT_WHITE, for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: guide0820Design(34), weight: .medium)
        button.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
        button.layer.cornerRadius = guide0820Design(24)
        button.layer.cornerCurve = .continuous
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)
        button.enablePressEffect()
        return button
    }()

    /// 执行 `viewDidLoad` 操作，完成当前引导页面的状态更新或交互处理。
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        // Every new instance starts a fresh flow from the first step. Do not
        // restore the previous answers or page index here.
        showPage(at: currentIndex, animated: false)
    }

    /// 执行 `viewWillAppear` 操作，完成当前引导页面的状态更新或交互处理。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// GuidanceGoalPlanVC 扩展，提供 Guide0820 流程相关的辅助能力。
private extension GuidanceGoalPlanVC {
    // 执行 `initUI` 操作，完成当前引导页面的状态更新或交互处理。
    func initUI() {
        view.backgroundColor = GuidanceGoalPlanStyle.pageBackgroundColor
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(progressTrackView)
        view.addSubview(scrollView)
        view.addSubview(nextButton)

        backButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(8))
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(kFitWidth(2))
            make.width.height.equalTo(kFitWidth(44))
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
        }

        progressTrackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(42))
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(guide0820Design(96))
            make.height.equalTo(guide0820Design(8))
        }

        progressTrackView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }

        nextButton.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(32))
            make.right.equalTo(guide0820Design(-32))
            make.height.equalTo(guide0820Design(104))
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide)
        }

        view.bringSubviewToFront(backButton)
        view.bringSubviewToFront(titleLabel)
        view.bringSubviewToFront(progressTrackView)
        view.bringSubviewToFront(nextButton)
    }

    // 执行 `showPage` 操作，完成当前引导页面的状态更新或交互处理。
    func showPage(at index: Int, animated: Bool) {
        let steps = flowState.steps
        guard steps.indices.contains(index) else { return }
        currentIndex = index
        persistCurrentProgress()

        installPages(steps)
        view.layoutIfNeeded()
        let nextPage = page(for: steps[index])
        currentPageView = nextPage
        // Keep the same page-width calculation as the other Guide0820 flow VCs.
        scrollView.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(index), y: 0), animated: animated)
        refreshNavigationState()
        (nextPage as? (UIView & GuidanceGoalPlanPageVM))?.pageWillAppear()
    }

    // 执行 `installPages` 操作，完成当前引导页面的状态更新或交互处理。
    func installPages(_ steps: [GuidanceGoalPlanStep]) {
        stackView.arrangedSubviews.forEach { page in
            stackView.removeArrangedSubview(page)
            page.removeFromSuperview()
        }

        steps.forEach { step in
            let page = page(for: step)
            stackView.addArrangedSubview(page)
            page.snp.remakeConstraints { make in
                make.width.equalTo(scrollView.frameLayoutGuide)
            }
        }
    }

    // 执行 `page` 操作，完成当前引导页面的状态更新或交互处理。
    func page(for step: GuidanceGoalPlanStep) -> UIView {
        let cacheKey = pageCacheKey(for: step)
        if let page = pageCache[cacheKey] {
            return page
        }

        let page: UIView
        switch step {
        case .goal:
            page = GuidanceGoalPlanGoalVM(flowState: flowState)
        case .profile, .muscleGainProfile, .fatLossProfile:
            page = GuidanceGoalPlanProfileVM(flowState: flowState)
        case .muscleGainBarrier:
            page = GuidanceGoalPlanMuscleGainBarrierVM(flowState: flowState)
        case .muscleGainProteinHabit:
            page = GuidanceGoalPlanMuscleGainProteinHabitVM(flowState: flowState)
        case .muscleGainMode:
            page = GuidanceGoalPlanMuscleGainModeVM(flowState: flowState)
        case .muscleGainDuration:
            page = GuidanceGoalPlanMuscleGainDurationVM(flowState: flowState)
        case .fatLossFoodFluctuation:
            page = GuidanceGoalPlanFatLossFoodFluctuationVM(flowState: flowState)
        case .fatLossMode:
            page = GuidanceGoalPlanFatLossModeVM(flowState: flowState)
        case .fatLossDuration:
            page = GuidanceGoalPlanFatLossDurationVM(flowState: flowState)
        case .fatLossProteinHabit:
            page = GuidanceGoalPlanFatLossProteinHabitVM(flowState: flowState)
        case .foodAdjustment:
            page = GuidanceGoalPlanFoodAdjustmentVM(flowState: flowState)
        }

        if let pageVM = page as? (UIView & GuidanceGoalPlanPageVM) {
            pageVM.selectionChanged = { [weak self] in
                self?.persistCurrentProgress()
                self?.refreshNavigationState()
            }
        }
        pageCache[cacheKey] = page
        return page
    }

    // 执行 `refreshNavigationState` 操作，完成当前引导页面的状态更新或交互处理。
    func refreshNavigationState() {
        let total = progressTotalStepCount
        nextButton.setTitle(currentIndex == total - 1 ? "完成" : "下一步", for: .normal)

        let canContinue = (currentPageView as? (UIView & GuidanceGoalPlanPageVM))?.hasSelection ?? false
        nextButton.isEnabled = canContinue
        nextButton.backgroundColor = canContinue ? .THEME : .COLOR_BUTTON_DISABLE_BG_THEME
        updateProgress()
    }

    // 执行 `updateProgress` 操作，完成当前引导页面的状态更新或交互处理。
    func updateProgress() {
        let total = progressTotalStepCount
        let ratio = CGFloat(currentIndex + 1) / CGFloat(total)
        progressView.snp.remakeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(progressTrackView.snp.width).multipliedBy(ratio)
        }
        UIView.animate(withDuration: 0.2) {
            self.progressTrackView.layoutIfNeeded()
        }
    }

    // 执行 `finishFlow` 操作，完成当前引导页面的状态更新或交互处理。
    func finishFlow() {
        persistCurrentProgress()
        Guide0820ProgressStorage.markStepCompleted(.directionProfile)
        if let finishBlock = finishBlock {
            finishBlock(flowState)
            return
        }

        // Keep the flow connected even when this VC is opened directly (for
        // example from a resumed navigation stack) without an external
        // finishBlock.
        if let navigationController {
            let progressVC = GuidanceNutritionGoalsProgressVC(flowState: flowState)
            progressVC.finishBlock = { [weak progressVC] _ in
                progressVC?.navigationController?.popViewController(animated: true)
            }
            navigationController.pushViewController(progressVC, animated: true)
            return
        }

        if let navigationController = navigationController,
           navigationController.viewControllers.first !== self {
            navigationController.popViewController(animated: true)
            return
        }

        if presentingViewController != nil {
            dismiss(animated: true)
        }
    }

    // 执行 `persistCurrentProgress` 操作，完成当前引导页面的状态更新或交互处理。
    func persistCurrentProgress() {
        Guide0820ProgressStorage.saveDirectionProfile(flowState: flowState)
        Guide0820ProgressStorage.saveCurrentPageIndex(currentIndex, for: .directionProfile)
        Guide0820ProgressStorage.recordFurthestPageIndex(currentIndex, for: .directionProfile)
    }

    // 执行 `backButtonTapAction` 操作，完成当前引导页面的状态更新或交互处理。
    @objc func backButtonTapAction() {
        if currentIndex > 0 {
            showPage(at: currentIndex - 1, animated: true)
            return
        }

        if let navigationController = navigationController,
           navigationController.viewControllers.first !== self {
            navigationController.popViewController(animated: true)
            return
        }

        if presentingViewController != nil {
            dismiss(animated: true)
        }
    }

    // 执行 `nextButtonTapAction` 操作，完成当前引导页面的状态更新或交互处理。
    @objc func nextButtonTapAction() {
        guard nextButton.isEnabled else { return }
        let nextIndex = currentIndex + 1
        if flowState.steps.indices.contains(nextIndex) {
            showPage(at: nextIndex, animated: true)
            return
        }
        finishFlow()
    }

    // 执行 `pageCacheKey` 操作，完成当前引导页面的状态更新或交互处理。
    func pageCacheKey(for step: GuidanceGoalPlanStep) -> String {
        "\(step.rawValue)|\(flowState.target?.rawValue ?? "none")"
    }
}
