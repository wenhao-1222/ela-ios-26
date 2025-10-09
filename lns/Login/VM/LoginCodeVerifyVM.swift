//
//  LoginCodeVerifyVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/3.
//

import Foundation
import UIKit
import MCToast

class LoginCodeVerifyVM: UIView {
    
    var hasPlan = true
//    var codeTimer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: .global())
    var getCodeTime = 60
    var timer: Timer?
    
    var controller = WHBaseViewVC()
    
    var phone = ""
    var code = ""
    var invideCode = ""
    
    var saveSurveyBlock:(()->())?
    var closeBlock:(()->())?
    var showBlock:(()->())?
    var showInviteCodeBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.alpha = 0
        
        initUI()
//        initTimer()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var closeImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "login_close_img")
        img.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelfAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "请输入验证码"
        lab.textColor = WHColor_16(colorStr: "262626")
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        
        return lab
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var getCodeBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("重新发送", for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.25), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: WHColorWithAlpha(colorStr: "000000", alpha: 0.2)), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        btn.layer.cornerRadius = kFitWidth(12)
        btn.clipsToBounds = true
        
        btn.addTarget(self, action: #selector(sendSmsAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var verifyCodeView : MHVerifyCodeView = {
        let vi = MHVerifyCodeView.init()
        vi.spacing = kFitWidth(24)
        vi.verifyCount = 4
        vi.setCompleteHandler { verifyCode in
            DLLog(message: "\(verifyCode)")
            self.code = verifyCode
            self.loginBtn.isEnabled = true
            self.loginBtn.backgroundColor = .THEME
        }
        vi.inputBlock = {()in
            self.loginBtn.isEnabled = false
            self.loginBtn.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.45)
        }
        
        return vi
    }()
    lazy var loginBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("登录", for: .normal)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.45)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var inviteCodeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("我有邀请码", for:.normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.isHidden = true
        
        btn.addTarget(self, action: #selector(showInviteCodeAction), for: .touchUpInside)
        
        return btn
    }()
}

extension LoginCodeVerifyVM{
    @objc func loginAction(){
        if self.code.count < 4 {
            MCToast.mc_text("请输入4位数验证码")
            return
        }
        sendPhoneLoginRequest()
    }
    @objc func sendSmsAction() {
        self.sendGetCodeRequest(phone: self.phone)
    }
    @objc func showInviteCodeAction(){
        if self.showInviteCodeBlock != nil{
            self.showInviteCodeBlock!()
        }
    }
    @objc func hiddenSelfAction() {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.alpha = 0
            self.center = CGPoint.init(x: SCREEN_WIDHT*1.5, y: SCREEN_HEIGHT*0.5)
        }
//        self.codeTimer.suspend()
        self.disableTimer()
        self.getCodeTime = 60
        self.verifyCodeView.hideTextField.resignFirstResponder()
        self.verifyCodeView.clearNumber()
        self.loginBtn.isEnabled = false
        self.loginBtn.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.45)
        if self.closeBlock != nil{
            self.closeBlock!()
        }
    }
    func showSelfAction() {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.alpha = 1
            self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
        }completion: { t in
//            self.verifyCodeView.hideTextField.becomeFirstResponder()
        }
        if self.showBlock != nil{
            self.showBlock!()
        }
    }
