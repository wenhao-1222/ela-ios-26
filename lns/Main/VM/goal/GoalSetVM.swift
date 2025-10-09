//
//  GoalSetVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/31.
//

import Foundation
import UIKit
import MCToast

class GoalSetVM: UIView {
    
    let selfHeight = kFitWidth(506)
    var dataDict = NSDictionary()
    
    var confirmBlock:(()->())?
    var dataChangeBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: kFitWidth(16), y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(12)
        self.clipsToBounds = true
        
        initUI()
        self.addShadow()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var typeVm: GoalSetTypeVM = {
        let vm = GoalSetTypeVM.init(frame: CGRect.init(x: kFitWidth(98), y: kFitWidth(20), width: 0, height: 0))
        vm.typeChangeBlock = {(type)in
            self.caloriesVm.changeType(type: type)
            if type == "g"{
                self.specGVm.isHidden = false
                self.specPercentVm.isHidden = true
                self.specPercentVm.caloriesNumber = Int(self.caloriesVm.numberLabel.text ?? "0") ?? 0
                self.caloriesVm.numberLabel.text = "\(self.specGVm.caloriesNumber)"
            }else{
                self.specGVm.isHidden = true
                self.specPercentVm.isHidden = false
                self.specGVm.resignTextField()
                self.caloriesVm.numberLabel.text = "\(self.specPercentVm.caloriesNumber)"
            }
            self.changeDataDict()
        }
        return vm
    }()
    lazy var caloriesVm: GoalSetCaloriesVM = {
        let vm = GoalSetCaloriesVM.init(frame: CGRect.init(x: 0, y: kFitWidth(60), width: 0, height: 0))
        vm.numberChangeBlock = {(calories)in
            self.specPercentVm.updateNumberWithCalories(calories: Int(calories) ?? 0)
            self.changeDataDict()
            
            if self.dataChangeBlock != nil{
                self.dataChangeBlock!()
            }
        }
        return vm
    }()
    lazy var specGVm: GoalSetSpecGVM = {
        let vm = GoalSetSpecGVM.init(frame: CGRect.init(x: 0, y: self.caloriesVm.frame.maxY, width: 0, height: 0))
        vm.carVm.lineView.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
        vm.proteinVm.lineView.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
        vm.fatVm.lineView.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
        vm.caloriChangeBlock = {(calori)in
            self.caloriesVm.numberLabel.text = calori
            self.changeDataDict()
            
            if self.dataChangeBlock != nil{
                self.dataChangeBlock!()
            }
        }
        vm.caloriInitBlock = {(calori)in
            self.caloriesVm.numberLabel.text = calori
            self.specPercentVm.caloriesNumber = Int(calori) ?? 0
            self.specPercentVm.updateNum(specGVm: self.specGVm)
        }
        return vm
    }()
    lazy var specPercentVm: GoalSetSpecPercentVM = {
        let vm = GoalSetSpecPercentVM.init(frame: CGRect.init(x: 0, y: self.caloriesVm.frame.maxY, width: 0, height: 0))
        vm.isHidden = true
        vm.numberChangeBlock = {()in
//            self.specGVm.updateNum(perVm: self.specPercentVm)
            self.changeDataDict()
            
            if self.dataChangeBlock != nil{
                self.dataChangeBlock!()
            }
        }
        
        return vm
    }()
    lazy var nextBtn : UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(442), width: SCREEN_WIDHT-kFitWidth(32)-kFitWidth(32), height: kFitWidth(48))
        btn.setTitle("保存目标", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME, for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .disabled)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.layer.cornerRadius = kFitWidth(4)
        btn.clipsToBounds = true
        
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        
        btn.enablePressEffect()
        
        return btn
    }()
}

extension GoalSetVM{
    @objc func confirmAction() {
        if checkValue(){
            if self.confirmBlock != nil{
                self.confirmBlock!()
            }
        }
    }
    func checkValue() -> Bool {
        if self.typeVm.type == "g"{
            QuestinonaireMsgModel.shared.calories = "\(self.specGVm.caloriesNumber)"
            QuestinonaireMsgModel.shared.carbohydrates = "\(self.specGVm.carNumber)"
            QuestinonaireMsgModel.shared.protein = "\(self.specGVm.proteinNumber)"
            QuestinonaireMsgModel.shared.fats = "\(self.specGVm.fatNumber)"
        }else{
            let totalPercent = self.specPercentVm.carboPercent + self.specPercentVm.proteinPercent + self.specPercentVm.fatPercent
            
            if totalPercent != 100{
                MCToast.mc_text("营养素必须等于100%",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
                return false
            }
            
            QuestinonaireMsgModel.shared.calories = "\(self.specPercentVm.caloriesNumber)"
            QuestinonaireMsgModel.shared.carbohydrates = "\(self.specPercentVm.carNumber)"
            QuestinonaireMsgModel.shared.protein = "\(self.specPercentVm.proteinNumber)"
            QuestinonaireMsgModel.shared.fats = "\(self.specPercentVm.fatNumber)"
        }
        DLLog(message: "QuestinonaireMsgModel:\(QuestinonaireMsgModel.shared.carbohydrates) -- \(QuestinonaireMsgModel.shared.protein)  -- \(QuestinonaireMsgModel.shared.fats)")
        if (QuestinonaireMsgModel.shared.carbohydrates == "0" || QuestinonaireMsgModel.shared.carbohydrates == "") &&
        (QuestinonaireMsgModel.shared.protein == "0" || QuestinonaireMsgModel.shared.protein == "") &&
        (QuestinonaireMsgModel.shared.fats == "0" || QuestinonaireMsgModel.shared.fats == ""){
            MCToast.mc_text("请输入营养素数值",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return false
        }
        
        if Int(QuestinonaireMsgModel.shared.carbohydrates) ?? 0 <= 4999 {
            //Int(QuestinonaireMsgModel.shared.carbohydrates) ?? 0 >= 0 &&
        }else{
            MCToast.mc_text("碳水化合物目标数值范围 0 ~ 4999 g",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return false
        }
        if Int(QuestinonaireMsgModel.shared.protein) ?? 0 <= 4999 {
            //Int(QuestinonaireMsgModel.shared.protein) ?? 0 >= 1 &&
        }else{
            MCToast.mc_text("蛋白质目标数值范围 0 ~ 4999 g",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return false
        }
        //Int(QuestinonaireMsgModel.shared.fats) ?? 0 >= 0 &&
        if Int(QuestinonaireMsgModel.shared.fats) ?? 0 <= 4999 {
            
        }else{
            MCToast.mc_text("脂肪目标数值范围 0 ~ 4999 g",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return false
        }
        return true
    }
    func changeDataDict() {
        if self.typeVm.type == "g"{
            self.dataDict = ["calories":"\(self.specGVm.caloriesNumber)",
                             "proteins":"\(self.specGVm.proteinNumber)",
                             "carbohydrates":"\(self.specGVm.carNumber)",
                             "fats":"\(self.specGVm.fatNumber)"]
        }else{
            self.dataDict = ["calories":"\(self.specPercentVm.caloriesNumber)",
                             "proteins":"\(self.specPercentVm.proteinNumber)",
                             "carbohydrates":"\(self.specPercentVm.carNumber)",
                             "fats":"\(self.specPercentVm.fatNumber)"]
        }
    }
}

extension GoalSetVM{
    func initUI() {
        addSubview(typeVm)
        addSubview(caloriesVm)
        addSubview(specGVm)
        addSubview(specPercentVm)
        addSubview(nextBtn)
//        specGVm.initData()
    }
}
