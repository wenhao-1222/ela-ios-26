//
//  GoalSetSpecPercentVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/31.
//

import Foundation
import UIKit

class GoalSetSpecPercentVM: UIView {
    
    let selfHeight = kFitWidth(312)
    
    var caloriesNumber = 0
    
    var carNumber = 0
    var proteinNumber = 0
    var fatNumber = 0
    
    var carboPercent = 0
    var proteinPercent = 0
    var fatPercent = 0
    
    var numberChangeBlock:(()->())?
    var dataIsChanged = false
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: kFitWidth(0), y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(56), height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var naturalVm: GoalSetSpecPercentNaturalVM = {
        let vm = GoalSetSpecPercentNaturalVM.init(frame: .zero)
        return vm
    }()
    
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView(frame: CGRect.init(x: kFitWidth(16), y: self.naturalVm.frame.maxY-kFitWidth(5), width: SCREEN_WIDHT-kFitWidth(56)-kFitWidth(32), height: kFitWidth(190)))
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    lazy var percentArray: NSArray = {
        return [0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100]
    }()
    lazy var bottomLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        return vi
    }()
    lazy var tipsOneLabel: UILabel = {
        let lab = UILabel()
        lab.text = "总计 %"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .bold)
        
        return lab
    }()
    lazy var tipsTwoLabel: UILabel = {
        let lab = UILabel()
        lab.text = "营养素必须等于 100%"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        return lab
    }()
    lazy var totalPercentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 14, weight: .bold)
        lab.text = "100%"
        return lab
    }()
}

extension GoalSetSpecPercentVM{
    func updateNum(specGVm:GoalSetSpecGVM) {
        self.carNumber = specGVm.carNumber
        self.proteinNumber = specGVm.proteinNumber
        self.fatNumber = specGVm.fatNumber
        
        updateNaturalNum()
        
        var calori = self.caloriesNumber
        if calori == 0 {
            calori = 1
        }
        
        self.carboPercent = Int((Float(carNumber * 4) / Float(calori)) * 100.0)
        self.proteinPercent = Int((Float(proteinNumber * 4) / Float(calori)) * 100.0)
        self.fatPercent = Int((Float(fatNumber * 9) / Float(calori)) * 100.0)
        
        self.carboPercent = self.judgePercentNumber(percent: self.carboPercent)
        self.proteinPercent = self.judgePercentNumber(percent: self.proteinPercent)
        self.fatPercent = self.judgePercentNumber(percent: self.fatPercent)
        
        scrollPickerRow(percent: carboPercent, component: 0)
        scrollPickerRow(percent: proteinPercent, component: 1)
        scrollPickerRow(percent: fatPercent, component: 2)
        
        updateTotalPercent()
        
        carNumber = Int(((Float(caloriesNumber * carboPercent)*0.01)/Float(4)).rounded())
        proteinNumber = Int(((Float(caloriesNumber * proteinPercent)*0.01)/Float(4)).rounded())
        fatNumber = Int(((Float(caloriesNumber * fatPercent)*0.01)/Float(9)).rounded())
        
        naturalVm.carboNumLab.text = "\(carNumber)g"
        naturalVm.proteinNumLab.text = "\(proteinNumber)g"
        naturalVm.fatNumLab.text = "\(fatNumber)g"
    }
    func updateNumberWithCalories(calories:Int) {
        caloriesNumber = calories
        self.dataIsChanged = true
//        carNumber = Int((CGFloat(caloriesNumber*carboPercent)/4.0).rounded())
//        proteinNumber = Int((CGFloat(caloriesNumber*proteinPercent)/4.0).rounded())
//        fatNumber = Int((CGFloat(caloriesNumber*fatPercent)/9.0).rounded())
        updateNumber()
        updateNaturalNum()
    }
    func updateTotalPercent() {
        let totalPercent = self.carboPercent + self.proteinPercent + self.fatPercent
        
        totalPercentLabel.text = "\(totalPercent)%"
        if totalPercent == 100 {
            totalPercentLabel.textColor = .THEME
        }else if totalPercent > 100 {
            totalPercentLabel.textColor = .systemRed
        }else{
            totalPercentLabel.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        }
    }
    func updateNumber() {
        carNumber = Int(((Float(caloriesNumber * carboPercent)*0.01)/Float(4)).rounded())
        proteinNumber = Int(((Float(caloriesNumber * proteinPercent)*0.01)/Float(4)).rounded())
        fatNumber = Int(((Float(caloriesNumber * fatPercent)*0.01)/Float(9)).rounded())
    }
    func updateNaturalNum() {
        naturalVm.carboNumLab.text = "\(carNumber)g"
        naturalVm.proteinNumLab.text = "\(proteinNumber)g"
        naturalVm.fatNumLab.text = "\(fatNumber)g"
        
        if self.numberChangeBlock != nil{
            self.numberChangeBlock!()
        }
    }
    func judgePercentNumber(percent:Int) -> Int {
        var numOne = percent % 10
        
        if numOne > 7 {
            numOne = 10
        }else if numOne > 2 {
            numOne = 5
        }else{
            numOne = 0
        }
        
        return percent/10*10+numOne
    }
    func scrollPickerRow(percent:Int,component: Int) {
        for i in 0..<percentArray.count{
            let num = percentArray[i]as? Int ?? 0
            if percent == num{
                self.pickerView.selectRow(i, inComponent: component, animated: true)
                return
            }
        }
    }
}
extension GoalSetSpecPercentVM{
    func initUI() {
        addSubview(naturalVm)
        addSubview(pickerView)
        addSubview(bottomLineView)
        addSubview(tipsOneLabel)
        addSubview(tipsTwoLabel)
        addSubview(totalPercentLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bottomLineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(56)-kFitWidth(32))
            make.height.equalTo(kFitWidth(1))
            make.bottom.equalTo(kFitWidth(-68))
        }
        tipsOneLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(bottomLineView.snp.bottom).offset(kFitWidth(11))
        }
        tipsTwoLabel.snp.makeConstraints { make in
            make.left.equalTo(tipsOneLabel)
            make.top.equalTo(tipsOneLabel.snp.bottom).offset(kFitWidth(8))
        }
        totalPercentLabel.snp.makeConstraints { make in
            make.right.equalTo(bottomLineView)
            make.top.equalTo(bottomLineView.snp.bottom).offset(kFitWidth(21))
        }
    }
    func updateConstraitForAlert() {
        let selfFrame = self.frame
        self.frame = CGRect.init(x: 0, y: selfFrame.origin.y, width: SCREEN_WIDHT, height: selfFrame.height)
        
        naturalVm.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(50))
        naturalVm.updateConstraitForAlert()
        pickerView.frame = CGRect.init(x: kFitWidth(16), y: self.naturalVm.frame.maxY-kFitWidth(5), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(190))
