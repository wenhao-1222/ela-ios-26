//
//  DietPlanCreateSecondVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/16.
//

import MCToast


class DietPlanCreateSecondVC: WHBaseViewVC {
    
    var currentIndex: Int = 0
    private var shouldShowSexStep = false
    private var isDateStepEnabled = false
    private var isShowingManualTargetEditor = false
    private var shouldPreserveManualTargetCalories = false
    private var hasRestoredDateRangeFromResponse = false
    private var isSubmittingFinalFlow = false
    private var isBackButtonCoolingDown = false
    private var isWaitingForVipPurchaseToCreatePlan = false
    private var shouldResumeCreatePlanOnAppear = false
    private var hasConfiguredFullscreenPopGesture = false
    private var isFullscreenPopGestureEnabledForInitialStep = false
    private weak var fullscreenPopGestureNavigationController: UINavigationController?
    private weak var fullscreenPopGestureFailureNavigationController: UINavigationController?
    private var scrollDragStartIndex: Int?
    private var isStepTransitioning = false
    private var isScrollBackInteractionInProgress = false
    private lazy var backEdgePanGesture: UIScreenEdgePanGestureRecognizer = {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleBackEdgePan(_:)))
        gesture.edges = .left
        gesture.delegate = self
        return gesture
    }()
    private var createPlanLoadingConfig = DietPlanFakeProgressLoadingVM.Config(
        fakeDuration: 9.0,
        maxProgressBeforeSuccess: 0.92,
        statusText: "创建食谱中..."
    )
    private lazy var requestDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFullscreenPopGestureAvailability()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateFullscreenPopGestureAvailability()
        resumeCreatePlanAfterVipPurchaseIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isScrollBackInteractionInProgress = false
        if let coordinator = transitionCoordinator, coordinator.isInteractive {
            coordinator.notifyWhenInteractionChanges { [weak self] context in
                if context.isCancelled {
                    self?.updateFullscreenPopGestureAvailability()
                } else {
                    self?.updateInteractivePopGestureBlocked(false)
                }
            }
            return
        }
        if navigationController?.topViewController !== self {
            updateInteractivePopGestureBlocked(false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFullscreenPopGestureAvailability()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleVipStatusRefreshForPendingCreatePlan),
                                               name: NOTIFI_NAME_REFRESH_DIET_PLAN_STATUS,
                                               object: nil)
        shouldShowSexStep = resolvedShouldShowSexStep()
        initUI()
        sendDietMsgRequest()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NOTIFI_NAME_REFRESH_DIET_PLAN_STATUS, object: nil)
    }
    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
        vm.backTapBlock = {[weak self] in
            self?.navigateBackOneStep()
        }
        return vm
    }()
    var stepsArray: [Int] {
        return shouldShowSexStep ? [5,3,4] : [4,3,4]
    }
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
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)

        return btn
    }()
    lazy var dateVm: DietPlanCreateDateVM = {
        let vm = DietPlanCreateDateVM.init(frame: .zero)
        vm.nextButtonEnableChangeBlock = { [weak self] isEnabled in
            self?.isDateStepEnabled = isEnabled
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var sexVm: DietPlanCreateSexVM = {
        let vm = DietPlanCreateSexVM(frame: CGRect(x: SCREEN_WIDHT, y: 0, width: 0, height: 0))
        vm.sexManButton.removeTarget(vm, action: #selector(DietPlanCreateSexVM.manTapAction), for: .touchUpInside)
        vm.sexFeManButton.removeTarget(vm, action: #selector(DietPlanCreateSexVM.femanTapAction), for: .touchUpInside)
        vm.sexManButton.addTarget(self, action: #selector(handleSecretSexManTap), for: .touchUpInside)
        vm.sexFeManButton.addTarget(self, action: #selector(handleSecretSexWomanTap), for: .touchUpInside)
        
        vm.showTipsBlock = {()in
            self.sexTipsAlertVm.showView()
        }
        return vm
    }()
    lazy var weightVm: DietPlanCreateWeightVM = {
        let vm = DietPlanCreateWeightVM.init(frame: CGRect.init(x: SCREEN_WIDHT * CGFloat(visibleStepIndex(forBaseIndex: 1)), y: 0, width: 0, height: 0))
        vm.titleLabel.text = "你的最新体重是？"
        vm.weightChangedBlock = { [weak self] weight in
            self?.targetWeightVm.syncWithCurrentWeight(weight, syncTarget: false)
        }
        vm.showTipsBlock = {()in
            self.weightTipsAlertVm.showView()
        }
        return vm
    }()
    lazy var targetWeightVm: DietPlanCreateTargetWeightVM = {
        let vm = DietPlanCreateTargetWeightVM(frame: CGRect(x: SCREEN_WIDHT * CGFloat(visibleStepIndex(forBaseIndex: 2)), y: 0, width: 0, height: 0))
        vm.titleLabel.text = "你的目标体重需要改变吗？"
        return vm
    }()
    lazy var bodyfatVm: DietPlanCreateBodyfatVM = {
        let vm = DietPlanCreateBodyfatVM.init(frame: CGRect(x: SCREEN_WIDHT * CGFloat(visibleStepIndex(forBaseIndex: 3)), y: 0, width: 0, height: 0))
        vm.selectStateChangeBlock = {[weak self] _ in
            self?.syncNextButtonEnableStatus()
        }
        
        vm.showTipsBlock = {()in
            self.bodyFatAlertVm.showView()
        }
        return vm
    }()
    lazy var eventsVm: DietPlanCreateEventsVM = {
        let vm = DietPlanCreateEventsVM.init(frame: CGRect(x: SCREEN_WIDHT * CGFloat(visibleStepIndex(forBaseIndex: 4)), y: 0, width: 0, height: 0))
        vm.titleLabel.text = "你的每日活动量有变动吗？"
        vm.selectedBlock = {[weak self] in
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var paceVm: DietPlanCreatePaceSecondVM = {
        let vm = DietPlanCreatePaceSecondVM(frame: CGRect(x: SCREEN_WIDHT * CGFloat(visibleStepIndex(forBaseIndex: 5)), y: 0, width: 0, height: 0))
//        vm.titleLabel.text = "你的增肌节奏需要改变吗？"
        vm.selectedBlock = { [weak self] in
            self?.refreshRecommendIntakeForCurrentSelections()
        }
        return vm
    }()
    lazy var recommendIntakeVm: DietPlanCreateRecommendIntakeVM = {
        let vm = DietPlanCreateRecommendIntakeVM(frame: CGRect(x: SCREEN_WIDHT * CGFloat(visibleStepIndex(forBaseIndex: 6)), y: 0, width: 0, height: 0))
        vm.editTargetBlock = { [weak self] in
            self?.showManualTargetEditor()
        }
        return vm
    }()
    lazy var eatStyleVm: DietPlanCreateEatStyleSecondVM = {
        let vm = DietPlanCreateEatStyleSecondVM(frame: CGRect(x: SCREEN_WIDHT * CGFloat(visibleStepIndex(forBaseIndex: 7)), y: 0, width: 0, height: 0))
        vm.selectedBlock = { [weak self] in
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
//    lazy var flavorVM: DietPlanCreateFlavorVM = {
//        let vm = DietPlanCreateFlavorVM(frame: CGRect(x: SCREEN_WIDHT * 7, y: 0, width: 0, height: 0))
//        vm.selectedBlock = {[weak self] in
//            self?.syncNextButtonEnableStatus()
//        }
//        return vm
//    }()
    lazy var allergyVm: DietPlanCreateAllergyVM = {
        let vm = DietPlanCreateAllergyVM(frame: CGRect(x: SCREEN_WIDHT * CGFloat(visibleStepIndex(forBaseIndex: 8)), y: 0, width: 0, height: 0))
        vm.selectedBlock = {[weak self] in
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var specialAdjustmentVm: DietPlanCreateSpecialAdjustmentVM = {
        let vm = DietPlanCreateSpecialAdjustmentVM(frame: CGRect(x: SCREEN_WIDHT * CGFloat(visibleStepIndex(forBaseIndex: 9)), y: 0, width: 0, height: 0))
        vm.selectedBlock = { [weak self] in
            self?.allergyVm.enforceHighUricSelectionsIfNeeded()
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var mealModeVm: DietPlanCreateMealModeSecondVM = {
        let vm = DietPlanCreateMealModeSecondVM(frame: CGRect(x: SCREEN_WIDHT * CGFloat(visibleStepIndex(forBaseIndex: 10)), y: 0, width: 0, height: 0))
        vm.selectedBlock = { [weak self] in
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var manualTargetVm: DietPlanCreateManualTargetVM = {
        let vm = DietPlanCreateManualTargetVM(frame: CGRect(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vm.backTapBlock = { [weak self] in
            self?.hideManualTargetEditor(isBack: true)
        }
        vm.saveTapBlock = { [weak self] value in
            self?.saveManualTarget(value)
        }
        return vm
    }()
    private lazy var createPlanLoadingVm: DietPlanFakeProgressLoadingVM = {
        let vm = DietPlanFakeProgressLoadingVM(frame: .zero)
        vm.updateConfig(createPlanLoadingConfig)
        return vm
    }()
    lazy var weightTipsAlertVm: DietPlanCreateWeightAlertVM = {
        let vm = DietPlanCreateWeightAlertVM.init(frame: .zero)
        
        return vm
    }()
    lazy var manualTargetLimitAlertVm: DietPlanManualTargetLimitAlertVM = {
        let vm = DietPlanManualTargetLimitAlertVM(frame: .zero)
        return vm
    }()
    lazy var sexTipsAlertVm: GuidanceSexTipsAlertVM = {
        let vm = GuidanceSexTipsAlertVM(frame: .zero)
        return vm
    }()
    lazy var bodyFatAlertVm : QuestionnaireBodyFatAlertVM = {
        let vm = QuestionnaireBodyFatAlertVM.init(frame: .zero)
        
        return vm
    }()
}

extension DietPlanCreateSecondVC{
    @objc func handleBackEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard gesture.state == .recognized else { return }
        navigateBackOneStep()
    }

    func navigateBackOneStep() {
        guard !isBackButtonCoolingDown, !isStepTransitioning, !isScrollBackInteractionInProgress else { return }
        if isShowingManualTargetEditor {
            hideManualTargetEditor(isBack: true)
            return
        }
        guard !isSubmittingFinalFlow else { return }
        startBackButtonCooldown()
        if currentIndex == 0 {
            backTapAction()
            return
        }
        currentIndex = previousStepIndex(from: currentIndex)
        let targetOffsetX = SCREEN_WIDHT * CGFloat(currentIndex)
        prepareStepTransition(to: targetOffsetX, animated: true)
        scrollViewBase.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
        updateNextButtonForCurrentStep(animated: false)
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

    @objc func handleSecretSexManTap() {
        applySecretSexSelection(gender: "1")
    }

    @objc func handleSecretSexWomanTap() {
        applySecretSexSelection(gender: "2")
    }

    @objc func nextButtonTapAction() {
        guard !isStepTransitioning, !isScrollBackInteractionInProgress else { return }
        goToNextStep()
    }

    func goToNextStep() {
        let maxOffsetX = max(scrollViewBase.contentSize.width - scrollViewBase.bounds.width, 0)
        let isAtLastStep = scrollViewBase.contentOffset.x >= (maxOffsetX - 0.5)
        if isAtLastStep {
            submitFinalFlow()
            return
        }

        if currentIndex == visibleStepIndex(forBaseIndex: 6) {
            syncCaloriesNumberForRecommendStepIfNeeded()
            
        }
        let nextIndex = nextStepIndex(from: currentIndex)
        if currentIndex == visibleStepIndex(forBaseIndex: 4) {
            sendBasicRequest()
        }
        if currentIndex == visibleStepIndex(forBaseIndex: 7){
            mealModeVm.refreshOptions(caloriesText: QuestinonaireMsgModel.shared.caloriesNumber)
        }
        let targetOffsetX = SCREEN_WIDHT * CGFloat(nextIndex)
        let finalOffsetX = min(targetOffsetX, maxOffsetX)
        currentIndex = Int(round(finalOffsetX / SCREEN_WIDHT))
        prepareStepTransition(to: finalOffsetX, animated: true)
        scrollViewBase.setContentOffset(CGPoint(x: finalOffsetX, y: 0), animated: true)
        updateNextButtonForCurrentStep(animated: false)
    }

    func updateNextButtonForCurrentStep(animated: Bool) {
        let shouldHideButton = false
        let moveY = kFitWidth(90) + WHUtils().getBottomSafeAreaHeight()
        let targetTransform = shouldHideButton ? CGAffineTransform(translationX: 0, y: moveY) : .identity
        let targetAlpha: CGFloat = shouldHideButton ? 0 : 1
        let applyChange = {
            self.nextButton.transform = targetTransform
            self.nextButton.alpha = targetAlpha
        }
        nextButton.isUserInteractionEnabled = !shouldHideButton
        naviVm.updateStep(steps: self.stepsArray, currentStep: currentIndex)

        if animated {
            UIView.animate(withDuration: 0.25) {
                applyChange()
            }
        } else {
            applyChange()
        }
        syncNextButtonEnableStatus()
    }

    func syncNextButtonEnableStatus() {
        if isSubmittingFinalFlow {
            nextButton.isEnabled = false
            return
        }
        let sexIndex = shouldShowSexStep ? 1 : -1
        let bodyfatIndex = visibleStepIndex(forBaseIndex: 3)
        let eatStyleIndex = visibleStepIndex(forBaseIndex: 7)
        let allergyIndex = visibleStepIndex(forBaseIndex: 8)
        let adjustmentIndex = visibleStepIndex(forBaseIndex: 9)
        let mealModeIndex = visibleStepIndex(forBaseIndex: 10)

        switch currentIndex {
        case 0:
            nextButton.isEnabled = isDateStepEnabled
        case let idx where idx == sexIndex:
            nextButton.isEnabled = !QuestinonaireMsgModel.shared.sex.isEmpty
        case let idx where idx == bodyfatIndex:
            nextButton.isEnabled = bodyfatVm.selectIndex >= 0
        case let idx where idx == eatStyleIndex:
            nextButton.isEnabled = eatStyleVm.selectedIndex >= 0
        case let idx where idx == allergyIndex:
            nextButton.isEnabled = allergyVm.selectedIndex >= 0
        case let idx where idx == adjustmentIndex:
            nextButton.isEnabled = specialAdjustmentVm.hasSelection
        case let idx where idx == mealModeIndex:
            nextButton.isEnabled = mealModeVm.selectedIndex >= 0
        default:
            nextButton.isEnabled = true
        }
    }

    func nextStepIndex(from index: Int) -> Int {
        return index + 1
    }
    
    func previousStepIndex(from index: Int) -> Int {
        return index - 1
    }

    func showManualTargetEditor() {
        let initialValue = QuestinonaireMsgModel.shared.caloriesNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        manualTargetVm.configure(initialValue: initialValue)
        manualTargetVm.isHidden = false
        view.bringSubviewToFront(manualTargetVm)
        isShowingManualTargetEditor = true
        
        UIView.animate(withDuration: 0.25, animations: {
            self.manualTargetVm.frame.origin.x = 0
            self.nextButtonTapAction()
        }, completion: { _ in
            self.manualTargetVm.focusInput()
            
        })
    }

    func hideManualTargetEditor(isBack:Bool) {
        manualTargetVm.resignInput()
        isShowingManualTargetEditor = false
        if isBack{
//            self.currentIndex = self.previousStepIndex(from: self.currentIndex)
//            let targetOffsetX = SCREEN_WIDHT * CGFloat(self.currentIndex)
//            self.scrollViewBase.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
//            self.updateNextButtonForCurrentStep(animated: true)
        }else{
            self.nextButtonTapAction()
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.manualTargetVm.frame.origin.x = isBack ? SCREEN_WIDHT : -SCREEN_WIDHT
            if isBack{
                self.currentIndex = self.previousStepIndex(from: self.currentIndex)
                let targetOffsetX = SCREEN_WIDHT * CGFloat(self.currentIndex)
                self.prepareStepTransition(to: targetOffsetX, animated: true)
                self.scrollViewBase.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
                self.updateNextButtonForCurrentStep(animated: false)
            }
        }, completion: { _ in
            self.manualTargetVm.frame.origin.x = SCREEN_WIDHT
        })
    }

    func saveManualTarget(_ value: String) {
        if let alertType = manualTargetAlertType(for: value) {
            manualTargetLimitAlertVm.update(type: alertType)
            view.bringSubviewToFront(manualTargetLimitAlertVm)
            manualTargetLimitAlertVm.showSelf()
            return
        }

        self.currentIndex = self.previousStepIndex(from: self.currentIndex)
        let targetOffsetX = SCREEN_WIDHT * CGFloat(self.currentIndex)
        self.scrollViewBase.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: false)
        self.updateNextButtonForCurrentStep(animated: false)
        self.updateFullscreenPopGestureAvailability()
        QuestinonaireMsgModel.shared.caloriesNumber = value
        shouldPreserveManualTargetCalories = true
        mealModeVm.refreshOptions(caloriesText: value)
        if !QuestinonaireMsgModel.shared.mealsPerDay.isEmpty {
            mealModeVm.restoreSelection(modelValue: QuestinonaireMsgModel.shared.mealsPerDay)
        }
        hideManualTargetEditor(isBack: false)
    }

    func manualTargetAlertType(for value: String) -> ManualTargetLimitAlertType? {
        guard let calories = Int(value) else {
            return nil
        }

        if calories > 5000 {
            return .tooHigh
        }

        let gender = resolvedDietTargetGender()
        if calories < gender.minimumCalories {
            return .tooLow(gender: gender, minimumCalories: gender.minimumCalories)
        }

        return nil
    }

    func resolvedDietTargetGender() -> DietTargetGender {
        let questionnaireGender = normalizedGenderValue(QuestinonaireMsgModel.shared.sex)
        if questionnaireGender == "1" {
            return .male
        }
        if questionnaireGender == "2" {
            return .female
        }

        let profileGender = normalizedProfileGender()
        if profileGender == "1" {
            return .male
        }
        if profileGender == "2" {
            return .female
        }

        return .unknown
    }

    func resolvedShouldShowSexStep() -> Bool {
        let profileGender = normalizedProfileGender()
        let questionnaireGender = normalizedGenderValue(QuestinonaireMsgModel.shared.sex)
        return profileGender != "" && profileGender != questionnaireGender
    }

    func updateShouldShowSexStepIfNeeded(_ shouldShow: Bool) {
        guard shouldShowSexStep != shouldShow else {
            return
        }
        shouldShowSexStep = shouldShow
        guard isViewLoaded else {
            return
        }
        refreshVisibleStepLayout()
    }

    func refreshVisibleStepLayout() {
        updateStepFrame(dateVm, index: 0)
        updateStepFrame(sexVm, index: 1)
        updateStepFrame(weightVm, index: visibleStepIndex(forBaseIndex: 1))
        updateStepFrame(targetWeightVm, index: visibleStepIndex(forBaseIndex: 2))
        updateStepFrame(bodyfatVm, index: visibleStepIndex(forBaseIndex: 3))
        updateStepFrame(eventsVm, index: visibleStepIndex(forBaseIndex: 4))
        updateStepFrame(paceVm, index: visibleStepIndex(forBaseIndex: 5))
        updateStepFrame(recommendIntakeVm, index: visibleStepIndex(forBaseIndex: 6))
        updateStepFrame(eatStyleVm, index: visibleStepIndex(forBaseIndex: 7))
        updateStepFrame(allergyVm, index: visibleStepIndex(forBaseIndex: 8))
        updateStepFrame(specialAdjustmentVm, index: visibleStepIndex(forBaseIndex: 9))
        updateStepFrame(mealModeVm, index: visibleStepIndex(forBaseIndex: 10))

        sexVm.isHidden = !shouldShowSexStep
        scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT * CGFloat(totalVisibleStepCount), height: 0)

        let maxIndex = max(totalVisibleStepCount - 1, 0)
        currentIndex = min(currentIndex, maxIndex)

        let maxOffsetX = max(scrollViewBase.contentSize.width - scrollViewBase.bounds.width, 0)
        let targetOffsetX = min(SCREEN_WIDHT * CGFloat(currentIndex), maxOffsetX)
        scrollViewBase.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: false)
        updateNextButtonForCurrentStep(animated: false)
        updateFullscreenPopGestureAvailability()
    }

    func updateStepFrame(_ stepView: UIView, index: Int) {
        stepView.frame.origin.x = SCREEN_WIDHT * CGFloat(index)
    }
}

extension DietPlanCreateSecondVC{
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(scrollViewBase)
        view.addSubview(naviVm)
        view.addSubview(nextButton)
        view.addSubview(manualTargetVm)
        view.addSubview(weightTipsAlertVm)
        view.addSubview(manualTargetLimitAlertVm)
        view.addSubview(bodyFatAlertVm)
        view.addSubview(sexTipsAlertVm)
        
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.isScrollEnabled = true
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.bounces = false
        scrollViewBase.delegate = self
        view.addGestureRecognizer(backEdgePanGesture)
        
        scrollViewBase.addSubview(dateVm)
        scrollViewBase.addSubview(sexVm)
        scrollViewBase.addSubview(weightVm)
        scrollViewBase.addSubview(targetWeightVm)
        scrollViewBase.addSubview(bodyfatVm)
        scrollViewBase.addSubview(eventsVm)
        scrollViewBase.addSubview(paceVm)
        scrollViewBase.addSubview(recommendIntakeVm)
        scrollViewBase.addSubview(eatStyleVm)
        scrollViewBase.addSubview(allergyVm)
        scrollViewBase.addSubview(specialAdjustmentVm)
        scrollViewBase.addSubview(mealModeVm)
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }

        refreshVisibleStepLayout()
    }
}

//MARK: 网络请求
extension DietPlanCreateSecondVC{
    func sendDietMsgRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_get, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendDietMsgRequest:\(dataObj)")

            guard let dict = dataObj as? NSDictionary else {
                return
            }

            DispatchQueue.main.async {
                self.applyDietQuestionnaireData(dict)
//                if QuestinonaireMsgModel.shared.targetWeight.floatValue == QuestinonaireMsgModel.shared.weight.floatValue{
//                    //TODO: 这里需要隐藏 paceVm
//                }else if QuestinonaireMsgModel.shared.targetWeight.floatValue > QuestinonaireMsgModel.shared.weight.floatValue{
//                    self.paceVm.titleLabel.text = "你的增肌节奏需要改变吗？"
//                }else{
//                    self.paceVm.titleLabel.text = "你的减脂节奏需要改变吗？"
//                }
            }
        }
    }

    func submitFinalFlow() {
        guard !isSubmittingFinalFlow else {
            return
        }

//        syncCaloriesNumberForRecommendStepIfNeeded()
        isSubmittingFinalFlow = true
        syncNextButtonEnableStatus()
        createPlanLoadingVm.updateConfig(createPlanLoadingConfig)
        createPlanLoadingVm.start(on: view)
        enableInteractivePopGesture()
        updateFullscreenPopGestureAvailability()

        let param = buildDietUpsertParameters()
        DLLog(message: "sendDietUpsertRequest(second):\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_upsert, parameters: param as [String : AnyObject]) { [weak self] responseObject in
            guard let self = self else { return }
            let code = responseObject["code"] as? Int ?? -1
            guard code == 200 else {
                let msg = responseObject["message"] as? String ?? "保存失败，请稍后重试"
                self.handleFinalFlowFailure(message: msg)
                return
            }
            self.createPlanAfterUpsertIfVipValid()
        } failure: { [weak self] isError in
            guard let self = self else { return }
            self.handleFinalFlowFailure(message: isError ? "保存失败，请稍后重试" : nil)
        }
    }
    
    func sendBasicRequest() {
        let param = ["gender":"\(QuestinonaireMsgModel.shared.sex)",
                     "dailyact":"\(QuestinonaireMsgModel.shared.events)",
                     "bodyfat":"\(QuestinonaireMsgModel.shared.bodyFat)",
                     "weight":"\(QuestinonaireMsgModel.shared.weight)"]
        DLLog(message: "sendBasicRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_question_basic_consumption, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            var dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
//            dataString = "3200"
            DLLog(message: "sendBasicRequest:\(dataString ?? "")")
            let caloriesText = (dataString ?? "0").trimmingCharacters(in: .whitespacesAndNewlines)
            QuestinonaireMsgModel.shared.caloriesNumberFromServer = caloriesText

            DispatchQueue.main.async {
                self.updateRecommendIntake(withBaseCaloriesText: caloriesText)
            }
        }
    }

    func createPlanAfterUpsertIfVipValid() {
        guard VIPModel.shared.status == .valid else {
            handleFinalFlowVipUpgradeRequired()
            return
        }
        sendCreatePlanRequestAfterUpsert()
    }

    func sendCreatePlanRequestAfterUpsert() {
        let param = [
            "startDate": requestDateFormatter.string(from: QuestinonaireMsgModel.shared.chartStartDate),
            "endDate": requestDateFormatter.string(from: QuestinonaireMsgModel.shared.chartEndDate),
            "customTdee":QuestinonaireMsgModel.shared.caloriesNumber
        ]
        DLLog(message: "sendCreatePlanRequest(second):\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_create, parameters: param as [String : AnyObject]) { [weak self] responseObject in
            guard let self = self else { return }
            let code = responseObject["code"] as? Int ?? -1
            guard code == 200 else {
                if code == 403 {
                    self.handleFinalFlowVipUpgradeRequired()
                } else {
                    let msg = responseObject["message"] as? String ?? "创建失败，请稍后重试"
                    self.handleFinalFlowFailure(message: msg)
                }
                return
            }

            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendDietPlanMsgRequest(second):\(dataObj)")
            _ = LogsSQLiteManager.getInstance().applyDietPlanNutrientsTargets(dataObj["nutrientsTarget"] as? NSArray ?? [])
            self.refreshUserCenterAndLogsAfterDietPlanCreate()

            self.createPlanLoadingVm.completeSuccess { [weak self] in
                guard let self = self else { return }
                self.isSubmittingFinalFlow = false
                self.navigationController?.tabBarController?.selectedIndex = 2
                self.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: NOTIFI_NAME_DIET_PLAN_CREATE_SUCCESS, object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dietPlan"), object: nil)
            }
        } failure: { [weak self] isError in
            guard let self = self else { return }
            self.handleFinalFlowFailure(message: isError ? "创建失败，请稍后重试" : nil)
        }
    }
}

extension DietPlanCreateSecondVC {
    func refreshRecommendIntakeForCurrentSelections() {
        let baseCaloriesText = QuestinonaireMsgModel.shared.caloriesNumberFromServer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !baseCaloriesText.isEmpty else {
            recommendIntakeVm.refreshContent()
            return
        }
        updateRecommendIntake(withBaseCaloriesText: baseCaloriesText)
    }

    func updateRecommendIntake(withBaseCaloriesText baseCaloriesText: String) {
        let adjustedCaloriesText = adjustedRecommendCaloriesText(from: baseCaloriesText)
        recommendIntakeVm.updateCalories(adjustedCaloriesText)
        mealModeVm.refreshOptions(caloriesText: adjustedCaloriesText)
        if !QuestinonaireMsgModel.shared.mealsPerDay.isEmpty {
            mealModeVm.restoreSelection(modelValue: QuestinonaireMsgModel.shared.mealsPerDay)
        }
    }

    func adjustedRecommendCaloriesText(from baseCaloriesText: String) -> String {
        let trimmedCalories = baseCaloriesText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let baseCalories = Int(trimmedCalories),
              let currentWeight = Double(QuestinonaireMsgModel.shared.weight.trimmingCharacters(in: .whitespacesAndNewlines)),
              let targetWeight = Double(QuestinonaireMsgModel.shared.targetWeight.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return trimmedCalories
        }

        if currentWeight == targetWeight {
            return "\(baseCalories)"
        }

        let offset: Int
        switch QuestinonaireMsgModel.shared.paceLevel.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "1", "slight":
            offset = 275
        case "3", "major":
            offset = 770
        default:
            offset = 495
        }

        let minCalories = QuestinonaireMsgModel.shared.sex == "1" ? 1500 : 1200
        if currentWeight > targetWeight {
            if baseCalories - offset > minCalories{
                self.recommendIntakeVm.refreshDesc(isShow: true)
                return "\(baseCalories - offset)"
            }else if baseCalories - offset >= 5000 {
                self.recommendIntakeVm.refreshDesc(isShow: false)
                return "5000"
            }else{
                self.recommendIntakeVm.refreshDesc(isShow: false)
                return "\(minCalories)"
            }
        }
        
        if baseCalories + offset > 5000{
            self.recommendIntakeVm.refreshDesc(isShow: false)
            return "5000"
        }else{
            self.recommendIntakeVm.refreshDesc(isShow: true)
            return "\(baseCalories + offset)"
        }
    }

    func applyDietQuestionnaireData(_ data: NSDictionary) {
        let model = QuestinonaireMsgModel.shared
        model.sex = normalizedGenderValue(stringValue(from: data["gender"]))
        model.birthDay = birthYear(from: data["birthday"])
        model.goal = mapUserGoals(from: intArrayValue(from: data["userGoal"]))
        model.height = stringValue(from: data["height"])
        model.weight = formattedWeightString(from: data["currentWeight"])
        model.targetWeight = formattedWeightString(from: data["targetWeight"])
        model.bodyFat = stringValue(from: data["bodyFat"])
        model.events = stringValue(from: data["dailyActivityLevel"])
        model.paceLevel = normalizedPaceLevel(from: data["goalTimeline"])
        model.foodAllergy = mapFoodRestrictions(from: intArrayValue(from: data["foodRestrictions"]))
        model.foodBarrier = mapDietBarriers(from: intArrayValue(from: data["dietBarriers"]))
        model.foodTasteType = mapFlavorPreferences(from: multiValueArray(from: data["flavorPreferences"]))
        model.dietHistoryType = localDietHistoryValue(from: data["dietMethodExperience"])
        model.mealsPerDay = stringValue(from: data["dailyMeals"])
        model.goalImportance = stringValue(from: data["goalImportance"])
        model.dietType = stringValue(from: data["dietType"])
        model.specialAdjustmentType = mapDietAdjustmentTypes(from: intArrayValue(from: data["dietAdjustmentType"]))
        hasRestoredDateRangeFromResponse = false
        if let startDate = dateValue(from: data["startDate"]),
           let endDate = dateValue(from: data["endDate"]) {
            model.chartStartDate = startDate
            model.chartEndDate = endDate
            hasRestoredDateRangeFromResponse = true
        }

        updateShouldShowSexStepIfNeeded(resolvedShouldShowSexStep())
        applyRestoredQuestionnaireDataToCurrentSteps()
        model.printModelMsg()
    }

    func applyRestoredQuestionnaireDataToCurrentSteps() {
        let restoredFoodAllergy = QuestinonaireMsgModel.shared.foodAllergy

        if shouldShowSexStep {
            updateSecretSexSelectionUI()
        }

        if hasRestoredDateRangeFromResponse {
            dateVm.restoreDateRange(start: QuestinonaireMsgModel.shared.chartStartDate,
                                    end: QuestinonaireMsgModel.shared.chartEndDate)
        }

        if let weightValue = parsedWeight(from: QuestinonaireMsgModel.shared.weight) {
            let tenths = Int((weightValue * 10).rounded())
            let integer = tenths / 10
            let decimal = abs(tenths % 10)
            weightVm.applyDefaultWeight(integer: integer, decimal: decimal)
        }

        targetWeightVm.applyInitialValue()

        let restoredBodyFat = QuestinonaireMsgModel.shared.bodyFat
        bodyfatVm.updateScrollView()
        if !restoredBodyFat.isEmpty {
            bodyfatVm.restoreSelection(modelValue: restoredBodyFat)
        }

        if let eventsValue = Int(QuestinonaireMsgModel.shared.events),
           eventsValue > 0,
           eventsValue <= eventsVm.dataArray.count {
            eventsVm.selectedIndex = eventsValue - 1
            eventsVm.tableView.reloadData()
        }

        if !QuestinonaireMsgModel.shared.paceLevel.isEmpty {
            paceVm.restoreSelection(modelValue: QuestinonaireMsgModel.shared.paceLevel)
        }

        recommendIntakeVm.refreshContent()
        mealModeVm.refreshOptions(caloriesText: QuestinonaireMsgModel.shared.caloriesNumber)
        allergyVm.applyGoalFilter()
        if !restoredFoodAllergy.isEmpty {
            allergyVm.restoreSelection(modelValue: restoredFoodAllergy)
        } else {
            allergyVm.restoreSelection(modelValue: "无")
        }
        if !QuestinonaireMsgModel.shared.specialAdjustmentType.isEmpty {
            specialAdjustmentVm.restoreSelection(modelValue: QuestinonaireMsgModel.shared.specialAdjustmentType)
        } else {
            specialAdjustmentVm.restoreSelection(modelValue: "3")
        }
        allergyVm.enforceHighUricSelectionsIfNeeded()
        if !QuestinonaireMsgModel.shared.dietType.isEmpty {
            eatStyleVm.restoreSelection(modelValue: QuestinonaireMsgModel.shared.dietType)
        }
        if !QuestinonaireMsgModel.shared.mealsPerDay.isEmpty {
            mealModeVm.restoreSelection(modelValue: QuestinonaireMsgModel.shared.mealsPerDay)
        }
        
        syncNextButtonEnableStatus()
    }

    func stringValue(from value: Any?) -> String {
        if let string = value as? String {
            return string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let number = value as? NSNumber {
            return number.stringValue
        }
        return ""
    }

    func numberValue(from text: String) -> NSNumber? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else {
            return nil
        }
        if let intValue = Int(normalized) {
            return NSNumber(value: intValue)
        }
        if let doubleValue = Double(normalized) {
            return NSNumber(value: doubleValue)
        }
        return nil
    }

    func dateValue(from value: Any?) -> Date? {
        let text = stringValue(from: value)
        guard !text.isEmpty else {
            return nil
        }

        let formatters: [DateFormatter] = {
            let formats = ["yyyy-MM-dd", "yyyy.MM.dd", "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ss"]
            return formats.map { format in
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.calendar = Calendar(identifier: .gregorian)
                formatter.locale = Locale(identifier: "en_US_POSIX")
                return formatter
            }
        }()

        for formatter in formatters {
            if let date = formatter.date(from: text) {
                return Calendar(identifier: .gregorian).startOfDay(for: date)
            }
        }
        return nil
    }

    func syncCaloriesNumberForRecommendStepIfNeeded() {
        defer {
            shouldPreserveManualTargetCalories = false
        }

        guard !shouldPreserveManualTargetCalories else {
            return
        }

        let caloriesText = recommendIntakeVm.caloriesLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !caloriesText.isEmpty, caloriesText != "--" else {
            return
        }
        QuestinonaireMsgModel.shared.caloriesNumber = caloriesText
    }

    func buildDietUpsertParameters() -> [String: Any] {
        let model = QuestinonaireMsgModel.shared
        var param: [String: Any] = [
            "userGoal": buildAdjustedUserGoalsForRequest(goalText: model.goal,
                                                        targetWeightText: model.targetWeight,
                                                        currentWeightText: model.weight),
            "birthday": model.birthDay,
            "gender": model.sex,
            "currentWeight": model.weight,
            "targetWeight": model.targetWeight,
            "height": model.height,
            "bodyFat": model.bodyFat,
            "dailyActivityLevel": model.events,
            "goalImportance": model.goalImportance,
            "goalTimeline": model.paceLevel,
            "foodRestrictions": allergyVm.buildFoodRestrictions(),
            "dietBarriers": buildDietBarriersForRequest(from: model.foodBarrier),
            "dailyMeals": model.mealsPerDay,
            "dietType": Int(model.dietType) ?? 0,
            "dietMethodExperience": buildDietMethodExperienceForRequest(from: model.dietHistoryType),
            "flavorPreferences": buildFlavorPreferencesValue(from: model.foodTasteType),
            "dietAdjustmentType": buildDietAdjustmentTypesForRequest(from: model.specialAdjustmentType)
        ]
        param["tdee"] = numberValue(from: model.caloriesNumber) ?? NSNull()
        return param
    }

    func buildAdjustedUserGoalsForRequest(goalText: String,
                                          targetWeightText: String,
                                          currentWeightText: String) -> [Int] {
        let userGoals = buildUserGoalsForRequest(from: goalText)
        guard let targetWeight = Double(targetWeightText.trimmingCharacters(in: .whitespacesAndNewlines)),
              let currentWeight = Double(currentWeightText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return userGoals
        }

        if targetWeight > currentWeight {
            return userGoals.map { $0 == 1 ? 2 : $0 }
        }

        if targetWeight < currentWeight {
            return userGoals.map { $0 == 2 ? 1 : $0 }
        }

        return userGoals
    }

    func buildUserGoalsForRequest(from text: String) -> [Int] {
        let mapping: [String: Int] = [
            "减脂": 1,
            "增肌": 2,
            "保持体型": 3,
            "提升力量": 4,
            "提高运动表现": 5,
            "提升整体健康": 6,
            "改善血脂": 7,
            "降低尿酸": 8,
            "养成规律饮食习惯": 9,
            "节省时间": 10,
            "节省外食开销": 11
        ]
        return splitCSVText(text).compactMap { mapping[$0] }
    }

    func buildDietBarriersForRequest(from text: String) -> [Int] {
        let mapping: [String: Int] = [
            "不确定": 1,
            "容易嘴馋": 2,
            "做饭太麻烦": 3,
            "健身餐不好吃": 4,
            "无法平衡家庭餐和健身餐": 5,
            "不知道吃什么": 6
        ]
        return Array(Set(splitCSVText(text).compactMap { mapping[$0] })).sorted()
    }

    func buildFlavorPreferencesValue(from text: String) -> Int {
        let mapping: [String: Int] = [
            "不确定": 1,
            "清爽": 2,
            "咸香": 3,
            "香辣": 4,
            "香甜": 5
        ]
        return splitCSVText(text).compactMap { mapping[$0] }.first ?? 1
    }

    func buildDietMethodExperienceForRequest(from text: String) -> Int {
        guard let localValue = Int(text), localValue >= 0 else {
            return 1
        }
        return localValue + 1
    }

    func buildDietAdjustmentTypesForRequest(from text: String) -> [Int] {
        let values = Set(splitCSVText(text))
        if values.contains("3") {
            return [0]
        }

        var result: [Int] = []
        if values.contains("1") {
            result.append(8)
        }
        if values.contains("2") {
            result.append(7)
        }
        return result.isEmpty ? [0] : result
    }

    func splitCSVText(_ text: String) -> [String] {
        return text
            .split(whereSeparator: { ",，".contains($0) })
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    func birthYear(from value: Any?) -> String {
        let birthday = stringValue(from: value)
        if birthday.contains("-") {
            return birthday.components(separatedBy: "-").first ?? birthday
        }
        return birthday
    }

    func formattedWeightString(from value: Any?) -> String {
        guard let weightValue = parsedWeight(from: value) else {
            return ""
        }
        return String(format: "%.1f", weightValue)
    }

    func parsedWeight(from value: Any?) -> Double? {
        if let number = value as? NSNumber {
            return number.doubleValue
        }
        if let string = value as? String {
            return Double(string.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return nil
    }

    func intArrayValue(from value: Any?) -> [Int] {
        return multiValueArray(from: value).compactMap { Int($0) }
    }

    func multiValueArray(from value: Any?) -> [String] {
        if let array = value as? [Any] {
            return array.map { stringValue(from: $0) }.filter { !$0.isEmpty }
        }
        if let nsArray = value as? NSArray {
            return nsArray.compactMap { stringValue(from: $0) }.filter { !$0.isEmpty }
        }
        let single = stringValue(from: value)
        return single.isEmpty ? [] : [single]
    }

    func mapUserGoals(from values: [Int]) -> String {
        let mapping: [Int: String] = [
            1: "减脂",
            2: "增肌",
            3: "保持体型",
            4: "提升力量",
            5: "提高运动表现",
            6: "提升整体健康",
            7: "改善血脂",
            8: "降低尿酸",
            9: "养成规律饮食习惯",
            10: "节省时间",
            11: "节省外食开销"
        ]
        return values.compactMap { mapping[$0] }.joined(separator: ",")
    }

    func mapFoodRestrictions(from values: [Int]) -> String {
        let mapping: [Int: String] = [
            1: "花生",
            2: "坚果",
            3: "乳制品",
            4: "豆制品",
            5: "海鲜",
            6: "猪肉"
        ]
        return values.compactMap { mapping[$0] }.joined(separator: ",")
    }

    func mapDietAdjustmentTypes(from values: [Int]) -> String {
        let mapping: [Int: String] = [
            0: "3",
            7: "2",
            8: "1"
        ]
        return values.compactMap { mapping[$0] }.joined(separator: ",")
    }

    func mapDietBarriers(from values: [Int]) -> String {
        let mapping: [Int: String] = [
            1: "不确定",
            2: "容易嘴馋",
            3: "做饭太麻烦",
            4: "健身餐不好吃",
            5: "无法平衡家庭餐和健身餐",
            6: "不知道吃什么"
        ]
        return values.compactMap { mapping[$0] }.joined(separator: ",")
    }

    func mapFlavorPreferences(from values: [String]) -> String {
        let mapping: [String: String] = [
            "1": "不确定",
            "2": "清爽",
            "3": "咸香",
            "4": "香辣",
            "5": "香甜"
        ]
        return values.compactMap { mapping[$0] }.joined(separator: ",")
    }

    func normalizedPaceLevel(from value: Any?) -> String {
        let pace = stringValue(from: value)
        return pace.isEmpty ? "2" : pace
    }

    func localDietHistoryValue(from value: Any?) -> String {
        guard let serverValue = Int(stringValue(from: value)), serverValue > 0 else {
            return ""
        }
        return "\(serverValue - 1)"
    }

    func handleFinalFlowFailure(message: String?) {
        createPlanLoadingVm.completeFailure { [weak self] in
            guard let self = self else { return }
            self.isSubmittingFinalFlow = false
            self.syncNextButtonEnableStatus()
            self.updateFullscreenPopGestureAvailability()
            if let message = message, !message.isEmpty {
                MCToast.mc_text(message)
            }
        }
    }

    func handleFinalFlowVipUpgradeRequired() {
        createPlanLoadingVm.completeSuccess { [weak self] in
            guard let self = self else { return }
            self.isWaitingForVipPurchaseToCreatePlan = true
            self.isSubmittingFinalFlow = false
            self.syncNextButtonEnableStatus()
            let vc = ElaProVC()
            vc.showPriceOnly = true
            vc.pendingDietPlanCreateParameters = self.buildDietPlanCreateParameters()
            self.pushElaProVCWhenReady(vc)
        }
    }

    func buildDietPlanCreateParameters() -> [String: Any] {
        return [
            "startDate": requestDateFormatter.string(from: QuestinonaireMsgModel.shared.chartStartDate),
            "endDate": requestDateFormatter.string(from: QuestinonaireMsgModel.shared.chartEndDate),
            "customTdee": QuestinonaireMsgModel.shared.caloriesNumber
        ]
    }

    @objc func handleVipStatusRefreshForPendingCreatePlan() {
        guard isWaitingForVipPurchaseToCreatePlan,
              VIPModel.shared.status == .valid else {
            return
        }
        shouldResumeCreatePlanOnAppear = true
        resumeCreatePlanAfterVipPurchaseIfNeeded()
    }

    func resumeCreatePlanAfterVipPurchaseIfNeeded() {
        guard shouldResumeCreatePlanOnAppear,
              isWaitingForVipPurchaseToCreatePlan,
              VIPModel.shared.status == .valid,
              viewIfLoaded?.window != nil,
              navigationController?.topViewController === self,
              !isSubmittingFinalFlow else {
            return
        }

        shouldResumeCreatePlanOnAppear = false
        isWaitingForVipPurchaseToCreatePlan = false
        isSubmittingFinalFlow = true
        syncNextButtonEnableStatus()
        updateFullscreenPopGestureAvailability()
        createPlanLoadingVm.updateConfig(createPlanLoadingConfig)
        createPlanLoadingVm.start(on: view)
        sendCreatePlanRequestAfterUpsert()
    }

    func visibleStepIndex(forBaseIndex baseIndex: Int) -> Int {
        return shouldShowSexStep && baseIndex >= 1 ? (baseIndex + 1) : baseIndex
    }

    var totalVisibleStepCount: Int {
        return shouldShowSexStep ? 12 : 11
    }

    func applySecretSexSelection(gender: String) {
        let restoredBodyFat = QuestinonaireMsgModel.shared.bodyFat
        let defaultWeight = gender == "1" ? 70.0 : 50.0
        QuestinonaireMsgModel.shared.sex = gender
        weightVm.applyDefaultWeight(integer: Int(defaultWeight))
        targetWeightVm.syncWithCurrentWeight(defaultWeight, syncTarget: true)
        updateSecretSexSelectionUI()
        bodyfatVm.updateScrollView()
        if !restoredBodyFat.isEmpty {
            bodyfatVm.restoreSelection(modelValue: restoredBodyFat)
        }
        syncNextButtonEnableStatus()
    }

    func updateSecretSexSelectionUI() {
        let selectedGender = normalizedGenderValue(QuestinonaireMsgModel.shared.sex)
        if selectedGender == "1" {
            sexVm.sexManButton.backgroundColor = .THEME
            sexVm.sexManIcon.setImgLocal(imgName: "sex_icon_man")
            sexVm.sexManLabel.textColor = .COLOR_TEXT_WHITE

            sexVm.sexFeManButton.backgroundColor = .COLOR_BG_BLACK_04
            sexVm.sexFeManIcon.setImgLocal(imgName: "sex_icon_feman_normal")
            sexVm.sexFeManLabel.textColor = WHColor_16(colorStr: "595959")
        } else if selectedGender == "2" {
            sexVm.sexManButton.backgroundColor = .COLOR_BG_BLACK_04
            sexVm.sexManIcon.setImgLocal(imgName: "sex_icon_man_normal")
            sexVm.sexManLabel.textColor = WHColor_16(colorStr: "595959")

            sexVm.sexFeManButton.backgroundColor = UIColor(named: "color_sex_femal") ?? .THEME
            sexVm.sexFeManIcon.setImgLocal(imgName: "sex_icon_feman")
            sexVm.sexFeManLabel.textColor = .COLOR_TEXT_WHITE
        } else {
            sexVm.sexManButton.backgroundColor = .COLOR_BG_BLACK_04
            sexVm.sexManIcon.setImgLocal(imgName: "sex_icon_man_normal")
            sexVm.sexManLabel.textColor = WHColor_16(colorStr: "595959")

            sexVm.sexFeManButton.backgroundColor = .COLOR_BG_BLACK_04
            sexVm.sexFeManIcon.setImgLocal(imgName: "sex_icon_feman_normal")
            sexVm.sexFeManLabel.textColor = WHColor_16(colorStr: "595959")
        }
    }

    func normalizedProfileGender() -> String {
        let profileGender = normalizedGenderValue(UserInfoModel.shared.gender)
        if !profileGender.isEmpty {
            return profileGender
        }
        return normalizedGenderValue(UserInfoModel.shared.sex)
    }

    func normalizedGenderValue(_ value: String) -> String {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
        switch normalized {
        case "1", "男":
            return "1"
        case "2", "女":
            return "2"
        default:
            return ""
        }
    }
}

extension DietPlanCreateSecondVC: UIGestureRecognizerDelegate, UIScrollViewDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === backEdgePanGesture else { return true }
        guard !isBackButtonCoolingDown, !isStepTransitioning, !isScrollBackInteractionInProgress else { return false }
        
        if isShowingManualTargetEditor {
            return true
        }
        
        guard !isSubmittingFinalFlow,
              let panGesture = gestureRecognizer as? UIPanGestureRecognizer,
              let gestureView = panGesture.view else {
            return false
        }
        return !isAtInitialScrollPage && isBackSwipe(panGesture, in: gestureView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === scrollViewBase else { return }
        scrollDragStartIndex = currentIndex
        isScrollBackInteractionInProgress = true
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
        let offsetRange = allowedBackScrollOffsetRange(from: startIndex)
        targetContentOffset.pointee.x = min(max(targetContentOffset.pointee.x, offsetRange.min), offsetRange.max)
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
    
    private func allowedBackScrollOffsetRange(from startIndex: Int) -> (min: CGFloat, max: CGFloat) {
        let currentOffsetX = SCREEN_WIDHT * CGFloat(max(startIndex, 0))
        let previousIndex = max(previousStepIndex(from: startIndex), 0)
        let previousOffsetX = SCREEN_WIDHT * CGFloat(previousIndex)
        return (min: previousOffsetX, max: currentOffsetX)
    }
    
    private func prepareStepTransition(to targetOffsetX: CGFloat, animated: Bool) {
        isStepTransitioning = animated && abs(scrollViewBase.contentOffset.x - targetOffsetX) > 0.5
        scrollViewBase.isScrollEnabled = !isStepTransitioning
    }
    
    private func syncCurrentStepWithScrollView(_ scrollView: UIScrollView) {
        guard scrollView === scrollViewBase else { return }
        let maxOffsetX = max(scrollView.contentSize.width - scrollView.bounds.width, 0)
        let maxIndex = max(Int(round(maxOffsetX / SCREEN_WIDHT)), 0)
        let visibleIndex = min(max(Int(round(scrollView.contentOffset.x / SCREEN_WIDHT)), 0), maxIndex)
        
        if currentIndex != visibleIndex {
            currentIndex = visibleIndex
            updateNextButtonForCurrentStep(animated: false)
        }
        isStepTransitioning = false
        isScrollBackInteractionInProgress = false
        scrollViewBase.isScrollEnabled = true
        scrollDragStartIndex = nil
        updateFullscreenPopGestureAvailability()
    }
    
    private func updateFullscreenPopGestureAvailability() {
        guard isViewLoaded else { return }
        configureScrollPanFailureRequirementIfNeeded()
        let shouldAllowFullscreenPop = isAtInitialScrollPage && !isShowingManualTargetEditor && !isSubmittingFinalFlow
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
