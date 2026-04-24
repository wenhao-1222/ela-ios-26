//
//  UIButton+Exs.swift
//  lns
//
//  Created by Elavatine on 2025/5/28.
//

import UIKit

private var spinnerKey: UInt8 = 0
private var successShapeLayerKey: UInt8 = 0
private var generator = UIImpactFeedbackGenerator(style: .rigid)
private var generatorWeight = 0.6
private var lastFeedbackTime: TimeInterval = 0
private let minimumFeedbackInterval: TimeInterval = 0.2
private let statusIndicatorFadeDuration: TimeInterval = 0.18

private func triggerImpact(_ generator: UIImpactFeedbackGenerator, intensity: CGFloat) {
    let now = Date().timeIntervalSince1970
    guard now - lastFeedbackTime > minimumFeedbackInterval else { return }
    generator.impactOccurred(intensity: intensity)
    lastFeedbackTime = now
}

extension UIButton {
    func showLoadingIndicator(color: UIColor = .white,
                              animated: Bool = false,
                              hideContent: Bool = true,
                              completion: (() -> Void)? = nil) {
        isUserInteractionEnabled = false
        if hideContent {
            setStatusContentHidden(true)
        }
        removeSuccessIndicator()
        var spinner = objc_getAssociatedObject(self, &spinnerKey) as? UIActivityIndicatorView
        if spinner == nil {
            spinner = UIActivityIndicatorView(style: .medium)
            spinner!.translatesAutoresizingMaskIntoConstraints = false
            addSubview(spinner!)
            NSLayoutConstraint.activate([
                spinner!.centerXAnchor.constraint(equalTo: centerXAnchor),
                spinner!.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            objc_setAssociatedObject(self, &spinnerKey, spinner, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        spinner?.color = color
        spinner?.alpha = animated ? 0 : 1
        spinner!.startAnimating()

        guard animated, let spinner else {
            completion?()
            return
        }

        UIView.animate(withDuration: statusIndicatorFadeDuration,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]) {
            spinner.alpha = 1
        } completion: { _ in
            completion?()
        }
    }

    func hideLoadingIndicator(animated: Bool = false,
                              restoreContent: Bool = true,
                              completion: (() -> Void)? = nil) {
        isUserInteractionEnabled = true
        if restoreContent {
            setStatusContentHidden(false)
        }

        guard let spinner = objc_getAssociatedObject(self, &spinnerKey) as? UIActivityIndicatorView else {
            completion?()
            return
        }

        let removeSpinner = {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            objc_setAssociatedObject(self, &spinnerKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            completion?()
        }

        guard animated else {
            removeSpinner()
            return
        }

        UIView.animate(withDuration: statusIndicatorFadeDuration,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]) {
            spinner.alpha = 0
        } completion: { _ in
            removeSpinner()
        }
    }

    func showSuccessIndicator(tintColor: UIColor = .white, completion: (() -> Void)? = nil) {
        hideLoadingIndicator(animated: true, restoreContent: false) {
            self.isUserInteractionEnabled = false
            self.setStatusContentHidden(true)
            self.removeSuccessIndicator()
            self.layoutIfNeeded()

            let checkLayer = CAShapeLayer()
            checkLayer.frame = self.bounds
            checkLayer.fillColor = UIColor.clear.cgColor
            checkLayer.strokeColor = tintColor.cgColor
            checkLayer.lineWidth = 2.5
            checkLayer.lineCap = .round
            checkLayer.lineJoin = .round
            checkLayer.strokeEnd = 1
            self.layer.addSublayer(checkLayer)
            objc_setAssociatedObject(self, &successShapeLayerKey, checkLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            let width = self.bounds.width
            let height = self.bounds.height
            let path = UIBezierPath()
            path.move(to: CGPoint(x: width * 0.3, y: height * 0.54))
            path.addLine(to: CGPoint(x: width * 0.45, y: height * 0.69))
            path.addLine(to: CGPoint(x: width * 0.72, y: height * 0.36))
            checkLayer.path = path.cgPath

            let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
            strokeAnimation.fromValue = 0
            strokeAnimation.toValue = 1
            strokeAnimation.duration = 0.32
            strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            checkLayer.strokeEnd = 1
            checkLayer.add(strokeAnimation, forKey: "drawCheckmark")
            CATransaction.commit()
        }
    }

    func resetStatusIndicators() {
        hideLoadingIndicator(animated: false, restoreContent: false)
        removeSuccessIndicator()
        setStatusContentHidden(false)
        transform = .identity
    }

    private func removeSuccessIndicator() {
        if let successLayer = objc_getAssociatedObject(self, &successShapeLayerKey) as? CAShapeLayer {
            successLayer.removeFromSuperlayer()
            objc_setAssociatedObject(self, &successShapeLayerKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private func setStatusContentHidden(_ isHidden: Bool) {
        titleLabel?.isHidden = isHidden
        imageView?.isHidden = isHidden
        titleLabel?.alpha = isHidden ? 0 : 1
        imageView?.alpha = isHidden ? 0 : 1
        setNeedsLayout()
        layoutIfNeeded()
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
