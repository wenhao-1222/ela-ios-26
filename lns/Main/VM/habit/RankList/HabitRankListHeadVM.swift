//
//  HabitRankListHeadVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/30.
//

class HabitRankListHeadVM: UIView {
    
    let selfHeight = kFitWidth(192) + kFitWidth(25)
    var timer: Timer?
    var remainSeconds = 3
    private var currentTierIndex: Int = 0
    private var unlockedTierIndex: Int = 0
    private var nextModeIsPromote: Bool = true
    private let rankTiers: [RankTier] = RankTier.defaultNine()
    private var isAnimatingToDemo: Bool = false
    private var isAnimatingBackFromDemo: Bool = false
    
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_F2
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var degreeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        
        return lab
    }()
    lazy var timeImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_rank_time_icon")
        
        return img
    }()
    lazy var timeCountLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "00:00:00"
        lab.alpha = 0
        return lab
    }()
    lazy var pointLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.font = .systemFont(ofSize: 13, weight: .semibold)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var rankImgView: UIImageView = {
        let vi = UIImageView()
        vi.setImgLocal(imgName: "rank_1")
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var rankImgViewDefault_one: UIImageView = {
        let vi = UIImageView()
        vi.setImgLocal(imgName: "rank_unlock")
        
        return vi
    }()
    lazy var rankImgViewDefault_two: UIImageView = {
        let vi = UIImageView()
        vi.setImgLocal(imgName: "rank_unlock")
        
        return vi
    }()
    lazy var rankImgViewDefault_three: UIImageView = {
        let vi = UIImageView()
        vi.setImgLocal(imgName: "rank_unlock")
        
        return vi
    }()
    lazy var bottomWhiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: selfHeight-kFitWidth(25), width: SCREEN_WIDHT, height: kFitWidth(50)))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
}

extension HabitRankListHeadVM{
    func updateUI(champion:String,runnerUp:String,thirdPlace:String,secondsToWeekEnd:Int) {
        degreeLabel.text = "青铜"

        let attr = NSMutableAttributedString(string: "周结算奖励：冠军 ", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50])
        attr.append(NSAttributedString(string: "+\(champion)", attributes: [.foregroundColor:UIColor.THEME]))
        attr.append(NSAttributedString(string: " 分｜亚军 ", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50]))
        attr.append(NSAttributedString(string: "+\(runnerUp)", attributes: [.foregroundColor:UIColor.THEME]))
        attr.append(NSAttributedString(string: " 分｜季军 ", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50]))
        attr.append(NSAttributedString(string: "+\(thirdPlace)", attributes: [.foregroundColor:UIColor.THEME]))
        attr.append(NSAttributedString(string: " 分", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50]))
        pointLabel.attributedText = attr
//        pointLabel.setLineHeight(attr: attr ,lineHeight: kFitWidth(20))
        
        remainSeconds = secondsToWeekEnd
        if remainSeconds > 0 && timer == nil{
            countDownAction()
        }
    }
    
    func updateDegree(tier:Int) {
        let fromIndex: Int = UserDefaults().getTierData().intValue
        
        DLLog(message: "updateDegree:\(tier)")
        guard fromIndex != tier,
        fromIndex > 0 else { return }
        DLLog(message: "updateDegree: ---  \(tier)")
        rankImgView.setImgLocal(imgName: "rank_\(tier)")
        currentTierIndex = max(0, min(rankTiers.count - 1, tier - 1))
        unlockedTierIndex = max(unlockedTierIndex, currentTierIndex)
        rankImgViewDefault_one.isHidden = tier == 9
        rankImgViewDefault_two.isHidden = tier >= 8
        rankImgViewDefault_three.isHidden = tier >= 7
    }
    private func updateRemainTimeLabel() {
        if remainSeconds <= 0 {
            timeCountLabel.text = "00:00:00"
//            remainTimeLabel.isHidden = true
            
            UIView.animate(withDuration: 0.25) {
                self.timeCountLabel.alpha = 0
            }
            self.timer?.invalidate()
            self.timer = nil
            return
        }
        
        let hours = remainSeconds / 3600
        let minutes = (remainSeconds % 3600) / 60
        let seconds = remainSeconds % 60
        if hours > 23 {
            let days = hours / 24
            timeCountLabel.text = "\(days)天"
        }else{
            timeCountLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        
        remainSeconds -= 1
        
        if self.timeCountLabel.alpha < 1{
            UIView.animate(withDuration: 0.5) {
                self.timeCountLabel.alpha = 1
            }
        }
    }
    func countDownAction() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.updateRemainTimeLabel()
        }
    }
}

