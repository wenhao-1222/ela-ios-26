//
//  PlanCreateNameVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/12.
//

import Foundation
import UIKit

class PlanCreateNameVM: UIView {
    
    let selfHeight = kFitWidth(99)
    var timer: Timer?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
//        startCountdown()
        //监听textField内容改变通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.greetingTextFieldChanged),
                                               name:NSNotification.Name(rawValue:"UITextFieldTextDidChangeNotification"),
                                               object: self.textField)
//        self.textField.addTarget(self, action: #selector(textFieldChanged(textField: )), for: .editingChanged)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var iconImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "create_plan_name_icon")
        
        return img
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "计划名称"
        
        return lab
    }()
    lazy var textBgView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var textField : UITextField = {
        let text = UITextField()
        text.placeholder = "计划名称15字以内"
        text.font = .systemFont(ofSize: 16, weight: .regular)
        text.textColor = .COLOR_GRAY_BLACK_85
        text.delegate = self
        text.returnKeyType = .done
        text.textContentType = nil
        
        return text
    }()
}

extension PlanCreateNameVM{
    func initUI() {
        addSubview(iconImgView)
        addSubview(titleLabel)
        addSubview(textBgView)
        textBgView.addSubview(textField)
        
        setConstrait()
    }
    func setConstrait() {
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(24))
            make.width.height.equalTo(kFitWidth(16))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(iconImgView)
        }
        textBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(51))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(48))
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.height.equalToSuperview()
        }
    }
    func startCountdown() {
        //一般倒计时是操作UI，使用主队列
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            // 定时器执行的操作
            DLLog(message: "timer:\(self.textField.text ?? "")")
            var string = self.textField.text ?? ""
            string = string.disable_emoji(text: string as NSString)
//            if string.count > 15 {
//                string = String(string.prefix(15))
//            }
            
            self.textField.text = string
        }
    }
    func disableTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

extension PlanCreateNameVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if let _: UITextRange = textField.markedTextRange {
//            if string.isStrokes(){
//                return true
//            }
//        }
        if string == ""{
            return true
        }else if string == "。"{
            return false
        }
//        DLLog(message: "primaryLanguage:\(textField.textInputMode?.primaryLanguage ?? "")")
        if textField.textInputMode?.primaryLanguage == "emoji"{
            return false
        }
//        else if textField.textInputMode?.primaryLanguage == "zh-Hans"{
//            return true
//        }
        if string.isNineKeyBoard() {
            return true
        }else{
            if string.hasEmoji(){
                return false
            }
//            if string.containsEmoji(){
//                return false
//            }
//            if string.hasEmoji() || string.containsEmoji(){
//                return false
//            }
//            if textField.textInputMode?.primaryLanguage == "emoji" || !((textField.textInputMode?.primaryLanguage) != nil){
//                return false
//            }
        }
        
        if textField.text?.count ?? 0 >= 50 {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
    }
    //textField内容改变通知响应
    @objc func greetingTextFieldChanged(obj: Notification) {
        DLLog(message: "greetingTextFieldChanged")
        //非markedText才继续往下处理
        guard let _: UITextRange = textField.markedTextRange else{
            //当前光标的位置（后面会对其做修改）
            let cursorPostion = textField.offset(from: textField.endOfDocument,
                                                 to: textField.selectedTextRange!.end)
            //判断非中文非字母非数字的正则表达式
            let pattern = "[^A-Za-z0-9\\u0020\\u4E00-\\u9FA5]"
//            非中文：[^\\u4E00-\\u9FA5]
//            非英文：[^A-Za-z]
//            非数字：[^0-9]
//            非中文或英文：[^A-Za-z\\u4E00-\\u9FA5]
//            非英文或数字：[^A-Za-z0-9]
            //替换后的字符串（过滤调非中文字符）
            var str = self.textField.text!.pregReplace(pattern: pattern, with: "")
            if str.count > 20 {
                str = String(str.prefix(20))
            }
            self.textField.text = str
             
            //让光标停留在正确位置
            let targetPostion = textField.position(from: textField.endOfDocument,
                                                   offset: cursorPostion)!
            textField.selectedTextRange = textField.textRange(from: targetPostion,
                                                              to: targetPostion)
            return
        }
    }
}

extension PlanCreateNameVM{
    @objc func textFieldChanged(textField:UITextField) {
        let toBeString = textField.text ?? ""
        
        if !self.isInputRuleAndBlank(string: toBeString){
            textField.text = toBeString.disable_emoji(text: toBeString as NSString)
            return
        }
        
    }
    
    func isInputRuleAndBlank(string:String) -> Bool {
        let pattern = "[^A-Za-z0-9\\u4E00-\\u9FA5]*$"
                       
        let pred = NSPredicate(format: "SELF MATCHES %@",pattern)
        return pred.evaluate(with: string)
    }
}
