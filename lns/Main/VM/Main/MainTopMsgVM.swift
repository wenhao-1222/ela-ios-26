//
//  MainTopMsgVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/9.
//

import Foundation
import UIKit

class MainTopMsgVM: UIView {
    
    let selfHeight = kFitWidth(296)//+WHUtils().getTopSafeAreaHeight()
    var number = 0
    
    var planTapBlock:(()->())?
    var editBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNaturalData), name: NSNotification.Name(rawValue: "updateMainNatural"), object: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(26), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(270)))
        vi.backgroundColor = .white//UIColor(white: 0.1, alpha: 0.95)//.white
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var titleLab : UILabel = {
        let lab = UILabel()
        lab.text = "今日营养目标"
        lab.font = .systemFont(ofSize: 18, weight: .semibold)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var goalVm : MainTopGoalVM = {
        let vm = MainTopGoalVM.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(50), width: 0, height: 0))
        vm.editBlock = {()in
            self.editActtion()
        }
        return vm
    }()
    lazy var circleVm : MainCircleVM = {
        let vm = MainCircleVM.init(frame: CGRect.init(x: kFitWidth(195), y: 0, width: 0, height: 0))
        
        return vm
    }()
    lazy var circleV : CalCircleView = {
        let v = CalCircleView.init(frame: self.circleVm.frame)
        
        return v
    }()
    lazy var cirlcCoverView : CalFillCircleView = {
        let vi = CalFillCircleView.init(frame: self.circleVm.frame)
        vi.editBlock = {()in
            self.editActtion()
        }
        return vi
    }()
    lazy var carbonVm : MainNutrientItemVM = {
        let vm = MainNutrientItemVM.init(frame: CGRect.init(x: kFitWidth(15), y: kFitWidth(138), width: 0, height: 0))
        vm.titleLabel.text = "碳水"
        vm.progressColor = .COLOR_CARBOHYDRATE
        vm.bottomBgView.backgroundColor = .clear
        vm.editBlock = {()in
            self.editActtion()
        }
//        vm.setNumberMsg(num: "1000", total: "")
        return vm
    }()
    lazy var proteinVm : MainNutrientItemVM = {
        let vm = MainNutrientItemVM.init(frame: CGRect.init(x: self.carbonVm.frame.maxX+kFitWidth(11), y: kFitWidth(138), width: 0, height: 0))
        vm.titleLabel.text = "蛋白质"
        vm.progressColor = .COLOR_PROTEIN
        vm.bottomBgView.backgroundColor = .clear
        vm.editBlock = {()in
            self.editActtion()
        }
//        vm.setNumberMsg(num: "456", total: "1268")
        return vm
    }()
    lazy var fatVm : MainNutrientItemVM = {
        let vm = MainNutrientItemVM.init(frame: CGRect.init(x: self.proteinVm.frame.maxX+kFitWidth(12), y: kFitWidth(138), width: 0, height: 0))
        vm.titleLabel.text = "脂肪"
        vm.progressColor = .COLOR_FAT
        vm.bottomBgView.backgroundColor = .clear
        vm.editBlock = {()in
            self.editActtion()
        }
//        vm.setNumberMsg(num: "456", total: "1268")
        return vm
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
        return vi
    }()
    lazy var planButton : GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.setTitle("饮食计划", for: .normal)
//        btn.enablePressEffectNoneFeedback()
//        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
//        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_TEXT_TITLE_0f1214_03), for: .highlighted)
        btn.clipsToBounds = true
        
        btn.addTarget(self, action: #selector(planTapAction), for: .touchUpInside)
        
        return btn
    }()
}

