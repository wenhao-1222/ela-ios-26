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
    var proteinIntakeOnTargetWithFriendFirstTimeRewardId = ""
    var proteinIntakeOnTargetWithFriendFirstTimePoint = ""
    private var pendingPointTarget: Int?
    private var deferPointAnimation = false
    private var shouldAnimatePointWhenVisible = false
    private var pendingStreakParabolaAction: (() -> Void)?
    private var pendingStreakSnapshotRestoreAction: (((() -> Void)?) -> Void)?
    private var pendingStreakFailureRestoreAction: (((() -> Void)?) -> Void)?
    private var shouldStartPendingStreakParabola = false
    
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
    override func layoutSubviews() {
        super.layoutSubviews()
        triggerPointAnimationIfNeeded()
    }
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.backgroundColor = .clear
        scro.delegate = self
        scro.showsVerticalScrollIndicator = false
        
        return scro
    }()
    lazy var animOverlayView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = false
        vi.clipsToBounds = true
        return vi
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
        vm.firstOnTargetVm.tapBlock = {()in
            DLLog(message: "proteinIntakeOnTargetWithFriendFirstTimeRewardId:\(self.proteinIntakeOnTargetWithFriendFirstTimeRewardId)   --- \(self.proteinIntakeOnTargetWithFriendFirstTimePoint)")
            self.deferPointAnimation = true
            DispatchQueue.main.asyncAfter(deadline: .now()+0.7, execute: {
                self.sendRecieveFriendProteinRequest()
            })
            self.playStreakReceiveAnimation(from: self.friendMsgVm.firstOnTargetVm,
                                            point: self.proteinIntakeOnTargetWithFriendFirstTimePoint) {
                self.deferPointAnimation = false
                self.triggerPointAnimationIfNeeded()
            }
            self.triggerPendingStreakParabolaIfNeeded(forceStart: true)
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
            self.playStreakReceiveAnimation(from: sourceVm, point: point)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.7, execute: {
                self.sendRecieveStreakRequest(streakId: streakId)
            })
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
        self.proteinIntakeOnTargetWithFriendFirstTimeRewardId = dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendFirstTimeRewardId")
        self.proteinIntakeOnTargetWithFriendFirstTimePoint = dict.stringValueForKey(key: "proteinIntakeOnTargetWithFriendFirstTimePoint")
//        self.topMsgVm.numberLabel.text = dict.stringValueForKey(key: "pointBalance")
//        if isCounting{
        let nextPointBalance = Int(dict.doubleValueForKey(key: "pointBalance").rounded())
        let previousPointBalance = lastNumber

        isCounting = false

        if previousPointBalance != nextPointBalance {
            pendingPointTarget = nextPointBalance
            if shouldAnimatePointWhenVisible || isPointLabelVisible() {
                triggerPointAnimationIfNeeded()
            }
        } else {
            pendingPointTarget = nil
            self.topMsgVm.numberLabel.text = "\(nextPointBalance)"
        }
        self.lastNumber = nextPointBalance//dict.stringValueForKey(key: "pointBalance").intValue
        self.todayMsgVm.updateUI(dict: dict)
        self.friendMsgVm.updateUI(dict: dict)
