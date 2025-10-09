//
//  NeedBuildPlanVC.swift
//  lns
//
//  Created by LNS2 on 2024/3/27.
//

import Foundation
import MCToast
import AuthenticationServices
import UMCommon

class NeedBuildPlanVC: WHBaseViewVC {
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(wechatLogin), name: Notification.Name(rawValue: "wechatLogin"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        enableInteractivePopGesture()
        self.navigationController?.fd_interactivePopDisabled = true
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
    }
    
    lazy var topTitleLabel : UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.textColor = .black
        lab.text = "设定您的营养目标"
        
        return lab
    }()
    lazy var tipsButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("我该如何选择？", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.addTarget(self, action: #selector(tipsTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var buttonOne : FeedBackButton = {
        let btn = FeedBackButton()
        btn.layer.cornerRadius = kFitWidth(36)
        btn.clipsToBounds = true
        btn.backgroundColor = WHColor_16(colorStr: "007AFF")
//        btn.setTitle("需要营养目标以及饮食计划", for: .normal)
//        btn.setTitle("• 智能推荐", for: .normal)
        btn.setTitle("智能推荐", for: .normal)
//        btn.setTitle("是", for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.85), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)
        
        btn.addTarget(self, action: #selector(buildPlanPartAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var buttonTwo : FeedBackButton = {
        let btn = FeedBackButton()
        btn.layer.cornerRadius = kFitWidth(36)
        btn.clipsToBounds = true
        btn.backgroundColor = WHColor_16(colorStr: "007AFF")
        btn.setTitle("手动输入", for: .normal)
//        btn.setTitle("需要营养目标，不需要饮食计划", for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.85), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)
        
        btn.addTarget(self, action: #selector(customTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var buttonThree : UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = kFitWidth(36)
        btn.clipsToBounds = true
        btn.isHidden = true
        btn.backgroundColor = WHColor_16(colorStr: "007AFF")
        btn.setTitle("否，我需要营养目标", for: .normal)
//        btn.setTitle("自己制定营养目标", for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.85), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        
        btn.addTarget(self, action: #selector(buildPlanPartAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var bottomView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "D9D9D9")
        
        return vi
    }()
    lazy var loginBtn : FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("登录", for: .normal)
        btn.setTitleColor(WHColor_16(colorStr: "007AFF"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        
        btn.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var tipsAlertVm : QuestionnairePlanTipsAlertVM = {
        let vm = QuestionnairePlanTipsAlertVM.init(frame: .zero)
        
        return vm
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
}

extension NeedBuildPlanVC{
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
    
    @objc func buildPlanFullAction(){
        QuestinonaireMsgModel.shared.surveytype = "full"
        let vc = QuestionnaireVC()
        self.navigationController?.pushViewController(vc, animated: true)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "wechatLogin"), object: nil)
    }
    @objc func buildPlanPartAction(){
        QuestinonaireMsgModel.shared.surveytype = "part"
        let vc = QuestionnaireNewVC()
//        let vc = QuestionnaireVC()
        vc.surveytype = "part"
        self.navigationController?.pushViewController(vc, animated: true)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "wechatLogin"), object: nil)
    }
    @objc func tipsTapAction(){
        tipsAlertVm.showView()
    }
    @objc func customTapAction(){
        MobClick.event("createPlanManual")
        QuestinonaireMsgModel.shared.surveytype = "custom"
        let vc = QuestionCustomVC()
        vc.nextBtn.isEnabled = true
        vc.tipsButton.isHidden = true
        self.navigationController?.pushViewController(vc, animated: true)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "wechatLogin"), object: nil)
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
extension NeedBuildPlanVC{
    func initUI(){
        view.backgroundColor = WHColor_16(colorStr: "F6F6F6")
        
        view.addSubview(topTitleLabel)
        view.addSubview(tipsButton)
        view.addSubview(buttonOne)
        view.addSubview(buttonTwo)
        view.addSubview(buttonThree)
        
        view.addSubview(bottomView)
        bottomView.addSubview(lineView)
        bottomView.addSubview(loginBtn)
        
        view.addSubview(loginAlertVm)
        view.addSubview(notRegistVm)
        view.addSubview(tipsAlertVm)
        
        setConstrait()
    }
    func setConstrait() {
        topTitleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(getNavigationBarHeight()+kFitWidth(60))
        }
        tipsButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(getNavigationBarHeight()+kFitWidth(100))
            
        }
        buttonOne.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(72))
            make.top.equalTo(tipsButton.snp.bottom).offset(kFitWidth(120))
        }
        buttonTwo.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.height.equalTo(buttonOne)
            make.top.equalTo(buttonOne.snp.bottom).offset(kFitWidth(30))
        }
        buttonThree.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.height.equalTo(buttonOne)
            make.top.equalTo(buttonTwo.snp.bottom).offset(kFitWidth(20))
        }
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(50)+getBottomSafeAreaHeight())
        }
        loginBtn.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(40))
            make.width.equalToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }
}

extension NeedBuildPlanVC{
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

extension NeedBuildPlanVC:ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding{
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
