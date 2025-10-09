//
//  GoalSetTipsVM.swift
//  lns
//
//  Created by LNS2 on 2024/8/1.
//

import Foundation
import UIKit

class GoalSetTipsVM: UIView {
    
    let selfHeight = kFitWidth(61)
    var caloriesTapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var lineView: DottedLineView = {
        let vi = DottedLineView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        return vi
    }()
    lazy var tipsOneLabel: UILabel = {
        let lab = UILabel()
//        lab.text = "总计 %"
        lab.text = "卡路里"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        
        return lab
    }()
    lazy var tipsTwoLabel: UILabel = {
        let lab = UILabel()
//        lab.text = "营养素必须等于 100%"
        lab.text = "按下方的克数值自动计算"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var totalPercentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 20, weight: .medium)
//        lab.text = "100%"
        lab.isUserInteractionEnabled = true
        
        
        return lab
    }()
    lazy var numberTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(caloriesTapAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    lazy var unitLab: UILabel = {
        let lab = UILabel()
        lab.text = "热量（千卡）"
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        return lab
    }()
}

extension GoalSetTipsVM{
    @objc func caloriesTapAction()  {
        self.caloriesTapBlock?()
    }
}

extension GoalSetTipsVM{
    func initUI() {
        addSubview(lineView)
        addSubview(tipsOneLabel)
        addSubview(tipsTwoLabel)
        addSubview(totalPercentLabel)
        addSubview(unitLab)
        addSubview(numberTapView)
        
        setConstrait()
    }
    func setConstrait(){
        lineView.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
//            make.width.equalToSuperview()
            make.left.equalTo(kFitWidth(19))
            make.right.equalTo(kFitWidth(-19))
            make.height.equalTo(kFitWidth(1))
            make.bottom.equalToSuperview()
        }
        tipsOneLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(19))
            make.top.equalTo(kFitWidth(0))
        }
        tipsTwoLabel.snp.makeConstraints { make in
            make.left.equalTo(tipsOneLabel)
            make.top.equalTo(kFitWidth(27))
//            make.top.equalTo(tipsOneLabel.snp.bottom).offset(kFitWidth(8))
        }
        totalPercentLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-19))
//            make.top.equalTo(kFitWidth(21))
            make.top.equalTo(kFitWidth(2))
        }
        unitLab.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-19))
            make.centerY.lessThanOrEqualTo(tipsTwoLabel)
        }
        numberTapView.snp.makeConstraints { make in
            make.top.right.height.equalToSuperview()
            make.left.equalTo(unitLab)
        }
    }
}
