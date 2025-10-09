//
//  FoodsCreateItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import UIKit

class FoodsCreateItemVM: UIView {
    
    let selfHeight = kFitWidth(56)
    var numberChangeBlock:((String)->())?
    
    var maxLength = 2
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var textField: NumericTextField = {
        let text = NumericTextField()
        text.keyboardType = .decimalPad
        text.placeholder = "请输入数值"
        text.textColor = .COLOR_GRAY_BLACK_85
        text.font = .systemFont(ofSize: 16, weight: .medium)
        text.textAlignment = .right
        text.delegate = self
        text.returnKeyType = .done
        text.textContentType = nil
        
        return text
    }()
    lazy var unitLab : UILabel = {
        let lab = UILabel()
        lab.text = "g"
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        return vi
    }()
}

extension FoodsCreateItemVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(unitLab)
        addSubview(lineView)
        
        
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.isSecureTextEntry = false
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        unitLab.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        textField.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-34))
            make.top.height.equalToSuperview()
            make.left.equalTo(kFitWidth(100))
//            make.centerY.lessThanOrEqualToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(1))
        }
    }
}

extension FoodsCreateItemVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var textString = (textField.text ?? "")
        if string == ""{
            if self.numberChangeBlock != nil{
                if textString.count > 0 {
                    self.numberChangeBlock!("\(textString.mc_clipFromPrefix(to: textString.count-1))".replacingOccurrences(of: ",", with: "."))
                }else{
                    self.numberChangeBlock!("")
                }
            }
            return true
        }
        // 检查输入的字符是否是数字
        let allowedCharacters = CharacterSet(charactersIn: ".,0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        if allowedCharacters.isSuperset(of: characterSet) == false{
            self.textField.text = ""
            self.numberChangeBlock!("")
            return false
        }
        
        if range.length > 0 || (range.location == 0 && range.length == 0){
            let firstStr = textString.mc_clipFromPrefix(to: range.location)
            let endStr = textString.mc_cutToSuffix(from: range.location+range.length)
//            textField.text = "\(firstStr)\(string)\(endStr)"
            
            if range.location == 0{
                if string == "0"{
                    if textString == ""{
                        textField.text = "0"
                    }else{
                        textField.text = "\(endStr)"
                    }
//                    textField.text = "\(endStr)"
                }else if string == "." || string == ","{
                    textField.text = "0.\(endStr)"
                }else{
                    let numStr = "\(firstStr)\(string)\(endStr)"
                    let numFloat = numStr.floatValue
                    
                    if numFloat > 999.9{
                        return false
                    }
                    
                    textField.text = "\(firstStr)\(string)\(endStr)"
                }
            }else{
                let numStr = "\(firstStr)\(string)\(endStr)"
                let numFloat = numStr.floatValue
                
                if numFloat > 999.9{
                    return false
                }
                textField.text = "\(firstStr)\(string)\(endStr)"
            }
            if self.numberChangeBlock != nil{
                self.numberChangeBlock!("\(textField.text ?? "")".replacingOccurrences(of: ",", with: "."))
            }
            return false
        }
        if string == "0" && textString == "0"{
            return false
        }
        if (string == "." && textString.contains(".")) || (string == "," && textString.contains(",")){
            return false
        }
        if (string == "." || string == ",") && textString == ""{
//            textField.text = "0."
            return false
        }
        if textString.contains("."){
            let arr = textString.components(separatedBy: ".")
            if arr.count > 1{
                let decimalString = arr[1]
                if decimalString.count >= 1 {
                    return false
                }
                if self.numberChangeBlock != nil{
                    self.numberChangeBlock!("\(textField.text ?? "")\(string)".replacingOccurrences(of: ",", with: "."))
                }
                return true
            }
        }else if textString.contains(","){
            let arr = textString.components(separatedBy: ",")
            if arr.count > 1{
                let decimalString = arr[1]
                if decimalString.count >= 1 {
                    return false
                }
                if self.numberChangeBlock != nil{
                    self.numberChangeBlock!("\(textField.text ?? "")\(string)".replacingOccurrences(of: ",", with: "."))
                }
                return true
            }
        }
        
        if textField.text?.count ?? 0 >= maxLength {
            return false
        }
        
        if textString == "0"{
            if string == "." || string == ","{
                return true
            }
            textField.text = "\(string)"
            if self.numberChangeBlock != nil{
                self.numberChangeBlock!("\(string)".replacingOccurrences(of: ",", with: "."))
            }
            return false
        }
        let numStr = "\(textField.text ?? "")\(string)"
        let numFloat = numStr.floatValue
        
        if numFloat > 999.9{
            return false
        }
        
        if self.numberChangeBlock != nil{
            self.numberChangeBlock!("\(textField.text ?? "")\(string)".replacingOccurrences(of: ",", with: "."))
        }
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
    }
}
