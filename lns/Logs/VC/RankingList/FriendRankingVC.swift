//
//  FriendRankingVC.swift
//  lns
//
//  Created by Elavatine on 2025/6/30.
//

class FriendRankingVC: WHBaseViewVC {
    
    var isSetPopGesture = false
    
    override func viewWillAppear(_ animated: Bool) {
        sendFriendListRequest()
        
//        if scrollViewBase.contentOffset.x > kFitWidth(20){
//            self.navigationController?.fd_interactivePopDisabled = true
//            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
//        }else{
//            self.navigationController?.fd_interactivePopDisabled = false
//            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self.navigationController?.fd_interactivePopDisabled = false
//        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        if self.typeVm.currentIndex == 1{
//            self.navigationController?.fd_interactivePopDisabled = true
//            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now()+0.03, execute: {
                self.typeVm.changeType(duration: 0)
                self.scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT, y: 0), animated: false)
            })
        }else{
//            if let popGesture = self.navigationController?.fd_fullscreenPopGestureRecognizer {
//                isSetPopGesture = true
//                scrollViewBase.panGestureRecognizer.require(toFail: popGesture)
//            }
        }
    }
    lazy var topVm: FriendRankingListTopVM = {
        let vm = FriendRankingListTopVM.init(frame: .zero)
        vm.friendTapBlock = {()in
            let vc = FriendListVC()
//            self.present(vc, animated: true)
            vc.friendDataRefreshBlock = {()in
                self.dailyRankingVm.sendDailyRankingListRequest()
                self.weekRankingVm.sendWeekRankingListRequest()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.backTapBlock = {()in
            self.backTapAction()
        }
        return vm
    }()
    lazy var typeVm: FriendRankingListTypeVM = {
        let vm = FriendRankingListTypeVM.init(frame: CGRect.init(x: 0, y: self.topVm.frame.maxY, width: 0, height: 0))
        vm.tapBlock = {()in
            self.updateUI()
        }
        return vm
    }()
    lazy var dailyRankingVm: FriendRankingDailyListVM = {
        let vm = FriendRankingDailyListVM.init(frame: CGRect.init(x: 0, y: self.typeVm.frame.maxY, width: SCREEN_WIDHT, height: 0))
        vm.controller = self
        
        return vm
    }()
    lazy var weekRankingVm: FriendRankingWeekListVM = {
        let vm = FriendRankingWeekListVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.typeVm.frame.maxY, width: SCREEN_WIDHT, height: 0))
        vm.controller = self
        return vm
    }()
}

extension FriendRankingVC{
    func initUI()  {
        view.addSubview(scrollViewBase)
        view.addSubview(topVm)
        view.addSubview(typeVm)
        
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.addSubview(dailyRankingVm)
        scrollViewBase.addSubview(weekRankingVm)
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.bounces = false
        scrollViewBase.delegate = self
        scrollViewBase.showsHorizontalScrollIndicator = false
        scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*2, height: 0)
    }
}

extension FriendRankingVC : UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > kFitWidth(20){
            self.typeVm.currentIndex = 1
            self.navigationController?.fd_interactivePopDisabled = true
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        }else{
            if let popGesture = self.navigationController?.fd_fullscreenPopGestureRecognizer ,
               isSetPopGesture == false{
                isSetPopGesture = true
                scrollViewBase.panGestureRecognizer.require(toFail: popGesture)
            }
            self.typeVm.currentIndex = 0
            self.navigationController?.fd_interactivePopDisabled = false
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        }
        self.typeVm.changeType()
    }
    func updateUI() {
        if self.typeVm.currentIndex == 0 {
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.scrollViewBase.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
            self.navigationController?.fd_interactivePopDisabled = false
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        }else{
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT, y: 0), animated: true)
            }
            self.navigationController?.fd_interactivePopDisabled = true
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        }
    }
}

extension FriendRankingVC{
    func sendFriendListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_friend_pengding_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
            self.topVm.newFriendMsgRedIcon.isHidden = dataArray.count > 0 ? false : true
        }
    }
}
