//
//  HabitSettleVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/28.
//

import SnapKit
import UIKit

class HabitSettleVM: UIView {

    var hasData = false
    var currentRank = 1
    var tapCount = 0
    var tapBlock: (() -> Void)?
    weak var headCupVm: HabitRankListHeadCupVM?

    private var isAnimatingToHeadCup = false
    var displayedDataArray = NSArray()

    // MARK: - Layout Const
    /// 图一 settleView 缩放比例（你要求缩小显示）
    private let settleScale: CGFloat = 0.78

    /// 桌面“接触线”在 deskImgView 内的 y 偏移（从 deskImgView 顶部算）
    /// ✅ 这是唯一需要你微调的值，用来让奖杯底座贴在桌面上
    private let deskSurfaceOffsetY: CGFloat = kFitWidth(265)

    /// 图一 -> 图二 下移距离
    private let dropOffset: CGFloat = kFitWidth(90)

    // MARK: - Constraints ref
    private var deskTopC: Constraint?
    private var settleTopC: Constraint?

    /// 记录图一对齐后 settleTop 的“基准值”，图二就是 +dropOffset
    private var settleAlignedTop: CGFloat = 0
    private var deskBaseTop: CGFloat = 0

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .COLOR_CARD_BG_WHITE
        self.isUserInteractionEnabled = true
        self.alpha = 0
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Views
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_settle_bg_img")
        img.contentMode = .scaleAspectFit
        return img
    }()

    lazy var imgs: [UIImage] = {
        var imgT = [UIImage]()
        for i in 1...9 {
//            imgT.append(UIImage(named: "rank_\(i)")!)//rank_unlock
            if i > currentRank {
                imgT.append(UIImage(named: "rank_unlock")!)
            } else {
                imgT.append(UIImage(named: "rank_\(i)_reached")!)
            }
        }
        return imgT
    }()

    lazy var settleView: RankSettleView = {
        return RankSettleView(
            frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_WIDHT),
            rankImages: imgs,
            currentRank: self.currentRank
        )
    }()

    lazy var deskImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_settle_desk")
        img.contentMode = .scaleAspectFit
        return img
    }()

    /// ✅ 阴影：现在改为加到 settleView 内部，并约束到 settleView.cupBaseAnchorView
    private lazy var cupShadowImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_settle_cup_shadow")
//        img.alpha = 0.35
        img.isUserInteractionEnabled = false
//        img.backgroundColor = .THEME
        return img
    }()
    lazy var rankLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        
        return lab
    }()
    lazy var rankTipLabel: UILabel = {
        let lab = UILabel()
        lab.alpha = 0
        lab.text = "你晋升到了"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .regular)
        
        return lab
    }()
    lazy var pointLabel: UILabel = {
        let lab = UILabel()
        
        return lab
    }()
    lazy var currentCupNameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 28, weight: .semibold)
        lab.numberOfLines = 2
        lab.textAlignment = .center
        lab.lineBreakMode = .byWordWrapping
        lab.alpha = 0
        
        return lab
    }()
    lazy var cupLeftImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_settle_degree_left_icon")
        img.alpha = 0
        
        return img
    }()
    lazy var cupRightImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_settle_degree_right_icon")
        img.alpha = 0
        
        return img
    }()
    
    lazy var tableView: UITableView = {
        let vi = UITableView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(100)), style: .plain)
        vi.backgroundColor = .clear//.COLOR_BG_F2
//        vi.layer.borderWidth = kFitWidth(1)
//        vi.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_10.cgColor
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.contentInsetAdjustmentBehavior = .never
        vi.estimatedRowHeight = 0
        vi.estimatedSectionHeaderHeight = 0
        vi.estimatedSectionFooterHeight = 0
        vi.sectionHeaderHeight = 0

        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        vi.register(HabitRankTableViewCell.classForCoder(), forCellReuseIdentifier: HabitRankTableViewCell.identifier)
        
        return vi
    }()
    lazy var tableViewBgImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_settle_list_bg")
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.setTitle("继续", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_WHITE, for: .normal)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        
        return btn
    }()
}

extension HabitSettleVM{
    @objc func tapAction() {
        self.confirmButton.isUserInteractionEnabled = false
        if self.tapCount == 0 {
            animateDownFromRankToTier {
                self.startAnimation()
            }
        }else{
            guard !isAnimatingToHeadCup else { return }
           isAnimatingToHeadCup = true
            UIView.animate(withDuration: 0.1) {
                self.cupShadowImgView.alpha = 0
            }
           animateRankIconToHeadCup { [weak self] in
               guard let self else { return }
               self.isAnimatingToHeadCup = false
//               self.confirmButton.isUserInteractionEnabled = true
//               self.tapBlock?()
           }
        }
        tapCount += 1
    }
}

