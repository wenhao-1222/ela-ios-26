//
//  PlanShareMealsTitleVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/16.
//

import Foundation
import UIKit

class PlanShareMealsTitleVM: UIView {
    
    let selfHeight = kFitWidth(32)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: frame.size.width, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F5F5F5")
        
        return vi
    }()
}

extension PlanShareMealsTitleVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(36))
            make.centerY.lessThanOrEqualToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
            make.width.equalTo(kFitWidth(248))
        }
    }
}


