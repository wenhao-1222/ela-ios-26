//
//  PropotionResultVC.swift
//  lns
//  配料表结果
//  Created by Elavatine on 2025/3/12.
//


import Foundation
import MCToast
import IQKeyboardManagerSwift

class PropotionResultVC: WHBaseViewVC {
    
    var msgDict = NSDictionary()
    var unitNaturalMsgDict = NSMutableDictionary()
    
    var carNumber = Float(0)
    var proteinNumber = Float(0)
    var fatNumber = Float(0)
    
    var eatCaloriesNumber = Float(0)
    var eatCarNumber = Float(0)
    var eatProteinNumber = Float(0)
    var eatFatNumber = Float(0)
    var eatQtyNumber = Float(0)
    
    var addBlock:(()->())?
    var specArray = ["份"]
    
    var isFromPlan = false
    var sourceType = ADD_FOODS_SOURCE.other
    
    override func viewWillAppear(_ animated: Bool) {
//        IQKeyboardManager.shared.enable = false
//        IQKeyboardManager.shared.enableAutoToolbar = false
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
//        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if msgDict.stringValueForKey(key: "balance") == "3"{
            MCToast.mc_text("今日识别次数还剩 3 次\n（识图功能测试期间，每天可使用 10 次）")
        }else if msgDict.stringValueForKey(key: "balance") == "0"{
            MCToast.mc_text("今日识别次数已用完，请明天再来\n（识图功能测试期间，每天可使用 10 次）")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unitNaturalMsgDict = NSMutableDictionary(dictionary: self.msgDict)
        initUI()
        calculateNaturalMsg()
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is CameraViewController }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
    }
    lazy var bottomView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var foodsNameVm : FoodsCreateNameVM = {
        let vm = FoodsCreateNameVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: 0, height: 0))
        
        vm.numberChangeBlock = {(number)in
            
            let nameStr = number.replacingOccurrences(of: " ", with: "")
            if nameStr == "" {
                self.saveButton.isEnabled = false
            }else if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
                self.saveButton.isEnabled = false
            }else{
                self.saveButton.isEnabled = true
            }
        }
        return vm
    }()
    lazy var specVm : FoodsCreateSpecVM = {
        let vm = FoodsCreateSpecVM.init(frame: CGRect.init(x: 0, y: self.foodsNameVm.frame.maxY, width: 0, height: 0))
        vm.specBlock = {()in
            self.foodsNameVm.textField.resignFirstResponder()
            self.proteinVm.textField.resignFirstResponder()
            self.fatVm.textField.resignFirstResponder()
            self.carboVm.textField.resignFirstResponder()
            self.caloriVm.numberLabel.resignFirstResponder()
            self.specAlertVm.showView()
        }
        vm.perNumBlock = {()in
//            self.calculateNaturalMsg()
        }
        vm.numberChangeBlock = {(number)in
            DLLog(message: "numberChangeBlock:\(number)")
            if number.count > 0{
                self.calculateNaturalMsg(specNum: number)
            }else{
                self.calculateNaturalMsg(specNum: self.specVm.numberTextField.placeholder)
            }
        }
        return vm
    }()
    lazy var caloriVm: PropotionResultCaloriVM = {
        let vm = PropotionResultCaloriVM.init(frame: CGRect.init(x: 0, y: self.specVm.frame.maxY, width: 0, height: 0))
        vm.numberChangeBlock = {(number)in
            if number.count > 0 {
                self.saveButton.isEnabled = true
                self.calculateNaturalMsg(caloriesNum: number)
            }else{
                self.saveButton.isEnabled = false
                self.calculateNaturalMsg(caloriesNum: number)
                if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
                    self.caloriVm.numberLabel.text = ""
                    return
                }
                self.saveButton.isEnabled = true
            }
        }
        return vm
    }()
