//
//  DataAddItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/17.
//

import Foundation
import UIKit

class DataAddItemVM: UIView {
    
    let selfHeight = kFitWidth(50)
    var maxNumber = 3
    var decimalNum = 1
    
    var dataChangeBlock:((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var leftTitleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var unitLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.text = "cm"
        return lab
    }()
    lazy var textField : NumericTextField = {
        let text = NumericTextField()
        text.placeholder = "选填"
//        text.placeholder = "请输入数值"
        text.font = .systemFont(ofSize: 14, weight: .medium)
        text.textColor = .COLOR_TEXT_TITLE_0f1214
        text.keyboardType = .decimalPad
        text.textAlignment = .right
        text.delegate = self
        text.textContentType = nil
//        text.clearButtonMode = .whileEditing
        
        return text
    }()
    lazy var tapView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
}

extension DataAddItemVM{
    @objc func tapAction() {
        self.textField.becomeFirstResponder()
    }
}
extension DataAddItemVM{
    func initUI() {
        addSubview(leftTitleLabel)
        addSubview(unitLabel)
        addSubview(textField)
        addSubview(lineView)
//        addSubview(tapView)
        
        setConstrait()
    }
    func setConstrait() {
        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        unitLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        textField.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-46))
//            make.centerY.lessThanOrEqualToSuperview()
//            make.width.equalTo(kFitWidth(160))
//            make.right.equalTo(unitLabel.snp.left).offset(kFitWidth(-8))
            make.top.height.equalToSuperview()
            make.left.equalTo(leftTitleLabel.snp.right).offset(kFitWidth(50))
        }
//        tapView.snp.makeConstraints { make in
//            make.top.left.right.height.equalToSuperview()
////            make.width.equalTo(kFitWidth(160))
////            make.left.equalTo(textField.snp.right).offset(kFitWidth(-100))
////            make.left.equalToSuperview()
//        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(0.5))
            make.bottom.equalToSuperview()
        }
    }
}

extension DataAddItemVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textString = (textField.text ?? "")
        if string == ""{
            if textString.count > 0{
                self.updateTextContent(text: textString.mc_clipFromPrefix(to: textString.count-1))
            }
            return true
        }
        // 检查输入的字符是否是数字
        let allowedCharacters = CharacterSet(charactersIn: ".,0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        if allowedCharacters.isSuperset(of: characterSet) == false{
            return false
        }
        if range.length > 0 || (range.location == 0 && range.length == 0) {
            let firstStr = textString.mc_clipFromPrefix(to: range.location)
            let endStr = textString.mc_cutToSuffix(from: range.location+range.length)
            if range.location == 0{
                if string == "0"{
                    textField.text = "\(endStr)"
                }else if string == "."{
                    textField.text = "0.\(endStr)"
                }else if string == ","{
                    textField.text = "0,\(endStr)"
                }else{
                    textField.text = "\(firstStr)\(string)\(endStr)"
                }
            }else{
                textField.text = "\(firstStr)\(string)\(endStr)"
            }
            self.updateTextContent(text: "\(textField.text ?? "")")
            return false
        }
        if string == "0" && textString == "0"{
            return false
        }
        if string == "."{
            if textString.contains(".") || textString == ""{
                return false
            }
            self.updateTextContent(text: "\(textString).")
            return true
        }else if string == ","{
            if textString.contains(",") || textString == ""{
                return false
            }
            self.updateTextContent(text: "\(textString),")
            return true
        }
        if textString.contains("."){
            let arr = textString.components(separatedBy: ".")
            if arr.count > 1{
                let decimalString = arr[1]
                if decimalString.count > decimalNum - 1 {
                    return false
                }
                self.updateTextContent(text: "\(textString)\(string)")
                return true
            }
        }else if textString.contains(","){
            let arr = textString.components(separatedBy: ",")
            if arr.count > 1{
                let decimalString = arr[1]
                if decimalString.count > 0 {
                    return false
                }
                self.updateTextContent(text: "\(textString)\(string)")
                return true
            }
        }
        
        if textField.text?.count ?? 0 >= maxNumber{
            return false
        }
        
        if textString == "0"{
            textField.text = "\(string)"
            self.updateTextContent(text: "\(string)")
            return false
        }
        self.updateTextContent(text: "\(textString)\(string)")
        return true
    }
    func updateTextContent(text:String) {
        if self.dataChangeBlock != nil{
            self.dataChangeBlock!(text)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.dataChangeBlock != nil{
            self.dataChangeBlock!(textField.text ?? "")
        }
    }
}
