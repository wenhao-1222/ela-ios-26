//
//  DietPlanCreateVC.swift
//  lns
//  饮食计划生成页面
//  Created by LNS2 on 2026/2/24.
//  


class DietPlanCreateVC: WHBaseViewVC {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
    }
    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
        vm.backTapBlock = {()
            self.backTapAction()
        }
        return vm
    }()
    lazy var goalVm: DietPlanCreateGoalVM = {
        let vm = DietPlanCreateGoalVM.init(frame: .zero)
        return vm
    }()
}

extension DietPlanCreateVC{
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(goalVm)
        view.addSubview(naviVm)
    }
}
