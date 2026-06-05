//
//  AIGuidanceVC.swift
//  lns
//  AI教练  问卷
//  Created by LNS2 on 2026/3/24.
//

import UIKit
import SnapKit

class AIGuidanceVC: WHBaseViewVC {

    enum FlowStep: Hashable {
        case goal
        case goalStage
        case coachStrictness
        case notice
        case elaProIntro
        case readyStart
    }

    private enum AICoachProfileSubmitState {
        case idle
        case submitting
        case success
        case failed(String?)
    }

    var currentIndex: Int = 0
    private var mountedSteps = Set<FlowStep>()
    private let totalSteps = 6
    private var isSubmittingAICoachProfile = false
    private var aiCoachProfileSubmitState: AICoachProfileSubmitState = .idle
    private var activeAICoachProfileSubmitKey: String?
    private var successfulAICoachProfileSubmitKey: String?
    private var aiCoachProfileSubmitCompletions: [() -> Void] = []
    private var shouldShowAICoachProfileSubmitFailureAlert = false
    private var isBackButtonCoolingDown = false
    private var isStepTransitioning = false
    private var scrollDragStartIndex: Int?
    private var isScrollBackInteractionInProgress = false
    private weak var fullscreenPopGestureFailureNavigationController: UINavigationController?
    private var backSwipeBackgroundSourceStep: FlowStep?
    private var sharedBackgroundShouldBeVisible = false
    private var shouldHideProgressViews = false
    private lazy var backEdgePanGesture: UIScreenEdgePanGestureRecognizer = {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleBackEdgePan(_:)))
        gesture.edges = .left
        gesture.delegate = self
        return gesture
    }()

    private lazy var sharedBackgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ela_pro_ai_bg"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0
        imageView.isHidden = true
        return imageView
    }()

    private let sharedBackgroundTransitionDuration: TimeInterval = 0.25
    private let introViewFadeDuration: TimeInterval = 0.25
    private var isIntroVisible: Bool {
        introVm.superview != nil && !introVm.isHidden && introVm.alpha > 0.01
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        canEdgeBack = false
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePopGestureState()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updatePopGestureState()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isStepTransitioning = false
        isScrollBackInteractionInProgress = false
        backSwipeBackgroundSourceStep = nil
        scrollViewBase.isScrollEnabled = true
        restoreFullscreenInteractivePopGesture()
    }

    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
        vm.backButton.isHidden = false
        vm.backTapBlock = {[weak self] in
            self?.navigateBackOneStep()
        }
        return vm
    }()
    lazy var stepsArray: [Int] = [1,1,1]
    lazy var nextButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.isHidden = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)

        return btn
    }()
    lazy var introVm: AIGuidanceIntroVM = {
        let vm = AIGuidanceIntroVM(frame: .zero)
        vm.startBlock = { [weak self] in
            self?.dismissIntroVm()
        }
        return vm
    }()
    lazy var goalVm: AIGuidanceGoalVM = {
        let vm = AIGuidanceGoalVM.init(frame: .zero)
        vm.selectedBlock = { [weak self] in
            self?.handleAICoachQuestionnaireSelectionChanged()
        }
        return vm
    }()
    lazy var goalStageVm: AIGuidanceGoalStageVM = {
        let vm = AIGuidanceGoalStageVM.init(frame: .zero)
        vm.selectedBlock = { [weak self] in
            self?.handleAICoachQuestionnaireSelectionChanged()
        }
        vm.infoButtonTapBlock = { [weak self] content in
            self?.showGoalStageInfoAlert(content: content)
        }
        return vm
    }()
    lazy var goalStageInfoAlertVm: AIGuidanceGoalStageInfoAlertVM = {
        let vm = AIGuidanceGoalStageInfoAlertVM(frame: .zero)
        return vm
    }()
    lazy var coachStrictnessVm: AIGuidanceCoachStrictnessVM = {
        let vm = AIGuidanceCoachStrictnessVM.init(frame: .zero)
        vm.selectedBlock = { [weak self] in
            self?.handleAICoachQuestionnaireSelectionChanged()
        }
        return vm
    }()
    lazy var noticeVm: AIGuidanceNoticeVM = {
        let vm = AIGuidanceNoticeVM.init(frame: .zero)
        return vm
    }()
    lazy var elaProIntroVm: AIGuidanceElaProIntroVM = {
        let vm = AIGuidanceElaProIntroVM.init(frame: .zero)
        return vm
    }()
    lazy var readyStartVm: AIGuidanceReadyStartVM = {
        let vm = AIGuidanceReadyStartVM.init(frame: .zero)
        return vm
    }()
}

