//
//  GoalSetWeeksNaturalItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/8/1.
//

import Foundation
import UIKit

class GoalSetWeeksNaturalItemVM: UIView {
    
    let selfHeight = kFitWidth(56)
    
    var percentBlock:(()->())?
    var numberBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .bold)
        
        return lab
    }()
    lazy var percentLab: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 14, weight: .bold)
        
        return lab
    }()
    lazy var unitLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.text = "g"
        lab.font = .systemFont(ofSize: 14, weight: .bold)
        
        return lab
    }()
    
    lazy var percentTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(percentTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var numberTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(numberTapAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
}

extension GoalSetWeeksNaturalItemVM{
    @objc func percentTapAction() {
        if self.percentBlock != nil{
            self.percentBlock!()
        }
    }
    @objc func numberTapAction() {
        if self.numberBlock != nil{
            self.numberBlock!()
        }
    }
}

extension GoalSetWeeksNaturalItemVM{
    func initUI() {
        addSubview(titleLab)
        addSubview(percentLab)
        addSubview(numberLabel)
        addSubview(unitLabel)
        addSubview(percentTapView)
        addSubview(numberTapView)
        
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        percentLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(96))
            make.centerY.lessThanOrEqualToSuperview()
        }
        unitLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        numberLabel.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-16))
            make.right.equalTo(unitLabel.snp.left)
            make.centerY.lessThanOrEqualToSuperview()
        }
        percentTapView.snp.makeConstraints { make in
            make.left.equalTo(titleLab.snp.right)
            make.top.height.equalToSuperview()
            make.right.equalTo(percentLab.snp.right).offset(kFitWidth(30))
        }
        numberTapView.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(numberLabel.snp.left).offset(kFitWidth(-30))
        }
    }
}
