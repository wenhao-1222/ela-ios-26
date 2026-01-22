//
//  RankBadgeView.swift
//  lns
//
//  Created by LNS2 on 2026/1/22.
//

import UIKit

final class RankBadgeView: NaturalDampedShakeImageView {

    /// 当前等比缩放
    private(set) var currentScale: CGFloat = 1.0

    /// 进入时倾斜角（模拟加速惯性）
    var enterTiltAngle: CGFloat = 8 * .pi / 180

    func setScale(_ scale: CGFloat) {
        currentScale = scale
        apply(scale: scale, angle: 0)
    }

    func setTiltForEnter(_ enabled: Bool) {
        apply(scale: currentScale, angle: enabled ? enterTiltAngle : 0)
    }

    func shakeInPlace(completion: (() -> Void)? = nil) {
        shakeThreeTimesAndStopUIKit(scale: currentScale, completion: completion)
    }
    /// ✅ 在“保持倾斜”的基态上摇晃，摇完才回正
    func shakeKeepingTiltThenUpright(completion: (() -> Void)? = nil) {
        let baseAngle = enterTiltAngle // 保持倾斜作为基态
        shakeAround(baseAngle: baseAngle, scale: currentScale) {
            // 摇完回正
            self.apply(scale: self.currentScale, angle: 0)
            completion?()
        }
    }

    /// 在某个 baseAngle 上做阻尼摇晃（UIKit keyframes）
    private func shakeAround(baseAngle: CGFloat, scale: CGFloat, completion: (() -> Void)? = nil) {
        let a = maxAngle
        let angles: [CGFloat] = [
            0,
            -a,
            a * 0.75,
            -a * 0.45,
            a * 0.25,
            -a * 0.12,
            0
        ]

        // 从 baseAngle 开始（保持倾斜，不回正）
        transform = makeBottomPivotTransform(scale: scale, angle: baseAngle)

        UIView.animateKeyframes(
            withDuration: totalDuration,
            delay: 0,
            options: [.calculationModeCubic, .beginFromCurrentState]
        ) {
            let n = angles.count - 1
            for i in 0..<n {
                let start = Double(i) / Double(n)
                let dur = 1.0 / Double(n)
                UIView.addKeyframe(withRelativeStartTime: start, relativeDuration: dur) {
                    self.transform = self.makeBottomPivotTransform(scale: scale, angle: baseAngle + angles[i + 1])
                }
            }
        } completion: { _ in
            self.transform = self.makeBottomPivotTransform(scale: scale, angle: baseAngle)
            completion?()
        }
    }
}
