//
//  DietPlanCreateVC.swift
//  lns
//  饮食计划生成页面
//  Created by LNS2 on 2026/2/24.
//  


class DietPlanCreateVC: WHBaseViewVC {
    
    var currentIndex: Int = 0
    private var isGoalStepEnabled = false
    
    var skipStepsOne = 0
    var skipStepsNine = false//是否跳过第九步  此处是由第八步决定
    var skipKetoHistory = false//是否跳过生酮历史（由饮食风格决定）
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.fd_interactivePopDisabled = true
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.fd_interactivePopDisabled = false
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.enableInteractivePopGesture()
        initUI()
        
    }
    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
        vm.backTapBlock = {[weak self] in
            guard let self = self else { return }
            if self.currentIndex == 0 {
                self.backTapAction()
                return
            }
            self.currentIndex = self.previousStepIndex(from: self.currentIndex)
            let targetOffsetX = SCREEN_WIDHT * CGFloat(self.currentIndex)
            self.scrollViewBase.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
            self.updateNextButtonForCurrentStep(animated: true)
        }
        return vm
    }()
    lazy var stepsArray: [Int] = {
        return [5,6,6]
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
            self?.moveFromSexToNextStep()
        }
        vm.femanTapBlock = {[weak self] in
            self?.moveFromSexToNextStep()
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
}

extension DietPlanCreateVC{
    @objc func nextButtonTapAction() {
        let nextIndex = nextStepIndex(from: currentIndex)
        
        if nextIndex == 5 {
            weightVm.getWeightValue()
            targetWeightVm.applyInitialValue()
            birthdayVm.getBirthDayData()
        }
        if currentIndex == 6{
            //目标体重如果是维持，则跳过 第8步“达成目标对你有多重要？”   和  第9步“你希望多快达成目标？”
            skipStepsOne = shouldSkipImportantAndPaceSteps() ? 2 : 0
        }
        
        let targetOffsetX = SCREEN_WIDHT * CGFloat(nextIndex)
        let maxOffsetX = max(scrollViewBase.contentSize.width - scrollViewBase.bounds.width, 0)
        let finalOffsetX = min(targetOffsetX, maxOffsetX)
        currentIndex = Int(round(finalOffsetX / SCREEN_WIDHT))
        scrollViewBase.setContentOffset(CGPoint(x: finalOffsetX, y: 0), animated: true)
        updateNextButtonForCurrentStep(animated: true)
        
    }

    func moveFromSexToNextStep() {
        guard currentIndex == 1 else { return }
        let nextIndex = nextStepIndex(from: currentIndex)
        let targetOffsetX = SCREEN_WIDHT * CGFloat(nextIndex)
        let maxOffsetX = max(scrollViewBase.contentSize.width - scrollViewBase.bounds.width, 0)
        let finalOffsetX = min(targetOffsetX, maxOffsetX)
        currentIndex = Int(round(finalOffsetX / SCREEN_WIDHT))
        scrollViewBase.setContentOffset(CGPoint(x: finalOffsetX, y: 0), animated: true)
        updateNextButtonForCurrentStep(animated: true)
        self.bodyfatVm.updateScrollView()
    }

