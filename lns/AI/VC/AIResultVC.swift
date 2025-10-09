//
//  AIResultVC.swift
//  lns
//
//  Created by Elavatine on 2025/3/10.
//

import MCToast
import IQKeyboardManagerSwift
import UMCommon

class AIResultVC: WHBaseViewVC {
    
    var foodsImg = UIImage()
    var msgDict = NSDictionary()
    
    var carNumber = Float(0)
    var proteinNumber = Float(0)
    var fatNumber = Float(0)
    
    var addBlock:(()->())?
    var specArray = ["份"]
    var specChanged = false
    
    var isFromPlan = false
    var sourceType = ADD_FOODS_SOURCE.other
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
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
        
        initUI()
        sendSpecEnumRequest()
        
//        if self.msgDict.doubleValueForKey(key: "calories") > 0 || self.carNumber > 0 || self.proteinNumber > 0 || self.fatNumber > 0{
//            saveButton.isEnabled = true
//        }
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
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        vi.clipsToBounds = true
        
        return vi
    }()
    
    lazy var foodsImgView: UIImageView = {
        let img = UIImageView()
        img.image = self.foodsImg
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        
        return img
    }()
    lazy var foodsNameVm : FoodsCreateNameVM = {
        let vm = FoodsCreateNameVM.init(frame: CGRect.init(x: 0, y: statusBarHeight+kFitWidth(132), width: 0, height: 0))
//        let vm = FoodsCreateNameVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(132), width: 0, height: 0))
        vm.textField.text = "\(self.msgDict.stringValueForKey(key: "fname"))"
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
        return vm
    }()
    lazy var caloriVm : FoodsCreateCaloriVM = {
        let vm = FoodsCreateCaloriVM.init(frame: CGRect.init(x: 0, y: specVm.frame.maxY, width: 0, height: 0))
//        vm.numberLabel.isEnabled = false
        vm.numberLabel.text = self.msgDict.stringValueForKey(key: "calories")
        vm.hiddenUnitChange()
        vm.numberChangeBlock = {(number)in
            if number.count > 0 {
                self.saveButton.isEnabled = true
            }else{
                self.saveButton.isEnabled = false
                if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
                    self.caloriVm.numberLabel.text = ""
                    return
                }
                self.saveButton.isEnabled = true
            }
        }
        return vm
    }()
    lazy var carboVm : FoodsCreateItemVM = {
        let vm = FoodsCreateItemVM.init(frame: CGRect.init(x: 0, y: self.caloriVm.frame.maxY, width: 0, height: 0))
        vm.titleLabel.text = "碳水"
        vm.textField.text = self.msgDict.stringValueForKey(key: "carbohydrate")
        self.carNumber = self.msgDict.stringValueForKey(key: "carbohydrate").floatValue
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
        vm.textField.text = self.msgDict.stringValueForKey(key: "protein")
        self.proteinNumber = self.msgDict.stringValueForKey(key: "protein").floatValue
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
        vm.textField.text = self.msgDict.stringValueForKey(key: "fat")
        self.fatNumber = self.msgDict.stringValueForKey(key: "fat").floatValue
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
    lazy var saveButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = CGRect.init(x: kFitWidth(20), y: SCREEN_HEIGHT-kFitWidth(60)-getBottomSafeAreaHeight(), width: SCREEN_WIDHT-kFitWidth(40), height: kFitWidth(48))
        btn.backgroundColor = .THEME
        btn.setTitle("添加到日志", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
//        btn.isEnabled = false
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var specAlertVm: FoodsCreateSpecAlertVM = {
        let vm = FoodsCreateSpecAlertVM.init(frame: .zero)
        vm.confirmBlock = {(spec)in
            self.specVm.specName = "\(spec)"
            self.specVm.updateButtonForAi()
            if self.specChanged == false && (spec == "克" || spec == "g" || spec == "ml" || spec == "毫升"){
                self.specChanged = true
                let totalNum = ceil(self.carNumber + self.proteinNumber + self.fatNumber)
                self.specVm.numberTextField.text = String(format: "%.0f", totalNum)
            }
        }
        return vm
    }()
}

extension AIResultVC{
    func calculateNumber() {
        saveButton.isEnabled = false
        if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
            caloriVm.numberLabel.text = ""
//            return
        }
        let nameString = foodsNameVm.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if nameString?.count ?? 0 > 0 {
            saveButton.isEnabled = true
        }
        let number = (proteinNumber + carNumber) * 4 + fatNumber * 9
        
        if caloriVm.unit == "kcal"{
            caloriVm.numberLabel.text = "\(WHUtils.convertStringToString("\(number.rounded())") ?? "")"
        }else{
            let numberKj = number * 4.18585
            caloriVm.numberLabel.text = "\(WHUtils.convertStringToString("\(numberKj.rounded())") ?? "")"
        }
    }
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
    //        MobClick.event("createFoods")
            sendAddFoodsRequest()
        }
    }
}