//    lazy var caloriVm : FoodsCreateCaloriVM = {
//        let vm = FoodsCreateCaloriVM.init(frame: CGRect.init(x: 0, y: self.specVm.frame.maxY, width: 0, height: 0))
////        vm.numberLabel.isEnabled = false
//        vm.numberChangeBlock = {(number)in
//            if number.count > 0 {
//                self.saveButton.isEnabled = true
//                self.calculateNaturalMsg(caloriesNum: number)
//            }else{
//                self.saveButton.isEnabled = false
//                self.calculateNaturalMsg(caloriesNum: number)
//                if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
//                    self.caloriVm.numberLabel.text = ""
//                    return
//                }
//                self.saveButton.isEnabled = true
//            }
//        }
//        vm.unitChangeBlock = {()in
//            self.calculateNaturalMsg()
//        }
//        return vm
//    }()
    lazy var carboVm : FoodsCreateItemVM = {
        let vm = FoodsCreateItemVM.init(frame: CGRect.init(x: 0, y: self.caloriVm.frame.maxY, width: 0, height: 0))
        vm.titleLabel.text = "碳水"
        vm.maxLength = 4
        vm.numberChangeBlock = {(number)in
            if let num = Float(number){
                self.carNumber = Float(number) ?? 0.0
            }else{
                self.carNumber = 0
                self.carboVm.textField.text = ""
            }
            self.calculateNumber()
        }
        return vm
    }()
    lazy var proteinVm : FoodsCreateItemVM = {
        let vm = FoodsCreateItemVM.init(frame: CGRect.init(x: 0, y: self.carboVm.frame.maxY, width: 0, height: 0))
        vm.titleLabel.text = "蛋白质"
        vm.maxLength = 4
        vm.numberChangeBlock = {(number)in
            if let num = Float(number){
                self.proteinNumber = Float(number) ?? 0.0
            }else{
                self.proteinNumber = 0
                self.proteinVm.textField.text = ""
            }
            self.calculateNumber()
        }
        return vm
    }()
    lazy var fatVm : FoodsCreateItemVM = {
        let vm = FoodsCreateItemVM.init(frame: CGRect.init(x: 0, y: self.proteinVm.frame.maxY, width: 0, height: 0))
        vm.titleLabel.text = "脂肪"
        vm.maxLength = 4
        vm.numberChangeBlock = {(number)in
            if let num = Float(number){
                self.fatNumber = Float(number) ?? 0.0
            }else{
                self.fatNumber = 0
                self.fatVm.textField.text = ""
            }
            self.calculateNumber()
        }
        return vm
    }()
    lazy var synVm: SynMyFoodsVM = {
        let vm = SynMyFoodsVM.init(frame: CGRect.init(x: 0, y: self.fatVm.frame.maxY, width: 0, height: 0))
        return vm
    }()
    lazy var naturalVm: PropotionResultNumberVM = {
        let vm = PropotionResultNumberVM.init(frame: CGRect.init(x: 0, y: self.synVm.frame.maxY, width: 0, height: 0))
        vm.updateUI(dict:self.msgDict)
        vm.numberChangeBlock = {(number)in
            if number.intValue > 0 {
                self.naturalVm.inputNumer = number.doubleValue
            }else{
                self.naturalVm.inputNumer = Double(self.naturalVm.defaultNumer)
            }
//            if self.specVm.numberTextField.text?.count ?? 0 > 0 {
//                self.calculateNaturalMsg(specNum: self.specVm.numberTextField.text)
//            }else{
//                self.calculateNaturalMsg(specNum: self.specVm.numberTextField.placeholder)
//            }
            self.calculateNaturalMsg()
//            self.calculateNaturalMsgChangeQty()
        }
        return vm
    }()
    lazy var btnBgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-kFitWidth(60)-getBottomSafeAreaHeight(), width: SCREEN_WIDHT, height: kFitWidth(60)+getBottomSafeAreaHeight()))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var saveButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = CGRect.init(x: kFitWidth(20), y: kFitWidth(6), width: SCREEN_WIDHT-kFitWidth(40), height: kFitWidth(48))
        btn.backgroundColor = .THEME
        btn.setTitle("添加到日志", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.isEnabled = false
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var specAlertVm: FoodsCreateSpecAlertVM = {
        let vm = FoodsCreateSpecAlertVM.init(frame: .zero)
        vm.confirmBlock = {(spec)in
            self.specVm.specName = "\(spec)"
            self.specVm.updateButton()
            self.naturalVm.specLab.text = "\(spec)"
            self.calculateNaturalMsg()
        }
        return vm
    }()
}

