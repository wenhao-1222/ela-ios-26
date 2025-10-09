//
//  AITipsAlertConfirmBtn.swift
//  lns
//
//  Created by Elavatine on 2025/3/6.
//


class AITipsAlertConfirmBtn: UIView {
    
    let selfHeight = kFitWidth(55) + WHUtils().getBottomSafeAreaHeight()
    var countTime = 5
    var timer: Timer?
    
    var canCloseBlock:(()->())?
    var confirmBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
        
        self.addShadow()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var confirmBtn: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.setTitle("确认", for: .normal)
        btn.backgroundColor = .COLOR_GRAY_C4C4C4
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("确认（\(countTime)）", for: .disabled)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_GRAY_C4C4C4), for: .disabled)
        btn.isEnabled = false
        
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        btn.enablePressEffect()
        
        return btn
    }()
}

extension AITipsAlertConfirmBtn{
    func startCountdown() {
        DLLog(message: "AITipsAlertConfirmBtn isShowAiTipsAlert:\(UserDefaults.getString(forKey: .isShowAiTipsAlert))")
        if UserDefaults.getString(forKey: .isShowAiTipsAlert) == "2"{
            self.confirmBtn.isEnabled = true
            self.canCloseBlock?()
            return
        }
        //一般倒计时是操作UI，使用主队列
//        self.getCodeTime = 59
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            // 定时器执行的操作
            self.countTime = self.countTime - 1
            if self.countTime <= 0{
                self.disableTimer()
                
                DispatchQueue.main.async {
                    self.confirmBtn.isEnabled = true
//                    self.confirmBtn.backgroundColor = .THEME
                }
            }else{
                DispatchQueue.main.async {
                    self.confirmBtn.setTitle("确认（\(self.countTime)）", for: .disabled)
                }
            }
        }
    }
    func disableTimer() {
//        DLLog(message: "scrollViewDidScroll : disableTimer")
        self.timer?.invalidate()
        self.timer = nil
        self.confirmBtn.isEnabled = true
        
        self.canCloseBlock?()
//        self.confirmBtn.backgroundColor = .THEME
    }
    
    @objc func confirmAction() {
//        DLLog(message: "确认")
        self.confirmBlock?()
    }
}

extension AITipsAlertConfirmBtn{
    func initUI() {
        addSubview(confirmBtn)
        
        confirmBtn.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(7))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(44))
        }
    }
}
