//
//  PlanShareAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/16.
//

import Foundation
import UIKit
import MCToast

class PlanShareAlertVM: UIView {
    
    var controller = WHBaseViewVC()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColor_16(colorStr: "1F2833")
        self.isUserInteractionEnabled = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var closeButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "plan_share_close_icon"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        return btn
    }()
    
}

extension PlanShareAlertVM{
    func initUI() {
        
    }
}
