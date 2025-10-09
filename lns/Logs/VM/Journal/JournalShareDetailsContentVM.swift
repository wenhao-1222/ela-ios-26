//
//  JournalShareDetailsContentVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/10.
//

import Foundation
import UIKit

class JournalShareDetailsContentVM: UIView {
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(8)
//        self.clipsToBounds = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var timeImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "logs_share_time_icon")
//        img.isHidden = true
        
        return img
    }()
    lazy var daysLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColor_16(colorStr: "999999")
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var goalLab: UILabel = {
        let lab = UILabel()
        lab.text = "目标"
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = WHColor_16(colorStr: "999999")
        
        return lab
    }()
    lazy var goalNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
//        lab.font = .systemFont(ofSize: 15, weight: .medium)
        lab.font = UIFont().DDInFontMedium(fontSize: 15)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .right
//        lab.text = "1283"
        return lab
    }()
    lazy var eatLab: UILabel = {
        let lab = UILabel()
        lab.text = "已摄入"
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = WHColor_16(colorStr: "999999")
        
        return lab
    }()
    lazy var eatNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = UIFont().DDInFontMedium(fontSize: 15)
        return lab
    }()
//    lazy var sportLab: UILabel = {
//        let lab = UILabel()
//        lab.text = "运动消耗"
//        lab.font = .systemFont(ofSize: 12, weight: .regular)
//        lab.textColor = WHColor_16(colorStr: "999999")
//        
//        return lab
//    }()
//    lazy var sportNumLabel: UILabel = {
//        let lab = UILabel()
//        lab.textColor = .COLOR_SPORT
//        lab.font = UIFont().DDInFontMedium(fontSize: 15)
//
//        return lab
//    }()
    lazy var caloriBgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(4)
        img.clipsToBounds = true
        img.backgroundColor = .THEME
        img.isHidden = true
        
        return img
    }()
    
    lazy var caloriIconView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "plan_get_alert_calori_icon")
        img.isHidden = true
        return img
    }()
    lazy var caloriNumberLabel : UILabel = {
        let lab = UILabel()
        lab.font = UIFont().DDInFontMedium(fontSize: 24)
        lab.textColor = .white
        lab.isHidden = true
        lab.textAlignment = .center
        lab.text = "-"
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var unitLabel : UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 8, weight: .regular)
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.65)
        lab.text = "千卡\n营养目标"
//        lab.textAlignment = .right
        lab.isHidden = true
        lab.adjustsFontSizeToFitWidth = true
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var circleVm : MainCircleVM = {
        let vm = MainCircleVM.init(frame: CGRect.init(x: kFitWidth(120), y: 0, width: 0, height: 0))
        vm.frame = CGRect.init(x: self.frame.size.width-kFitWidth(120), y: kFitWidth(-20), width: kFitWidth(120), height: kFitWidth(120))
        vm.setConstraitForLogsShare()
        return vm
    }()
    lazy var circleV : CalCircleView = {
        let v = CalCircleView.init(frame: self.circleVm.frame)
        v.frame = self.circleVm.frame
        v.circelWidth = kFitWidth(7)
        v.lineWidth = kFitWidth(7)
        v.radiusWidth = kFitWidth(-4.1)
        v.radius = self.circleVm.frame.width / 2.0 - kFitWidth(12)
        v.centerX = self.circleVm.frame.width / 2.0
        v.centerY = self.circleVm.frame.height / 2.0
        
        return v
    }()
    lazy var cirlcCoverView : CalFillCircleView = {
        let vi = CalFillCircleView.init(frame: self.circleVm.frame)
        vi.frame = self.circleVm.frame
        vi.circelWidth = kFitWidth(7)
        vi.radiusWidth = kFitWidth(-4.1)
        
        return vi
    }()
    lazy var carbonVm : MainNutrientItemVM = {
        let vm = MainNutrientItemVM.init(frame: CGRect.init(x: kFitWidth(15), y: kFitWidth(110), width: 0, height: 0))
        vm.titleLabel.text = "碳水"
        vm.selfWidth = kFitWidth(80)
        vm.progressColor = .COLOR_CARBOHYDRATE
        vm.setConstraitForLogsShare()
//        vm.setNumberMsg(num: "1000", total: "1200")
        return vm
    }()
    lazy var proteinVm : MainNutrientItemVM = {
        let vm = MainNutrientItemVM.init(frame: CGRect.init(x: kFitWidth(122), y: kFitWidth(110), width: 0, height: 0))
        vm.titleLabel.text = "蛋白质"
        vm.selfWidth = kFitWidth(80)
        vm.progressColor = .COLOR_PROTEIN
        vm.setConstraitForLogsShare()
        vm.frame = CGRect.init(x: kFitWidth(100), y: kFitWidth(110), width: kFitWidth(80), height: kFitWidth(80))
//        vm.setNumberMsg(num: "430", total: "300")
        
        return vm
    }()
    lazy var fatVm : MainNutrientItemVM = {
        let vm = MainNutrientItemVM.init(frame: CGRect.init(x: kFitWidth(230), y: kFitWidth(110), width: 0, height: 0))
        vm.titleLabel.text = "脂肪"
        vm.selfWidth = kFitWidth(80)
        vm.progressColor = .COLOR_FAT
        vm.setConstraitForLogsShare()
        
        vm.frame = CGRect.init(x: kFitWidth(185), y: kFitWidth(110), width: kFitWidth(80), height: kFitWidth(80))
//        vm.setNumberMsg(num: "657", total: "1268")
        return vm
    }()
}

