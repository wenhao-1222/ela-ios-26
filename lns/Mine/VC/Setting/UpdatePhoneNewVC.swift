//
//  UpdatePhoneNewVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/14.
//

import Foundation
import MCToast

class UpdatePhoneNewVC: WHBaseViewVC {
    
//    let codeTimer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: .global())
    var getCodeTime = 60
    var timer: Timer?
    
    var verifyCode = ""
    
    override func viewDidDisappear(_ animated: Bool) {
        self.disableTimer()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
//        initTimer()
    }
    
    lazy var phoneVm : LoginPhoneButton = {
        let vm = LoginPhoneButton.init(frame: CGRect.init(x: kFitWidth(24), y: kFitWidth(40)+getNavigationBarHeight(), width: 0, height: 0))
        vm.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        vm.layer.borderColor = UIColor.clear.cgColor
        vm.controller = self
        return vm
    }()
    lazy var verifyCodeVm : BindPhoneVerifyCodeButton = {
        let vm = BindPhoneVerifyCodeButton.init(frame: CGRect.init(x: kFitWidth(24), y: kFitWidth(108)+getNavigationBarHeight(), width: 0, height: 0))
        vm.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        vm.layer.borderColor = UIColor.clear.cgColor
        vm.judgeVerifyCodeBlock = {(code)in
            self.verifyCode = code
            self.judgeCodeNumber(code: code)
        }
        vm.getCodeBlock = {()in
            self.getCodeAction()
        }
        return vm
    }()
    lazy var bindButton: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(24), y: kFitWidth(176)+getNavigationBarHeight(), width: kFitWidth(327), height: kFitWidth(56))
        btn.setTitle("绑定新手机号", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .THEME
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.isEnabled = false

        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(bindAction), for: .touchUpInside)
        
        return btn
    }()
}

extension UpdatePhoneNewVC{
    @objc func bindAction(){
        if phoneVm.phoneTextField.text?.count ?? 0 < 7 {
            MCToast.mc_text("请输入正确的手机号",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        if verifyCode.count < 4 {
            MCToast.mc_text("请输入正确的验证码")
            return
        }
        sendBindPhoneRequest()
    }
    func getCodeAction() {
//        if !judgePhoneNumber(phoneNum: phoneVm.phoneTextField.text ?? ""){
//            MCToast.mc_text("请输入正确的手机号",offset: kFitWidth(-100),respond: .allow)
//            return
//        }
        if phoneVm.phoneTextField.text?.count ?? 0 < 7 {
            MCToast.mc_text("请输入正确的手机号",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        UserInfoModel.shared.idc = self.phoneVm.idc
        sendGetCodeRequest(phone: phoneVm.phoneTextField.text ?? "")
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
//                    self.verifyCodeVm.getCodeBtn.isUserInteractionEnabled = true
//                    self.verifyCodeVm.getCodeBtn.setTitle("获取验证码", for: .normal)
//                    self.verifyCodeVm.getCodeBtn.setTitleColor(.THEME, for: .normal)
//                }
//            }else{
//                DispatchQueue.main.async {
//                    self.verifyCodeVm.getCodeBtn.isUserInteractionEnabled = false
//                    self.verifyCodeVm.getCodeBtn.setTitleColor(WHColor_16(colorStr: "73B6FF"), for: .normal)
//                    self.verifyCodeVm.getCodeBtn.setTitle("重新发送 \(self.getCodeTime) s", for: .normal)
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
                self.getCodeTime = 60
                DispatchQueue.main.async {
                    self.verifyCodeVm.getCodeBtn.isUserInteractionEnabled = true
                    self.verifyCodeVm.getCodeBtn.setTitle("获取验证码", for: .normal)
                    self.verifyCodeVm.getCodeBtn.setTitleColor(.THEME, for: .normal)
                }
            }else{
                DispatchQueue.main.async {
                    self.verifyCodeVm.getCodeBtn.isUserInteractionEnabled = false
                    self.verifyCodeVm.getCodeBtn.setTitleColor(WHColor_16(colorStr: "73B6FF"), for: .normal)
                    self.verifyCodeVm.getCodeBtn.setTitle("重新发送 \(self.getCodeTime) s", for: .normal)
                }
            }
        }
    }
    func disableTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.verifyCodeVm.getCodeBtn.setTitle("获取验证码", for: .normal)
    }
    func judgeCodeNumber(code:String) {
        if code.count == 4 {
            self.bindButton.isEnabled = true
        }else{
            self.bindButton.isEnabled = false
        }
    }
}

extension UpdatePhoneNewVC{
    func initUI() {
        initNavi(titleStr: "绑定新手机号")
        
        view.addSubview(phoneVm)
        view.addSubview(verifyCodeVm)
        
        view.addSubview(bindButton)
    }
    
}

extension UpdatePhoneNewVC{
    func sendGetCodeRequest(phone:String){
        MCToast.mc_loading()
//        let param = ["phone":"\(phone)"]

        let param = ["phone":"\(phone)",
                     "idc":"\(UserInfoModel.shared.idc)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_send_sms, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: "\(responseObject)")
//            self.codeTimer.resume()
            self.startCountdown()
        }
    }
    func sendBindPhoneRequest() {
        MCToast.mc_loading()
        let param = ["phone":"\(phoneVm.phoneTextField.text ?? "")",
                     "code":"\(verifyCode)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_bind_phone_new, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: "\(responseObject)")
            UserInfoModel.shared.phone = self.phoneVm.phoneTextField.text ?? ""
            UserInfoModel.shared.changePhoneStar()
            
            if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 1 {
                for vc in viewControllers{
                    if vc.isKind(of: SettingVC.self){
                        self.navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
            }
        }
    }
}
