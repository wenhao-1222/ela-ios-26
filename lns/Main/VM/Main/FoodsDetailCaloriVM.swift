//
//  FoodsDetailCaloriVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/23.
//

import Foundation
import UIKit

class FoodsDetailCaloriVM: UIView {
    
    var isFirst = true
    let selfHeight = kFitWidth(193)
    let whiteWidth = SCREEN_WIDHT-kFitWidth(32)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: whiteWidth, height: kFitWidth(193)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: whiteWidth, height: kFitWidth(188)))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "热量来源"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var carboVm: FoodsDetailCaloriItemVM = {
        let vm = FoodsDetailCaloriItemVM.init(frame: CGRect.init(x: kFitWidth(33), y: kFitWidth(54), width: 0, height: 0))
        vm.titleLabel.text = "碳水"
        vm.imgView.setImgLocal(imgName: "foods_calori_type_carbo")
        
        return vm
    }()
    lazy var proteinVm: FoodsDetailCaloriItemVM = {
//        let vm = FoodsDetailCaloriItemVM.init(frame: CGRect.init(x: kFitWidth(141), y: kFitWidth(54), width: 0, height: 0))
        let vm = FoodsDetailCaloriItemVM.init(frame: CGRect.init(x: whiteWidth*0.5-kFitWidth(30), y: kFitWidth(54), width: 0, height: 0))
        vm.titleLabel.text = "蛋白质"
        vm.imgView.setImgLocal(imgName: "foods_calori_type_protein")
        
        return vm
    }()
    lazy var fatsVm: FoodsDetailCaloriItemVM = {
        let vm = FoodsDetailCaloriItemVM.init(frame: CGRect.init(x: whiteWidth-kFitWidth(100), y: kFitWidth(54), width: 0, height: 0))
        vm.titleLabel.text = "脂肪"
        vm.imgView.setImgLocal(imgName: "foods_calori_type_fats")
        
        return vm
    }()
}

