//
//  FoodsMergeAlertSpecVM.swift
//  lns
//
//  Created by Elavatine on 2025/3/18.
//


class FoodsMergeAlertSpecVM: UIView {
    
    var specTapBlock:(()->())?
    var changeBlock:((NSDictionary)->())?
    
    var foodsMsgDict = NSDictionary()
    var specName = ""
    var specNum = ""
    var specArray = NSMutableArray()
    var specDict = NSDictionary()
    
    var calories = Double(0)
    var carbohydrate = Double(0)
    var protein = Double(0)
    var fat = Double(0)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: kFitHeight(50)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var numberLab: UILabel = {
        let lab = UILabel()
        lab.text = "数量"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var numberTextField: NumericTextField = {
        let text = NumericTextField()
        text.placeholder = "100"
        text.text = "100"
        text.textColor = .COLOR_GRAY_BLACK_85
        text.font = .systemFont(ofSize: 14, weight: .medium)
        text.backgroundColor = .clear
        text.keyboardType = .decimalPad
        text.delegate = self
        text.textContentType = nil
        
        return text
    }()
    lazy var numberTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(textFieldInputAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.1)
        return vi
    }()
    lazy var specLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.textAlignment = .right
        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()
    lazy var specImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "foods_merge_arrow_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var specTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(specTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var bottomLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.1)
        return vi
    }()
}

extension FoodsMergeAlertSpecVM{
    @objc func textFieldInputAction() {
        self.numberTextField.becomeFirstResponder()
    }
    @objc func specTapAction() {
        self.specTapBlock?()
    }
    func updateNumber(num:String,isUpdateSpec:Bool? = true) {
        let numString = num.replacingOccurrences(of: ",", with: ".")
        if isUpdateSpec == true && numString == "" {
            if self.specDict["specName"]as? String ?? "" == "g" ||
                self.specDict["specName"]as? String ?? "" == "克" ||
                self.specDict["specName"]as? String ?? "" == "ml" ||
                self.specDict["specName"]as? String ?? "" == "毫升"{
                updatePlaceHolder(num:"100")
                updateNumber(num: "100", isUpdateSpec: false)
            }else{
                updatePlaceHolder(num:"1")
                updateNumber(num: "1", isUpdateSpec: false)
            }
            return
        }
        calories = (self.specDict["specCalories"]as? Double ?? 0) * (Double(numString) ?? 0)
        carbohydrate = (self.specDict["specCarbohydrate"]as? Double ?? 0) * (Double(numString) ?? 0)
        protein = (self.specDict["specProtein"]as? Double ?? 0) * (Double(numString) ?? 0)
        fat = (self.specDict["specFat"]as? Double ?? 0) * (Double(numString) ?? 0)
//        DLLog(message: "specDict:\(specDict)")
        
//        let carboOneDigit = WHUtils.convertStringToString(String(format: "%.1f", carbohydrate)) ?? "0"
//        let proteinOneDigit = WHUtils.convertStringToString(String(format: "%.1f", protein)) ?? "0"
//        let fatOneDigit = WHUtils.convertStringToString(String(format: "%.1f", fat)) ?? "0"
        
//        setAttributeStringForLabel(numberString: "\(WHUtils.convertStringToStringNoDigit("\(calories.rounded())") ?? "0")", unitString: "千卡", label: caloriLabel)
//        setAttributeStringForLabel(numberString: "\(carboOneDigit)", unitString: "g", label: carboLabel)
//        setAttributeStringForLabel(numberString: "\(proteinOneDigit)", unitString: "g", label: proteinLabel)
//        setAttributeStringForLabel(numberString: "\(fatOneDigit)", unitString: "g", label: fatLabel)
//        
        if self.changeBlock != nil{
            let dict = ["carbohydrate":"\(WHUtils.convertStringToStringOneDigit("\(carbohydrate)") ?? "0")",
                        "protein":"\(WHUtils.convertStringToStringOneDigit("\(protein)") ?? "0")",
                        "fat":"\(WHUtils.convertStringToStringOneDigit("\(fat)") ?? "0")",
                        "calories":"\(WHUtils.convertStringToStringNoDigit("\(calories)") ?? "0")",
                        "specName":self.specDict.stringValueForKey(key: "specName")]
//            let dict = ["carbohydrate":"\(WHUtils.convertStringToStringOneDigit("\(specCarbohydrate)") ?? "0")",
//                        "protein":"\(WHUtils.convertStringToStringOneDigit("\(specProtein)") ?? "0")",
//                        "fat":"\(WHUtils.convertStringToStringOneDigit("\(specFat)") ?? "0")"]
            self.changeBlock!(dict as NSDictionary)
        }
    }
    func changeSpec() {
        let numString = numberTextField.text?.replacingOccurrences(of: ",", with: ".") ?? "0"
        if numString == "" || numString == "0"{
            if self.specDict["specName"]as? String ?? "" == "g" ||
                self.specDict["specName"]as? String ?? "" == "克" ||
                self.specDict["specName"]as? String ?? "" == "ml" ||
                self.specDict["specName"]as? String ?? "" == "毫升"{
                updatePlaceHolder(num:"100")
                updateNumber(num: "100", isUpdateSpec: false)
            }else{
                updatePlaceHolder(num:"1")
                updateNumber(num: "1", isUpdateSpec: false)
            }
            return
        }
        
        calories = (self.specDict["specCalories"]as? Double ?? 0) * (Double(numString) ?? 0)
        carbohydrate = (self.specDict["specCarbohydrate"]as? Double ?? 0) * (Double(numString) ?? 0)
        protein = (self.specDict["specProtein"]as? Double ?? 0) * (Double(numString) ?? 0)
        fat = (self.specDict["specFat"]as? Double ?? 0) * (Double(numString) ?? 0)
        
        if self.changeBlock != nil{
            let dict = ["carbohydrate":"\(WHUtils.convertStringToStringOneDigit("\(carbohydrate)") ?? "0")",
                        "protein":"\(WHUtils.convertStringToStringOneDigit("\(protein)") ?? "0")",
                        "fat":"\(WHUtils.convertStringToStringOneDigit("\(fat)") ?? "0")",
                        "calories":"\(WHUtils.convertStringToStringNoDigit("\(calories)") ?? "0")",
                        "specName":self.specDict.stringValueForKey(key: "specName")]
            self.changeBlock!(dict as NSDictionary)
        }
    }
}

