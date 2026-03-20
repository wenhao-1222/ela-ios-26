//
//  GuidanceVC.swift
//  lns
//  新用户引导
//  Created by LNS2 on 2026/3/17.
//

import MCToast
import AuthenticationServices
import UMCommon
import UserNotifications
import IQKeyboardManagerSwift

class GuidanceVC: WHBaseViewVC {

    enum FlowStep: Hashable {
        case sex
        case dietRecord
        case progressChart
        case fixedTarget
        case birthday
        case weight
        case height
        case bodyfat
        case takeoutFrequency
        case mealsPerDay
        case mealsSummary
        case mealsAdjust
        case exerciseCaloriesRecord
        case cardioFrequency
        case strengthTrainingFrequency
        case strengthTrainingSummary
        case caloriesResultBase
        case caloriesResultExplain
        case goal
        case goalBarrier
        case removeBarrier
        case nutritionGoal
        case reminderPrompt
    }
    
    var currentIndex: Int = 0
    private var nextButtonEnableWorkItem: DispatchWorkItem?
    private var delayedNextWorkItem: DispatchWorkItem?
    private var isShowingFinishLoading = false
    private var pendingNutritionGoalPresentation = false
    private let defaultStepsArray = [7,7,8]
    private let fixedTargetStepsArray = [4,5,4]
    private let defaultFlow: [FlowStep] = [
        .sex, .dietRecord, .progressChart, .fixedTarget,
        .birthday, .weight, .height, .bodyfat, .takeoutFrequency,
        .mealsPerDay, .mealsSummary, .mealsAdjust, .exerciseCaloriesRecord, .cardioFrequency,
        .strengthTrainingFrequency, .strengthTrainingSummary, .caloriesResultBase, .caloriesResultExplain,
        .goal, .goalBarrier, .removeBarrier, .nutritionGoal, .reminderPrompt
    ]
    private let fixedTargetFlow: [FlowStep] = [
        .sex, .dietRecord, .progressChart, .fixedTarget,
        .strengthTrainingFrequency, .strengthTrainingSummary, .mealsPerDay, .mealsSummary, .mealsAdjust, .goal,
        .nutritionGoal, .goalBarrier, .removeBarrier, .reminderPrompt
    ]
    private var mountedSteps = Set<FlowStep>()
    private var isFixedTargetFlowEnabled: Bool {
        QuestinonaireMsgModel.shared.guidanceFixedTargetType == "fixed"
    }
    private var activeFlow: [FlowStep] {
        isFixedTargetFlowEnabled ? fixedTargetFlow : defaultFlow
    }
    private var totalSteps: Int {
        activeFlow.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        self.navigationController?.fd_interactivePopDisabled = true
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = true
        navigationController?.fd_interactivePopDisabled = false
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(wechatLogin), name: Notification.Name(rawValue: "wechatLogin"), object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .dietPlanPaceInputDidChange, object: nil)
    }
    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
        vm.backButton.isHidden = false
        vm.backTapBlock = {[weak self] in
            guard let self = self else { return }
            if self.isShowingFinishLoading {
                return
            }
            if self.currentIndex == 0 {
                self.backTapAction()
                return
            }
            if let currentStep = self.flowStep(for: self.currentIndex),
               self.shouldDisableBack(for: currentStep) {
                return
            }
            let targetIndex = self.previousNavigableIndex(from: self.currentIndex)
            self.moveToStep(index: targetIndex, animated: true)
        }
        return vm
    }()
    lazy var stepsArray: [Int] = defaultStepsArray
    lazy var loginAlertVm : LoginAlertVm = {
        let vm = LoginAlertVm.init(frame: .zero)
        vm.weChatLoginBlock = {()in
            WXUtil().wxLogin()
        }
        vm.appleLoginBlock = {()in
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
        vm.phoneLoginBlock = {()in
            self.loginAlertVm.hiddenLoginView()
            let vc = LoginVC()
            if self.navigationController != nil{
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
        return vm
    }()
    lazy var notRegistVm : NotRegistTipsVM = {
        let vm = NotRegistTipsVM.init(frame: .zero)
        
        return vm
    }()
    lazy var bodyFatAlertVm : QuestionnaireBodyFatAlertVM = {
        let vm = QuestionnaireBodyFatAlertVM.init(frame: .zero)
        return vm
    }()
    lazy var katchAlertVm : QuestionnaireBodyFatAlertVM = {
        let vm = QuestionnaireBodyFatAlertVM.init(frame: .zero)
        vm.titleLabel.text = "为什么不用BMI或身高？"
        vm.contentLabelOne.text = "BMI 主要反映体重和身高的比例，无法区分肌肉和脂肪，因此同样 BMI 的两个人，代谢需求可能差很多。Katch-McArdle 会参考你的瘦体重(去脂体重)，在体脂数据较准确时，通常能更贴近健身人群的代谢情况，给出更个性化的结果。"
        vm.contentLabelTwo.text = ""
        vm.contentLabelThree.text = ""
        return vm
    }()
    lazy var nextButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.isHidden = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)

        return btn
    }()
    lazy var sexVm: GuidanceSexVM = {
        let vm = GuidanceSexVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.manTapBlock = {[weak self] in
            self?.handleSexSelection(defaultHeight: 170, defaultWeight: 70)
        }
        vm.femanTapBlock = {[weak self] in
            self?.handleSexSelection(defaultHeight: 160, defaultWeight: 50)
        }
        vm.loginTapBlock = {() in
            self.loginAction()
        }
        
        return vm
    }()
    lazy var dietRecordVm: GuidanceDietRecordVM = {
        let vm = GuidanceDietRecordVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: 0, height: 0))
        vm.selectedBlock = {()in
            self.moveToStep(index: 2, animated: true)
        }
        return vm
    }()
    lazy var progressChartVm: GuideTotalFirstVM = {
        let vm = GuideTotalFirstVM.init(frame: CGRect.init(x: SCREEN_WIDHT*2, y: 0, width: 0, height: 0))
        vm.shouldAutoStartChartAnimation = false
        vm.updateConstraitForGuidance()
        vm.chart.gradientAnimationDidFinish = { [weak self] in
            self?.handleProgressChartAnimationFinished()
        }
        vm.nextBlock = { [weak self] in
//            self?.secondVm.pageDisplayDate = Date()
//            self?.animateTransition(to: 1)
        }
        return vm
    }()
    lazy var fixedTargetVm: GuidanceFixedTargetVM = {
        let vm = GuidanceFixedTargetVM.init(frame: CGRect.init(x: SCREEN_WIDHT*3, y: 0, width: 0, height: 0))
        vm.selectedBlock = { [weak self] in
            self?.updateFlowConfiguration()
            self?.nextButtonTapAction()
        }
        return vm
    }()
    lazy var birthdayVm: DietPlanCreateYearVM = {
        let vm = DietPlanCreateYearVM.init(frame: CGRect.init(x: SCREEN_WIDHT*4, y: 0, width: 0, height: 0))
        vm.applyDefaultAge(18)
        return vm
    }()
    lazy var weightVm: DietPlanCreateWeightVM = {
        let vm = DietPlanCreateWeightVM.init(frame: CGRect.init(x: SCREEN_WIDHT*5, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var heightVm: DietPlanCreateHeightVM = {
        let vm = DietPlanCreateHeightVM.init(frame: CGRect.init(x: SCREEN_WIDHT*6, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var bodyfatVm: DietPlanCreateBodyfatVM = {
        let vm = DietPlanCreateBodyfatVM.init(frame: CGRect.init(x: SCREEN_WIDHT*7, y: 0, width: 0, height: 0))
        vm.selectStateChangeBlock = { [weak self] _ in
            self?.updateNextButtonForCurrentStep()
        }
        vm.showTipsBlock = { [weak self] in
            self?.bodyFatAlertVm.showView()
        }
        return vm
    }()
    lazy var takeoutFrequencyVm: GuidanceTakeoutFrequencyVM = {
        let vm = GuidanceTakeoutFrequencyVM.init(frame: CGRect.init(x: SCREEN_WIDHT*8, y: 0, width: 0, height: 0))
        vm.selectedBlock = { [weak self] in
            self?.updateNextButtonForCurrentStep()
        }
        return vm
    }()
    lazy var mealsPerDayVm: GuidanceMealsPerDayVM = {
        let vm = GuidanceMealsPerDayVM.init(frame: CGRect.init(x: SCREEN_WIDHT*9, y: 0, width: 0, height: 0))
        vm.selectedBlock = { [weak self] in 
            QuestinonaireMsgModel.shared.guidanceMealsAdjustType = QuestinonaireMsgModel.shared.guidanceMealsPerDayType
            self?.mealsAdjustVm.refreshSelectionFromModel()
            self?.updateNextButtonForCurrentStep()
        }
        return vm
    }()
    lazy var mealsSummaryVm: GuidanceMealsSummaryVM = {
        let vm = GuidanceMealsSummaryVM.init(frame: .zero)
        vm.isHidden = true
        vm.nextBlock = { [weak self] in
            self?.advanceFromMealsSummary()
        }
        return vm
    }()
    lazy var mealsAdjustVm: GuidanceMealsAdjustVM = {
        let vm = GuidanceMealsAdjustVM.init(frame: CGRect.init(x: SCREEN_WIDHT*10, y: 0, width: 0, height: 0))
        vm.selectedBlock = { [weak self] in
            self?.updateNextButtonForCurrentStep()
        }
        return vm
    }()
    lazy var exerciseCaloriesRecordVm: GuidanceExerciseCaloriesRecordVM = {
        let vm = GuidanceExerciseCaloriesRecordVM.init(frame: CGRect.init(x: SCREEN_WIDHT*11, y: 0, width: 0, height: 0))
        vm.selectedBlock = { [weak self] in
            self?.updateNextButtonForCurrentStep()
        }
        return vm
    }()
    lazy var cardioFrequencyVm: GuidanceCardioFrequencyVM = {
        let vm = GuidanceCardioFrequencyVM.init(frame: CGRect.init(x: SCREEN_WIDHT*12, y: 0, width: 0, height: 0))
        vm.selectedBlock = { [weak self] in
            self?.updateNextButtonForCurrentStep()
        }
        return vm
    }()
    lazy var strengthTrainingFrequencyVm: GuidanceStrengthTrainingFrequencyVM = {
        let vm = GuidanceStrengthTrainingFrequencyVM.init(frame: CGRect.init(x: SCREEN_WIDHT*13, y: 0, width: 0, height: 0))
        vm.selectedBlock = { [weak self] in
            self?.updateNextButtonForCurrentStep()
        }
        return vm
    }()
    lazy var strengthTrainingSummaryVm: GuidanceStrengthTrainingSummaryVM = {
        let vm = GuidanceStrengthTrainingSummaryVM.init(frame: .zero)
        vm.isHidden = true
        vm.nextBlock = { [weak self] in
            self?.advanceFromStrengthTrainingSummary()
        }
        return vm
    }()
    lazy var caloriesResultBaseVm: QuestionResultBaseVM = {
        let vm = QuestionResultBaseVM.init(frame: CGRect.init(x: SCREEN_WIDHT*14, y: 0, width: 0, height: 0))
        vm.updateConstrait()
        vm.showTipsBlock = { [weak self] in
            self?.katchAlertVm.showView()
        }
        return vm
    }()
    lazy var caloriesResultExplainVm: QuestionResultExplainVM = {
        let vm = QuestionResultExplainVM.init(frame: CGRect.init(x: SCREEN_WIDHT*15, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var goalVm : QuestionnaireGoalVM = {
        let vm = QuestionnaireGoalVM.init(frame: CGRect.init(x: SCREEN_WIDHT*16, y: 0, width: 0, height: 0))
        vm.updateConstrait()
        vm.choiceBlock = { [weak self] in
            self?.goalBarrierVm.updateContentForGoal(modelValue: QuestinonaireMsgModel.shared.goal)
            self?.updateNextButtonForCurrentStep()
        }
        return vm
    }()
    lazy var goalBarrierVm: GuidanceGoalBarrierVM = {
        let vm = GuidanceGoalBarrierVM.init(frame: CGRect.init(x: SCREEN_WIDHT*17, y: 0, width: 0, height: 0))
        vm.selectedBlock = { [weak self] in
            self?.updateNextButtonForCurrentStep()
        }
        return vm
    }()
    lazy var removeBarrierVm: GuidanceRemoveBarrierVM = {
        let vm = GuidanceRemoveBarrierVM.init(frame: CGRect(x: SCREEN_WIDHT * 18, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        return vm
    }()
    lazy var nutritionGoalVm: GuidanceNutritionGoalVM = {
        let vm = GuidanceNutritionGoalVM.init(frame: CGRect(x: SCREEN_WIDHT * 19, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vm.saveBlock = { [weak self] in
            self?.saveGuidanceNutritionGoals()
        }
        return vm
    }()
    lazy var fixedTargetNutritionGoalVm: GuidanceFixedTargetNutritionGoalVM = {
        let vm = GuidanceFixedTargetNutritionGoalVM.init(frame: CGRect(x: SCREEN_WIDHT * 19, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vm.saveBlock = { [weak self] in
            self?.nextButtonTapAction()
//            self?.saveGuidanceNutritionGoals()
        }
        return vm
    }()
    lazy var reminderPromptVm: GuidanceReminderPromptVM = {
        let vm = GuidanceReminderPromptVM.init(frame: CGRect(x: SCREEN_WIDHT * 20, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vm.enableReminderBlock = { [weak self] in
            self?.requestReminderPermissionIfNeeded()
        }
        vm.skipBlock = { [weak self] in
            self?.finishGuidanceFlow()
//            self?.finishLoadingVm.showLoading(waitForExternalCompletion: false)
        }
        return vm
    }()
    lazy var finishLoadingVm: GuidanceFinishLoadingVM = {
        let vm = GuidanceFinishLoadingVM.init(frame: .zero)
        vm.progressCompleteBlock = { [weak self] in
            guard let self = self else { return }
            if self.pendingNutritionGoalPresentation {
                self.pendingNutritionGoalPresentation = false
                self.isShowingFinishLoading = false
                self.finishLoadingVm.hideLoadingView()
                self.naviVm.isHidden = false
                self.moveToStep(index: self.indexOfStep(.nutritionGoal) ?? self.currentIndex, animated: true)
                return
            }
            self.isShowingFinishLoading = false
            self.finishLoadingVm.hideLoadingView()
            self.changeRootVcToLogin()
        }
        return vm
    }()
}

extension GuidanceVC{
    @objc func nextButtonTapAction() {
        guard let currentStep = flowStep(for: currentIndex) else { return }

        switch currentStep {
        case .progressChart, .fixedTarget, .height, .bodyfat, .takeoutFrequency,
             .mealsAdjust, .exerciseCaloriesRecord, .cardioFrequency,
             .caloriesResultExplain, .nutritionGoal,.goalBarrier:
            moveToStep(index: currentIndex + 1, animated: true)
        case .birthday:
            birthdayVm.getBirthDayData()
            moveToStep(index: currentIndex + 1, animated: true)
        case .weight:
            weightVm.getWeightValue()
            moveToStep(index: currentIndex + 1, animated: true)
        case .mealsPerDay:
            moveToStep(index: currentIndex + 1, animated: true)
        case .strengthTrainingFrequency:
            moveToStep(index: currentIndex + 1, animated: true)
        case .goal:
            moveToStep(index: currentIndex + 1, animated: true)
        case .caloriesResultBase:
            let caloriesText = caloriesResultBaseVm.caloriesTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"
            if caloriesText.floatValue < 100 {
                presentAlertVcNoAction(title: "请输入合理的热量摄入值", viewController: self)
                return
            }
            QuestinonaireMsgModel.shared.caloriesNumber = "\(Int(caloriesText.floatValue))"
            caloriesResultBaseVm.caloriesTextField.resignFirstResponder()
            moveToStep(index: currentIndex + 1, animated: true)
        case .removeBarrier:
            if isFixedTargetFlowEnabled {
                moveToStep(index: currentIndex + 1, animated: true)
            } else {
                nextButton.isEnabled = false
                delayedNextWorkItem?.cancel()
                let workItem = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }
                    self.startNutritionGoalLoadingFlow()
                }
                delayedNextWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: workItem)
            }
        case .sex, .dietRecord, .mealsSummary, .strengthTrainingSummary,  .reminderPrompt:
            break
        }
    }

    func handleSexSelection(defaultHeight: Int, defaultWeight: Int) {
        heightVm.applyDefaultHeight(defaultHeight)
        weightVm.applyDefaultWeight(integer: defaultWeight)
        bodyfatVm.updateScrollView()
        birthdayVm.getBirthDayData()
        moveToStep(index: 1, animated: true)
    }

    func flowStep(for index: Int) -> FlowStep? {
        guard activeFlow.indices.contains(index) else { return nil }
        return activeFlow[index]
    }

    func indexOfStep(_ step: FlowStep) -> Int? {
        activeFlow.firstIndex(of: step)
    }

    func isSummaryStep(_ step: FlowStep) -> Bool {
        step == .mealsSummary || step == .strengthTrainingSummary
    }

    func shouldCountForProgress(_ step: FlowStep) -> Bool {
        step != .strengthTrainingSummary
    }

    func previousNavigableIndex(from index: Int) -> Int {
        var targetIndex = index - 1
        while targetIndex >= 0,
              let step = flowStep(for: targetIndex),
              isSummaryStep(step) {
            targetIndex -= 1
        }
        return max(0, targetIndex)
    }

    func progressIndex(for flowIndex: Int) -> Int {
        let prefixSteps = activeFlow.prefix(max(0, flowIndex + 1))
        let actualStepCount = prefixSteps.filter { shouldCountForProgress($0) }.count
        return max(0, actualStepCount - 1)
    }

    func shouldDisableBack(for step: FlowStep) -> Bool {
        !isFixedTargetFlowEnabled && step == .nutritionGoal
    }

    func shouldHideNavigation(for step: FlowStep) -> Bool {
        if isShowingFinishLoading || isSummaryStep(step) {
            return true
        }
        return shouldDisableBack(for: step)
    }

    func updateFlowConfiguration() {
        stepsArray = isFixedTargetFlowEnabled ? fixedTargetStepsArray : defaultStepsArray
        scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT * CGFloat(totalSteps), height: SCREEN_HEIGHT)
        layoutMountedStepViews()
        updateNutritionGoalViewVisibility()
    }

    func layoutMountedStepViews() {
        for step in mountedSteps {
            guard let stepView = stepView(for: step) else { continue }
            if let index = activeFlow.firstIndex(of: step) {
                stepView.isHidden = false
                stepView.frame = CGRect(x: SCREEN_WIDHT * CGFloat(index), y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
            } else {
                stepView.isHidden = true
            }
        }
    }

    func updateNutritionGoalViewVisibility() {
        guard mountedSteps.contains(.nutritionGoal) else { return }
        nutritionGoalVm.isHidden = isFixedTargetFlowEnabled
        fixedTargetNutritionGoalVm.isHidden = !isFixedTargetFlowEnabled
    }

    func scrollableIndex(for targetIndex: Int) -> Int {
        var index = max(0, min(targetIndex, totalSteps - 1))
        while index > 0 && stepView(for: activeFlow[index]) == nil {
            index -= 1
        }
        return index
    }

    func advanceFromMealsSummary() {
        moveToStep(index: currentIndex + 1, animated: true)
    }

    func advanceFromStrengthTrainingSummary() {
        if isFixedTargetFlowEnabled {
            moveToStep(index: currentIndex + 1, animated: true)
        } else {
            sendBasicRequest(continueTo: .caloriesResultBase)
        }
    }

    func moveToStep(index: Int, animated: Bool) {
        updateFlowConfiguration()
        let targetIndex = max(0, min(index, totalSteps - 1))
        guard let targetStep = flowStep(for: targetIndex) else { return }
        if flowStep(for: currentIndex) == .nutritionGoal {
            fixedTargetNutritionGoalVm.endEditing(true)
        }
        installStepViewsIfNeeded(indexes: [targetIndex, targetIndex + 1, targetIndex + 2])
        currentIndex = targetIndex
        let visibleIndex = scrollableIndex(for: targetIndex)
        scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(visibleIndex), y: 0), animated: animated)
        naviVm.updateStep(steps: stepsArray, currentStep: progressIndex(for: targetIndex))
        naviVm.backButton.isEnabled = targetIndex > 0 && !shouldDisableBack(for: targetStep)
        naviVm.isHidden = shouldHideNavigation(for: targetStep)
        updateNextButtonForCurrentStep()

        if targetStep == .progressChart {
            progressChartVm.chart.startGradientAnimation()
        }
        if targetStep == .goalBarrier {
            goalBarrierVm.updateContentForGoal(modelValue: QuestinonaireMsgModel.shared.goal)
        }
        if targetStep == .removeBarrier {
            removeBarrierVm.startScrollersIfNeeded()
        }
        if targetStep == .nutritionGoal {
            if isFixedTargetFlowEnabled {
                fixedTargetNutritionGoalVm.refreshContentFromModel()
                let focusDelay = animated ? 0.35 : 0
                DispatchQueue.main.asyncAfter(deadline: .now() + focusDelay) { [weak self] in
                    guard let self = self,
                          self.flowStep(for: self.currentIndex) == .nutritionGoal,
                          self.isFixedTargetFlowEnabled else { return }
                    self.fixedTargetNutritionGoalVm.focusCarbInput()
                }
            } else {
                nutritionGoalVm.refreshContentFromModel()
            }
        }
        if targetStep == .mealsSummary {
            mealsSummaryVm.refreshContentFromModel()
        }
        if targetStep == .strengthTrainingSummary {
            strengthTrainingSummaryVm.refreshContentFromModel()
        }
    }

    func updateNextButtonForCurrentStep() {
        nextButtonEnableWorkItem?.cancel()
        nextButtonEnableWorkItem = nil

        guard let currentStep = flowStep(for: currentIndex) else {
            nextButton.isHidden = true
            nextButton.isEnabled = false
            return
        }

        switch currentStep {
        case .sex, .dietRecord, .mealsSummary, .strengthTrainingSummary, .nutritionGoal, .reminderPrompt:
            nextButton.isHidden = true
            nextButton.isEnabled = false
        case .progressChart:
            nextButton.isHidden = false
            nextButton.isEnabled = false
        case .fixedTarget:
            nextButton.isHidden = true
            nextButton.isEnabled = fixedTargetVm.hasSelection
        case .birthday, .weight, .height, .removeBarrier:
            nextButton.isHidden = false
            nextButton.isEnabled = true
        case .bodyfat:
            nextButton.isHidden = false
            nextButton.isEnabled = bodyfatVm.selectIndex >= 0
        case .takeoutFrequency:
            nextButton.isHidden = false
            nextButton.isEnabled = takeoutFrequencyVm.hasSelection
        case .mealsPerDay:
            nextButton.isHidden = false
            nextButton.isEnabled = mealsPerDayVm.hasSelection
        case .mealsAdjust:
            nextButton.isHidden = false
            nextButton.isEnabled = mealsAdjustVm.hasSelection
        case .exerciseCaloriesRecord:
            nextButton.isHidden = false
            nextButton.isEnabled = exerciseCaloriesRecordVm.hasSelection
        case .cardioFrequency:
            nextButton.isHidden = false
            nextButton.isEnabled = cardioFrequencyVm.hasSelection
        case .strengthTrainingFrequency:
            nextButton.isHidden = false
            nextButton.isEnabled = strengthTrainingFrequencyVm.hasSelection
        case .caloriesResultBase, .caloriesResultExplain:
            nextButton.isHidden = false
            nextButton.isEnabled = true
        case .goal:
            nextButton.isHidden = false
            nextButton.isEnabled = goalVm.selectIndex >= 0
        case .goalBarrier:
            nextButton.isHidden = false
            nextButton.isEnabled = goalBarrierVm.hasSelection
        }
    }

    func finishGuidanceFlow() {
        UserInfoModel.shared.showNotifiAuthoriAlertVM = false
        if isFixedTargetFlowEnabled {
            QuestinonaireMsgModel.shared.surveytype = "custom_v2"
            changeRootVcToLogin()
            return
        }
        QuestinonaireMsgModel.shared.surveytype = "part_v2"
        startFinalGuidanceSubmissionFlow()
    }

    func startFinalGuidanceSubmissionFlow() {
        guard !isShowingFinishLoading else { return }
        isShowingFinishLoading = true
        pendingNutritionGoalPresentation = false
        naviVm.isHidden = true
        nextButton.isHidden = true
        nextButton.isEnabled = false
        if isFixedTargetFlowEnabled {
            finishLoadingVm.configureLoading(
                titleText: "正在根据你的选择优化设置…",
                completionTitleText: "已完成",
                completionNotifyDelay: 0.35
            )
        } else {
            finishLoadingVm.configureLoading(titleText: "正在保存你的设置...")
        }
        finishLoadingVm.showLoading(waitForExternalCompletion: true)
        submitCompletedGuidanceFlow()
    }

    func startNutritionGoalLoadingFlow() {
        guard !isShowingFinishLoading else { return }
        isShowingFinishLoading = true
        pendingNutritionGoalPresentation = true
        naviVm.isHidden = true
        nextButton.isHidden = true
        nextButton.isEnabled = false
        finishLoadingVm.configureLoading(titleText: "计划生成中...")
        finishLoadingVm.showLoading(waitForExternalCompletion: true)
        sendGuidanceNutritionGoalRequest()
    }

    func cancelNutritionGoalLoadingFlow() {
        pendingNutritionGoalPresentation = false
        isShowingFinishLoading = false
        finishLoadingVm.hideLoadingView()
        naviVm.isHidden = false
        updateNextButtonForCurrentStep()
    }

    func cancelFinalGuidanceSubmissionFlow() {
        pendingNutritionGoalPresentation = false
        isShowingFinishLoading = false
        finishLoadingVm.hideLoadingView()

        let currentStep = flowStep(for: currentIndex) ?? .reminderPrompt
        naviVm.isHidden = shouldHideNavigation(for: currentStep)
        naviVm.backButton.isEnabled = currentIndex > 0 && !shouldDisableBack(for: currentStep)
        updateNextButtonForCurrentStep()
    }

    func requestReminderPermissionIfNeeded() {
        UserInfoModel.shared.showNotifiAuthoriAlertVM = false
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            switch settings.authorizationStatus {
            case .denied:
                DispatchQueue.main.async {
                    self.openUrl(urlString: UIApplication.openSettingsURLString)
                }
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async {
                    self.finishGuidanceFlow()
                }
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                    DispatchQueue.main.async {
                        self.finishGuidanceFlow()
                    }
                }
            @unknown default:
                DispatchQueue.main.async {
                    self.finishGuidanceFlow()
                }
            }
        }
    }

    func handleProgressChartAnimationFinished() {
        guard flowStep(for: currentIndex) == .progressChart else { return }
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self, self.flowStep(for: self.currentIndex) == .progressChart else { return }
            self.nextButton.isEnabled = true
        }
        nextButtonEnableWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }

    func estimatedDailyActivityLevel() -> String {
        let cardioScore: Double
        switch QuestinonaireMsgModel.shared.guidanceCardioFrequencyType {
        case "never":
            cardioScore = 0
        case "commute":
            cardioScore = 1
        case "2-3":
            cardioScore = 2.5
        case "4-5":
            cardioScore = 4.5
        case "6-7":
            cardioScore = 6.5
        default:
            cardioScore = 0
        }

        let strengthScore: Double
        switch QuestinonaireMsgModel.shared.guidanceStrengthTrainingFrequencyType {
        case "0-2":
            strengthScore = 1
        case "3-4":
            strengthScore = 3.5
        case "5-6":
            strengthScore = 5.5
        case "7+":
            strengthScore = 7
        default:
            strengthScore = 0
        }

        let totalScore = cardioScore + strengthScore
        switch totalScore {
        case ..<1:
            return "1"
        case ..<3:
            return "2"
        case ..<5:
            return "3"
        case ..<8:
            return "4"
        case ..<12:
            return "5"
        default:
            return "6"
        }
    }
    
    func saveGuidanceNutritionGoals() {
        if isFixedTargetFlowEnabled, let goalBarrierIndex = indexOfStep(.goalBarrier) {
            moveToStep(index: goalBarrierIndex, animated: true)
            return
        }
        QuestinonaireMsgModel.shared.surveytype = "part_v2"
        changeRootVcToLogin()
//        NutritionDefaultModel.shared.saveGoals(dict: [
//            "calories": QuestinonaireMsgModel.shared.caloriesNumber,
//            "carbohydrates": QuestinonaireMsgModel.shared.carbohydratesNumber,
//            "proteins": QuestinonaireMsgModel.shared.proteinNumber,
//            "fats": QuestinonaireMsgModel.shared.fatsNumber
//        ])
//        moveToStep(index: 20, animated: true)
    }
    @objc func loginAction(){
        openNetWorkServiceWithBolck(action: { netConnect in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                if netConnect == true{
                    self.loginAlertVm.showLoginView()
                }else{
                    self.presentAlertVc(confirmBtn: "设置", message: "可以在“设置->App->无线数据”中开启“无线数据”，连接网络后才能流畅使用。", title: "“Elavatine”已关闭网络权限", cancelBtn: "取消", handler: { action in
                        self.openUrl(urlString: UIApplication.openSettingsURLString)
                    }, viewController: self)
                }
            })
        })
   }
    @objc func wechatLogin() {
        if UserInfoModel.shared.isRegist == "yes"{
            if UserInfoModel.shared.state == 1 {
                self.changeRootVcToTabbar()
            }else{
                self.presentAlertVcNoAction(title: "账户已申请注销！", viewController: self)
            }
        }else{
            notRegistVm.showView()
        }
    }
}

extension GuidanceVC{
    func stepView(for step: FlowStep) -> UIView? {
        switch step {
        case .sex: return sexVm
        case .dietRecord: return dietRecordVm
        case .progressChart: return progressChartVm
        case .fixedTarget: return fixedTargetVm
        case .birthday: return birthdayVm
        case .weight: return weightVm
        case .height: return heightVm
        case .bodyfat: return bodyfatVm
        case .takeoutFrequency: return takeoutFrequencyVm
        case .mealsPerDay: return mealsPerDayVm
        case .mealsSummary: return mealsSummaryVm
        case .mealsAdjust: return mealsAdjustVm
        case .exerciseCaloriesRecord: return exerciseCaloriesRecordVm
        case .cardioFrequency: return cardioFrequencyVm
        case .strengthTrainingFrequency: return strengthTrainingFrequencyVm
        case .strengthTrainingSummary: return strengthTrainingSummaryVm
        case .caloriesResultBase: return caloriesResultBaseVm
        case .caloriesResultExplain: return caloriesResultExplainVm
        case .goal: return goalVm
        case .goalBarrier: return goalBarrierVm
        case .removeBarrier: return removeBarrierVm
        case .nutritionGoal: return isFixedTargetFlowEnabled ? fixedTargetNutritionGoalVm : nutritionGoalVm
        case .reminderPrompt: return reminderPromptVm
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

    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(scrollViewBase)
        view.addSubview(naviVm)
        view.addSubview(nextButton)
        view.addSubview(loginAlertVm)
        view.addSubview(notRegistVm)
        view.addSubview(bodyFatAlertVm)
        view.addSubview(katchAlertVm)
        view.addSubview(finishLoadingVm)
        
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.isScrollEnabled = false
        updateFlowConfiguration()
        
        installStepViewsIfNeeded(indexes: [0, 1, 2])
        
        setConstrait()
        moveToStep(index: 0, animated: false)
    }
    func setConstrait() {
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }
        finishLoadingVm.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

//MARK: 网络请求
extension GuidanceVC{
    func submitCompletedGuidanceFlow() {
        sendGuidanceNonFixedTargetUploadPlaceholder()
    }

    func sendBasicRequest(continueTo step: FlowStep = .caloriesResultBase) {
//        QuestinonaireMsgModel.shared.events = estimatedDailyActivityLevel()
        let param = [
            "gender": "\(QuestinonaireMsgModel.shared.sex)",
            "dailyact": "\(QuestinonaireMsgModel.shared.events)",
            "bodyfat": "\(QuestinonaireMsgModel.shared.bodyFat)",
            "weight": "\(QuestinonaireMsgModel.shared.weight)"
        ]
        DLLog(message: "sendBasicRequest(guidance):\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_question_basic_consumption, parameters: param as [String: AnyObject], isNeedToast: true, vc: self) { [weak self] responseObject in
            guard let self = self else { return }
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            DLLog(message: "sendBasicRequest(guidance):\(dataString ?? "")")
            let caloriesText = (dataString ?? "0").trimmingCharacters(in: .whitespacesAndNewlines)
            QuestinonaireMsgModel.shared.caloriesNumber = caloriesText
            QuestinonaireMsgModel.shared.caloriesNumberFromServer = caloriesText
            DispatchQueue.main.async {
                self.caloriesResultBaseVm.caloriesTextField.text = caloriesText
                self.moveToStep(index: self.indexOfStep(step) ?? self.currentIndex, animated: true)
            }
        }
    }

    func sendGuidanceNutritionGoalRequest() {
        let param = [
            "gender": "\(QuestinonaireMsgModel.shared.sex)",
            "birthday": "\(QuestinonaireMsgModel.shared.birthDay)",
            "weight": "\(QuestinonaireMsgModel.shared.weight)",
            "goal": "\(QuestinonaireMsgModel.shared.goal)",
            "dailyact": "\(QuestinonaireMsgModel.shared.events)",
            "bodyfat": "\(QuestinonaireMsgModel.shared.bodyFat)",
            "calories": QuestinonaireMsgModel.shared.caloriesNumber == "" ? QuestinonaireMsgModel.shared.caloriesNumberFromServer : QuestinonaireMsgModel.shared.caloriesNumber
        ]
        DLLog(message: "sendGuidanceNutritionGoalRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_question_survey_part_save, parameters: param as [String:AnyObject]) { [weak self] responseObject in
            guard let self = self else { return }
            let code = responseObject["code"]as? Int ?? -1
            if (code != 200) {
                DispatchQueue.main.async {
                    self.cancelNutritionGoalLoadingFlow()
                    self.presentAlertVc(confirmBtn: "刷新", message: "", title: "当前网络不稳定", cancelBtn: nil, handler: { _ in
                        self.startNutritionGoalLoadingFlow()
                    }, viewController: self)
                }
                return
            }

            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let data = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendGuidanceNutritionGoalRequest:\(data)")

            let carbohydrate = data["carbohydrate"] as? Int ?? Int(data.doubleValueForKey(key: "carbohydrate"))
            let fat = data["fat"] as? Int ?? Int(data.doubleValueForKey(key: "fat"))
            let protein = data["protein"] as? Int ?? Int(data.doubleValueForKey(key: "protein"))
            let calories = data["calories"] as? Int ?? Int(data.doubleValueForKey(key: "calories"))

            QuestinonaireMsgModel.shared.surveytype = "part"
            QuestinonaireMsgModel.shared.carbohydratesNumber = "\(carbohydrate)"
            QuestinonaireMsgModel.shared.fatsNumber = "\(fat)"
            QuestinonaireMsgModel.shared.proteinNumber = "\(protein)"
            QuestinonaireMsgModel.shared.caloriesNumber = "\(calories)"
            
            QuestinonaireMsgModel.shared.carbohydratesNumber = "\(carbohydrate)"
            QuestinonaireMsgModel.shared.proteinNumber = "\(protein)"
            QuestinonaireMsgModel.shared.fatsNumber = "\(fat)"
            QuestinonaireMsgModel.shared.caloriesNumber = "\(calories)"

            DispatchQueue.main.async {
                self.nutritionGoalVm.refreshContentFromModel()
                self.finishLoadingVm.completeLoading()
            }
        }
    }

    func sendGuidanceNonFixedTargetUploadPlaceholder() {
        // TODO: 这里预留给非“有固定目标”分支的最终上传接口，下一步接入。
        DispatchQueue.main.async {
            self.finishLoadingVm.completeLoading()
        }
    }
    func sendAppleIdLoginRequest(){
        MCToast.mc_loading()
        let param = ["appleid":"\(UserInfoModel.shared.appleId)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_Login_appid, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
            
            let dataEncString = responseObject["data"]as? String ?? ""
            let dataDecString = AESEncyptUtil.aesDecrypt(hexString: dataEncString)
            let dataObj = self.getDictionaryFromJSONString(jsonString: dataDecString ?? "")
            DLLog(message: "sendAppleIdLoginRequest:\(dataObj)")
            
            UserInfoModel.shared.isRegist = dataObj["registered"]as? String ?? ""
            if dataObj["registered"]as? String ?? "" == "yes"{
                if dataObj.stringValueForKey(key: "state") == "1" {
                    MCToast.mc_text("登录成功！")
                    UserInfoModel.shared.token = dataObj["token"]as? String ?? ""
                    UserInfoModel.shared.uId   = dataObj["uid"]as? String ?? ""
                    
                    UserDefaults.standard.setValue("\(dataObj["token"]as? String ?? "")", forKey: token)
                    UserDefaults.standard.setValue("\(dataObj["uid"]as? String ?? "")", forKey: userId)
                    
                    WidgetUtils().saveUserInfo(uId: "\(dataObj["uid"]as? String ?? "")", uToken: "\(dataObj["token"]as? String ?? "")")
                    self.changeRootVcToTabbar()
                }else{
                    self.presentAlertVcNoAction(title: "账户已申请注销。", viewController: self)
                }
            }else{
                self.notRegistVm.showView()
            }
        }
    }
}

//MARK: APPID登录
extension GuidanceVC:ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding{
/// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController,
      didCompleteWithAuthorization authorization: ASAuthorization) {

        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user // 保存一下, 用于校验登录状态
            DLLog(message: "appleIDCredential:\(appleIDCredential.description)")
            DLLog(message: "userIdentifier:\(userIdentifier)")
            
            UserInfoModel.shared.appleId = "\(userIdentifier)"
            self.sendAppleIdLoginRequest()
            // 与服务器交互, 并跳转页面 ...
            
            /*
             001020.3c40ffb6b0af4962902100fca966d926.0208
             */
        
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            DLLog(message: "\(passwordCredential.description)")
            
            // 与服务器交互, 并跳转页面 ...
            
        default:
            break
        }
    }

    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController,
      didCompleteWithError error: Error) {
        // Handle error.
    }
    
    /// - Tag: provide_presentation_anchor
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return self.view.window!
        }
}
