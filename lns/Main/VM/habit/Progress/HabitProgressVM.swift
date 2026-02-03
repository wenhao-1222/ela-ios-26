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
    private var pendingPointTarget: Int?
    
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
        scro.showsVerticalScrollIndicator = false
        
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
        vm.recieveBlock = {(streakId, sourceVm, point)in
            self.sendRecieveStreakRequest(streakId: streakId)
            self.playStreakReceiveAnimation(from: sourceVm, point: point)
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
    func updateUI(dict:NSDictionary,isAnimate:Bool=false) {
//        self.topMsgVm.numberLabel.text = dict.stringValueForKey(key: "pointBalance")
//        if isCounting{
        let nextPointBalance = Int(dict.doubleValueForKey(key: "pointBalance").rounded())
        let previousPointBalance = lastNumber

        isCounting = false

        if previousPointBalance != nextPointBalance {
            pendingPointTarget = nextPointBalance
            if isPointLabelVisible() {
                triggerPointAnimationIfNeeded()
            }
        } else {
            pendingPointTarget = nil
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
            
//            MCToast.mc_text("领取成功")
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.refreshBlock?()
            })
        }
    }
}

extension HabitProgressVM{
    func playStreakReceiveAnimation(from sourceView: UIView, point: String) {
        guard let window = self.window else { return }
        let startFrame = sourceView.convert(sourceView.bounds, to: window)
        let endFrame = topMsgVm.numberLabel.convert(topMsgVm.numberLabel.bounds, to: window)

        let snapshotView = sourceView.snapshotView(afterScreenUpdates: false) ?? UIView()
        snapshotView.frame = startFrame
        snapshotView.layer.masksToBounds = true
        window.addSubview(snapshotView)

        let circleSize = kFitWidth(48)
        let circleBounds = CGRect(x: 0, y: 0, width: circleSize, height: circleSize)
        let startCenter = CGPoint(x: startFrame.midX, y: startFrame.midY)
        let endCenter = CGPoint(x: endFrame.midX, y: endFrame.midY)

        let animateView = UIView(frame: CGRect.init(x: 0, y: 0, width: circleSize, height: circleSize))
        animateView.backgroundColor = .THEME
        animateView.layer.cornerRadius = circleSize*0.5
        animateView.isHidden = true
        window.addSubview(animateView)
        
        let pointLabel = UILabel()
        pointLabel.text = "+\(point)"
        pointLabel.textColor = .white
        pointLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        pointLabel.textAlignment = .center
        pointLabel.adjustsFontSizeToFitWidth = true
        pointLabel.minimumScaleFactor = 0.6
//        pointLabel.isHidden = true
//        snapshotView.addSubview(pointLabel)
        animateView.addSubview(pointLabel)
        pointLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(kFitWidth(4))
        }

        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.35) {
                snapshotView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.35, relativeDuration: 0.65) {
                snapshotView.transform = .identity
                snapshotView.bounds = circleBounds
                snapshotView.center = startCenter
                snapshotView.layer.cornerRadius = circleSize * 0.5
                snapshotView.backgroundColor = .THEME
            }
        }, completion: { _ in
            snapshotView.subviews.forEach { subview in
                if subview !== pointLabel {
                    subview.removeFromSuperview()
                }
            }
            pointLabel.isHidden = false
            snapshotView.backgroundColor = .clear
            snapshotView.layer.cornerRadius = 0
            snapshotView.clipsToBounds = false
            self.playParabolaAnimation(view: animateView,
                                       sourceView: snapshotView,
                                       from: startCenter,
                                       to: endCenter)
        })
    }

    private func playParabolaAnimation(view animView: UIView,
                                       sourceView : UIView,
                                       from startPoint: CGPoint,
                                       to endPoint: CGPoint) {
        animView.center = sourceView.center
        animView.isHidden = false
        sourceView.isHidden = true
        let midX = (startPoint.x + endPoint.x) * 0.5
        let controlPoint = CGPoint(x: midX, y: min(startPoint.y, endPoint.y) - kFitWidth(120))

        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addQuadCurve(to: endPoint, controlPoint: controlPoint)

        let positionAnim = CAKeyframeAnimation(keyPath: "position")
        positionAnim.path = path.cgPath
        positionAnim.rotationMode = .rotateAuto

        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 1.0
        scaleAnim.toValue = 0.3

        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1.0
        opacityAnim.toValue = 0.2

        let group = CAAnimationGroup()
        group.animations = [positionAnim, scaleAnim, opacityAnim]
        group.duration = 1
        group.timingFunction = CAMediaTimingFunction(name: .easeIn)

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            animView.removeFromSuperview()
        }
        animView.layer.add(group, forKey: "streakReceiveParabola")
        animView.layer.position = endPoint
        CATransaction.commit()
    }

    func triggerPointAnimationIfNeeded() {
        guard let target = pendingPointTarget else { return }
        guard isPointLabelVisible() else { return }
        pendingPointTarget = nil

        let currentValue = currentPointLabelValue()
        if currentValue == target {
            topMsgVm.numberLabel.text = "\(target)"
            return
        }
        topMsgVm.numberLabel.count(from: CGFloat(currentValue), to: CGFloat(target), withDuration: 0.5)
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

    private func currentPointLabelValue() -> Int {
        if let text = topMsgVm.numberLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           let value = Int(text) {
            return value
        }
        return topMsgVm.numberLabel.text?.intValue ?? 0
//        return Int(topMsgVm.numberLabel.text)
    }
}

extension HabitProgressVM: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        triggerPointAnimationIfNeeded()
    }
}
