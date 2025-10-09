//
//  FoodsDetailWeightVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/23.
//

import Foundation
import UIKit

class FoodsDetailWeightVM: UIView {
    
    var foodsMsgDict = NSDictionary()
    
    var carboPerUnit = Float(0)
    var proteinPerUnit = Float(0)
    var fatPerUnit = Float(0)
    var unitString = "克"
    var unitWeight = "1"//单位对应的重量   g
    var unitWeightDefault = "1"//单位对应的重量   g
//    var number = ""
    var defaultNumber = ""
    var isFirst = true
    
    var carboNumberString = ""
    var proteinNumberString = ""
    var fatsNumberString = ""
    var caloriNumberString = ""
    
    var carboNumberStringPer = ""
    var proteinNumberStringPer = ""
    var fatsNumberStringPer = ""
    var caloriNumberStringPer = ""
    
    var changeBlock:((NSDictionary,String)->())?
    var specTapBlock:(()->())?
    
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
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: kFitWidth(343), height: kFitWidth(193)))
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
        btn.setTitle("\(unitString)", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.imagePosition(style: .right, spacing: kFitWidth(2))
        
        btn.addTarget(self, action: #selector(unitTapAction), for: .touchUpInside)
        
        return btn
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
    
    lazy var numberLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var numberIcon : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "logs_pen_icon")
        
        return img
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
        text.textContentType = nil
        text.textColor = .COLOR_GRAY_BLACK_85
        // 使用方法
        let image = UIImage(named: "logs_pen_icon")!
        let attributedString = createAttributedStringWithImage(image: image, text: "0")
        text.attributedPlaceholder = attributedString
        text.font = .systemFont(ofSize: 16, weight: .medium)
        text.delegate = self
        
        return text
    }()
}

extension FoodsDetailWeightVM{
    //计算单位重量下    每克/每个/每份   各营养素所占重量
    func calculateNutritionNumberPer() {
        
    }
}
extension FoodsDetailWeightVM{
    func updateUI(dict:NSDictionary,isDetail:Bool? = false) {
        self.foodsMsgDict = dict
        var carbo = Float(dict["carbohydrate"]as? String ?? "0.00") ?? 0.00
        var protein = Float(dict["protein"]as? String ?? "0.00") ?? 0.00
        var fats = Float(dict["fat"]as? String ?? "0.00") ?? 0.00
        
        if carbo == 0 && protein == 0 && fats == 0 {
            carbo = Float(dict["carbohydrate"]as? Double ?? 0)
            protein = Float(dict["protein"]as? Double ?? 0)
            fats = Float(dict["fat"]as? Double ?? 0)
        }
         
//        var unitqty = Int(dict["unitqty"]as? Double ?? 0)
//        
//        if unitqty == 0 {
//            unitqty = Int(dict["unitqty"]as? String ?? "1") ?? 1
//        }
        let specDefault = WHUtils.getSpecDefaultFromFoods(foodsDict: foodsMsgDict)
        var unitqty = ((specDefault["specNum"]as? String ?? "") as NSString).intValue
        
        textField.text = "\(unitqty)"
        defaultNumber = "\(unitqty)"
        
        unitString = dict["unit"]as? String ?? "g"
        unitWeight = "\(unitqty)"
        
        let specArrString = self.foodsMsgDict["spec"]as? String ?? ""
        if specArrString.count > 0 {
            let specArray = WHUtils.getArrayFromJSONString(jsonString: specArrString)
            if specArray.count > 0 {
                let specDict = specArray[0]as? NSDictionary ?? [:]
                unitString = specDict["specName"]as? String ?? "g"
                unitWeightDefault = specDict["specNum"]as? String ?? "1"
            }
        }
        
        unitButton.setTitle("\(unitString)", for: .normal)
        unitButton.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        unitButton.imagePosition(style: .right, spacing: kFitWidth(2))
        
        if self.changeBlock != nil{
            let dict = ["carbohydrate":"\(carbo)",
                        "protein":"\(protein)",
                        "fat":"\(fats)"]
            self.changeBlock!(dict as NSDictionary,textField.text ?? "")
        }
        
        updateNumber(num: textField.text ?? "")
        
        if isDetail == false{
            DispatchQueue.main.asyncAfter(deadline:.now() + 0.1, execute: {
                self.resetTextFieldPlaceHolder()
            })
        }
    }
    func updateUIForFoodsMsg(dict:NSDictionary) {
        self.foodsMsgDict = dict["food"]as? NSDictionary ?? [:]
        var carbo = Float(dict["carbohydrate"]as? String ?? "0.00") ?? 0.00
        var protein = Float(dict["protein"]as? String ?? "0.00") ?? 0.00
        var fats = Float(dict["fat"]as? String ?? "0.00") ?? 0.00
        
        if carbo == 0 && protein == 0 && fats == 0 {
            carbo = Float(dict["carbohydrate"]as? Double ?? 0)
            protein = Float(dict["protein"]as? Double ?? 0)
            fats = Float(dict["fat"]as? Double ?? 0)
        }
         
//        var unitqty = Int(dict["qty"]as? Double ?? 0)
//        
//        if unitqty == 0 {
//            unitqty = Int(dict["qty"]as? String ?? "1") ?? 1
//        }
        let specDefault = WHUtils.getSpecDefaultFromFoods(foodsDict: foodsMsgDict)
        var unitqty = ((specDefault["specNum"]as? String ?? "") as NSString).intValue
        
        textField.text = "\(unitqty)"
        defaultNumber = "\(unitqty)"
        
        unitString = dict["spec"]as? String ?? "g"
        unitWeight = "\(unitqty)"
//        updateUnitButton(unit: unitString, unitWeightStr: unitWeight)
        
        let foodsDict =  foodsMsgDict["food"]as? NSDictionary ?? [:]
        let specArrString = foodsDict["spec"]as? String ?? ""
        if specArrString.count > 0 {
            let specArray = WHUtils.getArrayFromJSONString(jsonString: specArrString)
            if specArray.count > 0 {
                let specDict = specArray[0]as? NSDictionary ?? [:]
                unitString = specDict["specName"]as? String ?? "g"
                unitWeightDefault = specDict["specNum"]as? String ?? "1"
            }
        }
        
        unitButton.setTitle("\(unitString)", for: .normal)
        unitButton.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        unitButton.imagePosition(style: .right, spacing: kFitWidth(2))
        
        if self.changeBlock != nil{
            let dict = ["carbohydrate":"\(carbo)",
                        "protein":"\(protein)",
                        "fat":"\(fats)"]
            self.changeBlock!(dict as NSDictionary,textField.text ?? "")
        }
        updateNumber(num: textField.text ?? "")
    }
    
