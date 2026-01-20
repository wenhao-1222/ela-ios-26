//
//  HabitProgressVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/23.
//

import MCToast

class HabitProgressVM: UIView {
    
    var controller = WHBaseViewVC()
    var refreshBlock:(()->())?
    var lastNumber = 0
    var isCounting = false
    private var pendingPointAnimation: (start: Int, target: Int)?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        triggerPointAnimationIfNeeded()
    }
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.backgroundColor = .clear
        scro.delegate = self
        
        return scro
    }()
    lazy var topMsgVm: HabitTopMsgVM = {
        let vm = HabitTopMsgVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        
        return vm
    }()
    lazy var todayMsgVm: HabitTodayGoalVM = {
        let vm = HabitTodayGoalVM.init(frame: CGRect.init(x: 0, y: kFitWidth(170), width: 0, height: 0))
        vm.journalMsgVm.showButton.addTarget(self, action: #selector(showJournalRuleAction), for: .touchUpInside)
        vm.proteinMsgVm.showButton.addTarget(self, action: #selector(showProteinRuleAction), for: .touchUpInside)
        vm.bodyDataMsgVm.showButton.addTarget(self, action: #selector(showBodydataRuleAction), for: .touchUpInside)
        vm.fitnessMsgVm.showButton.addTarget(self, action: #selector(showFitnessRuleAction), for: .touchUpInside)
        vm.tipsTapBlock = {()in
            self.habitRuleAlertVm.showSelf()
        }
        return vm
    }()
    lazy var friendMsgVm: HabitFriendsGoalVM = {
        let vm = HabitFriendsGoalVM.init(frame: CGRect.init(x: 0, y: self.todayMsgVm.frame.maxY+kFitWidth(12), width: 0, height: 0))
        vm.heightChangeBlock = {(height)in
            let streakMsgVmCenter = self.streakMsgVm.center
            self.friendMsgVm.frame = CGRect.init(x: 0, y: self.todayMsgVm.frame.maxY+kFitWidth(12), width: SCREEN_WIDHT, height: height)
            self.streakMsgVm.center = CGPoint.init(x: streakMsgVmCenter.x, y: self.friendMsgVm.frame.maxY + kFitWidth(12) + self.streakMsgVm.selfHeight*0.5)
            self.streakListVm.frame = CGRect.init(x: 0, y: self.streakMsgVm.frame.maxY+kFitWidth(12), width: SCREEN_WIDHT, height: self.streakListVm.selfHeight)
            self.scrollView.contentSize = CGSize.init(width: 0, height: self.streakListVm.frame.maxY+kFitWidth(20))
        }
        
        return vm
    }()
    lazy var streakMsgVm: HabitStreakMsgVM = {
        let vm = HabitStreakMsgVM.init(frame: CGRect.init(x: 0, y: self.friendMsgVm.frame.maxY + kFitWidth(12), width: 0, height: 0))
        return vm
    }()
    lazy var streakListVm: HabitStreakListVM = {
        let vm = HabitStreakListVM.init(frame: CGRect.init(x: 0, y: self.streakMsgVm.frame.maxY + kFitWidth(12), width: 0, height: 0))
        vm.heightChangeBlock = {(height)in
            self.streakListVm.frame = CGRect.init(x: 0, y: self.streakMsgVm.frame.maxY+kFitWidth(12), width: SCREEN_WIDHT, height: self.streakListVm.selfHeight)
            self.scrollView.contentSize = CGSize.init(width: 0, height: self.streakListVm.frame.maxY+kFitWidth(20))
        }
        vm.recieveBlock = {(streakId)in
            self.sendRecieveStreakRequest(streakId: streakId)
        }
        return vm
    }()
    lazy var habitRuleAlertVm: HabitRuleAlertVM = {
        let vm = HabitRuleAlertVM.init(frame: .zero)
        return vm
    }()
    lazy var ruleJournalAlertVm: HabitRuleJournalAlertVM = {
        let vm = HabitRuleJournalAlertVM.init(frame: .zero)
        return vm
    }()
    lazy var ruleProteinAlertVm: HabitRuleProteinAlertVM = {
        let vm = HabitRuleProteinAlertVM.init(frame: .zero)
        return vm
    }()
    lazy var ruleBodydataAlertVm: HabitRuleBodyDataAlertVM = {
        let vm = HabitRuleBodyDataAlertVM.init(frame: .zero)
        return vm
    }()
    lazy var ruleFitnessAlertVm: HabitRuleFitnessAlertVM = {
        let vm = HabitRuleFitnessAlertVM.init(frame: .zero)
        return vm
    }()
}

extension HabitProgressVM{
    func updateUI(dict:NSDictionary) {
//        self.topMsgVm.numberLabel.text = dict.stringValueForKey(key: "pointBalance")
//        if isCounting{
        let nextPointBalance = Int(dict.doubleValueForKey(key: "pointBalance").rounded())
        let previousPointBalance = lastNumber

        if isCounting {
            pendingPointAnimation = (start: previousPointBalance, target: nextPointBalance)
            isCounting = false
//            self.topMsgVm.numberLabel.count(from: CGFloat(self.lastNumber), to: CGFloat(Int(dict.doubleValueForKey(key: "pointBalance").rounded())), withDuration: 0.5)
            if isPointLabelVisible() {
                triggerPointAnimationIfNeeded()
            } else {
                self.topMsgVm.numberLabel.text = "\(previousPointBalance)"
            }
        } else if pendingPointAnimation == nil {
            self.topMsgVm.numberLabel.text = "\(nextPointBalance)"
        }
        self.lastNumber = nextPointBalance//dict.stringValueForKey(key: "pointBalance").intValue
        self.todayMsgVm.updateUI(dict: dict)
        self.friendMsgVm.updateUI(dict: dict)
        self.streakListVm.updateUI(listArray: dict["streakRewardList"]as? NSArray ?? [])
    }
}

extension HabitProgressVM{
    @objc func showJournalRuleAction(){
        ruleJournalAlertVm.showSelf()
    }
    @objc func showProteinRuleAction(){
        ruleProteinAlertVm.showSelf()
    }
    @objc func showBodydataRuleAction(){
        ruleBodydataAlertVm.showSelf()
    }
    @objc func showFitnessRuleAction(){
        ruleFitnessAlertVm.showSelf()
    }
}

extension HabitProgressVM{
    func initUI() {
        addSubview(scrollView)
        scrollView.addSubview(topMsgVm)
        scrollView.addSubview(todayMsgVm)
        scrollView.addSubview(friendMsgVm)
        scrollView.addSubview(streakMsgVm)
        scrollView.addSubview(streakListVm)
        
        scrollView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getKeyWindow().addSubview(habitRuleAlertVm)
        appDelegate.getKeyWindow().addSubview(ruleJournalAlertVm)
        appDelegate.getKeyWindow().addSubview(ruleProteinAlertVm)
        appDelegate.getKeyWindow().addSubview(ruleBodydataAlertVm)
        appDelegate.getKeyWindow().addSubview(ruleFitnessAlertVm)
    }
}


extension HabitProgressVM{
    func sendRecieveStreakRequest(streakId:String) {
        let param = ["streakRewardId":streakId]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_user_habit_claimStreakReward, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendDataRequest:\(dataDict)")
            self.isCounting = true
            
            MCToast.mc_text("领取成功")
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                self.refreshBlock?()
            })
        }
    }
}