// MARK: - UI
extension HabitSettleVM {
    func initUI() {
        addSubview(bgImgView)
        addSubview(deskImgView)
        addSubview(confirmButton)
        addSubview(tableViewBgImg)
        addSubview(tableView)
        addSubview(rankLabel)
        addSubview(rankTipLabel)
        addSubview(pointLabel)
        addSubview(currentCupNameLabel)
        addSubview(cupLeftImgView)
        addSubview(cupRightImgView)

        setConstrait()
    }

    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }

        deskImgView.snp.makeConstraints { make in
            deskTopC = make.top.equalToSuperview().offset(deskBaseTop).constraint
            make.left.right.equalToSuperview()
            make.height.equalTo(SCREEN_WIDHT + WHUtils().getTopSafeAreaHeight())
        }
        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(5))
        }
    }
    func udpateConstrait() {
        rankLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(cupShadowImgView.snp.bottom).offset(kFitWidth(22))
        }
        rankTipLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(cupShadowImgView.snp.bottom).offset(kFitWidth(22))
        }
        pointLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(rankLabel.snp.bottom).offset(kFitWidth(22))
        }
        currentCupNameLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(rankLabel.snp.bottom).offset(kFitWidth(22))
        }
        cupLeftImgView.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(currentCupNameLabel)
            make.width.equalTo(kFitWidth(20))
            make.height.equalTo(kFitWidth(38.5))
            make.right.equalTo(currentCupNameLabel.snp.left).offset(kFitWidth(-19))
        }
        cupRightImgView.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(currentCupNameLabel)
            make.width.height.equalTo(cupLeftImgView)
            make.left.equalTo(currentCupNameLabel.snp.right).offset(kFitWidth(19))
        }
        tableView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(28))
            make.right.equalTo(kFitWidth(-28))
            make.top.equalTo(pointLabel.snp.bottom).offset(kFitWidth(30))
//            make.bottom.equalTo(confirmButton.snp.top).offset(kFitWidth(-20))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(74))
        }
        tableViewBgImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(25))
            make.right.equalTo(kFitWidth(-25))
            make.top.equalTo(pointLabel.snp.bottom).offset(kFitWidth(30))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(74))
        }
//        tableViewBgImg.snp.makeConstraints { make in
////            make.left.top.width.height.equalTo(tableView)
//            make.center.lessThanOrEqualTo(tableView)
//            make.width.height.equalTo(tableView.snp.width).offset(kFitWidth(6))
//        }
    }
}

// MARK: - Public Update
extension HabitSettleVM {
    /// 图一初始化（缩放+贴桌面+阴影绑定到底座）
    func updateCurrentTier(tier: Int, sn: Int, point: String, rankList: NSArray) {
        self.hasData = true
        self.currentRank = tier
        self.displayedDataArray = rankList
        self.tableView.reloadData()
        
        let newIndex = self.indexOfCurrentUser(in: self.displayedDataArray)
        if newIndex ?? 0 > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: newIndex!, section: 0), at: .middle, animated: false)
        }
        self.updateRankAndPointAttr(sn: sn, point: point)
        self.currentCupNameLabel.text = "纸浆杯"
        // settleView 只 add 一次
        if settleView.superview == nil {
            addSubview(settleView)
            settleView.animateCompletBlock = {()in
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    UIView.animate(withDuration: 0.25) {
                        self.confirmButton.alpha = 1
                    }
                    self.confirmButton.isUserInteractionEnabled = true
                }
            }

            settleView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                // 先给一个初始 top（后面会自动对齐到桌面）
                settleTopC = make.top.equalToSuperview().offset(WHUtils().getTopSafeAreaHeight()).constraint
                make.width.height.equalTo(SCREEN_WIDHT)
            }

            // ✅ 阴影加到 settleView 内部，绑定 settleView.cupBaseAnchorView
            installShadowInsideSettleView()

            // 层级：桌子在下，奖杯在上（阴影在 settleView 内部）
            bringSubviewToFront(deskImgView)
            bringSubviewToFront(settleView)
        }

        // 图一缩放
        settleView.transform = CGAffineTransform(scaleX: settleScale, y: settleScale)

        // 先布局一次，保证 settleView 内部 anchor 有 frame
        layoutIfNeeded()
        settleView.layoutIfNeeded()

        // ✅ 让“奖杯底座 anchor”贴到桌面线
        alignCupBaseToDeskSurface(animated: false)
    }
    