extension FoodsMergeAlertSpecVM{
    func initUI() {
        addSubview(numberLab)
        addSubview(numberTextField)
        addSubview(numberTapView)
        addSubview(lineView)
        addSubview(specLabel)
        addSubview(specImgView)
        addSubview(specTapView)
        addSubview(bottomLineView)
        
        setConstrait()
    }
    func setConstrait() {
        numberLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        numberTextField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(60))
            make.centerY.lessThanOrEqualToSuperview()
        }
        numberTapView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(50))
            make.top.height.equalToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(150))
        }
        lineView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-95))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(1))
            make.height.equalTo(kFitWidth(16))
        }
        specImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-15))
            make.width.height.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualToSuperview()
        }
        specLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-43))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(50))
        }
        specTapView.snp.makeConstraints { make in
            make.right.top.height.equalToSuperview()
            make.left.equalTo(lineView)
        }
        bottomLineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.right.equalTo(kFitWidth(-16))
            make.left.equalTo(kFitWidth(59))
            make.height.equalTo(kFitWidth(1))
        }
    }
}

extension FoodsMergeAlertSpecVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var number = textField.text ?? ""
        if string == ""{
            if number.count > 1 {
                number = number.mc_clipFromPrefix(to: number.count-1)
            }else{
                number = ""
            }
            updateNumber(num:number)
            return true
        }
        // 检查输入的字符是否是数字
        let allowedCharacters = CharacterSet(charactersIn: ".,0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        if allowedCharacters.isSuperset(of: characterSet) == false{
            return false
        }
        if range.length > 0 || (range.location == 0 && range.length == 0){
            let firstStr = number.mc_clipFromPrefix(to: range.location)
            let endStr = number.mc_cutToSuffix(from: range.location+range.length)
            if range.location == 0{
                if string == "0"{
                    textField.text = "\(endStr)"
                }else if string == "." || string == ","{
                    textField.text = "0.\(endStr)"
                }else{
                    textField.text = "\(firstStr)\(string)\(endStr)"
                }
            }else{
                textField.text = "\(firstStr)\(string)\(endStr)"
            }
            
            updateNumber(num:"\(textField.text ?? "")")
            return false
        }
        if (string == "." || string == ",") && number == ""{
//            textField.text = "0."
            return false
        }
        if (string == "." && number.contains(".")) || (string == "," && number.contains(",")){
            return false
        }
        if string == "0" && number == "0"{
            return false
        }
        if number.contains("."){
            let arr = number.components(separatedBy: ".")
            if arr.count > 1 {
                let decimalString = arr[1]
                if decimalString.count >= 3{
                    return false
                }
            }
            number = "\(number)\(string)"
            updateNumber(num:number)
            return true
        }else if number.contains(","){
            let arr = number.components(separatedBy: ",")
            if arr.count > 1 {
                let decimalString = arr[1]
                if decimalString.count >= 3{
                    return false
                }
            }
            number = "\(number)\(string)"
            updateNumber(num:number)
            return true
        }else if number.count >= 4 && string != "." && string != ","{
            return false
        }
        number = "\(number)\(string)"
        updateNumber(num:number)
        
        return true
    }
}

