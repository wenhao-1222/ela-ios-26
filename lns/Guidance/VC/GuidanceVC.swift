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
    private let totalSteps = 8
    private var nextButtonEnableWorkItem: DispatchWorkItem?
    
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
            if self.currentIndex == 0 {
                self.backTapAction()
                return
            }
            self.moveToStep(index: self.currentIndex - 1, animated: true)
        }
        return vm
    }()
    lazy var stepsArray: [Int] = {
        return [8,0,0]
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
        currentIndex = targetIndex
        scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(targetIndex), y: 0), animated: animated)
        naviVm.updateStep(steps: stepsArray, currentStep: targetIndex)
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
        view.addSubview(loginAlertVm)
        view.addSubview(notRegistVm)
        view.addSubview(bodyFatAlertVm)
        
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
