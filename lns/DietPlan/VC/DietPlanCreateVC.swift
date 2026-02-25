//
//  DietPlanCreateVC.swift
//  lns
//  饮食计划生成页面
//  Created by LNS2 on 2026/2/24.
//  


class DietPlanCreateVC: WHBaseViewVC {
    
    var currentIndex: Int = 0
    private var isGoalStepEnabled = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.fd_interactivePopDisabled = true
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.fd_interactivePopDisabled = false
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
    }
    
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
            self?.isGoalStepEnabled = isEnabled
            self?.syncNextButtonEnableStatus()
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
    lazy var heightVm: DietPlanCreateHeightVM = {
        let vm = DietPlanCreateHeightVM.init(frame: CGRect(x: SCREEN_WIDHT * 3, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var weightVm: DietPlanCreateWeightVM = {
        let vm = DietPlanCreateWeightVM.init(frame: CGRect.init(x: SCREEN_WIDHT*4, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var bodyfatVm: DietPlanCreateBodyfatVM = {
        let vm = DietPlanCreateBodyfatVM.init(frame: CGRect(x: SCREEN_WIDHT * 5, y: 0, width: 0, height: 0))
        vm.selectStateChangeBlock = {[weak self] _ in
            self?.syncNextButtonEnableStatus()
        }
        vm.showTipsBlock = {()in
            self.bodyFatAlertVm.showView()
        }
        return vm
    }()
    
    
    lazy var bodyFatAlertVm : QuestionnaireBodyFatAlertVM = {
        let vm = QuestionnaireBodyFatAlertVM.init(frame: .zero)
        
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
        self.bodyfatVm.updateScrollView()
    }

    func updateNextButtonForCurrentStep(animated: Bool) {
        let shouldHideButton = (currentIndex == 1)
        let moveY = kFitWidth(90) + WHUtils().getBottomSafeAreaHeight()
        let targetTransform = shouldHideButton ? CGAffineTransform(translationX: 0, y: moveY) : .identity
        let targetAlpha: CGFloat = shouldHideButton ? 0 : 1
        let applyChange = {
            self.nextButton.transform = targetTransform
            self.nextButton.alpha = targetAlpha
        }
        nextButton.isUserInteractionEnabled = !shouldHideButton

        if animated {
            UIView.animate(withDuration: 0.25) {
                applyChange()
            }
        } else {
            applyChange()
        }
        syncNextButtonEnableStatus()
    }

    func syncNextButtonEnableStatus() {
        switch currentIndex {
        case 0:
            nextButton.isEnabled = isGoalStepEnabled
        case 1:
            nextButton.isEnabled = false
        case 5:
            nextButton.isEnabled = bodyfatVm.selectIndex >= 0
        default:
            nextButton.isEnabled = true
        }
    }
}
    
extension DietPlanCreateVC{
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(scrollViewBase)
        view.addSubview(naviVm)
        view.addSubview(nextButton)
        
        view.addSubview(bodyFatAlertVm)
        
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.isScrollEnabled = false
        
        scrollViewBase.addSubview(goalVm)
        scrollViewBase.addSubview(sexVm)
        scrollViewBase.addSubview(birthdayVm)
        scrollViewBase.addSubview(heightVm)
        scrollViewBase.addSubview(weightVm)
        scrollViewBase.addSubview(bodyfatVm)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            self.birthdayVm.pickerView.selectRow(self.birthdayVm.defaultIndex, inComponent: 0, animated: true)
        })
        
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*6, height: 0)

        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }
        updateNextButtonForCurrentStep(animated: false)
    }
}
