//
//  DietPlanCreateVC.swift
//  lns
//  饮食计划生成页面
//  Created by LNS2 on 2026/2/24.
//  


class DietPlanCreateVC: WHBaseViewVC {
    
    var currentIndex: Int = 0
    private var maxReachedIndex: Int = 0
    private var isGoalStepEnabled = false
    private let draftKeyPrefix = "diet_plan_create_draft_"
    private var isRestoringDraft = false
    private var shouldSkipDraftPersistence = false
    private var hasRestoredDraft = false
    private var shouldResumeFromEatStyleForNonVip = false
    
    var skipStepsOne = 0
    var skipStepsNine = false//是否跳过第九步  此处是由第八步决定
    var skipMealStyle = false//是否跳过 一日几餐的选择页面
    var skipKetoHistory = false//是否跳过生酮历史（由饮食风格决定）
    
    private var isUploadingDietProfile = false
    private var shouldSkipSexStep: Bool {
        UserInfoModel.shared.gender == "1" || UserInfoModel.shared.gender == "2"
    }
    private var shouldSkipBirthdayStep = false
//    private var shouldSkipBirthdayStep: Bool {
//        
//        !UserInfoModel.shared.birthDay.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.fd_interactivePopDisabled = true
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.fd_interactivePopDisabled = false
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        persistDraftIfNeeded()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
//        let profileGender = normalizedProfileGender()
//        let questionnaireGender = normalizedGenderValue(QuestinonaireMsgModel.shared.sex)
//        return profileGender != "" && profileGender != questionnaireGender
        
