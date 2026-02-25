//
//  DietPlanCreateVC.swift
//  lns
//  饮食计划生成页面
//  Created by LNS2 on 2026/2/24.
//  


class DietPlanCreateVC: WHBaseViewVC {
    
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
    }
    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
        vm.backTapBlock = {[weak self] in
            guard let self = self else { return }
            if self.currentIndex == 0 {
                self.backTapAction()
                return
            }
            self.currentIndex -= 1
            let targetOffsetX = SCREEN_WIDHT * CGFloat(self.currentIndex)
            self.scrollViewBase.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
            self.updateNextButtonForCurrentStep(animated: true)
        }
        return vm
    }()
    
    lazy var goalVm: DietPlanCreateGoalVM = {
        let vm = DietPlanCreateGoalVM.init(frame: .zero)
        vm.nextButtonEnableChangeBlock = {[weak self] isEnabled in
            self?.nextButton.isEnabled = isEnabled
        }
        return vm
    }()
    lazy var sexVm: DietPlanCreateSexVM = {
        let vm = DietPlanCreateSexVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: 0, height: 0))
        vm.manTapBlock = {[weak self] in
            self?.moveFromSexToNextStep()
        }
        vm.femanTapBlock = {[weak self] in
            self?.moveFromSexToNextStep()
        }
        
        return vm
    }()
    lazy var birthdayVm: DietPlanCreateYearVM = {
        let vm = DietPlanCreateYearVM.init(frame: CGRect.init(x: SCREEN_WIDHT*2, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var nextButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)

        return btn
    }()
}

extension DietPlanCreateVC{
    @objc func nextButtonTapAction() {
        let nextIndex = currentIndex + 1
        let targetOffsetX = SCREEN_WIDHT * CGFloat(nextIndex)
        let maxOffsetX = max(scrollViewBase.contentSize.width - scrollViewBase.bounds.width, 0)
        let finalOffsetX = min(targetOffsetX, maxOffsetX)
        currentIndex = Int(round(finalOffsetX / SCREEN_WIDHT))
        scrollViewBase.setContentOffset(CGPoint(x: finalOffsetX, y: 0), animated: true)
        updateNextButtonForCurrentStep(animated: true)
    }

    func moveFromSexToNextStep() {
        guard currentIndex == 1 else { return }
        let nextIndex = currentIndex + 1
        let targetOffsetX = SCREEN_WIDHT * CGFloat(nextIndex)
        let maxOffsetX = max(scrollViewBase.contentSize.width - scrollViewBase.bounds.width, 0)
        let finalOffsetX = min(targetOffsetX, maxOffsetX)
        currentIndex = Int(round(finalOffsetX / SCREEN_WIDHT))
        scrollViewBase.setContentOffset(CGPoint(x: finalOffsetX, y: 0), animated: true)
        updateNextButtonForCurrentStep(animated: true)
    }

    func updateNextButtonForCurrentStep(animated: Bool) {
        let shouldHideOnSexStep = (currentIndex == 1)
        let moveY = kFitWidth(90) + WHUtils().getBottomSafeAreaHeight()
        let targetTransform = shouldHideOnSexStep ? CGAffineTransform(translationX: 0, y: moveY) : .identity
        let targetAlpha: CGFloat = shouldHideOnSexStep ? 0 : 1
        let applyChange = {
            self.nextButton.transform = targetTransform
            self.nextButton.alpha = targetAlpha
        }
        nextButton.isUserInteractionEnabled = !shouldHideOnSexStep

        if animated {
            UIView.animate(withDuration: 0.25) {
                applyChange()
            }
        } else {
            applyChange()
        }
    }
}
    
extension DietPlanCreateVC{
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(scrollViewBase)
        view.addSubview(naviVm)
        view.addSubview(nextButton)
        
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.backgroundColor = .clear
        
        scrollViewBase.addSubview(goalVm)
        scrollViewBase.addSubview(sexVm)
        scrollViewBase.addSubview(birthdayVm)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            self.birthdayVm.pickerView.selectRow(self.birthdayVm.defaultIndex, inComponent: 0, animated: true)
        })
        
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*3, height: 0)

        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }
        updateNextButtonForCurrentStep(animated: false)
    }
}