extension AIResultVC{
    func initUI() {
        view.addSubview(foodsImgView)
//        view.addSubview(backArrowButton)
        initNavi(titleStr: "")
        self.navigationView.backgroundColor = .clear
        
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
        bottomView.addSubview(scrollViewBase)
        
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.addSubview(foodsNameVm)
        scrollViewBase.addSubview(specVm)
        scrollViewBase.addSubview(caloriVm)
        scrollViewBase.addSubview(proteinVm)
        scrollViewBase.addSubview(fatVm)
        scrollViewBase.addSubview(carboVm)
        scrollViewBase.addSubview(synVm)
        
        bottomView.addSubview(saveButton)
        
        view.addSubview(specAlertVm)
        
        setConstrait()
        specVm.specName = "份"
        specVm.updateButton()
        
        foodsNameVm.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(13))
        scrollViewBase.bounces = false
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: (SCREEN_HEIGHT-kFitWidth(60)-getBottomSafeAreaHeight()))
        scrollViewBase.contentSize = CGSize.init(width: 0, height: self.synVm.frame.maxY + kFitWidth(20))
        
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
    func setConstrait() {
        backArrowButton.snp.makeConstraints { make in
            make.width.height.equalTo(kFitWidth(44))
            make.top.equalTo(statusBarHeight)
            make.left.equalTo(kFitWidth(2))
        }
        foodsImgView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(kFitWidth(305))
        }
    }
}

