//
//  NaturalShakeImageView.swift
//  lns
//
//  Created by LNS2 on 2026/1/22.
//
import UIKit

class NaturalDampedShakeImageView: UIImageView {

    /// 最大初始摇晃角度（弧度）
    var maxAngle: CGFloat = 8 * .pi / 180

    /// 摇晃总时长
    var totalDuration: TimeInterval = 1.6

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    override init(image: UIImage?) {
        super.init(image: image)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        contentMode = .scaleAspectFit
        clipsToBounds = false
    }

    /// 围绕“底部中心”旋转（不改 anchorPoint），并支持等比缩放
    func makeBottomPivotTransform(scale: CGFloat, angle: CGFloat) -> CGAffineTransform {
        // 注意：translate 会受到 scale 影响，所以用 bounds.height/2（未乘 scale）即可
        let h2 = bounds.height / 2

        var t = CGAffineTransform.identity
        t = t.scaledBy(x: scale, y: scale)
        t = t.translatedBy(x: 0, y: h2)
        t = t.rotated(by: angle)
        t = t.translatedBy(x: 0, y: -h2)
        return t
    }

    func apply(scale: CGFloat, angle: CGFloat) {
        transform = makeBottomPivotTransform(scale: scale, angle: angle)
    }

    /// UIKit Keyframes 阻尼摇晃：不会造成“结束后位置纠正”的闪烁/偏移
    func shakeThreeTimesAndStopUIKit(scale: CGFloat, completion: (() -> Void)? = nil) {
        // 从最终正确姿态开始
        transform = makeBottomPivotTransform(scale: scale, angle: 0)

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
                    self.transform = self.makeBottomPivotTransform(scale: scale, angle: angles[i + 1])
                }
            }
        } completion: { _ in
            self.transform = self.makeBottomPivotTransform(scale: scale, angle: 0)
            completion?()
        }
    }
}
