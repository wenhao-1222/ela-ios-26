//
//  PropotionResultCaloriVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/4.
//


import Foundation
import UIKit

class PropotionResultCaloriVM: UIView {
    
    let selfHeight = kFitWidth(54)
    
    var unit = "kcal"//kcal   kj
    var numberChangeBlock:((String)->())?
    var unitChangeBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var numberLabel : NumericTextField = {
        let lab = NumericTextField()
        lab.placeholder = "-"
        lab.delegate = self
        lab.keyboardType = .numberPad
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.textContentType = nil
        
        return lab
    }()
    lazy var numberTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
//        vi.isUserInteractionEnabled = false
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(numberTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.text = "热量"
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        return lab
    }()
    lazy var kjNumberLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        return lab
    }()
}

extension PropotionResultCaloriVM{
    @objc func numberTapAction() {
        numberLabel.becomeFirstResponder()
    }
    func changeKjNumber(numberString:String="-1") {
        let num = numberString == "-1" ? numberLabel.text : numberString
        let numFloat = num?.floatValue ?? 0
        
        if numFloat == 0{
            numberLabel.text = ""
            kjNumberLabel.text = "千卡（0千焦）"
            return
        }
        
        var kjNumber = "0"
//        if self.unit == "kj"{
            let kjNum = numFloat * 4.18585
            kjNumber = "\(WHUtils.convertStringToStringNoDigit("\(kjNum.rounded())") ?? "0")"
//        }else{
//            let kcalNum = numFloat / 4.18585
//            kjNumber = "\(WHUtils.convertStringToStringNoDigit("\(kcalNum.rounded())") ?? "0")"
//        }
        kjNumberLabel.text = "千卡（\(kjNumber)千焦）"
    }
    func refreshKcal(kjNumber:String) {
        kjNumberLabel.text = "千卡（\(kjNumber)千焦）"
        
        let numFloat = kjNumber.floatValue
        let kcalNum = numFloat / 4.18585
        numberLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(kcalNum.rounded())") ?? "0")"
    }
}

extension PropotionResultCaloriVM{
    func initUI() {
        addSubview(numberLabel)
        addSubview(tipsLabel)
        addSubview(numberTapView)
        addSubview(kjNumberLabel)
        
        setConstrait()
    }
    func setConstrait() {
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(tipsLabel.snp.bottom).offset(kFitWidth(5))
        }
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(5))
        }
        kjNumberLabel.snp.makeConstraints { make in
            make.left.equalTo(numberLabel.snp.right).offset(kFitWidth(3))
            make.bottom.equalTo(numberLabel).offset(kFitWidth(-4))
        }
        numberTapView.snp.makeConstraints { make in
            make.left.top.height.equalToSuperview()
            make.right.equalTo(kjNumberLabel)
        }
    }
}

extension PropotionResultCaloriVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textString = textField.text ?? ""
        if string == ""{
            if self.numberChangeBlock != nil{
                if textString.count > 0 {
                    self.numberChangeBlock!("\(textString.mc_clipFromPrefix(to: textString.count-1))")
                    self.changeKjNumber(numberString: "\(textString.mc_clipFromPrefix(to: textString.count-1))")
                }else{
                    self.changeKjNumber(numberString: "")
                    self.numberChangeBlock!("")
                }
            }
            return true
        }
        // 检查输入的字符是否是数字
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        if allowedCharacters.isSuperset(of: characterSet) == false{
            return false
        }
        if textString.count >= 5 {
            return false
        }
        if string == "0" && textString == "0"{
            return false
        }
        if self.numberChangeBlock != nil{
            self.numberChangeBlock!("\(textField.text ?? "")\(string)")
        }
        self.changeKjNumber(numberString: "\(textField.text ?? "")\(string)")
        
        return true
    }
}
