//
//  SegmentedLiquidDecorator.swift
//  lns
//
//  Created by LNS2 on 2025/10/23.
//

// MARK: - Liquid Glass Decorator for UISegmentedControl
final class SegmentedLiquidDecorator {
    private weak var target: UISegmentedControl?

    // 新增：一个裁剪用容器层（只放装饰用的子层，避免越界）
    private let container = CALayer()

    private let gloss = CAGradientLayer()
    private let innerShadow = CAShapeLayer()
    private let outerStroke = CAShapeLayer()
    private let innerStroke = CAShapeLayer()
    private let noiseLayer = CALayer()
    private let selectedShimmer = CAGradientLayer()
    private let baseFill = CAGradientLayer()

    init(target: UISegmentedControl) {
        self.target = target
        guard let view = target as UIView? else { return }

        // --- 新增：先把容器挂上去，并开启裁剪 ---
        view.layer.addSublayer(container)
        container.masksToBounds = true
        container.backgroundColor = UIColor.white.withAlphaComponent(1).cgColor
        container.shadowOpacity = 0

        // 以下这些“装饰层”全部加到 container，而不是直接加到 view.layer
        container.addSublayer(baseFill)  // 一定要最先加，作为基底
        container.addSublayer(gloss)
        container.addSublayer(innerShadow)
        container.addSublayer(outerStroke)
        container.addSublayer(innerStroke)
        
        container.addSublayer(noiseLayer)
//        container.addSublayer(selectedShimmer)
        // 基底：上稍亮、下稍暗，白感更自然
        baseFill.startPoint = CGPoint(x: 0.5, y: 0.0)
        baseFill.endPoint   = CGPoint(x: 0.5, y: 1.0)
        baseFill.colors = [
            UIColor.white.withAlphaComponent(0.35).cgColor,
            UIColor.white.withAlphaComponent(0.08).cgColor
        ]
        baseFill.locations = [0, 1]
        // 顶部高光
        gloss.startPoint = CGPoint(x: 0.5, y: 0.0)
        gloss.endPoint   = CGPoint(x: 0.5, y: 1.0)
        gloss.colors = [
            UIColor.white.withAlphaComponent(0.45).cgColor,
            UIColor.white.withAlphaComponent(0.06).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        gloss.locations = [0, 0.15, 0.45]

        // **修复点**：内阴影不再用“巨大外框 + even-odd”
        innerShadow.fillRule = .nonZero
        innerShadow.fillColor = UIColor.clear.cgColor
//        innerShadow.shadowColor = UIColor.black.withAlphaComponent(0.35).cgColor
//        innerShadow.shadowOffset = CGSize(width: 0, height: 1.5)
        innerShadow.shadowOpacity = 1
//        innerShadow.shadowRadius = 3
        innerShadow.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor // 原 0.35
        innerShadow.shadowRadius = 2.0  // 原 3
        innerShadow.shadowOffset = CGSize(width: 0, height: 0.3) // 原 1.5

        outerStroke.fillColor = UIColor.clear.cgColor
        outerStroke.strokeColor = UIColor.clear.cgColor//UIColor.white.withAlphaComponent(0.28).cgColor
        outerStroke.lineWidth = 1

        innerStroke.fillColor = UIColor.clear.cgColor
        innerStroke.strokeColor = UIColor.clear.cgColor//UIColor.white.withAlphaComponent(0.7).cgColor
        innerStroke.lineWidth = 1

        noiseLayer.compositingFilter = "softLightBlendMode"
        noiseLayer.opacity = 0.02
        noiseLayer.contents = Self.makeNoiseImage().cgImage
        noiseLayer.contentsGravity = .resizeAspectFill

//        selectedShimmer.startPoint = CGPoint(x: 0, y: 0.5)
//        selectedShimmer.endPoint   = CGPoint(x: 1, y: 0.5)
//        selectedShimmer.colors = [
//            UIColor.white.withAlphaComponent(0.0).cgColor,
//            UIColor.white.withAlphaComponent(0.55).cgColor,
//            UIColor.white.withAlphaComponent(0.0).cgColor
//        ]
//        selectedShimmer.locations = [0.35, 0.5, 0.65]
//        selectedShimmer.compositingFilter = "screenBlendMode"
//        selectedShimmer.opacity = 0.9

        relayout()
        target.addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
    }

    func relayout() {
        guard let view = target else { return }
        let bounds = view.bounds
        let radius = bounds.height / 2

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        baseFill.frame = container.bounds
        // **容器层跟随并裁剪圆角**
        container.frame = bounds
        container.cornerRadius = radius

        gloss.frame = container.bounds
        noiseLayer.frame = container.bounds
        outerStroke.frame = container.bounds
        innerStroke.frame = container.bounds
        innerShadow.frame = container.bounds

        let roundPath = UIBezierPath(roundedRect: container.bounds, cornerRadius: radius).cgPath
        outerStroke.path = roundPath
        innerStroke.path = roundPath

        // **修复点**：内阴影采用正常路径 + shadowPath（只在内部可见）
        let inset: CGFloat = 1
        let innerRect = container.bounds.insetBy(dx: inset, dy: inset)
        let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: radius - inset).cgPath
        innerShadow.path = innerPath
        innerShadow.shadowPath = innerPath  // 关键：不再用“巨大外框”

        // 选中段液态高光定位
//        if view.numberOfSegments > 0 {
//            let w = container.bounds.width / CGFloat(view.numberOfSegments)
//            let x = CGFloat(view.selectedSegmentIndex) * w
//            let segFrame = CGRect(x: x, y: 0, width: w, height: container.bounds.height)
//            let pad = w * 0.08
//            selectedShimmer.frame = segFrame.insetBy(dx: pad, dy: container.bounds.height * 0.25)
//            selectedShimmer.cornerRadius = selectedShimmer.frame.height / 2
//            selectedShimmer.masksToBounds = true
//
//            selectedShimmer.removeAllAnimations()
//            let anim = CABasicAnimation(keyPath: "locations")
//            anim.fromValue = [-0.2, 0.0, 0.2]
//            anim.toValue   = [0.8, 1.0, 1.2]
//            anim.duration = 2.6
//            anim.repeatCount = .infinity
//            selectedShimmer.add(anim, forKey: "liquid-shimmer")
//        }

        CATransaction.commit()

        // **建议**：给 segment 自身的投影一个明确的 shadowPath（更稳）
        if view.layer.shadowOpacity > 0 {
            view.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        }
    }
    @objc private func onValueChanged() {
        animateTap()
        relayout() // 更新选中段位置
    }
    private func animateTap() {
        guard let v = target else { return }
        v.layer.removeAnimation(forKey: "pop")
        let anim = CASpringAnimation(keyPath: "transform.scale")
        anim.fromValue = 0.98
        anim.toValue = 1.0
        anim.damping = 12
        anim.initialVelocity = 0.8
        anim.mass = 0.9
        anim.stiffness = 180
        anim.duration = anim.settlingDuration
        v.layer.add(anim, forKey: "pop")
    }

    static func makeNoiseImage(size: CGSize = CGSize(width: 64, height: 64)) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.clear.setFill()
            ctx.fill(rect)
            for _ in 0..<1200 {
                let x = CGFloat.random(in: 0..<size.width)
                let y = CGFloat.random(in: 0..<size.height)
                let alpha = CGFloat.random(in: 0.02...0.15)
                UIColor.white.withAlphaComponent(alpha).setFill()
                ctx.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }.resizableImage(withCapInsets: .zero, resizingMode: .tile)
    }
}
