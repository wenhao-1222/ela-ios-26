//
//  LNSLoginVC.swift
//  lns
//  填写问卷后的登录
//  Created by LNS2 on 2024/4/3.
//

import Foundation
import MCToast
import AuthenticationServices
import IQKeyboardManagerSwift

class LNSLoginVC : WHBaseViewVC {
    
    var hasPlan = true
    var loginType = ""
    
    var isCodeShow = false
    var edgePanChangeX = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        IQKeyboardManager.shared.enable = false
        initUI()
        NotificationCenter.default.addObserver(self, selector: #selector(wechatLoginResult), name: Notification.Name(rawValue: "wechatLogin"), object: nil)
        
        let panGes = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(popGestureAction(gesture: )))
        panGes.edges = .left
        view.addGestureRecognizer(panGes)
    }
    lazy var closeImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "login_close_img")
        img.isUserInteractionEnabled = true
        
        if self.hasPlan {
            img.isHidden = true
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(backTapAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "注册并登录"
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.textColor = WHColor_16(colorStr: "262626")
        
        return lab
    }()
    lazy var phoneVm : LoginPhoneButton = {
        let vm = LoginPhoneButton.init(frame: CGRect.init(x: kFitWidth(24), y: kFitWidth(163)+getNavigationBarHeight(), width: 0, height: 0))
        vm.controller = self
        return vm
    }()
    lazy var getCodeBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("获取验证码", for: .normal)
//        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.backgroundColor = .THEME
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(getCodeAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var orLeftLine : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        return vi
    }()
    lazy var orRightLine : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        return vi
    }()
    lazy var orLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "或者"
        
        return lab
    }()
    lazy var weChatLoginBtn : GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("使用微信账户继续登录", for: .normal)
        btn.setImage(UIImage.init(named: "login_wechat_icon"), for: .normal)
        btn.addShadow()
        btn.backgroundColor = .white
        btn.layer.cornerRadius = kFitWidth(8)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        
        btn.addTarget(self, action: #selector(wechatLoginAction), for: .touchUpInside)
        if WXApi.isWXAppInstalled() == false{
            btn.isHidden = true
        }
        return btn
    }()
    lazy var appleLoginBtn : GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("使用 Apple 账户继续登录", for: .normal)
        btn.setImage(UIImage.init(named: "login_apple_icon"), for: .normal)
        btn.addShadow()
        btn.backgroundColor = .white
        btn.layer.cornerRadius = kFitWidth(8)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        
        btn.addTarget(self, action: #selector(appleLoginAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.text = "未经你的同意，我们绝不会公开任何信息"
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = .COLOR_GRAY_BLACK_65
        
        return lab
    }()
    lazy var codeVm : LoginCodeVerifyVM = {
        let vm = LoginCodeVerifyVM.init(frame: .zero)
        vm.controller = self
        vm.hasPlan = self.hasPlan
        vm.saveSurveyBlock = {()in
            if QuestinonaireMsgModel.shared.surveytype == "noPlan"{
                self.changeRootVcToTabbar()
            }else{
                self.sendSurveySaveRequest()
            }
        }
        vm.closeBlock = {()in
            self.isCodeShow = false
        }
        vm.showBlock = {()in
            self.isCodeShow = true
        }
        vm.showInviteCodeBlock = {()in
            self.inviteCodeAlertVm.showLoginView()
        }
        return vm
    }()
    lazy var inviteCodeAlertVm: InviteCodeAlertVM = {
        let vm = InviteCodeAlertVM.init(frame: .zero)
        vm.confirmBlock = {(code)in
            self.codeVm.invideCode = code
            if code.count > 0 {
                self.codeVm.inviteCodeButton.setTitle("邀请码：\(code)", for: .normal)
            }else{
                self.codeVm.inviteCodeButton.setTitle("我有邀请码", for: .normal)
            }
        }
        return vm
    }()
}