extension HabitRankListHeadVM{
    func initUI() {
        addSubview(degreeLabel)
        addSubview(timeCountLabel)
        addSubview(timeImgView)
        addSubview(pointLabel)
        addSubview(rankImgView)
        addSubview(rankImgViewDefault_one)
        addSubview(rankImgViewDefault_two)
        addSubview(rankImgViewDefault_three)
        
        addSubview(bottomWhiteView)
        
        setConstrait()
        updateUI(champion: "3", runnerUp: "2", thirdPlace: "1", secondsToWeekEnd: -1)
        addGestureRecognizer()
    }
    func setConstrait() {
        degreeLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(23))
        }
        timeCountLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.centerY.lessThanOrEqualTo(degreeLabel)
        }
        timeImgView.snp.makeConstraints { make in
            make.right.equalTo(timeCountLabel.snp.left).offset(kFitWidth(-2))
            make.centerY.lessThanOrEqualTo(degreeLabel)
            make.width.height.equalTo(kFitWidth(15))
        }
        pointLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(49))
            make.height.equalTo(kFitWidth(20))
        }
        rankImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.width.height.equalTo(kFitWidth(90))
            make.top.equalTo(kFitWidth(81))
        }
        rankImgViewDefault_one.snp.makeConstraints { make in
            make.bottom.equalTo(rankImgView)
            make.width.height.equalTo(kFitWidth(70))
            make.left.equalTo(rankImgView.snp.right).offset(kFitWidth(17))
        }
        rankImgViewDefault_two.snp.makeConstraints { make in
            make.bottom.equalTo(rankImgView)
            make.width.height.equalTo(kFitWidth(70))
            make.left.equalTo(rankImgViewDefault_one.snp.right).offset(kFitWidth(12))
        }
        rankImgViewDefault_three.snp.makeConstraints { make in
            make.bottom.equalTo(rankImgView)
            make.width.height.equalTo(kFitWidth(70))
            make.left.equalTo(rankImgViewDefault_two.snp.right).offset(kFitWidth(12))
        }
    }
    private func addGestureRecognizer() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapRank))
//        rankImgView.addGestureRecognizer(tap)
    }
}
// MARK: - Animation bridge
extension HabitRankListHeadVM {
    @objc private func onTapRank() {
        guard !isAnimatingToDemo else { return }

        let mode: RankResultViewController.Mode = nextModeIsPromote ? .promote : .demote
        let toIndex: Int
        let fromIndex: Int

        if mode == .promote {
            fromIndex = currentTierIndex - 1
            toIndex = min(rankTiers.count - 1, currentTierIndex)
        } else {
            fromIndex = currentTierIndex  - 1
            toIndex = max(0, currentTierIndex)
        }

        guard fromIndex != toIndex else { return }
        nextModeIsPromote.toggle()
        currentTierIndex = toIndex
        unlockedTierIndex = max(unlockedTierIndex, currentTierIndex)

        playTransitionToDemo(mode: mode, fromIndex: fromIndex, toIndex: toIndex)
    }

    private func playTransitionToDemo(mode: RankResultViewController.Mode, fromIndex: Int, toIndex: Int) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.keyWindow else { return }
        isAnimatingToDemo = true

        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        window.addSubview(overlay)

