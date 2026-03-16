//
//  DietPlanCondimentVC.swift
//  lns
//   酱料
//  Created by LNS2 on 2026/3/16.
//


class DietPlanCondimentVC: WHBaseViewVC {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
}

extension DietPlanCondimentVC{
    func initUI() {
        initNavi(titleStr: "酱料")
        view.backgroundColor = .COLOR_BG_F2
        
    }
}