//    func initTimer() {
//        self.codeTimer.schedule(deadline: .now(), repeating: .milliseconds(1000))
//        self.codeTimer.setEventHandler {
//            self.getCodeTime = self.getCodeTime - 1
//            
//            if self.getCodeTime < 0{
//                self.codeTimer.suspend()
//                self.getCodeTime = 60
//                DispatchQueue.main.async {
//                    self.getCodeBtn.isUserInteractionEnabled = true
//                    self.getCodeBtn.setTitle("重新发送", for: .normal)
//                    self.getCodeBtn.snp.remakeConstraints { make in
//                        make.left.equalTo(self.tipsLabel.snp.right).offset(kFitWidth(32))
//                        make.centerY.lessThanOrEqualTo(self.tipsLabel)
//                        make.width.equalTo(kFitWidth(80))
//                        make.height.equalTo(kFitWidth(24))
//                    }
//                }
//            }else{
//                DispatchQueue.main.async {
//                    self.getCodeBtn.isUserInteractionEnabled = false
//                    self.getCodeBtn.setTitle("重新发送 \(self.getCodeTime) 秒", for: .normal)
//                    self.getCodeBtn.snp.remakeConstraints { make in
//                        make.left.equalTo(self.tipsLabel.snp.right).offset(kFitWidth(32))
//                        make.centerY.lessThanOrEqualTo(self.tipsLabel)
//                        make.width.equalTo(kFitWidth(112))
//                        make.height.equalTo(kFitWidth(24))
//                    }
//                }
//            }
//        }
//    }
    func startCountdown() {
        //一般倒计时是操作UI，使用主队列
        self.getCodeTime = 59
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            // 定时器执行的操作
            self.getCodeTime = self.getCodeTime - 1
            if self.getCodeTime < 0{
//                self.codeTimer.suspend()
                self.disableTimer()
                self.getCodeTime = 60
                DispatchQueue.main.async {
                    self.getCodeBtn.isUserInteractionEnabled = true
                    self.getCodeBtn.setTitle("重新发送", for: .normal)
                    self.getCodeBtn.snp.remakeConstraints { make in
                        make.left.equalTo(self.tipsLabel.snp.right).offset(kFitWidth(32))
                        make.centerY.lessThanOrEqualTo(self.tipsLabel)
                        make.width.equalTo(kFitWidth(80))
                        make.height.equalTo(kFitWidth(24))
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.getCodeBtn.isUserInteractionEnabled = false
                    self.getCodeBtn.setTitle("重新发送 \(self.getCodeTime) 秒", for: .normal)
                    self.getCodeBtn.snp.remakeConstraints { make in
                        make.left.equalTo(self.tipsLabel.snp.right).offset(kFitWidth(32))
                        make.centerY.lessThanOrEqualTo(self.tipsLabel)
                        make.width.equalTo(kFitWidth(112))
                        make.height.equalTo(kFitWidth(24))
                    }
                }
            }
        }
    }
    func disableTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.getCodeBtn.setTitle("重新发送", for: .normal)
    }
}
extension LoginCodeVerifyVM{
    func initUI(){
        addSubview(closeImgView)
        addSubview(titleLabel)
        addSubview(tipsLabel)
        addSubview(getCodeBtn)
        
        addSubview(verifyCodeView)
        addSubview(loginBtn)
        
        addSubview(inviteCodeButton)
        
        setConstrait()
    }
    func setConstrait() {
        closeImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(WHUtils().getNavigationBarHeight()+kFitWidth(10))
            make.width.height.equalTo(kFitWidth(24))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(79)+WHUtils().getNavigationBarHeight())
        }
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(117)+WHUtils().getNavigationBarHeight())
        }
        getCodeBtn.snp.makeConstraints { make in
            make.left.equalTo(tipsLabel.snp.right).offset(kFitWidth(32))
            make.centerY.lessThanOrEqualTo(tipsLabel)
            make.width.equalTo(kFitWidth(112))
            make.height.equalTo(kFitWidth(24))
        }
        let spacing = kFitWidth(24)
        let height = kFitWidth(56)
        let width = height * CGFloat(4) + spacing * CGFloat(3)//需要自己计算宽度
         
        verifyCodeView.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(195)+WHUtils().getNavigationBarHeight())
            make.height.equalTo(kFitWidth(56))
        }
        loginBtn.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(291)+WHUtils().getNavigationBarHeight())
            make.width.equalTo(kFitWidth(327))
            make.height.equalTo(kFitWidth(56))
        }
        inviteCodeButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(-40)-WHUtils().getBottomSafeAreaHeight())
        }
    }
}

