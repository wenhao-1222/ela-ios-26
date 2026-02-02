//
//  HabitVC.swift
//  lns
//
//  Created by LNS2 on 2025/12/23.
//

class HabitVC: WHBaseViewVC {
    
    var dataObj = NSDictionary()
    var isSetPopGesture = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendDataRequest()
        sendLastWeekRanklistRequest()
    }
    lazy var topTypeVm: HabitTopTypeVM = {
        let vm = HabitTopTypeVM.init(frame: .zero)
        vm.typeChangeBlock = {(pageIndex)in
            self.scrollViewBase.setContentOffset(CGPoint.init(x: SCREEN_WIDHT*pageIndex, y: 0), animated: true)
        }
        return vm
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
        vc.exchangeBlock = {()in
            self.sendDataRequest()
            self.rankListVm.sendDataRequest()
        }
    }
}

extension HabitVC{
    func initUI() {
        initNavi(titleStr: "自律习惯养成")
        self.navigationView.backgroundColor = .COLOR_BG_F2
        view.backgroundColor = .COLOR_BG_F2
        
        view.addSubview(topTypeVm)
        
        view.addSubview(scrollViewBase)
        
//        view.addSubview(guideVm)
        
        scrollViewBase.frame = CGRect.init(x: 0, y: self.topTypeVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT - self.topTypeVm.frame.maxY)
        scrollViewBase.addSubview(progressVm)
        scrollViewBase.addSubview(rankListVm)
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.delegate = self
        scrollViewBase.bounces = false
        scrollViewBase.showsHorizontalScrollIndicator = false
        scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*2, height: 0)
    }
}

extension HabitVC:UIScrollViewDelegate{
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

        topTypeVm.changeType(isLeft: !isShowingRank)
        rankListVm.updateVisibility(isVisible: isShowingRank)
        if !isShowingRank {
            progressVm.triggerPointAnimationIfNeeded()
        }
        if scrollView.contentOffset.x > kFitWidth(20){
            self.navigationController?.fd_interactivePopDisabled = true
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        }else{
            if let popGesture = self.navigationController?.fd_fullscreenPopGestureRecognizer {
                scrollViewBase.panGestureRecognizer.require(toFail: popGesture)
            }
            self.navigationController?.fd_interactivePopDisabled = false
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        }
    }
}

extension HabitVC{
    func sendDataRequest(){
        WHNetworkUtil.shareManager().POST(urlString: URL_user_habit_dashboard, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendDataRequest:\(dataDict)")
            
            self.dataObj = dataDict
            self.progressVm.updateUI(dict: self.dataObj)
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