extension JournalShareDetailsContentVM{
    func updateUI()  {
        let currentCalories = 920
        let targetCalories = 1120
        circleV.setValue(number: Double(currentCalories), total: Double(targetCalories))
        cirlcCoverView.setValue(number: Double(currentCalories), total: Double(targetCalories))

        if Int(currentCalories) <= targetCalories{
            circleVm.numberLabel.text = "\(targetCalories - currentCalories)"
            circleVm.tipsLabel.text = "剩余摄入 (千卡)"
        }else{
            circleVm.numberLabel.text = "\(currentCalories - targetCalories)"
            circleVm.tipsLabel.text = "超出摄入 (千卡)"
        }
        
        daysLabel.text = "2024-07-10"
    }
    func refreshUIForLogsNew(dict:NSDictionary) {
        let currentCalories = Int(dict.doubleValueForKey(key: "calories"))
        let targetCalories = Int(dict.doubleValueForKey(key: "caloriesden"))
        var sportCalories = Int(dict.stringValueForKey(key: "sportCalories").floatValue.rounded())
        if UserInfoModel.shared.statSportDataToTarget == "0"{
            sportCalories = 0
        }
//        circleV.setValue(number: Double(currentCalories), total: Double(targetCalories))
        circleV.setValueSport(number: Double(currentCalories), sport: Double(sportCalories), total: Double(targetCalories + sportCalories))
        cirlcCoverView.setValue(number: Double(currentCalories), total: Double(targetCalories + sportCalories))
        
//        goalNumLabel.text = "\(targetCalories)"
        eatNumLabel.text = "\(currentCalories)"
//        sportNumLabel.text = "\(sportCalories)"
        
        if currentCalories <= targetCalories + sportCalories{
            circleVm.numberLabel.text = "\(targetCalories + sportCalories - currentCalories)"
            circleVm.tipsLabel.text = "剩余摄入 (千卡)"
        }else{
            circleVm.numberLabel.text = "\(currentCalories - targetCalories - sportCalories)"
            circleVm.tipsLabel.text = "超出摄入 (千卡)"
        }
        
        if sportCalories > 0 {
            let attr = NSMutableAttributedString(string: "\(targetCalories)")
            let sportAttr = NSMutableAttributedString(string: "+\(sportCalories)")
            sportAttr.yy_color = .COLOR_SPORT
            attr.append(sportAttr)
            goalNumLabel.attributedText = attr
//            sportLab.isHidden = false
//            sportNumLabel.isHidden = false
        }else{
            goalNumLabel.text = "\(targetCalories)"
//            sportLab.isHidden = true
//            sportNumLabel.isHidden = true
        }
        
//        if currentCalories <= targetCalories{
//            circleVm.numberLabel.text = "\(targetCalories - currentCalories)"
//            circleVm.tipsLabel.text = "剩余摄入 (千卡)"
//        }else{
//            circleVm.numberLabel.text = "\(currentCalories - targetCalories)"
//            circleVm.tipsLabel.text = "超出摄入 (千卡)"
//        }
        
        carbonVm.setNumberMsg(num: dict.stringValueForKey(key: "carbohydrate"),
                              total: dict.stringValueForKey(key: "carbohydrateden"))
        proteinVm.setNumberMsg(num: dict.stringValueForKey(key: "protein"),
                              total: dict.stringValueForKey(key: "proteinden"))
        fatVm.setNumberMsg(num: dict.stringValueForKey(key: "fat"),
                              total: dict.stringValueForKey(key: "fatden"))
        daysLabel.text = Date().changeDateFormatter(dateString: dict.stringValueForKey(key: "sdate"), formatter: "yyyy-MM-dd", targetFormatter: "yyyy年MM月dd日")
    }
}