//    func animateDownFromRankToTier(completion: (() -> Void)? = nil) {
//        guard !isAnimatingToHeadCup else { return }
//        isAnimatingToHeadCup = true
//
//        // desk 下移
//        deskTopC?.update(offset: deskBaseTop + dropOffset)
//
//        // settleView 下移（基于对齐后的 top）
//        settleTopC?.update(offset: settleAlignedTop + dropOffset)
//
//        UIView.animate(
//            withDuration: 0.75,
//            delay: 0,
//            options: [.curveEaseInOut]
//        ) {
//            // ✅ 关键：恢复到正常尺寸
//            self.settleView.transform = .identity
//            self.confirmButton.alpha = 0
//            self.rankLabel.alpha = 0
//            self.pointLabel.alpha = 0
//            self.tableView.alpha = 0
//            self.tableViewBgImg.alpha = 0
//
//            // 同步执行约束动画
//            self.layoutIfNeeded()
//        } completion: { _ in
//            self.isAnimatingToHeadCup = false
//            completion?()
//        }
//    }
    func animateDownFromRankToTier(completion: (() -> Void)? = nil) {
        guard !isAnimatingToHeadCup else { return }
        isAnimatingToHeadCup = true

        deskTopC?.update(offset: deskBaseTop + dropOffset)
        settleTopC?.update(offset: settleAlignedTop + dropOffset)

        UIView.animateKeyframes(
            withDuration: 0.75,
            delay: 0,
            options: [.calculationModeCubic]
        ) {
            // 0% ~ 85%：主运动（更快到位）
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.85) {
                self.settleView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02) // 可选：稍微“冲一下”
                self.confirmButton.alpha = 0
                self.rankLabel.alpha = 0
                self.pointLabel.alpha = 0
                self.tableView.alpha = 0
                self.tableViewBgImg.alpha = 0
                self.layoutIfNeeded()
            }

            // 85% ~ 100%：刹车段（轻微反向再回正）
            UIView.addKeyframe(withRelativeStartTime: 0.85, relativeDuration: 0.15) {
                self.settleView.transform = .identity
                self.layoutIfNeeded()
            }
        } completion: { _ in
            self.isAnimatingToHeadCup = false
            completion?()
        }
    }

    private func animateRankIconToHeadCup(completion: @escaping () -> Void) {
        guard let headCupVm,
              let targetImageView = headCupVm.currentTierBadgeView(),
              let sourceBadge = settleView.currentRankBadgeView(),
              let sourceImage = sourceBadge.image,
              let window = self.window else {
            completion()
            return
        }

        window.layoutIfNeeded()
        headCupVm.layoutIfNeeded()
        settleView.layoutIfNeeded()
        targetImageView.layoutIfNeeded()
        sourceBadge.layoutIfNeeded()

        let startFrame = sourceBadge.convert(sourceBadge.bounds, to: window)
        let endFrame = targetImageView.convert(targetImageView.bounds, to: window)
        let movingImageView = UIImageView(image: sourceImage)
        movingImageView.contentMode = .scaleAspectFit
        movingImageView.frame = startFrame
        window.addSubview(movingImageView)

        let targetAlpha = targetImageView.alpha
        targetImageView.alpha = 0
        sourceBadge.alpha = 0
        UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseInOut]) {
            movingImageView.frame = endFrame
            movingImageView.alpha = 0.9
            self.alpha = 0
        } completion: { _ in
            targetImageView.alpha = targetAlpha
            movingImageView.removeFromSuperview()
            completion()
        }
    }
    func startAnimation() {
        let isRankUp = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if isRankUp{
                //段位上升
                self.settleView.playRankUpAnimation()
            }else{
                //段位下降
//                    self.settleView.playRankDownAnimation()
                self.settleView.playRankDownAnimation2()
            }
            UIView.animate(withDuration: 0.08) {
                self.cupShadowImgView.alpha = 0
            }
        }
        let dealyTime = isRankUp ? 0.5 : 1.5
        DispatchQueue.main.asyncAfter(deadline: .now() + dealyTime) {
            UIView.animate(withDuration: 0.15) {
                self.cupShadowImgView.alpha = 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            UIView.animate(withDuration: 0.25) {
                self.rankTipLabel.alpha = 1
                self.currentCupNameLabel.alpha = 1
                self.cupLeftImgView.alpha = 1
                self.cupRightImgView.alpha = 1
            }
        }
    }
    ///排名  +   积分
    func updateRankAndPointAttr(sn:Int,point:String) {
        let attr = NSMutableAttributedString(string: "您上周排名第 ", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214,
                       .font:UIFont.systemFont(ofSize: 21, weight: .medium)])
        attr.append(NSAttributedString(string: "\(sn) ", attributes: [.foregroundColor:UIColor.THEME,
                                                                     .font:UIFont().DDInFontBold(fontSize: 26)]))
        attr.append(NSAttributedString(string: "位", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214,
                         .font:UIFont.systemFont(ofSize: 21, weight: .medium)]))
        
        self.rankLabel.attributedText = attr
        
        let pointAttr = NSMutableAttributedString(string: "+", attributes: [.foregroundColor:UIColor.THEME,
                                                                            .font:UIFont().DDInFontSemiBold(fontSize: 40)])
        pointAttr.append(NSAttributedString(string: "\(point)", attributes: [.foregroundColor:UIColor.THEME,
                                                                          .font:UIFont().DDInFontBold(fontSize: 45)]))
        pointAttr.append(NSAttributedString(string: "积分", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
                                                                      .font:UIFont.systemFont(ofSize: 12, weight: .regular)]))
        pointLabel.attributedText = pointAttr
    }
}