extension PropotionResultVC{
    @objc func saveAction(){
        if self.synVm.switchButton.isSelect == false{
            saveFoodsSoonAction()
        }else{
            let nameString = foodsNameVm.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if nameString == "" {
                MCToast.mc_text("请输入食物名称")
                return
            }
            if self.foodsNameVm.textField.text?.count ?? 0 > 30{
                MCToast.mc_text("食物名称不能超过30个字符")
                return
            }
            let number = self.specVm.numberTextField.text ?? ""
            if number.isNumber() == false{
                self.presentAlertVcNoAction(title: "请输入正确的规格数量", viewController: self)
                return
            }
            if number.count == 0 || number.floatValue == 0{
                MCToast.mc_text("请输入食物规格数量")
                return
            }
            
            if ("\(self.carNumber)").isNumber() == false{
                self.presentAlertVcNoAction(title: "请输入正确的碳水数量", viewController: self)
                return
            }
            if ("\(self.proteinNumber)").isNumber() == false{
                self.presentAlertVcNoAction(title: "请输入正确的蛋白质数量", viewController: self)
                return
            }
            if ("\(self.fatNumber)").isNumber() == false{
                self.presentAlertVcNoAction(title: "请输入正确的脂肪数量", viewController: self)
                return
            }
            sendAddFoodsRequest()
        }
    }
    func calculateNumber() {
        saveButton.isEnabled = false
        if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
            caloriVm.numberLabel.text = ""

            calculateNaturalMsg()
            return
        }
        
