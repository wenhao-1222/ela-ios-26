//
//  RankSettleView.swift
//  lns
//
//  Created by LNS2 on 2026/1/22.
//

import UIKit
/// 让外部（HabitSettleVM）能拿到“奖杯底座接触点”的锚点
protocol CupBaseAnchorProviding: AnyObject {
    var cupBaseAnchorView: UIView { get }
}

final class RankSettleView: UIView {

    private let minRank = 1
    private let maxRank = 9

    private let badgeSize = CGSize(width: kFitWidth(220), height: kFitWidth(220))

    /// 左右槽位相对中间的偏移（决定露出多少）
    private let sideOffset: CGFloat = kFitWidth(150)

    /// 中间缩放
    private let centerScale: CGFloat = 1.0

    /// 左右缩放（别太小，否则显得“太靠边/太挤”）
    private let sideScale: CGFloat = 0.7

    /// 进入动画时长
    public let slideDuration: TimeInterval = 0.6

    private let rankImages: [UIImage]
    private var currentRank: Int // 1...9

    private var leftBadge: RankBadgeView?
    private var centerBadge: RankBadgeView!
    private var rightBadge: RankBadgeView?

    // MARK: - 槽位中心点（永远以 midX 为参考）
    private var centerSlotCX: CGFloat { bounds.midX }
    private var leftSlotCX: CGFloat { bounds.midX - sideOffset }
    private var rightSlotCX: CGFloat { bounds.midX + sideOffset }
    private var incomingRightStartCX: CGFloat { bounds.midX + sideOffset * 2 }

    private var badgeCenterY: CGFloat {
        let y = (bounds.height - badgeSize.height) / 2
        return y + badgeSize.height / 2 - kFitWidth(90)
    }
    private let confetti = RankUpConfetti3DView()

    private var rankUpAnimationPlayKey: Int = 0
    
    var animateCompletBlock:(()->())?
    
