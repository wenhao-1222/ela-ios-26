//
//  ElaProElementsVC.swift
//  lns
//
//  Created by Codex on 2026/7/20.
//

import UIKit

class ElaProElementsVC: WHBaseViewVC {
    private var currentIndex = 0
    private var agreementAlertVm: ElaProAgreementAlertVM?
    
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
        scrollViewBase.addSubview(introVm)
        scrollViewBase.addSubview(secondVm)
        
//        backButton.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(12))
//            make.top.equalTo(statusBarHeight + kFitWidth(5))
//            make.width.height.equalTo(kFitWidth(46))
//        }
    }
    
    func showNextVm() {
        currentIndex = 1
        scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT, y: 0), animated: true)
    }
    
    @objc func backButtonTapAction() {
        if currentIndex == 1 {
            currentIndex = 0
            scrollViewBase.setContentOffset(.zero, animated: true)
            return
        }
        backTapAction()
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
