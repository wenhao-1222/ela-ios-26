//
//  CourseTabVC.swift
//  lns
//
//  Created by LNS2 on 2026/7/1.
//

class CourseTabVC: WHBaseViewVC {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    lazy var tutorialListVm: CourseListVM = {
        let vm = CourseListVM.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: 0, height: 0))
        vm.controller = self
        vm.scrollOffBlock = {(offsetY)in
//            self.naviLiquidView.updateAlpha(offsetY: offsetY)
        }
        return vm
    }()
}

extension CourseTabVC{
    func initUI() {
        view.backgroundColor = .COLOR_BG_F5
        self.navigationView.backgroundColor = .clear
        view.addSubview(tutorialListVm)
    }
}
