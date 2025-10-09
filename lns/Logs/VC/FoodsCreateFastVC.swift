//
//  FoodsCreateFastVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import MCToast
import UMCommon
import IQKeyboardManagerSwift

class FoodsCreateFastVC: WHBaseViewVC {
    
    var isFromPlan = false
    var msgDict = NSDictionary()
    var sourceType = ADD_FOODS_SOURCE.other
    
    var carNumber = Float(0)
    var proteinNumber = Float(0)
    var fatNumber = Float(0)
    
    var fastAddBlock:((NSDictionary)->())?
    
    override func viewWillAppear(_ animated: Bool) {
        //        proteinVm.textField.becomeFirstResponder()
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
//        self.remarkVm.textField.startCountdown()
    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        IQKeyboardManager.shared.enable = true
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
////        self.remarkVm.textField.disableTimer()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    lazy var bottomView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        
        return vi
    }()
    lazy var caloriVm : FoodsCreateCaloriVM = {
        let vm = FoodsCreateCaloriVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(24), width: 0, height: 0))
        vm.numberLabel.isEnabled = true
        vm.numberTapView.isUserInteractionEnabled = true
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
        let vm = FoodsCreateItemVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(88), width: 0, height: 0))
        vm.titleLabel.text = "碳水"
        vm.maxLength = 4
        vm.numberChangeBlock = {(number)in
            self.carNumber = Float(number) ?? 0.0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var proteinVm : FoodsCreateItemVM = {
        let vm = FoodsCreateItemVM.init(frame: CGRect.init(x: 0, y: self.carboVm.frame.maxY, width: 0, height: 0))
        vm.titleLabel.text = "蛋白质"
        vm.maxLength = 4
        vm.numberChangeBlock = {(number)in
            self.proteinNumber = Float(number) ?? 0.0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var fatVm : FoodsCreateItemVM = {
        let vm = FoodsCreateItemVM.init(frame: CGRect.init(x: 0, y: self.proteinVm.frame.maxY, width: 0, height: 0))
        vm.titleLabel.text = "脂肪"
        vm.maxLength = 4
        vm.numberChangeBlock = {(number)in
            self.fatNumber = Float(number) ?? 0.0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var remarkVm: FoodsCreateFastRemarkVM = {
        let vm = FoodsCreateFastRemarkVM.init(frame: CGRect.init(x: 0, y: fatVm.frame.maxY+kFitWidth(4), width: 0, height: 0))
        
        return vm
    }()
    lazy var saveButton: GJVerButton = {
        let btn = GJVerButton()
        btn.frame = CGRect.init(x: kFitWidth(20), y: SCREEN_HEIGHT-kFitWidth(60)-getBottomSafeAreaHeight(), width: SCREEN_WIDHT-kFitWidth(40), height: kFitWidth(48))
        btn.backgroundColor = .THEME
        btn.setTitle("添加", for: .normal)
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
}

extension FoodsCreateFastVC{
    @objc func saveAction(){
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
                         "ctype":self.msgDict.stringValueForKey(key: "ctype"),
//                         "remark":"\((self.remarkVm.textField.text ?? "").disable)",
                         "remark":"\((self.remarkVm.textField.text ?? "").disable_emoji(text: (self.remarkVm.textField.text ?? "")as NSString))",
                         "fname":"快速添加"]
        
        if isFromPlan{
            if let viewControllers = navigationController?.viewControllers, viewControllers.count > 2 {
                for vc in viewControllers{
                    if vc.isKind(of: PlanCreateVC.self) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fastAddFoodsForPlan"), object: foodsDict)
                        navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
            }
        }else{
            if self.sourceType == .meals_create{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForMeals"), object: foodsDict)
                if let viewControllers = navigationController?.viewControllers {
                    for vc in viewControllers{
                        if vc.isKind(of: MealsDetailsVC.self){
                            navigationController?.popToViewController(vc, animated: true)
                            break
                        }
                    }
                }
            }else if self.sourceType == .plan_update{
                MobClick.event("planUpdateFoods")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsUpdateForPlan"), object: foodsDict)
                if let viewControllers = navigationController?.viewControllers{
                    for vc in viewControllers{
                        if vc.isKind(of: PlanDetailVC.self){
                            navigationController?.popToViewController(vc, animated: true)
                            break
                        }
                    }
                }
            }else if self.sourceType == .merge{
                MobClick.event("planUpdateFoodsMerge")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsUpdateForMerge"), object: foodsDict)
                if let viewControllers = navigationController?.viewControllers{
                    for vc in viewControllers{
                        if vc.isKind(of: FoodsMergeVC.self){
                            navigationController?.popToViewController(vc, animated: true)
                            break
                        }
                    }
                }
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fastAddFoods"), object: foodsDict)
                navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    func setNumber(dict:NSDictionary) {
        self.msgDict = dict
        self.carNumber = Float(dict.stringValueForKey(key: "carbohydrate")) ?? 0.0
        self.proteinNumber = Float(dict.stringValueForKey(key: "protein")) ?? 0.0
        self.fatNumber = Float(dict.stringValueForKey(key: "fat")) ?? 0.0
        caloriVm.numberLabel.text = dict.stringValueForKey(key: "calories")
        carboVm.textField.text = dict.stringValueForKey(key: "carbohydrate")
        proteinVm.textField.text = dict.stringValueForKey(key: "protein")
        fatVm.textField.text = dict.stringValueForKey(key: "fat")
        remarkVm.textField.text = dict.stringValueForKey(key: "remark")
        
        if msgDict.stringValueForKey(key: "ctype") == "3"{
            remarkVm.isHidden = true
            self.naviTitleLabel.text = msgDict.stringValueForKey(key: "remark")
        }
        saveButton.setTitle("保存", for: .normal)
        saveButton.isEnabled = true
    }
    func calculateNumber() {
        saveButton.isEnabled = false
        if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
            caloriVm.numberLabel.text = ""
            return
        }
        saveButton.isEnabled = true
        
        let number = (proteinNumber + carNumber) * 4 + fatNumber * 9
        
        if caloriVm.unit == "kcal"{
            caloriVm.numberLabel.text = "\(WHUtils.convertStringToString("\(number.rounded())") ?? "")"
        }else{
            let numberKj = number * 4.18585
            caloriVm.numberLabel.text = "\(WHUtils.convertStringToString("\(numberKj.rounded())") ?? "")"
        }
        
//        caloriVm.numberLabel.text = "\(String(format: "%.0f", number.rounded()))"
    }
}

extension FoodsCreateFastVC{
    func initUI() {
        initNavi(titleStr: "快速添加")
        view.insertSubview(bottomView, belowSubview: self.navigationView)
        
        bottomView.addSubview(caloriVm)
        bottomView.addSubview(proteinVm)
        bottomView.addSubview(fatVm)
        bottomView.addSubview(carboVm)
        bottomView.addSubview(remarkVm)
        
        bottomView.addSubview(saveButton)
        
        if msgDict.stringValueForKey(key: "ctype") == "3"{
            remarkVm.isHidden = true
            self.naviTitleLabel.text = msgDict.stringValueForKey(key: "remark")
        }
    }
}


extension FoodsCreateFastVC{
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let carboVmBottomGap = (SCREEN_HEIGHT-self.remarkVm.frame.maxY)
            if carboVmBottomGap < keyboardSize.size.height{
                UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                    self.bottomView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5-(keyboardSize.size.height-carboVmBottomGap))
                }
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.bottomView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
        }
    }
}
