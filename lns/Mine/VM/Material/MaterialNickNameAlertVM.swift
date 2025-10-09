//
//  MaterialNickNameAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/14.
//

import Foundation
import MCToast

class MaterialNickNameAlertVM: UIView {
    
    var maxLength = 20
    var isUpdatePlanName = false
    var confirmBlock:((String)->())?
    var timer: Timer?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
        self.alpha = 0
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        //监听textField内容改变通知
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(self.greetingTextFieldChanged),
//                                               name:NSNotification.Name(rawValue:"UITextFieldTextDidChangeNotification"),
//                                               object: self.textField)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(64)))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        vi.alpha = 0
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F5F5F5")
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(4)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var textField : UITextField = {
        let text = UITextField()
        text.placeholder = "请输入用户名"
        text.font = .systemFont(ofSize: 16, weight: .regular)
        text.textColor = .COLOR_GRAY_BLACK_85
        text.delegate = self
        text.returnKeyType = .done
        text.textContentType = nil
        
        return text
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("确定", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(4)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        
        return btn
    }()
}

extension MaterialNickNameAlertVM {
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(bgView)
        bgView.addSubview(textField)
        whiteView.addSubview(confirmButton)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(275))
            make.height.equalTo(kFitWidth(40))
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.height.equalToSuperview()
        }
        confirmButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(40))
            make.width.equalTo(kFitWidth(60))
        }
    }
}


extension MaterialNickNameAlertVM{
    @objc func showView() {
        self.isHidden = false
        self.textField.text = ""
        self.textField.becomeFirstResponder()
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.alpha = 1
            self.whiteView.alpha = 1
        }
    }
    @objc func hiddenView() {
        self.textField.resignFirstResponder()
        self.disableTimer()
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.alpha = 0
            self.whiteView.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
    }
    @objc func nothingToDo() {
        
    }
    @objc func confirmAction(){
        var name = self.textField.text ?? ""
        name = name.replacingOccurrences(of: " ", with: "")
//        if name.count == 0{
//            return
//        }
        if self.confirmBlock != nil{
            self.confirmBlock!(name)
        }
        self.hiddenView()
    }
    
    func startCountdown() {
        //一般倒计时是操作UI，使用主队列
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            // 定时器执行的操作
            DLLog(message: "timer:\(self.textField.text ?? "")")
            guard let _: UITextRange = self.textField.markedTextRange else{
                var string = self.textField.text ?? ""
                string = string.disable_emoji(text: string as NSString)
                if string.count > 15 {
                    string = String(string.prefix(15))
                }
                
                self.textField.text = string
                return
            }
        }
    }
    func disableTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

extension MaterialNickNameAlertVM{
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            DLLog(message: "keyboardSize:\(keyboardSize)")
//            DLLog(message: "\(SCREEN_HEIGHT)")
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: keyboardSize.origin.y-kFitWidth(32))
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT-kFitWidth(32))
        }completion: { t in
            self.hiddenView()
        }
    }
}

extension MaterialNickNameAlertVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == ""{
            return true
        }
        if string == "。"{
            return false
        }
//        if string.isNineKeyBoard(){
//            return true
//        }else{
////            if self.isUpdatePlanName{
////                if string.hasEmoji() || string.containsEmoji() || string.isChineseNumberAsciiNoWhiteSpace(){
////                    return false
////                }
////            }else{
//                if string.hasEmoji() || string.containsEmoji() || string.isChineseNumberAscii(){
//                    return false
//                }
////            }
//        }

        if textField.textInputMode?.primaryLanguage == "emoji"{
            return false
        }
        
        if range.length > 0 {
            return true
        }
//        if textField.text?.count ?? 0 >= maxLength{
//            return false
//        }
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
//        if self.isUpdatePlanName == true{
            if self.confirmBlock != nil{
                var name = self.textField.text ?? ""
                name = name.replacingOccurrences(of: " ", with: "")
                self.confirmBlock!(name)
            }
//        }
        
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        var stri = textField.text
        stri = stri?.replacingOccurrences(of: "。", with: " ")
        
        self.textField.text = stri
    }
    //textField内容改变通知响应
    @objc func greetingTextFieldChanged(obj: Notification) {
        //非markedText才继续往下处理
        guard let _: UITextRange = textField.markedTextRange else{
            //当前光标的位置（后面会对其做修改）
            let cursorPostion = textField.offset(from: textField.endOfDocument,
                                                 to: textField.selectedTextRange!.end)
            
            DLLog(message: "greetingTextFieldChanged:\(obj)")
            //判断非中文非字母非数字的正则表达式
            let pattern = "[^A-Za-z0-9\\u4E00-\\u9FA5]"
//            非中文：[^\\u4E00-\\u9FA5]
//            非英文：[^A-Za-z]
//            非数字：[^0-9]
//            句号：\\u3002
//            非中文或英文：[^A-Za-z\\u4E00-\\u9FA5]
//            非英文或数字：[^A-Za-z0-9]
            //替换后的字符串（过滤调非中文字符）
            var str = textField.text!.pregReplace(pattern: pattern, with: "")
            if str.count > maxLength {
                str = String(str.prefix(maxLength))
            }
            textField.text = str
             
            //让光标停留在正确位置
            let targetPostion = textField.position(from: textField.endOfDocument,
                                                   offset: cursorPostion)!
            textField.selectedTextRange = textField.textRange(from: targetPostion,
                                                              to: targetPostion)
            return
        }
    }
}