extension LNSLoginVC{
    @objc func getCodeAction() {
        if phoneVm.phoneTextField.text?.count ?? 0 < 7 {
            MCToast.mc_text("请输入正确的手机号",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        self.phoneVm.phoneTextField.resignFirstResponder()
        UserInfoModel.shared.idc = self.phoneVm.idc
        self.codeVm.sendGetCodeRequest(phone: phoneVm.phoneTextField.text ?? "")
//        sendGetCodeRequest()
    }
    @objc func wechatLoginAction(){
        WXUtil().wxLogin()
        loginType = "wechat"
    }
    @objc func appleLoginAction(){
        loginType = "appleid"
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    @objc func wechatLoginResult(){
        if UserInfoModel.shared.isRegist == "yes"{
            if UserInfoModel.shared.state == 1 {
                if QuestinonaireMsgModel.shared.surveytype == "noPlan"{
                    self.changeRootVcToTabbar()
                }else{
                    self.sendSurveySaveRequest()
                }
            }else{
                self.presentAlertVcNoAction(title: "账户已申请注销！", viewController: self)
            }
        }else{
            let vc = BindPhoneVC()
            vc.bindType = "wechat"
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    @objc func popGestureAction(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.edgePanChangeX = CGFloat(0)
        case .changed:
            let translation = gesture.translation(in: view)
//            DLLog(message: "translation.x:\(translation.x)")
            self.edgePanChangeX = self.edgePanChangeX + translation.x
            if self.isCodeShow{
                self.codeVm.center = CGPoint.init(x: self.edgePanChangeX+SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
            }
            
            gesture.setTranslation(.zero, in: view)
        case .ended:
            if self.isCodeShow == false{
                self.backTapAction()
            }else{
                self.codeVm.hiddenSelfAction()
            }
            
            break
        default:
            break
        }
    }
}

extension LNSLoginVC{
    func sendAppleIdLoginRequest(){
        MCToast.mc_loading()
        let param = ["appleid":"\(UserInfoModel.shared.appleId)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_Login_appid, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
//            let dataObj = responseObject["data"]as? NSDictionary ?? [:]
            
            let dataEncString = responseObject["data"]as? String ?? ""
            let dataDecString = AESEncyptUtil.aesDecrypt(hexString: dataEncString)
            let dataObj = self.getDictionaryFromJSONString(jsonString: dataDecString ?? "")
            
            UserInfoModel.shared.isRegist = dataObj["registered"]as? String ?? ""
            if dataObj["registered"]as? String ?? "" == "yes"{
                if dataObj.stringValueForKey(key: "state") == "1" {
                    MCToast.mc_text("登录成功！")
                    UserInfoModel.shared.token = dataObj["token"]as? String ?? ""
                    UserInfoModel.shared.uId   = dataObj["uid"]as? String ?? ""
                    
                    UserDefaults.standard.setValue("\(dataObj["token"]as? String ?? "")", forKey: token)
                    UserDefaults.standard.setValue("\(dataObj["uid"]as? String ?? "")", forKey: userId)
                    
                    WidgetUtils().saveUserInfo(uId: "\(dataObj["uid"]as? String ?? "")", uToken: "\(dataObj["token"]as? String ?? "")")
                    if QuestinonaireMsgModel.shared.surveytype == "noPlan"{
                        self.changeRootVcToTabbar()
                    }else{
                        self.sendSurveySaveRequest()
                    }
                }else{
                    self.presentAlertVcNoAction(title: "账户已申请注销。", viewController: self)
                }
                
            }else{
                let vc = BindPhoneVC()
                vc.bindType = "apple"
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
    }
    
    func sendSurveySaveRequest() {
        MCToast.mc_loading()
        var param = NSDictionary()
        if QuestinonaireMsgModel.shared.surveytype == "custom"{//自定义目标
            param = ["uid":"\(UserInfoModel.shared.uId)",
                     "surveytype":"custom",
                     "calories":"\(QuestinonaireMsgModel.shared.calories)",
                     "protein":"\(QuestinonaireMsgModel.shared.protein)",
                     "carbohydrate":"\(QuestinonaireMsgModel.shared.carbohydrates)",
                     "fat":"\(QuestinonaireMsgModel.shared.fats)",]
            
            WHNetworkUtil.shareManager().POST(urlString: URL_question_custom_save, parameters: param as? [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
                DLLog(message: "\(responseObject)")
                
                self.changeRootVcToTabbar()
            }
        }else {//填写了问卷
            if QuestinonaireMsgModel.shared.surveytype == "full"{
                param = ["uid":"\(UserInfoModel.shared.uId)",
                         "surveytype":"full",
                         "pname":"\(QuestinonaireMsgModel.shared.name)",
                         "gender":"\(QuestinonaireMsgModel.shared.sex)",
                         "birthday":"\(QuestinonaireMsgModel.shared.birthDay)",
                         "height":"\(QuestinonaireMsgModel.shared.height)",
                         "weight":"\(QuestinonaireMsgModel.shared.weight)",
                         "goal":"\(QuestinonaireMsgModel.shared.goal)",
                         "dailyact":"\(QuestinonaireMsgModel.shared.events)",
                         "bodyfat":"\(QuestinonaireMsgModel.shared.bodyFat)",
                         "dailymeals":"\(QuestinonaireMsgModel.shared.mealsPerDay)",
                         "planweeks":"\(QuestinonaireMsgModel.shared.planWeeks)",
                         "protein":QuestinonaireMsgModel.shared.foodsMsgProteins,
                         "fat":QuestinonaireMsgModel.shared.foodsMsgFats,
                         "carbohydrate":QuestinonaireMsgModel.shared.foodsMsgCarbohydrates,
                         "vegetable":QuestinonaireMsgModel.shared.foodsMsgVegetables,
                         "fruit":QuestinonaireMsgModel.shared.foodsMsgFrutis,
                         "dailyfoodsqty":"\(QuestinonaireMsgModel.shared.dailyfoodsqty)"]
                WHNetworkUtil.shareManager().POST(urlString: URL_question_survey_save, parameters: param as? [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
                    
//                    if BodyDataSQLiteManager.getInstance().queryTable(sDate: Date().nextDay(days: 0)){
//                        BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "weight", data: "\(QuestinonaireMsgModel.shared.weight)", cTime: Date().nextDay(days: 0))
//                    }else{
//                        BodyDataSQLiteManager.getInstance().updateData(cTime: Date().nextDay(days: 0), imgurl: "", hipsData: "", weightData: "\(QuestinonaireMsgModel.shared.weight)", waistlineData: "", shoulderData: "", bustData: "", thighData: "", calfData: "", bfpData: "", images: "[[],[],[]]", armcircumferenceData: "")
//                    }
                    
                    self.changeRootVcToTabbar()
                }
            }else{
                param = ["uid":"\(UserInfoModel.shared.uId)",
                         "surveytype":"part",
                         "removefoods":"false",
                         "gender":"\(QuestinonaireMsgModel.shared.sex)",
                         "birthday":"\(QuestinonaireMsgModel.shared.birthDay)",
                         "height":"\(QuestinonaireMsgModel.shared.height)",
                         "weight":"\(QuestinonaireMsgModel.shared.weight)",
                         "goal":"\(QuestinonaireMsgModel.shared.goal)",
                         "dailyact":"\(QuestinonaireMsgModel.shared.events)",
                         "bodyfat":"\(QuestinonaireMsgModel.shared.bodyFat)",
                         "fat":"\(QuestinonaireMsgModel.shared.fatsNumber)",
                         "protein":"\(QuestinonaireMsgModel.shared.proteinNumber)",
                         "carbohydrate":"\(QuestinonaireMsgModel.shared.carbohydratesNumber)",
                         "calories":"\(QuestinonaireMsgModel.shared.caloriesNumber)"]
                WHNetworkUtil.shareManager().POST(urlString: URL_question_survey_savepart, parameters: param as? [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
                    
//                    if BodyDataSQLiteManager.getInstance().queryTable(sDate: Date().nextDay(days: 0)){
//                        BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "weight", data: "\(QuestinonaireMsgModel.shared.weight)", cTime: Date().nextDay(days: 0))
//                    }else{
//                        BodyDataSQLiteManager.getInstance().updateData(cTime: Date().nextDay(days: 0), imgurl: "", hipsData: "", weightData: "\(QuestinonaireMsgModel.shared.weight)", waistlineData: "", shoulderData: "", bustData: "", thighData: "", calfData: "", bfpData: "", images: "[[],[],[]]", armcircumferenceData: "")
//                    }
                    
//                    MCToast.mc_text("计划保存成功")
                    self.changeRootVcToTabbar()
                }
            }
            
        }
    }
}

extension LNSLoginVC{
    func initUI() {
        view.addSubview(closeImgView)
        view.addSubview(titleLabel)
        view.addSubview(phoneVm)
        view.addSubview(getCodeBtn)
        view.addSubview(orLabel)
        view.addSubview(orLeftLine)
        view.addSubview(orRightLine)
        view.addSubview(weChatLoginBtn)
        view.addSubview(appleLoginBtn)
        view.addSubview(tipsLabel)
        
        weChatLoginBtn.addShadow()
        appleLoginBtn.addShadow()
        
        view.addSubview(codeVm)
        
        view.addSubview(inviteCodeAlertVm)
        setConstrait()
    }
    func setConstrait() {
        closeImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(kFitWidth(10)+getNavigationBarHeight())
            make.width.height.equalTo(kFitWidth(24))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(getNavigationBarHeight()+kFitWidth(79))
        }
        getCodeBtn.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(239)+getNavigationBarHeight())
            make.width.equalTo(kFitWidth(327))
            make.height.equalTo(kFitWidth(56))
        }
        orLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(getCodeBtn.snp.bottom).offset(kFitWidth(60))
        }
        orLeftLine.snp.makeConstraints { make in
            make.right.equalTo(orLabel.snp.left).offset(kFitWidth(-8))
            make.centerY.lessThanOrEqualTo(orLabel)
            make.width.equalTo(kFitWidth(120))
            make.height.equalTo(kFitWidth(1))
        }
        orRightLine.snp.makeConstraints { make in
            make.left.equalTo(orLabel.snp.right).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualTo(orLabel)
            make.width.height.equalTo(orLeftLine)
        }
        weChatLoginBtn.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.height.equalTo(getCodeBtn)
            make.top.equalTo(orLabel.snp.bottom).offset(kFitWidth(20))
        }
        appleLoginBtn.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.height.equalTo(weChatLoginBtn)
            make.top.equalTo(weChatLoginBtn.snp.bottom).offset(kFitWidth(12))
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(appleLoginBtn.snp.bottom).offset(kFitWidth(20))
        }
    }
}

extension LNSLoginVC:ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding{
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
