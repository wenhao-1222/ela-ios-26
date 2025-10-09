//
//  PropotionResultNumberVM.swift
//  lns
//
//  Created by Elavatine on 2025/4/25.
//


class PropotionResultNumberVM: UIView {
    
    let selfHeight = kFitHeight(266)
    
    var numberChangeBlock:((String)->())?
    var maxLength = 5
    var defaultNumer = 1
    var inputNumer = Double(1)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: kFitWidth(10), width: SCREEN_WIDHT, height: selfHeight-kFitWidth(10)))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .COLOR_BG_WHITE
        
        return vi
    }()
    lazy var leftTitleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "本次摄入"
        
        return lab
    }()
    lazy var textField : NumericTextField = {
        let text = NumericTextField()
        text.placeholder = "100"
        text.keyboardType = .decimalPad
        text.font = .systemFont(ofSize: 16, weight: .medium)
        text.textColor = .COLOR_TEXT_TITLE_0f1214
        text.textAlignment = .left
        text.delegate = self
        text.textContentType = nil
        
        return text
    }()
    lazy var specLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "毫升"
        return lab
    }()
    lazy var numTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(numberTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
        return vi
    }()
    lazy var naturalBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        vi.layer.cornerRadius = kFitWidth(13)
        vi.clipsToBounds = true
        
        return vi
    }()
    //foods_merge_calories_icon
    lazy var caloriesIconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "foods_merge_calories_icon")
        return img
    }()
    lazy var caloriesLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 20, weight: .semibold)
        
        return lab
    }()
    lazy var caloriesUnitLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
//        lab.text = "热量（千卡）"
        lab.text = "千卡"
        
        return lab
    }()
    lazy var dottedLineView: DottedLineView = {
        let vi = DottedLineView.init(frame: CGRect.init(x: kFitWidth(12), y: kFitWidth(55), width: SCREEN_WIDHT-kFitWidth(56), height: kFitHeight(1)))
        
        return vi
    }()
    lazy var carboCircleView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(2.5)
        vi.clipsToBounds = true
        vi.backgroundColor = .COLOR_CARBOHYDRATE
        return vi
    }()
    lazy var carboNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var proteinCircleView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(2.5)
        vi.clipsToBounds = true
        vi.backgroundColor = .COLOR_PROTEIN
        return vi
    }()
    lazy var proteinNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var fatCircleView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(2.5)
        vi.clipsToBounds = true
        vi.backgroundColor = .COLOR_FAT
        return vi
    }()
    lazy var fatNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
}

extension PropotionResultNumberVM{
    func updateUI(dict:NSDictionary) {
//        self.caloriesLabel.text = dict.stringValueForKey(key: "calories")
        textField.text = dict.stringValueForKey(key: "measurementNum")
        self.inputNumer = dict.stringValueForKey(key: "measurementNum").doubleValue
        self.defaultNumer = dict.stringValueForKey(key: "measurementNum").intValue
        let caloriesAttr = NSMutableAttributedString(string: dict.stringValueForKey(key: "calories"))
        let caloriesUnitAttr = NSMutableAttributedString(string: "千卡")
//        let caloriesUnitAttr = NSMutableAttributedString(string: "热量(千卡)")
        
        caloriesAttr.yy_color = .COLOR_TEXT_TITLE_0f1214
        caloriesAttr.yy_font = .systemFont(ofSize: 20, weight: .semibold)
        caloriesUnitAttr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        caloriesUnitAttr.yy_font = .systemFont(ofSize: 11, weight: .regular)
        caloriesAttr.append(caloriesUnitAttr)
        self.caloriesLabel.attributedText = caloriesAttr
        
        self.carboNumLabel.text = "碳水 \(dict.stringValueForKey(key: "carbohydrate"))g"
        self.proteinNumLabel.text = "蛋白质 \(dict.stringValueForKey(key: "protein"))g"
        self.fatNumLabel.text = "脂肪 \(dict.stringValueForKey(key: "fat"))g"
    }
    
    @objc func numberTapAction() {
        self.textField.becomeFirstResponder()
    }
}

