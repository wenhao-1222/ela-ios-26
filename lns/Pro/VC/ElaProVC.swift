//
//  ElaProVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/3.
//


class ElaProVC: WHBaseViewVC {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initUI()
    }
    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
        vm.firstStepVm.isHidden = true
        vm.secondStepVm.isHidden = true
        vm.thirdStepVm.isHidden = true
        vm.backTapBlock = {() in
            self.backTapAction()
        }
        return vm
    }()
    lazy var progressVm: ElaProProgressVM = {
        let vm = ElaProProgressVM.init(frame: .zero)
        return vm
    }()
    lazy var priceVm: ElaProPriceVM = {
        let vm = ElaProPriceVM.init(frame: .zero)
        return vm
    }()
}

extension ElaProVC{
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
//        view.addSubview(priceVm)
        view.addSubview(progressVm)
        view.addSubview(naviVm)
    }
}
