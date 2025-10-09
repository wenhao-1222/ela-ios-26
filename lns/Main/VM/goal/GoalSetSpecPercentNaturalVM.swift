//
//  GoalSetSpecPercentNaturalVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/31.
//

import Foundation
import UIKit

class GoalSetSpecPercentNaturalVM: UIView {
    
    let selfHeight = kFitWidth(50)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(56), height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var carboLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_CARBOHYDRATE
        lab.font = .systemFont(ofSize: 16, weight: .bold)
        lab.text = "碳水"
        
        return lab
    }()
    lazy var carboNumLab: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.text = "0g"
        
        return lab
    }()
    lazy var proteinLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_PROTEIN
        lab.font = .systemFont(ofSize: 16, weight: .bold)
        lab.text = "蛋白质"
        
        return lab
    }()
    lazy var proteinNumLab: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.text = "0g"
        
        return lab
    }()
    lazy var fatLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_FAT
        lab.font = .systemFont(ofSize: 16, weight: .bold)
        lab.text = "脂肪"
        
        return lab
    }()
    lazy var fatNumLab: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.text = "0g"
        
        return lab
    }()
}

extension GoalSetSpecPercentNaturalVM{
    func initUI() {
        addSubview(carboLab)
        addSubview(carboNumLab)
        addSubview(proteinLab)
        addSubview(proteinNumLab)
        addSubview(fatLab)
        addSubview(fatNumLab)
        
        setConstrait()
    }
    func setConstrait() {
        proteinLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(8))
        }
        proteinNumLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(32))
        }
        
        if isIpad(){
            carboLab.snp.makeConstraints { make in
                make.centerX.lessThanOrEqualTo((SCREEN_WIDHT-kFitWidth(56)-kFitWidth(32))*0.23)
                make.centerY.lessThanOrEqualTo(proteinLab)
            }
        }else{
            carboLab.snp.makeConstraints { make in
                make.centerX.lessThanOrEqualTo(kFitWidth(66))
                make.centerY.lessThanOrEqualTo(proteinLab)
            }
        }
        carboNumLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(carboLab)
            make.centerY.lessThanOrEqualTo(proteinNumLab)
        }
        if isIpad(){
            fatLab.snp.makeConstraints { make in
                make.centerX.lessThanOrEqualTo((SCREEN_WIDHT-kFitWidth(56)-kFitWidth(32))*0.82)
                make.centerY.lessThanOrEqualTo(proteinLab)
            }
        }else{
            fatLab.snp.makeConstraints { make in
                make.centerX.lessThanOrEqualTo(kFitWidth(254))
                make.centerY.lessThanOrEqualTo(proteinLab)
            }
        }
        
        fatNumLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(fatLab)
            make.centerY.lessThanOrEqualTo(proteinNumLab)
        }
    }
    func updateConstraitForAlert() {
        proteinLab.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(8))
        }
        proteinNumLab.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(32))
        }
        if isIpad(){
            carboLab.snp.remakeConstraints { make in
                make.centerX.lessThanOrEqualTo(SCREEN_WIDHT*0.2)
                make.centerY.lessThanOrEqualTo(proteinLab)
            }
        }else{
            carboLab.snp.remakeConstraints { make in
                make.centerX.lessThanOrEqualTo(kFitWidth(78))
                make.centerY.lessThanOrEqualTo(proteinLab)
            }
        }
        
        carboNumLab.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualTo(carboLab)
            make.centerY.lessThanOrEqualTo(proteinNumLab)
        }
        
        if isIpad(){
            fatLab.snp.remakeConstraints { make in
                make.centerX.lessThanOrEqualTo(SCREEN_WIDHT*0.8)
                make.centerY.lessThanOrEqualTo(proteinLab)
            }
        }else{
            fatLab.snp.remakeConstraints { make in
                make.centerX.lessThanOrEqualTo(kFitWidth(308))
                make.centerY.lessThanOrEqualTo(proteinLab)
            }
        }
        fatNumLab.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualTo(fatLab)
            make.centerY.lessThanOrEqualTo(proteinNumLab)
        }
    }
}

