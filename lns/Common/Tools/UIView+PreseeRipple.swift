//
//  UIView+PreseeRipple.swift
//  lns
//
//  Created by Codex on 2026/7/15.
//

import Foundation
import UIKit
import ObjectiveC

private final class UIViewPreseeRippleActionBox {
    let action: (() -> Void)?

    init(action: (() -> Void)?) {
        self.action = action
    }
}

private struct UIViewPreseeRippleKeys {
    static var gesture: UInt8 = 0
    static var action: UInt8 = 0
    static var generator: UInt8 = 0
    static var weight: UInt8 = 0
    static var pressed: UInt8 = 0
}

extension UIView {
    func enablePreseeRippleEffect(style: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid),
                                  weight: CGFloat = 0.6,
                                  tapAction: (() -> Void)? = nil) {
        isUserInteractionEnabled = true
        preseeRippleActionBox = UIViewPreseeRippleActionBox(action: tapAction)
        preseeRippleGenerator = style
        preseeRippleWeight = weight

        if let gesture = preseeRippleGesture {
            removeGestureRecognizer(gesture)
        }

        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePreseeRippleGesture(_:)))
        gesture.minimumPressDuration = 0
        gesture.cancelsTouchesInView = false
        addGestureRecognizer(gesture)
        preseeRippleGesture = gesture
    }
}

private extension UIView {
    var preseeRippleGesture: UILongPressGestureRecognizer? {
        get {
            objc_getAssociatedObject(self, &UIViewPreseeRippleKeys.gesture) as? UILongPressGestureRecognizer
        }
        set {
            objc_setAssociatedObject(self, &UIViewPreseeRippleKeys.gesture, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var preseeRippleActionBox: UIViewPreseeRippleActionBox? {
        get {
            objc_getAssociatedObject(self, &UIViewPreseeRippleKeys.action) as? UIViewPreseeRippleActionBox
        }
        set {
            objc_setAssociatedObject(self, &UIViewPreseeRippleKeys.action, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var preseeRippleGenerator: UIImpactFeedbackGenerator {
        get {
            if let generator = objc_getAssociatedObject(self, &UIViewPreseeRippleKeys.generator) as? UIImpactFeedbackGenerator {
                return generator
            }
            return UIImpactFeedbackGenerator(style: .rigid)
        }
        set {
            objc_setAssociatedObject(self, &UIViewPreseeRippleKeys.generator, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var preseeRippleWeight: CGFloat {
        get {
            if let number = objc_getAssociatedObject(self, &UIViewPreseeRippleKeys.weight) as? NSNumber {
                return CGFloat(truncating: number)
            }
            return 0.6
        }
        set {
            objc_setAssociatedObject(self, &UIViewPreseeRippleKeys.weight, NSNumber(value: Double(newValue)), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var isPreseeRipplePressed: Bool {
        get {
            if let number = objc_getAssociatedObject(self, &UIViewPreseeRippleKeys.pressed) as? NSNumber {
                return number.boolValue
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &UIViewPreseeRippleKeys.pressed, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc func handlePreseeRippleGesture(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: self)
        let containsPoint = bounds.contains(point)

        switch gesture.state {
        case .began:
            setPreseeRipplePressed(true, feedbackIntensity: preseeRippleWeight)
            showPreseeRippleEffect()
        case .changed:
            if containsPoint && isPreseeRipplePressed == false {
                setPreseeRipplePressed(true, feedbackIntensity: preseeRippleWeight)
            } else if containsPoint == false && isPreseeRipplePressed {
                setPreseeRipplePressed(false, feedbackIntensity: preseeRippleWeight)
            }
        case .ended:
            setPreseeRipplePressed(false, feedbackIntensity: containsPoint ? 0.9 : nil)
            if containsPoint {
                preseeRippleActionBox?.action?()
            }
        case .cancelled, .failed:
            setPreseeRipplePressed(false, feedbackIntensity: nil)
        default:
            break
        }
    }

    func setPreseeRipplePressed(_ pressed: Bool, feedbackIntensity: CGFloat?) {
        isPreseeRipplePressed = pressed
        let targetTransform = pressed ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        UIView.animate(withDuration: 0.1) {
            self.transform = targetTransform
        }
        if let feedbackIntensity = feedbackIntensity {
            preseeRippleGenerator.impactOccurred(intensity: feedbackIntensity)
        }
    }

    func showPreseeRippleEffect() {
        let size = max(bounds.width, bounds.height)
        let frame = CGRect(x: (bounds.width - size) / 2,
                           y: (bounds.height - size) / 2,
                           width: size,
                           height: size)

        let rippleLayer = CALayer()
        rippleLayer.frame = frame
        rippleLayer.cornerRadius = size / 2
        rippleLayer.backgroundColor = UIColor.white.withAlphaComponent(0.2).cgColor
        layer.insertSublayer(rippleLayer, at: 0)

        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 0.3
        scaleAnim.toValue = 1.4

        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 0.5
        opacityAnim.toValue = 0.0

        let group = CAAnimationGroup()
        group.animations = [scaleAnim, opacityAnim]
        group.duration = 0.5
        group.repeatCount = 0
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            rippleLayer.removeFromSuperlayer()
        }
        rippleLayer.add(group, forKey: "ripple")
        CATransaction.commit()
    }
}
