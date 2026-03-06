//
//  DietPlanVC.swift
//  lns
//  食谱
//  Created by LNS2 on 2026/3/6.
//


class DietPlanVC: WHBaseViewVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    lazy var emptyVm: PlanMainEmptyVM = {
        let vm = PlanMainEmptyVM.init(frame: .zero)
        vm.startButton.addTarget(self, action: #selector(createDietPlanAction), for: .touchUpInside)
        return vm
    }()
}

extension DietPlanVC{
    @objc func createDietPlanAction() {
        let vc = DietPlanCreateVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension DietPlanVC{
    func initUI() {
        view.addSubview(emptyVm)
        
    }
}
