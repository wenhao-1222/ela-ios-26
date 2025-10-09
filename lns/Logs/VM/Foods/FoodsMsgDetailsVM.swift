//
//  FoodsMsgDetailsVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/13.
//

import Foundation
import UIKit

class FoodsMsgDetailsVM: UIView {
    
    var foodsMsgDict = NSDictionary()
    var specName = ""
    var specNum = ""
    var specArray = NSMutableArray()
    var specDict = NSDictionary()
    
    var changeBlock:((NSDictionary)->())?
    var specTapBlock:(()->())?
    
    var specCalories = Double(0)
    var specCarbohydrate = Double(0)
    var specProtein = Double(0)
    var specFat = Double(0)
    
    var calories = Double(0)
    var carbohydrate = Double(0)
    var protein = Double(0)
    var fat = Double(0)
    
    let whiteWidth = SCREEN_WIDHT-kFitWidth(32)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: kFitWidth(193)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: whiteWidth, height: kFitWidth(193)))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var caloriLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.textAlignment = .center
        lab.text = "0"
        
        return lab
    }()
    lazy var caloriLab : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "热量"
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var carboLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.textAlignment = .center
        lab.text = "0"
        
        return lab
    }()
    lazy var carboLab : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "碳水"
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var proteinLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.textAlignment = .center
        lab.text = "0"
        
        return lab
    }()
    lazy var proteinLab : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "蛋白质"
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var fatLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.textAlignment = .center
        lab.text = "0"
        
        return lab
    }()
    lazy var fatLab : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "脂肪"
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var unitLab : UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.text = "单位"
        
        return lab
    }()
    lazy var unitButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("\(specName)", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
//        btn.imagePosition(style: .right, spacing: kFitWidth(2))
        
        btn.addTarget(self, action: #selector(unitTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var unitTapView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(unitTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        
        return vi
    }()
    lazy var weightLab: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.text = "数量"
        
        return lab
    }()
    
    lazy var numberTapView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(numberBtnTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var textField: NumericTextField = {
        let text = NumericTextField()
        text.keyboardType = .decimalPad
        text.textColor = .COLOR_GRAY_BLACK_85
        text.font = .systemFont(ofSize: 16, weight: .medium)
        text.delegate = self
        text.textContentType = nil
//        text.select
        
        return text
    }()
}

extension FoodsMsgDetailsVM{
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
        updateUnitButton()
        if self.specDict["specName"]as? String ?? "" == "g" ||
            self.specDict["specName"]as? String ?? "" == "克" ||
            self.specDict["specName"]as? String ?? "" == "ml" ||
            self.specDict["specName"]as? String ?? "" == "毫升"{
            updatePlaceHolder(num:"100")
        }else{
            updatePlaceHolder(num:"1")
        }
        
        if self.specNum.count > 0{
            textField.text = self.specNum
            updateNumber(num:self.specNum)
        }else{
            updateNumber(num:specDict["specNum"]as? String ?? "")
        }
    }
    func updateUnitButton() {
        self.specName = self.specDict.stringValueForKey(key: "specName")
        unitButton.setTitle("\(specDict["specName"]as? String ?? "")", for: .normal)
        unitButton.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        unitButton.imagePosition(style: .right, spacing: kFitWidth(2))
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
        
        let carboOneDigit = WHUtils.convertStringToString(String(format: "%.1f", carbohydrate)) ?? "0"
        let proteinOneDigit = WHUtils.convertStringToString(String(format: "%.1f", protein)) ?? "0"
        let fatOneDigit = WHUtils.convertStringToString(String(format: "%.1f", fat)) ?? "0"
        
        setAttributeStringForLabel(numberString: "\(WHUtils.convertStringToStringNoDigit("\(calories.rounded())") ?? "0")", unitString: "千卡", label: caloriLabel)
        setAttributeStringForLabel(numberString: "\(carboOneDigit)", unitString: "g", label: carboLabel)
        setAttributeStringForLabel(numberString: "\(proteinOneDigit)", unitString: "g", label: proteinLabel)
        setAttributeStringForLabel(numberString: "\(fatOneDigit)", unitString: "g", label: fatLabel)
        
        if self.changeBlock != nil{
            let dict = ["carbohydrate":"\(WHUtils.convertStringToStringOneDigit("\(specCarbohydrate)") ?? "0")",
                        "protein":"\(WHUtils.convertStringToStringOneDigit("\(specProtein)") ?? "0")",
                        "fat":"\(WHUtils.convertStringToStringOneDigit("\(specFat)") ?? "0")"]
            self.changeBlock!(dict as NSDictionary)
        }
    }
}

