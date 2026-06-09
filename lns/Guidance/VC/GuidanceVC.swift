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
        case elaProTransition
        case nutritionGoal
        case reminderPrompt
    }

    var currentIndex: Int = 0
    private var nextButtonEnableWorkItem: DispatchWorkItem?
    private var delayedNextWorkItem: DispatchWorkItem?
    private var deferredInitialStepWarmupWorkItem: DispatchWorkItem?
    private var isShowingFinishLoading = false
    private var pendingNutritionGoalPresentation = false
    private var isShowingStandaloneNutritionGoal = false
    private var isTransitioningToGuidancePro = false
    private var cachedGuidanceProHasFreeTrialPermission = true
    private var hasPrefetchedGuidanceProSubscriptionHistory = false
    private var hasPrefetchedGuidanceProProducts = false
    private var hasResolvedGuidanceProSubscriptionHistory = false
    private var hasAutoSelectedSkippedCardioFrequency = false
    private var isBackNavigationLocked = false
    private var lastGuidanceV2TrackedPageKey = ""
    private var hasConfiguredFullscreenPopGesture = false
    private let guidanceProTrialHistoryProductID = "annual_yeal_new"
    private var isFullscreenPopGestureEnabledForInitialStep = false
    private weak var fullscreenPopGestureNavigationController: UINavigationController?
    private weak var fullscreenPopGestureFailureNavigationController: UINavigationController?
    private var scrollDragStartIndex: Int?
    private var isStepTransitioning = false
    private var hasCompletedProgressChartAnimation = false
    private lazy var backEdgePanGesture: UIScreenEdgePanGestureRecognizer = {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleBackEdgePan(_:)))
        gesture.edges = .left
        gesture.delegate = self
        return gesture
    }()
    private let defaultStepsArray = [7,7,9]
    private let defaultStepsArrayWithoutCardio = [7,6,9]
    private let defaultStepsArrayUncertain = [7,7,8]
    private let defaultStepsArrayWithoutCardioUncertain = [7,6,8]
    private let fixedTargetStepsArray = [4,5,5]
    private let defaultFlow: [FlowStep] = [
        .sex, .dietRecord, .progressChart, .fixedTarget,
        .birthday, .weight, .height, .bodyfat, .takeoutFrequency,
        .mealsPerDay, .mealsSummary, .mealsAdjust, .exerciseCaloriesRecord, .cardioFrequency,
        .strengthTrainingFrequency, .strengthTrainingSummary, .caloriesResultBase, .caloriesResultExplain,
        .goal, .goalBarrier, .removeBarrier, .elaProTransition, .nutritionGoal, .reminderPrompt
    ]
    private let defaultFlowUncertain: [FlowStep] = [
        .sex, .dietRecord, .progressChart, .fixedTarget,
        .birthday, .weight, .height, .bodyfat, .takeoutFrequency,
        .mealsPerDay, .mealsSummary, .mealsAdjust, .exerciseCaloriesRecord, .cardioFrequency,
        .strengthTrainingFrequency, .strengthTrainingSummary, .caloriesResultBase, .caloriesResultExplain,
        .goal, .goalBarrier, .removeBarrier, .elaProTransition, .reminderPrompt
    ]
    private let defaultFlowNoCardioFrequency: [FlowStep] = [
        .sex, .dietRecord, .progressChart, .fixedTarget,
        .birthday, .weight, .height, .bodyfat, .takeoutFrequency,
        .mealsPerDay, .mealsSummary, .mealsAdjust, .exerciseCaloriesRecord,
        .strengthTrainingFrequency, .strengthTrainingSummary, .caloriesResultBase, .caloriesResultExplain,
        .goal, .goalBarrier, .removeBarrier, .elaProTransition, .nutritionGoal, .reminderPrompt
    ]
    private let defaultFlowNoCardioFrequencyUncertain: [FlowStep] = [
        .sex, .dietRecord, .progressChart, .fixedTarget,
        .birthday, .weight, .height, .bodyfat, .takeoutFrequency,
        .mealsPerDay, .mealsSummary, .mealsAdjust, .exerciseCaloriesRecord,
        .strengthTrainingFrequency, .strengthTrainingSummary, .caloriesResultBase, .caloriesResultExplain,
        .goal, .goalBarrier, .removeBarrier, .elaProTransition, .reminderPrompt
    ]
    private let fixedTargetFlow: [FlowStep] = [
        .sex, .dietRecord, .progressChart, .fixedTarget,
        .nutritionGoal, .strengthTrainingFrequency, .strengthTrainingSummary, .mealsPerDay, .mealsSummary, .mealsAdjust,
        .goal, .goalBarrier, .removeBarrier, .elaProTransition, .reminderPrompt
    ]
    private var mountedSteps = Set<FlowStep>()
    private var virtualBackScrollSourceIndex: Int?
    private var virtualBackScrollTargetIndex: Int?
    private var virtualBackScrollDisplayIndex: Int?
    private var didHideNextButtonForFixedNutritionBackSwipe = false
    private var isScrollBackInteractionInProgress = false
    private var isFixedTargetFlowEnabled: Bool {
        QuestinonaireMsgModel.shared.guidanceFixedTargetType == "fixed"
    }
    private var isUncertainFixedTargetSelection: Bool {
        QuestinonaireMsgModel.shared.guidanceFixedTargetType == "uncertain"
    }
    private var shouldSkipCardioFrequencyStep: Bool {
        !isFixedTargetFlowEnabled && QuestinonaireMsgModel.shared.guidanceExerciseCaloriesRecordType == "yes"
    }
    private var activeFlow: [FlowStep] {
        if isFixedTargetFlowEnabled {
            return fixedTargetFlow
        }
        if isUncertainFixedTargetSelection {
            return shouldSkipCardioFrequencyStep ? defaultFlowNoCardioFrequencyUncertain : defaultFlowUncertain
        }
        if shouldSkipCardioFrequencyStep {
            return defaultFlowNoCardioFrequency
        }
        return defaultFlow
    }
    private var totalSteps: Int {
        activeFlow.count
    }

    override func viewDidAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        updateFullscreenPopGestureAvailability()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = true
        isStepTransitioning = false
        isScrollBackInteractionInProgress = false
        scrollViewBase.isScrollEnabled = true
        restoreFullscreenInteractivePopGesture()
    }
    override func viewWillAppear(_ animated: Bool) {
        isTransitioningToGuidancePro = false
        NotificationCenter.default.addObserver(self, selector: #selector(wechatLogin), name: Notification.Name(rawValue: "wechatLogin"), object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        prefetchGuidanceProProductsIfNeeded()
        prefetchGuidanceProSubscriptionHistoryIfNeeded()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        nextButton.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
    }

    deinit {
        deferredInitialStepWarmupWorkItem?.cancel()
        NotificationCenter.default.removeObserver(self, name: .dietPlanPaceInputDidChange, object: nil)
    }
    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
        vm.backButton.isHidden = true
        vm.backTapBlock = {[weak self] in
            self?.navigateBackOneStep()
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
        vm.titleLabel.text = "为什么不用BMI？"
        vm.contentLabelOne.text = "BMI 主要反映体重和身高的比例，无法区分肌肉和脂肪，因此同样 BMI 的两个人，代谢需求可能差很多。Katch-McArdle 会参考你的瘦体重(去脂体重)，在体脂数据较准确时，通常能更贴近健身人群的代谢情况，给出更个性化的结果。"
        vm.contentLabelTwo.text = ""
        vm.contentLabelThree.text = ""
        return vm
    }()
    lazy var sexTipsAlertVm: GuidanceSexTipsAlertVM = {
        let vm = GuidanceSexTipsAlertVM(frame: .zero)
        return vm
    }()
    lazy var dietRecordTipsAlertVm: GuidanceDietRecordTipsAlertVM = {
        let vm = GuidanceDietRecordTipsAlertVM(frame: .zero)
        return vm
    }()
    lazy var weightTipsAlertVm: DietPlanCreateWeightAlertVM = {
        let vm = DietPlanCreateWeightAlertVM.init(frame: .zero)

        return vm
    }()
    lazy var takeoutTipsAlertVm: GuidanceTakeoutFrequencyTipsAlertVM = {
        let vm = GuidanceTakeoutFrequencyTipsAlertVM.init(frame: .zero)
        return vm
    }()
    lazy var caloriesRecordTipsAlertVm: GuidanceExerciseCaloriesRecordTipsAlertVM = {
        let vm = GuidanceExerciseCaloriesRecordTipsAlertVM.init(frame: .zero)
        return vm
    }()
    lazy var goalTipsAlertVm: GuidanceNutritionGoalTipsAlertVM = {
        let vm = GuidanceNutritionGoalTipsAlertVM.init(frame: .zero)
        return vm
    }()

    lazy var fixGoalTipsAlertVm: QuestionCustomTipsAlertVM = {
        let vm = QuestionCustomTipsAlertVM(frame: .zero)
        vm.isHidden = true
        vm.titleLabel.text = "身体是动态的，目标也应如此"
        vm.contentLabelOne.text = "我们必须诚实地告诉你，无论是你自己计算，还是使用 Elavatine 基于科学研究和运动员长期实践经验设计的目标计算公式，都无法保证初始目标 100% 贴合你的真实身体需求。你的训练风格、日常习惯，以及代谢适应能力等，都可能影响你的实际摄入需求。\n\n但请不必担心，你完全可以通过观察体重增减与体型变化，自己逐渐调整摄入量或营养比例。\n\n如果你需要更专业的支持，ELA AI 教练也可以帮助你更快地找到最适合你的摄入目标并持续调整。"
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
        vm.manTapBlock = {[weak self] didChangeSex in
            self?.handleSexSelection(defaultHeight: 170, defaultWeight: 70, shouldResetFlow: didChangeSex)
        }
        vm.femanTapBlock = {[weak self] didChangeSex in
            self?.handleSexSelection(defaultHeight: 160, defaultWeight: 50, shouldResetFlow: didChangeSex)
        }
        vm.loginTapBlock = {() in
            self.loginAction()
        }
        vm.showTipsBlock = { [weak self] in
            self?.sexTipsAlertVm.showView()
        }

        return vm
    }()
    lazy var dietRecordVm: GuidanceDietRecordVM = {
        let vm = GuidanceDietRecordVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: 0, height: 0))
        vm.selectedBlock = {()in
            self.updateNextButtonForCurrentStep()
//            self.moveToStep(index: 2, animated: true)
        }
        vm.showTipsBlock = { [weak self] in
            self?.dietRecordTipsAlertVm.showView()
        }
        return vm
    }()
    lazy var progressChartVm: GuideTotalFirstVM = {
        let vm = GuideTotalFirstVM.init(frame: CGRect.init(x: SCREEN_WIDHT*2, y: 0, width: 0, height: 0))
        vm.shouldAutoStartChartAnimation = false
        vm.updateConstraitForGuidance()
        vm.chart.legendFadeWillStart = { [weak self] in
            self?.animateProgressChartNextButtonFadeIn()
        }
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
            QuestinonaireMsgModel.shared.caloriesNumber = ""
            QuestinonaireMsgModel.shared.carbohydrates = ""
            QuestinonaireMsgModel.shared.carbohydratesNumber = ""
            QuestinonaireMsgModel.shared.proteinNumber = ""
            QuestinonaireMsgModel.shared.fatsNumber = ""
            QuestinonaireMsgModel.shared.caloriesNumberFromServer = ""
            QuestinonaireMsgModel.shared.carbohydratesNumberFromServer = ""
            QuestinonaireMsgModel.shared.proteinNumberFromServer = ""
            QuestinonaireMsgModel.shared.fatsNumberFromServer = ""
            self?.updateFlowConfiguration()
//            self?.nextButtonTapAction()
            self?.updateNextButtonForCurrentStep()
        }
        return vm
    }()
    lazy var birthdayVm: DietPlanCreateYearVM = {
        let vm = DietPlanCreateYearVM.init(frame: CGRect.init(x: SCREEN_WIDHT*4, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var weightVm: DietPlanCreateWeightVM = {
        let vm = DietPlanCreateWeightVM.init(frame: CGRect.init(x: SCREEN_WIDHT*5, y: 0, width: 0, height: 0))
        vm.showTipsBlock = {()in
            self.weightTipsAlertVm.showView()
        }
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
        vm.showTipsBlock = {()in
            self.takeoutTipsAlertVm.showView()
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
//            self?.handleExerciseCaloriesRecordSelectionChanged()
        }
        vm.showTipsBlock = {()in
            self.caloriesRecordTipsAlertVm.showView()
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
//        vm.updateConstraitForGuidance()
        vm.applyGuidanceSelectionStyle(isCompact: self.isFixedTargetFlowEnabled)
        vm.titleLabel.text = "你的目标是什么？"
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
    lazy var elaProTransitionVm: GuidanceElaProTransitionVM = {
        let vm = GuidanceElaProTransitionVM(frame: CGRect(x: SCREEN_WIDHT * 19, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        return vm
    }()
    lazy var nutritionGoalVm: GuidanceNutritionGoalVM = {
        let vm = GuidanceNutritionGoalVM.init(frame: CGRect(x: SCREEN_WIDHT * 20, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vm.saveBlock = { [weak self] in
            self?.saveGuidanceNutritionGoals()
        }
        vm.tipsTapBlock = {()in
            self.goalTipsAlertVm.showView()
        }
        return vm
    }()
    lazy var fixedTargetNutritionGoalVm: GuidanceFixedTargetNutritionGoalVM = {
        let vm = GuidanceFixedTargetNutritionGoalVM.init(frame: CGRect(x: SCREEN_WIDHT * 20, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vm.saveBlock = { [weak self] in
            self?.nextButtonTapAction()
//            self?.saveGuidanceNutritionGoals()
        }
        vm.tipsTapBlock = {()in
            self.fixGoalTipsAlertVm.showView()
        }
        return vm
    }()
    lazy var reminderPromptVm: GuidanceReminderPromptVM = {
        let vm = GuidanceReminderPromptVM.init(frame: CGRect(x: SCREEN_WIDHT * 21, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vm.enableReminderBlock = { [weak self] in
            self?.handleReminderPromptCompletion(requestPermission: true)
        }
        vm.skipBlock = { [weak self] in
            self?.handleReminderPromptCompletion(requestPermission: false)
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
                if self.isUncertainFixedTargetSelection {
                    self.showStandaloneNutritionGoal()
                } else {
                    self.moveToStep(index: self.indexOfStep(.nutritionGoal) ?? self.currentIndex, animated: true)
                }
                return
            }
            self.isShowingFinishLoading = false
            self.finishLoadingVm.hideLoadingView()
            self.showGuidanceProVCForSubscription()
        }
        return vm
    }()
}

extension GuidanceVC{
    @objc func nextButtonTapAction() {
        guard !isStepTransitioning, !isScrollBackInteractionInProgress else { return }
        guard let currentStep = flowStep(for: currentIndex) else { return }

        switch currentStep {
        case .progressChart, .fixedTarget, .height, .bodyfat, .takeoutFrequency,
             .mealsAdjust, .exerciseCaloriesRecord, .cardioFrequency, .elaProTransition,
             .caloriesResultExplain, .nutritionGoal,.goalBarrier,.dietRecord:
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
            delayedNextWorkItem?.cancel()
            moveToStep(index: currentIndex + 1, animated: true)
        case .sex, .mealsSummary, .strengthTrainingSummary,  .reminderPrompt:
            break
        }
    }

    func handleSexSelection(defaultHeight: Int, defaultWeight: Int, shouldResetFlow: Bool = false) {
        // 改性别后，后续问题需要重新确认；这里把 clearMsg() 清掉的模型状态同步回各个缓存了 UI 选中态的页面。
        if shouldResetFlow {
            resetGuidanceStateAfterSexSelection()
        }
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
              (isSummaryStep(step) || shouldSkipBackwardStep(step)) {
            targetIndex -= 1
        }
        return max(0, targetIndex)
    }

    @objc func handleBackEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard gesture.state == .recognized else { return }
        navigateBackOneStep()
    }

    func navigateBackOneStep() {
        if isShowingFinishLoading {
            return
        }
        if isBackNavigationLocked || isStepTransitioning {
            return
        }
        if currentIndex == 0 {
            backTapAction()
            return
        }
        if let currentStep = flowStep(for: currentIndex),
           shouldDisableBack(for: currentStep) {
            return
        }
        let targetIndex = previousNavigableIndex(from: currentIndex)
        moveToStep(index: targetIndex, animated: true)
    }

    func shouldSkipBackwardStep(_ step: FlowStep) -> Bool {
        !isFixedTargetFlowEnabled && step == .nutritionGoal
    }

    func shouldSkipForwardTransitionStep(_ step: FlowStep) -> Bool {
        !isFixedTargetFlowEnabled && step == .nutritionGoal
    }

    func progressIndex(for flowIndex: Int) -> Int {
        let prefixSteps = activeFlow.prefix(max(0, flowIndex + 1))
        let actualStepCount = prefixSteps.filter { shouldCountForProgress($0) }.count
        return max(0, actualStepCount - 1)
    }

    func shouldDisableBack(for step: FlowStep) -> Bool {
        isSummaryStep(step) || (!isFixedTargetFlowEnabled && step == .nutritionGoal)
    }

    func shouldDisableBackEdgePan(for step: FlowStep) -> Bool {
        if isSummaryStep(step) {
            return true
        }
        if step == .progressChart {
            return nextButton.isHidden || nextButton.alpha < 0.99 || !nextButton.isEnabled
        }
        return shouldDisableBack(for: step)
    }

    func shouldHideBackButton(for step: FlowStep) -> Bool {
        step == .sex
    }

    func shouldHideNavigation(for step: FlowStep) -> Bool {
        if isShowingFinishLoading || isSummaryStep(step) {
            return true
        }
        return shouldDisableBack(for: step)
    }

    func refreshBackButtonState(for step: FlowStep, index: Int) {
        naviVm.backButton.isHidden = shouldHideBackButton(for: step)
        naviVm.backButton.isEnabled = index > 0 &&
            !shouldDisableBack(for: step) &&
            !isBackNavigationLocked &&
            !isShowingFinishLoading
    }

    func updateFlowConfiguration() {
        syncCardioFrequencyFlowState()
        if mountedSteps.contains(.goal) {
            goalVm.applyGuidanceSelectionStyle(isCompact: isFixedTargetFlowEnabled)
        }
        if isFixedTargetFlowEnabled {
            stepsArray = fixedTargetStepsArray
        } else if isUncertainFixedTargetSelection {
            stepsArray = shouldSkipCardioFrequencyStep ? defaultStepsArrayWithoutCardioUncertain : defaultStepsArrayUncertain
        } else {
            stepsArray = shouldSkipCardioFrequencyStep ? defaultStepsArrayWithoutCardio : defaultStepsArray
        }
        scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT * CGFloat(totalSteps), height: SCREEN_HEIGHT)
        layoutMountedStepViews()
        updateNutritionGoalViewVisibility()
    }

    func syncCardioFrequencyFlowState() {
        guard !isFixedTargetFlowEnabled else {
            hasAutoSelectedSkippedCardioFrequency = false
            return
        }

        if shouldSkipCardioFrequencyStep {
            cardioFrequencyVm.selectNeverAsDefault()
            hasAutoSelectedSkippedCardioFrequency = true
        } else if hasAutoSelectedSkippedCardioFrequency {
            cardioFrequencyVm.clearSelection()
            hasAutoSelectedSkippedCardioFrequency = false
        }
    }

    func handleExerciseCaloriesRecordSelectionChanged() {
        moveToStep(index: currentIndex, animated: false)
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

    func shouldUseDirectStepTransition(from sourceIndex: Int, to targetIndex: Int, animated: Bool) -> Bool {
        guard animated, sourceIndex != targetIndex, abs(sourceIndex - targetIndex) > 1 else { return false }
        let lower = min(sourceIndex, targetIndex) + 1
        let upper = max(sourceIndex, targetIndex)
        guard lower < upper else { return false }

        let intermediateSteps = activeFlow[lower..<upper]
        return !intermediateSteps.isEmpty && intermediateSteps.allSatisfy {
            isSummaryStep($0) || shouldSkipForwardTransitionStep($0)
        }
    }

    func performDirectStepTransition(from sourceIndex: Int, to targetIndex: Int) {
        guard let sourceStep = flowStep(for: sourceIndex),
              let targetStep = flowStep(for: targetIndex),
              let sourceView = stepView(for: sourceStep),
              let targetView = stepView(for: targetStep) else {
            scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(targetIndex), y: 0), animated: false)
            isBackNavigationLocked = false
            finishStepTransitionIfNeeded(animated: false)
            handleStepDidBecomeVisible(flowStep(for: targetIndex))
            return
        }

        let sourceFrame = CGRect(x: SCREEN_WIDHT * CGFloat(sourceIndex), y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        let targetFrame = CGRect(x: SCREEN_WIDHT * CGFloat(targetIndex), y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        let visibleFrame = CGRect(x: SCREEN_WIDHT * CGFloat(sourceIndex), y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        let direction: CGFloat = targetIndex < sourceIndex ? -1 : 1

        sourceView.frame = visibleFrame
        targetView.frame = visibleFrame.offsetBy(dx: direction * SCREEN_WIDHT, dy: 0)
        scrollViewBase.bringSubviewToFront(sourceView)
        scrollViewBase.bringSubviewToFront(targetView)

        UIView.animate(withDuration: 0.28,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]) {
            sourceView.frame = visibleFrame.offsetBy(dx: -direction * SCREEN_WIDHT, dy: 0)
            targetView.frame = visibleFrame
        } completion: { _ in
            sourceView.frame = sourceFrame
            targetView.frame = targetFrame
            self.scrollViewBase.setContentOffset(CGPoint(x: targetFrame.minX, y: 0), animated: false)
            self.isBackNavigationLocked = false
            self.finishStepTransitionIfNeeded(animated: false)
            self.refreshBackButtonState(for: targetStep, index: targetIndex)
            self.handleStepDidBecomeVisible(targetStep)
        }
    }

    func handleStepDidBecomeVisible(_ step: FlowStep?) {
        guard let step = step else { return }
        if step == .removeBarrier {
            removeBarrierVm.startScrollersIfNeeded()
        } else {
            removeBarrierVm.stopScrollers()
        }
        sendGuidanceV2PageViewIfNeeded(for: step)
    }

    func sendGuidanceV2PageViewIfNeeded(for step: FlowStep) {
        guard let pageInfo = guidanceV2PageInfo(for: step) else { return }
        let pageKey = "\(pageInfo.pageIndex)-\(pageInfo.pageTitle)-\(pageInfo.bizType)"
        guard lastGuidanceV2TrackedPageKey != pageKey else { return }
        lastGuidanceV2TrackedPageKey = pageKey
        EventLogUtils().sendGuidanceV2PageView(
            pageIndex: pageInfo.pageIndex,
            pageTitle: pageInfo.pageTitle,
            bizType: pageInfo.bizType
        )
    }

    func guidanceV2PageInfo(for step: FlowStep) -> (pageIndex: String, pageTitle: String, bizType: String)? {
        switch step {
        case .sex:
            return ("2", "性别", "")
        case .dietRecord:
            return ("3", "饮食记录经验", "")
        case .progressChart:
            return ("4", "记录与否差异动画页", "")
        case .fixedTarget:
            return ("5", "是否有固定的tdee", "")
        case .birthday:
            return ("6", "出生年份", "自动")
        case .weight:
            return ("7", "体重", "自动")
        case .height:
            return ("8", "身高", "自动")
        case .bodyfat:
            return ("9", "体脂率", "自动")
        case .takeoutFrequency:
            return ("10", "周外卖频率", "自动")
        case .mealsPerDay:
            return isFixedTargetFlowEnabled ? ("9", "日餐数", "手动") : ("11", "日餐数", "自动")
        case .mealsSummary:
            return isFixedTargetFlowEnabled ? ("10", "日餐数描述", "手动") : ("12", "日餐数描述", "自动")
        case .mealsAdjust:
            return isFixedTargetFlowEnabled ? ("11", "日餐数调整", "手动") : ("13", "日餐数调整", "自动")
        case .exerciseCaloriesRecord:
            return ("14", "是否记录运动消耗热量", "自动")
        case .cardioFrequency:
            return ("15", "周有氧运动频率", "自动")
        case .strengthTrainingFrequency:
            return isFixedTargetFlowEnabled ? ("7", "周力量训练频率", "手动") : ("16", "周力量训练频率", "自动")
        case .strengthTrainingSummary:
            return isFixedTargetFlowEnabled ? ("8", "周力量训练频率描述", "手动") : ("17", "周力量训练频率描述", "自动")
        case .caloriesResultBase:
            return ("18", "tdee结果", "自动")
        case .caloriesResultExplain:
            return ("19", "计算tdee缺口或盈余", "自动")
        case .goal:
            return isFixedTargetFlowEnabled ? ("12", "目标", "手动") : ("20", "目标", "自动")
        case .goalBarrier:
            return isFixedTargetFlowEnabled ? ("13", "阻碍因素", "手动") : ("21", "阻碍因素", "自动")
        case .removeBarrier:
            return isFixedTargetFlowEnabled ? ("14", "ela广告动画页", "手动") : ("22", "ela广告动画页", "自动")
        case .elaProTransition:
            return isFixedTargetFlowEnabled ? ("15", "你只用记录饮食", "手动") : ("23", "你只用记录饮食", "自动")
        case .nutritionGoal:
            return isFixedTargetFlowEnabled ? ("6", "营养目标", "手动") : ("26", "保存目标", "自动")
        case .reminderPrompt:
            return isFixedTargetFlowEnabled ? ("16", "是否打开提醒", "手动") : ("24", "是否打开提醒", "自动")
        }
    }

    func resetGuidanceStateAfterSexSelection() {
        nextButtonEnableWorkItem?.cancel()
        nextButtonEnableWorkItem = nil
        delayedNextWorkItem?.cancel()
        delayedNextWorkItem = nil
        removeBarrierVm.stopScrollers()

        pendingNutritionGoalPresentation = false
        isShowingFinishLoading = false
        isBackNavigationLocked = false
        finishLoadingVm.hideLoadingView()

        reminderPromptVm.alpha = 1
        naviVm.isHidden = false

        resetStandaloneNutritionGoalPresentation()
        resetNutritionGoalDraftViews()
        syncStepViewStatesAfterModelReset()
        updateFlowConfiguration()
    }

    func resetStandaloneNutritionGoalPresentation() {
        if isShowingStandaloneNutritionGoal {
            hideStandaloneNutritionGoalIfNeeded()
        } else {
            nutritionGoalVm.removeFromSuperview()
            nutritionGoalVm.isHidden = true
            nutritionGoalVm.alpha = 1
        }
    }

    func resetNutritionGoalDraftViews() {
        nutritionGoalVm.endEditing(true)
        fixedTargetNutritionGoalVm.endEditing(true)

        nutritionGoalVm.carNumber = 0
        nutritionGoalVm.proteinNumber = 0
        nutritionGoalVm.fatNumber = 0
        nutritionGoalVm.carVm.textField.text = nil
        nutritionGoalVm.proteinVm.textField.text = nil
        nutritionGoalVm.fatVm.textField.text = nil
        nutritionGoalVm.labelOne.text = "-"
        nutritionGoalVm.labelOne.textColor = .COLOR_TEXT_TITLE_0f1214_25

        fixedTargetNutritionGoalVm.carNumber = 0
        fixedTargetNutritionGoalVm.proteinNumber = 0
        fixedTargetNutritionGoalVm.fatNumber = 0
        fixedTargetNutritionGoalVm.carVm.textField.text = nil
        fixedTargetNutritionGoalVm.proteinVm.textField.text = nil
        fixedTargetNutritionGoalVm.fatVm.textField.text = nil
        fixedTargetNutritionGoalVm.labelOne.text = "-"
        fixedTargetNutritionGoalVm.labelOne.textColor = .COLOR_TEXT_TITLE_0f1214_25
    }

    func syncStepViewStatesAfterModelReset() {
        dietRecordVm.refreshSelectionFromModel()
        fixedTargetVm.refreshSelectionFromModel()
        takeoutFrequencyVm.refreshSelectionFromModel()
        mealsPerDayVm.refreshSelectionFromModel()
        mealsAdjustVm.refreshSelectionFromModel()
        exerciseCaloriesRecordVm.refreshSelectionFromModel()
        cardioFrequencyVm.refreshSelectionFromModel()
        strengthTrainingFrequencyVm.refreshSelectionFromModel()
        bodyfatVm.updateScrollView()
        syncGoalSelectionFromModel()
        goalBarrierVm.updateContentForGoal(modelValue: QuestinonaireMsgModel.shared.goal)
        goalBarrierVm.refreshSelectionFromModel()
    }

    func syncGoalSelectionFromModel() {
        let goalValue = QuestinonaireMsgModel.shared.goal.trimmingCharacters(in: .whitespacesAndNewlines)
        if let goalIndex = Int(goalValue), goalIndex > 0 {
            goalVm.selectIndex = goalIndex - 1
        } else {
            goalVm.selectIndex = -1
        }
        goalVm.tableView.reloadData()
    }

    func refreshStepViewStateFromModel(for step: FlowStep, shouldCenterBodyfatSelection: Bool = true) {
        switch step {
        case .dietRecord:
            dietRecordVm.refreshSelectionFromModel()
        case .fixedTarget:
            fixedTargetVm.refreshSelectionFromModel()
        case .bodyfat:
            let bodyFatValue = QuestinonaireMsgModel.shared.bodyFat.trimmingCharacters(in: .whitespacesAndNewlines)
            if bodyFatValue.isEmpty {
                bodyfatVm.updateScrollView()
            } else {
                bodyfatVm.restoreSelection(modelValue: bodyFatValue, shouldCenterSelectedItem: shouldCenterBodyfatSelection)
            }
        case .takeoutFrequency:
            takeoutFrequencyVm.refreshSelectionFromModel()
        case .mealsPerDay:
            mealsPerDayVm.refreshSelectionFromModel()
        case .mealsAdjust:
            mealsAdjustVm.refreshSelectionFromModel()
        case .exerciseCaloriesRecord:
            exerciseCaloriesRecordVm.refreshSelectionFromModel()
        case .cardioFrequency:
            cardioFrequencyVm.refreshSelectionFromModel()
        case .strengthTrainingFrequency:
            strengthTrainingFrequencyVm.refreshSelectionFromModel()
        case .goal:
            syncGoalSelectionFromModel()
        case .goalBarrier:
            goalBarrierVm.updateContentForGoal(modelValue: QuestinonaireMsgModel.shared.goal)
            goalBarrierVm.refreshSelectionFromModel()
        case .nutritionGoal:
            if isFixedTargetFlowEnabled {
                fixedTargetNutritionGoalVm.endEditing(true)
            } else {
                nutritionGoalVm.refreshContentFromModel()
            }
        case .reminderPrompt:
            reminderPromptVm.alpha = 1
        default:
            break
        }
    }

    func moveToStep(index: Int, animated: Bool, prefetchAhead: Bool = true) {
        guard !isStepTransitioning || !animated || index == currentIndex else { return }
        updateFlowConfiguration()
        hideStandaloneNutritionGoalIfNeeded()
        let sourceIndex = currentIndex
        let targetIndex = max(0, min(index, totalSteps - 1))
        guard let targetStep = flowStep(for: targetIndex) else { return }
        if flowStep(for: currentIndex) == .nutritionGoal, isFixedTargetFlowEnabled {
            fixedTargetNutritionGoalVm.endEditing(true)
        }
        refreshStepViewStateFromModel(for: targetStep)
        let indexesToInstall = prefetchAhead ? [targetIndex, targetIndex + 1, targetIndex + 2] : [targetIndex]
        installStepViewsIfNeeded(indexes: indexesToInstall)
        currentIndex = targetIndex
        let visibleIndex = scrollableIndex(for: targetIndex)
        let targetOffset = CGPoint(x: SCREEN_WIDHT * CGFloat(visibleIndex), y: 0)
        let shouldUseDirectTransition = shouldUseDirectStepTransition(from: sourceIndex, to: targetIndex, animated: animated)
        let shouldLockBack = (animated || shouldUseDirectTransition) && abs(scrollViewBase.contentOffset.x - targetOffset.x) > 0.5
        prepareStepTransition(to: targetOffset.x, animated: animated || shouldUseDirectTransition)
        isBackNavigationLocked = shouldLockBack
        naviVm.updateStep(steps: stepsArray, currentStep: progressIndex(for: targetIndex))
        refreshBackButtonState(for: targetStep, index: targetIndex)
        naviVm.isHidden = shouldHideNavigation(for: targetStep)
        updateNextButtonForCurrentStep()

        if shouldUseDirectTransition {
            performDirectStepTransition(from: sourceIndex, to: targetIndex)
        } else {
            scrollViewBase.setContentOffset(targetOffset, animated: animated)
            if !animated {
                isBackNavigationLocked = false
                finishStepTransitionIfNeeded(animated: animated)
                handleStepDidBecomeVisible(targetStep)
            }
        }

        if targetStep == .progressChart {
            if hasCompletedProgressChartAnimation || progressChartVm.chart.areLegendLabelsVisible {
                showCompletedProgressChartPresentation()
            } else {
                resetProgressChartNextButtonPresentation()
                updateScrollViewBaseScrollAvailability()
                progressChartVm.chart.startGradientAnimation(duration: 2.4)
            }
        }
        if targetStep == .goalBarrier {
            goalBarrierVm.updateContentForGoal(modelValue: QuestinonaireMsgModel.shared.goal)
        }
        if targetStep == .nutritionGoal {
            if isFixedTargetFlowEnabled {
                let focusDelay = animated ? 0.35 : 0
                DispatchQueue.main.asyncAfter(deadline: .now() + focusDelay) { [weak self] in
                    guard let self = self,
                          self.flowStep(for: self.currentIndex) == .nutritionGoal,
                          self.isFixedTargetFlowEnabled else { return }
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
        case .sex, .mealsSummary, .strengthTrainingSummary, .nutritionGoal, .reminderPrompt:
            nextButton.isHidden = true
            nextButton.isEnabled = false
            nextButton.alpha = 1
        case .progressChart:
            let isReady = hasCompletedProgressChartAnimation || progressChartVm.chart.areLegendLabelsVisible
            nextButton.isHidden = false
            nextButton.isEnabled = isReady
            nextButton.alpha = isReady ? 1 : 0
        case .fixedTarget:
            nextButton.isHidden = false
            nextButton.isEnabled = fixedTargetVm.hasSelection
            nextButton.alpha = 1
        case .birthday, .weight, .height, .removeBarrier, .elaProTransition:
            nextButton.isHidden = false
            nextButton.isEnabled = true
            nextButton.alpha = 1
        case .bodyfat:
            nextButton.isHidden = false
            nextButton.isEnabled = bodyfatVm.selectIndex >= 0
            nextButton.alpha = 1
        case .takeoutFrequency:
            nextButton.isHidden = false
            nextButton.isEnabled = takeoutFrequencyVm.hasSelection
            nextButton.alpha = 1
        case .mealsPerDay:
            nextButton.isHidden = false
            nextButton.isEnabled = mealsPerDayVm.hasSelection
            nextButton.alpha = 1
        case .mealsAdjust:
            nextButton.isHidden = false
            nextButton.isEnabled = mealsAdjustVm.hasSelection
            nextButton.alpha = 1
        case .exerciseCaloriesRecord:
            nextButton.isHidden = false
            nextButton.isEnabled = exerciseCaloriesRecordVm.hasSelection
            nextButton.alpha = 1
        case .cardioFrequency:
            nextButton.isHidden = false
            nextButton.isEnabled = cardioFrequencyVm.hasSelection
            nextButton.alpha = 1
        case .strengthTrainingFrequency:
            nextButton.isHidden = false
            nextButton.isEnabled = strengthTrainingFrequencyVm.hasSelection
            nextButton.alpha = 1
        case .caloriesResultBase, .caloriesResultExplain:
            nextButton.isHidden = false
            nextButton.isEnabled = true
            nextButton.alpha = 1
        case .goal:
            nextButton.isHidden = false
            nextButton.isEnabled = goalVm.selectIndex >= 0
            nextButton.alpha = 1
        case .dietRecord:
            nextButton.isHidden = false
            nextButton.isEnabled = dietRecordVm.selectedIndex >= 0
            nextButton.alpha = 1
        case .goalBarrier:
            nextButton.isHidden = false
            nextButton.isEnabled = goalBarrierVm.hasSelection
            nextButton.alpha = 1
        }
    }

    func handleReminderPromptCompletion(requestPermission: Bool) {
        if requestPermission {
            requestReminderPermissionIfNeeded()
            return
        }

        if isUncertainFixedTargetSelection {
            startNutritionGoalLoadingFlow()
        } else {
            finishGuidanceFlow()
        }
        self.reminderPromptVm.alpha = 0
    }

    func finishGuidanceFlow() {
        UserInfoModel.shared.showNotifiAuthoriAlertVM = false
        if isFixedTargetFlowEnabled {
            QuestinonaireMsgModel.shared.surveytype = "custom_v2"
            startFinalGuidanceSubmissionFlow()
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
                titleText: "正在保存你的设置...",
                completionTitleText: "已完成",
                completionNotifyDelay: 0.35
            )
        } else {
            finishLoadingVm.configureLoading(titleText: "目标生成中...")
        }
        finishLoadingVm.showLoading(waitForExternalCompletion: true)
        EventLogUtils().sendGuidanceV2PageView(
            pageIndex: isFixedTargetFlowEnabled ? "17" : "25",
            pageTitle: "百分比动画页",
            bizType: isFixedTargetFlowEnabled ? "手动" : "自动"
        )
        submitCompletedGuidanceFlow()
    }

    func startNutritionGoalLoadingFlow() {
        guard !isShowingFinishLoading else { return }
        delayedNextWorkItem?.cancel()
        delayedNextWorkItem = nil
        removeBarrierVm.stopScrollers()
        hideStandaloneNutritionGoalIfNeeded()
        isShowingFinishLoading = true
        pendingNutritionGoalPresentation = true
        naviVm.isHidden = true
        nextButton.isHidden = true
        nextButton.isEnabled = false
        finishLoadingVm.configureLoading(titleText: "目标生成中...")
        finishLoadingVm.layoutIfNeeded()
        finishLoadingVm.showLoading(waitForExternalCompletion: true)
        EventLogUtils().sendGuidanceV2PageView(pageIndex: "25", pageTitle: "百分比动画页", bizType: "自动")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.isUncertainFixedTargetSelection {
                self.requestGuidanceBasicConsumption { [weak self] success in
                    guard let self = self else { return }
                    guard success else {
                        DispatchQueue.main.async {
                            self.cancelNutritionGoalLoadingFlow()
                            self.presentAlertVc(confirmBtn: "刷新", message: "", title: "当前网络不稳定", cancelBtn: nil, handler: { _ in
                                self.startNutritionGoalLoadingFlow()
                            }, viewController: self)
                        }
                        return
                    }
                    self.sendGuidanceNutritionGoalRequest()
                }
            } else {
                self.sendGuidanceNutritionGoalRequest()
            }
        }
    }

    func showStandaloneNutritionGoal() {
        isShowingStandaloneNutritionGoal = true
        nutritionGoalVm.refreshContentFromModel()
        sendGuidanceV2PageViewIfNeeded(for: .nutritionGoal)

        if nutritionGoalVm.superview !== view {
            nutritionGoalVm.removeFromSuperview()
            view.addSubview(nutritionGoalVm)
            nutritionGoalVm.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        nutritionGoalVm.isHidden = false
        nutritionGoalVm.alpha = 0
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]) {
            self.nutritionGoalVm.alpha = 1
        }
        view.bringSubviewToFront(nutritionGoalVm)
        view.bringSubviewToFront(goalTipsAlertVm)
        nextButton.isHidden = true
        nextButton.isEnabled = false
        naviVm.isHidden = true
    }

    func hideStandaloneNutritionGoalIfNeeded() {
        guard isShowingStandaloneNutritionGoal else { return }
        isShowingStandaloneNutritionGoal = false
        nutritionGoalVm.endEditing(true)
        nutritionGoalVm.isHidden = true
        nutritionGoalVm.alpha = 1
        nutritionGoalVm.removeFromSuperview()
//        nutritionGoalVm.isHidden = true
    }

    func cancelNutritionGoalLoadingFlow() {
        pendingNutritionGoalPresentation = false
        isShowingFinishLoading = false
        finishLoadingVm.hideLoadingView()
        naviVm.isHidden = false
        if let currentStep = flowStep(for: currentIndex) {
            refreshBackButtonState(for: currentStep, index: currentIndex)
        }
        updateNextButtonForCurrentStep()
    }

    func cancelFinalGuidanceSubmissionFlow() {
        pendingNutritionGoalPresentation = false
        isShowingFinishLoading = false
        finishLoadingVm.hideLoadingView()

        let currentStep = flowStep(for: currentIndex) ?? .reminderPrompt
        naviVm.isHidden = shouldHideNavigation(for: currentStep)
        refreshBackButtonState(for: currentStep, index: currentIndex)
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
                    if self.isUncertainFixedTargetSelection {
                        self.startNutritionGoalLoadingFlow()
                    } else {
                        self.finishGuidanceFlow()
                    }
                }
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                    DispatchQueue.main.async {
                        if self.isUncertainFixedTargetSelection {
                            self.startNutritionGoalLoadingFlow()
                        } else {
                            self.finishGuidanceFlow()
                        }
                    }
                }
            @unknown default:
                DispatchQueue.main.async {
                    if self.isUncertainFixedTargetSelection {
                        self.startNutritionGoalLoadingFlow()
                    } else {
                        self.finishGuidanceFlow()
                    }
                }
            }
        }
    }

    func handleProgressChartAnimationFinished() {
        guard flowStep(for: currentIndex) == .progressChart else { return }
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self, self.flowStep(for: self.currentIndex) == .progressChart else { return }
            self.hasCompletedProgressChartAnimation = true
            self.updateNextButtonEnabledState(true, animated: true)
            self.updateScrollViewBaseScrollAvailability()
        }
        nextButtonEnableWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }

    func resetProgressChartNextButtonPresentation() {
        guard flowStep(for: currentIndex) == .progressChart else { return }
        nextButton.isHidden = false
        nextButton.isEnabled = false
        nextButton.alpha = 0
        updateScrollViewBaseScrollAvailability()
    }

    func showCompletedProgressChartPresentation() {
        hasCompletedProgressChartAnimation = true
        nextButtonEnableWorkItem?.cancel()
        nextButtonEnableWorkItem = nil
        progressChartVm.chart.showCompletedState()
        nextButton.isHidden = false
        nextButton.alpha = 1
        nextButton.isEnabled = true
        updateScrollViewBaseScrollAvailability()
    }

    func animateProgressChartNextButtonFadeIn() {
        guard flowStep(for: currentIndex) == .progressChart else { return }
        guard nextButton.isHidden == false else { return }
        guard nextButton.alpha < 1 else { return }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState]) {
            self.nextButton.alpha = 1
        }
    }

    func updateNextButtonEnabledState(_ isEnabled: Bool, animated: Bool) {
        guard nextButton.isEnabled != isEnabled else { return }
        if animated {
            UIView.transition(with: nextButton, duration: 0.24, options: [.transitionCrossDissolve, .allowAnimatedContent, .beginFromCurrentState]) {
                self.nextButton.isEnabled = isEnabled
            }
            return
        }
        nextButton.isEnabled = isEnabled
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

    private func normalizedNutritionGoalText(_ text: String) -> String {
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalizedText == "-" {
            return ""
        }
        return normalizedText
    }

    private func resolvedNutritionGoalText(primary: String, fallback: String) -> String {
        let primaryText = normalizedNutritionGoalText(primary)
        if !primaryText.isEmpty {
            return primaryText
        }
        return normalizedNutritionGoalText(fallback)
    }

    private func resolvedNutritionGoalInt(primary: String, fallback: String) -> Int? {
        let resolvedText = resolvedNutritionGoalText(primary: primary, fallback: fallback)
        if let intValue = Int(resolvedText), intValue > 0 {
            return intValue
        }
        if let doubleValue = Double(resolvedText), doubleValue > 0 {
            return Int(doubleValue.rounded())
        }
        return nil
    }

    private func resolvedNutritionGoalRequestCaloriesText() -> String? {
        guard let calories = resolvedNutritionGoalInt(primary: QuestinonaireMsgModel.shared.caloriesNumber,
                                                      fallback: QuestinonaireMsgModel.shared.caloriesNumberFromServer) else {
            return nil
        }
        return "\(calories)"
    }

    private func parsedNutritionGoalValue(from data: NSDictionary, key: String) -> Int? {
        let rawValue = data[key]
        if let intValue = rawValue as? Int {
            return intValue
        }
        let doubleValue = data.doubleValueForKey(key: key)
        if rawValue != nil || doubleValue > 0 {
            return Int(doubleValue.rounded())
        }
        if let stringValue = rawValue as? String,
           let intValue = Int(stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return intValue
        }
        return nil
    }

    private func parsedValidNutritionGoalPayload(from data: NSDictionary) -> (carbohydrate: Int, fat: Int, protein: Int, calories: Int)? {
        guard
            let carbohydrate = parsedNutritionGoalValue(from: data, key: "carbohydrate"),
            let fat = parsedNutritionGoalValue(from: data, key: "fat"),
            let protein = parsedNutritionGoalValue(from: data, key: "protein"),
            let calories = parsedNutritionGoalValue(from: data, key: "calories")
        else {
            return nil
        }

        guard carbohydrate >= 0, fat > 0, protein > 0, calories > 0 else {
            return nil
        }

        return (carbohydrate, fat, protein, calories)
    }

    private func presentNutritionGoalRequestErrorAlert() {
        DispatchQueue.main.async {
            self.cancelNutritionGoalLoadingFlow()
            self.presentAlertVc(confirmBtn: "刷新", message: "", title: "营养目标生成失败，请稍后重试", cancelBtn: nil, handler: { _ in
                self.startNutritionGoalLoadingFlow()
            }, viewController: self)
        }
    }

    func saveGuidanceNutritionGoals() {
        hideStandaloneNutritionGoalIfNeeded()
        if isFixedTargetFlowEnabled, let goalBarrierIndex = indexOfStep(.goalBarrier) {
            moveToStep(index: goalBarrierIndex, animated: true)
            return
        }
        QuestinonaireMsgModel.shared.surveytype = "part_v2"
        showGuidanceProVCForSubscription()
//        NutritionDefaultModel.shared.saveGoals(dict: [
//            "calories": QuestinonaireMsgModel.shared.caloriesNumber,
//            "carbohydrates": QuestinonaireMsgModel.shared.carbohydratesNumber,
//            "proteins": QuestinonaireMsgModel.shared.proteinNumber,
//            "fats": QuestinonaireMsgModel.shared.fatsNumber
//        ])
//        moveToStep(index: 20, animated: true)
    }

    func showGuidanceProVCForSubscription() {
        guard !isTransitioningToGuidancePro else { return }
        isTransitioningToGuidancePro = true
        DLLog(message: "[GuidancePro][Route] request subscription page, hasResolved=\(hasResolvedGuidanceProSubscriptionHistory), cachedHasFreeTrial=\(cachedGuidanceProHasFreeTrialPermission)")

        if hasResolvedGuidanceProSubscriptionHistory {
            presentGuidanceProSubscriptionVC(hasSubscribedHistory: !cachedGuidanceProHasFreeTrialPermission)
            return
        }

        resolveGuidanceProSubscriptionHistoryState { [weak self] hasSubscribedHistory in
            self?.presentGuidanceProSubscriptionVC(hasSubscribedHistory: hasSubscribedHistory)
        }
    }

    func prefetchGuidanceProSubscriptionHistoryIfNeeded() {
        guard !hasPrefetchedGuidanceProSubscriptionHistory else { return }
        hasPrefetchedGuidanceProSubscriptionHistory = true
        DLLog(message: "[GuidancePro][Route] prefetch subscription history")

        resolveGuidanceProSubscriptionHistoryState(completion: nil)
    }

    func prefetchGuidanceProProductsIfNeeded() {
        guard !hasPrefetchedGuidanceProProducts else { return }
        hasPrefetchedGuidanceProProducts = true
        DLLog(message: "[GuidancePro][Route] prefetch product list")

        ElaProPriceVM.preloadProducts(bizType: "1") { success in
            DLLog(message: "[GuidancePro][Route] prefetch product list finished, isPurchased=0, success=\(success)")
        }
        ElaProPriceVM.preloadProducts(bizType: "1", isPurchased: "1") { success in
            DLLog(message: "[GuidancePro][Route] prefetch product list finished, isPurchased=1, success=\(success)")
        }
    }

    func resolveGuidanceProSubscriptionHistoryState(completion: ((Bool) -> Void)?) {
        let trialHistoryProductID = guidanceProTrialHistoryProductID.trimmingCharacters(in: .whitespacesAndNewlines)
        DLLog(message: "[GuidancePro][Route] resolve subscription history, trialHistoryProductID=\(trialHistoryProductID)")
        guard !trialHistoryProductID.isEmpty else {
            cachedGuidanceProHasFreeTrialPermission = true
            hasResolvedGuidanceProSubscriptionHistory = true
            DLLog(message: "[GuidancePro][Route] trialHistoryProductID empty, default hasFreeTrial=true")
            completion?(false)
            return
        }

        ElaProIAPManager.shared.checkSubscriptionHistoryState(productID: trialHistoryProductID) { [weak self] state in
            guard let self = self else { return }
            self.hasResolvedGuidanceProSubscriptionHistory = true
            switch state {
            case .subscribed:
                self.cachedGuidanceProHasFreeTrialPermission = false
                DLLog(message: "[GuidancePro][Route] subscription history result=subscribed, route=GuidanceProPurchasedVC")
                completion?(true)
            case .notSubscribed:
                self.cachedGuidanceProHasFreeTrialPermission = true
                DLLog(message: "[GuidancePro][Route] subscription history result=notSubscribed, route=GuidanceProVC")
                completion?(false)
            case .unknown:
                self.cachedGuidanceProHasFreeTrialPermission = true
                DLLog(message: "[GuidancePro][Route] subscription history result=unknown, route=GuidanceProVC")
                completion?(false)
            }
        }
    }

    func presentGuidanceProSubscriptionVC(hasSubscribedHistory: Bool) {
        let vc: WHBaseViewVC
        let guidanceV2BizType = isFixedTargetFlowEnabled ? "手动" : "自动"
        if hasSubscribedHistory {
            let purchasedVC = GuidanceProPurchasedVC()
            purchasedVC.guidanceV2BizType = guidanceV2BizType
            purchasedVC.nextBlock = { [weak purchasedVC] in
                purchasedVC?.changeRootVcToLogin()
            }
            DLLog(message: "[GuidancePro][Route] push GuidanceProPurchasedVC")
            vc = purchasedVC
        } else {
            let proVC = GuidanceProVC()
            proVC.guidanceV2BizType = guidanceV2BizType
            proVC.hasFreeTrialPermission = cachedGuidanceProHasFreeTrialPermission
            proVC.nextBlock = { [weak proVC] in
                proVC?.changeRootVcToLogin()
            }
            DLLog(message: "[GuidancePro][Route] push GuidanceProVC, hasFreeTrialPermission=\(cachedGuidanceProHasFreeTrialPermission)")
            vc = proVC
        }

//        self.navigationController?.fd_interactivePopDisabled = true
//        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        if let navigationController = navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
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
                self.completeLoginSuccessAndEnterApp()
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
        case .elaProTransition: return elaProTransitionVm
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

    func scheduleDeferredInitialStepWarmup() {
        deferredInitialStepWarmupWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.installStepViewsIfNeeded(indexes: [1, 2])
        }
        deferredInitialStepWarmupWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: workItem)
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
        view.addSubview(sexTipsAlertVm)
        view.addSubview(dietRecordTipsAlertVm)
        view.addSubview(weightTipsAlertVm)
        view.addSubview(takeoutTipsAlertVm)
        view.addSubview(caloriesRecordTipsAlertVm)
        view.addSubview(goalTipsAlertVm)
        view.addSubview(fixGoalTipsAlertVm)
        view.addSubview(finishLoadingVm)

        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.isScrollEnabled = true
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.bounces = false
        scrollViewBase.delegate = self
        view.addGestureRecognizer(backEdgePanGesture)
        updateFlowConfiguration()

        installStepViewsIfNeeded(indexes: [0])

        setConstrait()
        moveToStep(index: 0, animated: false, prefetchAhead: false)
        scheduleDeferredInitialStepWarmup()
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
        requestGuidanceBasicConsumption { [weak self] success in
            guard let self = self, success else { return }
            DispatchQueue.main.async {
                self.moveToStep(index: self.indexOfStep(step) ?? self.currentIndex, animated: true)
            }
        }
    }

    func requestGuidanceBasicConsumption(completion: ((Bool) -> Void)? = nil) {
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
            guard let calories = Int(caloriesText), calories > 0 else {
                DLLog(message: "sendBasicRequest(guidance) invalid calories response:\(caloriesText)")
                DispatchQueue.main.async {
                    completion?(false)
                }
                return
            }
//            QuestinonaireMsgModel.shared.caloriesNumber = caloriesText
//            QuestinonaireMsgModel.shared.caloriesNumberFromServer = caloriesText
            QuestinonaireMsgModel.shared.caloriesNumberFromServer = "\(calories)"
            QuestinonaireMsgModel.shared.caloriesNumber = "\(calories)"
            DispatchQueue.main.async {
                self.caloriesResultBaseVm.caloriesTextField.text = "\(calories)"
                completion?(true)
            }
        } failure: { _ in
            DispatchQueue.main.async {
                completion?(false)
            }
        }
    }

    func sendGuidanceNutritionGoalRequest() {
        guard let caloriesText = resolvedNutritionGoalRequestCaloriesText() else {
            DLLog(message: "sendGuidanceNutritionGoalRequest invalid calories before request. caloriesNumber=\(QuestinonaireMsgModel.shared.caloriesNumber), caloriesNumberFromServer=\(QuestinonaireMsgModel.shared.caloriesNumberFromServer)")
            presentNutritionGoalRequestErrorAlert()
            return
        }
//        let caloriesText = QuestinonaireMsgModel.shared.caloriesNumber
        let param = [
            "gender": "\(QuestinonaireMsgModel.shared.sex)",
            "birthday": "\(QuestinonaireMsgModel.shared.birthYear)",
            "weight": "\(QuestinonaireMsgModel.shared.weight)",
            "goal": "\(QuestinonaireMsgModel.shared.goal)",
            "dailyact": "\(QuestinonaireMsgModel.shared.events)",
            "bodyfat": "\(QuestinonaireMsgModel.shared.bodyFat)",
//            "calories": QuestinonaireMsgModel.shared.caloriesNumber == "" ? QuestinonaireMsgModel.shared.caloriesNumberFromServer : QuestinonaireMsgModel.shared.caloriesNumber
            "calories": caloriesText
//            "calories": QuestinonaireMsgModel.shared.caloriesNumber
        ]
        DLLog(message: "sendGuidanceNutritionGoalRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_question_survey_part_save, parameters: param as [String:AnyObject]) { [weak self] responseObject in
            guard let self = self else { return }
            let code = responseObject["code"]as? Int ?? -1
            if (code != 200) {
                self.presentNutritionGoalRequestErrorAlert()
                return
            }

            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let data = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendGuidanceNutritionGoalRequest:\(data)")

//            let carbohydrate = data["carbohydrate"] as? Int ?? Int(data.doubleValueForKey(key: "carbohydrate"))
//            let fat = data["fat"] as? Int ?? Int(data.doubleValueForKey(key: "fat"))
//            let protein = data["protein"] as? Int ?? Int(data.doubleValueForKey(key: "protein"))
//            let calories = data["calories"] as? Int ?? Int(data.doubleValueForKey(key: "calories"))
            guard let nutritionGoalPayload = self.parsedValidNutritionGoalPayload(from: data) else {
                DLLog(message: "sendGuidanceNutritionGoalRequest invalid payload:\(data)")
                self.presentNutritionGoalRequestErrorAlert()
                return
            }

            QuestinonaireMsgModel.shared.surveytype = "part"
            QuestinonaireMsgModel.shared.carbohydrates = "\(nutritionGoalPayload.carbohydrate)"
            QuestinonaireMsgModel.shared.protein = "\(nutritionGoalPayload.protein)"
            QuestinonaireMsgModel.shared.fats = "\(nutritionGoalPayload.fat)"
            QuestinonaireMsgModel.shared.calories = "\(nutritionGoalPayload.calories)"
            QuestinonaireMsgModel.shared.carbohydratesNumber = "\(nutritionGoalPayload.carbohydrate)"
            QuestinonaireMsgModel.shared.fatsNumber = "\(nutritionGoalPayload.fat)"
            QuestinonaireMsgModel.shared.proteinNumber = "\(nutritionGoalPayload.protein)"
            QuestinonaireMsgModel.shared.caloriesNumber = "\(nutritionGoalPayload.calories)"

            QuestinonaireMsgModel.shared.carbohydratesNumberFromServer = "\(nutritionGoalPayload.carbohydrate)"
            QuestinonaireMsgModel.shared.proteinNumberFromServer = "\(nutritionGoalPayload.protein)"
            QuestinonaireMsgModel.shared.fatsNumberFromServer = "\(nutritionGoalPayload.fat)"
            QuestinonaireMsgModel.shared.caloriesNumberFromServer = "\(nutritionGoalPayload.calories)"

            DispatchQueue.main.async {
                if self.isFixedTargetFlowEnabled {
//                    self.fixedTargetNutritionGoalVm.applyEditingMode(isEditable: true)
//                    self.fixedTargetNutritionGoalVm.refreshContentFromModel()
                } else {
                    self.nutritionGoalVm.refreshContentFromModel()
                }
                self.finishLoadingVm.completeLoading()
            }
        } failure: { [weak self] _ in
            self?.presentNutritionGoalRequestErrorAlert()
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
                    self.completeLoginSuccessAndEnterApp()
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

extension GuidanceVC: UIScrollViewDelegate {
    private var guidanceAlertViews: [UIView] {
        [
            loginAlertVm,
            notRegistVm,
            bodyFatAlertVm,
            katchAlertVm,
            sexTipsAlertVm,
            dietRecordTipsAlertVm,
            weightTipsAlertVm,
            takeoutTipsAlertVm,
            caloriesRecordTipsAlertVm,
            goalTipsAlertVm,
            fixGoalTipsAlertVm
        ]
    }

    private var isAnyGuidanceAlertVisible: Bool {
        guidanceAlertViews.contains { alertView in
            alertView.window != nil && !alertView.isHidden && alertView.alpha > 0.01
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === scrollViewBase else { return }
        guard !isAnyGuidanceAlertVisible else {
            scrollDragStartIndex = nil
            clearVirtualBackScrollLayout()
            return
        }
        guard let currentStep = flowStep(for: currentIndex), !isSummaryStep(currentStep) else {
            scrollDragStartIndex = nil
            clearVirtualBackScrollLayout()
            return
        }
        if currentStep == .nutritionGoal, isFixedTargetFlowEnabled {
            fixedTargetNutritionGoalVm.endEditing(true)
            view.endEditing(true)
        }
        didHideNextButtonForFixedNutritionBackSwipe = false
        isScrollBackInteractionInProgress = true
        scrollDragStartIndex = currentIndex
        installStepViewsIfNeeded(indexes: [previousNavigableIndex(from: currentIndex)])
        hideNextButtonForFixedNutritionBackSwipeIfNeeded(from: currentIndex)
        prepareVirtualBackScrollLayoutIfNeeded(from: currentIndex)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        syncCurrentStepWithScrollView(scrollView)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView === scrollViewBase else { return }
        let startIndex = scrollDragStartIndex ?? currentIndex
        guard let startStep = flowStep(for: startIndex), !isSummaryStep(startStep) else {
            targetContentOffset.pointee.x = SCREEN_WIDHT * CGFloat(max(startIndex, 0))
            return
        }
        let currentOffsetX = SCREEN_WIDHT * CGFloat(max(startIndex, 0))
        let previousDisplayIndex = virtualBackScrollDisplayIndex(for: startIndex) ?? previousNavigableIndex(from: startIndex)
        let previousOffsetX = SCREEN_WIDHT * CGFloat(previousDisplayIndex)
        let shouldReturnToPreviousStep = targetContentOffset.pointee.x < currentOffsetX - 0.5
        targetContentOffset.pointee.x = shouldReturnToPreviousStep ? previousOffsetX : currentOffsetX
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        syncCurrentStepWithScrollView(scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        syncCurrentStepWithScrollView(scrollView)
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

        if scrollView.contentOffset.x <= 0.5 || currentIndex == 0 {
            updateFullscreenPopGestureAvailability()
        }
    }

    private var isAtInitialScrollPage: Bool {
        currentIndex == 0 && scrollViewBase.contentOffset.x <= 0.5
    }

    private func isBackSwipe(_ panGesture: UIPanGestureRecognizer, in view: UIView) -> Bool {
        let translation = panGesture.translation(in: view)
        let velocity = panGesture.velocity(in: view)
        let isHorizontal = abs(translation.x) > abs(translation.y) || abs(velocity.x) > abs(velocity.y)
        guard isHorizontal else { return false }

        if UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == .rightToLeft {
            return velocity.x < 0 || translation.x < 0
        }
        return velocity.x > 0 || translation.x > 0
    }

    private func hideNextButtonForFixedNutritionBackSwipeIfNeeded(from startIndex: Int) {
        guard isFixedTargetFlowEnabled,
              let targetStep = flowStep(for: previousNavigableIndex(from: startIndex)),
              targetStep == .nutritionGoal else {
            return
        }
        didHideNextButtonForFixedNutritionBackSwipe = true
        nextButtonEnableWorkItem?.cancel()
        nextButtonEnableWorkItem = nil
        nextButton.isHidden = true
        nextButton.isEnabled = false
        nextButton.alpha = 1
    }

    private func allowedBackScrollOffsetRange(from startIndex: Int) -> (min: CGFloat, max: CGFloat) {
        let currentOffsetX = SCREEN_WIDHT * CGFloat(max(startIndex, 0))
        if let step = flowStep(for: startIndex), isSummaryStep(step) {
            return (min: currentOffsetX, max: currentOffsetX)
        }
        let previousDisplayIndex = virtualBackScrollDisplayIndex(for: startIndex) ?? previousNavigableIndex(from: startIndex)
        let previousOffsetX = SCREEN_WIDHT * CGFloat(previousDisplayIndex)
        return (min: previousOffsetX, max: currentOffsetX)
    }

    private func virtualBackScrollDisplayIndex(for startIndex: Int) -> Int? {
        guard virtualBackScrollSourceIndex == startIndex else { return nil }
        return virtualBackScrollDisplayIndex
    }

    private func prepareVirtualBackScrollLayoutIfNeeded(from startIndex: Int) {
        clearVirtualBackScrollLayout()
        let targetIndex = previousNavigableIndex(from: startIndex)
        let displayIndex = startIndex - 1
        guard targetIndex >= 0, targetIndex < displayIndex else { return }
        guard let targetStep = flowStep(for: targetIndex),
              let targetView = stepView(for: targetStep) else {
            return
        }

        targetView.isHidden = false
        targetView.frame = CGRect(x: SCREEN_WIDHT * CGFloat(displayIndex),
                                  y: 0,
                                  width: SCREEN_WIDHT,
                                  height: SCREEN_HEIGHT)
        for index in (targetIndex + 1)..<startIndex {
            guard let skippedStep = flowStep(for: index) else { continue }
            stepView(for: skippedStep)?.isHidden = true
        }

        virtualBackScrollSourceIndex = startIndex
        virtualBackScrollTargetIndex = targetIndex
        virtualBackScrollDisplayIndex = displayIndex
    }

    private func clearVirtualBackScrollLayout() {
        guard virtualBackScrollSourceIndex != nil else { return }
        virtualBackScrollSourceIndex = nil
        virtualBackScrollTargetIndex = nil
        virtualBackScrollDisplayIndex = nil
        layoutMountedStepViews()
        updateNutritionGoalViewVisibility()
    }

    private var shouldBlockScrollForProgressChartAnimation: Bool {
        flowStep(for: currentIndex) == .progressChart && !hasCompletedProgressChartAnimation
    }

    private var shouldBlockScrollForSummaryStep: Bool {
        guard let currentStep = flowStep(for: currentIndex) else { return false }
        return isSummaryStep(currentStep)
    }

    private func updateScrollViewBaseScrollAvailability() {
        scrollViewBase.isScrollEnabled = !isStepTransitioning &&
            !shouldBlockScrollForProgressChartAnimation &&
            !shouldBlockScrollForSummaryStep
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
        let resolvedIndex: Int
        let shouldResolveVirtualBackScroll = virtualBackScrollSourceIndex == scrollDragStartIndex &&
            visibleIndex < (virtualBackScrollSourceIndex ?? 0)
        if shouldResolveVirtualBackScroll, let targetIndex = virtualBackScrollTargetIndex {
            resolvedIndex = targetIndex
            clearVirtualBackScrollLayout()
            scrollView.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(targetIndex), y: 0), animated: false)
        } else if let startIndex = scrollDragStartIndex,
           startIndex > visibleIndex,
           let visibleStep = flowStep(for: visibleIndex),
           isSummaryStep(visibleStep) {
            resolvedIndex = previousNavigableIndex(from: startIndex)
            clearVirtualBackScrollLayout()
            scrollView.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(resolvedIndex), y: 0), animated: false)
        } else {
            resolvedIndex = visibleIndex
            clearVirtualBackScrollLayout()
        }

        if currentIndex != resolvedIndex {
            let isDraggingBack = (scrollDragStartIndex ?? currentIndex) > resolvedIndex
            currentIndex = resolvedIndex
            if let currentStep = flowStep(for: currentIndex) {
                let shouldCenterBodyfatSelection = !(isDraggingBack && currentStep == .bodyfat)
                refreshStepViewStateFromModel(
                    for: currentStep,
                    shouldCenterBodyfatSelection: shouldCenterBodyfatSelection
                )
                naviVm.updateStep(steps: stepsArray, currentStep: progressIndex(for: currentIndex))
                naviVm.isHidden = shouldHideNavigation(for: currentStep)
                updateNextButtonForCurrentStep()
            }
        } else if didHideNextButtonForFixedNutritionBackSwipe {
            updateNextButtonForCurrentStep()
        }
        didHideNextButtonForFixedNutritionBackSwipe = false

        isBackNavigationLocked = false
        isStepTransitioning = false
        isScrollBackInteractionInProgress = false
        updateScrollViewBaseScrollAvailability()
        scrollDragStartIndex = nil
        guard let currentStep = flowStep(for: currentIndex) else { return }
        refreshBackButtonState(for: currentStep, index: currentIndex)
        handleStepDidBecomeVisible(currentStep)
        updateFullscreenPopGestureAvailability()
    }

    private func updateFullscreenPopGestureAvailability() {
        guard isViewLoaded else { return }
        configureScrollPanFailureRequirementIfNeeded()
        let shouldAllowFullscreenPop = false
        guard !hasConfiguredFullscreenPopGesture
                || isFullscreenPopGestureEnabledForInitialStep != shouldAllowFullscreenPop
                || fullscreenPopGestureNavigationController !== navigationController else {
            return
        }

        updateInteractivePopGestureBlocked(!shouldAllowFullscreenPop)
        isFullscreenPopGestureEnabledForInitialStep = shouldAllowFullscreenPop
        fullscreenPopGestureNavigationController = navigationController
        hasConfiguredFullscreenPopGesture = true
    }

    private func configureScrollPanFailureRequirementIfNeeded() {
        guard fullscreenPopGestureFailureNavigationController !== navigationController,
              let navigationController = navigationController else {
            return
        }
        scrollViewBase.panGestureRecognizer.require(toFail: navigationController.fd_fullscreenPopGestureRecognizer)
        fullscreenPopGestureFailureNavigationController = navigationController
    }
}

extension GuidanceVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === backEdgePanGesture else { return true }
        guard !isAnyGuidanceAlertVisible else { return false }
        guard !isShowingFinishLoading, !isBackNavigationLocked, !isStepTransitioning else { return false }
        guard !isShowingStandaloneNutritionGoal else { return false }
        guard !isAtInitialScrollPage else { return false }
        guard let currentStep = flowStep(for: currentIndex),
              let panGesture = gestureRecognizer as? UIPanGestureRecognizer,
              let gestureView = panGesture.view else {
            return false
        }
        return !shouldDisableBackEdgePan(for: currentStep) && isBackSwipe(panGesture, in: gestureView)
    }
}
