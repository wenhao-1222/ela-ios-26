//
//  WithDrawMoneyVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/21.
//

import Foundation

class WithDrawMoneyVM: UIView {
    
    let selfHeight = kFitWidth(159)
    
    var money = "0"
    var limitMoney = Float(0)
    
    var numberChangeBlock:((Bool)->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        initUI()
    }
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "withdraw_bank_icon")
        return img
    }()
    lazy var wechatLab: UILabel = {
        let lab = UILabel()
        lab.text = "提现金额"
        lab.textColor = WHColor_16(colorStr: "222222")
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        return lab
    }()
    lazy var moneyLab: UILabel = {
        let lab = UILabel()
        lab.text = "¥"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 32, weight: .medium)
        return lab
    }()
    lazy var moneyTextField: NumericTextField = {
        let text = NumericTextField()
        text.keyboardType = .decimalPad
        text.placeholder = "0.00"
        text.textColor = .COLOR_GRAY_BLACK_85
        text.font = .systemFont(ofSize: 32, weight: .medium)
        text.delegate = self
        text.textAlignment = .left
        text.textContentType = nil
        
        return text
    }()
    lazy var moneyTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(textEditAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        return vi
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "可提现余额 ￥\(money)"
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    lazy var allMoneyButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("全部提现", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(allMoneyAction), for: .touchUpInside)
        
        return btn
    }()
}

extension WithDrawMoneyVM{
    @objc func allMoneyAction() {
        moneyTextField.text = self.money
        changeMoney(moneyStr: self.money)
    }
    @objc func textEditAction(){
        moneyTextField.becomeFirstResponder()
    }
    func changeMoney(moneyStr:String) {
        let moneyFloat = (moneyStr as NSString).floatValue
        if moneyFloat >= limitMoney{
            if self.numberChangeBlock != nil{
                self.numberChangeBlock!(true)
            }
        }else{
            if self.numberChangeBlock != nil{
                self.numberChangeBlock!(false)
            }
        }
    }
}

extension WithDrawMoneyVM{
    func initUI() {
        addSubview(iconImgView)
        addSubview(wechatLab)
        addSubview(moneyLab)
        addSubview(moneyTextField)
        addSubview(tipsLabel)
        addSubview(allMoneyButton)
        addSubview(lineView)
        addSubview(moneyTapView)
        
        setConstrait()
    }
    func setConstrait() {
        iconImgView.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(24))
        }
        wechatLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(48))
            make.centerY.lessThanOrEqualTo(iconImgView)
        }
        moneyLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(60))
        }
        moneyTextField.snp.makeConstraints { make in
            make.left.equalTo(moneyLab.snp.right).offset(kFitWidth(10))
            make.centerY.lessThanOrEqualTo(moneyLab)
        }
        lineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(1))
            make.top.equalTo(kFitWidth(108))
        }
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(lineView.snp.bottom).offset(kFitWidth(12))
        }
        allMoneyButton.snp.makeConstraints { make in
            make.left.equalTo(tipsLabel.snp.right).offset(kFitWidth(2))
            make.centerY.lessThanOrEqualTo(tipsLabel)
            make.height.equalTo(kFitWidth(38))
        }
        moneyTapView.snp.makeConstraints { make in
            make.left.equalTo(moneyLab.snp.right).offset(kFitWidth(10))
            make.centerY.lessThanOrEqualTo(moneyLab)
            make.height.equalTo(kFitWidth(50))
            make.right.equalTo(kFitWidth(-10))
        }
    }
}

extension WithDrawMoneyVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textString = (textField.text ?? "")
        if string == ""{
            
//            if self.numberChangeBlock != nil{
                if textString.count > 0 {
                    self.changeMoney(moneyStr: "\(textString.mc_clipFromPrefix(to: textString.count-1))")
//                    self.numberChangeBlock!("\(textString.mc_clipFromPrefix(to: textString.count-1))")
                }else{
                    self.changeMoney(moneyStr: "")
//                    self.numberChangeBlock!("")
                }
//            }
            return true
        }
        // 检查输入的字符是否是数字
        let allowedCharacters = CharacterSet(charactersIn: ",.0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        if allowedCharacters.isSuperset(of: characterSet) == false{
            return false
        }
        if string == "0" && textString == ""{
            textField.text = "0."
            return false
        }
        if string == "." || string == ","{
            if textString.contains("."){
                return false
            }
            if textString == ""{
//                textField.text = "0."
                return false
            }
            return true
        }
        if textString.contains("."){
            let arr = textString.components(separatedBy: ".")
            if arr.count > 1{
                let decimalString = arr[1]
                if decimalString.count >= 2 {
                    return false
                }
                self.changeMoney(moneyStr: "\(textField.text ?? "")\(string)")
                return true
            }
        }else if textString.contains(","){
            let arr = textString.components(separatedBy: ",")
            if arr.count > 1{
                let decimalString = arr[1]
                if decimalString.count >= 2 {
                    return false
                }
                self.changeMoney(moneyStr: "\(textField.text ?? "")\(string)")
                return true
            }
        }
        
        if range.length > 0 {
            return true
        }
        if textField.text?.count ?? 0 >= 8 {
            return false
        }
        self.changeMoney(moneyStr: "\(textField.text ?? "")\(string)")
//        if self.numberChangeBlock != nil{
//            self.numberChangeBlock!("\(textField.text ?? "")\(string)")
//        }
        return true
    }
}
