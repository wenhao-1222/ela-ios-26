//
//  PlanShareDetailsContentVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/16.
//

import Foundation
import UIKit

class PlanShareDetailsContentVM: UIView {
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(8)
        self.clipsToBounds = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var timeImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "plan_get_alert_clock_icon")
        
        return img
    }()
    lazy var daysLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var caloriBgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "plan_get_alert_calori_bg_img")
        return img
    }()
    
    lazy var caloriIconView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "plan_get_alert_calori_icon")
        return img
    }()
    lazy var caloriNumberLabel : UILabel = {
        let lab = UILabel()
        lab.font = UIFont().DDInFontMedium(fontSize: 32)
        lab.textColor = .white
        
        return lab
    }()
    lazy var unitLabel : UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.65)
        lab.text = "千卡\n食谱热量"
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.65)
        lab.text = "食谱热量"
        lab.adjustsFontSizeToFitWidth
        return lab
    }()
    lazy var naturalImgView : UIImageView = {
        let vi = UIImageView()
        vi.setImgLocal(imgName: "plan_get_alert_natural_line")
        
        return vi
    }()
    lazy var carboLabel: UILabel = {
        let lab = UILabel()
        lab.adjustsFontSizeToFitWidth = true
//        lab.text.adju
        return lab
    }()
    lazy var proteinLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var fatLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .right
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
}

extension PlanShareDetailsContentVM{
    func refreshUI(dict:NSDictionary)  {
        daysLabel.text = "计划周期 \(dict["pdays"]as? Int ?? 0) 天"
        caloriNumberLabel.text = "\(dict["calories"]as? Int ?? 0)"
        
//        addAttributString(number: "\(String(format: "%.0f", dict.doubleValueForKey(key: "carbohydrate")))", label: carboLabel, name: "碳水")
//        addAttributString(number: "\(String(format: "%.0f", dict.doubleValueForKey(key: "protein")))", label: proteinLabel, name: "蛋白质")
//        addAttributString(number: "\(String(format: "%.0f", dict.doubleValueForKey(key: "fat")))", label: fatLabel, name: "脂肪")
        
        addAttributString(number: "\(WHUtils.convertStringToStringNoDigit("\(dict.stringValueForKey(key: "carbohydrate"))") ?? "0")", label: carboLabel, name: "碳水")
        addAttributString(number: "\(WHUtils.convertStringToStringNoDigit("\(dict.stringValueForKey(key: "protein"))") ?? "0")", label: proteinLabel, name: "蛋白质")
        addAttributString(number: "\(WHUtils.convertStringToStringNoDigit("\(dict.stringValueForKey(key: "fat"))") ?? "0")", label: fatLabel, name: "脂肪")
        
    }
    func refreshUIForLogs(dict:NSDictionary)  {
        daysLabel.text = "计划周期 \(dict["pdays"]as? Int ?? 0) 天"
        
        caloriNumberLabel.text = dict["calories"]as? String ?? "\(dict["calories"]as? Int ?? 0)"
        if (dict["calories"]as? String ?? "\(dict["calories"]as? Int ?? 0)") == "0" {
            calculateNumber(dict: dict)
        }else{
            addAttributString(number: "\(String(format: "%.0f", dict.doubleValueForKey(key: "carbohydrate")))", label: carboLabel, name: "碳水")
            addAttributString(number: "\(String(format: "%.0f", dict.doubleValueForKey(key: "protein")))", label: proteinLabel, name: "蛋白质")
            addAttributString(number: "\(String(format: "%.0f", dict.doubleValueForKey(key: "fat")))", label: fatLabel, name: "脂肪")
            
//            addAttributString(number: "\(WHUtils.convertStringToStringNoDigit("\(dict["carbohydrate"]as? String ?? "\(dict["carbohydrate"]as? Double ?? 0)")") ?? "0")", label: carboLabel, name: "碳水")
//            addAttributString(number: "\(WHUtils.convertStringToStringNoDigit("\(dict["protein"]as? String ?? "\(dict["protein"]as? Double ?? 0)")") ?? "0")", label: proteinLabel, name: "蛋白质")
//            addAttributString(number: "\(WHUtils.convertStringToStringNoDigit("\(dict["fat"]as? String ?? "\(dict["fat"]as? Double ?? 0)")") ?? "0")", label: fatLabel, name: "脂肪")
        }
    }
    func calculateNumber(dict:NSDictionary) {
        DispatchQueue.global(qos: .userInitiated).async {
            var caloriTotal = Double(0)
            var carboTotal = Double(0)
            var proteinTotal = Double(0)
            var fatTotal = Double(0)
            
            var originY = kFitWidth(147)
            let foodsArray = dict["foods"]as? NSArray ?? []
            for i in 0..<foodsArray.count{
                
                let dict = foodsArray[i]as? NSDictionary ?? [:]
//                DLLog(message: "已选择的食物  --- \(i) : \(dict)")
                if dict["fname"]as? String ?? "" == "快速添加" {
                    let calori = (Double(dict["calories"]as? String ?? "\(dict["calories"]as? Double ?? 0)") ?? 0)
                    let carbohydrate = (Double(dict["carbohydrate"]as? String ?? "\(dict["carbohydrate"]as? Double ?? 0)") ?? 0)
                    let protein = (Double(dict["protein"]as? String ?? "\(dict["protein"]as? Double ?? 0)") ?? 0)
                    let fat = (Double(dict["fat"]as? String ?? "\(dict["fat"]as? Double ?? 0)") ?? 0)
                    
//                    caloriTotal = caloriTotal + calori
                    carboTotal = carboTotal + carbohydrate
                    proteinTotal = proteinTotal + protein
                    fatTotal = fatTotal + fat
                }else if (dict["caloriesNumber"]as? String ?? "").count > 0 {
                    var qty = Double(dict["qty"]as? Double ?? 0)
                    
                    if qty == 0 {
                        qty = Double(dict["qty"]as? String ?? "0") ?? 0
                    }
                    
                    var calori = (Double(dict["caloriesNumber"]as? String ?? "0") ?? 0)
                    var carbohydrate = (Double(dict["carbohydrateNumber"]as? String ?? "0") ?? 0)
                    var protein = (Double(dict["proteinNumber"]as? String ?? "0") ?? 0)
                    var fat = (Double(dict["fatNumber"]as? String ?? "0") ?? 0)
                    
                    if (dict["caloriesNumberPer"]as? String ?? "").count > 0 && (Double(dict["caloriesNumberPer"]as? String ?? "0") ?? 0) * qty > calori{
                        calori = (Double(dict["caloriesNumberPer"]as? String ?? "0") ?? 0) * qty
                        carbohydrate = (Double(dict["carbohydrateNumberPer"]as? String ?? "0") ?? 0) * qty
                        protein = (Double(dict["proteinNumberPer"]as? String ?? "0") ?? 0) * qty
                        fat = (Double(dict["fatNumberPer"]as? String ?? "0") ?? 0) * qty
                    }
                    
                    caloriTotal = caloriTotal + calori
                    carboTotal = carboTotal + carbohydrate
                    proteinTotal = proteinTotal + protein
                    fatTotal = fatTotal + fat
                }else{
                    let calori = dict["calories"]as? Double ?? Double(dict["calories"]as? String ?? "0")
                    let carbohydrate = dict["carbohydrate"]as? Double ?? Double(dict["calories"]as? String ?? "0")
                    let protein = dict["protein"]as? Double ?? Double(dict["calories"]as? String ?? "0")
                    let fat = dict["fat"]as? Double ?? Double(dict["calories"]as? String ?? "0")
                    
                    caloriTotal = caloriTotal + (calori ?? 0)
                    carboTotal = carboTotal + (carbohydrate ?? 0)
                    proteinTotal = proteinTotal + (protein ?? 0)
                    fatTotal = fatTotal + (fat ?? 0)
                }
            }
            DispatchQueue.main.async {
                self.caloriNumberLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(caloriTotal)") ?? "0")"
                self.addAttributString(number: "\(WHUtils.convertStringToStringNoDigit("\(carboTotal)") ?? "0")", label: self.carboLabel, name: "碳水")
                self.addAttributString(number: "\(WHUtils.convertStringToStringNoDigit("\(proteinTotal)") ?? "0")", label: self.proteinLabel, name: "蛋白质")
                self.addAttributString(number: "\(WHUtils.convertStringToStringNoDigit("\(fatTotal)") ?? "0")", label: self.fatLabel, name: "脂肪")
                
            }
        }
    }
    func addAttributString(number:String,label:UILabel,name:String) {
        var numberAttr = NSMutableAttributedString.init(string: number)
        let unitStr = NSMutableAttributedString.init(string: "g")
        let nameStr = NSMutableAttributedString.init(string: name)
        
        numberAttr.yy_font = .systemFont(ofSize: 20, weight: .medium)
        numberAttr.yy_color = WHColor_16(colorStr: "222222")
        
        unitStr.yy_font = .systemFont(ofSize: 12, weight: .medium)
        unitStr.yy_color = WHColor_16(colorStr: "222222")
        
        nameStr.yy_font = .systemFont(ofSize: 12, weight: .regular)
        nameStr.yy_color = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        
        numberAttr.append(unitStr)
        numberAttr.append(nameStr)
        
        label.attributedText = numberAttr
    }
}