extension HabitProgressVM{
    func triggerPointAnimationIfNeeded() {
        guard let pending = pendingPointAnimation else { return }
        guard isPointLabelVisible() else { return }
        pendingPointAnimation = nil
        if pending.start == pending.target {
            topMsgVm.numberLabel.text = "\(pending.target)"
            return
        }
        topMsgVm.numberLabel.text = "\(pending.start)"
        topMsgVm.numberLabel.count(from: CGFloat(pending.start), to: CGFloat(pending.target), withDuration: 0.5)
    }

    private func isPointLabelVisible() -> Bool {
        guard let window = self.window else { return false }
        if isHidden || alpha == 0 || topMsgVm.isHidden || topMsgVm.alpha == 0 { return false }
        if scrollView.isHidden || scrollView.alpha == 0 { return false }

        let labelFrameInWindow = topMsgVm.numberLabel.convert(topMsgVm.numberLabel.bounds, to: window)
        guard window.bounds.intersects(labelFrameInWindow) else { return false }

        let labelFrameInScroll = topMsgVm.numberLabel.convert(topMsgVm.numberLabel.bounds, to: scrollView)
        return scrollView.bounds.intersects(labelFrameInScroll)
    }
}

extension HabitProgressVM: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        triggerPointAnimationIfNeeded()
    }
}
