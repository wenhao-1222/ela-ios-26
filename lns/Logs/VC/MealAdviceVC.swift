//
//  MealAdviceVC.swift
//  lns
//  下餐规划
//  Created by LNS2 on 2026/8/5.
//

import UIKit


class MealAdviceVC: WHBaseViewVC {
    
    private var currentStep = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    lazy var backImg: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "habit_guide_back_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var backTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = WHColor_ARC()
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(backAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    
    lazy var mealsNumVm: MealsNumVM = {
        let vm = MealsNumVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: 0, height: 0))
        vm.nextBlock = { [weak self] in
            self?.showSecondStep()
        }
        
        return vm
    }()
    lazy var secondVm: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: SCREEN_WIDHT, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight()))
        vi.backgroundColor = .COLOR_BG_F2
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    
    @objc func backAction() {
        if currentStep > 0 {
            showMealsNumStep()
        } else {
            self.backTapAction()
        }
    }
    
}

extension MealAdviceVC{
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        
        view.addSubview(mealsNumVm)
        view.addSubview(secondVm)
        view.addSubview(backImg)
        view.addSubview(backTapView)
        
        setConstrait()
    }
    
    func setConstrait() {
        backImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(statusBarHeight+kFitWidth(4))
            make.width.height.equalTo(kFitWidth(35))
        }
        backTapView.snp.makeConstraints { make in
//            make.left.equalToSuperview()
            make.center.lessThanOrEqualTo(backImg)
            make.width.height.equalTo(kFitWidth(48))
        }
    }
    
    func showMealsNumStep() {
        currentStep = 0
        UIView.animate(withDuration: 0.25) {
            self.mealsNumVm.frame = CGRect.init(x: 0, y: self.getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.getNavigationBarHeight())
            self.secondVm.frame = CGRect.init(x: SCREEN_WIDHT, y: self.getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.getNavigationBarHeight())
        }
    }
    
    func showSecondStep() {
        currentStep = 1
        UIView.animate(withDuration: 0.25) {
            self.mealsNumVm.frame = CGRect.init(x: -SCREEN_WIDHT, y: self.getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.getNavigationBarHeight())
            self.secondVm.frame = CGRect.init(x: 0, y: self.getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.getNavigationBarHeight())
        }
    }
}
