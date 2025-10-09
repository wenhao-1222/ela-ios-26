//
//  QuestionnaireWeightVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/28.
//

import Foundation
import UIKit

class QuestionnaireWeightVM: UIView {
    
    var selfHeight = kFitWidth(0)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .COLOR_GRAY_FA
        self.isUserInteractionEnabled = true
        self.selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "您的体重是多少？"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        
        return lab
    }()
    lazy var numberIntArray : NSArray = {
        let numberAr = NSMutableArray()
        for i in 30...300{
            numberAr.add(i)
        }
        
        return numberAr
    }()
    lazy var numberDemicalArray : NSArray = {
        let numberAr = NSMutableArray()
        for i in 0...9{
            numberAr.add(i)
        }
        
        return numberAr
    }()
    lazy var pickerView : UIPickerView = {
        let vi = UIPickerView()
        vi.backgroundColor = . clear
        vi.dataSource = self
        vi.delegate = self
        
        return vi
    }()
    lazy var demicalLab : UILabel = {
        let lab = UILabel()
        lab.text = "."
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 28, weight: .medium)
        
        return lab
    }()
    lazy var unitLab : UILabel = {
        let lab = UILabel()
        lab.text = "公斤"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
}
extension QuestionnaireWeightVM{
    func getWeightValue() {
        let index = pickerView.selectedRow(inComponent: 0)
        let indexDecimal = pickerView.selectedRow(inComponent: 1)
        QuestinonaireMsgModel.shared.weight = "\(numberIntArray[index]as? Int ?? 0).\(numberDemicalArray[indexDecimal]as? Int ?? 0)"
        DLLog(message: "体重：\(QuestinonaireMsgModel.shared.weight)")
    }
}

extension QuestionnaireWeightVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(pickerView)
        
        pickerView.addSubview(demicalLab)
        pickerView.addSubview(unitLab)
        
        pickerView.selectRow(40, inComponent: 0, animated: false)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(60))
            make.height.equalTo(kFitWidth(72))
        }
        pickerView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(231))
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(252))
        }
        demicalLab.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(155))
            make.centerX.lessThanOrEqualToSuperview().offset(kFitWidth(3))
            make.centerY.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(30))
        }
        unitLab.snp.makeConstraints { make in
//            make.centerY.lessThanOrEqualToSuperview()
            make.centerX.lessThanOrEqualToSuperview().offset(kFitWidth(48))
//            make.height.equalTo(kFitWidth(30))
            make.bottom.equalTo(demicalLab).offset(kFitWidth(-4))
        }
    }
}

extension QuestionnaireWeightVM:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return numberIntArray.count
        }else {
            return numberDemicalArray.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kFitWidth(45)
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            return kFitWidth(45)
        }else{
            return kFitWidth(45)
        }
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if component == 0 {
            let lab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(80), height: kFitWidth(45)))
            lab.text = "\(self.numberIntArray[row]as? Int ?? 0)"
            lab.font = UIFont().DDInFontMedium(fontSize: 30)
            lab.textAlignment = .center
            setUpPickerStyleRowStyle(row: row, component: component)
            return lab
        }else{
            let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(40), y: 0, width: kFitWidth(38), height: kFitWidth(45)))
            lab.text = "\(self.numberDemicalArray[row]as? Int ?? 0)"
            lab.textAlignment = .center
            lab.adjustsFontSizeToFitWidth = true
            lab.font = UIFont().DDInFontMedium(fontSize: 30)
            setUpPickerStyleRowStyle(row: row, component: component)
            
            return lab
        }
    }
    func setUpPickerStyleRowStyle(row:Int,component:Int) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let label = self.pickerView.view(forRow: row, forComponent: component) as? UILabel
            if label != nil{
                label?.textColor = .THEME
            }
        })
    }
}