// MARK: - Shadow bind & Align
extension HabitSettleVM {
    /// ✅ 阴影在 settleView 内部，绑定到底座 anchor
    private func installShadowInsideSettleView() {
        // 防止重复添加
        if cupShadowImgView.superview != nil { return }

        // 让阴影在 settleView 内容的底层（避免盖住奖杯）
        settleView.insertSubview(cupShadowImgView, at: 0)

        // 关键：cupBaseAnchorView 来自 RankSettleView（你已按上面改法加了）
        // 阴影紧贴底座接触点下方
        cupShadowImgView.snp.makeConstraints { make in
            make.centerX.equalTo(settleView.cupBaseAnchorView.snp.centerX)
            make.top.equalTo(settleView.cupBaseAnchorView.snp.bottom).offset(kFitWidth(-70))
            make.width.equalTo(kFitWidth(222)*0.6)
            make.height.equalTo(kFitWidth(34))
        }
        udpateConstrait()
    }

    /// ✅ 把 settleView 的“底座 anchor”对齐到 desk 的桌面线
    private func alignCupBaseToDeskSurface(animated: Bool) {
        guard let settleTopC = self.settleTopC else { return }

        // desk 桌面线的绝对 y
        let deskSurfaceY = deskImgView.frame.minY + deskSurfaceOffsetY

        // 底座 anchor 在 HabitSettleVM 里的绝对 y
        let anchorRect = settleView.cupBaseAnchorView.convert(settleView.cupBaseAnchorView.bounds, to: self)
        let anchorY = anchorRect.midY

        // 需要把 settleView 整体上下挪多少，才能让 anchorY == deskSurfaceY
        let delta = deskSurfaceY - anchorY

        // 当前 settleTop offset（从约束里拿不到数值就用记录值）
        // 这里直接用“当前 frame”反推更稳
        let currentTop = settleView.frame.minY
        let newTop = currentTop + delta

        // 更新约束并记录“对齐后的基准 top”
        self.settleAlignedTop = newTop
        settleTopC.update(offset: newTop)

        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState]) {
                self.layoutIfNeeded()
            }
        } else {
            self.layoutIfNeeded()
        }
    }
}

extension HabitSettleVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedDataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                withIdentifier: HabitRankTableViewCell.identifier,
                for: indexPath
            ) as! HabitRankTableViewCell
        cell.isHidden = false        // ✅ 复位，避免复用导致隐藏
        cell.alpha = 1               // ✅ 保险一点
        cell.contentView.alpha = 1
        
        let dict = displayedDataArray[indexPath.row] as? NSDictionary ?? [:]
        
        cell.configure(
            rank: "\(indexPath.row + 1)",
            avatar: dict.stringValueForKey(key: "headimgurl"),
            name: dict.stringValueForKey(key: "nickname"),
            fireCount: dict.stringValueForKey(key: "donateCount").intValue,
            score: dict.stringValueForKey(key: "rankPointBalance"),
            isCurrentUser: isCurrentUser(dict)
        )
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(70)
    }
    private func indexOfCurrentUser(in leaderboard: NSArray) -> Int? {
        let uid = UserDefaults.standard.value(forKey: userId) as? String ?? ""
        guard !uid.isEmpty else { return nil }

        for (index, element) in leaderboard.enumerated() {
            guard let dict = element as? NSDictionary else { continue }
            let elementId = extractUserId(from: dict)
            if !elementId.isEmpty && elementId == uid {
                return index
            }
        }

        return nil
    }
    private func isCurrentUser(_ dict: NSDictionary) -> Bool {
        let uid = UserDefaults.standard.value(forKey: userId) as? String ?? ""
        guard !uid.isEmpty else { return false }
        let elementId = extractUserId(from: dict)
        return !elementId.isEmpty && elementId == uid
    }
    private func extractUserId(from dict: NSDictionary) -> String {
        if let uid = dict["uid"] as? String, !uid.isEmpty {
            return uid
        }
        if let uid = dict["userId"] as? String, !uid.isEmpty {
            return uid
        }
        if let uid = dict["user_id"] as? String, !uid.isEmpty {
            return uid
        }
        if let uid = dict["id"] as? String, !uid.isEmpty {
            return uid
        }

        return dict.stringValueForKey(key: "uid")
    }
}
