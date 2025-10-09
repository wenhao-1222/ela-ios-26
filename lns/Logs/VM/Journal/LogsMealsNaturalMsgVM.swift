//
//  LogsMealsNaturalMsgVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/22.
//

import Foundation
import UIKit

class LogsMealsNaturalMsgVM: UIView {
    
    let selfHeight = kFitWidth(85)
    let wihteViewWidth = SCREEN_WIDHT-kFitWidth(20)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(20), height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var caloriLabel : UICountingLabel = {
        let lab = UICountingLabel()
        lab.text = "0"
        lab.format = "%d"
        lab.font = UIFont().DDInFontSemiBold(fontSize: 16)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var caloriCircleView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CALORI
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var caloriLab : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "热量(千卡)"
        
        return lab
    }()
    lazy var carboCircleView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARBOHYDRATE
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var carboLabel : UICountingLabel = {
        let lab = UICountingLabel()
        lab.text = "0"
        lab.format = "%d"
        lab.font = UIFont().DDInFontSemiBold(fontSize: 16)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var carboLab : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "碳水(g)"
        
        return lab
    }()
    lazy var proteinLabel : UICountingLabel = {
        let lab = UICountingLabel()
        lab.text = "0"
        lab.format = "%d"
        lab.font = UIFont().DDInFontSemiBold(fontSize: 16)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var proteinCircleView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_PROTEIN
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var proteinLab : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "蛋白质(g)"
        
        return lab
    }()
    lazy var fatLabel : UICountingLabel = {
        let lab = UICountingLabel()
        lab.text = "0"
        lab.format = "%d"
        lab.font = UIFont().DDInFontSemiBold(fontSize: 16)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var fatCircleView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_FAT
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var fatLab : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "脂肪(g)"
        
        return lab
    }()
    lazy var bottTipsLabel : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .COLOR_BG_WHITE
        lab.text = "食物列表"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var bottomTipsLine : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    lazy var dottedLineView: DottedLineView = {
        let vi = DottedLineView.init(frame: CGRect.init(x: kFitWidth(16), y: selfHeight-kFitWidth(8)-kFitWidth(7.5), width: wihteViewWidth-kFitWidth(32), height: kFitHeight(1)))
        
        return vi
    }()
}

extension LogsMealsNaturalMsgVM{
    func updateUIForCreatePlan() {
        self.bottTipsLabel.isHidden = true
        self.bottomTipsLine.isHidden = true
        
        carboLab.text = "碳水(克)"
        proteinLab.text = "蛋白质(克)"
        fatLab.text = "脂肪(克)"
        
        let selfFrame = self.frame
        self.frame = CGRect.init(x: selfFrame.origin.x, y: selfFrame.origin.y, width: selfFrame.size.width, height: selfFrame.size.height - kFitWidth(28))
        
        caloriLab.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualTo(kFitWidth(46))
            make.top.equalTo(kFitWidth(27))
        }
        caloriLabel.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualTo(caloriLab)
            make.top.equalTo(kFitWidth(3))
        }
        carboLab.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualTo(kFitWidth(142))
            make.centerY.lessThanOrEqualTo(caloriLab)
        }
        carboLabel.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualTo(carboLab)
            make.centerY.lessThanOrEqualTo(caloriLabel)
        }
        proteinLab.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualTo(kFitWidth(232))
            make.centerY.lessThanOrEqualTo(caloriLab)
        }
        proteinLabel.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualTo(proteinLab)
            make.centerY.lessThanOrEqualTo(caloriLabel)
        }
        fatLab.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualTo(kFitWidth(329))
            make.centerY.lessThanOrEqualTo(caloriLab)
        }
        fatLabel.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualTo(fatLab)
            make.centerY.lessThanOrEqualTo(caloriLabel)
        }
    }
}

