//
//  SportAddAlertItemVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/22.
//

class SportAddAlertItemVM: UIView {
    
    var dataChangeBlock:((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(167), height: kFitWidth(64)))
        self.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(8)
        self.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var numberText: UITextField = {
        let text = UITextField()
        text.placeholder = "0.0"
        text.keyboardType = .decimalPad
        text.textColor = .COLOR_GRAY_BLACK_85
        text.font = .systemFont(ofSize: 24, weight: .bold)
        text.textAlignment = .right
        text.delegate = self
        text.textContentType = nil
        
        return text
    }()
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .bold)
        return lab
    }()
    lazy var unitLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .bold)
        return lab
    }()
}

extension SportAddAlertItemVM{
    @objc func tapAction() {
        self.numberText.becomeFirstResponder()
    }
}

extension SportAddAlertItemVM{
    func initUI() {
        addSubview(numberText)
        addSubview(nameLabel)
        addSubview(unitLabel)
        
        setConstrait()
    }
    func setConstrait() {
        numberText.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-86))
            make.centerY.lessThanOrEqualToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(89))
            make.top.equalTo(kFitWidth(18))
        }
        unitLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(kFitWidth(4))
        }
    }
}

extension SportAddAlertItemVM:UITextFieldDelegate{
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
                    if endStr == ""{
                        textField.text = "0"
                    }else{
                        textField.text = "\(endStr)"
                    }
                }else if string == "."{
                    textField.text = "0.\(endStr)"
                }else if string == ","{
                    textField.text = "0,\(endStr)"
                }else{
                    if "\(firstStr)\(string)\(endStr)".floatValue >= 1000{
                        return false
                    }
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
                if decimalString.count > 0 {
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
        
        if textField.text?.count ?? 0 >= 3 {
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
