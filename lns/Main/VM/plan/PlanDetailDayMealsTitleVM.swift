//
//  PlanDetailDayMealsTitleVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/12.
//

import Foundation
import UIKit

class PlanDetailDayMealsTitleVM: UIView {
    
    let selfHeight = kFitWidth(52)
    
    var addBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var addFoodsButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("添加食物", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setImage(UIImage.init(named: "create_plan_add_foods_icon"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        
        return btn
    }()
    
}
extension PlanDetailDayMealsTitleVM{
    @objc func addAction(){
        TouchGenerator.shared.touchGeneratorMedium()
        if self.addBlock != nil{
            self.addBlock!()
        }
    }
}

extension PlanDetailDayMealsTitleVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(addFoodsButton)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
//            make.top.equalTo(kFitWidth(24))
            make.centerY.lessThanOrEqualToSuperview()
        }
        
        addFoodsButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.right.equalTo(kFitWidth(-16))
            make.width.equalTo(kFitWidth(108))
        }
    }
}