extension LogsMealsNaturalMsgVM{
    func initUI(){
        addSubview(caloriLab)
        addSubview(caloriLabel)
        addSubview(carboLab)
        addSubview(carboLabel)
        addSubview(proteinLab)
        addSubview(proteinLabel)
        addSubview(fatLab)
        addSubview(fatLabel)
        addSubview(caloriCircleView)
        addSubview(carboCircleView)
        addSubview(proteinCircleView)
        addSubview(fatCircleView)
        
//        addSubview(bottomTipsLine)
        addSubview(dottedLineView)
        addSubview(bottTipsLabel)
        
        setConstrait()
    }
    func setConstrait() {
        let labWidth = (SCREEN_WIDHT-kFitWidth(20) - kFitWidth(18)*2 - kFitWidth(13)*3) * 0.25
        caloriLabel.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualTo(caloriLab)
            make.top.equalTo(kFitWidth(3))
            make.left.equalTo(kFitWidth(18))
            make.width.equalTo(labWidth)
        }
        caloriLab.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualTo(kFitWidth(53))
//            make.centerX.lessThanOrEqualTo(wihteViewWidth*0.5*0.25)
//            make.left.equalTo(kFitWidth(18))
//            make.width.equalTo(labWidth)
            make.centerX.lessThanOrEqualTo(caloriLabel)
            make.top.equalTo(kFitWidth(27))
        }
        caloriCircleView.snp.makeConstraints { make in
            make.right.equalTo(caloriLab.snp.left).offset(kFitWidth(-3))
            make.width.height.equalTo(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(caloriLab)
        }
        carboLabel.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(caloriLabel)
            make.left.equalTo(caloriLabel.snp.right).offset(kFitWidth(13))
            make.width.equalTo(labWidth)
        }
        carboLab.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualTo(kFitWidth(137))
//            make.centerX.lessThanOrEqualTo(wihteViewWidth*0.5*0.75)
            make.centerY.lessThanOrEqualTo(caloriLab)
            make.centerX.lessThanOrEqualTo(carboLabel)
        }
        carboCircleView.snp.makeConstraints { make in
            make.right.equalTo(carboLab.snp.left).offset(kFitWidth(-3))
            make.width.height.equalTo(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(carboLab)
        }
        proteinLabel.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(caloriLabel)
            make.left.equalTo(carboLabel.snp.right).offset(kFitWidth(13))
            make.width.equalTo(labWidth)
        }
        proteinLab.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualTo(kFitWidth(221))
//            make.centerX.lessThanOrEqualTo(wihteViewWidth*0.5*0.25+wihteViewWidth*0.5)
            make.centerY.lessThanOrEqualTo(caloriLab)
            make.centerX.lessThanOrEqualTo(proteinLabel)
        }
        proteinCircleView.snp.makeConstraints { make in
            make.right.equalTo(proteinLab.snp.left).offset(kFitWidth(-3))
            make.width.height.equalTo(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(proteinLab)
        }
        fatLabel.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(caloriLabel)
            make.left.equalTo(proteinLabel.snp.right).offset(kFitWidth(13))
            make.width.equalTo(labWidth)
        }
        fatLab.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualTo(kFitWidth(305))
//            make.centerX.lessThanOrEqualTo(wihteViewWidth*0.5*0.75+wihteViewWidth*0.5)
            make.centerY.lessThanOrEqualTo(caloriLab)
            make.centerX.lessThanOrEqualTo(fatLabel)
        }
        fatCircleView.snp.makeConstraints { make in
            make.right.equalTo(fatLab.snp.left).offset(kFitWidth(-3))
            make.width.height.equalTo(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(fatLab)
        }
        bottTipsLabel.snp.makeConstraints { make in
            make.bottom.equalTo(kFitWidth(-8))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(64))
            make.height.equalTo(kFitWidth(14))
        }
//        bottomTipsLine.snp.makeConstraints { make in
//            make.centerY.lessThanOrEqualTo(bottTipsLabel)
//            make.left.equalTo(kFitWidth(16))
//            make.right.equalTo(kFitWidth(-16))
//            make.height.equalTo(kFitWidth(1))
//        }
    }
}
