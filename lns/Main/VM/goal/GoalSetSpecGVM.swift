//
//  GoalSetSpecGVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/31.
//

import Foundation
import UIKit

class GoalSetSpecGVM: UIView {
    
    let selfHeight = kFitWidth(214)
    var carNumber = 0
    var proteinNumber = 0
    var fatNumber = 0
    var caloriesNumber = 0
    var dataIsChanged = false
    
    var caloriChangeBlock:((String)->())?
    var caloriInitBlock:((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: kFitWidth(0), y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
//        initData()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var carVm : QuestionCustomItemVM = {
        let vm = QuestionCustomItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(46), width: SCREEN_WIDHT-kFitWidth(32), height: 0))
        vm.titleLabel.text = "碳水化合物"
        vm.textField.textContentType = nil
        vm.maxLength = 4
//        if QuestinonaireMsgModel.shared.surveytype == "part" {
//            vm.textField.isEnabled = false
//        }
        vm.numberChangeBlock = {(number)in
            self.carNumber = Int(number) ?? 0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var proteinVm : QuestionCustomItemVM = {
        let vm = QuestionCustomItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(102), width: SCREEN_WIDHT-kFitWidth(32), height: 0))
        vm.titleLabel.text = "蛋白质"
        vm.textField.textContentType = nil
        vm.maxLength = 4
//        if QuestinonaireMsgModel.shared.surveytype == "part" {
//            vm.textField.isEnabled = false
//        }
        vm.numberChangeBlock = {(number)in
            self.proteinNumber = Int(number) ?? 0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var fatVm : QuestionCustomItemVM = {
        let vm = QuestionCustomItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(158), width: SCREEN_WIDHT-kFitWidth(32), height: 0))
        vm.titleLabel.text = "脂肪"
        vm.textField.textContentType = nil
        vm.maxLength = 4
//        if QuestinonaireMsgModel.shared.surveytype == "part" {
//            vm.textField.isEnabled = false
//        }
        vm.numberChangeBlock = {(number)in
            self.fatNumber = Int(number) ?? 0
            self.calculateNumber()
        }
        return vm
    }()
}

extension GoalSetSpecGVM{
    func calculateNumber() {
        self.dataIsChanged = true
        if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
            self.caloriesNumber = 0
            if self.caloriChangeBlock != nil{
                self.caloriChangeBlock!("")
            }
            return
        }
        
        self.caloriesNumber = (proteinNumber + carNumber) * 4 + fatNumber * 9
        
        if self.caloriChangeBlock != nil{
            self.caloriChangeBlock!("\(caloriesNumber)")
        }
    }
    func initData() {
        let goalDict = UserDefaults.getTodayGoal()
        
        if Int(goalDict?.floatValueForKey(key: "calories") ?? 0) == 0{
            NutritionDefaultModel.shared.getDefaultGoal(weekDay: Date().getWeekdayIndex(from: Date().nextDay(days: 0)))
            
            self.carNumber = Int(NutritionDefaultModel.shared.carbohydrate) ?? 0
            self.proteinNumber = Int(NutritionDefaultModel.shared.protein) ?? 0
            self.fatNumber = Int(NutritionDefaultModel.shared.fat) ?? 0
            self.caloriesNumber = Int(NutritionDefaultModel.shared.calories) ?? 0
            
            self.carVm.textField.text = NutritionDefaultModel.shared.carbohydrate
            self.proteinVm.textField.text = NutritionDefaultModel.shared.protein
            self.fatVm.textField.text = NutritionDefaultModel.shared.fat
            
            if self.caloriInitBlock != nil{
                self.caloriInitBlock!("\(Int(NutritionDefaultModel.shared.calories) ?? 0)")
            }
        }else{
            self.carNumber = Int(goalDict?.floatValueForKey(key: "carbohydrate") ?? 0)
            self.proteinNumber = Int(goalDict?.floatValueForKey(key: "protein") ?? 0)
            self.fatNumber = Int(goalDict?.floatValueForKey(key: "fat") ?? 0)
            self.caloriesNumber = Int(goalDict?.floatValueForKey(key: "calories") ?? 0)
            
            self.carVm.textField.text = "\(Int(goalDict?.floatValueForKey(key: "carbohydrate") ?? 0))"
            self.proteinVm.textField.text = "\(Int(goalDict?.floatValueForKey(key: "protein") ?? 0))"
            self.fatVm.textField.text = "\(Int(goalDict?.floatValueForKey(key: "fat") ?? 0))"
            
            if self.caloriInitBlock != nil{
                self.caloriInitBlock!("\(Int(goalDict?.floatValueForKey(key: "calories") ?? 0))")
            }
        }
        
    }
    
    func initData(dict:NSDictionary) {
        self.carNumber = Int(dict.doubleValueForKey(key: "carbohydrates"))
        self.proteinNumber = Int(dict.doubleValueForKey(key: "proteins"))
        self.fatNumber = Int(dict.doubleValueForKey(key: "fats"))
        self.caloriesNumber = Int(dict.doubleValueForKey(key: "calories"))
        
        self.carVm.textField.text = dict.stringValueForKey(key: "carbohydrates")
        self.proteinVm.textField.text = dict.stringValueForKey(key: "proteins")
        self.fatVm.textField.text = dict.stringValueForKey(key: "fats")
        
        if self.caloriInitBlock != nil{
            self.caloriInitBlock!("\(dict.stringValueForKey(key: "calories"))")
        }
    }
    
    func updateNum(perVm:GoalSetSpecPercentVM) {
        self.carNumber = perVm.carNumber
        self.proteinNumber = perVm.proteinNumber
        self.fatNumber = perVm.fatNumber
        self.carVm.textField.text = "\(self.carNumber)"
        self.proteinVm.textField.text = "\(self.proteinNumber)"
        self.fatVm.textField.text = "\(self.fatNumber)"
    }
    func resignTextField() {
        self.carVm.textField.resignFirstResponder()
        self.proteinVm.textField.resignFirstResponder()
        self.fatVm.textField.resignFirstResponder()
    }
}

extension GoalSetSpecGVM{
    func initUI() {
        addSubview(carVm)
        addSubview(proteinVm)
        addSubview(fatVm)
        
    }
    func updateConstraitForAlert() {
        carVm.frame = CGRect.init(x: 0, y: kFitWidth(46), width: SCREEN_WIDHT, height: kFitWidth(56))
        proteinVm.frame = CGRect.init(x: 0, y: kFitWidth(102), width: SCREEN_WIDHT, height: kFitWidth(56))
        fatVm.frame = CGRect.init(x: 0, y: kFitWidth(158), width: SCREEN_WIDHT, height: kFitWidth(56))
        
        carVm.updateConstrait()
        proteinVm.updateConstrait()
        fatVm.updateConstrait()
    }
}

