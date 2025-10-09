//
//  BindPhoneVerifyCodeButton.swift
//  lns
//
//  Created by LNS2 on 2024/4/3.
//

import Foundation
import UIKit

class BindPhoneVerifyCodeButton: FeedBackView {
    
    let selfHeight = kFitWidth(56)
    
    var getCodeBlock:(()->())?
    var judgeVerifyCodeBlock:((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(327), height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(8)
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = kFitWidth(1)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var codeTextField : NumericTextField = {
        let text = NumericTextField()
        text.keyboardType = .numberPad
        text.font = .systemFont(ofSize: 18, weight: .medium)
        text.placeholder = "请输入验证码"
        text.delegate = self
//        text.textContentType = .name
        
        return text
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
}

extension BindPhoneVerifyCodeButton{
    @objc func getCodeAction () {
        if self.getCodeBlock != nil{
            self.getCodeBlock!()
        }
    }
    @objc func tapAction(){
        self.codeTextField.becomeFirstResponder()
    }
}

extension BindPhoneVerifyCodeButton{
    func initUI() {
        addSubview(getCodeBtn)
        addSubview(codeTextField)
        
        setConstrait()
    }
    func setConstrait() {
        getCodeBtn.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-24))
            make.top.height.equalToSuperview()
        }
        codeTextField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.top.height.equalToSuperview()
//            make.right.equalTo(kFitWidth(-100))
        }
    }
}

extension BindPhoneVerifyCodeButton:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textString = textField.text ?? ""
        if string == ""{
            if self.judgeVerifyCodeBlock != nil && textString.count > 0{
                self.judgeVerifyCodeBlock!("\(textString.mc_cutToSuffix(from: textString.count-1))")
            }
            return true
        }
        // 检查输入的字符是否是数字
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        if allowedCharacters.isSuperset(of: characterSet) == false{
            return false
        }
        if textField.text?.count ?? 0 > 3 {
            return false
        }
        if self.judgeVerifyCodeBlock != nil{
            self.judgeVerifyCodeBlock!("\(textString)\(string)")
        }
        return true
    }
}
