//
//  CourseVC.swift
//  lns
//
//  Created by LNS2 on 2026/4/15.
//


class CourseVC: WHBaseViewVC {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    lazy var tutorialListVm: CourseListVM = {
        let vm = CourseListVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: 0, height: 0))
        vm.controller = self
        vm.scrollOffBlock = {(offsetY)in
//            self.naviLiquidView.updateAlpha(offsetY: offsetY)
        }
        return vm
    }()
}

extension CourseVC{
    func initUI() {
        initNavi(titleStr: "干货")
        view.addSubview(tutorialListVm)
    }
}
