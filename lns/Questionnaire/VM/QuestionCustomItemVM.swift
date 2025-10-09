//
//  QuestionCustomItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/2.
//

import Foundation
import UIKit
import MCToast

class QuestionCustomItemVM: UIView {
    
    let selfHeight = kFitWidth(56)
    
    var maxLength = 3
    
    var numberChangeBlock:((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(textTapAction))
        self.addGestureRecognizer(tap)
        
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
    lazy var textField : NumericTextField = {
        let text = NumericTextField()
        text.placeholder = "输入数值"
        text.keyboardType = .numberPad
        text.font = .systemFont(ofSize: 16, weight: .medium)
        text.textColor = .COLOR_GRAY_BLACK_85
        text.textAlignment = .right
        text.delegate = self
        text.textContentType = nil
        
        return text
    }()
    lazy var unitLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.text = "g"
        
        return lab
    }()
//    lazy var textTapView: UIView = {
//        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(130), y: 0, width: kFitWidth(245), height: selfHeight))
//        vi.isUserInteractionEnabled = true
//        vi.backgroundColor = .clear
//        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(textTapAction))
//        vi.addGestureRecognizer(tap)
//        
//        return vi
//    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
//        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
        
        return vi
    }()
}

extension QuestionCustomItemVM{
    @objc func textTapAction() {
        self.textField.becomeFirstResponder()
    }
}

extension QuestionCustomItemVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(unitLabel)
        addSubview(lineView)
//        addSubview(textTapView)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(27))
        }
        unitLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.centerY.lessThanOrEqualToSuperview()
        }
        textField.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-38))
            make.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(160))
        }
        lineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(SCREEN_WIDHT - kFitWidth(95))
            make.height.equalTo(kFitWidth(1))
        }
//        textTapView.snp.makeConstraints { make in
//            make.top.height.right.equalToSuperview()
//            make.width.equalTo(kFitWidth(200))
//        }
    }
    func updateConstrait() {
        titleLabel.snp.remakeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(27))
        }
        unitLabel.snp.remakeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.centerY.lessThanOrEqualToSuperview()
        }
        textField.snp.remakeConstraints { make in
            make.right.equalTo(kFitWidth(-38))
            make.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(160))
        }
        lineView.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
//            make.width.equalTo(kFitWidth(343))
            make.width.equalTo(SCREEN_WIDHT - kFitWidth(32))
            make.height.equalTo(kFitWidth(1))
        }
    }
}

extension QuestionCustomItemVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        if string == ""{
            if self.numberChangeBlock != nil{
                if text.count > 0{
                    self.numberChangeBlock!("\(text.mc_clipFromPrefix(to: text.count-1))")
                }
            }
            return true
        }else if string == "0" && text.count == 0{
            return false
        }
        // 检查输入的字符是否是数字
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
//        let allowedCharacters = CharacterSet(charactersIn: ".,0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        if allowedCharacters.isSuperset(of: characterSet) == false{
            return false
        }
        
        if range.length > 0 || range.location >= 0{
            let textString = (textField.text ?? "")
            let firstStr = textString.mc_clipFromPrefix(to: range.location)
            let endStr = textString.mc_cutToSuffix(from: range.location+range.length)
            
            var resultString = ""
            if range.location == 0{
                if string == "0"{
                    if text == ""{
                        resultString = "0"
                    }else{
                        resultString = "\(endStr)"
                    }
                }else if string == "." || string == ","{
                    resultString = "0.\(endStr)"
                }else{
                    resultString = "\(firstStr)\(string)\(endStr)"
                }
            }else{
                if string == "0"{
                    if text == "" || text == "0"{
                        resultString = "0"
                    }else{
                        resultString = "\(firstStr)\(string)\(endStr)"
                    }
                }else{
                    resultString = "\(firstStr)\(string)\(endStr)"
                }
            }
            
            if resultString.count > maxLength{
                return false
            }
            textField.text = resultString
            
            if self.numberChangeBlock != nil{
                self.numberChangeBlock!("\(textField.text ?? "")")
            }
            return false
        }
        
        if textField.text?.count ?? 0 > maxLength{
            return false
        }
        
        if self.numberChangeBlock != nil{
            self.numberChangeBlock!("\(textField.text ?? "")\(string)")
        }
        
        return true
    }
}
