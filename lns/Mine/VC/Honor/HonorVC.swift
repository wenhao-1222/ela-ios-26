//
//  HonorVC.swift
//  lns
//
//  Created by LNS2 on 2026/1/12.
//

class HonorVC: WHBaseViewVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    lazy var topMsgVm: HonorTopVM = {
        let vm = HonorTopVM.init(frame: .zero)
        return vm
    }()
    lazy var typeVm: HonorTypeVM = {
        let vm = HonorTypeVM.init(frame: CGRect.init(x: 0, y: self.topMsgVm.frame.minY+kFitWidth(161), width: 0, height: 0))
        
        vm.tapBlock = {(type)in
            if type == 0{
                self.scrollViewBase.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }else{
                self.scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT, y: 0), animated: true)
            }
            
        }
        
        return vm
    }()
    lazy var iconMsgVm: HonorIconVM = {
        let vm = HonorIconVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.scrollViewBase.frame.height))
        vm.dataBlock = {(dict)in
            self.topMsgVm.updateUI(iconNum: dict.stringValueForKey(key: "badgeCount"),
                                   donateNum: dict.stringValueForKey(key: "donationCertificateCount"))
        }
        
        return vm
    }()
    lazy var donationVm: HonorDonationVM = {
        let vm = HonorDonationVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: self.scrollViewBase.frame.height))
        return vm
    }()
    lazy var msgVm: HonorDonationMsgVM = {
        let vm = HonorDonationMsgVM.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(375), height: kFitWidth(812)))
        return vm
    }()
}

extension HonorVC{
    func initUI() {
        initNavi(titleStr: "")
        navigationView.backgroundColor = .clear
        view.backgroundColor = .COLOR_BG_F2
        
        view.insertSubview(topMsgVm, belowSubview: navigationView)
        view.addSubview(typeVm)
        
        view.addSubview(scrollViewBase)
        scrollViewBase.frame = CGRect.init(x: 0, y: self.typeVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.typeVm.frame.maxY)
        
        scrollViewBase.addSubview(iconMsgVm)
        scrollViewBase.addSubview(donationVm)
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.delegate = self
        scrollViewBase.bounces = false
        scrollViewBase.contentSize = CGSizeMake(SCREEN_WIDHT*2, 0)
//        FireworkParticlesBurst.play(in: self.view,
//                                    center: CGPoint(x: 200, y: 400),
//                                    size: CGSize(width: 260, height: 260))
        
//        view.addSubview(msgVm)
        if let popGesture = self.navigationController?.fd_fullscreenPopGestureRecognizer {
            scrollViewBase.panGestureRecognizer.require(toFail: popGesture)
        }
        self.navigationController?.fd_interactivePopDisabled = false
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
    }
}

extension HonorVC:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > SCREEN_WIDHT * 0.75{
            self.typeVm.rightTapAction()
            self.navigationController?.fd_interactivePopDisabled = true
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        }else{
            self.typeVm.leftTapAction()
            self.navigationController?.fd_interactivePopDisabled = false
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        }
    }
}
