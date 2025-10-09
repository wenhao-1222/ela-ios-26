//
//  GoalSetCircleVM.swift
//  lns
//
//  Created by Elavatine on 2024/10/7.
//

import Foundation
import UIKit

class GoalSetCircleVM: UIView {
    
    var selfHeight = kFitWidth(440) + kFitWidth(56)
    var controller = WHBaseViewVC()
    
    var currentIndex = 0
    var daysNumber = 4
    var goalsDataArray = NSMutableArray()
    
    var carNumber = 0
    var proteinNumber = 0
    var fatNumber = 0
    var caloriesNumber = 0
    
    var changeItemBlock:((NSDictionary)->())?
    var changeCircleTypeBlock:(()->())?
    var dataChangeBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgWhiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(200)))
        vi.isUserInteractionEnabled = true
        
        vi.backgroundColor = .white
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "创建自己的目标"
        lab.font = .systemFont(ofSize: 16, weight: .bold)
        lab.textColor = .COLOR_GRAY_BLACK_85
        
        return lab
    }()
    
    lazy var tipsLab: UILabel = {
        let lab = UILabel()
        lab.text = "选择日期并调整数值"
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
//        lab.isHidden = true
        
        return lab
    }()
    lazy var changeTypeButton: GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT*0.5, height: selfHeight-WHUtils().getBottomSafeAreaHeight()))
        btn.setTitle("按周设定碳循环", for: .normal)
        btn.setImage(UIImage.init(named: "circle_change_icon"), for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        btn.backgroundColor = .clear
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(changeCircleTypeAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var circleDaysVm: GoalSetCircleDaysVM = {
        let vm = GoalSetCircleDaysVM.init(frame: CGRect.init(x: 0, y: kFitWidth(68), width: 0, height: 0))
        vm.daysChangeBlock = {(daysNum)in
            self.daysNumber = daysNum
            self.weeksSegmentVm.updateCircleDays(daysNumber: self.daysNumber)
            self.currentIndex = 0
            self.updateWeeksDayData()
            
            if self.daysNumber == 3{
                self.templateVm.isHidden = false
                self.templateAlertVm.updateContent(circleType: "1")
                self.updateUI(hasTemplate: true)
            }else if  self.daysNumber == 4{
                self.templateVm.isHidden = false
                self.templateAlertVm.updateContent(circleType: "2")
                self.updateUI(hasTemplate: true)
            }else {
                self.templateVm.isHidden = true
                self.updateUI(hasTemplate: false)
            }
        }
        return vm
    }()
    
    lazy var weeksSegmentVm : GoalSetCircleSegmentVM = {
        let vm = GoalSetCircleSegmentVM.init(frame: CGRect.init(x: 0, y: self.circleDaysVm.frame.maxY + kFitWidth(8), width: 0, height: 0))
        vm.delegate = self
        
        return vm
    }()
    lazy var tipsVm: GoalSetTipsVM = {
        let vm = GoalSetTipsVM.init(frame: CGRect.init(x: 0, y: kFitWidth(186), width: 0, height: 0))
        return vm
    }()
    lazy var carboItemVm: GoalSetWeeksNaturalItemVM = {
        let vm = GoalSetWeeksNaturalItemVM.init(frame: CGRect.init(x: 0, y: self.tipsVm.frame.maxY, width: 0, height: 0))
        vm.titleLab.text = "碳水化合物"
//        vm.percentLab.text = "50%"
//        vm.numberLabel.text = "345g"
        return vm
    }()
    lazy var proteinItemVm: GoalSetWeeksNaturalItemVM = {
        let vm = GoalSetWeeksNaturalItemVM.init(frame: CGRect.init(x: 0, y: self.carboItemVm.frame.maxY, width: 0, height: 0))
        vm.titleLab.text = "蛋白质"
//        vm.percentLab.text = "30%"
//        vm.numberLabel.text = "35g"
        return vm
    }()
    lazy var fatItemVm: GoalSetWeeksNaturalItemVM = {
        let vm = GoalSetWeeksNaturalItemVM.init(frame: CGRect.init(x: 0, y: self.proteinItemVm.frame.maxY, width: 0, height: 0))
        vm.titleLab.text = "脂肪"
//        vm.percentLab.text = "20%"
//        vm.numberLabel.text = "4512g"
        return vm
    }()
    lazy var templateVm: GoalSetCircleTemplateVM = {
        let vm = GoalSetCircleTemplateVM.init(frame: CGRect.init(x: 0, y: self.fatItemVm.frame.maxY, width: 0, height: 0))
        vm.isHidden = true
        vm.tapBlock = {()in
            self.templateAlertVm.showSelf()
        }
        return vm
    }()
    lazy var templateAlertVm: GoalSetCircleTemplateAlertVM = {
        let vm = GoalSetCircleTemplateAlertVM.init(frame: .zero)
        vm.confirmBlock = {(type)in
            self.updateDataForTemplate(type: type)
        }
        return vm
    }()
}

extension GoalSetCircleVM{
    func initUI() {
        addSubview(bgWhiteView)
        addSubview(titleLab)
        addSubview(tipsLab)
        addSubview(circleDaysVm)
        addSubview(changeTypeButton)
        addSubview(weeksSegmentVm)
        addSubview(tipsVm)
        addSubview(carboItemVm)
        addSubview(proteinItemVm)
        addSubview(fatItemVm)
        addSubview(templateVm)
        
        setConstrait()
        
        circleDaysVm.updateDaysNumber(daysNumber: self.daysNumber)
        changeTypeButton.imagePosition(style: .right, spacing: kFitWidth(3))
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getKeyWindow().addSubview(templateAlertVm)
        
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(24))
        }
        tipsLab.snp.makeConstraints { make in
            make.left.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(8))
        }
        changeTypeButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(titleLab.snp.bottom)
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(24))
        }
        
    }
    func updateUI(hasTemplate:Bool) {
//        if hasTemplate {
//            selfHeight = self.templateVm.frame.maxY//kFitWidth(410) + kFitWidth(56)
//        }else{
//            selfHeight = kFitWidth(410) //+ kFitWidth(56)
//        }
//        let selfFrame = self.frame
//        self.frame = CGRect.init(x: 0, y: selfFrame.origin.y, width: SCREEN_WIDHT, height: selfFrame.size.height)
    }
}