extension LoginCodeVerifyVM{
    func sendGetCodeRequest(phone:String){
        MCToast.mc_loading()
        self.phone = phone
        sendJudgePhoneRegist()
    }
    func sendPhoneLoginRequest(){
        MCToast.mc_loading()
        let param = ["phone":"\(self.phone)",
                     "invcode":"\(self.invideCode)",
                     "code":"\(self.code)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_Login_phone, parameters: param as [String:AnyObject],isNeedToast: true,vc: controller) { responseObject in
            DLLog(message: "\(responseObject)")
//            let dataObj = responseObject["data"]as? NSDictionary ?? [:]
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
//            if dataObj.stringValueForKey(key: "state") == "1" {
                UserInfoModel.shared.token = dataObj["token"]as? String ?? ""
                UserInfoModel.shared.uId   = dataObj["uid"]as? String ?? ""
                UserDefaults.standard.setValue("\(dataObj["token"]as? String ?? "")", forKey: token)
                UserDefaults.standard.setValue("\(dataObj["uid"]as? String ?? "")", forKey: userId)
            
            WidgetUtils().saveUserInfo(uId: "\(dataObj["uid"]as? String ?? "")", uToken: "\(dataObj["token"]as? String ?? "")")
//                self.codeTimer.cancel()
                self.disableTimer()
                if self.hasPlan{
                    if self.saveSurveyBlock != nil{
                        self.saveSurveyBlock!()
                    }
                }else{
                    self.controller.changeRootVcToTabbar()
                }
//            }else{
//                self.controller.presentAlertVcNoAction(title: "账户已申请注销。", viewController: self.controller)
//            }
        }
    }
    func sendBindInviteCodeRequest() {
        let param = ["invcode":"\(self.invideCode)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_bind_inviteCode, parameters: param as [String:AnyObject],isNeedToast: true,vc: controller) { responseObject in
//            DLLog(message: "\(responseObject)")
            if self.hasPlan{
                if self.saveSurveyBlock != nil{
                    self.saveSurveyBlock!()
                }
            }else{
                self.controller.changeRootVcToTabbar()
            }
        }
    }
    func sendJudgePhoneRegist() {
        MCToast.mc_loading()
        let param = ["phone":"\(self.phone)",
                     "idc":"\(UserInfoModel.shared.idc)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_judge_phone_regist, parameters: param as [String : AnyObject]) { responseObject in
//            let respData = responseObject["data"]as? NSDictionary ?? [:]
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let respData = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            if respData["registered"] as? String ?? "" == "no"{
                self.inviteCodeButton.isHidden = false
                self.getCodeRequest()
            }else{
                if respData.stringValueForKey(key: "state") == "1" {
                    self.inviteCodeButton.isHidden = true
                    self.verifyCodeView.hideTextField.becomeFirstResponder()
                    self.getCodeRequest()
                }else{
//                    MCToast.mc_text("用户已注销！")
                    
                    self.controller.presentAlertVc(confirmBtn: "确定", message: "Elavatine 作为一款免费软件，致力于在有限资源下为用户提供最佳体验。为了防止频繁重复注册占用服务器资源，注销后需等待约24小时才能重新注册，由此带来的不便，敬请谅解。", title: "提示", cancelBtn: nil, handler: { action in
                        
                    }, viewController: self.controller)
                    self.hiddenSelfAction()
                }
            }
        }
    }
    func getCodeRequest() {
        self.tipsLabel.text = "已发送至 \(self.phone.mc_clipFromPrefix(to: 3)) **** \(self.phone.mc_cutToSuffix(from: self.phone.count - 4))"

        let param = ["phone":"\(self.phone)",
                     "idc":"\(UserInfoModel.shared.idc)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_send_sms, parameters: param as [String:AnyObject],isNeedToast: true,vc: controller) { responseObject in
            DLLog(message: "\(responseObject)")
            self.showSelfAction()
            
//            if #available(iOS 10.0, *) {
//                self.codeTimer.activate()
//            } else {
//                self.codeTimer.resume()
//            }
            DispatchQueue.main.async {
                self.getCodeBtn.isUserInteractionEnabled = false
                self.getCodeBtn.setTitle("重新发送 \(self.getCodeTime) 秒", for: .normal)
                self.getCodeBtn.snp.remakeConstraints { make in
                    make.left.equalTo(self.tipsLabel.snp.right).offset(kFitWidth(32))
                    make.centerY.lessThanOrEqualTo(self.tipsLabel)
                    make.width.equalTo(kFitWidth(112))
                    make.height.equalTo(kFitWidth(24))
                }
            }
            self.startCountdown()
        }
    }
}
