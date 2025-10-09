//
//  FeedBackButton.swift
//  lns
//
//  Created by Elavatine on 2025/8/15.
//

class FeedBackTapButton: UIButton {
    
    public var generator = UIImpactFeedbackGenerator(style: .rigid)
    public var generatorWeight = 0.6
    
    /// Adds a simple press animation with ripple effect.
    /// Call this once after button creation.
    func addPressEffect() {
        // Keep the button background unchanged during highlighting
        adjustsImageWhenHighlighted = false
        // Prepares the generator so the first tap has no delay
        generator.prepare()
//        addTarget(self, action: #selector(handlePressDownAction), for: .touchDown)
        addTarget(self, action: #selector(handlePressDownAction(_:event:)), for: .touchDown)
//        addTarget(self, action: #selector(handlePressDragExitAction), for: .touchDragExit)
//        addTarget(self, action: #selector(handlePressDragEnterAction), for: .touchDragEnter)
//        addTarget(self, action: #selector(handlePressUpInsideAction), for: .touchUpInside)
//        addTarget(self, action: #selector(handlePressUpOutsideAction), for: .touchUpOutside)
//        addTarget(self, action: #selector(handlePressUpCancelAction), for: .touchCancel)
    }
    
    @objc private func handlePressDownAction(_ sender: UIButton, event: UIEvent) {
        generator.impactOccurred(intensity: generatorWeight)
//        let width = bounds.width
//        let height = bounds.height
//        guard width > 0 && height > 0 else { return }
//
//        let scaleX = 0.98//(width - 4) / width
//        let scaleY = 0.98//(height - 4) / height
//
//        UIView.animate(withDuration: 0.1) {
//            self.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
//        }
//        showPressRippleEffectView()
        
        if let touch = event.touches(for: sender)?.first {
            let location = touch.location(in: self)
            showPressRippleEffectView(at: location)
        } else {
            let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
            showPressRippleEffectView(at: centerPoint)
        }

        // Prepare the generator for the next tap
        generator.prepare()
    }

    @objc private func handlePressDragExitAction() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
        generator.impactOccurred(intensity: generatorWeight)
    }
    @objc private func handlePressDragEnterAction() {
        let scaleX: CGFloat = 0.98
        let scaleY: CGFloat = 0.98
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        }
        generator.impactOccurred(intensity: generatorWeight)
    }

    @objc private func handlePressUpInsideAction() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
//        generator.impactOccurred(intensity: 1)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.9)
    }

    @objc private func handlePressUpOutsideAction() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }

    @objc private func handlePressUpCancelAction() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
//        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    private func showPressRippleEffectView(at point: CGPoint) {
//        let size = max(bounds.width, bounds.height)
//        let frame = CGRect(x: (bounds.width - size) / 2,
//                           y: (bounds.height - size) / 2,
//                           width: size,
//                           height: size)
        let maxX = max(point.x, bounds.width - point.x)
                let maxY = max(point.y, bounds.height - point.y)
                let radius = sqrt(maxX * maxX + maxY * maxY)
        let rippleLayer = CALayer()
//        rippleLayer.frame = frame
//        rippleLayer.cornerRadius = size / 2
        rippleLayer.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        rippleLayer.position = point
        rippleLayer.cornerRadius = radius
        rippleLayer.backgroundColor = UIColor.THEME.withAlphaComponent(0.15).cgColor
        layer.insertSublayer(rippleLayer, below: titleLabel?.layer)

        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
//        scaleAnim.fromValue = 0.3
//        scaleAnim.toValue = 1.4
        
        scaleAnim.fromValue = 0.3
        scaleAnim.toValue = 1.0

        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 0.5
        opacityAnim.toValue = 0.0

        let group = CAAnimationGroup()
        group.animations = [scaleAnim, opacityAnim]
        group.duration = 0.25
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