    func updateNumber(num:String) {
        
        var number = num//self.textField.text ?? ""
        if number.count == 0 || number == ""{
            number = "0"
        }
        let specDefault = WHUtils.getSpecDefaultFromFoods(foodsDict: foodsMsgDict)
        var unitqty = ((specDefault["specNum"]as? String ?? "") as NSString).intValue
//        var unitqty = Int(foodsMsgDict["unitqty"]as? Double ?? 1)
//        if unitqty == 1 {
//            unitqty = Int(foodsMsgDict["unitqty"]as? String ?? "1") ?? 1
//        }
        
        if unitqty == 100 && (unitString == "g" || unitString == "克"){
            unitWeight = "1"
        }
        let numberFloat = (number as NSString).floatValue * (unitWeight as NSString).floatValue///unitqty
        
        var carbo = Float(foodsMsgDict["carbohydrate"]as? String ?? "0.00") ?? 0.00
        var protein = Float(foodsMsgDict["protein"]as? String ?? "0.00") ?? 0.00
        var fats = Float(foodsMsgDict["fat"]as? String ?? "0.00") ?? 0.00
        
        if carbo == 0 && protein == 0 && fats == 0 {
            carbo = Float(foodsMsgDict["carbohydrate"]as? Double ?? 0)
            protein = Float(foodsMsgDict["protein"]as? Double ?? 0)
            fats = Float(foodsMsgDict["fat"]as? Double ?? 0)
        }
        
        let carboT = carbo/Float(unitqty) * numberFloat
        let proteinT = protein/Float(unitqty) * numberFloat
        let fatsT = fats/Float(unitqty) * numberFloat
        let caloriNumber = (carboT + proteinT)*4 + fatsT * 9
        
        carboNumberString = WHUtils.convertStringToString("\(String(format: "%.1f", carboT))") ?? "0"
        proteinNumberString = WHUtils.convertStringToString("\(String(format: "%.1f", proteinT))") ?? "0"
        fatsNumberString = WHUtils.convertStringToString("\(String(format: "%.1f", fatsT))") ?? "0"
        caloriNumberString = WHUtils.convertStringToString("\(String(format: "%.0f", caloriNumber))") ?? "0"
        
        carboNumberStringPer = WHUtils.convertStringToString("\(String(format: "%.2f", carbo/Float(unitqty)))") ?? "0"
        proteinNumberStringPer = WHUtils.convertStringToString("\(String(format: "%.2f", protein/Float(unitqty)))") ?? "0"
        fatsNumberStringPer = WHUtils.convertStringToString("\(String(format: "%.2f", fats/Float(unitqty)))") ?? "0"
        caloriNumberStringPer = WHUtils.convertStringToString("\(String(format: "%.2f", caloriNumber/numberFloat))") ?? "0"
        
        setAttributeStringForLabel(numberString: "\(carboNumberString)", unitString: "g", label: carboLabel)
        setAttributeStringForLabel(numberString: "\(proteinNumberString)", unitString: "g", label: proteinLabel)
        setAttributeStringForLabel(numberString: "\(fatsNumberString)", unitString: "g", label: fatLabel)
        setAttributeStringForLabel(numberString: "\(caloriNumberString)", unitString: "千卡", label: caloriLabel)
        
        if self.changeBlock != nil{
            let dict = ["carboNumberString":carboNumberString,
                        "proteinNumberString":proteinNumberString,
                        "fatNumberString":fatsNumberString]
            self.changeBlock!(dict as NSDictionary,num)
        }
        
    }
    
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
    @objc func numberBtnTapAction() {
        textField.becomeFirstResponder()
        
    }
    @objc func unitTapAction(){
        if self.specTapBlock != nil{
            self.specTapBlock!()
        }
    }
    func updateUnitButton(unit:String,unitWeightStr:String) {
        unitString = unit
        unitWeight = unitWeightStr
        
        unitButton.setTitle("\(unitString)", for: .normal)
        unitButton.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        unitButton.imagePosition(style: .right, spacing: kFitWidth(2))
        
        updateNumber(num:textField.text ?? "")
    }
    func resetTextFieldPlaceHolder() {
        let image = UIImage(named: "logs_pen_icon")!
        if self.textField.text?.count ?? 0 > 0 {
            let attributedString = createAttributedStringWithImage(image: image, text: "\(textField.text ?? "0")")
            textField.attributedPlaceholder = attributedString
        }else{
            let attributedString = createAttributedStringWithImage(image: image, text: "0")
            textField.attributedPlaceholder = attributedString
        }
        textField.text = ""
    }
}

