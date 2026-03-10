//
//  LogsMealsAlertSetRemarkVM.swift
//  lns
//
//  Created by Elavatine on 2024/10/16.
//


class LogsMealsAlertSetRemarkVM: UIView {
    
    let selfHeight = kFitWidth(56)
    var whiteViewHeight = kFitWidth(56)
    
    var remarkBlock:((String)->())?
    var timer: Timer?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: SCREEN_WIDHT-kFitWidth(32), height: whiteViewHeight))
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .COLOR_BG_BLACK_04//WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var penIcon : UIImageView = {
        let img = UIImageView()
//        img.setImgLocal(imgName: "logs_pen_icon")
        img.image = UIImage(named: "logs_pen_icon")?.withTintColor(.COLOR_BG_BLACK_045)
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var placeHoldLabel : UILabel = {
        let lab = UILabel()
        lab.text = "这里输入你的备注"
        lab.textColor = .COLOR_BG_BLACK_045//WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var textView : UITextView = {
        let vi = UITextView.init(frame: CGRect.init(x: kFitWidth(16), y: selfHeight*0.5-kFitWidth(16), width: SCREEN_WIDHT-kFitWidth(64), height: kFitWidth(32)))
        vi.textColor = .COLOR_TEXT_TITLE_0f1214
        vi.font = .systemFont(ofSize: 14, weight: .regular)
        vi.delegate = self
        vi.backgroundColor = .clear
        vi.returnKeyType = .done
        
        return vi
    }()
}

extension LogsMealsAlertSetRemarkVM{
    @objc func tapAction() {
        self.textView.becomeFirstResponder()
    }
    @objc func nothingAction(){
        self.textView.resignFirstResponder()
    }
    func updateContext(text:String) {
        if text.count > 0 {
            penIcon.isHidden = true
            placeHoldLabel.isHidden = true
            textView.text = text
        }else{
            penIcon.isHidden = false
            placeHoldLabel.isHidden = false
            textView.text = ""
        }
    }
    
    func startCountdown() {
        //一般倒计时是操作UI，使用主队列
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            // 定时器执行的操作
            DLLog(message: "timer:\(self.textView.text ?? "")")
            var string = self.textView.text ?? ""
            string = string.disable_emoji(text: string as NSString)
            if string.count > 400 {
                string = String(string.prefix(400))
            }
            self.textView.text = string
            
            if string.count == 0 {
                self.penIcon.isHidden = false
            }else{
                self.penIcon.isHidden = true
            }
        }
    }
    func disableTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

extension LogsMealsAlertSetRemarkVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(penIcon)
        whiteView.addSubview(placeHoldLabel)
        whiteView.addSubview(textView)
        
        setConstrait()
    }
    func setConstrait() {
        penIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(16))
        }
        placeHoldLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(36))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}

extension LogsMealsAlertSetRemarkVM:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == ""{
            if textView.text.count == 1 {
                penIcon.isHidden = false
                placeHoldLabel.isHidden = false
                self.textView.frame = CGRect.init(x: kFitWidth(16), y: self.selfHeight*0.5-kFitWidth(16), width: SCREEN_WIDHT-kFitWidth(64), height: kFitWidth(32))
            }
            return true
        }
        if text == "\n"{
            self.textView.resignFirstResponder()
            return false
        }
        
        if textView.textInputMode?.primaryLanguage == "emoji"{
            return false
        }
        penIcon.isHidden = true
        placeHoldLabel.isHidden = true
        
        self.textView.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(8), width: SCREEN_WIDHT-kFitWidth(64), height: kFitWidth(40))
        
        if textView.text.count >= 100{
            return false
        }
        
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.remarkBlock != nil{
            self.remarkBlock!(self.textView.text)
        }
    }
}