extension PlanShareDetailsContentVM{
    func initUI() {
        addSubview(timeImgView)
        addSubview(daysLabel)
        addSubview(caloriBgView)
        caloriBgView.addSubview(caloriIconView)
        caloriBgView.addSubview(caloriNumberLabel)
        caloriBgView.addSubview(unitLabel)
//        caloriBgView.addSubview(tipsLabel)
        
        addSubview(naturalImgView)
        addSubview(carboLabel)
        addSubview(proteinLabel)
        addSubview(fatLabel)
        
        setConstrait()
    }
    func setConstrait() {
        daysLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(114))
            make.top.equalTo(kFitWidth(14))
        }
        timeImgView.snp.makeConstraints { make in
            make.right.equalTo(daysLabel.snp.left).offset(kFitWidth(-5))
            make.centerY.lessThanOrEqualTo(daysLabel)
            make.width.height.equalTo(kFitWidth(16))
        }
        caloriBgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(40))
            make.height.equalTo(kFitWidth(56))
            make.width.equalTo(kFitWidth(240))
        }
        caloriIconView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(49))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
        caloriNumberLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(73))
            make.centerY.lessThanOrEqualToSuperview()
        }
        unitLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriNumberLabel.snp.right).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualToSuperview()
        }
//        tipsLabel.snp.makeConstraints { make in
//            make.left.equalTo(unitLabel)
//            make.top.equalTo(unitLabel.snp.bottom).offset(kFitWidth(4))
//        }
        naturalImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-52))
            make.width.equalTo(kFitWidth(248))
            make.height.equalTo(kFitWidth(2))
        }
        carboLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.width.equalTo(kFitWidth(80))
            make.bottom.equalTo(kFitWidth(-20))
        }
        proteinLabel.snp.makeConstraints { make in
            make.bottom.width.equalTo(carboLabel)
            make.centerX.lessThanOrEqualToSuperview()
        }
        fatLabel.snp.makeConstraints { make in
            make.right.equalTo(naturalImgView)
            make.bottom.width.equalTo(carboLabel)
        }
    }
}