//        pickerView.frame = CGRect.init(x: kFitWidth(16), y: self.naturalVm.frame.maxY-kFitWidth(5), width: kFitWidth(343), height: kFitWidth(190))
        bottomLineView.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
//            make.width.equalTo(kFitWidth(343))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(1))
            make.bottom.equalTo(kFitWidth(-68))
        }
        tipsOneLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(bottomLineView.snp.bottom).offset(kFitWidth(11))
        }
        tipsTwoLabel.snp.remakeConstraints { make in
            make.left.equalTo(tipsOneLabel)
            make.top.equalTo(tipsOneLabel.snp.bottom).offset(kFitWidth(8))
        }
        totalPercentLabel.snp.remakeConstraints { make in
            make.right.equalTo(bottomLineView)
            make.top.equalTo(bottomLineView.snp.bottom).offset(kFitWidth(21))
        }
    }
}

extension GoalSetSpecPercentVM:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return percentArray.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kFitWidth(45)
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            self.carboPercent = percentArray[row]as? Int ?? 0
            carNumber = Int(((Float(caloriesNumber * carboPercent)*0.01)/Float(4)).rounded())
        }else if component == 1 {
            self.proteinPercent = percentArray[row]as? Int ?? 0
            proteinNumber = Int(((Float(caloriesNumber * proteinPercent)*0.01)/Float(4)).rounded())
        }else{
            self.fatPercent = percentArray[row]as? Int ?? 0
            fatNumber = Int(((Float(caloriesNumber * fatPercent)*0.01)/Float(9)).rounded())
        }
        updateTotalPercent()
        
        self.dataIsChanged = true
        updateNaturalNum()
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(96), height: kFitWidth(45)))
        lab.font = .systemFont(ofSize: 16, weight: .bold)
        lab.textAlignment = .center
        
        lab.text =  "\(percentArray[row]as? Int ?? 0)%"
        setUpPickerStyleRowStyle(row: row, component: component)
        
        return lab
    }
    func setUpPickerStyleRowStyle(row:Int,component:Int) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let label = self.pickerView.view(forRow: row, forComponent: component) as? UILabel
            if label != nil{
                label?.textColor = .COLOR_GRAY_BLACK_85//.THEME
            }
        })
    }
}