extension MainTopMsgVM{
    @objc func editActtion() {
        if self.editBlock != nil{
            self.editBlock!()
        }
    }
    @objc func planTapAction() {
        if self.planTapBlock != nil{
            self.planTapBlock!()
        }
    }
    func updateNumber() {
        number = number + 1
        
//        circleV.setValue(number: number, total: 100)
        if number < 43{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self.updateNumber()
            })
        }
    }
    func updateUIForSportExample(targetNum:String,sportCalories:String) {
        goalVm.updateContent(targetNum: targetNum, sportNum: sportCalories)
        let currentCalories = 0
        let sportCalories = sportCalories.intValue
        let targetCalories = targetNum.intValue
        circleV.setValueSport(number: Double(currentCalories), sport: Double(sportCalories), total: Double(targetCalories + sportCalories))
        
        if currentCalories <= targetCalories + sportCalories{
            circleVm.numberLabel.text = "\(targetCalories - currentCalories + sportCalories)"
            circleVm.tipsLabel.text = "剩余摄入 (千卡)"
        }else{
            circleVm.numberLabel.text = "\(currentCalories - targetCalories - sportCalories)"
            circleVm.tipsLabel.text = "超出摄入 (千卡)"
        }
    }
    func updateUI(dict:NSDictionary) {
//        goalVm.numberLabel.text = "\(Int(dict.doubleValueForKey(key: "caloriesden").rounded()))"
        goalVm.updateContent(targetNum: dict.stringValueForKey(key: "caloriesden"), sportNum: dict.stringValueForKey(key: "sportCalories"))
        
        carbonVm.setNumberMsg(num: "\(Int(dict.stringValueForKey(key: "carbohydrate").floatValue.rounded()))",
                              total: "\(Int(dict.stringValueForKey(key: "carbohydrateden").floatValue.rounded()))")
        proteinVm.setNumberMsg(num: "\(Int(dict.stringValueForKey(key: "protein").floatValue.rounded()))",
                              total: "\(Int(dict.stringValueForKey(key: "proteinden").floatValue.rounded()))")
        fatVm.setNumberMsg(num: "\(Int(dict.stringValueForKey(key: "fat").floatValue.rounded()))",
                              total: "\(Int(dict.stringValueForKey(key: "fatden").floatValue.rounded()))")
        
        let currentCalories = Int(dict.stringValueForKey(key: "calories").floatValue.rounded())
        var sportCalories = Int(dict.stringValueForKey(key: "sportCalories").floatValue.rounded())
        let targetCalories = Int(dict.stringValueForKey(key: "caloriesden").floatValue.rounded())
//        circleV.setValue(number: Double(currentCalories), total: Double(targetCalories))
//        cirlcCoverView.setValue(number: Double(currentCalories), total: Double(targetCalories))
        if UserInfoModel.shared.statSportDataToTarget == "0"{
            sportCalories = 0
        }
        circleV.setValueSport(number: Double(currentCalories), sport: Double(sportCalories), total: Double(targetCalories + sportCalories))
        cirlcCoverView.setValue(number: Double(currentCalories), total: Double(targetCalories + sportCalories))
//        cirlcCoverView.setValueSport(number: Double(currentCalories), sport: Double(sportCalories), total: Double(targetCalories))
        
        
        if currentCalories <= targetCalories + sportCalories{
            circleVm.numberLabel.text = "\(targetCalories - currentCalories + sportCalories)"
            circleVm.tipsLabel.text = "剩余摄入 (千卡)"
        }else{
            circleVm.numberLabel.text = "\(currentCalories - targetCalories - sportCalories)"
            circleVm.tipsLabel.text = "超出摄入 (千卡)"
        }
    }
    func updateLocalData(model:LogsModel) {
        goalVm.numberLabel.text = model.caloriTarget
        
        var carbo = "\(model.carbohydrate)"
        var protein = "\(model.protein)"
        var fat = "\(model.fat)"
        
        carbo = "\(String(format: "%.0f", carbo.floatValue.rounded()))"
        protein = "\(String(format: "%.0f", protein.floatValue.rounded()))"
        fat = "\(String(format: "%.0f", fat.floatValue.rounded()))"
        
        carbonVm.setNumberMsg(num: "\(carbo)",
                              total: "\(String(format: "%.0f", model.carbohydrateTarget.doubleValue.rounded()))")
        proteinVm.setNumberMsg(num: "\(protein)",
                              total: "\(String(format: "%.0f", model.proteinTarget.doubleValue.rounded()))")
        fatVm.setNumberMsg(num: "\(fat)",
                              total: "\(String(format: "%.0f", model.fatTarget.doubleValue.rounded()))")
//        carbonVm.setNumberMsg(num: "\(carbo)",
//                              total: "\((model.carbohydrateTarget as NSString).intValue)")
//        proteinVm.setNumberMsg(num: "\(protein)",
//                              total: "\((model.proteinTarget as NSString).intValue)")
//        fatVm.setNumberMsg(num: "\(fat)",
//                              total: "\((model.fatTarget as NSString).intValue)")
        let currentCalories = (model.calori as String).floatValue.rounded()
        let targetCalories = (model.caloriTarget as NSString).intValue
        circleV.setValue(number: Double(currentCalories), total: Double(targetCalories))
        cirlcCoverView.setValue(number: Double(currentCalories), total: Double(targetCalories))
        DLLog(message: "test:(本地)\(targetCalories) - \(currentCalories)   ===== \(Float(targetCalories) - currentCalories)")
        if Int(currentCalories) <= targetCalories{
            circleVm.numberLabel.text = "\(targetCalories - Int32(currentCalories))"
            circleVm.tipsLabel.text = "剩余摄入 (千卡)"
        }else{
            circleVm.numberLabel.text = "\(Int32(currentCalories) - targetCalories)"
            circleVm.tipsLabel.text = "超出摄入 (千卡)"
        }
    }
    
    @objc func updateNaturalData() {
        let dict = WidgetUtils().readNaturalData()
        if dict.stringValueForKey(key: "sdate") != Date().nextDay(days: 0){
            return
        }
        goalVm.numberLabel.text = "\(Int(dict.doubleValueForKey(key: "caloriTar").rounded()))"
        
        carbonVm.setNumberMsg(num: "\(Int(dict.doubleValueForKey(key: "carbohydrates").rounded()))",
                              total: "\(Int(dict.doubleValueForKey(key: "carboTar").rounded()))")
        proteinVm.setNumberMsg(num: "\(Int(dict.doubleValueForKey(key: "protein").rounded()))",
                              total: "\(Int(dict.doubleValueForKey(key: "proteinTar").rounded()))")
        fatVm.setNumberMsg(num: "\(Int(dict.doubleValueForKey(key: "fats").rounded()))",
                              total: "\(Int(dict.doubleValueForKey(key: "fatsTar").rounded()))")
        
        let currentCalories = Int(dict.doubleValueForKey(key: "calori"))
        let targetCalories = Int(dict.doubleValueForKey(key: "caloriTar"))
        circleV.setValue(number: Double(currentCalories), total: Double(targetCalories))
        cirlcCoverView.setValue(number: Double(currentCalories), total: Double(targetCalories))
        
        if currentCalories <= targetCalories{
            circleVm.numberLabel.text = "\(targetCalories - currentCalories)"
            circleVm.tipsLabel.text = "剩余摄入 (千卡)"
        }else{
            circleVm.numberLabel.text = "\(currentCalories - targetCalories)"
            circleVm.tipsLabel.text = "超出摄入 (千卡)"
        }
    }
}

extension MainTopMsgVM{
    func initUI() {
        addSubview(whiteView)
        addSubview(circleVm)
        addSubview(circleV)
        addSubview(cirlcCoverView)
//        insertSubview(circleV, aboveSubview: circleVm)
        
//        circleV.setValue(number: 44)
        
        whiteView.addShadow(opacity: 0.05)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(goalVm)
        whiteView.addSubview(carbonVm)
        whiteView.addSubview(proteinVm)
        whiteView.addSubview(fatVm)
        whiteView.addSubview(lineView)
        whiteView.addSubview(planButton)
        
        setConstrait()
        
//        planButton.setImage(UIImage.init(named: "plan_arrow_theme"), for: .normal)
        planButton.setImage(UIImage.init(named: "plan_arrow_gray_whole"), for: .normal)
        planButton.imagePosition(style: .right, spacing: kFitWidth(5))
        
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
        }
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
            make.bottom.equalTo(kFitWidth(-50))
        }
        planButton.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(50))
            make.width.equalToSuperview()
        }
    }
}