extension AIGuidanceVC{
    @objc func handleBackEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard gesture.state == .recognized else { return }
        navigateBackOneStep()
    }

    func navigateBackOneStep() {
        guard !isBackButtonCoolingDown else { return }
        guard !isSubmittingAICoachProfile else { return }
        guard !isStepTransitioning, !isScrollBackInteractionInProgress else { return }
        startBackButtonCooldown()
        if currentIndex == 0 {
            backTapAction()
            return
        }
        moveToStep(index: currentIndex - 1, animated: true)
    }

    func startBackButtonCooldown() {
        isBackButtonCoolingDown = true
        naviVm.backButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            self.isBackButtonCoolingDown = false
            self.naviVm.backButton.isEnabled = true
        }
    }

    @objc func nextButtonTapAction() {
        guard !isStepTransitioning, !isScrollBackInteractionInProgress else { return }
        guard let currentStep = flowStep(for: currentIndex) else {
            return
        }

        switch currentStep {
        case .goal:
            goalStageVm.refreshContentForCurrentGoal()
            coachStrictnessVm.refreshContentForCurrentGoal()
            moveToStep(index: 1, animated: true)
        case .goalStage:
            moveToStep(index: 2, animated: true)
        case .coachStrictness:
            moveToStep(index: 3, animated: true)
        case .notice:
            moveToStep(index: 4, animated: true)
        case .elaProIntro:
//            if UserInfoModel.shared.vipModel.isValidVip {
//                submitAICoachProfile { [weak self] in
//                    self?.enterAICoachPrePage()
//                }
//            } else {
                moveToStep(index: 5, animated: true)
//            }
        case .readyStart:
            submitAICoachProfile { [weak self] in
                self?.enterElaProPage()
            }
        }
    }

    func flowStep(for index: Int) -> FlowStep? {
        switch index {
        case 0:
            return .goal
        case 1:
            return .goalStage
        case 2:
            return .coachStrictness
        case 3:
            return .notice
        case 4:
            return .elaProIntro
        case 5:
            return .readyStart
        default:
            return nil
        }
    }

    func stepView(for step: FlowStep) -> UIView? {
        switch step {
        case .goal:
            return goalVm
        case .goalStage:
            return goalStageVm
        case .coachStrictness:
            return coachStrictnessVm
        case .notice:
            return noticeVm
        case .elaProIntro:
            return elaProIntroVm
        case .readyStart:
            return readyStartVm
        }
    }

    func installStepViewsIfNeeded(indexes: [Int]) {
        for index in indexes {
            guard let step = flowStep(for: index),
                  let stepView = stepView(for: step) else {
                continue
            }
            mountedSteps.insert(step)
            stepView.isHidden = false
            stepView.frame = CGRect(x: SCREEN_WIDHT * CGFloat(index), y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
            guard stepView.superview == nil else {
                continue
            }
            scrollViewBase.addSubview(stepView)
        }
    }

    func moveToStep(index: Int, animated: Bool) {
        guard !isStepTransitioning || !animated || index == currentIndex else { return }
        let targetIndex = max(0, min(index, totalSteps - 1))
        let previousStep = flowStep(for: currentIndex)
        let targetOffset = CGPoint(x: SCREEN_WIDHT * CGFloat(targetIndex), y: 0)
        prepareStepTransition(to: targetOffset.x, animated: animated)
        currentIndex = targetIndex
        scrollViewBase.setContentOffset(targetOffset, animated: animated)
        updatePopGestureState()
        updateNavigationForCurrentStep(from: previousStep, animated: animated)
        updateNextButtonForCurrentStep()
        if !animated {
            finishStepTransitionIfNeeded(animated: animated)
        }
        EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW,
                                            scenarioType: .ai_coach_guide,
                                            text: "\(targetIndex + 1)")
        if flowStep(for: targetIndex) == .notice {
            submitAICoachProfile(showFailureAlert: false)
        }
    }
    
    func updatePopGestureState() {
        configureScrollPanFailureRequirementIfNeeded()
        let shouldAllowFullscreenPop = currentIndex == 0 && !isIntroVisible
        updateInteractivePopGestureBlocked(!shouldAllowFullscreenPop)
    }

    func configureScrollPanFailureRequirementIfNeeded() {
        guard fullscreenPopGestureFailureNavigationController !== navigationController,
              let navigationController = navigationController else {
            return
        }
        scrollViewBase.panGestureRecognizer.require(toFail: navigationController.fd_fullscreenPopGestureRecognizer)
        fullscreenPopGestureFailureNavigationController = navigationController
    }

    func updateNextButtonForCurrentStep() {
        guard let currentStep = flowStep(for: currentIndex) else {
            nextButton.isEnabled = false
            return
        }
        if isSubmittingAICoachProfile {
            nextButton.isHidden = false
            nextButton.isEnabled = false
            return
        }

        switch currentStep {
        case .goal:
            nextButton.isHidden = false
            nextButton.isEnabled = goalVm.hasSelection
        case .goalStage:
            nextButton.isHidden = false
            nextButton.isEnabled = goalStageVm.hasSelection
        case .coachStrictness:
            nextButton.isHidden = false
            nextButton.isEnabled = coachStrictnessVm.hasSelection
        case .notice:
            nextButton.isHidden = false
            nextButton.isEnabled = true
        case .elaProIntro:
            nextButton.isHidden = false
            nextButton.isEnabled = true
        case .readyStart:
            nextButton.isHidden = false
            nextButton.isEnabled = true
        }

        updateNextButtonTitle(for: currentStep)
    }

    func updateNavigationForCurrentStep(from previousStep: FlowStep? = nil, animated: Bool = false) {
        guard let currentStep = flowStep(for: currentIndex) else {
            return
        }

        let shouldShowBackground = usesSharedBackground(for: currentStep)
        let previousShouldShowBackground = previousStep.map { usesSharedBackground(for: $0) } ?? shouldShowBackground
        updateSharedBackgroundVisibility(shouldShow: shouldShowBackground,
                                         animated: animated && previousShouldShowBackground != shouldShowBackground)

        let shouldHideProgress = shouldShowBackground
        updateProgressVisibility(
            shouldHide: shouldHideProgress,
            wasHidden: previousShouldShowBackground,
            animated: animated
        )
        let isCloseStyle = currentStep == .readyStart
        let backImageName = isCloseStyle ? "navi_close_icon" : "habit_guide_back_icon"
        naviVm.backButton.setImage(UIImage(named: backImageName), for: .normal)

        if shouldHideProgress == false {
            naviVm.updateStep(steps: stepsArray, currentStep: currentIndex)
        }
    }

    func updateProgressVisibility(shouldHide: Bool, wasHidden: Bool, animated: Bool) {
        shouldHideProgressViews = shouldHide
        let progressViews = [naviVm.firstStepVm, naviVm.secondStepVm, naviVm.thirdStepVm]
        progressViews.forEach { $0.layer.removeAllAnimations() }

        if shouldHide {
            progressViews.forEach { progressView in
                if animated && !wasHidden {
                    UIView.animate(withDuration: sharedBackgroundTransitionDuration,
                                   delay: 0,
                                   options: [.curveEaseInOut, .beginFromCurrentState]) {
                        progressView.alpha = 0
                    } completion: { [weak self] _ in
                        guard self?.shouldHideProgressViews == true else { return }
                        progressView.isHidden = true
                    }
                } else {
                    progressView.alpha = 1
                    progressView.isHidden = true
                }
            }
            return
        }

        progressViews.forEach { progressView in
            progressView.isHidden = false
            if animated && wasHidden {
                progressView.alpha = 0
                UIView.animate(withDuration: sharedBackgroundTransitionDuration,
                               delay: 0,
                               options: [.curveEaseInOut, .beginFromCurrentState]) {
                    progressView.alpha = 1
                } completion: { [weak self] _ in
                    guard self?.shouldHideProgressViews == false else { return }
                    progressView.isHidden = false
                    progressView.alpha = 1
                }
            } else {
                progressView.alpha = 1
            }
        }
    }

    func usesSharedBackground(for step: FlowStep) -> Bool {
        step == .notice || step == .elaProIntro || step == .readyStart
    }

    func updateSharedBackgroundVisibility(shouldShow: Bool, animated: Bool) {
        sharedBackgroundShouldBeVisible = shouldShow
        sharedBackgroundImageView.layer.removeAllAnimations()

        guard animated else {
            sharedBackgroundImageView.alpha = shouldShow ? 1 : 0
            sharedBackgroundImageView.isHidden = !shouldShow
            return
        }

        sharedBackgroundImageView.isHidden = false
        if shouldShow {
            sharedBackgroundImageView.alpha = 0
            UIView.animate(withDuration: sharedBackgroundTransitionDuration,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState]) {
                self.sharedBackgroundImageView.alpha = 1
            } completion: { [weak self] _ in
                guard let self = self, self.sharedBackgroundShouldBeVisible else { return }
                self.sharedBackgroundImageView.isHidden = false
                self.sharedBackgroundImageView.alpha = 1
            }
        } else {
            sharedBackgroundImageView.alpha = 1
            UIView.animate(withDuration: sharedBackgroundTransitionDuration,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState]) {
                self.sharedBackgroundImageView.alpha = 0
            } completion: { [weak self] _ in
                guard let self = self else { return }
                guard !self.sharedBackgroundShouldBeVisible else { return }
                self.sharedBackgroundImageView.isHidden = true
                self.sharedBackgroundImageView.alpha = 0
            }
        }
    }

    func updateNextButtonTitle(for step: FlowStep) {
        let title = step == .readyStart ? "即刻开始" : "下一步"
        naviVm.backButton.isHidden = step == .readyStart ? true : false
        nextButton.setTitle(title, for: .normal)
        nextButton.setTitle(title, for: .disabled)
    }

    func dismissIntroVm() {
        introVm.isUserInteractionEnabled = false
        UIView.animate(withDuration: introViewFadeDuration,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState]) {
            self.introVm.alpha = 0
        } completion: { [weak self] _ in
            self?.introVm.removeFromSuperview()
            self?.updatePopGestureState()
        }
    }

    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(sharedBackgroundImageView)
        view.addSubview(scrollViewBase)
        view.addSubview(naviVm)
        view.addSubview(nextButton)
        view.addSubview(introVm)
        view.addSubview(goalStageInfoAlertVm)

        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.isScrollEnabled = true
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.bounces = false
        scrollViewBase.delegate = self
        scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT * CGFloat(totalSteps), height: SCREEN_HEIGHT)
        view.addGestureRecognizer(backEdgePanGesture)

        installStepViewsIfNeeded(indexes: [0, 1, 2, 3, 4, 5])
        setConstrait()
        moveToStep(index: 0, animated: false)
    }

    func setConstrait() {
        sharedBackgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }

        introVm.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        goalStageInfoAlertVm.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AIGuidanceVC {
    func showGoalStageInfoAlert(content: AIGuidanceGoalStageVM.StageInfoContent) {
        view.bringSubviewToFront(goalStageInfoAlertVm)
        goalStageInfoAlertVm.show(content: content)
    }

    func enterElaProPage() {
        VIPModel.shared.isAiCoachSurveyFinished = true
        if VIPModel.shared.status == .valid{
            let vc = AICoachPreVC()
            navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = ElaProVC()
            vc.showPriceOnly = true
            vc.priceBizType = "2"
            vc.priceDisplayMode = .aiGuidance
            vc.popToRootOnClose = true
            vc.enterAICoachPreOnPurchaseSuccess = true
            pushElaProVCWhenReady(vc)
        }
    }

    func enterAICoachPrePage() {
        let vc = AICoachPreVC()
        navigationController?.pushViewController(vc, animated: true)
    }

    func handleAICoachQuestionnaireSelectionChanged() {
        aiCoachProfileSubmitState = .idle
        activeAICoachProfileSubmitKey = nil
        successfulAICoachProfileSubmitKey = nil
        aiCoachProfileSubmitCompletions.removeAll()
        shouldShowAICoachProfileSubmitFailureAlert = false
        isSubmittingAICoachProfile = false
        updateNextButtonForCurrentStep()
    }

    func submitAICoachProfile(showFailureAlert: Bool = true, completion: (() -> Void)? = nil) {
        let param = buildAICoachUpsertParameters()
        let submitKey = aiCoachProfileSubmitKey(for: param)

        if successfulAICoachProfileSubmitKey == submitKey {
            completion?()
            return
        }

        if case .submitting = aiCoachProfileSubmitState,
           activeAICoachProfileSubmitKey == submitKey {
            if showFailureAlert {
                isSubmittingAICoachProfile = true
                shouldShowAICoachProfileSubmitFailureAlert = true
                updateNextButtonForCurrentStep()
            }
            if let completion = completion {
                aiCoachProfileSubmitCompletions.append(completion)
            }
            return
        }

        if let completion = completion {
            aiCoachProfileSubmitCompletions.append(completion)
        }

        activeAICoachProfileSubmitKey = submitKey
        aiCoachProfileSubmitState = .submitting
        shouldShowAICoachProfileSubmitFailureAlert = showFailureAlert
        isSubmittingAICoachProfile = showFailureAlert
        updateNextButtonForCurrentStep()

        DLLog(message: "submitAICoachProfile:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_ai_coach_upsert,
                                          parameters: param as [String : AnyObject],
                                          isNeedToast: showFailureAlert,
                                          vc: showFailureAlert ? self : nil) { [weak self] responseObject in
            guard let self = self else { return }
            let code = responseObject["code"] as? Int ?? -1
            guard code == 200 else {
                let msg = responseObject["message"] as? String ?? "保存失败，请稍后重试"
                self.handleAICoachSubmitFailure(message: msg, submitKey: submitKey)
                return
            }
            self.handleAICoachSubmitSuccess(submitKey: submitKey)
        } failure: { [weak self] _ in
            self?.handleAICoachSubmitFailure(message: nil, submitKey: submitKey)
        }
    }

    func buildAICoachUpsertParameters() -> [String: Any] {
        let isMuscleGainGoal = ["4", "5", "7"].contains(QuestinonaireMsgModel.shared.goal)
        var param: [String: Any] = [
            "userGoal": isMuscleGainGoal ? 2 : 1
        ]

        if isMuscleGainGoal {
            if let muscleGainPhase = buildMuscleGainPhaseValue() {
                param["muscleGainPhase"] = muscleGainPhase
            }
        } else {
            if let fatLossPhase = buildFatLossPhaseValue() {
                param["fatLossPhase"] = fatLossPhase
            }
        }

        if let intensityPreference = buildAICoachIntensityPreferenceValue() {
            param["aiCoachIntensityPreference"] = intensityPreference
        }

        return param
    }

    func buildMuscleGainPhaseValue() -> Int? {
        let mapping: [String: Int] = [
            "gain_prepare": 1,
            "gain_less_1_month": 2,
            "gain_1_3_months": 3,
            "gain_3_12_months": 4,
            "gain_over_1_year": 5
        ]
        return mapping[QuestinonaireMsgModel.shared.aiGuidanceGoalStageType]
    }

    func buildFatLossPhaseValue() -> Int? {
        let mapping: [String: Int] = [
            "fat_prepare": 1,
            "fat_less_2_weeks": 2,
            "fat_2_6_weeks": 3,
            "fat_7_12_weeks": 4,
            "fat_over_12_weeks": 5
        ]
        return mapping[QuestinonaireMsgModel.shared.aiGuidanceGoalStageType]
    }

    func buildAICoachIntensityPreferenceValue() -> Int? {
        let mapping: [String: Int] = [
            "very_relaxed": 1,
            "relaxed": 2,
            "normal": 3,
            "enthusiast": 4,
            "athlete": 5
        ]
        return mapping[QuestinonaireMsgModel.shared.aiGuidanceCoachStrictnessType]
    }

    func aiCoachProfileSubmitKey(for parameters: [String: Any]) -> String {
        parameters.keys.sorted().map { key in
            "\(key)=\(parameters[key] ?? "")"
        }.joined(separator: "&")
    }

    func handleAICoachSubmitSuccess(submitKey: String) {
        guard activeAICoachProfileSubmitKey == submitKey else { return }
        let completions = aiCoachProfileSubmitCompletions
        aiCoachProfileSubmitState = .success
        activeAICoachProfileSubmitKey = nil
        successfulAICoachProfileSubmitKey = submitKey
        aiCoachProfileSubmitCompletions.removeAll()
        shouldShowAICoachProfileSubmitFailureAlert = false
        isSubmittingAICoachProfile = false
        updateNextButtonForCurrentStep()
        completions.forEach { $0() }
    }

    func handleAICoachSubmitFailure(message: String?, submitKey: String) {
        guard activeAICoachProfileSubmitKey == submitKey else { return }
        let shouldShowFailureAlert = shouldShowAICoachProfileSubmitFailureAlert
        aiCoachProfileSubmitState = .failed(message)
        activeAICoachProfileSubmitKey = nil
        successfulAICoachProfileSubmitKey = nil
        aiCoachProfileSubmitCompletions.removeAll()
        shouldShowAICoachProfileSubmitFailureAlert = false
        isSubmittingAICoachProfile = false
        updateNextButtonForCurrentStep()

        guard shouldShowFailureAlert else {
            return
        }
        guard let message = message, !message.isEmpty else {
            return
        }

        let alertVc = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "确定", style: .cancel)
        alertVc.addAction(confirmAction)
        present(alertVc, animated: true)
    }
}

