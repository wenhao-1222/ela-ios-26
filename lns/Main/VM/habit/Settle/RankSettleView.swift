//
//  RankSettleView.swift
//  lns
//
//  Created by LNS2 on 2026/1/22.
//

import UIKit

final class RankSettleView: UIView {

    private let minRank = 1
    private let maxRank = 9

    private let badgeSize = CGSize(width: 180, height: 260)

    /// 左右槽位相对中间的偏移（决定露出多少）
    private let sideOffset: CGFloat = kFitWidth(150)

    /// 中间缩放
    private let centerScale: CGFloat = 1.0

    /// 左右缩放（别太小，否则显得“太靠边/太挤”）
    private let sideScale: CGFloat = 0.7

    /// 进入动画时长
    private let slideDuration: TimeInterval = 0.55

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
        return y + badgeSize.height / 2
    }

    init(frame: CGRect, rankImages: [UIImage], currentRank: Int) {
        self.rankImages = rankImages
        self.currentRank = currentRank
        super.init(frame: frame)
        backgroundColor = .clear
        setupInitialRanks()
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

    // MARK: - 段位升级动画：四个一起动（oldLeft / oldCenter / oldRight / incomingRight）
    func playRankUpAnimation() {
        guard currentRank < maxRank,
              let oldRight = rightBadge else { return }

        let oldLeft = leftBadge
        let oldCenter = centerBadge

        // incomingRight：升级后新的右侧段位 = currentRank + 2
        let incomingRank = currentRank + 2
        var incomingRight: RankBadgeView? = nil
        if incomingRank <= maxRank {
            let img = rankImages[incomingRank - 1]
            incomingRight = makeBadge(image: img, centerX: incomingRightStartCX, scale: sideScale)
            incomingRight?.alpha = 1.0
            incomingRight?.setGrayscale(true)
        }

        // oldRight 在“从右到中”的过程中带一点倾斜（惯性）
        oldRight.setScale(sideScale)
        oldRight.setTiltForEnter(true)
//        oldRight.setGrayscale(true)
        
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
                oldRight.setTiltForEnter(true)

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

                oldRight.setGrayscale(false)
                oldRight.flashGlow {
                    
                }
                oldRight.shakeInPlace()
            }
        )
    }
}
//extension RankSettleView {
//
//    func playRankDownAnimation() {
//        guard currentRank > minRank else { return }
//
//        let oldLeft = leftBadge                // 将成为新中心
//        let oldCenter = centerBadge!           // 会碎裂并移到右侧
//        let oldRight = rightBadge              // 可能存在，推出
//
//        // 1) 先原地碎裂（中心）
//        var shatterCfg = RankDownShatterView.Config()
////        shatterCfg.maxPieceCount = 12
////        shatterCfg.duration = 0.45
//////        shatterCfg.burstUp = 100...160
//        shatterCfg.burstX = -40...40
////        shatterCfg.keepBaseRows = 1
//
//        // ✅ 关键：先声明，后赋值（避免闭包提前捕获）
//        var shatterView: RankDownShatterView?
//
//        shatterView = RankDownShatterView.play(on: oldCenter, in: self, config: shatterCfg) { [weak self] in
//            guard let self else { return }
//            guard let shatterView = shatterView else { return }
//
//            // 2) 碎裂完成后：整体向右移动，同时左->中，右->推出
//            UIView.animate(withDuration: self.slideDuration,
//                           delay: 0.25,
//                           options: [.curveEaseOut, .beginFromCurrentState],
//                           animations: {
//
//                // oldLeft -> 中心（放大）
//                if let oldLeft {
//                    oldLeft.center.x = self.centerSlotCX
//                    oldLeft.setScale(self.centerScale)
//                    oldLeft.alpha = 1
//                    oldLeft.setGrayscale(false)
//                }
//
//                // oldRight -> 更右推出并淡出
//                if let oldRight {
//                    oldRight.center.x = self.rightSlotCX + self.sideOffset
//                    oldRight.alpha = 0
//                }
//
//                // ✅ 碎裂整体 -> 右槽位（缩小）
//                shatterView.center.x = self.rightSlotCX
//                shatterView.transform = CGAffineTransform(scaleX: self.sideScale, y: self.sideScale)
//
//            }, completion: { _ in
//
//                // 清理推出的 oldRight
//                if let oldRight {
//                    oldRight.removeFromSuperview()
//                }
//
//                // oldCenter 已经被隐藏，直接移除（碎裂层替代显示）
//                oldCenter.removeFromSuperview()
//
//                // ✅ 更新 rank
//                self.currentRank -= 1
//
//                // ✅ 更新 center
//                if let oldLeft {
//                    self.centerBadge = oldLeft
//                }
//
//                // ✅ 更新 left（新的左 = currentRank-1）
//                // 先移除旧 left（oldLeft 已经变成 center，不移除）
//                // leftBadge 应该变为 “currentRank-1”，也就是 currentRank-2 索引
//                if self.currentRank > self.minRank {
//                    let img = self.rankImages[self.currentRank - 2]
//                    let newLeft = self.makeBadge(image: img, centerX: self.leftSlotCX, scale: self.sideScale)
//                    newLeft.alpha = 1
//                    self.leftBadge = newLeft
//                } else {
//                    self.leftBadge = nil
//                }
//                // ✅ 右侧只展示碎裂层：不创建可见的 rightBadge
//                if self.currentRank < self.maxRank {
//                    // 仍然创建一个“隐藏的逻辑 rightBadge”，确保后续升级动画有 oldRight 可用
//                    let img = self.rankImages[self.currentRank]  // currentRank+1
//                    let hiddenRight = self.makeBadge(image: img, centerX: self.rightSlotCX, scale: self.sideScale)
//                    hiddenRight.setGrayscale(true)
//                    hiddenRight.alpha = 0.0          // ✅ 不显示完整奖杯
//                    hiddenRight.isUserInteractionEnabled = false
//                    self.rightBadge = hiddenRight
//
//                    // 碎裂层盖在最上面
//                    self.bringSubviewToFront(shatterView)
//                } else {
//                    self.rightBadge = nil
//                }
//
//            })
//        }
//    }
//}
extension RankSettleView {

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
