//
//  DietPlanCreateSecondVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/16.
//


class DietPlanCreateSecondVC: WHBaseViewVC {
    
    var currentIndex: Int = 0
    private var isDateStepEnabled = false
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.fd_interactivePopDisabled = false
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendDietMsgRequest()
    }
    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
        vm.backTapBlock = {[weak self] in
            guard let self = self else { return }
            if self.currentIndex == 0 {
                self.backTapAction()
                return
            }
        }
        return vm
    }()
    lazy var stepsArray: [Int] = {
        return [5,6,6]
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
    lazy var dateVm: DietPlanCreateDateVM = {
        let vm = DietPlanCreateDateVM.init(frame: .zero)
        vm.nextButtonEnableChangeBlock = { [weak self] isEnabled in
            self?.isDateStepEnabled = isEnabled
            self?.syncNextButtonEnableStatus()
        }
        return vm
    }()
    lazy var weightVm: DietPlanCreateWeightVM = {
        let vm = DietPlanCreateWeightVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "你的最新体重是？"
        vm.weightChangedBlock = { [weak self] weight in
            self?.targetWeightVm.syncWithCurrentWeight(weight)
        }
        return vm
    }()
    lazy var targetWeightVm: DietPlanCreateTargetWeightVM = {
        let vm = DietPlanCreateTargetWeightVM(frame: CGRect(x: SCREEN_WIDHT * 2, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "你的目标体重需要改变吗？"
        return vm
    }()
}

extension DietPlanCreateSecondVC{
    @objc func nextButtonTapAction() {
        goToNextStep()
    }

    func goToNextStep() {
        let maxOffsetX = max(scrollViewBase.contentSize.width - scrollViewBase.bounds.width, 0)
        let isAtLastStep = scrollViewBase.contentOffset.x >= (maxOffsetX - 0.5)
        if isAtLastStep {
            return
        }

        let nextIndex = nextStepIndex(from: currentIndex)
        let targetOffsetX = SCREEN_WIDHT * CGFloat(nextIndex)
        let finalOffsetX = min(targetOffsetX, maxOffsetX)
        currentIndex = Int(round(finalOffsetX / SCREEN_WIDHT))
        scrollViewBase.setContentOffset(CGPoint(x: finalOffsetX, y: 0), animated: true)
        updateNextButtonForCurrentStep(animated: true)
    }

    func updateNextButtonForCurrentStep(animated: Bool) {
        let shouldHideButton = false
        let moveY = kFitWidth(90) + WHUtils().getBottomSafeAreaHeight()
        let targetTransform = shouldHideButton ? CGAffineTransform(translationX: 0, y: moveY) : .identity
        let targetAlpha: CGFloat = shouldHideButton ? 0 : 1
        let applyChange = {
            self.nextButton.transform = targetTransform
            self.nextButton.alpha = targetAlpha
        }
        nextButton.isUserInteractionEnabled = !shouldHideButton
        naviVm.updateStep(steps: self.stepsArray, currentStep: currentIndex)

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
            nextButton.isEnabled = isDateStepEnabled
        default:
            nextButton.isEnabled = true
        }
    }

    func nextStepIndex(from index: Int) -> Int {
        return index + 1
    }
}

extension DietPlanCreateSecondVC{
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(scrollViewBase)
        view.addSubview(naviVm)
        view.addSubview(nextButton)
        
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.isScrollEnabled = false
        
        scrollViewBase.addSubview(dateVm)
        scrollViewBase.addSubview(weightVm)
        scrollViewBase.addSubview(targetWeightVm)
        scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT*3, height: 0)
        
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }

        updateNextButtonForCurrentStep(animated: false)
    }
}

extension DietPlanCreateSecondVC{
    func sendDietMsgRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_get, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendDietMsgRequest:\(dataObj)")
            
        }
    }
}