        syncProfileFromUserInfoIfNeeded(applyDefaultValues: true)
        observeDraftChanges()
        handleDraftRestoreFlow()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .dietPlanPaceInputDidChange, object: nil)
    }
    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
        vm.backTapBlock = {[weak self] in
            guard let self = self else { return }
            if self.currentIndex == 0 {
                self.backTapAction()
                return
            }
            let previousIndex = self.currentIndex
            self.currentIndex = self.previousStepIndex(from: self.currentIndex)
            let targetOffsetX = SCREEN_WIDHT * CGFloat(self.currentIndex)
            let shouldAnimate = self.shouldAnimateStepTransition(from: previousIndex, to: self.currentIndex)
            self.scrollViewBase.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: shouldAnimate)
            self.updateNextButtonForCurrentStep(animated: true)
            self.persistDraftIfNeeded()
        }
        return vm
    }()
    lazy var stepsArray: [Int] = {
        return displayedStepsArray(for: [5,6,6])
    }()
    lazy var goalVm: DietPlanCreateGoalVM = {
        let vm = DietPlanCreateGoalVM.init(frame: .zero)
        vm.nextButtonEnableChangeBlock = {[weak self] isEnabled in
            self?.isGoalStepEnabled = isEnabled
            self?.syncNextButtonEnableStatus()
        }
        vm.selectedGoalsBlock = { [weak self] selectedGoals in
            QuestinonaireMsgModel.shared.goal = selectedGoals.joined(separator: ",")
            self?.allergyVm.applyGoalFilter()
        }
        return vm
    }()
    lazy var sexVm: DietPlanCreateSexVM = {
        let vm = DietPlanCreateSexVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: 0, height: 0))
        vm.manTapBlock = {[weak self] in
            self?.heightVm.applyDefaultHeight(170)
            self?.weightVm.applyDefaultWeight(integer: 70)
            self?.syncNextButtonEnableStatus()
        }
        vm.femanTapBlock = {[weak self] in
            self?.heightVm.applyDefaultHeight(160)
            self?.weightVm.applyDefaultWeight(integer: 50)
            self?.syncNextButtonEnableStatus()
        }
        vm.showTipsBlock = {()in
            self.sexTipsAlertVm.showView()
        }
        
        return vm
    }()
    lazy var birthdayVm: DietPlanCreateYearVM = {
        let vm = DietPlanCreateYearVM.init(frame: CGRect.init(x: SCREEN_WIDHT*2, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var heightVm: DietPlanCreateHeightVM = {
        let vm = DietPlanCreateHeightVM.init(frame: CGRect(x: SCREEN_WIDHT * 3, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var weightVm: DietPlanCreateWeightVM = {
        let vm = DietPlanCreateWeightVM.init(frame: CGRect.init(x: SCREEN_WIDHT*4, y: 0, width: 0, height: 0))
        vm.weightChangedBlock = { [weak self] weight in
            self?.targetWeightVm.syncWithCurrentWeight(weight)
        }
        vm.showTipsBlock = {()in
            self.weightTipsAlertVm.showView()
        }
        return vm
    }()
    lazy var bodyfatVm: DietPlanCreateBodyfatVM = {
        let vm = DietPlanCreateBodyfatVM.init(frame: CGRect(x: SCREEN_WIDHT * 5, y: 0, width: 0, height: 0))
        vm.selectStateChangeBlock = {[weak self] _ in
            self?.syncNextButtonEnableStatus()
        }
        
        vm.showTipsBlock = {()in
            self.bodyFatAlertVm.showView()
        }
        return vm
    }()
    lazy var targetWeightVm: DietPlanCreateTargetWeightVM = {
        let vm = DietPlanCreateTargetWeightVM(frame: CGRect(x: SCREEN_WIDHT * 6, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var eventsVm: DietPlanCreateEventsVM = {
        let vm = DietPlanCreateEventsVM.init(frame: CGRect(x: SCREEN_WIDHT * 7, y: 0, width: 0, height: 0))
        vm.selectedBlock = {[weak self] in
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var importantVm: DietPlanCreateImportantVM = {
        let vm = DietPlanCreateImportantVM.init(frame: CGRect.init(x: SCREEN_WIDHT*8, y: 0, width: 0, height: 0))
        vm.selectedBlock = {[weak self] in
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var paceVm: DietPlanCreatePaceVM = {
        let vm = DietPlanCreatePaceVM(frame: CGRect(x: SCREEN_WIDHT * 9, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var allergyVm: DietPlanCreateAllergyVM = {
        let vm = DietPlanCreateAllergyVM(frame: CGRect(x: SCREEN_WIDHT * 10, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "你是否有过敏或忌口？"
        vm.selectedBlock = {[weak self] in
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var barrierVm: DietPlanCreateBarrierVM = {
        let vm = DietPlanCreateBarrierVM(frame: CGRect(x: SCREEN_WIDHT * 11, y: 0, width: 0, height: 0))
        vm.selectedBlock = {[weak self] in
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var adviceVm: DietPlanCreateAdviceVM = {
        let vm = DietPlanCreateAdviceVM(frame: CGRect(x: SCREEN_WIDHT * 12, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var mealStyleVm: DietPlanCreateMealStyleVM = {
        let vm = DietPlanCreateMealStyleVM(frame: CGRect(x: SCREEN_WIDHT * 13, y: 0, width: 0, height: 0))
        vm.selectedBlock = {[weak self] in
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var eatStyleVm: DietPlanCreateEatStyleVM = {
        let vm = DietPlanCreateEatStyleVM.init(frame: CGRect.init(x: SCREEN_WIDHT*14, y: 0, width: 0, height: 0))
        vm.selectedBlock = {[weak self] in
            self?.updateKetoHistoryTitleIfNeeded()
            self?.updateKetoHistorySkipIfNeeded()
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var ketoHistoryVm: DietPlanCreateKetoHistoryVM = {
        let vm = DietPlanCreateKetoHistoryVM(frame: CGRect(x: SCREEN_WIDHT * 15, y: 0, width: 0, height: 0))
        vm.selectedBlock = {[weak self] in
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    
    lazy var flavorVM: DietPlanCreateFlavorVM = {
        let vm = DietPlanCreateFlavorVM(frame: CGRect(x: SCREEN_WIDHT * 16, y: 0, width: 0, height: 0))
        vm.selectedBlock = {[weak self] in
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var bodyFatAlertVm : QuestionnaireBodyFatAlertVM = {
        let vm = QuestionnaireBodyFatAlertVM.init(frame: .zero)
        
        return vm
    }()
    lazy var targetWeightAlertVm: ElaCreateTargetWeightAlertVM = {
        let vm = ElaCreateTargetWeightAlertVM(frame: .zero)
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
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)

        return btn
    }()
    lazy var sexTipsAlertVm: GuidanceSexTipsAlertVM = {
        let vm = GuidanceSexTipsAlertVM(frame: .zero)
        return vm
    }()
    lazy var weightTipsAlertVm: DietPlanCreateWeightAlertVM = {
        let vm = DietPlanCreateWeightAlertVM.init(frame: .zero)
        
        return vm
    }()
}

extension DietPlanCreateVC{
    @objc func nextButtonTapAction() {
        if currentIndex == displayStepIndex(for: 6), let payload = targetWeightVm.buildTargetWeightAlertPayload() {
            targetWeightAlertVm.showView(type: payload.type, confirmBlock: { [weak self] in
                guard let self = self else { return }
                self.targetWeightVm.applyRecommendedTargetWeight(payload.recommendedWeight)
                self.goToNextStep()
            })
            return
        }
        goToNextStep()
    }

    func goToNextStep() {
        resetDraftAfterManualSexChangeIfNeeded()
        if currentIndex == displayStepIndex(for: 1) && !shouldSkipSexStep {
            bodyfatVm.updateScrollView()
        }

        let maxOffsetX = max(scrollViewBase.contentSize.width - scrollViewBase.bounds.width, 0)
        let isAtLastStep = scrollViewBase.contentOffset.x >= (maxOffsetX - 0.5)
        if isAtLastStep {
            sendDietUpsertRequest()
            return
        }

        let nextIndex = nextStepIndex(from: currentIndex)
        
        if nextIndex == displayStepIndex(for: 5) {
            weightVm.getWeightValue()
            targetWeightVm.applyInitialValue()
            if !shouldSkipBirthdayStep {
                birthdayVm.getBirthDayData()
            }
        }
        if currentIndex == displayStepIndex(for: 6){
            //目标体重如果是维持，则跳过 第8步“达成目标对你有多重要？”   和  第9步“你希望多快达成目标？”
            skipStepsOne = shouldSkipImportantAndPaceSteps() ? 2 : 0
        }
        if currentIndex == displayStepIndex(for: 7) {
            sendBasicRequest()
        }
        
        let targetOffsetX = SCREEN_WIDHT * CGFloat(nextIndex)
        let finalOffsetX = min(targetOffsetX, maxOffsetX)
        let previousIndex = currentIndex
        currentIndex = Int(round(finalOffsetX / SCREEN_WIDHT))
        updateMaxReachedIndexIfNeeded(withVisibleIndex: currentIndex)
        let shouldAnimate = shouldAnimateStepTransition(from: previousIndex, to: currentIndex)
        scrollViewBase.setContentOffset(CGPoint(x: finalOffsetX, y: 0), animated: shouldAnimate)
        updateNextButtonForCurrentStep(animated: true)
        persistDraftIfNeeded()
    }

    func moveFromSexToNextStep() {
        guard currentIndex == displayStepIndex(for: 1) else { return }
        resetDraftAfterManualSexChangeIfNeeded()
        let nextIndex = nextStepIndex(from: currentIndex)
        let targetOffsetX = SCREEN_WIDHT * CGFloat(nextIndex)
        let maxOffsetX = max(scrollViewBase.contentSize.width - scrollViewBase.bounds.width, 0)
        let finalOffsetX = min(targetOffsetX, maxOffsetX)
        let previousIndex = currentIndex
        currentIndex = Int(round(finalOffsetX / SCREEN_WIDHT))
        updateMaxReachedIndexIfNeeded(withVisibleIndex: currentIndex)
        let shouldAnimate = shouldAnimateStepTransition(from: previousIndex, to: currentIndex)
        scrollViewBase.setContentOffset(CGPoint(x: finalOffsetX, y: 0), animated: shouldAnimate)
        updateNextButtonForCurrentStep(animated: true)
        self.bodyfatVm.updateScrollView()
        persistDraftIfNeeded()
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
        DLLog(message: "当前步骤：\(currentIndex)")
        
        if currentIndex > 0 {
            self.enableInteractivePopGesture()
        }else{
            self.openInteractivePopGesture()
        }
        
        let introIndexOffset = skippedIntroStepIndexes.count
        let skipStepN = skipStepsNine ? 1 : 0
        let mealStyleIndex = skipMealStyle ? 1 : 0
        let ketoIndex = 15-skipStepsOne-skipStepN-mealStyleIndex-introIndexOffset
        let flavorIndex = 16-skipStepsOne-skipStepN-(skipKetoHistory ? 1 : 0)-mealStyleIndex-introIndexOffset
        
        switch currentIndex {
        case 0:
            nextButton.isEnabled = isGoalStepEnabled
        case let idx where idx == displayStepIndex(for: 1) && !shouldSkipSexStep:
            nextButton.isEnabled = !QuestinonaireMsgModel.shared.sex.isEmpty
        case 5-introIndexOffset:
            nextButton.isEnabled = bodyfatVm.selectIndex >= 0
        case 6-introIndexOffset:
            targetWeightVm.tipsLabel.alpha = 0
            targetWeightVm.valueChanged = false
            nextButton.isEnabled = !QuestinonaireMsgModel.shared.targetWeight.isEmpty
        case 7-introIndexOffset:
            nextButton.isEnabled = eventsVm.selectedIndex >= 0
        case 8-skipStepsOne-introIndexOffset:
            nextButton.isEnabled = importantVm.selectedIndex >= 0
        case 10-skipStepsOne-skipStepN-introIndexOffset:
            nextButton.isEnabled = allergyVm.selectedIndex >= 0
        case 11-skipStepsOne-skipStepN-introIndexOffset:
            nextButton.isEnabled = barrierVm.selectedIndex >= 0
        case 13-skipStepsOne-skipStepN-introIndexOffset:
            if skipMealStyle{
                nextButton.isEnabled = eatStyleVm.selectedIndex >= 0
            }else{
                nextButton.isEnabled = mealStyleVm.selectedIndex >= 0
            }
        case 14-skipStepsOne-skipStepN-mealStyleIndex-introIndexOffset:
            nextButton.isEnabled = eatStyleVm.selectedIndex >= 0
        case ketoIndex:
            nextButton.isEnabled = skipKetoHistory ? (flavorVM.selectedIndex >= 0) : (ketoHistoryVm.selectedIndex >= 0)
        case flavorIndex:
            nextButton.isEnabled = flavorVM.selectedIndex >= 0
        default:
            nextButton.isEnabled = true
        }
    }

    func nextStepIndex(from index: Int) -> Int {
        if index == displayStepIndex(for: 6) && shouldSkipImportantAndPaceSteps() {
//            return 10
        }
//        if index == 7{
//            DLLog(message: "日常活动量选择------")
//        }
        if index == displayStepIndex(for: 8) {
            //8. 达成目标对你有多重要？
            //以下处理，只有当目标体重  非维持时，即显示 “达成目标对你有多重要？”时。否则 跳过这里的判断
            if !shouldSkipImportantAndPaceSteps(){
                let off = skipMealStyle ? SCREEN_WIDHT : 0
                if importantVm.selectedIndex == 3{
    //            1.非常重要，我愿意全力以赴   想尽快看到明显进展
    //            2.我愿意认真尝试           希望稳步取得不错的进度
    //            3.我更想循序渐进           选择更轻松、更容易坚持的方式
    //            4.我还不确定
    //            备注：如选择 4，则跳过 9（9 默认选择 2）
                    paceVm.isHidden = true
                    skipStepsNine = true
                    if skipMealStyle {
                        scrollViewBase.contentSize = CGSize.init(width: contentWidth(forBasePageCount: 15), height: 0)
                        self.stepsArray = self.displayedStepsArray(for: [5,5,5])
                    }else{
                        scrollViewBase.contentSize = CGSize.init(width: contentWidth(forBasePageCount: 16), height: 0)
                        self.stepsArray = self.displayedStepsArray(for: [5,5,6])
                    }
//                    scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*16, height: 0)
//                    self.stepsArray = skipMealStyle ? [5,5,5] : [5,5,6]
                    let firstCenterX = paceVm.center.x//(SCREEN_WIDHT * 9.5)
                    allergyVm.center = CGPoint(x: firstCenterX, y: SCREEN_HEIGHT*0.5)
                    barrierVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT, y: SCREEN_HEIGHT*0.5)
                    adviceVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*2, y: SCREEN_HEIGHT*0.5)
                    mealStyleVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*3, y: SCREEN_HEIGHT*0.5)
                    eatStyleVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*4-off, y: SCREEN_HEIGHT*0.5)
                    ketoHistoryVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*5-off, y: SCREEN_HEIGHT*0.5)
                    flavorVM.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*6-off, y: SCREEN_HEIGHT*0.5)
                    updateKetoHistorySkipIfNeeded()
                }else{
                    if skipStepsNine{//如果之前选择的是 4
                        paceVm.isHidden = false
                        if skipMealStyle {
                            scrollViewBase.contentSize = CGSize.init(width: contentWidth(forBasePageCount: 16), height: 0)
                            self.stepsArray = self.displayedStepsArray(for: [5,5,6])
                        }else{
                            scrollViewBase.contentSize = CGSize.init(width: contentWidth(forBasePageCount: 17), height: 0)
                            self.stepsArray = self.displayedStepsArray(for: [5,6,6])
                        }
//                        scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*17, height: 0)
//                        self.stepsArray = skipMealStyle ? [5,6,5] : [5,6,6]
                        let firstCenterX = pageCenterX(forOriginalPage: 10.5)
                        allergyVm.center = CGPoint(x: firstCenterX, y: SCREEN_HEIGHT*0.5)
                        barrierVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT, y: SCREEN_HEIGHT*0.5)
                        adviceVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*2, y: SCREEN_HEIGHT*0.5)
                        mealStyleVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*3, y: SCREEN_HEIGHT*0.5)
                        eatStyleVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*4-off, y: SCREEN_HEIGHT*0.5)
                        ketoHistoryVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*5-off, y: SCREEN_HEIGHT*0.5)
                        flavorVM.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*6-off, y: SCREEN_HEIGHT*0.5)
                        updateKetoHistorySkipIfNeeded()
                    }
                    skipStepsNine = false
                }
            }
        }
        return index + 1
    }

    func previousStepIndex(from index: Int) -> Int {
//        if index == 10 && shouldSkipImportantAndPaceSteps() {
//            return 6
//        }
        return index - 1
    }

    func shouldAnimateStepTransition(from previousIndex: Int, to nextIndex: Int) -> Bool {
        if abs(nextIndex - previousIndex) <= 1 {
            return true
        }

        let lowerBound = min(previousIndex, nextIndex) + 1
        let upperBound = max(previousIndex, nextIndex)
        let skippedSet = Set(skippedIntroStepIndexes)
        let crossedIndexes = Array(lowerBound..<upperBound)
        guard !crossedIndexes.isEmpty else {
            return false
        }
        return crossedIndexes.allSatisfy { skippedSet.contains($0) }
    }

    func shouldSkipImportantAndPaceSteps() -> Bool {
        let currentWeightText = QuestinonaireMsgModel.shared.weight
        let targetWeightText = QuestinonaireMsgModel.shared.targetWeight
        guard
            let currentWeight = Double(currentWeightText),
            let targetWeight = Double(targetWeightText)
        else {
            if goalVm.buildUserGoal().contains(7){
                return true
            }
            return false
        }
        var isSkip = abs(currentWeight - targetWeight) < 0.05
        
        //2026年03月16日17:48:27    如果第一步选择了增肌 +  降血脂，默认跳过8/9
        if goalVm.buildUserGoal().contains(7){
            isSkip = true
        }
        
        let off = skipMealStyle ? SCREEN_WIDHT : 0
        if skipMealStyle{
            self.stepsArray = displayedStepsArray(for: isSkip ? [5,5,4] : [5,5,6])
        }else{
            self.stepsArray = displayedStepsArray(for: isSkip ? [5,5,5] : [5,6,6])
        }
//        self.stepsArray = isSkip ? [5,5,5] : [5,6,6]
        let firstCenterX = pageCenterX(forOriginalPage: isSkip ? 8.5 : 10.5)
        allergyVm.center = CGPoint(x: firstCenterX, y: SCREEN_HEIGHT*0.5)
        barrierVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT, y: SCREEN_HEIGHT*0.5)
        adviceVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*2, y: SCREEN_HEIGHT*0.5)
        mealStyleVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*3, y: SCREEN_HEIGHT*0.5)
        eatStyleVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*4-off, y: SCREEN_HEIGHT*0.5)
        ketoHistoryVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*5-off, y: SCREEN_HEIGHT*0.5)
        flavorVM.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*6-off, y: SCREEN_HEIGHT*0.5)
        
        if isSkip{
            importantVm.isHidden = true
            paceVm.isHidden = true
            scrollViewBase.contentSize = CGSize.init(width: contentWidth(forBasePageCount: 15)-off, height: 0)
        }else{
            importantVm.isHidden = false
            paceVm.isHidden = false
            scrollViewBase.contentSize = CGSize.init(width: contentWidth(forBasePageCount: 17)-off, height: 0)
        }
        updateKetoHistorySkipIfNeeded()
        return isSkip
    }

    func shouldSkipKetoHistoryStep() -> Bool {
        guard eatStyleVm.selectedIndex >= 0,
              eatStyleVm.selectedIndex < eatStyleVm.dataArray.count else {
            return false
        }
        return eatStyleVm.selectedIndex == 0
    }

    func updateKetoHistoryTitleIfNeeded() {
        let titleText: String
        switch eatStyleVm.selectedIndex {
        case 1:
            titleText = "你之前有尝试过\n高蛋白饮食吗？"
        case 2:
            titleText = "你之前有尝试过\n生酮饮食吗？"
        case 3:
            titleText = "你之前有尝试过\n低碳饮食吗？"
        default:
            titleText = "你之前有尝试过\n高蛋白/低碳/生酮饮食吗？"
        }
        ketoHistoryVm.titleLabel.text = titleText
//        ketoHistoryVm.titleLabel.setLineHeight(
//            textString: titleText,
//            lineHeight: ketoHistoryVm.titleLabel.font.lineHeight * 0.8
//        )
    }

    func updateKetoHistorySkipIfNeeded() {
        updateKetoHistoryTitleIfNeeded()
        let shouldSkip = shouldSkipKetoHistoryStep()
        let skipStateChanged = (shouldSkip != skipKetoHistory)

        skipKetoHistory = shouldSkip
        ketoHistoryVm.isHidden = shouldSkip

        if shouldSkip {
            flavorVM.center = ketoHistoryVm.center
            if skipStateChanged {
                scrollViewBase.contentSize = CGSize(width: max(scrollViewBase.contentSize.width - SCREEN_WIDHT, SCREEN_WIDHT), height: 0)
                if stepsArray.count >= 3 {
                    stepsArray[2] = max(1, stepsArray[2] - 1)
                }
            }
        } else {
            flavorVM.center = CGPoint(x: ketoHistoryVm.center.x + SCREEN_WIDHT, y: ketoHistoryVm.center.y)
            if skipStateChanged {
                scrollViewBase.contentSize = CGSize(width: scrollViewBase.contentSize.width + SCREEN_WIDHT, height: 0)
                if stepsArray.count >= 3 {
                    stepsArray[2] += 1
                }
            }
        }
    }
    //第七步，判断是否跳过 mealStyleVm
    func updateEatStyleSkipIfNeeded(){
        if mealStyleVm.isHidden == skipMealStyle{
            return
        }
        mealStyleVm.isHidden = skipMealStyle
        if skipMealStyle{
            flavorVM.center = ketoHistoryVm.center
            ketoHistoryVm.center = eatStyleVm.center
            eatStyleVm.center = mealStyleVm.center
            scrollViewBase.contentSize = CGSize(width: max(scrollViewBase.contentSize.width - SCREEN_WIDHT, SCREEN_WIDHT), height: 0)
            if stepsArray.count >= 3 {
                stepsArray[2] = max(1, stepsArray[2] - 1)
            }
        }else{
            mealStyleVm.center = eatStyleVm.center
            eatStyleVm.center = ketoHistoryVm.center
            ketoHistoryVm.center = flavorVM.center
            flavorVM.center = CGPoint(x: ketoHistoryVm.center.x+SCREEN_WIDHT, y: ketoHistoryVm.center.y)
            scrollViewBase.contentSize = CGSize(width: scrollViewBase.contentSize.width + SCREEN_WIDHT, height: 0)
            if stepsArray.count >= 3 {
                stepsArray[2] += 1
            }
        }
    }
}
    
extension DietPlanCreateVC{
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(scrollViewBase)
        view.addSubview(naviVm)
        view.addSubview(nextButton)
        
        view.addSubview(bodyFatAlertVm)
        view.addSubview(targetWeightAlertVm)
        view.addSubview(sexTipsAlertVm)
        view.addSubview(weightTipsAlertVm)
        
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.isScrollEnabled = false
        
        scrollViewBase.addSubview(goalVm)
        scrollViewBase.addSubview(sexVm)
        scrollViewBase.addSubview(birthdayVm)
        scrollViewBase.addSubview(heightVm)
        scrollViewBase.addSubview(weightVm)
        scrollViewBase.addSubview(bodyfatVm)
        scrollViewBase.addSubview(targetWeightVm)
        scrollViewBase.addSubview(eventsVm)
        scrollViewBase.addSubview(importantVm)
        scrollViewBase.addSubview(paceVm)
        scrollViewBase.addSubview(allergyVm)
        scrollViewBase.addSubview(barrierVm)
        scrollViewBase.addSubview(adviceVm)
        scrollViewBase.addSubview(mealStyleVm)
        scrollViewBase.addSubview(eatStyleVm)
        scrollViewBase.addSubview(ketoHistoryVm)
        scrollViewBase.addSubview(flavorVM)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            if self.hasRestoredDraft {
                return
            }
            if self.shouldSkipBirthdayStep {
                return
            }
            self.birthdayVm.pickerView.selectRow(self.birthdayVm.defaultIndex, inComponent: 0, animated: true)
        })
        
        scrollViewBase.isPagingEnabled = true
        applyIntroStepOffsetLayout()
        scrollViewBase.contentSize = CGSize.init(width: contentWidth(forBasePageCount: 17), height: 0)
        sexVm.isHidden = shouldSkipSexStep
        birthdayVm.isHidden = shouldSkipBirthdayStep

        if WHUtils().getBottomSafeAreaHeight() > 0{
            nextButton.snp.makeConstraints { make in
                make.left.equalTo(kFitWidth(20))
                make.right.equalTo(kFitWidth(-20))
                make.height.equalTo(kFitWidth(44))
                make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight())
            }
        }else{
            nextButton.snp.makeConstraints { make in
                make.left.equalTo(kFitWidth(20))
                make.right.equalTo(kFitWidth(-20))
                make.height.equalTo(kFitWidth(44))
                make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
            }
        }
        
        updateNextButtonForCurrentStep(animated: false)
    }
}

extension DietPlanCreateVC{
    func observeDraftChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDraftInputDidChange),
            name: .dietPlanPaceInputDidChange,
            object: nil
        )
    }
    
    @objc func handleDraftInputDidChange() {
        persistDraftIfNeeded()
    }
    
    func persistDraftIfNeeded() {
        if isRestoringDraft || shouldSkipDraftPersistence {
            return
        }
        guard let key = draftStorageKey() else {
            return
        }
        let draft = buildDraftPayload()
        if hasDraftProgress(draft) {
            UserDefaults.standard.set(draft, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    func restoreDraftIfNeeded() {
        if hasRestoredDraft {
            return
        }
        guard let key = draftStorageKey(),
              let draft = UserDefaults.standard.dictionary(forKey: key) else {
            return
        }
        
        isRestoringDraft = true
        defer {
            isRestoringDraft = false
            hasRestoredDraft = true
        }
        
        let model = QuestinonaireMsgModel.shared
        model.sex = resolvedDraftGender(from: draft)
        model.birthYear = draftString(draft["birthYear"])
        model.goal = draftString(draft["goal"])
        model.height = draftString(draft["height"])
        model.weight = draftString(draft["weight"])
        model.targetWeight = draftString(draft["targetWeight"])
        model.bodyFat = draftString(draft["bodyFat"])
        model.events = draftString(draft["events"])
        model.paceLevel = draftString(draft["paceLevel"], fallback: "2")
        model.foodAllergy = draftString(draft["foodAllergy"])
        model.foodBarrier = draftString(draft["foodBarrier"])
        model.foodTasteType = draftString(draft["foodTasteType"])
        model.dietHistoryType = draftString(draft["dietHistoryType"])
        model.caloriesNumber = draftString(draft["caloriesNumber"])
        model.caloriesNumberFromServer = draftString(draft["caloriesNumberFromServer"])
        
        let goalIndexes = Set(draftIntArray(draft["goalSelectedIndexes"]).filter { $0 >= 0 && $0 < goalVm.dataArray.count })
        goalVm.selectedIndexes = goalIndexes
        goalVm.selectedIndex = goalIndexes.sorted().first ?? -1
        goalVm.refreshListUI()
        let selectedGoals = goalIndexes.sorted().map { goalVm.dataArray[$0] }
        model.goal = selectedGoals.joined(separator: ",")
        isGoalStepEnabled = !selectedGoals.isEmpty
        goalVm.nextButtonEnableChangeBlock?(!selectedGoals.isEmpty)
        goalVm.selectedGoalsBlock?(selectedGoals)
        
        applySexSelectionUI()
        bodyfatVm.updateScrollView()
        
        if let birthYear = Int(model.birthYear) {
            let yearArray = birthdayVm.yearDataArray.compactMap { $0 as? Int }
            if let yearIndex = yearArray.firstIndex(of: birthYear) {
                birthdayVm.pickerView.selectRow(yearIndex, inComponent: 0, animated: false)
            }
        }
        
        if let heightValue = Int(model.height), heightValue > 0 {
            heightVm.applyDefaultHeight(heightValue)
        }
        
        if let weightValue = Double(model.weight), weightValue > 0 {
            let rounded = (weightValue * 10).rounded() / 10
            let integerPart = Int(rounded)
            let decimalPart = Int((rounded * 10).truncatingRemainder(dividingBy: 10))
            weightVm.applyDefaultWeight(integer: integerPart, decimal: max(0, min(decimalPart, 9)))
        } else {
            weightVm.getWeightValue()
        }
        
        targetWeightVm.applyInitialValue()
        
        let hasValidBodyFatSelection = restoreBodyFatSelection(from: draft, gender: model.sex)
        
        eventsVm.selectedIndex = normalizedSingleSelectionIndex(
            preferred: draftInt(draft["eventsSelectedIndex"], fallback: -1),
            fallback: (Int(model.events) ?? 0) - 1,
            count: eventsVm.dataArray.count
        )
        if eventsVm.selectedIndex >= 0 {
            model.events = "\(eventsVm.selectedIndex + 1)"
        }
        eventsVm.tableView.reloadData()
        
        importantVm.selectedIndex = normalizedSingleSelectionIndex(
            preferred: draftInt(draft["importantSelectedIndex"], fallback: -1),
            fallback: -1,
            count: importantVm.dataArray.count
        )
        importantVm.tableView.reloadData()
        
        if model.paceLevel.isEmpty {
            model.paceLevel = "2"
        }
        paceVm.restoreLevelFromDraft(modelValue: model.paceLevel)
        
        allergyVm.applyGoalFilter()
        let allergyIndexes = restoredIndexes(
            csvText: model.foodAllergy,
            rawIndexes: draftIntArray(draft["allergySelectedIndexes"]),
            dataArray: allergyVm.dataArray
        )
        allergyVm.selectedIndexes = allergyIndexes
        allergyVm.selectedIndex = allergyIndexes.sorted().first ?? -1
        allergyVm.refreshListUI()
        model.foodAllergy = allergyIndexes.sorted().map { allergyVm.dataArray[$0] }.joined(separator: ",")
        allergyVm.applyDefaultSelectionsForLowerUricAcidIfNeeded()
        
        let barrierIndexes = restoredIndexes(
            csvText: model.foodBarrier,
            rawIndexes: draftIntArray(draft["barrierSelectedIndexes"]),
            dataArray: barrierVm.dataArray
        )
        barrierVm.selectedIndexes = barrierIndexes
        barrierVm.selectedIndex = barrierIndexes.sorted().first ?? -1
        barrierVm.refreshListUI()
        model.foodBarrier = barrierIndexes.sorted().map { barrierVm.dataArray[$0] }.joined(separator: ",")
        
        mealStyleVm.selectedIndex = normalizedSingleSelectionIndex(
            preferred: draftInt(draft["mealStyleSelectedIndex"], fallback: -1),
            fallback: -1,
            count: mealStyleVm.dataArray.count
        )
        if mealStyleVm.selectedIndex >= 0 {
            model.mealsPerDay = mealStyleVm.selectedIndex == 1 ? "4" : "3"
        }
        mealStyleVm.tableView.reloadData()
        
        eatStyleVm.selectedIndex = normalizedSingleSelectionIndex(
            preferred: draftInt(draft["eatStyleSelectedIndex"], fallback: -1),
            fallback: -1,
            count: eatStyleVm.dataArray.count
        )
        eatStyleVm.refreshListUI()
        
        let ketoIndex = normalizedSingleSelectionIndex(
            preferred: draftInt(draft["ketoHistorySelectedIndex"], fallback: -1),
            fallback: -1,
            count: 3
        )
        if ketoIndex >= 0 {
            ketoHistoryVm.select(index: ketoIndex)
        }
        
        let flavorIndexes = restoredIndexes(
            csvText: model.foodTasteType,
            rawIndexes: draftIntArray(draft["flavorSelectedIndexes"]),
            dataArray: flavorVM.dataArray
        )
        flavorVM.selectedIndexes = flavorIndexes
        flavorVM.selectedIndex = flavorIndexes.sorted().first ?? -1
        flavorVM.refreshListUI()
        model.foodTasteType = flavorIndexes.sorted().map { flavorVM.dataArray[$0] }.joined(separator: ",")
        
        skipMealStyle = draftBool(draft["skipMealStyle"])
        if skipMealStyle && mealStyleVm.selectedIndex < 0 {
            mealStyleVm.selectedIndex = 1
            mealStyleVm.tableView.reloadData()
        }
        updateEatStyleSkipIfNeeded()
        
        let skipImportantAndPace = shouldSkipImportantAndPaceSteps()
        skipStepsOne = skipImportantAndPace ? 2 : 0
        if skipImportantAndPace {
            skipStepsNine = false
        } else {
            applySkipNineLayout(isSkip: draftBool(draft["skipStepsNine"]))
        }
        updateKetoHistorySkipIfNeeded()
        
        shouldResumeFromEatStyleForNonVip = draftBool(draft["shouldResumeFromEatStyleForNonVip"])
        let savedIndex = draftInt(draft["currentIndex"], fallback: 0)
        let maxSavedIndex = draftInt(draft["maxReachedIndex"], fallback: savedIndex)
        let maxIndex = max(Int(round((scrollViewBase.contentSize.width / SCREEN_WIDHT) - 1)), 0)
        let shouldForceResumeFromEatStyle = shouldResumeFromEatStyleForNonVip && UserInfoModel.shared.vipModel.status != .valid
        let resumeActualIndex = max(savedIndex, maxSavedIndex)
        let targetIndex = shouldForceResumeFromEatStyle ? eatStyleVisibleIndex() : displayStepIndex(for: resumeActualIndex)
        let bodyFatVisibleIndex = displayStepIndex(for: 5)
        let clampedTargetIndex = hasValidBodyFatSelection ? targetIndex : min(targetIndex, bodyFatVisibleIndex)
        currentIndex = min(max(clampedTargetIndex, 0), maxIndex)
        updateMaxReachedIndexIfNeeded(withVisibleIndex: currentIndex)
        scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(currentIndex), y: 0), animated: false)
        updateNextButtonForCurrentStep(animated: false)
        syncProfileFromUserInfoIfNeeded(applyDefaultValues: false)
    }
    
    func clearDraftIfNeeded() {
        guard let key = draftStorageKey() else {
            return
        }
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    func sendDietUpsertRequest() {
        if isUploadingDietProfile {
            return
        }
        isUploadingDietProfile = true
        let flavorPreferences = flavorVM.selectedIndex == 4 ? 1 : (flavorVM.selectedIndex + 1)
        let goalImportance = importantVm.selectedIndex < 0 ? 4 : (importantVm.selectedIndex == 3 ? 1 : importantVm.selectedIndex + 1)
        var param = ["userGoal":goalVm.buildUserGoal(),
                     "birthYear":QuestinonaireMsgModel.shared.birthYear,
                     "gender":QuestinonaireMsgModel.shared.sex,
                     "currentWeight":QuestinonaireMsgModel.shared.weight,
                     "targetWeight":QuestinonaireMsgModel.shared.targetWeight,
                     "height":QuestinonaireMsgModel.shared.height,
                     "bodyFat":QuestinonaireMsgModel.shared.bodyFat,
                     "dailyActivityLevel":QuestinonaireMsgModel.shared.events,
                     "goalImportance":"\(goalImportance)",
                     "goalTimeline":QuestinonaireMsgModel.shared.paceLevel,
                     "foodRestrictions":allergyVm.buildFoodRestrictions(),
                     "dietBarriers":barrierVm.buildDietBarriers(),
                     "dailyMeals":mealStyleVm.selectedIndex == 1 ? "4" : "3",
                     "dietType":eatStyleVm.selectedIndex + 1,
                     "dietMethodExperience":ketoHistoryVm.selectedIndex + 1,
                     "flavorPreferences":flavorPreferences] as [String : Any]
        
//        if importantVm.selectedIndex < 0 {
//            param.removeValue(forKey: "goalImportance")
//        }
        if ketoHistoryVm.selectedIndex + 1 <= 0{
            param.removeValue(forKey: "dietMethodExperience")
        }
        
        DLLog(message: "sendDietUpsertRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_upsert, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            self.isUploadingDietProfile = false
        }
        
        shouldResumeFromEatStyleForNonVip = true
        shouldSkipDraftPersistence = false
        persistDraftIfNeeded()
        let vc = ElaProVC()
        vc.shouldClearDietPlanCreateDraftOnPurchaseSuccess = true
//            vc.param = param
        self.navigationController?.pushViewController(vc, animated: true)
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
            QuestinonaireMsgModel.shared.caloriesNumber = "\(dataString ?? "0")"
            QuestinonaireMsgModel.shared.caloriesNumberFromServer = "\(dataString ?? "0")"
            self.skipMealStyle = dataString?.doubleValue ?? 0 > 3000
            if self.skipMealStyle {
                self.mealStyleVm.selectedIndex = 1
                QuestinonaireMsgModel.shared.mealsPerDay = "4"
                self.mealStyleVm.tableView.reloadData()
            } else if self.mealStyleVm.selectedIndex >= 0 {
                QuestinonaireMsgModel.shared.mealsPerDay = self.mealStyleVm.selectedIndex == 1 ? "4" : "3"
            }
            self.updateEatStyleSkipIfNeeded()
            self.persistDraftIfNeeded()
//            let targetOffsetX = SCREEN_WIDHT * CGFloat(8)
//            let maxOffsetX = max(self.scrollViewBase.contentSize.width - self.scrollViewBase.bounds.width, 0)
//            let finalOffsetX = min(targetOffsetX, maxOffsetX)
//            self.currentIndex = Int(round(finalOffsetX / SCREEN_WIDHT))
//            self.scrollViewBase.setContentOffset(CGPoint(x: finalOffsetX, y: 0), animated: true)
//            self.updateNextButtonForCurrentStep(animated: true)
        }
    }
}

private extension DietPlanCreateVC {
    func handleDraftRestoreFlow() {
        let profileGender = UserInfoModel.shared.gender
        let hasValidProfileGender = profileGender == "1" || profileGender == "2"

        guard let key = draftStorageKey(),
              let draft = UserDefaults.standard.dictionary(forKey: key) else {
            resetQuestionnaireForFreshStart()
            return
        }

        if hasValidProfileGender {
            let draftGender = draftString(draft["sex"])
            if !draftGender.isEmpty && draftGender != profileGender {
                UserDefaults.standard.removeObject(forKey: key)
                resetQuestionnaireForFreshStart()
                return
            }
        }

        restoreDraftIfNeeded()
    }

    func resetQuestionnaireForFreshStart(preservedSex: String? = nil, startVisibleIndex: Int = 0) {
        QuestinonaireMsgModel.shared.clearMsg()
        currentIndex = max(0, startVisibleIndex)
        maxReachedIndex = currentIndex
        skipStepsOne = 0
        skipStepsNine = false
        skipMealStyle = false
        skipKetoHistory = false
        shouldResumeFromEatStyleForNonVip = false

        resetDynamicStepLayoutToDefault()
        resetQuestionnaireSelectionState()

        if preservedSex == "1" || preservedSex == "2" {
            QuestinonaireMsgModel.shared.sex = preservedSex ?? ""
            applyDefaultPhysicalValuesForCurrentSexIfNeeded()
        } else {
            syncProfileFromUserInfoIfNeeded(applyDefaultValues: true)
        }

        applySexSelectionUI()
        bodyfatVm.updateScrollView()
        updateKetoHistoryTitleIfNeeded()
        scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(currentIndex), y: 0), animated: false)
        updateNextButtonForCurrentStep(animated: false)
    }

    func resetDraftAfterManualSexChangeIfNeeded() {
        let sexStepIndex = displayStepIndex(for: 1)
        guard !shouldSkipSexStep,
              currentIndex == sexStepIndex,
              maxReachedIndex > sexStepIndex,
              let key = draftStorageKey(),
              let draft = UserDefaults.standard.dictionary(forKey: key) else {
            return
        }

        let currentSex = QuestinonaireMsgModel.shared.sex
        let draftGender = draftString(draft["sex"])
        guard (currentSex == "1" || currentSex == "2"),
              (draftGender == "1" || draftGender == "2"),
              currentSex != draftGender else {
            return
        }

        UserDefaults.standard.removeObject(forKey: key)
        resetQuestionnaireForFreshStart(preservedSex: currentSex, startVisibleIndex: sexStepIndex)
    }

    func resetDynamicStepLayoutToDefault() {
        stepsArray = displayedStepsArray(for: [5,6,6])
        importantVm.isHidden = false
        paceVm.isHidden = false
        mealStyleVm.isHidden = false
        ketoHistoryVm.isHidden = false
        applyIntroStepOffsetLayout()
        scrollViewBase.contentSize = CGSize(width: contentWidth(forBasePageCount: 17), height: 0)
    }

    func resetQuestionnaireSelectionState() {
        isGoalStepEnabled = false
        goalVm.selectedIndexes = []
        goalVm.selectedIndex = -1
        goalVm.refreshListUI()

        eventsVm.selectedIndex = -1
        eventsVm.tableView.reloadData()

        importantVm.selectedIndex = -1
        importantVm.tableView.reloadData()

        paceVm.restoreLevelFromDraft(modelValue: "2")

        allergyVm.selectedIndexes = []
        allergyVm.selectedIndex = -1
        allergyVm.applyGoalFilter()
        allergyVm.refreshListUI()

        barrierVm.selectedIndexes = []
        barrierVm.selectedIndex = -1
        barrierVm.refreshListUI()

        mealStyleVm.selectedIndex = -1
        mealStyleVm.tableView.reloadData()

        eatStyleVm.selectedIndex = -1
        eatStyleVm.refreshListUI()

        ketoHistoryVm.clearSelection()

        flavorVM.selectedIndexes = []
        flavorVM.selectedIndex = -1
        flavorVM.refreshListUI()
    }

    func applyDefaultPhysicalValuesForCurrentSexIfNeeded() {
        guard QuestinonaireMsgModel.shared.sex == "1" || QuestinonaireMsgModel.shared.sex == "2" else {
            return
        }
        let isMale = QuestinonaireMsgModel.shared.sex == "1"
        if QuestinonaireMsgModel.shared.height.isEmpty {
            heightVm.applyDefaultHeight(isMale ? 170 : 160)
        }
        if QuestinonaireMsgModel.shared.weight.isEmpty {
            weightVm.applyDefaultWeight(integer: isMale ? 70 : 50)
        }
        targetWeightVm.syncWithCurrentWeight(Double(QuestinonaireMsgModel.shared.weight) ?? (isMale ? 70 : 50), syncTarget: true)
    }

    func draftStorageKey() -> String? {
        let uid = UserInfoModel.shared.uId.trimmingCharacters(in: .whitespacesAndNewlines)
        if uid.isEmpty {
            return nil
        }
        return draftKeyPrefix + uid
    }
    
    func buildDraftPayload() -> [String: Any] {
        return [
            "currentIndex": persistedStepIndex(forVisibleIndex: currentIndex),
            "maxReachedIndex": persistedStepIndex(forVisibleIndex: max(maxReachedIndex, currentIndex)),
            "skipStepsOne": skipStepsOne,
            "skipStepsNine": skipStepsNine,
            "skipMealStyle": skipMealStyle,
            "skipKetoHistory": skipKetoHistory,
            "shouldResumeFromEatStyleForNonVip": shouldResumeFromEatStyleForNonVip,
            "goalSelectedIndexes": Array(goalVm.selectedIndexes).sorted(),
            "sex": QuestinonaireMsgModel.shared.sex,
            "birthYear": QuestinonaireMsgModel.shared.birthYear,
            "goal": QuestinonaireMsgModel.shared.goal,
            "height": QuestinonaireMsgModel.shared.height,
            "weight": QuestinonaireMsgModel.shared.weight,
            "targetWeight": QuestinonaireMsgModel.shared.targetWeight,
            "bodyFat": QuestinonaireMsgModel.shared.bodyFat,
            "bodyFatSelectIndex": bodyfatVm.selectIndex,
            "events": QuestinonaireMsgModel.shared.events,
            "eventsSelectedIndex": eventsVm.selectedIndex,
            "importantSelectedIndex": importantVm.selectedIndex,
            "paceLevel": QuestinonaireMsgModel.shared.paceLevel,
            "foodAllergy": QuestinonaireMsgModel.shared.foodAllergy,
            "allergySelectedIndexes": Array(allergyVm.selectedIndexes).sorted(),
            "foodBarrier": QuestinonaireMsgModel.shared.foodBarrier,
            "barrierSelectedIndexes": Array(barrierVm.selectedIndexes).sorted(),
            "mealStyleSelectedIndex": mealStyleVm.selectedIndex,
            "eatStyleSelectedIndex": eatStyleVm.selectedIndex,
            "dietHistoryType": QuestinonaireMsgModel.shared.dietHistoryType,
            "ketoHistorySelectedIndex": ketoHistoryVm.selectedIndex,
            "foodTasteType": QuestinonaireMsgModel.shared.foodTasteType,
            "flavorSelectedIndexes": Array(flavorVM.selectedIndexes).sorted(),
            "caloriesNumber": QuestinonaireMsgModel.shared.caloriesNumber,
            "caloriesNumberFromServer": QuestinonaireMsgModel.shared.caloriesNumberFromServer
        ]
    }
    
    func hasDraftProgress(_ draft: [String: Any]) -> Bool {
        if (draft["currentIndex"] as? Int ?? 0) > 0 {
            return true
        }
        let hasText = [
            draftString(draft["sex"]),
            draftString(draft["birthYear"]),
            draftString(draft["goal"]),
            draftString(draft["height"]),
            draftString(draft["weight"]),
            draftString(draft["targetWeight"]),
            draftString(draft["bodyFat"]),
            draftString(draft["events"]),
            draftString(draft["foodAllergy"]),
            draftString(draft["foodBarrier"]),
            draftString(draft["foodTasteType"])
        ].contains { !$0.isEmpty }
        if hasText {
            return true
        }
        if !(goalVm.selectedIndexes.isEmpty &&
             allergyVm.selectedIndexes.isEmpty &&
             barrierVm.selectedIndexes.isEmpty &&
             flavorVM.selectedIndexes.isEmpty) {
            return true
        }
        return eventsVm.selectedIndex >= 0 ||
               importantVm.selectedIndex >= 0 ||
               mealStyleVm.selectedIndex >= 0 ||
               eatStyleVm.selectedIndex >= 0 ||
               ketoHistoryVm.selectedIndex >= 0 ||
               bodyfatVm.selectIndex >= 0
    }
    
    func applySexSelectionUI() {
        if QuestinonaireMsgModel.shared.sex == "1" {
            sexVm.sexManButton.backgroundColor = .THEME
            sexVm.sexManIcon.setImgLocal(imgName: "sex_icon_man")
            sexVm.sexManLabel.textColor = .COLOR_TEXT_WHITE
            
            sexVm.sexFeManButton.backgroundColor = .COLOR_BG_BLACK_04
            sexVm.sexFeManIcon.setImgLocal(imgName: "sex_icon_feman_normal")
            sexVm.sexFeManLabel.textColor = WHColor_16(colorStr: "595959")
        } else if QuestinonaireMsgModel.shared.sex == "2" {
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
    
    func applySkipNineLayout(isSkip: Bool) {
        let off = skipMealStyle ? SCREEN_WIDHT : 0
        skipStepsNine = isSkip
        if isSkip {
            paceVm.isHidden = true
            if skipMealStyle {
                scrollViewBase.contentSize = CGSize(width: contentWidth(forBasePageCount: 15), height: 0)
                stepsArray = displayedStepsArray(for: [5,5,5])
            } else {
                scrollViewBase.contentSize = CGSize(width: contentWidth(forBasePageCount: 16), height: 0)
                stepsArray = displayedStepsArray(for: [5,5,6])
            }
            let firstCenterX = paceVm.center.x
            allergyVm.center = CGPoint(x: firstCenterX, y: SCREEN_HEIGHT * 0.5)
            barrierVm.center = CGPoint(x: firstCenterX + SCREEN_WIDHT, y: SCREEN_HEIGHT * 0.5)
            adviceVm.center = CGPoint(x: firstCenterX + SCREEN_WIDHT * 2, y: SCREEN_HEIGHT * 0.5)
            mealStyleVm.center = CGPoint(x: firstCenterX + SCREEN_WIDHT * 3, y: SCREEN_HEIGHT * 0.5)
            eatStyleVm.center = CGPoint(x: firstCenterX + SCREEN_WIDHT * 4 - off, y: SCREEN_HEIGHT * 0.5)
            ketoHistoryVm.center = CGPoint(x: firstCenterX + SCREEN_WIDHT * 5 - off, y: SCREEN_HEIGHT * 0.5)
            flavorVM.center = CGPoint(x: firstCenterX + SCREEN_WIDHT * 6 - off, y: SCREEN_HEIGHT * 0.5)
        } else {
            paceVm.isHidden = false
            if skipMealStyle {
                scrollViewBase.contentSize = CGSize(width: contentWidth(forBasePageCount: 16), height: 0)
                stepsArray = displayedStepsArray(for: [5,5,6])
            } else {
                scrollViewBase.contentSize = CGSize(width: contentWidth(forBasePageCount: 17), height: 0)
                stepsArray = displayedStepsArray(for: [5,6,6])
            }
            let firstCenterX = pageCenterX(forOriginalPage: 10.5)
            allergyVm.center = CGPoint(x: firstCenterX, y: SCREEN_HEIGHT * 0.5)
            barrierVm.center = CGPoint(x: firstCenterX + SCREEN_WIDHT, y: SCREEN_HEIGHT * 0.5)
            adviceVm.center = CGPoint(x: firstCenterX + SCREEN_WIDHT * 2, y: SCREEN_HEIGHT * 0.5)
            mealStyleVm.center = CGPoint(x: firstCenterX + SCREEN_WIDHT * 3, y: SCREEN_HEIGHT * 0.5)
            eatStyleVm.center = CGPoint(x: firstCenterX + SCREEN_WIDHT * 4 - off, y: SCREEN_HEIGHT * 0.5)
            ketoHistoryVm.center = CGPoint(x: firstCenterX + SCREEN_WIDHT * 5 - off, y: SCREEN_HEIGHT * 0.5)
            flavorVM.center = CGPoint(x: firstCenterX + SCREEN_WIDHT * 6 - off, y: SCREEN_HEIGHT * 0.5)
        }
        updateKetoHistorySkipIfNeeded()
    }

    func displayedStepsArray(for baseSteps: [Int]) -> [Int] {
        guard !skippedIntroStepIndexes.isEmpty, !baseSteps.isEmpty else { return baseSteps }
        var adjusted = baseSteps
        adjusted[0] = max(1, adjusted[0] - skippedIntroStepIndexes.count)
        return adjusted
    }

    func displayStepIndex(for actualIndex: Int) -> Int {
        guard actualIndex > 0 else { return actualIndex }
        let skippedCount = skippedIntroStepIndexes.filter { $0 < actualIndex }.count
        return max(0, actualIndex - skippedCount)
    }

    var skippedIntroStepIndexes: [Int] {
        var indexes: [Int] = []
        if shouldSkipSexStep {
            indexes.append(1)
        }
        if shouldSkipBirthdayStep {
            indexes.append(2)
        }
        return indexes
    }

    func applyIntroStepOffsetLayout() {
        setPageOriginX(goalVm, originalIndex: 0)
        setPageOriginX(sexVm, originalIndex: 1)
        setPageOriginX(birthdayVm, originalIndex: 2)
        setPageOriginX(heightVm, originalIndex: 3)
        setPageOriginX(weightVm, originalIndex: 4)
        setPageOriginX(bodyfatVm, originalIndex: 5)
        setPageOriginX(targetWeightVm, originalIndex: 6)
        setPageOriginX(eventsVm, originalIndex: 7)
        setPageOriginX(importantVm, originalIndex: 8)
        setPageOriginX(paceVm, originalIndex: 9)
        setPageOriginX(allergyVm, originalIndex: 10)
        setPageOriginX(barrierVm, originalIndex: 11)
        setPageOriginX(adviceVm, originalIndex: 12)
        setPageOriginX(mealStyleVm, originalIndex: 13)
        setPageOriginX(eatStyleVm, originalIndex: 14)
        setPageOriginX(ketoHistoryVm, originalIndex: 15)
        setPageOriginX(flavorVM, originalIndex: 16)
    }

    func setPageOriginX(_ view: UIView, originalIndex: Int) {
        var frame = view.frame
        frame.origin.x = SCREEN_WIDHT * CGFloat(displayStepIndex(for: originalIndex))
        view.frame = frame
    }

    func contentWidth(forBasePageCount pageCount: Int) -> CGFloat {
        SCREEN_WIDHT * CGFloat(max(1, pageCount - skippedIntroStepIndexes.count))
    }

    func pageCenterX(forOriginalPage page: CGFloat) -> CGFloat {
        SCREEN_WIDHT * (page - CGFloat(skippedIntroStepIndexes.count))
    }

    func eatStyleVisibleIndex() -> Int {
        Int(round(eatStyleVm.frame.minX / SCREEN_WIDHT))
    }

    func persistedStepIndex(forVisibleIndex visibleIndex: Int) -> Int {
        var originalIndex = visibleIndex
        if shouldSkipSexStep && visibleIndex >= 1 {
            originalIndex += 1
        }
        let birthdayVisibleIndex = shouldSkipSexStep ? 1 : 2
        if shouldSkipBirthdayStep && visibleIndex >= birthdayVisibleIndex {
            originalIndex += 1
        }
        return originalIndex
    }

    func updateMaxReachedIndexIfNeeded(withVisibleIndex visibleIndex: Int) {
        maxReachedIndex = max(maxReachedIndex, visibleIndex)
    }

    func resolvedDraftGender(from draft: [String: Any]) -> String {
        let draftGender = draftString(draft["sex"])
        if shouldSkipSexStep {
            let profileGender = UserInfoModel.shared.gender
            if profileGender == "1" || profileGender == "2" {
                return profileGender
            }
        }
        if draftGender == "1" || draftGender == "2" {
            return draftGender
        }
        return QuestinonaireMsgModel.shared.sex
    }

    @discardableResult
    func restoreBodyFatSelection(from draft: [String: Any], gender: String) -> Bool {
        guard gender == "1" || gender == "2" else {
            QuestinonaireMsgModel.shared.bodyFat = ""
            bodyfatVm.selectIndex = -1
            bodyfatVm.refreshSelectStatus()
            bodyfatVm.selectStateChangeBlock?(false)
            return false
        }

        let bodyFatOptions = gender == "1" ? bodyfatVm.dataArray : bodyfatVm.dataFemanArray
        let savedBodyFat = draftString(draft["bodyFat"]).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !savedBodyFat.isEmpty else {
            QuestinonaireMsgModel.shared.bodyFat = ""
            bodyfatVm.selectIndex = -1
            bodyfatVm.refreshSelectStatus()
            bodyfatVm.selectStateChangeBlock?(false)
            return false
        }

        if let matchedIndex = bodyFatOptions.firstIndex(where: { ($0["data"] ?? "") == savedBodyFat }) {
            bodyfatVm.selectIndex = matchedIndex
            bodyfatVm.refreshSelectStatus()
            bodyfatVm.updateBodyFatValue(index: matchedIndex)
            bodyfatVm.selectStateChangeBlock?(true)
            return true
        }

        QuestinonaireMsgModel.shared.bodyFat = ""
        bodyfatVm.selectIndex = -1
        bodyfatVm.refreshSelectStatus()
        bodyfatVm.selectStateChangeBlock?(false)
        return false
    }

    func syncProfileFromUserInfoIfNeeded(applyDefaultValues: Bool) {
        if shouldSkipSexStep {
            let gender = UserInfoModel.shared.gender
            QuestinonaireMsgModel.shared.sex = gender
            applySexSelectionUI()

            if applyDefaultValues {
                if QuestinonaireMsgModel.shared.height.isEmpty {
                    heightVm.applyDefaultHeight(gender == "1" ? 170 : 160)
                }
                if QuestinonaireMsgModel.shared.weight.isEmpty {
                    weightVm.applyDefaultWeight(integer: gender == "1" ? 70 : 50)
                }
            }
        }

        if shouldSkipBirthdayStep {
            let profileBirthday = UserInfoModel.shared.birthYear.trimmingCharacters(in: .whitespacesAndNewlines)
            if !profileBirthday.isEmpty {
                let birthYear = profileBirthday.contains("-")
                ? Date().changeDateFormatter(dateString: profileBirthday, formatter: "yyyy-MM-dd", targetFormatter: "yyyy")
                : profileBirthday
                QuestinonaireMsgModel.shared.birthYear = birthYear
            }
        }
    }
    
    func draftString(_ value: Any?, fallback: String = "") -> String {
        if let text = value as? String {
            return text
        }
        if let number = value as? NSNumber {
            return number.stringValue
        }
        return fallback
    }
    
    func draftInt(_ value: Any?, fallback: Int) -> Int {
        if let intValue = value as? Int {
            return intValue
        }
        if let number = value as? NSNumber {
            return number.intValue
        }
        if let text = value as? String, let intValue = Int(text) {
            return intValue
        }
        return fallback
    }
    
    func draftBool(_ value: Any?) -> Bool {
        if let boolValue = value as? Bool {
            return boolValue
        }
        if let number = value as? NSNumber {
            return number.boolValue
        }
        if let text = value as? String {
            return (text as NSString).boolValue
        }
        return false
    }
    
    func draftIntArray(_ value: Any?) -> [Int] {
        let array = value as? [Any] ?? []
        return array.compactMap { item in
            if let intValue = item as? Int {
                return intValue
            }
            if let number = item as? NSNumber {
                return number.intValue
            }
            if let text = item as? String {
                return Int(text)
            }
            return nil
        }
    }
    
    func normalizedSingleSelectionIndex(preferred: Int, fallback: Int, count: Int) -> Int {
        if preferred >= 0 && preferred < count {
            return preferred
        }
        if fallback >= 0 && fallback < count {
            return fallback
        }
        return -1
    }
    
    func csvItems(_ text: String) -> [String] {
        return text
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    func restoredIndexes(csvText: String, rawIndexes: [Int], dataArray: [String]) -> Set<Int> {
        let titles = csvItems(csvText)
        if !titles.isEmpty {
            var indexes = Set<Int>()
            for title in titles {
                if let index = dataArray.firstIndex(of: title) {
                    indexes.insert(index)
                }
            }
            return indexes
        }
        return Set(rawIndexes.filter { $0 >= 0 && $0 < dataArray.count })
    }

}

extension DietPlanCreateVC {
    static func clearStoredDraftForCurrentUser() {
        let uid = UserInfoModel.shared.uId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !uid.isEmpty else {
            return
        }
        UserDefaults.standard.removeObject(forKey: "diet_plan_create_draft_" + uid)
    }
}