extension AIGuidanceVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === backEdgePanGesture else { return true }
        guard !isIntroVisible else { return false }
        guard !isStepTransitioning, !isScrollBackInteractionInProgress else { return false }
        guard currentIndex > 0 else { return false }
        guard flowStep(for: currentIndex) != .readyStart else { return false }
        return !isBackButtonCoolingDown && !isSubmittingAICoachProfile
    }
}

extension AIGuidanceVC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === scrollViewBase else { return }
        guard !isIntroVisible else {
            scrollDragStartIndex = nil
            return
        }
        guard !isSubmittingAICoachProfile, !isStepTransitioning else {
            scrollDragStartIndex = nil
            return
        }
        guard flowStep(for: currentIndex) != .readyStart else {
            scrollDragStartIndex = nil
            return
        }
        scrollDragStartIndex = currentIndex
        isScrollBackInteractionInProgress = true
        prepareSharedBackgroundForBackSwipeIfNeeded(from: currentIndex)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView === scrollViewBase else { return }
        let startIndex = scrollDragStartIndex ?? currentIndex
        let offsetRange = allowedBackScrollOffsetRange(from: startIndex)
        targetContentOffset.pointee.x = min(max(targetContentOffset.pointee.x, offsetRange.min), offsetRange.max)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === scrollViewBase else { return }
        if scrollView.isDragging || scrollView.isDecelerating {
            let startIndex = scrollDragStartIndex ?? currentIndex
            let offsetRange = allowedBackScrollOffsetRange(from: startIndex)
            if scrollView.contentOffset.x > offsetRange.max {
                scrollView.contentOffset.x = offsetRange.max
            } else if scrollView.contentOffset.x < offsetRange.min {
                scrollView.contentOffset.x = offsetRange.min
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        syncCurrentStepWithScrollView(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        syncCurrentStepWithScrollView(scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        syncCurrentStepWithScrollView(scrollView)
    }

    private func updateScrollViewBaseScrollAvailability() {
        scrollViewBase.isScrollEnabled = !isStepTransitioning && flowStep(for: currentIndex) != .readyStart
    }

    private func prepareSharedBackgroundForBackSwipeIfNeeded(from startIndex: Int) {
        let targetIndex = max(startIndex - 1, 0)
        guard targetIndex < startIndex,
              let sourceStep = flowStep(for: startIndex),
              let targetStep = flowStep(for: targetIndex) else {
            return
        }
        let sourceUsesBackground = usesSharedBackground(for: sourceStep)
        let targetUsesBackground = usesSharedBackground(for: targetStep)
        guard sourceUsesBackground != targetUsesBackground else { return }

        backSwipeBackgroundSourceStep = sourceStep
        updateSharedBackgroundVisibility(shouldShow: targetUsesBackground, animated: true)
    }

    private func restoreSharedBackgroundAfterCancelledBackSwipeIfNeeded() {
        guard let sourceStep = backSwipeBackgroundSourceStep else { return }
        updateSharedBackgroundVisibility(shouldShow: usesSharedBackground(for: sourceStep), animated: true)
        backSwipeBackgroundSourceStep = nil
    }

    private func allowedBackScrollOffsetRange(from startIndex: Int) -> (min: CGFloat, max: CGFloat) {
        let currentOffsetX = SCREEN_WIDHT * CGFloat(max(startIndex, 0))
        let previousOffsetX = SCREEN_WIDHT * CGFloat(max(startIndex - 1, 0))
        return (min: previousOffsetX, max: currentOffsetX)
    }

    private func prepareStepTransition(to targetOffsetX: CGFloat, animated: Bool) {
        isStepTransitioning = animated && abs(scrollViewBase.contentOffset.x - targetOffsetX) > 0.5
        updateScrollViewBaseScrollAvailability()
    }

    private func finishStepTransitionIfNeeded(animated: Bool) {
        if !animated || !isStepTransitioning {
            isStepTransitioning = false
            updateScrollViewBaseScrollAvailability()
        }
    }

    private func syncCurrentStepWithScrollView(_ scrollView: UIScrollView) {
        guard scrollView === scrollViewBase else { return }
        let maxOffsetX = max(scrollView.contentSize.width - scrollView.bounds.width, 0)
        let maxIndex = max(Int(round(maxOffsetX / SCREEN_WIDHT)), 0)
        let visibleIndex = min(max(Int(round(scrollView.contentOffset.x / SCREEN_WIDHT)), 0), maxIndex)

        if currentIndex != visibleIndex {
            let didPrepareBackSwipeBackground = backSwipeBackgroundSourceStep != nil
            let previousStep = flowStep(for: currentIndex)
            currentIndex = visibleIndex
            updatePopGestureState()
            updateNavigationForCurrentStep(from: previousStep, animated: didPrepareBackSwipeBackground)
            updateNextButtonForCurrentStep()
            EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW,
                                                scenarioType: .ai_coach_guide,
                                                text: "\(visibleIndex + 1)")
            backSwipeBackgroundSourceStep = nil
        } else {
            restoreSharedBackgroundAfterCancelledBackSwipeIfNeeded()
        }

        isStepTransitioning = false
        isScrollBackInteractionInProgress = false
        updateScrollViewBaseScrollAvailability()
        scrollDragStartIndex = nil
    }
}