//        self.streakListVm.updateUI(listArray: dict["streakRewardList"]as? NSArray ?? [])
        let arr = [["streakRewardName":"测试连胜一",
                    "isClaimed":"0",
                    "streakRewardPoint":"14",
                    "streakRewardId":"2342342"],
                   ["streakRewardName":"测试连胜二",
                               "isClaimed":"0",
                               "streakRewardPoint":"88",
                               "streakRewardId":"2342wfwe342"]]
        self.streakListVm.updateUI(listArray: arr as NSArray)
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
        addSubview(animOverlayView)
        scrollView.addSubview(topMsgVm)
        scrollView.addSubview(todayMsgVm)
        scrollView.addSubview(friendMsgVm)
        scrollView.addSubview(streakMsgVm)
        scrollView.addSubview(streakListVm)
        
        scrollView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        animOverlayView.snp.makeConstraints { make in
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
    private func triggerPendingStreakParabolaIfNeeded(forceStart: Bool = false) {
        if forceStart {
            shouldStartPendingStreakParabola = true
        }
        guard shouldStartPendingStreakParabola,
              let action = pendingStreakParabolaAction else { return }
        pendingStreakParabolaAction = nil
        shouldStartPendingStreakParabola = false
        action()
    }

    private func restorePendingStreakSnapshotIfNeeded(completion: (() -> Void)? = nil) {
        guard let action = pendingStreakSnapshotRestoreAction else {
            completion?()
            return
        }
        pendingStreakSnapshotRestoreAction = nil
        action(completion)
    }

    private func restorePendingStreakFailureIfNeeded(completion: (() -> Void)? = nil) {
        guard let action = pendingStreakFailureRestoreAction else {
            completion?()
            return
        }
        pendingStreakFailureRestoreAction = nil
        action(completion)
    }

    func playStreakReceiveAnimation(from sourceView: UIView,
                                    point: String,
                                    completion: (() -> Void)? = nil) {
        shouldStartPendingStreakParabola = false
        pendingStreakParabolaAction = nil
        pendingStreakSnapshotRestoreAction = nil
        pendingStreakFailureRestoreAction = nil
        let containerView = animOverlayView
        let startFrame: CGRect
        let snapshotView: UIView
        weak var sourceButton: UIButton?
        if let item = sourceView as? HabitItemVM {
            let buttonFrame = item.showButton.convert(item.showButton.bounds, to: containerView)
            startFrame = buttonFrame
            snapshotView = item.showButton.snapshotView(afterScreenUpdates: false) ?? UIView()
            snapshotView.clipsToBounds = true
            snapshotView.layer.cornerRadius = kFitWidth(15)//item.showButton.layer.cornerRadius
            sourceButton = item.showButton
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                item.showButton.isHidden = true
            })
        } else {
            startFrame = sourceView.convert(sourceView.bounds, to: containerView)
            snapshotView = sourceView.snapshotView(afterScreenUpdates: false) ?? UIView()
        }
        let endFrame = topMsgVm.numberLabel.convert(topMsgVm.numberLabel.bounds, to: containerView)

        snapshotView.frame = startFrame
        snapshotView.layer.masksToBounds = true
        containerView.addSubview(snapshotView)

        let circleSize = startFrame.height//kFitWidth(48)
        let circleBounds = CGRect(x: 0, y: 0, width: circleSize, height: circleSize)
        let startCenter = CGPoint(x: startFrame.maxX - circleSize*0.5, y: startFrame.midY)
        let endCenter = CGPoint(x: endFrame.midX, y: endFrame.midY)

        let animateView = UIView(frame: CGRect.init(x: 0, y: 0, width: circleSize, height: circleSize))
        animateView.backgroundColor = .clear//.THEME
        animateView.layer.cornerRadius = circleSize*0.5
        animateView.isHidden = true
        containerView.addSubview(animateView)
        
        let pointLabel = UILabel()
        pointLabel.text = "+\(point)"
        pointLabel.textColor = .THEME//.white
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
                snapshotView.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
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
            self.pendingStreakSnapshotRestoreAction = { restoreCompletion in
                snapshotView.backgroundColor = .COLOR_BG_C4
                sourceButton?.setTitle("已领取", for: .normal)
                UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
                    snapshotView.transform = .identity
                    snapshotView.frame = startFrame
                    snapshotView.layer.cornerRadius = kFitWidth(15)
                } completion: { _ in
                    sourceButton?.backgroundColor = .COLOR_BG_C4
                    sourceButton?.setTitle("已领取", for: .normal)
                    sourceButton?.isEnabled = false
                    sourceButton?.isUserInteractionEnabled = false
                    sourceButton?.transform = .identity
                    sourceButton?.alpha = 1
                    sourceButton?.isHidden = false
                    snapshotView.removeFromSuperview()
                    restoreCompletion?()
                }
            }
            self.pendingStreakFailureRestoreAction = { restoreCompletion in
                UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
                    snapshotView.transform = .identity
                    snapshotView.frame = startFrame
                    snapshotView.layer.cornerRadius = kFitWidth(15)
                    snapshotView.backgroundColor = .THEME
                } completion: { _ in
                    sourceButton?.backgroundColor = .THEME
                    sourceButton?.setTitle("领取", for: .normal)
                    sourceButton?.isEnabled = true
                    sourceButton?.isUserInteractionEnabled = true
                    sourceButton?.transform = .identity
                    sourceButton?.alpha = 1
                    sourceButton?.isHidden = false
                    snapshotView.removeFromSuperview()
                    restoreCompletion?()
                }
            }
            self.pendingStreakParabolaAction = {
                self.playParabolaAnimation(view: animateView,
                                           sourceView: snapshotView,
                                           from: startCenter,
                                           to: endCenter,
                                           completion: completion)
            }
            self.triggerPendingStreakParabolaIfNeeded()
        })
    }

    private func playParabolaAnimation(view animView: UIView,
                                       sourceView : UIView,
                                       from startPoint: CGPoint,
                                       to endPoint: CGPoint,
                                       completion: (() -> Void)? = nil) {
        animView.center = sourceView.center
        animView.isHidden = false
        sourceView.isHidden = false//true
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
        scaleAnim.toValue = 0.5

        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1.0
        opacityAnim.toValue = 0.2

        let group = CAAnimationGroup()
        group.animations = [positionAnim, scaleAnim, opacityAnim]
        group.duration = 0.65
        group.timingFunction = CAMediaTimingFunction(name: .easeIn)

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            animView.removeFromSuperview()
            completion?()
        }
        animView.layer.add(group, forKey: "streakReceiveParabola")
        animView.layer.position = endPoint
        CATransaction.commit()
    }

    func triggerPointAnimationIfNeeded() {
        guard !deferPointAnimation else { return }
        guard let target = pendingPointTarget else { return }
        guard isPointLabelVisible() else { return }
        pendingPointTarget = nil

        let currentValue = currentPointLabelValue()
        if currentValue == target {
            shouldAnimatePointWhenVisible = false
            topMsgVm.numberLabel.text = "\(target)"
            return
        }
        shouldAnimatePointWhenVisible = false
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

extension HabitProgressVM{
    func sendRecieveStreakRequest(streakId:String) {
        let param = ["streakRewardId":streakId]

//        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
//            self.shouldStartPendingStreakParabola = true
//            self.triggerPendingStreakParabolaIfNeeded()
//            self.restorePendingStreakSnapshotIfNeeded {
//            }
//            self.shouldAnimatePointWhenVisible = true
//            self.refreshBlock?()
//        })

        WHNetworkUtil.shareManager().POST(urlString: URL_user_habit_claimStreakReward, parameters: param as [String:AnyObject]) { responseObject in
            let code = responseObject["code"]as? Int ?? -1
            if (code == 200) {
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")

                DLLog(message: "sendDataRequest:\(dataDict)")
                self.isCounting = true

    //            MCToast.mc_text("领取成功")
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    self.shouldStartPendingStreakParabola = true
                    self.triggerPendingStreakParabolaIfNeeded()
                    self.restorePendingStreakSnapshotIfNeeded {
                    }
                    self.shouldAnimatePointWhenVisible = true
                    self.refreshBlock?()
                })
            }else {
                MCToast.mc_text("领取失败")
                self.pendingStreakParabolaAction = nil
                self.shouldStartPendingStreakParabola = false
                self.restorePendingStreakFailureIfNeeded {
                }
            }
        } failure: { _ in
            self.pendingStreakParabolaAction = nil
            self.shouldStartPendingStreakParabola = false
            self.restorePendingStreakFailureIfNeeded {
            }
        }
    }
    func sendRecieveFriendProteinRequest() {
        let param = ["rewardId":self.proteinIntakeOnTargetWithFriendFirstTimeRewardId]
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
//            self.shouldStartPendingStreakParabola = true
//            self.triggerPendingStreakParabolaIfNeeded()
//            self.restorePendingStreakSnapshotIfNeeded {
//            }
//            self.shouldAnimatePointWhenVisible = true
//            self.refreshBlock?()
//        })
        WHNetworkUtil.shareManager().POST(urlString: URL_user_habit_claimFirstFriendGoalReward, parameters: param as [String:AnyObject]) { responseObject in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                self.shouldStartPendingStreakParabola = true
                self.triggerPendingStreakParabolaIfNeeded()
                self.restorePendingStreakSnapshotIfNeeded {
                }
                self.shouldAnimatePointWhenVisible = true
                self.refreshBlock?()
            })
        }
    }
}
