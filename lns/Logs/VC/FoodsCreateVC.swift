//
//  FoodsCreateVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import MCToast
import IQKeyboardManagerSwift
import UMCommon

class FoodsCreateVC: WHBaseViewVC {
    
    var carNumber = Float(0)
    var proteinNumber = Float(0)
    var fatNumber = Float(0)
    
    var addBlock:(()->())?
    var specArray = ["克"]
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
        MobClick.beginLogPageView("创建食物")
    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        MobClick.beginLogPageView("创建食物")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendSpecEnumRequest()
    }
    lazy var bottomView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var foodsNameVm : FoodsCreateNameVM = {
        let vm = FoodsCreateNameVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(12), width: 0, height: 0))
        
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
        let vm = FoodsCreateCaloriVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(163), width: 0, height: 0))
//        vm.numberLabel.isEnabled = false
        vm.numberChangeBlock = {(number)in
            DLLog(message: "热量数值输入：\(number)")
            self.judgeCaloriNum(caloriesNum: number)
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
    lazy var tipsLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(16), y: caloriVm.frame.maxY, width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(40)))
        lab.text = "热量与营养素相差较大，建议核对数值/单位"
        lab.textColor = .COLOR_TIPS
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.alpha = 0
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var carboVm : FoodsCreateItemVM = {
        let vm = FoodsCreateItemVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(232), width: 0, height: 0))
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
    lazy var saveButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = CGRect.init(x: kFitWidth(20), y: SCREEN_HEIGHT-kFitWidth(60)-getBottomSafeAreaHeight(), width: SCREEN_WIDHT-kFitWidth(40), height: kFitWidth(48))
        btn.backgroundColor = .THEME
        btn.setTitle("保存", for: .normal)
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
        }
        return vm
    }()
}

extension FoodsCreateVC{
    @objc func saveAction(){
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
//        if self.specVm.specName == "克" && Int32(self.carNumber + self.proteinNumber + self.fatNumber) > (self.specVm.numberTextField.text! as NSString).intValue{
//            MCToast.mc_text("蛋白质+脂肪+碳水 不能超过\(self.specVm.numberTextField.text ?? "100")g")
//            return
//        }
        MobClick.event("createFoods")
        sendAddFoodsRequest()
    }
    func calculateNumber() {
        saveButton.isEnabled = false
        if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
            caloriVm.numberLabel.text = ""
        }
        let nameString = foodsNameVm.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if nameString?.count ?? 0 > 0 {
            saveButton.isEnabled = true
        }
        let number = (proteinNumber + carNumber) * 4 + fatNumber * 9
        
        if caloriVm.unit == "kcal"{
            caloriVm.numberLabel.text = "\(WHUtils.convertStringToString("\(number.rounded())") ?? "")"
            self.judgeCaloriNum(caloriesNum: "\(number)")
        }else{
            let numberKj = number * 4.18585
            caloriVm.numberLabel.text = "\(WHUtils.convertStringToString("\(numberKj.rounded())") ?? "")"
            self.judgeCaloriNum(caloriesNum: "\(numberKj)")
        }
    }
    //用户输入的卡路里 如果小于计算值的70% 或 大于计算值的130%，且两者绝对值超过20千卡时，提示用户
    func judgeCaloriNum(caloriesNum:String) {
        var caloNumTemp = (proteinNumber + carNumber) * 4 + fatNumber * 9
        if caloriVm.unit == "kcal"{
            
        }else{
            caloNumTemp = caloNumTemp * 4.18585
        }
        
        var carboCenterY = getNavigationBarHeight()+kFitWidth(232) + self.carboVm.selfHeight*0.5
        if (caloriesNum.floatValue < caloNumTemp * 0.7 || caloriesNum.floatValue > caloNumTemp * 1.3) && abs(caloriesNum.floatValue - caloNumTemp) > 20{
            carboCenterY = self.tipsLabel.frame.maxY + self.carboVm.selfHeight*0.5
            UIView.animate(withDuration: 0.35, animations: {
                self.tipsLabel.alpha = 1
            })
        }else{
            UIView.animate(withDuration: 0.25, animations: {
                self.tipsLabel.alpha = 0
            })
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.carboVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: carboCenterY)
            self.proteinVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: carboCenterY+self.carboVm.selfHeight)
            self.fatVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: carboCenterY+self.carboVm.selfHeight*2)
        })
    }
}

extension FoodsCreateVC{
    func initUI() {
        initNavi(titleStr: "创建食物")
        
        view.insertSubview(bottomView, belowSubview: self.navigationView)
        
        bottomView.addSubview(foodsNameVm)
        bottomView.addSubview(specVm)
        bottomView.addSubview(caloriVm)
        bottomView.addSubview(tipsLabel)
        bottomView.addSubview(proteinVm)
        bottomView.addSubview(fatVm)
        bottomView.addSubview(carboVm)
        bottomView.addSubview(saveButton)
        
        bottomView.addSubview(specAlertVm)
    }
}

extension FoodsCreateVC{
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
//            param.setValue("\(self.specVm.numberTextField.text ?? "1")", forKey: "qty")
            WHUtils().sendAddHistoryFoods(foodsMsgArray: [param])
            if self.addBlock != nil{
                self.addBlock!()
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createFoodsSuccess"), object: nil)
            self.backTapAction()
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
                self.specArray = ["克"]
            }
//            self.specArray = responseObject["data"]as? [String] ?? ["克"]
//            self.specArray = arr
            self.specAlertVm.setSpecArr(arr: self.specArray)
        }
    }
}

extension FoodsCreateVC{
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