extension JournalShareDetailsContentVM{
    func initUI() {
        addSubview(timeImgView)
        addSubview(daysLabel)
        addSubview(caloriBgView)
        caloriBgView.addSubview(caloriIconView)
        caloriBgView.addSubview(caloriNumberLabel)
        caloriBgView.addSubview(unitLabel)
        
        addSubview(goalLab)
        addSubview(goalNumLabel)
        addSubview(eatLab)
        addSubview(eatNumLabel)
//        addSubview(sportLab)
//        addSubview(sportNumLabel)
        
        addSubview(circleVm)
        addSubview(circleV)
        addSubview(cirlcCoverView)
        
        addSubview(carbonVm)
        addSubview(proteinVm)
        addSubview(fatVm)
        
        setConstrait()
        
        updateUI()
    }
    
    func setConstrait() {
        caloriBgView.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(50))
            make.left.equalTo(kFitWidth(10))
            make.height.equalTo(kFitWidth(28))
            make.width.equalTo(kFitWidth(120))
        }
        caloriIconView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(8))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
        caloriNumberLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(30))
//            make.width.equalTo(kFitWidth(50))
            make.left.right.equalToSuperview()
            make.centerY.lessThanOrEqualToSuperview()
        }
        unitLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriNumberLabel.snp.right).offset(kFitWidth(2))
//            make.right.equalTo(kFitWidth(-10))
            make.centerY.lessThanOrEqualToSuperview()
        }
        timeImgView.snp.makeConstraints { make in
//            make.right.equalTo(daysLabel.snp.left).offset(kFitWidth(-5))
//            make.centerY.lessThanOrEqualTo(daysLabel)
            make.width.height.equalTo(kFitWidth(12))
            make.left.equalTo(kFitWidth(13))
            make.top.equalTo(kFitWidth(11))
        }
//        daysLabel.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualTo(caloriBgView).offset(kFitWidth(20))
//            make.top.equalTo(kFitWidth(26))
//        }
        daysLabel.snp.makeConstraints { make in
            make.left.equalTo(timeImgView.snp.right).offset(kFitWidth(5))
            make.centerY.lessThanOrEqualTo(timeImgView)
        }
        goalLab.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(29))
            make.left.equalTo(daysLabel)
            make.top.equalTo(daysLabel.snp.bottom).offset(kFitWidth(18))
        }
        goalNumLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(90))
            make.left.equalTo(goalLab.snp.right).offset(kFitWidth(6))
            make.right.equalTo(daysLabel)
            make.centerY.lessThanOrEqualTo(goalLab)
        }
        eatLab.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(29))
            make.left.equalTo(goalLab)
            make.top.equalTo(goalLab.snp.bottom).offset(kFitWidth(12))
        }
        eatNumLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(80))
            make.right.equalTo(goalNumLabel)
            make.centerY.lessThanOrEqualTo(eatLab)
        }
//        sportLab.snp.makeConstraints { make in
//            make.left.equalTo(goalLab)
//            make.top.equalTo(eatLab.snp.bottom).offset(kFitWidth(12))
//        }
//        sportNumLabel.snp.makeConstraints { make in
//            make.right.equalTo(goalNumLabel)
//            make.centerY.lessThanOrEqualTo(sportLab)
//        }
    }
}