extension AIResultVC{
    func sendAddFoodsRequest() {
        MCToast.mc_loading(text: "食物创建中...")
        let spec = [["specNum":"\(self.specVm.numberTextField.text ?? "1")",
                     "specName":"\(self.specVm.specName)"]]
        var calories = self.caloriVm.numberLabel.text
        
        if calories == "" {
            calories = "0"
        }
        if self.caloriVm.unit == "kj"{
            let caloriesFLoat = (calories?.floatValue ?? 0)/4.18585
            calories = "\(WHUtils.convertStringToString("\(caloriesFLoat.rounded())") ?? "0")"
        }
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
            param.setValue("\(self.specVm.numberTextField.text ?? "1")", forKey: "qty")
            UserDefaults.saveFoods(foodsDict: param as NSDictionary,forKey: .myFoodsList)
//            WHUtils().sendAddFoodsForCountRequest(fids: ["\(dataStrig ?? "")"])
            
            param.setValue("\(self.specVm.specName)", forKey: "spec")
            param.setValue("\(self.specVm.numberTextField.text ?? "1")", forKey: "qty")
            param.setValue("\(self.specVm.numberTextField.text ?? "1")", forKey: "weight")
            param.setValue("\(self.specVm.numberTextField.text ?? "1")", forKey: "specNum")
            param.setValue("\(self.proteinNumber)".replacingOccurrences(of: ",", with: "."), forKey: "proteinNumber")
            param.setValue("\(self.carNumber)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrateNumber")
            param.setValue("\(self.fatNumber)".replacingOccurrences(of: ",", with: "."), forKey: "fatNumber")
            param.setValue("\(WHUtils.convertStringToString("\(calories ?? "0")") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "caloriesNumber")
            param.setValue("1", forKey: "select")
            param.setValue("1", forKey: "state")
            param.setValue("\(self.specVm.specName)", forKey: "specName")
            param.setValue("\(self.specVm.specName)", forKey: "spec")
            param.setValue("\(self.proteinNumber)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
            param.setValue("\(self.carNumber)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
            param.setValue("\(self.fatNumber)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
            param.setValue("\(WHUtils.convertStringToString("\(calories ?? "")") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
            
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
                MobClick.event("journalEditFoods")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForLogs"), object: foodMsg)
                self.navigationController?.popToRootViewController(animated: true)
            case .plan:
                MobClick.event("planEditFoods")
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
                MobClick.event("planUpdateFoods")
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
            case .merge:
//                DLLog(message: "融合食物")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsUpdateForMerge"), object: foodMsg)
                if let viewControllers = self.navigationController?.viewControllers {
                    for vc in viewControllers{
                        if vc.isKind(of: FoodsMergeVC.self){
                            self.navigationController?.popToViewController(vc, animated: true)
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
    func sendSpecEnumRequest() {
        WHNetworkUtil.shareManager().GET(urlString: URL_foods_spec_enum) { responseObject in
//            let dict = responseObject["data"]as? NSDictionary ?? [:]
            
            let dataObj = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            DLLog(message: "\(dataObj ?? "")")
            let arr = self.getArrayFromJSONString(jsonString: dataObj ?? "[]")
            if arr.count > 0 {
                self.specArray = arr as! [String]
            }else{
                self.specArray = ["份"]
            }
            self.specAlertVm.setSpecArr(arr: self.specArray)
        }
    }
    @objc func saveFoodsSoonAction(){
        var calories = self.caloriVm.numberLabel.text ?? "0"
        
        if calories == "" {
            calories = "0"
        }
        if self.caloriVm.unit == "kj"{
            let caloriesFLoat = (calories.floatValue)/4.18585
            calories = "\(WHUtils.convertStringToString("\(caloriesFLoat.rounded())") ?? "0")"
        }
        if calories != "" && calories != "0"{
            
        }else{
            if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
                MCToast.mc_text("请填写至少一种营养元素含量")
                return
            }
        }
        
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
        
        MobClick.event("createFoodsSoon")
        let foodsDict = ["proteinNumber":"\(proteinNumber)",
                         "carbohydrateNumber":"\(carNumber)",
                         "fatNumber":"\(fatNumber)",
                         "caloriesNumber":"\(calories)".replacingOccurrences(of: ",", with: "."),
                         "protein":"\(proteinNumber)",
                          "carbohydrate":"\(carNumber)",
                          "fat":"\(fatNumber)",
                         "calories":"\(calories)".replacingOccurrences(of: ",", with: "."),
                         "state":"1",
                         "ctype":"3",
//                         "remark":"\((self.remarkVm.textField.text ?? "").disable)",
                         "remark":"\((self.foodsNameVm.textField.text ?? "").disable_emoji(text: (self.foodsNameVm.textField.text ?? "")as NSString))",
                         "fname":"快速添加"]
        
        switch self.sourceType {
        case .logs:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fastAddFoods"), object: foodsDict)
            navigationController?.popToRootViewController(animated: true)
        case .merge:
//            DLLog(message: "融合食物")
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
        
//        
//        if isFromPlan{
//            if let viewControllers = navigationController?.viewControllers, viewControllers.count > 2 {
//                for vc in viewControllers{
//                    if vc.isKind(of: PlanCreateVC.self) {
//                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fastAddFoodsForPlan"), object: foodsDict)
//                        navigationController?.popToViewController(vc, animated: true)
//                        break
//                    }
//                }
//            }
//        }else{
//            if self.sourceType == .meals_create{
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForMeals"), object: foodsDict)
//                if let viewControllers = navigationController?.viewControllers {
//                    for vc in viewControllers{
//                        if vc.isKind(of: MealsDetailsVC.self){
//                            navigationController?.popToViewController(vc, animated: true)
//                            break
//                        }
//                    }
//                }
//            }else if self.sourceType == .plan_update{
//                MobClick.event("planUpdateFoods")
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsUpdateForPlan"), object: foodsDict)
//                if let viewControllers = navigationController?.viewControllers{
//                    for vc in viewControllers{
//                        if vc.isKind(of: PlanDetailVC.self){
//                            navigationController?.popToViewController(vc, animated: true)
//                            break
//                        }
//                    }
//                }
//            }else{
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fastAddFoods"), object: foodsDict)
//                navigationController?.popToRootViewController(animated: true)
//            }
//        }
    }
}

extension AIResultVC{
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
