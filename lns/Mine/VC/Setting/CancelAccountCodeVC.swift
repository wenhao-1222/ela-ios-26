//
//  CancelAccountCodeVC.swift
//  lns
//
//  Created by Elavatine on 2025/9/26.
//


import MCToast

class CancelAccountCodeVC: WHBaseViewVC {
    
    var getCodeTime = 60
    var timer: Timer?
    var verifyCode = ""
        
    var reasons : [String] = [String]()
    var remarks = ""
    
    override func viewDidAppear(_ animated: Bool) {
        sendGetCodeRequest()
        self.verifyCodeView.hideTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    lazy var tipsLab: UILabel = {
        let lab = UILabel()
        lab.text = "请输入短信验证码"
        lab.font = .systemFont(ofSize: 26, weight: .semibold)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var phoneLabe: UILabel = {
        let lab = UILabel()
        let attr = NSMutableAttributedString(string: "验证码已发送至 ")
        var attrNum = NSMutableAttributedString(string: UserInfoModel.shared.phoneStar)
        
        attr.yy_font = .systemFont(ofSize: 13, weight: .regular)
        attr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        
        attrNum.yy_font = .systemFont(ofSize: 13, weight: .regular)
        attrNum.yy_color = .COLOR_TEXT_TITLE_0f1214
        
        attr.append(attrNum)
        lab.attributedText = attr
        
        return lab
    }()
    lazy var getCodeBtn : FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("获取验证码", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.backgroundColor = .clear
        
        btn.addTarget(self, action: #selector(getCodeAction), for: .touchUpInside)
        
        return btn
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
            self.changeButton.isEnabled = true
        }
        vi.inputBlock = {()in
            self.changeButton.isEnabled = false
        }
        
        return vi
    }()
    lazy var changeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("确认注销", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_GRAY_C4C4C4), for: .disabled)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.isEnabled = false
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        
        btn.addTarget(self, action: #selector(sendCancelRequest), for: .touchUpInside)
        btn.enablePressEffect()
        
        return btn
    }()
    lazy var cancelButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("取消", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.isHidden = true
        
        btn.addTarget(self, action: #selector(backTapAction), for: .touchUpInside)
        
        return btn
    }()
}

extension CancelAccountCodeVC{
    @objc func getCodeAction () {
        sendGetCodeRequest()
    }
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
                    self.getCodeBtn.setTitle("获取验证码", for: .normal)
                    self.getCodeBtn.setTitleColor(.THEME, for: .normal)
                }
            }else{
                DispatchQueue.main.async {
                    self.getCodeBtn.isUserInteractionEnabled = false
                    self.getCodeBtn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
                    self.getCodeBtn.setTitle("重新发送（\(self.getCodeTime)）", for: .normal)
                }
            }
        }
    }
    func disableTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.getCodeBtn.setTitle("获取验证码", for: .normal)
    }
}

extension CancelAccountCodeVC{
    func initUI() {
        initNavi(titleStr: "注销账号")
        
        view.addSubview(tipsLab)
        view.addSubview(phoneLabe)
        view.addSubview(getCodeBtn)
        view.addSubview(verifyCodeView)
        view.addSubview(changeButton)
        view.addSubview(cancelButton)
        
        setConstrait()
    }
    func setConstrait() {
        tipsLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(27))
            make.top.equalTo(kFitWidth(90)+getNavigationBarHeight())
        }
        phoneLabe.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(27))
            make.top.equalTo(kFitWidth(133)+getNavigationBarHeight())
        }
        getCodeBtn.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-27))
            make.right.equalToSuperview()
            make.centerY.lessThanOrEqualTo(phoneLabe)
            make.height.equalTo(kFitWidth(40))
            make.width.equalTo(kFitWidth(130))
        }
        
        let spacing = kFitWidth(12)
        let height = kFitWidth(60)
        let width = height * CGFloat(4) + spacing * CGFloat(3)//需要自己计算宽度
         
        verifyCodeView.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(180)+WHUtils().getNavigationBarHeight())
            make.height.equalTo(kFitWidth(56))
        }
        changeButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(320)+getNavigationBarHeight())
            make.height.equalTo(kFitWidth(44))
        }
        cancelButton.snp.makeConstraints { make in
            make.height.equalTo(changeButton)
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(88))
            make.top.equalTo(changeButton.snp.bottom).offset(kFitWidth(8))
        }
    }
}

extension CancelAccountCodeVC{
    func sendGetCodeRequest(){
        MCToast.mc_loading()

        let param = ["phone":"\(UserInfoModel.shared.phone)",
                     "idc":"\(UserInfoModel.shared.idc)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_send_sms, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
            
            self.getCodeBtn.isUserInteractionEnabled = false
            self.getCodeBtn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
            self.getCodeBtn.setTitle("重新发送（59）", for: .normal)
            self.startCountdown()
        }
    }
    @objc func sendCancelRequest() {
        let param : [String : Any] = ["reasons":reasons,
                                      "remarks":"\(remarks)",
                                      "code":verifyCode]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_Uer_Cancel, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            WHBaseViewVC().changeRootVcToWelcome()
            LogsSQLiteUploadManager().clearNaturalData()
            BodyDataSQLiteManager.getInstance().deleteAllData()
            LogsMealsAlertSetManage().removeAllNotifi()
            LogsSQLiteManager.getInstance().deleteAllData()
            CourseProgressSQLiteManager.getInstance().deleteAllData()
            WidgetUtils().saveUserInfo(uId: "", uToken: "")
            UserDefaults.standard.setValue("", forKey: token)
            UserDefaults.standard.setValue("", forKey: userId)
            UserDefaults.set(value: "", forKey: .myFoodsList)
            UserDefaults.set(value: "", forKey: .hidsoryFoodsAdd)
            UserInfoModel.shared.clearMsg()
        }
    }
}
