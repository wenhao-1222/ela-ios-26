//
//  DietPlanCreateNaviVM.swift
//  lns
//
//  Created by LNS2 on 2026/2/24.
//


class DietPlanCreateNaviVM: UIView {
    
    let segmentWidth = (SCREEN_WIDHT - kFitWidth(56) - kFitWidth(24) - kFitWidth(15))/3
    var backTapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: WHUtils().getNavigationBarHeight()))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var backButton: UIButton = {
        let img = UIButton.init(type: .custom)
        img.frame = CGRect.init(x: kFitWidth(12.5), y: statusBarHeight+kFitWidth(5), width: kFitWidth(35), height: kFitWidth(35))
        img.setImage(UIImage(named: "habit_guide_back_icon"), for: .normal)
//        img.setImgLocal(imgName: "habit_guide_back_icon")
        img.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        
        return img
    }()
    lazy var firstStepVm: DietPlanCreateNaviSegmentVM = {
        let vm = DietPlanCreateNaviSegmentVM.init(frame: CGRect.init(x: kFitWidth(56), y: self.backButton.center.y - kFitWidth(1.5), width: segmentWidth, height: 0))
        
        return vm
    }()
    lazy var secondStepVm: DietPlanCreateNaviSegmentVM = {
        let vm = DietPlanCreateNaviSegmentVM.init(frame: CGRect.init(x: firstStepVm.frame.maxX+kFitWidth(12), y: self.firstStepVm.frame.minY, width: segmentWidth, height: 0))
        
        return vm
    }()
    lazy var thirdStepVm: DietPlanCreateNaviSegmentVM = {
        let vm = DietPlanCreateNaviSegmentVM.init(frame: CGRect.init(x: secondStepVm.frame.maxX+kFitWidth(12), y: self.firstStepVm.frame.minY, width: segmentWidth, height: 0))
        
        return vm
    }()
}

extension DietPlanCreateNaviVM{
    @objc func backAction() {
        self.backTapBlock?()
    }
}

extension DietPlanCreateNaviVM{
    func initUI() {
        addSubview(backButton)
        addSubview(firstStepVm)
        addSubview(secondStepVm)
        addSubview(thirdStepVm)
        
        firstStepVm.updateProgress(step: 1, totalStep: 4, animate: false)
        secondStepVm.updateProgress(step: 0, totalStep: 4, animate: false)
        thirdStepVm.updateProgress(step: 0, totalStep: 4, animate: false)
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
//            self.firstStepVm.updateProgress(step: 2, totalStep: 5, animate: false)
//            self.secondStepVm.updateProgress(step: 4, totalStep: 6, animate: true)
//            self.thirdStepVm.updateProgress(step: 2, totalStep: 5, animate: true)
//        })
//        
//        DispatchQueue.main.asyncAfter(deadline: .now()+4, execute: {
//            self.firstStepVm.updateProgress(step: 5, totalStep: 5, animate: true)
//            self.secondStepVm.updateProgress(step: 1, totalStep: 6, animate: true)
//            self.thirdStepVm.updateProgress(step: 4, totalStep: 5, animate: true)
//        })
    }
}
