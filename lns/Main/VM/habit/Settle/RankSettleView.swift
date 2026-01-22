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
        }

        // oldRight 在“从右到中”的过程中带一点倾斜（惯性）
        oldRight.setScale(sideScale)
        oldRight.setTiltForEnter(true)

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

                // 主角摇晃：在最终正确位置上摇晃，不再做任何位置修正（不会闪、不会偏）
                oldRight.shakeInPlace()
//                oldRight.shakeKeepingTiltThenUpright()
            }
        )
    }
}
