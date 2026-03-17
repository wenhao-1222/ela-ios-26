//
//  DietPlanCreateSecondVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/16.
//


class DietPlanCreateSecondVC: WHBaseViewVC {
    
    var currentIndex: Int = 0
    private var isDateStepEnabled = false
    private var isShowingManualTargetEditor = false
    private var shouldPreserveManualTargetCalories = false
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.fd_interactivePopDisabled = false
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendDietMsgRequest()
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
        return [3,3,4]
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
    lazy var dateVm: DietPlanCreateDateVM = {
        let vm = DietPlanCreateDateVM.init(frame: .zero)
        vm.nextButtonEnableChangeBlock = { [weak self] isEnabled in
            self?.isDateStepEnabled = isEnabled
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var weightVm: DietPlanCreateWeightVM = {
        let vm = DietPlanCreateWeightVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "你的最新体重是？"
        vm.weightChangedBlock = { [weak self] weight in
            self?.targetWeightVm.syncWithCurrentWeight(weight, syncTarget: false)
        }
        return vm
    }()
    lazy var targetWeightVm: DietPlanCreateTargetWeightVM = {
        let vm = DietPlanCreateTargetWeightVM(frame: CGRect(x: SCREEN_WIDHT * 2, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "你的目标体重需要改变吗？"
        return vm
    }()
    lazy var eventsVm: DietPlanCreateEventsVM = {
        let vm = DietPlanCreateEventsVM.init(frame: CGRect(x: SCREEN_WIDHT * 3, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "你的每日活动量有变动吗？"
        vm.selectedBlock = {[weak self] in
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var paceVm: DietPlanCreatePaceSecondVM = {
        let vm = DietPlanCreatePaceSecondVM(frame: CGRect(x: SCREEN_WIDHT * 4, y: 0, width: 0, height: 0))
//        vm.titleLabel.text = "你的增肌节奏需要改变吗？"
        return vm
    }()
    lazy var recommendIntakeVm: DietPlanCreateRecommendIntakeVM = {
        let vm = DietPlanCreateRecommendIntakeVM(frame: CGRect(x: SCREEN_WIDHT * 5, y: 0, width: 0, height: 0))
        vm.editTargetBlock = { [weak self] in
            self?.showManualTargetEditor()
        }
        return vm
    }()
    lazy var eatStyleVm: DietPlanCreateEatStyleSecondVM = {
        let vm = DietPlanCreateEatStyleSecondVM(frame: CGRect(x: SCREEN_WIDHT * 6, y: 0, width: 0, height: 0))
        vm.selectedBlock = { [weak self] in
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
//    lazy var flavorVM: DietPlanCreateFlavorVM = {
//        let vm = DietPlanCreateFlavorVM(frame: CGRect(x: SCREEN_WIDHT * 8, y: 0, width: 0, height: 0))
//        vm.selectedBlock = {[weak self] in
//            self?.syncNextButtonEnableStatus()
//        }
//        return vm
//    }()
    lazy var allergyVm: DietPlanCreateAllergyVM = {
        let vm = DietPlanCreateAllergyVM(frame: CGRect(x: SCREEN_WIDHT * 7, y: 0, width: 0, height: 0))
        vm.selectedBlock = {[weak self] in
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var specialAdjustmentVm: DietPlanCreateSpecialAdjustmentVM = {
        let vm = DietPlanCreateSpecialAdjustmentVM(frame: CGRect(x: SCREEN_WIDHT * 8, y: 0, width: 0, height: 0))
        vm.selectedBlock = { [weak self] in
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var mealModeVm: DietPlanCreateMealModeSecondVM = {
        let vm = DietPlanCreateMealModeSecondVM(frame: CGRect(x: SCREEN_WIDHT * 9, y: 0, width: 0, height: 0))
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
}

extension DietPlanCreateSecondVC{
    @objc func nextButtonTapAction() {
        goToNextStep()
    }

    func goToNextStep() {
        let maxOffsetX = max(scrollViewBase.contentSize.width - scrollViewBase.bounds.width, 0)
        let isAtLastStep = scrollViewBase.contentOffset.x >= (maxOffsetX - 0.5)
        if isAtLastStep {
            return
        }

        if currentIndex == 5 {
            syncCaloriesNumberForRecommendStepIfNeeded()
            
        }
        let nextIndex = nextStepIndex(from: currentIndex)
        if currentIndex == 3 {
            sendBasicRequest()
        }
        if currentIndex == 6{
            mealModeVm.refreshOptions(caloriesText: QuestinonaireMsgModel.shared.caloriesNumber)
        }
        let targetOffsetX = SCREEN_WIDHT * CGFloat(nextIndex)
        let finalOffsetX = min(targetOffsetX, maxOffsetX)
        currentIndex = Int(round(finalOffsetX / SCREEN_WIDHT))
        scrollViewBase.setContentOffset(CGPoint(x: finalOffsetX, y: 0), animated: true)
        updateNextButtonForCurrentStep(animated: true)
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
        switch currentIndex {
        case 0:
            nextButton.isEnabled = isDateStepEnabled
        case 6:
            nextButton.isEnabled = eatStyleVm.selectedIndex >= 0
        case 7:
            nextButton.isEnabled = allergyVm.selectedIndex >= 0
        case 8:
            nextButton.isEnabled = specialAdjustmentVm.selectedIndex >= 0
        case 9:
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
                self.scrollViewBase.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
                self.updateNextButtonForCurrentStep(animated: true)
            }
        }, completion: { _ in
            self.manualTargetVm.frame.origin.x = SCREEN_WIDHT
        })
    }

    func saveManualTarget(_ value: String) {
        self.currentIndex = self.previousStepIndex(from: self.currentIndex)
        let targetOffsetX = SCREEN_WIDHT * CGFloat(self.currentIndex)
        self.scrollViewBase.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: false)
        self.updateNextButtonForCurrentStep(animated: true)
        QuestinonaireMsgModel.shared.caloriesNumber = value
        shouldPreserveManualTargetCalories = true
        mealModeVm.refreshOptions(caloriesText: value)
        if !QuestinonaireMsgModel.shared.mealsPerDay.isEmpty {
            mealModeVm.restoreSelection(modelValue: QuestinonaireMsgModel.shared.mealsPerDay)
        }
        hideManualTargetEditor(isBack: false)
    }
}

extension DietPlanCreateSecondVC{
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(scrollViewBase)
        view.addSubview(naviVm)
        view.addSubview(nextButton)
        view.addSubview(manualTargetVm)
        
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.isScrollEnabled = false
        
        scrollViewBase.addSubview(dateVm)
        scrollViewBase.addSubview(weightVm)
        scrollViewBase.addSubview(targetWeightVm)
        scrollViewBase.addSubview(eventsVm)
        scrollViewBase.addSubview(paceVm)
        scrollViewBase.addSubview(recommendIntakeVm)
        scrollViewBase.addSubview(eatStyleVm)
        scrollViewBase.addSubview(allergyVm)
        scrollViewBase.addSubview(specialAdjustmentVm)
        scrollViewBase.addSubview(mealModeVm)
        scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT*10, height: 0)
        
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }

        updateNextButtonForCurrentStep(animated: false)
    }
}

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
            QuestinonaireMsgModel.shared.caloriesNumber = caloriesText
            QuestinonaireMsgModel.shared.caloriesNumberFromServer = caloriesText

            DispatchQueue.main.async {
                self.recommendIntakeVm.updateCalories(caloriesText)
                self.mealModeVm.refreshOptions(caloriesText: caloriesText)
                if !QuestinonaireMsgModel.shared.mealsPerDay.isEmpty {
                    self.mealModeVm.restoreSelection(modelValue: QuestinonaireMsgModel.shared.mealsPerDay)
                }
            }
        }
    }
}

extension DietPlanCreateSecondVC {
    func applyDietQuestionnaireData(_ data: NSDictionary) {
        let model = QuestinonaireMsgModel.shared

        model.sex = stringValue(from: data["gender"])
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
        model.specialAdjustmentType = defaultSpecialAdjustmentType(from: model.goal)

        applyRestoredQuestionnaireDataToCurrentSteps()
        model.printModelMsg()
    }

    func applyRestoredQuestionnaireDataToCurrentSteps() {
        if let weightValue = parsedWeight(from: QuestinonaireMsgModel.shared.weight) {
            let tenths = Int((weightValue * 10).rounded())
            let integer = tenths / 10
            let decimal = abs(tenths % 10)
            weightVm.applyDefaultWeight(integer: integer, decimal: decimal)
        }

        targetWeightVm.applyInitialValue()

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
        if !QuestinonaireMsgModel.shared.specialAdjustmentType.isEmpty {
            specialAdjustmentVm.restoreSelection(modelValue: QuestinonaireMsgModel.shared.specialAdjustmentType)
        }
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

    func defaultSpecialAdjustmentType(from goals: String) -> String {
        let normalized = goals.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else {
            return ""
        }
        let combined = normalized.lowercased()
        if combined.contains("尿酸") {
            return "1"
        }
        if combined.contains("血脂") {
            return "2"
        }
        let tokens = normalized
            .split(whereSeparator: { ",|， ".contains($0) })
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        if tokens.contains("8") {
            return "1"
        }
        if tokens.contains("7") {
            return "2"
        }
        return ""
    }
}
