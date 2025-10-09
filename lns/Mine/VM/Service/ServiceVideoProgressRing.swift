//
//  ServiceVideoProgressRing.swift
//  lns
//
//  Created by Elavatine on 2025/9/25.
//

import UIKit

final class ServiceVideoProgressRing: UIControl {
    enum DisplayState {
        case hidden
        case preparing
        case uploading(progress: CGFloat)
        case paused(progress: CGFloat)
        case failed(progress: CGFloat)
    }

    private let backgroundLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let centerLabel = UILabel()
    private let progressAnimationKey = "ServiceVideoProgressRing.strokeEndAnimation"
    private let lineWidth: CGFloat = 4
    private var lastState: DisplayState?
    private var currentProgress: CGFloat = 0

    var displayState: DisplayState = .hidden {
        didSet {
            updateAppearance()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 52, height: 52)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        updatePaths()
    }

    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.55)
        clipsToBounds = true

        backgroundLayer.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = lineWidth
        layer.addSublayer(backgroundLayer)

        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)

        centerLabel.textColor = .white
        centerLabel.font = .systemFont(ofSize: 12, weight: .medium)
        centerLabel.textAlignment = .center
        centerLabel.adjustsFontSizeToFitWidth = true
        addSubview(centerLabel)
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7)
        ])

        updateAppearance()
    }

    private func updatePaths() {
        let radius = max(0, min(bounds.width, bounds.height) / 2 - lineWidth / 2)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: -.pi / 2,
                                endAngle: .pi * 1.5,
                                clockwise: true)
        backgroundLayer.frame = bounds
        backgroundLayer.path = path.cgPath
        progressLayer.frame = bounds
        progressLayer.path = path.cgPath
    }

    private func updateAppearance() {
        if String(describing: lastState) != String(describing: displayState) {
            switch displayState {
            case .hidden:
                isHidden = true
                isUserInteractionEnabled = false
                centerLabel.text = nil
                progressLayer.strokeEnd = 0
            case .preparing:
                isHidden = false
                isUserInteractionEnabled = false
                currentProgress = 0
                progressLayer.strokeEnd = 0
                centerLabel.text = "准备"
            case .uploading(let progress):
                isHidden = false
                isUserInteractionEnabled = true
                updateProgress(progress)
                centerLabel.text = String(format: "%.0f%%", currentProgress * 100)
            case .paused(let progress):
                isHidden = false
                isUserInteractionEnabled = true
                updateProgress(progress)
                centerLabel.text = "继续"
            case .failed(let progress):
                isHidden = false
                isUserInteractionEnabled = true
                updateProgress(progress)
                centerLabel.text = "重试"
            }
            lastState = displayState
        }
        // 数字文字每次都可更新，但不要重复隐藏/显示
       switch displayState {
       case .uploading(let p):
           centerLabel.text = String(format: "%.0f%%", max(0, min(1, p)) * 100)
       case .paused(let p):
           centerLabel.text = "继续"
           updateProgress(p)
       case .failed(let p):
           centerLabel.text = "重试"
           updateProgress(p)
       default:
           break
       }
        
    }

//    private func updateProgress(_ value: CGFloat) {
////        currentProgress = max(0, min(1, value))
////        progressLayer.strokeEnd = currentProgress
////        let clampedProgress = max(0, min(1, value))
////        let currentStrokeEnd = progressLayer.presentation()?.strokeEnd ?? progressLayer.strokeEnd
////        let fromValue = CGFloat(currentStrokeEnd)
////
////        guard abs(clampedProgress - fromValue) > .ulpOfOne else {
////            currentProgress = clampedProgress
////            progressLayer.strokeEnd = clampedProgress
////            return
////        }
////
////        progressLayer.removeAnimation(forKey: "strokeEndAnimation")
////
////        let animation = CABasicAnimation(keyPath: "strokeEnd")
////        animation.fromValue = fromValue
////        animation.toValue = clampedProgress
////        animation.duration = CFTimeInterval(max(0.12, Double(abs(clampedProgress - fromValue)) * 0.35))
////        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
////        animation.fillMode = .forwards
////        animation.isRemovedOnCompletion = true
////        progressLayer.add(animation, forKey: "strokeEndAnimation")
////
////        CATransaction.begin()
////        CATransaction.setDisableActions(true)
////        progressLayer.strokeEnd = clampedProgress
////        CATransaction.commit()
////
////        currentProgress = clampedProgress
//        let clampedProgress = max(0, min(1, value))
//        let currentStrokeEnd = progressLayer.presentation()?.strokeEnd ?? progressLayer.strokeEnd
//        let fromValue = CGFloat(currentStrokeEnd)
//
//        guard abs(clampedProgress - fromValue) > 0.0005 else {
//            currentProgress = clampedProgress
//            CATransaction.begin()
//            CATransaction.setDisableActions(true)
//            progressLayer.strokeEnd = clampedProgress
//            CATransaction.commit()
//            return
//        }
//
//        progressLayer.removeAnimation(forKey: progressAnimationKey)
//
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        progressLayer.strokeEnd = fromValue
//        CATransaction.commit()
//
//        let animation = CASpringAnimation(keyPath: "strokeEnd")
//        animation.fromValue = fromValue
//        animation.toValue = clampedProgress
//        animation.damping = 18
//        animation.stiffness = 150
//        animation.mass = 1
//        animation.initialVelocity = 0
//        animation.duration = animation.settlingDuration
//        animation.fillMode = .forwards
//        animation.isRemovedOnCompletion = true
//        progressLayer.add(animation, forKey: progressAnimationKey)
//
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        progressLayer.strokeEnd = clampedProgress
//        CATransaction.commit()
//
//        currentProgress = clampedProgress
//    }
    private func updateProgress(_ value: CGFloat) {
        let clamped = max(0, min(1, value))

        // 1) 若增量非常小，直接静默设置，避免频繁动画
        let current = progressLayer.presentation()?.strokeEnd ?? progressLayer.strokeEnd
        if abs(clamped - CGFloat(current)) < 0.01 {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            progressLayer.strokeEnd = clamped
            CATransaction.commit()
            currentProgress = clamped
            return
        }

        // 2) 移除旧动画，避免叠加
        progressLayer.removeAnimation(forKey: progressAnimationKey)

        // 3) 以当前呈现值为起点做一段短动画（避免抖动/倒跳）
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = current
        anim.toValue = clamped
        anim.duration = 0.18               // 短、固定，手感稳定
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = true
        progressLayer.add(anim, forKey: progressAnimationKey)

        // 4) 同步模型层到目标值
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = clamped
        CATransaction.commit()

        currentProgress = clamped
    }

}