        let nameString = foodsNameVm.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if nameString?.count ?? 0 > 0 {
            saveButton.isEnabled = true
        }
        let number = (proteinNumber + carNumber) * 4 + fatNumber * 9
        
//        if caloriVm.unit == "kcal"{
            caloriVm.numberLabel.text = "\(WHUtils.convertStringToString("\(number.rounded())") ?? "")"
//        }else{
//            let numberKj = number * 4.18585
//            caloriVm.numberLabel.text = "\(WHUtils.convertStringToString("\(numberKj.rounded())") ?? "")"
//        }
        caloriVm.changeKjNumber()
        calculateNaturalMsg()
    }
    func calculateNaturalMsg(specNum:String?="-1",caloriesNum:String?="-1") {
        changeUnitNaturalMsg(specNum: specNum,caloriesNum: caloriesNum)
        let num = unitNaturalMsgDict.doubleValueForKey(key: "measurementNum")
        let calories = unitNaturalMsgDict.doubleValueForKey(key: "calories")
        let carbohydrate = unitNaturalMsgDict.doubleValueForKey(key: "carbohydrate")
        let protein = unitNaturalMsgDict.doubleValueForKey(key: "protein")
        let fat = unitNaturalMsgDict.doubleValueForKey(key: "fat")
        
        eatQtyNumber = Float(naturalVm.inputNumer)
        eatCaloriesNumber = Float(calories/num * (naturalVm.inputNumer))
        eatCarNumber = Float(carbohydrate/num * (naturalVm.inputNumer))
        eatProteinNumber = Float(protein/num * (naturalVm.inputNumer))
        eatFatNumber = Float(fat/num * (naturalVm.inputNumer))
        
        self.naturalVm.carboNumLabel.text = "碳水 \(WHUtils.convertStringToStringOneDigit("\(eatCarNumber)") ?? "0")g"
        self.naturalVm.proteinNumLabel.text = "蛋白质 \(WHUtils.convertStringToStringOneDigit("\(eatProteinNumber)") ?? "0")g"
        self.naturalVm.fatNumLabel.text = "脂肪 \(WHUtils.convertStringToStringOneDigit("\(eatFatNumber)") ?? "0")g"
        
        let caloriesAttr = NSMutableAttributedString(string: WHUtils.convertStringToStringNoDigit("\(eatCaloriesNumber)") ?? "0")
        var caloriesUnitAttr = NSMutableAttributedString(string: "千卡")
//        var caloriesUnitAttr = NSMutableAttributedString(string: "热量(千卡)")
//        if caloriVm.unit == "kcal"{
//            
//        }else{
//            caloriesUnitAttr = NSMutableAttributedString(string: "热量(千焦)")
//        }
        
        caloriesAttr.yy_color = .COLOR_TEXT_TITLE_0f1214
        caloriesAttr.yy_font = .systemFont(ofSize: 20, weight: .semibold)
        caloriesUnitAttr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        caloriesUnitAttr.yy_font = .systemFont(ofSize: 11, weight: .regular)
        caloriesAttr.append(caloriesUnitAttr)
        self.naturalVm.caloriesLabel.attributedText = caloriesAttr
    }
    func calculateNaturalMsgChangeQty() {
        let num = unitNaturalMsgDict.doubleValueForKey(key: "measurementNum")
        let calories = unitNaturalMsgDict.doubleValueForKey(key: "calories")
        let carbohydrate = unitNaturalMsgDict.doubleValueForKey(key: "carbohydrate")
        let protein = unitNaturalMsgDict.doubleValueForKey(key: "protein")
        let fat = unitNaturalMsgDict.doubleValueForKey(key: "fat")
        
        eatQtyNumber = Float(naturalVm.inputNumer)
        eatCaloriesNumber = Float(calories/num * (naturalVm.inputNumer))
        eatCarNumber = Float(carbohydrate/num * (naturalVm.inputNumer))
        eatProteinNumber = Float(protein/num * (naturalVm.inputNumer))
        eatFatNumber = Float(fat/num * (naturalVm.inputNumer))
        
//        let caloriesNum = calories/num * Double(naturalVm.inputNumer)
//        let carboNum = carbohydrate/num * Double(naturalVm.inputNumer)
//        let proteinNum = protein/num * Double(naturalVm.inputNumer)
//        let fatNum = fat/num * Double(naturalVm.inputNumer)
        
//        self.naturalVm.caloriesLabel.text = WHUtils.convertStringToStringNoDigit("\(caloriesNum)")
        self.naturalVm.carboNumLabel.text = "碳水 \(WHUtils.convertStringToStringOneDigit("\(eatCarNumber)") ?? "0")g"
        self.naturalVm.proteinNumLabel.text = "蛋白质 \(WHUtils.convertStringToStringOneDigit("\(eatProteinNumber)") ?? "0")g"
        self.naturalVm.fatNumLabel.text = "脂肪 \(WHUtils.convertStringToStringOneDigit("\(eatFatNumber)") ?? "0")g"
        
        let caloriesAttr = NSMutableAttributedString(string: WHUtils.convertStringToStringNoDigit("\(eatCaloriesNumber)") ?? "0")
        var caloriesUnitAttr = NSMutableAttributedString(string: "千卡")
//        var caloriesUnitAttr = NSMutableAttributedString(string: "热量(千卡)")
//        if caloriVm.unit == "kcal"{
//            
//        }else{
//            caloriesUnitAttr = NSMutableAttributedString(string: "热量(千焦)")
//        }
        
        caloriesAttr.yy_color = .COLOR_TEXT_TITLE_0f1214
        caloriesAttr.yy_font = .systemFont(ofSize: 20, weight: .semibold)
        caloriesUnitAttr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        caloriesUnitAttr.yy_font = .systemFont(ofSize: 11, weight: .regular)
        caloriesAttr.append(caloriesUnitAttr)
        self.naturalVm.caloriesLabel.attributedText = caloriesAttr
    }
    ///更新单位营养素信息
    func changeUnitNaturalMsg(specNum:String?="-1",caloriesNum:String?="-1") {
//        if self.specVm.numberInput == false{
//            naturalVm.textField.text = self.specVm.numberTextField.text
//            naturalVm.inputNumer = self.specVm.numberTextField.text?.doubleValue ?? 1
//        }
        
        if specNum == "-1"{
            if self.specVm.numberTextField.text?.count ?? 0 > 0 {
                naturalVm.defaultNumer = (self.specVm.numberTextField.text ?? "1").intValue
                unitNaturalMsgDict.setValue("\(self.specVm.numberTextField.text ?? "1")", forKey: "measurementNum")
            }else{
                naturalVm.defaultNumer = (self.specVm.numberTextField.placeholder ?? "1").intValue
                unitNaturalMsgDict.setValue("\(self.specVm.numberTextField.placeholder ?? "1")", forKey: "measurementNum")
            }
        }else{
            naturalVm.defaultNumer = specNum?.intValue ?? 1
            unitNaturalMsgDict.setValue("\(specNum ?? "1")", forKey: "measurementNum")
        }
//        
//        if
        
        if caloriesNum == "-1"{
            unitNaturalMsgDict.setValue("\(caloriVm.numberLabel.text ?? "0")", forKey: "calories")
        }else{
            if caloriesNum?.count ?? 0 > 0 {
                unitNaturalMsgDict.setValue("\(caloriesNum ?? "0")", forKey: "calories")
            }else{
                unitNaturalMsgDict.setValue("0", forKey: "calories")
            }
        }
        
        naturalVm.textField.placeholder = "\(naturalVm.defaultNumer)"
        unitNaturalMsgDict.setValue("\(self.carNumber)", forKey: "carbohydrate")
        unitNaturalMsgDict.setValue("\(self.proteinNumber)", forKey: "protein")
        unitNaturalMsgDict.setValue("\(self.fatNumber)", forKey: "fat")
    }
}

