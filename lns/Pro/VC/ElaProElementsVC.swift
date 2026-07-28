//
//  ElaProElementsVC.swift
//  lns
//
//  Created by Codex on 2026/7/20.
//

import UIKit

class ElaProElementsVC: WHBaseViewVC, UIGestureRecognizerDelegate {
    private var currentIndex = 0
    private var agreementAlertVm: ElaProAgreementAlertVM?
    private lazy var backToIntroPanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleBackToIntroPan(_:)))
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        return gesture
    }()
    
    lazy var introVm: ElaProElementsIntroVM = {
        let vm = ElaProElementsIntroVM(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vm.continueTapBlock = { [weak self] in
            self?.showNextVm()
        }
        return vm
    }()
    
    lazy var secondVm: ElaProPriceVM = {
        let vm = ElaProPriceVM(frame: CGRect(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vm.backgroundColor = .clear
        vm.bizType = "5"
        vm.purchaseQueryBizType = "5"
        vm.displayMode = .elements
        vm.protocalTapBlock = { [weak self] in
            self?.showAgreementAlert()
        }
        vm.purchaseSuccessBlock = { [weak self] in
            self?.refreshVipInfoAndBack()
        }
        vm.startLoadingIfNeeded()
        return vm
    }()
    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
//        vm.alpha = 0
        vm.firstStepVm.isHidden = true
        vm.secondStepVm.isHidden = true
        vm.thirdStepVm.isHidden = true
        vm.backTapBlock = {[weak self] in
            self?.backButtonTapAction()
        }
        return vm
    }()
//    lazy var backButton: UIButton = {
//        let btn = UIButton(type: .custom)
//        btn.backgroundColor = .clear
//        btn.layer.cornerRadius = kFitWidth(23)
//        btn.layer.borderWidth = kFitWidth(1)
//        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.9).cgColor
//        btn.clipsToBounds = true
//        btn.setImage(UIImage(named: "habit_guide_back_icon"), for: .normal)
//        btn.imageView?.contentMode = .scaleAspectFit
//        btn.addTarget(self, action: #selector(backButtonTapAction), for: .touchUpInside)
//        return btn
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VIPModel.shared.updateSubscriptionBizType("5")
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePopGestureState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreElementsPopGestureState()
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === backToIntroPanGesture,
              currentIndex == 1,
              agreementAlertVm?.isHidden != false,
              let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        let translation = panGesture.translation(in: view)
        let velocity = panGesture.velocity(in: view)
        let isHorizontal = abs(translation.x) > abs(translation.y) || abs(velocity.x) > abs(velocity.y)
        return isHorizontal && (translation.x > 0 || velocity.x > 0)
    }
}

private extension ElaProElementsVC {
    func initUI() {
        addELAFlowingBackground()
        view.addSubview(scrollViewBase)
        view.addSubview(naviVm)
//        view.addSubview(backButton)
        
        scrollViewBase.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT * 2, height: SCREEN_HEIGHT)
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.isScrollEnabled = false
        scrollViewBase.bounces = false
        scrollViewBase.showsHorizontalScrollIndicator = false
        scrollViewBase.backgroundColor = .clear
        view.addGestureRecognizer(backToIntroPanGesture)
        scrollViewBase.addSubview(introVm)
        scrollViewBase.addSubview(secondVm)
        updatePopGestureState()
        
//        backButton.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(12))
//            make.top.equalTo(statusBarHeight + kFitWidth(5))
//            make.width.height.equalTo(kFitWidth(46))
//        }
    }
    
    func showNextVm() {
        currentIndex = 1
        scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT, y: 0), animated: true)
        updatePopGestureState()
    }
    
    func showIntroVm(animated: Bool = true) {
        currentIndex = 0
        scrollViewBase.setContentOffset(.zero, animated: animated)
        updatePopGestureState()
    }
    
    @objc func backButtonTapAction() {
        if currentIndex == 1 {
            showIntroVm()
            return
        }
        backTapAction()
    }
    
    @objc func handleBackToIntroPan(_ gesture: UIPanGestureRecognizer) {
        let translationX = max(gesture.translation(in: view).x, 0)
        let progress = min(translationX / SCREEN_WIDHT, 1)
        
        switch gesture.state {
        case .changed:
            let offsetX = max(SCREEN_WIDHT - translationX, 0)
            scrollViewBase.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
        case .ended:
            let velocityX = gesture.velocity(in: view).x
            if progress > 0.3 || velocityX > kFitWidth(500) {
                showIntroVm()
            } else {
                scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT, y: 0), animated: true)
            }
        case .cancelled, .failed:
            scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT, y: 0), animated: true)
        default:
            break
        }
    }
    
    func updatePopGestureState() {
        let isShowingSecondVm = currentIndex == 1
        canEdgeBack = !isShowingSecondVm
        fd_forceDisableInteractivePopGesture = isShowingSecondVm
        fd_interactivePopDisabled = isShowingSecondVm
        navigationController?.fd_interactivePopDisabled = isShowingSecondVm
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = !isShowingSecondVm
        navigationController?.interactivePopGestureRecognizer?.isEnabled = !isShowingSecondVm
        backToIntroPanGesture.isEnabled = isShowingSecondVm
    }
    
    func restoreElementsPopGestureState() {
        canEdgeBack = true
        fd_forceDisableInteractivePopGesture = false
        fd_interactivePopDisabled = false
        navigationController?.fd_interactivePopDisabled = false
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        backToIntroPanGesture.isEnabled = false
    }
    
    func showAgreementAlert() {
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
    
    func refreshVipInfoAndBack() {
        WHNetworkUtil.shareManager().POST(urlString: URL_pro_info, parameters: nil) { [weak self] responseObject in
            guard let self = self else { return }
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            VIPModel.shared.update(with: dataDict)
            NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_VIP_STATUS, object: nil)
            self.backTapAction()
        } failure: { [weak self] _ in
            self?.backTapAction()
        }
    }
}