extension GoalSetCircleVM:GoalSetCircleSegmentVMDelegate{
    func segment(didSelectItemAt index: Int) {
        currentIndex = index
        updateWeeksDayData()
    }
    func updateWeeksDayData() {
        if goalsDataArray.count > currentIndex{
            let dict = goalsDataArray[currentIndex]as? NSDictionary ?? [:]
            
            caloriesNumber = Int(dict.doubleValueForKey(key: "calories"))
            carNumber = Int(dict.doubleValueForKey(key: "carbohydrates"))
            proteinNumber = Int(dict.doubleValueForKey(key: "proteins"))
            fatNumber = Int(dict.doubleValueForKey(key: "fats"))
            
            tipsVm.totalPercentLabel.text = "\(caloriesNumber)"//dict.stringValueForKey(key: "calories")
            carboItemVm.numberLabel.text = "\(carNumber)"//"\(dict.stringValueForKey(key: "carbohydrates"))g"
            proteinItemVm.numberLabel.text = "\(proteinNumber)"//"\(dict.stringValueForKey(key: "proteins"))g"
            fatItemVm.numberLabel.text = "\(fatNumber)"//"\(dict.stringValueForKey(key: "fats"))g"
            
            calculatePercentNumber()
            
            if self.changeItemBlock != nil{
                self.changeItemBlock!(dict)
            }
        }
    }
    func updateDaysNumber(dayNumber:Int)  {
        self.daysNumber = dayNumber
        self.weeksSegmentVm.updateCircleDays(daysNumber: self.daysNumber)
        self.circleDaysVm.updateDaysNumber(daysNumber: self.daysNumber)
    }
    func updateDataForTemplate(type:String) {
        DLLog(message: "updateDataForTemplate:\(self.goalsDataArray)")
        if type == "1"{
            updateCircleTemplateData(carboPercent: [45,30,20])
        }else{
            updateCircleTemplateData(carboPercent: [20,20,20,55])
        }
        if self.dataChangeBlock != nil{
            self.dataChangeBlock!()
        }
    }
    func updateCircleTemplateData(carboPercent:[Int]) {
        for i in 0..<self.goalsDataArray.count{
            if i < carboPercent.count{
                let dict = NSMutableDictionary(dictionary: self.goalsDataArray[i]as? NSDictionary ?? [:])
                
                let calories = Float(dict.doubleValueForKey(key: "calories"))
                let carboPer = carboPercent[i]
                var proteinPer = (100 - carboPer)/2
                var fatPer = (100 - carboPer)/2
                
                if i == 3 {//低低低高，第四天的比例为  55   25   20
                    proteinPer = 25
                    fatPer = 20
                }else if i == 0 && carboPer == 45{//高中低    第一天的比例为 45  30  25
                    proteinPer = 30
                    fatPer = 25
                }
                
                let carboNum = (calories * Float(carboPer) * 0.01)/4
                let proteinNUm = (calories * Float(proteinPer) * 0.01)/4
                let fatNum = (calories * Float(fatPer) * 0.01)/9
                
                dict.setValue("\(Int(carboNum.rounded()))", forKey: "carbohydrates")
                dict.setValue("\(Int(proteinNUm.rounded()))", forKey: "proteins")
                dict.setValue("\(Int(fatNum.rounded()))", forKey: "fats")
                
                self.goalsDataArray.replaceObject(at: i, with: dict)
            }
        }
        self.updateWeeksDayData()
    }
    func calculatePercentNumber() {
        let carboPercent = (Float(carNumber * 4) / Float(caloriesNumber)) * 100.0
        let proteinPercent = (Float(proteinNumber * 4) / Float(caloriesNumber)) * 100.0
//        let fatPercent = (Float(fatNumber * 9) / Float(caloriesNumber)) * 100.0
        let fatPercent = 100 - Int(carboPercent.rounded()) - Int(proteinPercent.rounded())
        carboItemVm.percentLab.text = "\(Int(carboPercent.rounded()))%"
        proteinItemVm.percentLab.text = "\(Int(proteinPercent.rounded()))%"
        fatItemVm.percentLab.text = "\(fatPercent)%"
    }
    @objc func changeCircleTypeAction() {
        if self.changeCircleTypeBlock != nil{
            self.changeCircleTypeBlock!()
        }
    }
}