extension PropotionResultVC{
    func initUI() {
        initNavi(titleStr: "营养成分")
        self.backArrowButton.tapBlock = {()in
//            self.presentAlertVc(confirmBtn: "返回", message: "", title: "返回后不会保存当前页面信息", cancelBtn: "取消", handler: { action in
                if let viewControllers = self.navigationController?.viewControllers{
                    for vc in viewControllers{
                        if vc.isKind(of: FoodsListNewVC.self){
                            self.navigationController?.popToViewController(vc, animated: true)
                            break
                        }
                    }
                }
//                self.backTapAction()
//            }, viewController: self)
        }
        
        view.insertSubview(bottomView, belowSubview: self.navigationView)
        self.navigationView.addShadow(opacity: 0.08, offset:CGSize(width: 0, height: 2))
        
        bottomView.addSubview(scrollViewBase)
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-kFitWidth(60)-getBottomSafeAreaHeight())
        scrollViewBase.bounces = false
        scrollViewBase.addSubview(foodsNameVm)
        scrollViewBase.addSubview(specVm)
        scrollViewBase.addSubview(caloriVm)
        scrollViewBase.addSubview(proteinVm)
        scrollViewBase.addSubview(fatVm)
        scrollViewBase.addSubview(carboVm)
        scrollViewBase.addSubview(synVm)
        scrollViewBase.addSubview(naturalVm)
        
        scrollViewBase.contentSize = CGSize.init(width: 0, height: self.naturalVm.frame.maxY)
        
        bottomView.addSubview(btnBgView)
        btnBgView.addSubview(saveButton)
        btnBgView.addShadow(opacity: 0.08,offset: CGSize.init(width: 0, height: -3))
        
        bottomView.addSubview(specAlertVm)
        initMsg()
        changeUnitNaturalMsg()
    }
    func initMsg() {
        if msgDict.stringValueForKey(key: "measurementUnit").lowercased() == "ml" ||
            msgDict.stringValueForKey(key: "measurementUnit") == "毫升"{
            self.specArray = ["毫升"]
            self.naturalVm.specLab.text = "毫升"
        }else if msgDict.stringValueForKey(key: "measurementUnit").lowercased() == "g" ||
            msgDict.stringValueForKey(key: "measurementUnit") == "克"{
            self.specArray = ["克"]
            self.naturalVm.specLab.text = "克"
        }

        sendSpecEnumRequest()
        foodsNameVm.textField.text = msgDict.stringValueForKey(key: "fname")
        carboVm.textField.text = WHUtils.convertStringToStringOneDigit(msgDict.stringValueForKey(key: "carbohydrate"))
        proteinVm.textField.text = WHUtils.convertStringToStringOneDigit(msgDict.stringValueForKey(key: "protein"))
        fatVm.textField.text = WHUtils.convertStringToStringOneDigit(msgDict.stringValueForKey(key: "fat"))
        
        carNumber = msgDict.stringValueForKey(key: "carbohydrate").floatValue
        proteinNumber = msgDict.stringValueForKey(key: "protein").floatValue
        fatNumber = msgDict.stringValueForKey(key: "fat").floatValue
        
        
        if msgDict.stringValueForKey(key: "fname").trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            saveButton.isEnabled = true
        }
        
        if msgDict.stringValueForKey(key: "measurementNum").intValue > 0 {
            specVm.numberTextField.text = "\(msgDict.stringValueForKey(key: "measurementNum").intValue)"
        }
        
        if msgDict.stringValueForKey(key: "energyUnit").lowercased() == "kj"{
            caloriVm.unit = "kj"
            caloriVm.refreshKcal(kjNumber: WHUtils.convertStringToStringNoDigit(msgDict.stringValueForKey(key: "calories")) ?? "")
        }else{
            caloriVm.numberLabel.text = WHUtils.convertStringToStringNoDigit(msgDict.stringValueForKey(key: "calories"))
            caloriVm.changeKjNumber()
        }
        
        switch self.sourceType {
        case .logs:
            
            break
        case .merge:
            saveButton.setTitle("添加食材", for: .normal)
        case .plan:
            saveButton.setTitle("添加到计划", for: .normal)
        case .main:
            saveButton.setTitle("确定", for: .normal)
        case .meals_create:
            saveButton.setTitle("添加到餐食", for: .normal)
        case .plan_update:
            saveButton.setTitle("添加到计划", for: .normal)
        case .other:
            saveButton.setTitle("确定", for: .normal)
        }
    }
}

