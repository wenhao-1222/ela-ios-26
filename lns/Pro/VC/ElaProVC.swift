//
//  ElaProVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/3.
//


class ElaProVC: WHBaseViewVC {
    private var currentIndex: Int = 0
    
    var param = [String : Any]()
    var showPriceOnly = false
    var popToRootOnClose = false
    var enterAICoachPreOnClose = false
    private var agreementAlertVm: ElaProAgreementAlertVM?
    
    lazy var purchaseLoadingMaskView: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        vi.isUserInteractionEnabled = true
        vi.isHidden = true
        return vi
    }()
    lazy var purchaseLoadingIndicator: UIActivityIndicatorView = {
        let vi = UIActivityIndicatorView(style: .large)
        vi.color = .white
        vi.hidesWhenStopped = false
        return vi
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        applyInitialDisplayMode()
//        
//        if showPriceOnly == false {
//            self.sendDietUpsertRequest()
//        }
        
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is DietPlanCreateVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.fd_interactivePopDisabled = true
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.fd_interactivePopDisabled = false
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
    }
    
    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
//        vm.alpha = 0
        vm.firstStepVm.isHidden = true
        vm.secondStepVm.isHidden = true
        vm.thirdStepVm.isHidden = true
        vm.backTapBlock = {[weak self] in
            guard let self = self else { return }
            self.handleCloseAction()
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
            self?.handlePurchaseSuccess()
        }
        vm.protocalTapBlock = { [weak self] in
            self?.showAgreementAlert()
        }
        vm.purchaseLoadingStateChangeBlock = { [weak self] visible in
            self?.setPurchaseLoadingVisible(visible)
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
            self.naviVm.backButton.frame = CGRect.init(x: SCREEN_WIDHT - kFitWidth(12.5) - kFitWidth(35), y: statusBarHeight+kFitWidth(5), width: kFitWidth(35), height: kFitWidth(35))
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
    
    private func applyInitialDisplayMode() {
        if showPriceOnly {
            currentIndex = 4
            progressVm.isHidden = true
            planVm.isHidden = true
            readyVm.isHidden = true
            transformVm.isHidden = true
            priceVm.isHidden = false
            priceVm.frame.origin.x = 0
            naviVm.alpha = 1
            naviVm.backButton.setImage(UIImage(named: "navi_close_icon"), for: .normal)
            naviVm.backButton.frame = CGRect.init(x: SCREEN_WIDHT - kFitWidth(12.5) - kFitWidth(35), y: statusBarHeight+kFitWidth(5), width: kFitWidth(35), height: kFitWidth(35))
            scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT, height: 0)
            scrollViewBase.setContentOffset(.zero, animated: false)
            updateNextButtonForCurrentStep(animated: false)
            
            return
        }
        
        progressVm.isHidden = false
        planVm.isHidden = false
        readyVm.isHidden = false
        transformVm.isHidden = false
        priceVm.isHidden = false
    }
    
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        
        view.addSubview(scrollViewBase)
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.showsHorizontalScrollIndicator = false
        scrollViewBase.isScrollEnabled = false
        view.addSubview(naviVm)
        view.addSubview(nextButton)
        view.addSubview(purchaseLoadingMaskView)
        purchaseLoadingMaskView.addSubview(purchaseLoadingIndicator)

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
        
        purchaseLoadingMaskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        purchaseLoadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
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
    
    private func setPurchaseLoadingVisible(_ visible: Bool) {
        purchaseLoadingMaskView.isHidden = !visible
        if visible {
            view.bringSubviewToFront(purchaseLoadingMaskView)
            purchaseLoadingIndicator.startAnimating()
        } else {
            purchaseLoadingIndicator.stopAnimating()
        }
    }
    
    private func handlePurchaseSuccess() {
        applyTemporaryValidVipStatus()
        requestLatestVipInfo()
        NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_DIET_PLAN_STATUS, object: nil)
        handleCloseAction()
    }
    
    private func handleCloseAction() {
        if enterAICoachPreOnClose {
            let vc = AICoachPreVC()
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        if popToRootOnClose {
            navigationController?.popToRootViewController(animated: true)
        } else {
            backTapAction()
        }
    }
    
    private func applyTemporaryValidVipStatus() {
        let currentVipModel = UserInfoModel.shared.vipModel
        let tempVipModel = VIPModel()
        tempVipModel.uid = currentVipModel.uid.isEmpty ? UserInfoModel.shared.uId : currentVipModel.uid
        tempVipModel.startTime = currentVipModel.startTime
        tempVipModel.expireTime = currentVipModel.expireTime
        tempVipModel.ctime = currentVipModel.ctime
        tempVipModel.etime = currentVipModel.etime
        tempVipModel.isLifetime = currentVipModel.isLifetime
//        tempVipModel.vipType = currentVipModel.vipType == .none ? .year : currentVipModel.vipType
        tempVipModel.status = .valid
        UserInfoModel.shared.vipModel = tempVipModel
    }
    
    private func requestLatestVipInfo() {
        WHNetworkUtil.shareManager().POST(urlString: URL_pro_info, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            let vipModel = VIPModel().initWithDict(dict: dataDict)
            UserInfoModel.shared.vipModel = vipModel
            DLLog(message: "ElaProVC requestLatestVipInfo:\(dataDict)")
            DLLog(message: "ElaProVC requestLatestVipInfo model: uid=\(vipModel.uid), status=\(vipModel.status?.rawValue ?? 0), isLifetime=\(vipModel.isLifetime), expireTime=\(vipModel.expireTime)")
            NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_DIET_PLAN_STATUS, object: nil)
        }
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