    // 四次喷射参数
    private let bursts: [(duration: TimeInterval, interval: TimeInterval, rate: Float)] = [
        (0.35, 0.50, 60),
        (0.30, 0.35, 90),
        (0.22, 0.25, 120),
        (0.15, 0.15, 140)
    ]
    // ✅ 新增：底座锚点（透明 view，用来给阴影和“贴桌面”对齐）
    public let cupBaseAnchorView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = false
        // v.backgroundColor = UIColor.red.withAlphaComponent(0.3) // 调试时可打开
        return v
    }()
    private let trophyContainerView = UIView() // 仅示例：你可能叫 cupView / cupImgView 等

    init(frame: CGRect, rankImages: [UIImage], currentRank: Int) {
        self.rankImages = rankImages
        self.currentRank = currentRank
        super.init(frame: frame)
        backgroundColor = .clear
        setupInitialRanks()
        initConfetti()
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - factory：固定 bounds，用 center 定位（transform 下稳定）
    private func makeBadge(image: UIImage, centerX: CGFloat, scale: CGFloat) -> RankBadgeView {
        let v = RankBadgeView(image: image)
        v.bounds = CGRect(origin: .zero, size: badgeSize)
        v.center = CGPoint(x: centerX, y: badgeCenterY)
        v.setScale(scale)
        addSubview(v)
        return v
    }

    private func setupInitialRanks() {
        subviews.forEach { $0.removeFromSuperview() }

        // left
        if currentRank > minRank {
            leftBadge = makeBadge(image: rankImages[currentRank - 2], centerX: leftSlotCX, scale: sideScale)
        } else {
            leftBadge = nil
        }

        // center
        centerBadge = makeBadge(image: rankImages[currentRank - 1], centerX: centerSlotCX, scale: centerScale)

        // right
        if currentRank < maxRank {
            rightBadge = makeBadge(image: rankImages[currentRank], centerX: rightSlotCX, scale: sideScale)
            rightBadge?.setGrayscale(true)
        } else {
            rightBadge = nil
        }
    }
    private func setupUI() {
        // ⚠️ 你原本 RankSettleView 的 UI 代码保留不动
        // 这里仅演示：确保 trophyContainerView 是“奖杯（含底座）所在的容器”
        addSubview(trophyContainerView)
        trophyContainerView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        trophyContainerView.addSubview(cupBaseAnchorView)
        // 如果你暂时拿不到底座 view，那么用 settleView 的“奖杯整体底部”先顶住：
        cupBaseAnchorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kFitWidth(120)) // ⚠️ 先用这个，之后你把它改成真正的底座接触点
            make.width.height.equalTo(2)
        }
    }
    func initConfetti() {
        confetti.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        confetti.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        confetti.layer.zPosition = 12345
        confetti.isUserInteractionEnabled = false
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getKeyWindow().addSubview(confetti)
        // 建议加到最顶层 overlay
//        addSubview(confetti)

        // 配置参数（对齐 Kotlin）
        var cfg = RankUpConfetti3DView.Config()
        cfg.enabledShapes = [.parallelogram]

        cfg.burstCount = 5
        cfg.burstIntervalMsList = [0, 500, 350, 200, 200]
        cfg.durationMs = 2500
        cfg.burstIntervalMs = 1000 // 兜底

        cfg.clearPreviousOnNewBurst = false

        cfg.particleCount = 70
        cfg.verticalRange = 0       // 0：不限制垂直范围（对齐 Kotlin 的 0f=>∞）
        cfg.horizontalRange = 2
        cfg.minParticleSize = 5
        cfg.maxParticleSize = 10

        cfg.originX = 0.5
        cfg.originY = 0.43
        cfg.spawnRadius = 80

        cfg.colors = [
            UIColor(red: 0x25/255, green: 0x63/255, blue: 0xEB/255, alpha: 1),
            UIColor(red: 0x43/255, green: 0x38/255, blue: 0xCA/255, alpha: 1),
            UIColor(red: 0x7C/255, green: 0x3A/255, blue: 0xED/255, alpha: 1),
            UIColor(red: 0x08/255, green: 0x91/255, blue: 0xB2/255, alpha: 1),
            UIColor(red: 0x0D/255, green: 0x94/255, blue: 0x88/255, alpha: 1),
            UIColor(red: 0xDB/255, green: 0x27/255, blue: 0x77/255, alpha: 1),
            UIColor(red: 0xEA/255, green: 0x58/255, blue: 0x0C/255, alpha: 1),
            UIColor(red: 0xD9/255, green: 0x77/255, blue: 0x06/255, alpha: 1),
            UIColor(red: 0x16/255, green: 0xA3/255, blue: 0x4A/255, alpha: 1),
            UIColor(red: 0x65/255, green: 0xA3/255, blue: 0x0D/255, alpha: 1),
        ]

        cfg.explodePower = 45 // 还高就 30；想更猛就 50
        cfg.explosionDirectionDeg = -90
        cfg.gravityPx = 1500
        cfg.windPx = 0
        cfg.randomSeed = 0 // 0:完全随机

        confetti.config = cfg
    }

    // MARK: - 段位升级动画：四个一起动（oldLeft / oldCenter / oldRight / incomingRight）
    func playFirstUnlockAnimation() {
        let originalTransform = centerBadge.transform
        centerBadge.alpha = 0.2
        centerBadge.transform = originalTransform.scaledBy(x: 0.85, y: 0.85)
        rankUpAnimationPlayKey += 1
        confetti.play(playKey: rankUpAnimationPlayKey) { [weak self] in
            self?.handleFinished()
        }
        UIView.animate(withDuration: 0.45,
                       delay: 0,
                       usingSpringWithDamping: 0.62,
                       initialSpringVelocity: 0.8,
                       options: [.curveEaseOut, .beginFromCurrentState]) {
            self.centerBadge.alpha = 1
            self.centerBadge.transform = originalTransform.scaledBy(x: 1.08, y: 1.08)
        } completion: { _ in
            UIView.animate(withDuration: 0.18,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState]) {
                self.centerBadge.transform = originalTransform
            }
        }
    }
    
    func playRankUpAnimation() {
        guard currentRank < maxRank,
              let oldRight = rightBadge else { return }

        let oldLeft = leftBadge
        let oldCenter = centerBadge
        let upgradedRank = currentRank + 1
        let upgradedImage = UIImage(named: "rank_\(upgradedRank)_reached")

        // incomingRight：升级后新的右侧段位 = currentRank + 2
        let incomingRank = currentRank + 2
        var incomingRight: RankBadgeView? = nil
        if incomingRank <= maxRank {
            let img = rankImages[incomingRank - 1]
            incomingRight = makeBadge(image: img, centerX: incomingRightStartCX, scale: sideScale)
            incomingRight?.alpha = 1.0
            incomingRight?.setGrayscale(true)
        }
        if let upgradedImage {
        let crossfadeDelay = slideDuration * 0.5
        let crossfadeDuration = slideDuration * 0.35
        DispatchQueue.main.asyncAfter(deadline: .now() + crossfadeDelay) { [weak oldRight] in
            guard let oldRight else { return }
            UIView.transition(
                with: oldRight,
                duration: crossfadeDuration,
                options: [.transitionCrossDissolve, .beginFromCurrentState]
            ) {
                oldRight.updateImage(upgradedImage, grayscale: false)
            }
        }
    }
        UIView.animate(
            withDuration: slideDuration,
            delay: 0,
            options: [.curveEaseOut, .beginFromCurrentState],
            animations: {
                // 1) oldLeft 向更左移出并淡出
                if let oldLeft {
                    oldLeft.center.x = self.leftSlotCX - self.sideOffset
                    oldLeft.alpha = 0.0
                }

                // 2) oldCenter -> 左槽位（缩小）
                oldCenter?.center.x = self.leftSlotCX
                oldCenter?.setScale(self.sideScale)
                oldCenter?.alpha = 1.0

                // 3) oldRight -> 中槽位（放大回正）
                oldRight.center.x = self.centerSlotCX
                oldRight.setScale(self.centerScale)
//                oldRight.setTiltForEnter(false)

                // 4) incomingRight -> 右槽位（跟随移动出现）
                if let incomingRight {
                    incomingRight.center.x = self.rightSlotCX
                    incomingRight.alpha = 1.0
                }

            }, completion: { _ in

                // 清理 oldLeft
                if let oldLeft {
                    oldLeft.removeFromSuperview()
                }

                // 更新状态
                self.currentRank += 1

                self.leftBadge = oldCenter
                self.centerBadge = oldRight
                self.rightBadge = incomingRight
                
                UIView.animate(withDuration: 0.7) {
                    self.leftBadge?.alpha = 0
                    self.rightBadge?.alpha = 0
                }

                oldRight.setGrayscale(false)
//                oldRight.flashGlow {
//                    
//                }
                
                // playKey 变化触发（对齐 Compose 的 playKey）
                self.rankUpAnimationPlayKey += 1
                DLLog(message: "动画播放 开始  ---   \(self.rankUpAnimationPlayKey)")
                self.confetti.play(playKey: self.rankUpAnimationPlayKey) { [weak self] in
                    // 对齐 Kotlin：onFinished -> onAnimationEvent(Finished)
                    self?.handleFinished()
                }
                
            }
        )
    }
    func currentRankBadgeView() -> RankBadgeView? {
       return centerBadge
   }
    
    private func handleFinished() {
        DLLog(message: "动画播放完毕")
        // ...
        self.animateCompletBlock?()
    }
}
extension RankSettleView {
    func playRankDownAnimation2() {
        guard currentRank > minRank else { return }

        let oldLeft = leftBadge                // 将成为新中心（rank-1）
        let oldCenter = centerBadge!           // 将渐变为 unlock 并移到右侧（rank）
        let oldRight = rightBadge              // 可能存在（rank+1），推出

        let newRank = currentRank - 1
        let incomingLeftRank = newRank - 1 // 需要显示在左槽位的段位
        var incomingLeft: RankBadgeView? = nil
        if incomingLeftRank >= minRank {
            let img = rankImages[incomingLeftRank - 1]
            let startCX = leftSlotCX - sideOffset
            incomingLeft = makeBadge(image: img, centerX: startCX, scale: sideScale)
            incomingLeft?.alpha = 1.0
            incomingLeft?.setGrayscale(false)
        }
        let unlockImage = UIImage(named: "rank_unlock")
        let crossfadeDuration: TimeInterval = slideDuration * 0.85//0.25
        
        UIView.transition(
            with: oldCenter,
            duration: crossfadeDuration,
            options: [.transitionCrossDissolve, .beginFromCurrentState]
        ) {
            oldCenter.updateImage(unlockImage, grayscale: false)
        } completion: { [weak self] _ in
            guard let self else { return }
            UIView.animate(withDuration: self.slideDuration,
                           delay: 0.25,
                           options: [.curveEaseOut, .beginFromCurrentState],
                           animations: {
                // 0) ✅ incomingLeft 同步移动到 left 槽位（一起出现）
                // incomingLeft 同步移动到 left 槽位
                incomingLeft?.center.x = self.leftSlotCX
                // oldLeft -> 中心（放大）
                if let oldLeft {
                    oldLeft.center.x = self.centerSlotCX
                    oldLeft.setScale(self.centerScale)
                    oldLeft.alpha = 1
                    oldLeft.setGrayscale(false)
                }
                
                // oldRight -> 更右推出并淡出
                if let oldRight {
                    oldRight.center.x = self.rightSlotCX + self.sideOffset
                    oldRight.alpha = 0
                }
                // oldCenter -> 右槽位（缩小）
                oldCenter.center.x = self.rightSlotCX
                oldCenter.setScale(self.sideScale)
                oldCenter.alpha = 1
            }, completion: { _ in
                if let oldRight {
                    oldRight.removeFromSuperview()
                }
                self.currentRank = newRank
                if let oldLeft {
                    self.centerBadge = oldLeft
                }
                self.leftBadge = incomingLeft
                self.rightBadge = oldCenter
                self.handleFinished()
            })
        }
    }
    func playRankDownAnimation() {
        guard currentRank > minRank else { return }

        let oldLeft = leftBadge                // 将成为新中心（rank-1）
        let oldCenter = centerBadge!           // 会碎裂并移到右侧（rank）
        let oldRight = rightBadge              // 可能存在（rank+1），推出

        // 1) 先原地碎裂（中心）
        var shatterCfg = RankDownShatterView.Config()
        shatterCfg.burstX = -40...40

        // ✅ 避免闭包提前捕获
        var shatterView: RankDownShatterView?

        shatterView = RankDownShatterView.play(on: oldCenter, in: self, config: shatterCfg) { [weak self] in
            guard let self else { return }
            guard let shatterView = shatterView else { return }

            // ✅ 碎裂后停留一下
            let holdAfterShatter: TimeInterval = 0.25

            // ✅ 关键：在“位移动画开始之前”就把 incomingLeft 创建出来
            // 降级后 newRank = currentRank - 1，新的左侧应为 newRank - 1 = currentRank - 2
            let newRank = self.currentRank - 1
            let incomingLeftRank = newRank - 1 // 需要显示在左槽位的段位

            var incomingLeft: RankBadgeView? = nil
            if incomingLeftRank >= self.minRank {
                let img = self.rankImages[incomingLeftRank - 1]
                // 从更左边进来（你也可以用 leftSlotCX - sideOffset * 1.2）
                let startCX = self.leftSlotCX - self.sideOffset
                incomingLeft = self.makeBadge(image: img, centerX: startCX, scale: self.sideScale)
                incomingLeft?.alpha = 1.0
                incomingLeft?.setGrayscale(false)
            }

            UIView.animate(withDuration: self.slideDuration,
                           delay: holdAfterShatter,
                           options: [.curveEaseOut, .beginFromCurrentState],
                           animations: {

                // 0) ✅ incomingLeft 同步移动到 left 槽位（一起出现）
                incomingLeft?.center.x = self.leftSlotCX

                // 1) oldLeft -> 中心（放大）
                if let oldLeft {
                    oldLeft.center.x = self.centerSlotCX
                    oldLeft.setScale(self.centerScale)
                    oldLeft.alpha = 1
                    oldLeft.setGrayscale(false)
                }

                // 2) oldRight -> 更右推出并淡出
                if let oldRight {
                    oldRight.center.x = self.rightSlotCX + self.sideOffset
                    oldRight.alpha = 0
                }

                // 3) ✅ 碎裂整体 -> 右槽位（缩小）
                shatterView.center.x = self.rightSlotCX
                shatterView.transform = CGAffineTransform(scaleX: self.sideScale, y: self.sideScale)

            }, completion: { _ in

                // 清理推出的 oldRight
                if let oldRight {
                    oldRight.removeFromSuperview()
                }

                // oldCenter 已隐藏，移除
                oldCenter.removeFromSuperview()

                // ✅ 更新 rank（此时才真正切换）
                self.currentRank = newRank

                // ✅ 更新 center：oldLeft 成为新的 center
                if let oldLeft {
                    self.centerBadge = oldLeft
                }

                // ✅ 更新 left：就是刚刚滑入的 incomingLeft（如果存在）
                self.leftBadge = incomingLeft

                // ✅ 右侧只展示碎裂层：仍创建隐藏 rightBadge 保逻辑
                if self.currentRank < self.maxRank {
                    let img = self.rankImages[self.currentRank]  // currentRank+1
                    let hiddenRight = self.makeBadge(image: img, centerX: self.rightSlotCX, scale: self.sideScale)
                    hiddenRight.setGrayscale(true)
                    hiddenRight.alpha = 0.0
                    hiddenRight.isUserInteractionEnabled = false
                    self.rightBadge = hiddenRight

                    // 碎裂层盖在最上面
                    self.bringSubviewToFront(shatterView)
                } else {
                    self.rightBadge = nil
                }
            })
        }
    }
}
