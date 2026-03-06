//
//  ElaProVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/3.
//


class ElaProVC: WHBaseViewVC {
    private var currentIndex: Int = 0
    
    var param = [String : Any]()
    private var agreementAlertVm: ElaProAgreementAlertVM?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.fd_interactivePopDisabled = true
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.fd_interactivePopDisabled = false
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        self.sendDietUpsertRequest()
        
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is DietPlanCreateVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
    }
    
    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
//        vm.alpha = 0
        vm.firstStepVm.isHidden = true
        vm.secondStepVm.isHidden = true
        vm.thirdStepVm.isHidden = true
        vm.backTapBlock = {[weak self] in
            guard let self = self else { return }
//            if self.currentIndex == 0 {
                self.backTapAction()
//            }
//            else {
//                self.currentIndex -= 1
//                self.scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(self.currentIndex), y: 0), animated: true)
//                self.updateNextButtonForCurrentStep(animated: true)
//            }
        }
        return vm
    }()
    
    lazy var progressVm: ElaProProgressVM = {
        let vm = ElaProProgressVM.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        vm.progressCompleteBlock = {[weak self] in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                guard self.currentIndex == 0 else { return }
                self.currentIndex = 1
                UIView.animate(withDuration: 0.35, delay: 0) {
                    self.naviVm.alpha = 0
                }
                self.scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT, y: 0), animated: true)
                self.updateNextButtonForCurrentStep(animated: true)
            }
        }
        return vm
    }()
    
    lazy var planVm: ElaProPlanVM = {
        let vm = ElaProPlanVM.init(frame: CGRect(x: SCREEN_WIDHT, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var readyVm: ElaProReadyVM = {
        let vm = ElaProReadyVM.init(frame: CGRect(x: SCREEN_WIDHT*2, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var transformVm: ElaProTransformVM = {
        let vm = ElaProTransformVM.init(frame: CGRect(x: SCREEN_WIDHT*3, y: 0, width: 0, height: 0))
        return vm
    }()
    
    lazy var priceVm: ElaProPriceVM = {
        let vm = ElaProPriceVM.init(frame: CGRect(x: SCREEN_WIDHT * 4, y: 0, width: 0, height: 0))
        vm.purchaseSuccessBlock = { [weak self] in
            self?.backTapAction()
        }
        vm.protocalTapBlock = { [weak self] in
            self?.showAgreementAlert()
        }
        return vm
    }()
    
    lazy var nextButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)
        return btn
    }()
}

extension ElaProVC{
    @objc func nextButtonTapAction() {
        if currentIndex == 1 {
            currentIndex = 2
            scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * 2, y: 0), animated: true)
            updateNextButtonForCurrentStep(animated: true)
            UIView.animate(withDuration: 0.35, delay: 0) {
                self.naviVm.alpha = 1
            }
        } else if currentIndex == 2 {
            currentIndex = 3
            self.naviVm.alpha = 0
            scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * 3, y: 0), animated: true)
            updateNextButtonForCurrentStep(animated: true)
        } else if currentIndex == 3 {
            currentIndex = 4
            self.naviVm.backButton.setImage(UIImage(named: "navi_close_icon"), for: .normal)
            UIView.animate(withDuration: 0.35, delay: 0) {
                self.naviVm.alpha = 1
            }
            scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * 4, y: 0), animated: true)
            updateNextButtonForCurrentStep(animated: true)
        }
    }
    
    func updateNextButtonForCurrentStep(animated: Bool) {
        let shouldShow = (currentIndex == 1 || currentIndex == 2 || currentIndex == 3)
        let moveY = kFitWidth(90) + WHUtils().getBottomSafeAreaHeight()
        let targetTransform = shouldShow ? .identity : CGAffineTransform(translationX: 0, y: moveY)
        let targetAlpha: CGFloat = shouldShow ? 1 : 0
        let apply = {
            self.nextButton.transform = targetTransform
            self.nextButton.alpha = targetAlpha
        }
        nextButton.isUserInteractionEnabled = shouldShow
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                apply()
            }
        } else {
            apply()
        }
    }
    
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        
        view.addSubview(scrollViewBase)
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.showsHorizontalScrollIndicator = false
        scrollViewBase.isScrollEnabled = false
        view.addSubview(naviVm)
        view.addSubview(nextButton)

        scrollViewBase.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT * 5, height: 0)
        scrollViewBase.addSubview(progressVm)
        scrollViewBase.addSubview(planVm)
        scrollViewBase.addSubview(readyVm)
        scrollViewBase.addSubview(transformVm)
        scrollViewBase.addSubview(priceVm)
        
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }
        
        updateNextButtonForCurrentStep(animated: false)
    }
    
    private func showAgreementAlert() {
        let alertVm: ElaProAgreementAlertVM
        if let existing = agreementAlertVm {
            alertVm = existing
        } else {
            let created = ElaProAgreementAlertVM(frame: .zero)
            agreementAlertVm = created
            view.addSubview(created)
            alertVm = created
        }
        alertVm.showSelf()
    }
}

extension ElaProVC{
    func sendDietUpsertRequest() {
        DLLog(message: "sendDietUpsertRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_upsert, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            
        }
    }
}