extension PropotionResultVC{
    func sendAddFoodsRequest() {
        MCToast.mc_loading(text: "食物创建中...")
        let spec = [["specNum":"\(self.specVm.numberTextField.text ?? "1")",
                     "specName":"\(self.specVm.specName)"]]
        var calories = self.caloriVm.numberLabel.text
        
        if calories == "" {
            calories = "0"
        }
//        if self.caloriVm.unit == "kj"{
//            let caloriesFLoat = (calories?.floatValue ?? 0)/4.18585
//            calories = "\(WHUtils.convertStringToString("\(caloriesFLoat.rounded())") ?? "0")"
//            
//            self.eatCaloriesNumber = self.eatCaloriesNumber/4.18585
//        }
        let param = ["fname":"\(foodsNameVm.textField.text ?? "".trimmingCharacters(in: .whitespacesAndNewlines))",
                     "calories":"\(calories ?? "0")".replacingOccurrences(of: ",", with: "."),
                     "protein":"\(WHUtils.convertStringToString("\(self.proteinNumber)") ?? "0")".replacingOccurrences(of: ",", with: "."),
                     "fat":"\(WHUtils.convertStringToString("\(self.fatNumber)") ?? "0")".replacingOccurrences(of: ",", with: "."),
                     "carbohydrate":"\(WHUtils.convertStringToString("\(self.carNumber)") ?? "0")".replacingOccurrences(of: ",", with: "."),
                     "spec":self.getJSONStringFromArray(array: spec as NSArray)] as NSMutableDictionary
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_save, parameters: param as? [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: "\(responseObject)")
            MCToast.mc_text("“\(self.foodsNameVm.textField.text ?? "")”创建成功",respond: .allow)
            
            let dataStrig = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            
            param.setValue("\(dataStrig ?? "")", forKey: "fid")
            param.setValue("\(self.specVm.specName)", forKey: "specName")
            param.setValue("\(self.specVm.numberTextField.text ?? "1")", forKey: "specNum")
            param.setValue("\(self.eatQtyNumber)".replacingOccurrences(of: ",", with: "."), forKey: "qty")
            UserDefaults.saveFoods(foodsDict: param as NSDictionary,forKey: .myFoodsList)
//            WHUtils().sendAddFoodsForCountRequest(fids: ["\(dataStrig ?? "")"])
            
            param.setValue("\(self.specVm.specName)", forKey: "spec")
//            param.setValue("\(self.specVm.numberTextField.text ?? "1")", forKey: "qty")
            param.setValue("\(self.eatQtyNumber)".replacingOccurrences(of: ",", with: "."), forKey: "weight")
            param.setValue("\(self.eatQtyNumber)".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
//            param.setValue("\(self.specVm.numberTextField.text ?? "1")", forKey: "weight")
//            param.setValue("\(self.specVm.numberTextField.text ?? "1")", forKey: "specNum")
            param.setValue("\(self.eatProteinNumber)".replacingOccurrences(of: ",", with: "."), forKey: "proteinNumber")
            param.setValue("\(self.eatCarNumber)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrateNumber")
            param.setValue("\(self.eatFatNumber)".replacingOccurrences(of: ",", with: "."), forKey: "fatNumber")
            param.setValue("\(WHUtils.convertStringToString("\(self.eatCaloriesNumber)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "caloriesNumber")
            param.setValue("1", forKey: "select")
            param.setValue("1", forKey: "state")
            param.setValue("\(self.specVm.specName)", forKey: "specName")
            param.setValue("\(self.specVm.specName)", forKey: "spec")
            param.setValue("\(self.eatProteinNumber)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
            param.setValue("\(self.eatCarNumber)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
            param.setValue("\(self.eatFatNumber)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
            param.setValue("\(WHUtils.convertStringToString("\(self.eatCaloriesNumber)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
            
//            param.setValue("\(self.proteinNumber)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
//            param.setValue("\(self.carNumber)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
//            param.setValue("\(self.fatNumber)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
//            param.setValue("\(WHUtils.convertStringToString("\(calories ?? "")") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
            
            self.sendFoodsDetailRequest(fid: "\(dataStrig ?? "")", paramFoods: param)
            WHUtils().sendAddHistoryFoods(foodsMsgArray: [param])
        }
    }
    func sendFoodsDetailRequest(fid:String,paramFoods:NSDictionary){
        let param = ["fid":"\(fid)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_query_id, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let foodsMsgDict = self.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendFoodsDetailRequest:\(foodsMsgDict)")
            let foodMsg = NSMutableDictionary(dictionary: paramFoods)
            foodMsg.setValue(foodsMsgDict, forKey: "foods")
            UserDefaults.saveFoods(foodsDict: foodMsg)
            
            switch self.sourceType {
            case .logs:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForLogs"), object: foodMsg)
                self.navigationController?.popToRootViewController(animated: true)
            case .merge:
                DLLog(message: "融合食物")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsUpdateForMerge"), object: foodMsg)
                if let viewControllers = self.navigationController?.viewControllers {
                    for vc in viewControllers{
                        if vc.isKind(of: FoodsMergeVC.self){
                            self.navigationController?.popToViewController(vc, animated: true)
                            break
                        }
                    }
                }
            case .plan:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForPlan"), object: foodMsg)
                if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 2 {
                    for vc in viewControllers{
                        if vc.isKind(of: PlanCreateVC.self){
                            self.navigationController?.popToViewController(vc, animated: true)
                            break
                        }
                    }
                }
            case .plan_update:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsUpdateForPlan"), object: foodMsg)
                if let viewControllers = self.navigationController?.viewControllers{
                    for vc in viewControllers{
                        if vc.isKind(of: PlanDetailVC.self){
                            self.navigationController?.popToViewController(vc, animated: true)
                            break
                        }
                    }
                }
            case .meals_create:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForMeals"), object: foodMsg)
                if let viewControllers = self.navigationController?.viewControllers {
                    for vc in viewControllers{
                        if vc.isKind(of: MealsDetailsVC.self){
                            self.navigationController?.popToViewController(vc, animated: true)
                            break
                        }
                    }
                }
            case .other:
//                self.backTapAction()
                if let viewControllers = self.navigationController?.viewControllers {
                    for vc in viewControllers{
                        if vc.isKind(of: FoodsListNewVC.self){
                            self.navigationController?.popToViewController(vc, animated: true)
                            return
                        }
                    }
                }
                self.backTapAction()
            case .main:
                if let viewControllers = self.navigationController?.viewControllers {
                    for vc in viewControllers{
                        if vc.isKind(of: FoodsListNewVC.self){
                            self.navigationController?.popToViewController(vc, animated: true)
                            return
                        }
                    }
                }
                self.backTapAction()
                break
            }
        }
    }
    func sendSpecEnumRequest() {
        WHNetworkUtil.shareManager().GET(urlString: URL_foods_spec_enum) { responseObject in
            let dataObj = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            DLLog(message: "\(dataObj ?? "")")
            let arr = self.getArrayFromJSONString(jsonString: dataObj ?? "[]")
//            self.specAlertVm.setSpecArr(arr: self.specArray)
            self.specAlertVm.setSpecArr(arr: arr as! [String])
            self.specAlertVm.reloadPickerIndex(arr: self.specArray)
            self.specVm.specName = "\( self.specArray[0])"
            self.specVm.updateButtonForAi()
            if arr.count > 0 {
                self.specArray = arr as! [String]
            }else{
                self.specArray = ["份"]
            }
        }
    }
    @objc func saveFoodsSoonAction(){
        var calories = "\(self.eatCaloriesNumber)"//self.caloriVm.numberLabel.text ?? "0"
        
        if calories == "" {
            calories = "0"
        }
//        if self.caloriVm.unit == "kj"{
//            let caloriesFLoat = (calories.floatValue)/4.18585
//            calories = "\(WHUtils.convertStringToString("\(caloriesFLoat.rounded())") ?? "0")"
//        }
        
        if calories.floatValue >= 100000 {
            MCToast.mc_text("食物热量数据错误！")
            return
        }
        if carNumber >= 100000 {
            MCToast.mc_text("食物碳水数据错误！")
            return
        }
        if proteinNumber >= 100000 {
            MCToast.mc_text("食物蛋白质数据错误！")
            return
        }
        if fatNumber >= 100000 {
            MCToast.mc_text("食物脂肪数据错误！")
            return
        }
        
        let foodsDict = ["proteinNumber":"\(eatProteinNumber)",
                         "carbohydrateNumber":"\(eatCarNumber)",
                         "fatNumber":"\(eatFatNumber)",
                         "caloriesNumber":"\(calories)".replacingOccurrences(of: ",", with: "."),
                         "protein":"\(eatProteinNumber)",
                          "carbohydrate":"\(eatCarNumber)",
                          "fat":"\(eatFatNumber)",
                         "calories":"\(calories)".replacingOccurrences(of: ",", with: "."),
                         "state":"1",
                         "ctype":"3",
//                         "remark":"\((self.remarkVm.textField.text ?? "").disable)",
                         "remark":"\((self.foodsNameVm.textField.text ?? "").disable_emoji(text: (self.foodsNameVm.textField.text ?? "")as NSString))",
                         "fname":"快速添加"]
//        let foodsDict = ["proteinNumber":"\(proteinNumber)",
//                         "carbohydrateNumber":"\(carNumber)",
//                         "fatNumber":"\(fatNumber)",
//                         "caloriesNumber":"\(calories)".replacingOccurrences(of: ",", with: "."),
//                         "protein":"\(proteinNumber)",
//                          "carbohydrate":"\(carNumber)",
//                          "fat":"\(fatNumber)",
//                         "calories":"\(calories)".replacingOccurrences(of: ",", with: "."),
//                         "state":"1",
//                         "ctype":"3",
////                         "remark":"\((self.remarkVm.textField.text ?? "").disable)",
//                         "remark":"\((self.foodsNameVm.textField.text ?? "").disable_emoji(text: (self.foodsNameVm.textField.text ?? "")as NSString))",
//                         "fname":"快速添加"]
        switch self.sourceType {
        case .logs:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fastAddFoods"), object: foodsDict)
            navigationController?.popToRootViewController(animated: true)
        case .merge:
            DLLog(message: "融合食物")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsUpdateForMerge"), object: foodsDict)
            if let viewControllers = self.navigationController?.viewControllers {
                for vc in viewControllers{
                    if vc.isKind(of: FoodsMergeVC.self){
                        self.navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
            }
        case .plan:
            if let viewControllers = navigationController?.viewControllers, viewControllers.count > 2 {
                for vc in viewControllers{
                    if vc.isKind(of: PlanCreateVC.self) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fastAddFoodsForPlan"), object: foodsDict)
                        navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
            }
        case .plan_update:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsUpdateForPlan"), object: foodsDict)
            if let viewControllers = navigationController?.viewControllers{
                for vc in viewControllers{
                    if vc.isKind(of: PlanDetailVC.self){
                        navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
            }
        case .meals_create:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForMeals"), object: foodsDict)
            if let viewControllers = navigationController?.viewControllers {
                for vc in viewControllers{
                    if vc.isKind(of: MealsDetailsVC.self){
                        navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
            }
        case .other:
            if let viewControllers = self.navigationController?.viewControllers {
                for vc in viewControllers{
                    if vc.isKind(of: FoodsListNewVC.self){
                        self.navigationController?.popToViewController(vc, animated: true)
                        return
                    }
                }
            }
            self.backTapAction()
        case .main:
            if let viewControllers = self.navigationController?.viewControllers {
                for vc in viewControllers{
                    if vc.isKind(of: FoodsListNewVC.self){
                        self.navigationController?.popToViewController(vc, animated: true)
                        return
                    }
                }
            }
            self.backTapAction()
            break
        }
    }
}

extension PropotionResultVC{
    @objc func keyboardWillShow(notification: NSNotification) {
        if self.fatVm.textField.isEditing{
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//                if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let carboVmBottomGap = (SCREEN_HEIGHT-self.fatVm.frame.maxY)
                if carboVmBottomGap < keyboardSize.size.height{
                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                        self.bottomView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5-(keyboardSize.size.height-carboVmBottomGap))
                    }
                }
            }
        }else if self.proteinVm.textField.isEditing{
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//                if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let carboVmBottomGap = (SCREEN_HEIGHT-self.proteinVm.frame.maxY)
                if carboVmBottomGap < keyboardSize.size.height{
                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                        self.bottomView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5-(keyboardSize.size.height-carboVmBottomGap))
                    }
                }
            }
        }else{
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.bottomView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.bottomView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
        }
    }
}