extension PropotionResultNumberVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(leftTitleLab)
        whiteView.addSubview(textField)
        whiteView.addSubview(specLab)
        whiteView.addSubview(lineView)
        whiteView.addSubview(numTapView)
        whiteView.addSubview(naturalBgView)
        naturalBgView.addSubview(caloriesIconImgView)
        naturalBgView.addSubview(caloriesLabel)
//        naturalBgView.addSubview(caloriesUnitLabel)
        naturalBgView.addSubview(dottedLineView)
        naturalBgView.addSubview(carboCircleView)
        naturalBgView.addSubview(carboNumLabel)
        naturalBgView.addSubview(proteinCircleView)
        naturalBgView.addSubview(proteinNumLabel)
        naturalBgView.addSubview(fatCircleView)
        naturalBgView.addSubview(fatNumLabel)
        
        setConstrait()
    }
    func setConstrait() {
        leftTitleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(20))
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(leftTitleLab.snp.right).offset(kFitWidth(17))
//            make.right.equalTo(kFitWidth(-80))
            make.centerY.lessThanOrEqualTo(leftTitleLab)
            make.height.equalTo(kFitWidth(30))
        }
        specLab.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(leftTitleLab)
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(81))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(1))
            make.top.equalTo(kFitWidth(52))
        }
        numTapView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.bottom.equalTo(lineView)
        }
        naturalBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(lineView.snp.bottom).offset(kFitWidth(18))
            make.height.equalTo(kFitWidth(102))
        }
        caloriesIconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(kFitWidth(18))
            make.width.height.equalTo(kFitWidth(20))
        }
        caloriesLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriesIconImgView.snp.right).offset(kFitWidth(3))
            make.centerY.lessThanOrEqualTo(caloriesIconImgView)
        }
//        caloriesUnitLabel.snp.makeConstraints { make in
//            make.left.equalTo(caloriesLabel.snp.right).offset(kFitWidth(3))
//            make.bottom.equalTo(caloriesLabel)
//        }
//        let labWidth = SCREEN_WIDHT-kFitWidth(150)
        carboCircleView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(27))
            make.top.equalTo(kFitWidth(74))
            make.width.height.equalTo(kFitWidth(5))
        }
        carboNumLabel.snp.makeConstraints { make in
            make.left.equalTo(carboCircleView.snp.right).offset(kFitWidth(5))
            make.centerY.lessThanOrEqualTo(carboCircleView)
//            make.width.equalTo(labWidth)
        }
        proteinNumLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.centerY.lessThanOrEqualTo(carboCircleView)
        }
        proteinCircleView.snp.makeConstraints { make in
            make.right.equalTo(proteinNumLabel.snp.left).offset(kFitWidth(-5))
            make.width.height.equalTo(carboCircleView)
            make.centerY.lessThanOrEqualTo(carboCircleView)
        }
        fatNumLabel.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualTo((SCREEN_WIDHT-kFitWidth(32))*0.75)
            make.right.equalTo(kFitWidth(-34))
            make.centerY.lessThanOrEqualTo(carboCircleView)
        }
        fatCircleView.snp.makeConstraints { make in
            make.right.equalTo(fatNumLabel.snp.left).offset(kFitWidth(-5))
            make.width.height.equalTo(carboCircleView)
            make.centerY.lessThanOrEqualTo(carboCircleView)
        }
    }
}


extension PropotionResultNumberVM:UITextFieldDelegate{
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
                    
                    if numFloat > 9999.9{
                        return false
                    }
                    
                    textField.text = "\(firstStr)\(string)\(endStr)"
                }
            }else{
                let numStr = "\(firstStr)\(string)\(endStr)"
                let numFloat = numStr.floatValue
                
                if numFloat > 9999.9{
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
        
        if numFloat > 9999.9{
            return false
        }
        
        if self.numberChangeBlock != nil{
            self.numberChangeBlock!("\(textField.text ?? "")\(string)".replacingOccurrences(of: ",", with: "."))
        }
        
        return true
    }
}
