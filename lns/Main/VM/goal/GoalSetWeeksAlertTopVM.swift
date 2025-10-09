//
//  GoalSetWeeksAlertTopVM.swift
//  lns
//
//  Created by LNS2 on 2024/8/5.
//

import Foundation
import UIKit

class GoalSetWeeksAlertTopVM: UIView {
    
    let selfHeight = kFitWidth(56)
    
    var cancelBlock:(()->())?
    var confirmBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var closeButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var confirmButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "date_fliter_confirm_img"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return btn
    }()
    lazy var typeVm: GoalSetTypeVM = {
        let vm = GoalSetTypeVM.init(frame: CGRect.init(x: kFitWidth(126), y: kFitWidth(12), width: 0, height: 0))
        vm.frame = CGRect.init(x: (SCREEN_WIDHT-kFitWidth(124))*0.5, y: kFitWidth(12), width: kFitWidth(124), height: kFitWidth(32))
        
        return vm
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        return vi
    }()
}

extension GoalSetWeeksAlertTopVM{
    @objc func closeAction() {
        if self.cancelBlock != nil{
            self.cancelBlock!()
        }
    }
    @objc func confirmAction() {
        if self.confirmBlock != nil{
            self.confirmBlock!()
        }
    }
}
extension GoalSetWeeksAlertTopVM{
    func initUI(){
        addSubview(typeVm)
        addSubview(closeButton)
        addSubview(confirmButton)
        addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(55))
            make.height.equalTo(kFitWidth(1))
        }
        closeButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.bottom.equalTo(lineView)
            make.width.equalTo(kFitWidth(56))
        }
        confirmButton.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.bottom.width.equalTo(closeButton)
        }
    }
}