extension FoodsDetailWeightVM{
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
        whiteView.addSubview(lineView)
        whiteView.addSubview(weightLab)
//        whiteView.addSubview(numberLabel)
//        whiteView.addSubview(numberIcon)
        whiteView.addSubview(textField)
        whiteView.addSubview(numberTapView)
        unitButton.imagePosition(style: .right, spacing: kFitWidth(2))
        
        setConstrait()
    }
    func setConstrait() {
        caloriLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(kFitWidth(52))
            make.top.equalTo(kFitWidth(49))
        }
        caloriLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(caloriLab)
            make.top.equalTo(kFitWidth(17))
        }
        carboLab.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(caloriLab)
            make.centerX.lessThanOrEqualTo(kFitWidth(135))
        }
        carboLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(carboLab)
            make.centerY.lessThanOrEqualTo(caloriLabel)
        }
        proteinLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(kFitWidth(215))
            make.centerY.lessThanOrEqualTo(caloriLab)
        }
        proteinLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(proteinLab)
            make.centerY.lessThanOrEqualTo(caloriLabel)
        }
        fatLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(kFitWidth(295))
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
            make.centerY.lessThanOrEqualTo(unitLab)
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(136))
            make.width.equalTo(kFitWidth(311))
            make.height.equalTo(kFitWidth(1))
        }
        weightLab.snp.makeConstraints { make in
            make.left.equalTo(unitLab)
            make.top.equalTo(lineView.snp.bottom)
            make.bottom.equalToSuperview()
        }
//        numberLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(84))
//            make.top.height.equalTo(weightLab)
//        }
//        numberIcon.snp.makeConstraints { make in
//            make.left.equalTo(numberLabel.snp.right).offset(kFitWidth(1))
//            make.centerY.lessThanOrEqualTo(numberLabel)
//            make.width.height.equalTo(kFitWidth(16))
//        }
        
        numberTapView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(84))
            make.top.height.equalTo(weightLab)
            make.width.equalTo(kFitWidth(200))
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(84))
            make.top.height.equalTo(weightLab)
        }
    }
}

extension FoodsDetailWeightVM:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        textField.text = number
//        if number == "0"{
//            textField.text = ""
//        }
//        let image = UIImage(named: "logs_pen_icon")!
//        let attributedString = createAttributedStringWithImage(image: image, text: "0")
//        textField.attributedPlaceholder = attributedString
    }
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
        if (string == "." || string == ",") && (number.contains(".") || number.contains(",") || number == ""){
            return false
        }
        if string == "0" && number == ""{
            return false
        }
        
        if number.contains("."){
            let arr = number.components(separatedBy: ".")
            if arr.count > 1 {
                let decimalString = arr[1]
                if decimalString.count >= 4{
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
                if decimalString.count >= 4{
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
    func textFieldDidEndEditing(_ textField: UITextField) {
//        if isFirst {
//            let image = UIImage(named: "logs_pen_icon")!
//            if self.textField.text?.count ?? 0 > 0 {
//                let attributedString = createAttributedStringWithImage(image: image, text: "\(textField.text ?? "0")")
//                textField.attributedPlaceholder = attributedString
//            }else{
//                let attributedString = createAttributedStringWithImage(image: image, text: "0")
//                textField.attributedPlaceholder = attributedString
//            }
//            textField.text = ""
//        }
//        isFirst = false
    }
}
