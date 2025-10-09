//
//  BindOtherAccountVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/15.
//

import Foundation
import AuthenticationServices

class BindOtherAccountVC : WHBaseViewVC {
    
    override func viewWillAppear(_ animated: Bool) {
        DLLog(message: "viewWillAppear")
        NotificationCenter.default.addObserver(self, selector: #selector(bindWeChatAction), name: Notification.Name(rawValue: "wechatBind"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    lazy var appidVm: BindOtherAccountItemVM = {
        let vm = BindOtherAccountItemVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(8), width: 0, height: 0))
//        vm.frame = CGRect.init(x: 0, y: self.wechatVm.frame.maxY, width: SCREEN_WIDHT, height: MineFuncItemVM().selfHeight)
        vm.leftIconImgView.setImgLocal(imgName: "login_apple_icon")
        vm.titleLab.text = "Apple ID"
        vm.tapBlock = {()in
            if UserInfoModel.shared.isBindAppId{
                self.presentAlertVc(confirmBtn: "确认", message: "解绑Apple ID 账号后将无法继续使用它登录该Elavatine账号", title: "确认解绑", cancelBtn: "取消", handler: { action in
                    
                    self.sendUnbindAppleIdRequest()
                }, viewController: self)
            }else{
                self.appleLoginAction()
            }
        }
        
        return vm
    }()
    lazy var wechatVm: BindOtherAccountItemVM = {
        let vm = BindOtherAccountItemVM.init(frame: CGRect.init(x: 0, y: self.appidVm.frame.maxY, width: 0, height: 0))
//        vm.frame = CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(8), width: SCREEN_WIDHT, height: MineFuncItemVM().selfHeight)
        vm.leftIconImgView.setImgLocal(imgName: "login_wechat_icon")
        vm.titleLab.text = "微信"
        vm.tapBlock = {()in
            if UserInfoModel.shared.isBindWeChat{
                self.presentAlertVc(confirmBtn: "确认", message: "解绑微信账号后将无法继续使用它登录该Elavatine账号", title: "确认解绑", cancelBtn: "取消", handler: { action in
                    self.sendUnbindWeChatRequest()
                }, viewController: self)
            }else{
                WXUtil().wxLogin()
            }
        }
        if WXApi.isWXAppInstalled() == false{
            vm.isHidden = true
        }
        
        return vm
    }()
    
}

extension BindOtherAccountVC{
    @objc func appleLoginAction(){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    @objc func bindWeChatAction(){
//        UserInfoModel.shared.isBindWeChat = true
//        upateBindStatus()
        sendBindWeChatRequest()
    }
}

extension BindOtherAccountVC{
    func initUI() {
        initNavi(titleStr: "关联第三方账号")
        
        view.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        view.addSubview(wechatVm)
        view.addSubview(appidVm)
        upateBindStatus()
    }
    func upateBindStatus() {
        if UserInfoModel.shared.isBindWeChat {
            wechatVm.detailLabel.text = "已关联"
            wechatVm.detailLabel.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        }else{
            wechatVm.detailLabel.text = "未关联"
            wechatVm.detailLabel.textColor = .THEME
        }
        
        if UserInfoModel.shared.isBindAppId {
            appidVm.detailLabel.text = "已关联"
            appidVm.detailLabel.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        }else{
            appidVm.detailLabel.text = "未关联"
            appidVm.detailLabel.textColor = .THEME
        }
    }
}

extension BindOtherAccountVC{
    func sendUnbindWeChatRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_wechat_unbind, parameters: nil,isNeedToast: true,vc: self) { responseObject in
            UserInfoModel.shared.isBindWeChat = false
            self.upateBindStatus()
        }
    }
    func sendUnbindAppleIdRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_appleid_unbind, parameters: nil,isNeedToast: true,vc: self) { responseObject in
            UserInfoModel.shared.isBindAppId = false
            UserInfoModel.shared.appleId = ""
            self.upateBindStatus()
        }
    }
    func sendBindAppleIdRequest() {
        let param = ["appleid":UserInfoModel.shared.appleId]
        WHNetworkUtil.shareManager().POST(urlString: URL_appleid_bind, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            UserInfoModel.shared.isBindAppId = true
            self.upateBindStatus()
        }
    }
    func sendBindWeChatRequest() {
        let param = ["openid":UserInfoModel.shared.wxOpenId,
                     "unionid":UserInfoModel.shared.wxUnionId]
        WHNetworkUtil.shareManager().POST(urlString: URL_wechat_bind, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            UserInfoModel.shared.isBindWeChat = true
            self.upateBindStatus()
        }
    }
}


extension BindOtherAccountVC:ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding{
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
            self.sendBindAppleIdRequest()
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
