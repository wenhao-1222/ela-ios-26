//
//  GoalSetWeeksCenterVM.swift
//  lns
//
//  Created by LNS2 on 2024/8/1.
//

import Foundation
import UIKit

class GoalSetWeeksCenterVM: UIView {
    
    let selfHeight = kFitWidth(390)
    var controller = WHBaseViewVC()
    
    var currentIndex = 0
    var goalsDataArray = NSMutableArray()
    
    var carNumber = 0
    var proteinNumber = 0
    var fatNumber = 0
    var caloriesNumber = 0
    
    var changeItemBlock:((NSDictionary)->())?
    var changeCircleTypeBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
        
        return lab
    }()
    lazy var changeTypeButton: GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT*0.5, height: selfHeight-WHUtils().getBottomSafeAreaHeight()))
        btn.setTitle("自定义碳循环周期", for: .normal)
        btn.setImage(UIImage.init(named: "circle_change_icon"), for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        btn.backgroundColor = .clear
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(changeCircleTypeAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var weeksSegmentVm : GoalSetWeeksSegmentVM = {
        let vm = GoalSetWeeksSegmentVM.init(frame: CGRect.init(x: 0, y: kFitWidth(76), width: 0, height: 0))
        vm.delegate = self
        
        return vm
    }()
    lazy var tipsVm: GoalSetTipsVM = {
        let vm = GoalSetTipsVM.init(frame: CGRect.init(x: 0, y: kFitWidth(166), width: 0, height: 0))
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
}

extension GoalSetWeeksCenterVM{
    func initUI() {
        addSubview(titleLab)
        addSubview(tipsLab)
        addSubview(changeTypeButton)
        addSubview(weeksSegmentVm)
        addSubview(tipsVm)
        addSubview(carboItemVm)
        addSubview(proteinItemVm)
        addSubview(fatItemVm)
        
        setConstrait()
        
        changeTypeButton.imagePosition(style: .right, spacing: kFitWidth(3))
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
}

extension GoalSetWeeksCenterVM:GoalSetWeeksSegmentVMDelegate{
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