extension FoodsMsgDetailsVM{
    @objc func unitTapAction(){
        if self.specTapBlock != nil{
            self.specTapBlock!()
        }
    }
    @objc func numberBtnTapAction() {
        textField.becomeFirstResponder()
        
    }
}
extension FoodsMsgDetailsVM{
    func initUI() {
        addSubview(textField)
        
        addSubview(whiteView)
        whiteView.addShadow()
        
        whiteView.addSubview(caloriLab)
        whiteView.addSubview(caloriLabel)
        whiteView.addSubview(carboLab)
        whiteView.addSubview(carboLabel)
        whiteView.addSubview(proteinLab)
        whiteView.addSubview(proteinLabel)
        whiteView.addSubview(fatLab)
        whiteView.addSubview(fatLabel)
        whiteView.addSubview(unitLab)
        whiteView.addSubview(unitButton)
        whiteView.addSubview(unitTapView)
        whiteView.addSubview(lineView)
        whiteView.addSubview(weightLab)
        whiteView.addSubview(textField)
//        whiteView.addSubview(numberTapView)
        unitButton.imagePosition(style: .right, spacing: kFitWidth(2))
        
        setConstrait()
    }
    func setConstrait() {
        caloriLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(whiteWidth*0.5*0.25)
            make.top.equalTo(kFitWidth(49))
        }
        caloriLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(caloriLab)
            make.top.equalTo(kFitWidth(17))
        }
        carboLab.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(caloriLab)
            make.centerX.lessThanOrEqualTo(whiteWidth*0.5*0.75)
        }
        carboLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(carboLab)
            make.centerY.lessThanOrEqualTo(caloriLabel)
        }
        proteinLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(whiteWidth*0.5*0.25+whiteWidth*0.5)
            make.centerY.lessThanOrEqualTo(caloriLab)
        }
        proteinLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(proteinLab)
            make.centerY.lessThanOrEqualTo(caloriLabel)
        }
        fatLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(whiteWidth*0.5*0.75+whiteWidth*0.5)
            make.centerY.lessThanOrEqualTo(caloriLab)
        }
        fatLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(fatLab)
            make.centerY.lessThanOrEqualTo(caloriLabel)
        }
        unitLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(102))
        }
        unitButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(84))
            make.height.equalTo(kFitWidth(56))
            make.centerY.lessThanOrEqualTo(unitLab)
        }
        unitTapView.snp.makeConstraints { make in
            make.left.height.centerY.equalTo(unitButton)
            make.right.equalTo(kFitWidth(-20))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(136))
            make.width.equalTo(whiteWidth-kFitWidth(32))
            make.height.equalTo(kFitWidth(1))
        }
        weightLab.snp.makeConstraints { make in
            make.left.equalTo(unitLab)
            make.top.equalTo(lineView.snp.bottom)
            make.bottom.equalToSuperview()
        }
//        numberTapView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(84))
//            make.top.height.equalTo(weightLab)
//            make.width.equalTo(kFitWidth(200))
//        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(84))
            make.top.height.equalTo(weightLab)
            make.width.equalTo(whiteWidth-kFitWidth(90))
        }
    }
    
}

extension FoodsMsgDetailsVM{
    func setAttributeStringForLabel(numberString:String,unitString:String,label:UILabel) {
        let numberAttr = NSMutableAttributedString(string: "\(numberString)")
        numberAttr.yy_font = UIFont().DDInFontMedium(fontSize: 20)
        let unitAttr = NSMutableAttributedString(string: " \(unitString)")
        unitAttr.yy_font = .systemFont(ofSize: 10, weight: .medium)
        
        numberAttr.append(unitAttr)
        label.attributedText = numberAttr
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
    func updatePlaceHolder(num:String) {
        // 使用方法
        let image = UIImage(named: "logs_pen_icon")!
//        let attributedString = createAttributedStringWithImage(image: image, text: "\(specDict["specNum"]as? String ?? "\(specDict["specNum"]as? Double ?? 0)")")
        let attributedString = createAttributedStringWithImage(image: image, text: "\(num)")
        textField.attributedPlaceholder = attributedString
    }
}

extension FoodsMsgDetailsVM:UITextFieldDelegate{
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
                    if number == "0"{
                        textField.text = "0"//"\(endStr)"
                    }else{
                        textField.text = "0"//"\(endStr)"
                    }
//                    textField.text = "0"//"\(endStr)"
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