extension FoodsMergeAlertSpecVM{
    //计算不同规格的单位数量下，营养元素的值
    func calculateSpecWeight(){
        specArray.removeAllObjects()
        
        let specString = self.foodsMsgDict["spec"]as? String ?? ""
        let specArr = WHUtils.getArrayFromJSONString(jsonString: specString)
        
        let specDefault = WHUtils.getSpecDefaultFromFoods(foodsDict: foodsMsgDict)
        
        var unitqty = Double(specDefault["specNum"]as? String ?? "\(specDefault["specNum"]as? Double ?? 0)") ?? 0
        let calories = Double(self.foodsMsgDict["calories"]as? String ?? "\(self.foodsMsgDict["calories"]as? Double ?? 0)") ?? 0
        let carbohydrate = Double(self.foodsMsgDict["carbohydrate"]as? String ?? "\(self.foodsMsgDict["carbohydrate"]as? Double ?? 0)") ?? 0
        let protein = Double(self.foodsMsgDict["protein"]as? String ?? "\(self.foodsMsgDict["protein"]as? Double ?? 0)") ?? 0
        let fat = Double(self.foodsMsgDict["fat"]as? String ?? "\(self.foodsMsgDict["fat"]as? Double ?? 0)") ?? 0
        
        for i in 0..<specArr.count{
            let dict = NSMutableDictionary(dictionary: specArr[i]as? NSDictionary ?? [:])
            var specQty = Double(dict["specNum"]as? String ?? "\(dict["specNum"]as? Double ?? 0)") ?? 0
            
            if dict["specName"]as? String ?? "" == "g" ||
                dict["specName"]as? String ?? "" == "克" ||
                dict["specName"]as? String ?? "" == "ml" ||
                dict["specName"]as? String ?? "" == "毫升" ||
                specArr.count == 1{
                specQty = 1
            }
            
            let specCaloriesPer = calories/unitqty*specQty
            let specCarbohydratePer = carbohydrate/unitqty*specQty
            let specProteinPer = protein/unitqty*specQty
            let specFatPer = fat/unitqty*specQty
            
            dict.setValue(specCaloriesPer, forKey: "specCalories")
            dict.setValue(specCarbohydratePer, forKey: "specCarbohydrate")
            dict.setValue(specProteinPer, forKey: "specProtein")
            dict.setValue(specFatPer, forKey: "specFat")
            
            specArray.add(dict)
            
            if i == 0 || dict["specName"]as? String ?? "" == self.specName{
                specDict = dict
            }
        }
        
        if self.specDict["specName"]as? String ?? "" == "g" ||
            self.specDict["specName"]as? String ?? "" == "克" ||
            self.specDict["specName"]as? String ?? "" == "ml" ||
            self.specDict["specName"]as? String ?? "" == "毫升"{
            updatePlaceHolder(num:"100")
        }else{
            updatePlaceHolder(num:"1")
        }
        
        if self.specNum.count > 0{
            numberTextField.text = self.specNum
            updateNumber(num:self.specNum)
        }else{
            updateNumber(num:specDict["specNum"]as? String ?? "")
        }
    }
    func updatePlaceHolder(num:String) {
        // 使用方法
        let image = UIImage(named: "logs_pen_icon")!
//        let attributedString = createAttributedStringWithImage(image: image, text: "\(specDict["specNum"]as? String ?? "\(specDict["specNum"]as? Double ?? 0)")")
        let attributedString = createAttributedStringWithImage(image: image, text: "\(num)")
        numberTextField.attributedPlaceholder = attributedString
    }
    func createAttributedStringWithImage(image: UIImage, text: String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: (UIFont.systemFont(ofSize: 16, weight: .medium).capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
        let attachmentString = NSAttributedString(attachment: attachment)
        
        let string = NSMutableAttributedString(string: text)
        string.append(attachmentString)
        
        return string
    }
}
