//
//  HabitVC.swift
//  lns
//
//  Created by LNS2 on 2025/12/23.
//

class HabitVC: WHBaseViewVC {
    
    var dataObj = NSDictionary()
    var isSetPopGesture = false
    private var isRankListPageShowing = false

//    override var prefersSystemNavigationBarOnIOS26: Bool { true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        updateInteractivePopGestureState()
        sendDataRequest()
        sendLastWeekRanklistRequest()
        
        EventLogUtils().sendEventLogRequest(
            eventName: .CLICK_BUTTON,
            scenarioType: .habit_view,
            text: ""
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateInteractivePopGestureState()
    }
    
    lazy var topTypeVm: HabitTopTypeVM = {
        let vm = HabitTopTypeVM.init(frame: .zero)
        vm.typeChangeBlock = {(pageIndex)in
            let targetOffset = CGPoint.init(x: SCREEN_WIDHT*pageIndex, y: 0)
            if pageIndex == 1 {
                self.topTypeVm.isUserInteractionEnabled = false
                self.scrollViewBase.isUserInteractionEnabled = false
                self.rankListVm.prepareLeaderboardForDisplay {
                    self.scrollViewBase.setContentOffset(targetOffset, animated: true)
                    self.scrollViewBase.isUserInteractionEnabled = true
                    self.topTypeVm.isUserInteractionEnabled = true
                }
            }else{
                self.scrollViewBase.setContentOffset(targetOffset, animated: true)
            }
        }
        return vm
    }()
    
    lazy var bgImgView: UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        img.setImgLocal(imgName: "habit_ranklist_bg_img")
        img.contentMode = isIpad() ? .scaleAspectFill : .scaleAspectFit
//        img.alpha = 0
        
        return img
    }()
    lazy var progressVm: HabitProgressVM = {
        let vm = HabitProgressVM.init(frame: CGRect.init(x: 0, y: self.topTypeVm.frame.maxY, width: 0, height: 0))
//        let vm = HabitProgressVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.controller = self
        vm.friendMsgVm.controller = self
        
        vm.topMsgVm.numberTapBlock = {()in
            self.pointDetailTapAction()
        }
        vm.refreshBlock = {()in
            self.rankListVm.isCurrentlyVisible = false
            self.sendDataRequest()
        }
        
        vm.topMsgVm.changeButton.addTarget(self, action: #selector(pointExchangeTapAction), for: .touchUpInside)
        
        return vm
    }()
    lazy var rankListVm: HabitRankListVM = {
        let vm = HabitRankListVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.topTypeVm.frame.maxY, width: 0, height: 0 ))
        vm.controller = self
        vm.emptyVm.togoRecordBlock = {()in
            self.scrollViewBase.setContentOffset(.zero, animated: true)
        }
        return vm
    }()
    lazy var guideVm: HabitGuideVM = {
        let vm = HabitGuideVM.init(frame: .zero)
        vm.backBlock = {()in
            self.backTapAction()
        }
        return vm
    }()
}

extension HabitVC{
    @objc func pointDetailTapAction() {
        let vc = HabitDetailVC()
//        let vc = DemoVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func pointExchangeTapAction() {
//        let vc = DemoViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
        let vc = HabitExchangeVC()
        vc.msgDict = self.dataObj
        self.navigationController?.pushViewController(vc, animated: true)
        vc.exchangeBlock = {(dataDict) in
            self.dataObj = dataDict
            self.progressVm.updateUI(dict: dataDict, isAnimate: true)
            self.rankListVm.sendDataRequest()
        }
    }
}

extension HabitVC{
    func initUI() {
        view.addSubview(bgImgView)
        initNavi(titleStr: "自律习惯养成")
        self.navigationView.backgroundColor = .clear
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(topTypeVm)
        
        view.addSubview(scrollViewBase)
        
        if UserDefaults.getString(forKey: .rank_list_guide) == nil{
            view.addSubview(guideVm)
        }
        
        scrollViewBase.frame = CGRect.init(x: 0, y: self.topTypeVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT - self.topTypeVm.frame.maxY)
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.addSubview(progressVm)
        scrollViewBase.addSubview(rankListVm)
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.delegate = self
        scrollViewBase.bounces = false
        scrollViewBase.showsHorizontalScrollIndicator = false
        scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*2, height: 0)
        configureScrollPopGestureDependency()
    }
}

extension HabitVC:UIScrollViewDelegate{
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === scrollViewBase,
              scrollView.contentOffset.x < SCREEN_WIDHT * 0.5,
              !rankListVm.canShowPreparedLeaderboard else {
            return
        }
        rankListVm.prepareLeaderboardForDisplay()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView === scrollViewBase,
              targetContentOffset.pointee.x > SCREEN_WIDHT * 0.5,
              !rankListVm.isCurrentlyVisible else {
            return
        }

        guard rankListVm.canShowPreparedLeaderboard else {
            targetContentOffset.pointee = CGPoint(x: 0, y: targetContentOffset.pointee.y)
            rankListVm.prepareLeaderboardForDisplay {
                self.scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT, y: 0), animated: true)
            }
            return
        }

        targetContentOffset.pointee = CGPoint(x: SCREEN_WIDHT, y: targetContentOffset.pointee.y)
        rankListVm.prepareLeaderboardForDisplay {
            if self.scrollViewBase.contentOffset.x > SCREEN_WIDHT * 0.5 {
                self.rankListVm.updateVisibility(isVisible: true)
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        adjustPageState(for: scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        adjustPageState(for: scrollView)
    }
}

extension HabitVC{
    private func adjustPageState(for scrollView: UIScrollView) {
        let isShowingRank = scrollView.contentOffset.x > SCREEN_WIDHT * 0.5
        if isShowingRank && !isRankListPageShowing {
            EventLogUtils().sendHabitRankListPageView()
        }
        isRankListPageShowing = isShowingRank

        topTypeVm.changeType(isLeft: !isShowingRank)
        rankListVm.updateVisibility(isVisible: isShowingRank)
        
//        UIView.animate(withDuration: 0.25, delay: 0) {
//            self.bgImgView.alpha = isShowingRank ? 1 : 0
//        }
        if !isShowingRank {
            progressVm.triggerPointAnimationIfNeeded()
        }
        updateInteractivePopGestureState()
    }
    
    private func updateInteractivePopGestureState() {
        let isPopDisabled = scrollViewBase.contentOffset.x > kFitWidth(20)
        canEdgeBack = !isPopDisabled
        fd_interactivePopDisabled = isPopDisabled
        navigationController?.fd_interactivePopDisabled = isPopDisabled
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = !isPopDisabled
        navigationController?.interactivePopGestureRecognizer?.isEnabled = !isPopDisabled
        
        if !isPopDisabled {
            configureScrollPopGestureDependency()
        }
    }
    
    private func configureScrollPopGestureDependency() {
        if let popGesture = self.navigationController?.fd_fullscreenPopGestureRecognizer {
            scrollViewBase.panGestureRecognizer.require(toFail: popGesture)
        }
    }
}

extension HabitVC{
    func sendDataRequest(){
        WHNetworkUtil.shareManager().POST(urlString: URL_user_habit_dashboard, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendDataRequest dashboard:\(dataDict)")
            
            self.dataObj = dataDict
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.progressVm.updateUI(dict: self.dataObj,isAnimate: true)
            })
        }
    }
    func sendLastWeekRanklistRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_user_habit_leaderboard_last, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendLastWeekRanklistRequest:\(dataDict)")
            
            self.rankListVm.updateUI(dict: dataDict)
        }
    }
}
