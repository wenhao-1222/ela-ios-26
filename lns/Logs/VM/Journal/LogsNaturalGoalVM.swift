//
//  LogsNaturalGoalVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/22.
//

import Foundation
import UIKit

class LogsNaturalGoalVM: UIView {
    
    var selfHeight = kFitWidth(233)
    let whiteViewWidth = SCREEN_WIDHT-kFitWidth(16)
    
    var calcuBlock:(()->())?
    var updateDataBlock:(()->())?
    var addPlanBlock:(()->())?
    var goalTapBlock:(()->())?
    var updateGoalBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// Background view used for fade effect when scrolling
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.alpha = 0
        vi.isUserInteractionEnabled = true
        return vi
    }()
    
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(10), y: kFitWidth(8), width: SCREEN_WIDHT-kFitWidth(20), height: kFitWidth(218)))
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(8)
        
        return vi
    }()
    lazy var titlLab : UILabel = {
        let lab = UILabel()
        lab.text = "营养目标"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        
        return lab
    }()
    lazy var circleTag: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        lab.layer.cornerRadius = kFitWidth(4)
        lab.clipsToBounds = true
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 10, weight: .medium)
        lab.textAlignment = .center
        lab.isHidden = true
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var updateGoalTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear//WHColor_ARC()
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(updateGoalAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var caloriCircleVm : LogsNaturalGoalCircleVM = {
        let vm = LogsNaturalGoalCircleVM.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(62), width: 0, height: 0))
        vm.circleColor = UIColor.COLOR_CALORI
        vm.titleLab.text = "热量(千卡)"
        vm.circleFillColor = WHColor_RGB(r: 28, g: 70, b: 140)
        vm.center = CGPointMake(whiteViewWidth*0.25*0.5, kFitWidth(73)+kFitWidth(38))
        return vm
    }()
    lazy var carboCircleVm : LogsNaturalGoalCircleVM = {
        let vm = LogsNaturalGoalCircleVM.init(frame: CGRect.init(x: kFitWidth(106), y: kFitWidth(62), width: 0, height: 0))
        vm.circleColor = .COLOR_CARBOHYDRATE
        vm.circleFillColor = WHColor_RGB(r: 62, g: 36, b: 101)
        vm.titleLab.text = "碳水(g)"
        vm.center = CGPointMake(whiteViewWidth*0.5*0.75, kFitWidth(73)+kFitWidth(38))
        return vm
    }()
    lazy var proteinCircleVm : LogsNaturalGoalCircleVM = {
        let vm = LogsNaturalGoalCircleVM.init(frame: CGRect.init(x: kFitWidth(196), y: kFitWidth(62), width: 0, height: 0))
        vm.circleColor = .COLOR_PROTEIN
        vm.circleFillColor = WHColor_RGB(r: 135, g: 102, b: 13)
        vm.titleLab.text = "蛋白质(g)"
        vm.center = CGPointMake(whiteViewWidth*0.5*0.25+whiteViewWidth*0.5, kFitWidth(73)+kFitWidth(38))
        return vm
    }()
    lazy var fatCircleVm : LogsNaturalGoalCircleVM = {
        let vm = LogsNaturalGoalCircleVM.init(frame: CGRect.init(x: kFitWidth(286), y: kFitWidth(62), width: 0, height: 0))
        vm.circleColor = .COLOR_FAT
        vm.circleFillColor = WHColor_RGB(r: 116, g: 66, b: 25)
        vm.titleLab.text = "脂肪(g)"
        vm.center = CGPointMake(whiteViewWidth*0.5*0.75+whiteViewWidth*0.5, kFitWidth(73)+kFitWidth(38))
        return vm
    }()
    lazy var createPlanButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("免费获取计划", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.setImage(UIImage(named: "logs_create_plan_icon"), for: .normal)
        btn.imagePosition(style: .left, spacing: kFitWidth(6))
        btn.backgroundColor = .THEME
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(addPlanAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var winnerVm: WinnerStreakVM = {
        let vm = WinnerStreakVM.init(frame: CGRect.init(x: 0, y: kFitWidth(20), width: 0, height: 0))
        vm.tapBlock = {()in
            self.winnerPopView.showSelf()
        }
        vm.updateUI(dict: UserInfoModel.shared.streakDict)
        return vm
    }()
    lazy var winnerPopView: WinnerStreakAlertVM = {
        let vm = WinnerStreakAlertVM.init(frame: CGRect.init(x: 0, y: self.winnerVm.frame.maxY-kFitWidth(5), width: 0, height: 0))
        vm.frame = CGRect.init(x: SCREEN_WIDHT-kFitWidth(16)-kFitWidth(274), y: self.winnerVm.frame.maxY, width: kFitWidth(274), height: kFitWidth(80))
        vm.isHidden = true
        vm.updateUI(dict: UserInfoModel.shared.streakDict)
        return vm
    }()
    lazy var tapView: UIView = {
//        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT-kFitWidth(16), height: kFitWidth(168)))
        let vi = UIView.init(frame: CGRect.init(x: 0, y: kFitWidth(62), width: SCREEN_WIDHT-kFitWidth(16), height: kFitWidth(106)))
        vi.backgroundColor = .clear//WHColor_ARC()//.clear
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(goalSetAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
}
extension LogsNaturalGoalVM{
    
    @objc func updateGoalAction() {
        self.updateGoalBlock?()
    }
    
    @objc func addPlanAction() {
        if self.addPlanBlock != nil{
            self.addPlanBlock!()
        }
    }
    @objc func goalSetAction(){
        if self.goalTapBlock != nil{
            self.goalTapBlock!()
        }
    }
    func refreshHiddenSurveyButton() {
        createPlanButton.isHidden = UserInfoModel.shared.hidden_survery_button_status
        
        selfHeight = UserInfoModel.shared.hidden_survery_button_status ? kFitWidth(180) : kFitWidth(233)
        
        self.frame = CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight)
        self.whiteView.frame = CGRect.init(x: kFitWidth(10), y: kFitWidth(8), width: SCREEN_WIDHT-kFitWidth(20), height: selfHeight-kFitWidth(8))
    }
}

extension LogsNaturalGoalVM{
    func updateUI(dict:NSDictionary,isUpload:Bool? = true) {
        DLLog(message: "刷新营养目标：原始数据\(dict)")
        var caloriTarget = Int(dict["caloriesden"]as? String ?? "0") ?? 0
        var sportNumber = Int(dict.doubleValueForKey(key: "sportCalories").rounded())
        var carboTarget = Float(dict["carbohydrateden"]as? String ?? "0") ?? 0
        var proteinTarget = Float(dict["proteinden"]as? String ?? "0") ?? 0
        var fatTarget = Float(dict["fatden"]as? String ?? "0") ?? 0
        
        if caloriTarget == 0{
            caloriTarget = Int(dict["caloriesden"]as? Int ?? 0)
            carboTarget = Float(dict["carbohydrateden"]as? Double ?? 0)
            proteinTarget = Float(dict["proteinden"]as? Double ?? 0)
            fatTarget = Float(dict["fatden"]as? Double ?? 0)
        }
        if UserInfoModel.shared.statSportDataToTarget == "0" {
            sportNumber = 0
        }
        DispatchQueue.global(qos: .userInitiated).async {
            var caloriTotal = Double(0)
            var carboTotal = Double(0)
            var proteinTotal = Double(0)
            var fatTotal = Double(0)
            
            let mealsArray = dict["foods"]as? NSArray ?? []
            
            for i in 0..<mealsArray.count{
                let mealPerArr = mealsArray[i]as? NSArray ?? []
                for j in 0..<mealPerArr.count{
                    let dictTemp = mealPerArr[j]as? NSDictionary ?? [:]
                    if dictTemp.stringValueForKey(key: "state") == "1"{
                        let calori = dictTemp.doubleValueForKey(key: "calories")
                        let carbohydrate = dictTemp.doubleValueForKey(key: "carbohydrate")
                        let protein = dictTemp.doubleValueForKey(key: "protein")
                        let fat = dictTemp.doubleValueForKey(key: "fat")
                        
                        caloriTotal = caloriTotal + calori
                        carboTotal = carboTotal + carbohydrate
                        proteinTotal = proteinTotal + protein
                        fatTotal = fatTotal + fat
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.caloriCircleVm.totalNumberLabel.text = "/\(caloriTarget+sportNumber)"
                self.carboCircleVm.totalNumberLabel.text = "/\(String(format: "%.0f", carboTarget))g"
                self.proteinCircleVm.totalNumberLabel.text = "/\(String(format: "%.0f", proteinTarget))g"
                self.fatCircleVm.totalNumberLabel.text = "/\(String(format: "%.0f", fatTarget))g"
                
                self.caloriCircleVm.currentNumFloat = caloriTotal
                self.carboCircleVm.currentNumFloat = carboTotal
                self.proteinCircleVm.currentNumFloat = proteinTotal
                self.fatCircleVm.currentNumFloat = fatTotal
                
                caloriTotal = String(format: "%.0f", caloriTotal.rounded()).doubleValue
                carboTotal = String(format: "%.0f", carboTotal.rounded()).doubleValue
                proteinTotal = String(format: "%.0f", proteinTotal.rounded()).doubleValue
                fatTotal = String(format: "%.0f", fatTotal.rounded()).doubleValue
                
                self.caloriCircleVm.currentNumberLabel.textColor = .COLOR_TEXT_TITLE_0f1214
                self.carboCircleVm.currentNumberLabel.textColor = .COLOR_TEXT_TITLE_0f1214
                self.proteinCircleVm.currentNumberLabel.textColor = .COLOR_TEXT_TITLE_0f1214
                self.fatCircleVm.currentNumberLabel.textColor = .COLOR_TEXT_TITLE_0f1214
                
                self.caloriCircleVm.setDataSport(currentNumber: String(format: "%.0f", caloriTotal).intValue, sportNumber: sportNumber, totalNumber: caloriTarget+sportNumber)
                self.carboCircleVm.setData(currentNumber: String(format: "%.0f", carboTotal).intValue, totalNumber: Int(carboTarget.rounded()))
                self.proteinCircleVm.setData(currentNumber: String(format: "%.0f", proteinTotal).intValue, totalNumber: Int(proteinTarget.rounded()))
                self.fatCircleVm.setData(currentNumber: String(format: "%.0f", fatTotal).intValue, totalNumber: Int(fatTarget.rounded()))
                
                self.circleTag.isHidden = true
                self.circleTag.text = ""
                self.updateGoalTapView.isHidden = true
                if dict.stringValueForKey(key: "circleTag").count > 0 {
                    self.circleTag.isHidden = false
                    self.circleTag.text = "\(dict.stringValueForKey(key: "circleTag"))日"
                    self.updateGoalTapView.isHidden = false
                }else if dict.stringValueForKey(key: "carbLabel").count > 0{
                    self.circleTag.isHidden = false
                    self.circleTag.text = "\(dict.stringValueForKey(key: "carbLabel"))日"
                    self.updateGoalTapView.isHidden = false
                }
                
                if UserInfoModel.shared.showRemainCalories{
                    let attr = NSMutableAttributedString(string: "营养目标")
                    let tipAttr = NSMutableAttributedString(string:"（剩余）")
                    tipAttr.yy_font = .systemFont(ofSize: 14, weight: .regular)
                    attr.append(tipAttr)
                    self.titlLab.attributedText = attr
                    caloriTotal = Double(caloriTarget+sportNumber) - caloriTotal
                    carboTotal = Double(carboTarget) - carboTotal
                    proteinTotal = Double(proteinTarget) - proteinTotal
                    fatTotal = Double(fatTarget) - fatTotal
                    
                    if caloriTotal <= -0.5 {
                        self.caloriCircleVm.currentNumberLabel.textColor = WHColor_16(colorStr: "D54941")
                    }else{
                        caloriTotal = abs(caloriTotal)
                    }
                    if carboTotal <= -0.5 {
                        self.carboCircleVm.currentNumberLabel.textColor = WHColor_16(colorStr: "D54941")
                    }else{
                        carboTotal = abs(carboTotal)
                    }
                    if proteinTotal <= -0.5 {
                        self.proteinCircleVm.currentNumberLabel.textColor = WHColor_16(colorStr: "D54941")
                    }else{
                        proteinTotal = abs(proteinTotal)
                    }
                    if fatTotal <= -0.5 {
                        self.fatCircleVm.currentNumberLabel.textColor = WHColor_16(colorStr: "D54941")
                    }else{
                        fatTotal = abs(fatTotal)
                    }
                }else{
                    self.titlLab.text = "营养目标"
                }
                DLLog(message: "刷新营养目标：\(caloriTotal)   ----  \(carboTotal)  ----  \(proteinTotal)  ----  \(fatTotal)")
                
                self.caloriCircleVm.currentNumberLabel.text = "\(WHUtils.convertStringToString(String(format: "%.0f", caloriTotal)) ?? "0")"
                self.carboCircleVm.currentNumberLabel.text = "\(WHUtils.convertStringToString(String(format: "%.0f", carboTotal)) ?? "0")"
                self.proteinCircleVm.currentNumberLabel.text = "\(WHUtils.convertStringToString(String(format: "%.0f", proteinTotal)) ?? "0")"
                self.fatCircleVm.currentNumberLabel.text = "\(WHUtils.convertStringToString(String(format: "%.0f", fatTotal)) ?? "0")"
                
                if isUpload == true{
                    if self.calcuBlock != nil{
                        self.calcuBlock!()
                    }
                }else{
                    if self.updateDataBlock != nil{
                        self.updateDataBlock!()
                    }
                }
            }
        }
    }
}

extension LogsNaturalGoalVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
//        whiteView.addShadow(opacity: 0.08,radius: kFitWidth(8))
        
        whiteView.addSubview(titlLab)
        whiteView.addSubview(circleTag)
        whiteView.addSubview(updateGoalTapView)
        
        whiteView.addSubview(caloriCircleVm)
        whiteView.addSubview(carboCircleVm)
        whiteView.addSubview(proteinCircleVm)
        whiteView.addSubview(fatCircleVm)
        whiteView.addSubview(tapView)
        whiteView.addSubview(winnerVm)
        whiteView.addSubview(winnerPopView)
        
        whiteView.addSubview(createPlanButton)
        
        setConstrait()
        bgView.addShadow(opacity: 0.05)
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titlLab.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.height.equalTo(kFitWidth(25))
        }
        circleTag.snp.makeConstraints { make in
            make.left.equalTo(titlLab.snp.right).offset(kFitWidth(10))
            make.centerY.lessThanOrEqualTo(titlLab)
            make.width.equalTo(kFitWidth(38))
            make.height.equalTo(kFitWidth(16))
        }
        updateGoalTapView.snp.makeConstraints { make in
//            make.left.top.equalToSuperview()
            make.top.equalToSuperview()
            make.left.right.bottom.equalTo(circleTag)
//            make.bottom.equalTo(circleTag)
        }
        createPlanButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(40))
            make.bottom.equalTo(kFitWidth(-12))
        }
    }
}

extension LogsNaturalGoalVM {
    /// Adjust the background transparency according to scroll offset
    func changeBgAlpha(offsetY: CGFloat) {
//        DLLog(message: "changeBgAlpha:\(offsetY)")
        if offsetY > 0 {
            let percent = offsetY/kFitWidth(280)
//            DLLog(message: "changeBgAlpha: percent -- \(percent)")
            bgView.alpha = percent
        } else {
            bgView.alpha = 0
        }
    }
}
