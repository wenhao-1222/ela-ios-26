//
//  PlanCreateGoalNaturalVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/15.
//

import Foundation
import UIKit


class PlanCreateGoalNaturalVM: UIView {
    
    let selfHeight = kFitWidth(80)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "营养目标"
        lab.textAlignment = .center
        lab.backgroundColor = .white
        
        return lab
    }()
    lazy var leftLineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    lazy var caloriTotalLabel : UICountingLabel = {
        let lab = UICountingLabel()
        lab.text = "0"
        lab.format = "%d"
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var caloriTipsLabel : UILabel = {
        let lab = UILabel()
        lab.text = "热量 (千卡)"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    //碳水
    lazy var carboNumberLabel : UICountingLabel = {
        let lab = UICountingLabel()
        lab.text = "0"
        lab.format = "%.1f"
        lab.textAlignment = .center
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var carboNumberLab : UILabel = {
        let lab = UILabel()
        lab.text = "碳水（克）"
        lab.textAlignment = .center
//        lab.backgroundColor = WHColorWithAlpha(colorStr: "7137BF", alpha: 0.15)
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    //蛋白质
    lazy var proteinNumberLabel : UICountingLabel = {
        let lab = UICountingLabel()
        lab.text = "0"
        lab.format = "%.1f"
        lab.textAlignment = .center
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var proteinNumberLab : UILabel = {
        let lab = UILabel()
        lab.text = "蛋白质（克）"
        lab.textAlignment = .center
//        lab.backgroundColor = WHColorWithAlpha(colorStr: "F5BA18", alpha: 0.15)
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    //脂肪
    lazy var fatNumberLabel : UICountingLabel = {
        let lab = UICountingLabel()
        lab.text = "0"
        lab.format = "%.1f"
        lab.textAlignment = .center
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var fatNumberLab : UILabel = {
        let lab = UILabel()
        lab.text = "脂肪（克）"
        lab.textAlignment = .center
//        lab.backgroundColor = WHColorWithAlpha(colorStr: "E37318", alpha: 0.15)
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    
}

extension PlanCreateGoalNaturalVM{
    func refreshUI() {
        
    }
}

extension PlanCreateGoalNaturalVM{
    func initUI() {
        addSubview(leftLineView)
        addSubview(titleLabel)
        addSubview(caloriTotalLabel)
        addSubview(caloriTipsLabel)
        addSubview(carboNumberLabel)
        addSubview(carboNumberLab)
        addSubview(fatNumberLabel)
        addSubview(fatNumberLab)
        addSubview(proteinNumberLabel)
        addSubview(proteinNumberLab)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(64))
            make.height.equalTo(kFitWidth(16))
        }
        leftLineView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(titleLabel)
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(0.5))
        }
        caloriTotalLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(28))
            make.width.equalTo(kFitWidth(60))
            make.centerX.lessThanOrEqualTo(SCREEN_WIDHT*0.5*0.25)
        }
        caloriTipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(caloriTotalLabel)
            make.top.equalTo(caloriTotalLabel.snp.bottom).offset(kFitWidth(4))
        }
        carboNumberLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(112))
            make.centerX.lessThanOrEqualTo(SCREEN_WIDHT*0.5*0.75)
            make.width.equalTo(caloriTotalLabel)
            make.centerY.lessThanOrEqualTo(caloriTotalLabel)
        }
        carboNumberLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(carboNumberLabel)
            make.centerY.lessThanOrEqualTo(caloriTipsLabel)
        }
        proteinNumberLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(202))
            make.centerX.lessThanOrEqualTo(SCREEN_WIDHT*0.5*0.25+SCREEN_WIDHT*0.5)
            make.width.equalTo(caloriTotalLabel)
            make.centerY.lessThanOrEqualTo(caloriTotalLabel)
        }
        proteinNumberLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(proteinNumberLabel)
            make.centerY.lessThanOrEqualTo(caloriTipsLabel)
        }
        fatNumberLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(299))
            make.centerX.lessThanOrEqualTo(SCREEN_WIDHT*0.5*0.75+SCREEN_WIDHT*0.5)
            make.width.equalTo(caloriTotalLabel)
            make.centerY.lessThanOrEqualTo(caloriTotalLabel)
        }
        fatNumberLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(fatNumberLabel)
            make.centerY.lessThanOrEqualTo(caloriTipsLabel)
        }
    }
}
