//
//  QuestionnairePlanFoodsTypeAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/1.
//

import Foundation
import UIKit

class QuestionnairePlanFoodsTypeAlertVM: UIView {
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.0)
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var typeVm : QuestionnairePlanFoodsTypeVM = {
        let vm = QuestionnairePlanFoodsTypeVM.init(frame: CGRect.init(x: kFitWidth(88), y:kFitWidth(44), width: 0, height: 0))
        
        return vm
    }()
}

extension QuestionnairePlanFoodsTypeAlertVM{
    @objc func showSelf() {
        self.isHidden = false
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveLinear) {
            self.typeVm.whiteView.alpha = 1
        }
    }
    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveLinear) {
            self.typeVm.whiteView.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
    }
}

extension QuestionnairePlanFoodsTypeAlertVM{
    func initUI() {
        addSubview(typeVm)
        
        let typeVmCenter = typeVm.center
        typeVm.center = CGPointMake(SCREEN_WIDHT*0.5, typeVmCenter.y)
    }
}
