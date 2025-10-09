//
//  PlanDetailTopVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/12.
//

import Foundation
import UIKit

class PlanDetailTopVM: UIView {
    
    let selfHeight = kFitWidth(268)
    
    var displayLink: CADisplayLink?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var circleImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "plan_detail_circle_img")
        
        return img
    }()
    lazy var caloriTotalLabel : UICountingLabel = {
        let lab = UICountingLabel()
        lab.text = "0"
        
        lab.format = "%d"
        lab.font = UIFont().DDInFontMedium(fontSize: 32)
        lab.textColor = .THEME
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var caloriTipsLabel : UILabel = {
        let lab = UILabel()
        lab.text = "食谱热量 (千卡)"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    //碳水
    lazy var carboNumberLabel : UICountingLabel = {
        let lab = UICountingLabel()
        lab.text = "0"
        lab.format = "%.0f"
        lab.textColor = WHColor_16(colorStr: "222222")
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        
        return lab
    }()
    lazy var carboNumberLab : UILabel = {
        let lab = UILabel()
        lab.text = "碳水"
        lab.textAlignment = .center
        lab.backgroundColor = WHColorWithAlpha(colorStr: "7137BF", alpha: 0.15)
        lab.textColor = .COLOR_CARBOHYDRATE
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.layer.cornerRadius = kFitWidth(10)
        lab.clipsToBounds = true
        
        return lab
    }()
    //蛋白质
    lazy var proteinNumberLabel : UICountingLabel = {
        let lab = UICountingLabel()
        lab.text = "0"
        lab.format = "%.0f"
        lab.textColor = WHColor_16(colorStr: "222222")
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        
        return lab
    }()
    lazy var proteinNumberLab : UILabel = {
        let lab = UILabel()
        lab.text = "蛋白质"
        lab.textAlignment = .center
        lab.backgroundColor = WHColorWithAlpha(colorStr: "F5BA18", alpha: 0.15)
        lab.textColor = .COLOR_PROTEIN
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.layer.cornerRadius = kFitWidth(10)
        lab.clipsToBounds = true
        
        return lab
    }()
    //脂肪
    lazy var fatNumberLabel : UICountingLabel = {
        let lab = UICountingLabel()
        lab.text = "0"
        lab.format = "%.0f"
        lab.textColor = WHColor_16(colorStr: "222222")
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        
        return lab
    }()
    lazy var fatNumberLab : UILabel = {
        let lab = UILabel()
        lab.text = "脂肪"
        lab.textAlignment = .center
        lab.backgroundColor = WHColorWithAlpha(colorStr: "E37318", alpha: 0.15)
        lab.textColor = .COLOR_FAT
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.layer.cornerRadius = kFitWidth(10)
        lab.clipsToBounds = true
        
        return lab
    }()
    
}

extension PlanDetailTopVM{
    func updateUI(dict:NSDictionary) {
        
//        var caloriTarget = Float(dict.stringValueForKey(key: "calories")) ?? 0
//        var carboTarget = Float(dict.stringValueForKey(key: "carbohydrate")) ?? 0
//        var proteinTarget = Float(dict.stringValueForKey(key: "protein")) ?? 0
//        var fatTarget = Float(dict.stringValueForKey(key: "fat")) ?? 0
//
//        caloriTarget = (String(format: "%.0f", caloriTarget)).floatValue
//        carboTarget = (String(format: "%.0f", carboTarget)).floatValue
//        proteinTarget = (String(format: "%.0f", proteinTarget)).floatValue
//        fatTarget = (String(format: "%.0f", fatTarget)).floatValue
//
//        caloriTotalLabel.count(from: 0, to: CGFloat(caloriTarget), withDuration: 0.7)
//        carboNumberLabel.count(from: 0, to: CGFloat(carboTarget), withDuration: 0.7)
//        proteinNumberLabel.count(from: 0, to: CGFloat(proteinTarget), withDuration: 0.7)
//        fatNumberLabel.count(from: 0, to: CGFloat(fatTarget), withDuration: 0.7)
        
        caloriTotalLabel.count(from: 0, to: CGFloat(Int(dict.doubleValueForKey(key: "calories").rounded())), withDuration: 0.7)
        carboNumberLabel.count(from: 0, to: CGFloat(Int(dict.doubleValueForKey(key: "carbohydrate").rounded())), withDuration: 0.7)
        proteinNumberLabel.count(from: 0, to: CGFloat(Int(dict.doubleValueForKey(key: "protein").rounded())), withDuration: 0.7)
        fatNumberLabel.count(from: 0, to: CGFloat(Int(dict.doubleValueForKey(key: "fat").rounded())), withDuration: 0.7)
//        proteinNumberLabel.count(from: 0, to: CGFloat(dict["protein"]as? Double ?? 0), withDuration: 0.7)
//        fatNumberLabel.count(from: 0, to: CGFloat(dict["fat"]as? Double ?? 0), withDuration: 0.7)
    }
    func updateNumber(dict:NSDictionary) {
        caloriTotalLabel.text = "\(Int(dict.doubleValueForKey(key: "calories").rounded()))"
        carboNumberLabel.text = "\(Int(dict.doubleValueForKey(key: "carbohydrate").rounded()))"
        proteinNumberLabel.text = "\(Int(dict.doubleValueForKey(key: "protein").rounded()))"
        fatNumberLabel.text = "\(Int(dict.doubleValueForKey(key: "fat").rounded()))"
    }
}

extension PlanDetailTopVM{
    func initUI() {
        addSubview(circleImgView)
        circleImgView.addSubview(caloriTotalLabel)
        circleImgView.addSubview(caloriTipsLabel)
        
        addSubview(carboNumberLab)
        addSubview(carboNumberLabel)
        addSubview(proteinNumberLab)
        addSubview(proteinNumberLabel)
        addSubview(fatNumberLab)
        addSubview(fatNumberLabel)
        
        setConstrait()
    }
    func setConstrait() {
        circleImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(25))
            make.width.height.equalTo(kFitWidth(138))
        }
        caloriTotalLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(43))
            make.width.equalTo(kFitWidth(108))
        }
        caloriTipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(83))
        }
        
        carboNumberLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(50))
            make.top.equalTo(kFitWidth(208))
            make.width.equalTo(kFitWidth(60))
            make.height.equalTo(kFitWidth(20))
        }
        carboNumberLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(carboNumberLab)
            make.bottom.equalTo(carboNumberLab.snp.top).offset(kFitWidth(-4))
        }
        proteinNumberLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.centerY.lessThanOrEqualTo(carboNumberLab)
            make.width.height.equalTo(carboNumberLab)
        }
        proteinNumberLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(proteinNumberLab)
            make.centerY.lessThanOrEqualTo(carboNumberLabel)
        }
        fatNumberLab.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-49))
            make.centerY.lessThanOrEqualTo(carboNumberLab)
            make.width.height.equalTo(carboNumberLab)
        }
        fatNumberLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(fatNumberLab)
            make.centerY.lessThanOrEqualTo(carboNumberLabel)
        }
    }
}
