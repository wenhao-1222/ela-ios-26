//
//  UIButton+Exs.swift
//  lns
//
//  Created by Elavatine on 2025/5/28.
//

import UIKit

private var spinnerKey: UInt8 = 0
private var generator = UIImpactFeedbackGenerator(style: .rigid)
private var generatorWeight = 0.6
private var lastFeedbackTime: TimeInterval = 0
private let minimumFeedbackInterval: TimeInterval = 0.2

private func triggerImpact(_ generator: UIImpactFeedbackGenerator, intensity: CGFloat) {
    let now = Date().timeIntervalSince1970
    guard now - lastFeedbackTime > minimumFeedbackInterval else { return }
    generator.impactOccurred(intensity: intensity)
    lastFeedbackTime = now
}

extension UIButton {
    func showLoadingIndicator() {
        isUserInteractionEnabled = false
        self.titleLabel?.alpha = 0
        var spinner = objc_getAssociatedObject(self, &spinnerKey) as? UIActivityIndicatorView
        if spinner == nil {
            spinner = UIActivityIndicatorView(style: .medium)
            spinner?.color = .white
            spinner!.translatesAutoresizingMaskIntoConstraints = false
            addSubview(spinner!)
            NSLayoutConstraint.activate([
                spinner!.centerXAnchor.constraint(equalTo: centerXAnchor),
                spinner!.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            objc_setAssociatedObject(self, &spinnerKey, spinner, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        spinner!.startAnimating()
    }

    func hideLoadingIndicator() {
        isUserInteractionEnabled = true
        self.titleLabel?.alpha = 1
        if let spinner = objc_getAssociatedObject(self, &spinnerKey) as? UIActivityIndicatorView {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            objc_setAssociatedObject(self, &spinnerKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - Press Effect
extension UIButton {
    /// Adds a simple press animation with ripple effect.
    /// Call this once after button creation.
    func enablePressEffect(style: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid),weight:CGFloat = 0.6) {
        // Keep the button background unchanged during highlighting
        adjustsImageWhenHighlighted = false
        generator = style
        generatorWeight = weight
        addTarget(self, action: #selector(handlePressDown), for: .touchDown)
//        addTarget(self, action: #selector(handlePressUp), for: [.touchUpInside,.touchUpOutside])
//        addTarget(self, action: #selector(handlePressUpCancel), for: [.touchCancel])
        addTarget(self, action: #selector(handlePressDragExit), for: .touchDragExit)
        addTarget(self, action: #selector(handlePressDragEnter), for: .touchDragEnter)
        addTarget(self, action: #selector(handlePressUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(handlePressUpOutside), for: .touchUpOutside)
        addTarget(self, action: #selector(handlePressUpCancel), for: .touchCancel)
    }
    func enablePressEffectNoneFeedback() {
        // Keep the button background unchanged during highlighting
        adjustsImageWhenHighlighted = false
        
        addTarget(self, action: #selector(handlePressDownNoFeedBack), for: .touchDown)
    }

    @objc private func handlePressDownNoFeedBack() {
        let width = bounds.width
        let height = bounds.height
        guard width > 0 && height > 0 else { return }

        let scaleX = 0.98//(width - 4) / width
        let scaleY = 0.98//(height - 4) / height

        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        }
        showPressRippleEffect(color: .THEME)
    }
    @objc private func handlePressDown() {
        let width = bounds.width
        let height = bounds.height
        guard width > 0 && height > 0 else { return }

        let scaleX = 0.98//(width - 4) / width
        let scaleY = 0.98//(height - 4) / height

        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        }
        showPressRippleEffect()
//        generator.impactOccurred(intensity: generatorWeight)
        triggerImpact(generator, intensity: generatorWeight)
    }

    @objc private func handlePressDragExit() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
//        generator.impactOccurred(intensity: generatorWeight)
        triggerImpact(generator, intensity: generatorWeight)
    }
    @objc private func handlePressDragEnter() {
        let scaleX: CGFloat = 0.98
        let scaleY: CGFloat = 0.98
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        }
//        generator.impactOccurred(intensity: generatorWeight)
        triggerImpact(generator, intensity: generatorWeight)
    }

    @objc private func handlePressUpInside() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
//        generator.impactOccurred(intensity: 1)
//        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.9)
        triggerImpact(UIImpactFeedbackGenerator(style: .medium), intensity: 0.9)
    }

    @objc private func handlePressUpOutside() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }

    @objc private func handlePressUpCancel() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
//        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    private func showPressRippleEffect(color:UIColor=UIColor.white) {
        let size = max(bounds.width, bounds.height)
        let frame = CGRect(x: (bounds.width - size) / 2,
                           y: (bounds.height - size) / 2,
                           width: size,
                           height: size)

        let rippleLayer = CALayer()
        rippleLayer.frame = frame
        rippleLayer.cornerRadius = size / 2
        rippleLayer.backgroundColor = color.withAlphaComponent(0.2).cgColor
        layer.insertSublayer(rippleLayer, below: titleLabel?.layer)

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

//
//extension UIButton{
//    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
////        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//    }
//    open override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
//        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//    }
////    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
////        UIImpactFeedbackGenerator(style: .light).impactOccurred()
////    }
////    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
////        UIImpactFeedbackGenerator(style: .light).impactOccurred()
////    }
//}
