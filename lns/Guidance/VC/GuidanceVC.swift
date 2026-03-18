//
//  GuidanceVC.swift
//  lns
//  新用户引导
//  Created by LNS2 on 2026/3/17.
//

import MCToast
import AuthenticationServices
import UMCommon

class GuidanceVC: WHBaseViewVC {
    
    var currentIndex: Int = 0
    private let totalSteps = 18
    private var nextButtonEnableWorkItem: DispatchWorkItem?
    private var isShowingMealsSummary = false
    private var isShowingStrengthTrainingSummary = false
    
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
            if self.isShowingMealsSummary || self.isShowingStrengthTrainingSummary {
                return
            }
            if self.currentIndex == 0 {
                self.backTapAction()
                return
            }
            self.moveToStep(index: self.currentIndex - 1, animated: true)
        }
        return vm
    }()
    lazy var stepsArray: [Int] = {
        return [7,7,8]
    }()
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
            self?.nextButtonTapAction()
//            self?.updateNextButtonForCurrentStep()
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
            self?.hideMealsSummary()
            self?.mealsAdjustVm.refreshSelectionFromModel()
            self?.moveToStep(index: 10, animated: true)
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
            self?.hideStrengthTrainingSummary()
            self?.sendBasicRequest()
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
}


extension GuidanceVC{
    @objc func nextButtonTapAction() {
        switch currentIndex {
        case 2:
            moveToStep(index: 3, animated: true)
        case 3:
            moveToStep(index: 4, animated: true)
        case 4:
            birthdayVm.getBirthDayData()
            moveToStep(index: 5, animated: true)
        case 5:
            weightVm.getWeightValue()
            moveToStep(index: 6, animated: true)
        case 6:
            moveToStep(index: 7, animated: true)
        case 7:
            moveToStep(index: 8, animated: true)
        case 8:
            moveToStep(index: 9, animated: true)
        case 9:
            mealsSummaryVm.refreshContentFromModel()
            showMealsSummary()
        case 10:
            moveToStep(index: 11, animated: true)
        case 11:
            moveToStep(index: 12, animated: true)
        case 12:
            moveToStep(index: 13, animated: true)
        case 13:
            strengthTrainingSummaryVm.refreshContentFromModel()
            showStrengthTrainingSummary()
        case 14:
            let caloriesText = caloriesResultBaseVm.caloriesTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"
            if caloriesText.floatValue < 100 {
                presentAlertVcNoAction(title: "请输入合理的热量摄入值", viewController: self)
                return
            }
            QuestinonaireMsgModel.shared.caloriesNumber = "\(Int(caloriesText.floatValue))"
            caloriesResultBaseVm.caloriesTextField.resignFirstResponder()
            moveToStep(index: 15, animated: true)
        case 15:
            moveToStep(index: 16, animated: true)
        case 16:
            moveToStep(index: 17, animated: true)
        case 17:
            break
        default:
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

    func moveToStep(index: Int, animated: Bool) {
        let targetIndex = max(0, min(index, totalSteps - 1))
        if isShowingMealsSummary {
            hideMealsSummary()
        }
        if isShowingStrengthTrainingSummary {
            hideStrengthTrainingSummary()
        }
        currentIndex = targetIndex
        scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(targetIndex), y: 0), animated: animated)
        naviVm.updateStep(steps: stepsArray, currentStep: targetIndex)
        naviVm.backButton.isEnabled = true
        updateNextButtonForCurrentStep()

        if currentIndex == 2 {
            progressChartVm.chart.startGradientAnimation()
        }
    }

