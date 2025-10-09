//
//  UpdatePhoneVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/14.
//

import Foundation
import MCToast

class UpdatePhoneVC: WHBaseViewVC {
    
    
//    let codeTimer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: .global())
    var getCodeTime = 60
    var timer: Timer?
    var verifyCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "我们要对您绑定的手机号进行验证"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
    lazy var phoneLabel: UILabel = {
        let lab = UILabel()
        lab.text = "\(UserInfoModel.shared.phone.mc_clipFromPrefix(to: 3)) **** \(UserInfoModel.shared.phone.mc_cutToSuffix(from: 7))"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
    lazy var verifyCodeView : MHVerifyCodeView = {
        let vi = MHVerifyCodeView.init()
        vi.spacing = kFitWidth(24)
        vi.verifyCount = 4
        vi.bgColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        vi.borderColor = .clear
        vi.setCompleteHandler { verifyCode in
            DLLog(message: "\(verifyCode)")
            self.verifyCode = verifyCode
            self.nextButton.isEnabled = true
        }
        vi.inputBlock = {()in
            self.nextButton.isEnabled = false
        }
        
        return vi
    }()
    lazy var getCodeBtn : FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("获取验证码", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(WHColor_16(colorStr: "73B6FF"), for: .highlighted)
        btn.setTitleColor(WHColor_16(colorStr: "73B6FF"), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.backgroundColor = .clear
        
        btn.addTarget(self, action: #selector(sendGetCodeRequest), for: .touchUpInside)
        
        return btn
    }()
    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .THEME
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(sendVerifyCodeRequest), for: .touchUpInside)
        
        return btn
    }()
}

extension UpdatePhoneVC{
//    func initTimer() {
//        self.codeTimer.schedule(deadline: .now(), repeating: .milliseconds(1000))
//        self.codeTimer.setEventHandler {
//            self.getCodeTime = self.getCodeTime - 1
//            
//            if self.getCodeTime < 0{
//                self.codeTimer.suspend()
//                self.getCodeTime = 60
//                DispatchQueue.main.async {
//                    self.getCodeBtn.isEnabled = true
//                    self.getCodeBtn.setTitle("重新发送", for: .normal)
//                }
//            }else{
//                DispatchQueue.main.async {
//                    self.getCodeBtn.isEnabled = false
//                    self.getCodeBtn.setTitle("重新发送 \(self.getCodeTime)s", for: .normal)
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
                    self.getCodeBtn.isEnabled = true
                    self.getCodeBtn.setTitle("重新发送", for: .normal)
                }
            }else{
                DispatchQueue.main.async {
                    self.getCodeBtn.isEnabled = false
                    self.getCodeBtn.setTitle("重新发送 \(self.getCodeTime)s", for: .normal)
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

extension UpdatePhoneVC{
    func initUI() {
        initNavi(titleStr: "绑定手机号")
        view.backgroundColor = .white
        
        view.addSubview(tipsLabel)
        view.addSubview(phoneLabel)
        view.addSubview(verifyCodeView)

        view.addSubview(getCodeBtn)
        view.addSubview(nextButton)
        
        setConstrait()
    }
    func setConstrait(){
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(60)+getNavigationBarHeight())
        }
        phoneLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(tipsLabel.snp.bottom).offset(kFitWidth(20))
        }
        let spacing = kFitWidth(12)
        let height = kFitWidth(60)
        let width = height * CGFloat(4) + spacing * CGFloat(3)//需要自己计算宽度
         
        verifyCodeView.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(152)+WHUtils().getNavigationBarHeight())
            make.height.equalTo(kFitWidth(56))
        }
        getCodeBtn.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(verifyCodeView.snp.bottom).offset(kFitWidth(30))
            make.height.equalTo(kFitWidth(34))
            make.width.equalTo(kFitWidth(150))
        }
        nextButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(-12)-getBottomSafeAreaHeight())
            make.width.equalTo(kFitWidth(327))
            make.height.equalTo(kFitWidth(56))
        }
    }
}
extension UpdatePhoneVC{
    @objc func sendGetCodeRequest(){
        MCToast.mc_loading()
//        let param = ["phone":"\(UserInfoModel.shared.phone)"]

        let param = ["phone":"\(UserInfoModel.shared.phone)",
                     "idc":"\(UserInfoModel.shared.idc)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_send_sms, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
//            self.initTimer()
//            self.codeTimer.resume()
            self.startCountdown()
        }
    }
    @objc func sendVerifyCodeRequest(){
        MCToast.mc_loading()
        let param = ["phone":"\(UserInfoModel.shared.phone)",
                     "code":"\(verifyCode)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_verify_sms, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: "\(responseObject)")
            self.disableTimer()
            let vc = UpdatePhoneNewVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