extension FoodsDetailCaloriVM{
    func updateUI(dict:NSDictionary) {
        DLLog(message: "\(dict)")
        var carboNumber = Float(0)
        var proteinNumber = Float(0)
        var fatNumber = Float(0)
        if (dict["proteinNumberString"]as? String ?? "").count > 0 {
            carboNumber = ((dict["carboNumberString"]as? String ?? "0")as NSString).floatValue
            proteinNumber = ((dict["proteinNumberString"]as? String ?? "0")as NSString).floatValue
            fatNumber = ((dict["fatNumberString"]as? String ?? "0")as NSString).floatValue
        }else{
            carboNumber = ((dict["carbohydrate"]as? String ?? "\(dict["carbohydrate"]as? Double ?? 0)")as NSString).floatValue
            proteinNumber = ((dict["protein"]as? String ?? "\(dict["protein"]as? Double ?? 0)")as NSString).floatValue
            fatNumber = ((dict["fat"]as? String ?? "\(dict["fat"]as? Double ?? 0)")as NSString).floatValue
        }
        
        carboVm.numberLabel.text = "\(WHUtils.convertStringToString("\(carboNumber)") ?? "0")g"
        proteinVm.numberLabel.text = "\(WHUtils.convertStringToString("\(proteinNumber)") ?? "0")g"
        fatsVm.numberLabel.text = "\(WHUtils.convertStringToString("\(fatNumber)") ?? "0")g"
    }
    func calculatePercent(dict:NSDictionary){
        let carbo = Double(dict["carbohydrate"]as? String ?? "\(dict["carbohydrate"]as? Double ?? 0)") ?? 0
        let fat = Double(dict["fat"]as? String ?? "\(dict["fat"]as? Double ?? 0)") ?? 0
        let protein = Double(dict["protein"]as? String ?? "\(dict["protein"]as? Double ?? 0)") ?? 0
        
        let caloriTotal = (carbo + protein) * 4 + fat * 9
        
        if caloriTotal == 0 {
            carboVm.percentLabel.text = "（0%）"
            proteinVm.percentLabel.text = "（0%）"
            fatsVm.percentLabel.text = "（0%）"
        }else{
            let carboPercent = carbo/caloriTotal * 100 * 4
            let proteinPercent = protein/caloriTotal * 100 * 4
//            let fatsPercent = fat/caloriTotal * 100 * 9
            
            carboVm.percentLabel.text = "（\(String(format: "%.0f", carboPercent))%）"
            proteinVm.percentLabel.text = "（\(String(format: "%.0f", proteinPercent))%）"
    //        fatsVm.percentLabel.text = "（\(String(format: "%.0f", fatsPercent))%）"
            
            let fatPercent = 100 - Double((String(format: "%.0f", carboPercent) as NSString).intValue) - Double((String(format: "%.0f", proteinPercent) as NSString).intValue)
            fatsVm.percentLabel.text = "（\(String(format: "%.0f", fatPercent))%）"
        }
    }
    func updateMealsDetail(dict:NSDictionary) {
        self.calculatePercent(dict: dict)
        
        self.carboVm.numberLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(dict.doubleValueForKey(key: "carbohydrate").rounded())") ?? "0")g"
        self.proteinVm.numberLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(dict.doubleValueForKey(key: "protein").rounded())") ?? "0")g"
        self.fatsVm.numberLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(dict.doubleValueForKey(key: "fat").rounded())") ?? "0")g"
        
    }
    func updateUIFormMeals() {
        let detailDict = ["carbohydrate":"0",
                          "fat":"0",
                          "protein":"0",
                          "calories":"0"] as NSDictionary
        self.calculatePercent(dict: detailDict)
        
        self.carboVm.numberLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(detailDict.doubleValueForKey(key: "carbohydrate").rounded())") ?? "0")g"
        self.proteinVm.numberLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(detailDict.doubleValueForKey(key: "protein").rounded())") ?? "0")g"
        self.fatsVm.numberLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(detailDict.doubleValueForKey(key: "fat").rounded())") ?? "0")g"
        self.carboVm.numberLabel.isHidden = false
        self.proteinVm.numberLabel.isHidden = false
        self.fatsVm.numberLabel.isHidden = false
        
        self.carboVm.numberLabel.textColor = .COLOR_CARBOHYDRATE//.COLOR_GRAY_BLACK_65
        self.proteinVm.numberLabel.textColor = .COLOR_PROTEIN
        self.fatsVm.numberLabel.textColor = .COLOR_FAT
        
        self.carboVm.percentLabel.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        self.proteinVm.percentLabel.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        self.fatsVm.percentLabel.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        
        self.titleLabel.text = ""
        
        self.whiteView.frame = CGRect.init(x: kFitWidth(16), y: 0, width: whiteWidth, height: kFitWidth(134))
        let carboFrame = self.carboVm.frame
        let proteinFrame = self.proteinVm.frame
        let fatsFrame = self.fatsVm.frame
        
        self.carboVm.frame = CGRect.init(x: kFitWidth(33), y: 0, width: carboFrame.width, height: carboFrame.height)
        self.proteinVm.frame = CGRect.init(x: proteinFrame.origin.x, y: 0, width: proteinFrame.width, height: proteinFrame.height)
        self.fatsVm.frame = CGRect.init(x: fatsFrame.origin.x, y: 0, width: fatsFrame.width, height: fatsFrame.height)
        
        self.carboVm.refresConstrait()
        self.proteinVm.refresConstrait()
        self.fatsVm.refresConstrait()
        
        self.whiteView.addShadow(color: .clear,opacity: 0)
        self.whiteView.backgroundColor = .clear
    }
    
}
extension FoodsDetailCaloriVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addShadow()
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(carboVm)
        whiteView.addSubview(proteinVm)
        whiteView.addSubview(fatsVm)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(20))
        }
    }
}