    func updateNextButtonForCurrentStep() {
        nextButtonEnableWorkItem?.cancel()
        nextButtonEnableWorkItem = nil

        switch currentIndex {
        case 0, 1:
            nextButton.isHidden = true
            nextButton.isEnabled = false
        case 2:
            nextButton.isHidden = false
            nextButton.isEnabled = false
        case 3:
            nextButton.isHidden = true
            nextButton.isEnabled = true//fixedTargetVm.hasSelection
        case 4, 5, 6:
            nextButton.isHidden = false
            nextButton.isEnabled = true
        case 7:
            nextButton.isHidden = false
            nextButton.isEnabled = bodyfatVm.selectIndex >= 0
        case 8:
            nextButton.isHidden = false
            nextButton.isEnabled = takeoutFrequencyVm.hasSelection
        case 9:
            nextButton.isHidden = false
            nextButton.isEnabled = mealsPerDayVm.hasSelection
        case 10:
            nextButton.isHidden = false
            nextButton.isEnabled = mealsAdjustVm.hasSelection
        case 11:
            nextButton.isHidden = false
            nextButton.isEnabled = exerciseCaloriesRecordVm.hasSelection
        case 12:
            nextButton.isHidden = false
            nextButton.isEnabled = cardioFrequencyVm.hasSelection
        case 13:
            nextButton.isHidden = false
            nextButton.isEnabled = strengthTrainingFrequencyVm.hasSelection
        case 14:
            nextButton.isHidden = false
            nextButton.isEnabled = true
        case 15:
            nextButton.isHidden = false
            nextButton.isEnabled = true
        case 16:
            nextButton.isHidden = false
            nextButton.isEnabled = goalVm.selectIndex >= 0
        case 17:
            nextButton.isHidden = false
            nextButton.isEnabled = goalBarrierVm.hasSelection
        default:
            nextButton.isHidden = true
            nextButton.isEnabled = false
        }
    }

    func handleProgressChartAnimationFinished() {
        guard currentIndex == 2 else { return }
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self, self.currentIndex == 2 else { return }
            self.nextButton.isEnabled = true
        }
        nextButtonEnableWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }

    func showMealsSummary() {
        isShowingMealsSummary = true
        mealsSummaryVm.isHidden = false
        naviVm.isHidden = true
        nextButton.isHidden = true
        nextButton.isEnabled = false
    }

    func hideMealsSummary() {
        guard isShowingMealsSummary else { return }
        isShowingMealsSummary = false
        mealsSummaryVm.isHidden = true
        naviVm.isHidden = false
    }

    func showStrengthTrainingSummary() {
        isShowingStrengthTrainingSummary = true
        strengthTrainingSummaryVm.isHidden = false
        naviVm.isHidden = true
        nextButton.isHidden = true
        nextButton.isEnabled = false
    }

    func hideStrengthTrainingSummary() {
        guard isShowingStrengthTrainingSummary else { return }
        isShowingStrengthTrainingSummary = false
        strengthTrainingSummaryVm.isHidden = true
        naviVm.isHidden = false
        updateNextButtonForCurrentStep()
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

    func sendBasicRequest() {
        QuestinonaireMsgModel.shared.events = estimatedDailyActivityLevel()
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
                self.moveToStep(index: 14, animated: true)
            }
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
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(scrollViewBase)
        view.addSubview(naviVm)
        view.addSubview(nextButton)
        view.addSubview(mealsSummaryVm)
        view.addSubview(strengthTrainingSummaryVm)
        view.addSubview(loginAlertVm)
        view.addSubview(notRegistVm)
        view.addSubview(bodyFatAlertVm)
        view.addSubview(katchAlertVm)
        
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.isScrollEnabled = false
        scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT * CGFloat(totalSteps), height: SCREEN_HEIGHT)
        
        scrollViewBase.addSubview(sexVm)
        scrollViewBase.addSubview(dietRecordVm)
        scrollViewBase.addSubview(progressChartVm)
        scrollViewBase.addSubview(fixedTargetVm)
        scrollViewBase.addSubview(birthdayVm)
        scrollViewBase.addSubview(weightVm)
        scrollViewBase.addSubview(heightVm)
        scrollViewBase.addSubview(bodyfatVm)
        scrollViewBase.addSubview(takeoutFrequencyVm)
        scrollViewBase.addSubview(mealsPerDayVm)
        scrollViewBase.addSubview(mealsAdjustVm)
        scrollViewBase.addSubview(exerciseCaloriesRecordVm)
        scrollViewBase.addSubview(cardioFrequencyVm)
        scrollViewBase.addSubview(strengthTrainingFrequencyVm)
        scrollViewBase.addSubview(caloriesResultBaseVm)
        scrollViewBase.addSubview(caloriesResultExplainVm)
        scrollViewBase.addSubview(goalVm)
        scrollViewBase.addSubview(goalBarrierVm)
        
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
    }
}

//MARK: 网络请求
extension GuidanceVC{
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
