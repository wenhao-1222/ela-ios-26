//
//  GuidanceGoalPlanVC.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit
import SnapKit

final class GuidanceGoalPlanVC: WHBaseViewVC {
    var finishBlock: ((GuidanceGoalPlanFlowState) -> Void)?

    private let flowState = GuidanceGoalPlanFlowState()
    private var currentIndex = 0
    private var currentPageView: UIView?
    private var pageCache: [String: UIView] = [:]

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

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        return stack
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "明确你的方向"
        label.textAlignment = .center
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()

    private let progressTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.1)
        view.layer.cornerRadius = kFitWidth(2)
        view.clipsToBounds = true
        return view
    }()

    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_TEXT_TITLE_0f1214
        view.layer.cornerRadius = kFitWidth(2)
        view.clipsToBounds = true
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("‹", for: .normal)
        button.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 36, weight: .regular)
        button.addTarget(self, action: #selector(backButtonTapAction), for: .touchUpInside)
        return button
    }()

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

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        // Every new instance starts a fresh flow from the first step. Do not
        // restore the previous answers or page index here.
        showPage(at: currentIndex, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

private extension GuidanceGoalPlanVC {
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

    func refreshNavigationState() {
        let total = max(flowState.steps.count, 6)
        nextButton.setTitle(currentIndex == total - 1 ? "完成" : "下一步", for: .normal)

        let canContinue = (currentPageView as? (UIView & GuidanceGoalPlanPageVM))?.hasSelection ?? false
        nextButton.isEnabled = canContinue
        nextButton.backgroundColor = canContinue ? .THEME : .COLOR_BUTTON_DISABLE_BG_THEME
        updateProgress()
    }

    func updateProgress() {
        let total = max(flowState.steps.count, 6)
        let ratio = CGFloat(currentIndex + 1) / CGFloat(total)
        progressView.snp.remakeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(progressTrackView.snp.width).multipliedBy(ratio)
        }
        UIView.animate(withDuration: 0.2) {
            self.progressTrackView.layoutIfNeeded()
        }
    }

    func finishFlow() {
        persistCurrentProgress()
        Guide0820ProgressStorage.markStepCompleted(.directionProfile)
        if let finishBlock = finishBlock {
            finishBlock(flowState)
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

    func persistCurrentProgress() {
        Guide0820ProgressStorage.saveDirectionProfile(flowState: flowState)
        Guide0820ProgressStorage.saveCurrentPageIndex(currentIndex, for: .directionProfile)
        Guide0820ProgressStorage.recordFurthestPageIndex(currentIndex, for: .directionProfile)
    }

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

    @objc func nextButtonTapAction() {
        guard nextButton.isEnabled else { return }
        let nextIndex = currentIndex + 1
        if flowState.steps.indices.contains(nextIndex) {
            showPage(at: nextIndex, animated: true)
            return
        }
        finishFlow()
    }

    func pageCacheKey(for step: GuidanceGoalPlanStep) -> String {
        "\(step.rawValue)|\(flowState.target?.rawValue ?? "none")"
    }
}