        let snapshot = UIImageView(image: rankImgView.image)
        snapshot.contentMode = .scaleAspectFit
        snapshot.frame = rankImgView.convert(rankImgView.bounds, to: window)
        overlay.addSubview(snapshot)
        let demoVC = DemoViewController()
//       demoVC.configure(currentIndex: currentTierIndex, unlockedMaxIndex: unlockedTierIndex)
//       let preparedTargetFrame = targetBadgeFrame(in: window, using: demoVC)
        demoVC.configure(currentIndex: currentTierIndex, unlockedMaxIndex: unlockedTierIndex)
        let preparedTargetFrame = targetBadgeFrame(in: window, using: demoVC)

        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.curveEaseInOut]) {
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.15)
//            snapshot.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
//            snapshot.center = CGPoint(x: window.bounds.midX, y: window.bounds.midY)
//        if let targetFrame = preparedTargetFrame {
//            snapshot.frame = targetFrame
//        } else {
//            snapshot.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
//            snapshot.center = CGPoint(x: window.bounds.midX, y: window.bounds.midY)
//        }
            if let targetFrame = preparedTargetFrame {
                            snapshot.frame = targetFrame
                        } else {
                            snapshot.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                            snapshot.center = CGPoint(x: window.bounds.midX, y: window.bounds.midY)
                        }
        } completion: { _ in
            self.presentDemoPage(using: snapshot,
                                 overlay: overlay,
                                 mode: mode,
                                 fromIndex: fromIndex,
                                 toIndex: toIndex,
                                 demoVC: demoVC,
                                 preparedTargetFrame: preparedTargetFrame)
        }
    }

    private func presentDemoPage(using snapshot: UIImageView,
                                 overlay: UIView,
                                 mode: RankResultViewController.Mode,
                                 fromIndex: Int,
                                 toIndex: Int,
                                  demoVC: DemoViewController,
                                  preparedTargetFrame: CGRect?) {
        demoVC.modalPresentationStyle = .fullScreen
        demoVC.onRequestDismiss = { [weak self, weak demoVC] badgeFrame, badgeImage in
            guard let self, let demoVC else { return }
            self.animateBackToRank(from: badgeFrame, badgeImage: badgeImage, demoVC: demoVC)
        }

        let hostVC = WHTool.shared.getCurrentViewController()
        hostVC.present(demoVC, animated: false) {
            demoVC.view.layoutIfNeeded()
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.keyWindow else {
                overlay.removeFromSuperview()
                snapshot.removeFromSuperview()
                demoVC.play(mode: mode, fromIndex: fromIndex, toIndex: toIndex)
                self.isAnimatingToDemo = false
                return
            }
            let targetInWindow = preparedTargetFrame ?? {
                guard let targetFrame = demoVC.badgeFrame(in: demoVC.view) else { return nil }
                return demoVC.view.convert(targetFrame, to: window)
            }()

            guard let finalFrame = targetInWindow else {
                overlay.removeFromSuperview()
                snapshot.removeFromSuperview()
                demoVC.play(mode: mode, fromIndex: fromIndex, toIndex: toIndex)
                self.isAnimatingToDemo = false
                return
            }

            UIView.animate(withDuration: 0.15,
                           delay: 0,
                           options: [.curveEaseInOut]) {
                snapshot.transform = .identity
                snapshot.frame = finalFrame
                overlay.backgroundColor = .clear
            } completion: { _ in
                overlay.removeFromSuperview()
                snapshot.removeFromSuperview()
                demoVC.play(mode: mode, fromIndex: fromIndex, toIndex: toIndex)
                self.isAnimatingToDemo = false
            }
        }
    }
    private func animateBackToRank(from badgeFrame: CGRect, badgeImage: UIImage?, demoVC: DemoViewController) {
        guard !isAnimatingBackFromDemo else { return }
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.keyWindow else {
            demoVC.dismiss(animated: true)
            return
        }
        isAnimatingBackFromDemo = true

        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        window.addSubview(overlay)

        let snapshot = UIImageView(image: badgeImage ?? rankImgView.image)
        snapshot.contentMode = .scaleAspectFit
        snapshot.frame = badgeFrame
        overlay.addSubview(snapshot)

        demoVC.dismiss(animated: false) {
            let targetFrame = self.rankImgView.convert(self.rankImgView.bounds, to: window)
            UIView.animate(withDuration: 0.32,
                           delay: 0,
                           options: [.curveEaseInOut]) {
                overlay.backgroundColor = UIColor.black.withAlphaComponent(0.08)
                snapshot.frame = targetFrame
            } completion: { _ in
                overlay.removeFromSuperview()
                self.isAnimatingBackFromDemo = false
            }
        }
    }
    private func targetBadgeFrame(in window: UIWindow, using demoVC: DemoViewController) -> CGRect? {
       demoVC.loadViewIfNeeded()
       demoVC.view.frame = window.bounds
       demoVC.view.layoutIfNeeded()
       guard let targetFrame = demoVC.badgeFrame(in: demoVC.view) else { return nil }
       return demoVC.view.convert(targetFrame, to: window)
   }
}
