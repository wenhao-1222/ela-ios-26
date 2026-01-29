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
            imgT.append(UIImage(named: "rank_\(i)")!)//rank_unlock
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
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(4)
        btn.clipsToBounds = true
        btn.setTitle("继续", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_WHITE, for: .normal)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        
        return btn
    }()

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
}

extension HabitSettleVM{
    @objc func tapAction() {
        animateDownFromRankToTier {
            
        }
    }
}

// MARK: - UI
extension HabitSettleVM {
    func initUI() {
        addSubview(bgImgView)
        addSubview(deskImgView)
        addSubview(confirmButton)

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
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }
    }
}

// MARK: - Public Update
extension HabitSettleVM {

    /// 图一初始化（缩放+贴桌面+阴影绑定到底座）
    func updateCurrentTier(tier: Int, sn: Int, point: String, rankList: NSArray) {
        self.hasData = true
        self.currentRank = tier
        self.displayedDataArray = rankList

        // settleView 只 add 一次
        if settleView.superview == nil {
            addSubview(settleView)

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

    /// 图一 -> 图二：桌子和奖杯同步下移（阴影跟随奖杯无需单独动）
//    func animateDownFromRankToTier(completion: (() -> Void)? = nil) {
//        guard !isAnimatingToHeadCup else { return }
//        isAnimatingToHeadCup = true
//
//        // desk 下移
//        deskTopC?.update(offset: deskBaseTop + dropOffset)
//
//        // settleView 下移：用“已对齐后的基准 top”再 +dropOffset
//        settleTopC?.update(offset: settleAlignedTop + dropOffset)
//
//        UIView.animate(withDuration: 0.45,
//                       delay: 0,
//                       options: [.curveEaseInOut, .beginFromCurrentState]) {
//            self.layoutIfNeeded()
//        } completion: { _ in
//            self.isAnimatingToHeadCup = false
//            completion?()
//        }
//    }
    func animateDownFromRankToTier(completion: (() -> Void)? = nil) {
        guard !isAnimatingToHeadCup else { return }
        isAnimatingToHeadCup = true

        // desk 下移
        deskTopC?.update(offset: deskBaseTop + dropOffset)

        // settleView 下移（基于对齐后的 top）
        settleTopC?.update(offset: settleAlignedTop + dropOffset)

        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState]
        ) {
            // ✅ 关键：恢复到正常尺寸
            self.settleView.transform = .identity

            // 同步执行约束动画
            self.layoutIfNeeded()
        } completion: { _ in
            self.isAnimatingToHeadCup = false
            completion?()
        }
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