    func updateNextButtonForCurrentStep(animated: Bool) {
        let shouldHideButton = (currentIndex == 1)
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
        
        let skipStepN = skipStepsNine ? 1 : 0
        let ketoIndex = 15-skipStepsOne-skipStepN
        let flavorIndex = 16-skipStepsOne-skipStepN-(skipKetoHistory ? 1 : 0)
        
        switch currentIndex {
        case 0:
            nextButton.isEnabled = isGoalStepEnabled
        case 1:
            nextButton.isEnabled = false
        case 5:
            nextButton.isEnabled = bodyfatVm.selectIndex >= 0
        case 6:
            nextButton.isEnabled = !QuestinonaireMsgModel.shared.targetWeight.isEmpty
        case 7:
            nextButton.isEnabled = eventsVm.selectedIndex >= 0
        case 8-skipStepsOne:
            nextButton.isEnabled = importantVm.selectedIndex >= 0
        case 10-skipStepsOne-skipStepN:
            nextButton.isEnabled = allergyVm.selectedIndex >= 0
        case 11-skipStepsOne-skipStepN:
            nextButton.isEnabled = barrierVm.selectedIndex >= 0
        case 13-skipStepsOne-skipStepN:
            nextButton.isEnabled = mealStyleVm.selectedIndex >= 0
        case 14-skipStepsOne-skipStepN:
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
        if index == 6 && shouldSkipImportantAndPaceSteps() {
//            return 10
        }
        if index == 8 {
            //8. 达成目标对你有多重要？
            //以下处理，只有当目标体重  非维持时，即显示 “达成目标对你有多重要？”时。否则 跳过这里的判断
            if !shouldSkipImportantAndPaceSteps(){
                if importantVm.selectedIndex == 3{
    //            1.非常重要，我愿意全力以赴   想尽快看到明显进展
    //            2.我愿意认真尝试           希望稳步取得不错的进度
    //            3.我更想循序渐进           选择更轻松、更容易坚持的方式
    //            4.我还不确定
    //            备注：如选择 4，则跳过 9（9 默认选择 2）
                    paceVm.isHidden = true
                    skipStepsNine = true
                    scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*16, height: 0)
                    self.stepsArray = [5,5,6]
                    let firstCenterX = paceVm.center.x//(SCREEN_WIDHT * 9.5)
                    allergyVm.center = CGPoint(x: firstCenterX, y: SCREEN_HEIGHT*0.5)
                    barrierVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT, y: SCREEN_HEIGHT*0.5)
                    adviceVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*2, y: SCREEN_HEIGHT*0.5)
                    mealStyleVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*3, y: SCREEN_HEIGHT*0.5)
                    eatStyleVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*4, y: SCREEN_HEIGHT*0.5)
                    ketoHistoryVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*5, y: SCREEN_HEIGHT*0.5)
                    flavorVM.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*6, y: SCREEN_HEIGHT*0.5)
                    updateKetoHistorySkipIfNeeded()
                }else{
                    if skipStepsNine{//如果之前选择的是 4
                        paceVm.isHidden = false
                        scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*17, height: 0)
                        self.stepsArray = [5,6,6]
                        let firstCenterX = (SCREEN_WIDHT * 10.5)
                        allergyVm.center = CGPoint(x: firstCenterX, y: SCREEN_HEIGHT*0.5)
                        barrierVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT, y: SCREEN_HEIGHT*0.5)
                        adviceVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*2, y: SCREEN_HEIGHT*0.5)
                        mealStyleVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*3, y: SCREEN_HEIGHT*0.5)
                        eatStyleVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*4, y: SCREEN_HEIGHT*0.5)
                        ketoHistoryVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*5, y: SCREEN_HEIGHT*0.5)
                        flavorVM.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*6, y: SCREEN_HEIGHT*0.5)
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

    func shouldSkipImportantAndPaceSteps() -> Bool {
        let currentWeightText = QuestinonaireMsgModel.shared.weight
        let targetWeightText = QuestinonaireMsgModel.shared.targetWeight
        guard
            let currentWeight = Double(currentWeightText),
            let targetWeight = Double(targetWeightText)
        else {
            return false
        }
        let isSkip = abs(currentWeight - targetWeight) < 0.05
        self.stepsArray = isSkip ? [5,5,5] : [5,6,6]
        let firstCenterX = isSkip ? (SCREEN_WIDHT * 8.5) : (SCREEN_WIDHT * 10.5)
        allergyVm.center = CGPoint(x: firstCenterX, y: SCREEN_HEIGHT*0.5)
        barrierVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT, y: SCREEN_HEIGHT*0.5)
        adviceVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*2, y: SCREEN_HEIGHT*0.5)
        mealStyleVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*3, y: SCREEN_HEIGHT*0.5)
        eatStyleVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*4, y: SCREEN_HEIGHT*0.5)
        ketoHistoryVm.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*5, y: SCREEN_HEIGHT*0.5)
        flavorVM.center = CGPoint(x: firstCenterX+SCREEN_WIDHT*6, y: SCREEN_HEIGHT*0.5)
        
        if isSkip{
            importantVm.isHidden = true
            paceVm.isHidden = true
            scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*15, height: 0)
        }else{
            importantVm.isHidden = false
            paceVm.isHidden = false
            scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*17, height: 0)
        }
        updateKetoHistorySkipIfNeeded()
        return isSkip
    }

    func shouldSkipKetoHistoryStep() -> Bool {
        guard eatStyleVm.selectedIndex >= 0,
              eatStyleVm.selectedIndex < eatStyleVm.dataArray.count else {
            return false
        }
        let styleName = eatStyleVm.dataArray[eatStyleVm.selectedIndex]["name"] ?? ""
        return styleName == "均衡，碳蛋脂平衡"
    }

    func updateKetoHistorySkipIfNeeded() {
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
}
    
extension DietPlanCreateVC{
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(scrollViewBase)
        view.addSubview(naviVm)
        view.addSubview(nextButton)
        
        view.addSubview(bodyFatAlertVm)
        
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
            self.birthdayVm.pickerView.selectRow(self.birthdayVm.defaultIndex, inComponent: 0, animated: true)
        })
        
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*17, height: 0)

        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }
        updateNextButtonForCurrentStep(animated: false)
    }
}

extension DietPlanCreateVC{
    func sendDietUpsertRequest() {
        let flavorPreferences = flavorVM.selectedIndex == 4 ? 1 : (flavorVM.selectedIndex + 1)
        var param = ["userGoal":goalVm.buildUserGoal(),
                     "birthday":QuestinonaireMsgModel.shared.birthDay,
                     "gender":QuestinonaireMsgModel.shared.sex,
                     "currentWeight":QuestinonaireMsgModel.shared.weight,
                     "targetWeight":QuestinonaireMsgModel.shared.targetWeight,
                     "height":QuestinonaireMsgModel.shared.height,
                     "bodyFat":QuestinonaireMsgModel.shared.bodyFat,
                     "dailyActivityLevel":QuestinonaireMsgModel.shared.events,
                     "goalImportance":"\(importantVm.selectedIndex+1)",
                     "goalTimeline":QuestinonaireMsgModel.shared.paceLevel,
                     "foodRestrictions":allergyVm.buildFoodRestrictions(),
                     "dietBarriers":barrierVm.buildDietBarriers(),
                     "dailyMeals":mealStyleVm.selectedIndex == 1 ? "4" : "3",
                     "dietType":eatStyleVm.selectedIndex + 1,
                     "dietMethodExperience":ketoHistoryVm.selectedIndex + 1,
                     "flavorPreferences":flavorPreferences] as [String : Any]
        
        
        DLLog(message: "sendDietUpsertRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_upsert, parameters: param) { responseObject in
            DLLog(message: "\(responseObject)")
        }
    }
}
