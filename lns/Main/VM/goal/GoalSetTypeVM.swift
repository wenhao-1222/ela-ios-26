//
//  GoalSetTypeVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/31.
//

import Foundation
import UIKit

class GoalSetTypeVM: UIView {
    
    let selfHeight = kFitWidth(32)
    
    var type = "g"
    var typeChangeBlock:((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: (SCREEN_WIDHT-kFitWidth(32)-kFitWidth(124))*0.5, y: frame.origin.y, width: kFitWidth(124), height: selfHeight))
        self.backgroundColor = WHColor_16(colorStr: "EFEFEF")
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(8)
        self.clipsToBounds = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var unitGButton : FeedBackTapButton = {
        let btn = FeedBackTapButton()
        btn.generatorWeight = 0.9
        btn.addPressEffect()
        btn.setTitle("克", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.setBackgroundImage(createImageWithColor(color: .clear), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .white), for: .selected)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.45), for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .selected)
        btn.setBackgroundImage(createImageWithColor(color: WHColorWithAlpha(colorStr: "000000", alpha: 0.1)), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(4)
        btn.clipsToBounds = true
        btn.isSelected = true
        btn.addTarget(self, action: #selector(gTapAction), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var unitPerButton : FeedBackTapButton = {
        let btn = FeedBackTapButton()
        btn.generatorWeight = 0.9
        btn.addPressEffect()
        btn.setTitle("%", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.setBackgroundImage(createImageWithColor(color: .clear), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .white), for: .selected)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.45), for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .selected)
        btn.setBackgroundImage(createImageWithColor(color: WHColorWithAlpha(colorStr: "000000", alpha: 0.1)), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(4)
        btn.clipsToBounds = true
        
        btn.addTarget(self, action: #selector(perTapAction), for: .touchUpInside)
        
        return btn
    }()
}

extension GoalSetTypeVM{
    @objc func gTapAction() {
        if self.type == "g"{
            return
        }
        self.type = "g"
        self.unitGButton.isSelected = true
        self.unitPerButton.isSelected = false
        if self.typeChangeBlock != nil{
            self.typeChangeBlock!(self.type)
        }
    }
    @objc func perTapAction() {
        if self.type == "%"{
            return
        }
        self.type = "%"
        self.unitGButton.isSelected = false
        self.unitPerButton.isSelected = true
        if self.typeChangeBlock != nil{
            self.typeChangeBlock!(self.type)
        }
    }
}

extension GoalSetTypeVM{
    func initUI() {
        addSubview(unitGButton)
        addSubview(unitPerButton)
        
        setConstrait()
    }
    func setConstrait() {
        unitGButton.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(2))
            make.bottom.equalTo(kFitWidth(-2))
            make.width.equalTo(kFitWidth(60))
        }
        unitPerButton.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(2))
            make.bottom.right.equalTo(kFitWidth(-2))
            make.width.equalTo(kFitWidth(60))
        }
    }
}
