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
        container.backgroundColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.6).cgColor // 让选中更贴近玻璃感（可按需改）
            // UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(1).cgColor
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
            UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.35).cgColor,
            UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.08).cgColor
        ]
        baseFill.locations = [0, 1]
        // 顶部高光
        gloss.startPoint = CGPoint(x: 0.5, y: 0.0)
        gloss.endPoint   = CGPoint(x: 0.5, y: 1.0)
        gloss.colors = [
            UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.45).cgColor,
            UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.06).cgColor,
            UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.0).cgColor
        ]
        gloss.locations = [0, 0.15, 0.45]

        // **修复点**：内阴影不再用“巨大外框 + even-odd”
        innerShadow.fillRule = .nonZero
        innerShadow.fillColor = UIColor.clear.cgColor
        innerShadow.shadowOpacity = 1
//        innerShadow.shadowRadius = 3
        innerShadow.shadowColor = UIColor.COLOR_BG_BLACK.withAlphaComponent(0.2).cgColor // 原 0.35
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
        
        relayout()
        target.addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
    }
    
//    func changeStyle() {
//        
//        container.backgroundColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(1).cgColor
//        baseFill.colors = [
//            UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.35).cgColor,
//            UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.08).cgColor
//        ]
//        gloss.colors = [
//            UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.45).cgColor,
//            UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.06).cgColor,
//            UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.0).cgColor
//        ]
//        innerShadow.shadowColor = UIColor.COLOR_BG_BLACK.withAlphaComponent(0.2).cgColor // 原 0.35
//    }
//    func changeStyle() {
//        // 深色模式下增强边界
//        if UITraitCollection.current.userInterfaceStyle == .dark {
//            container.backgroundColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.35).cgColor
//            outerStroke.strokeColor = UIColor.white.withAlphaComponent(0.05).cgColor
//            innerStroke.strokeColor = UIColor.white.withAlphaComponent(0.15).cgColor
//            innerShadow.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
//            baseFill.colors = [
//                UIColor.white.withAlphaComponent(0.1).cgColor,
//                UIColor.white.withAlphaComponent(0.03).cgColor
//            ]
//        } else {
//            // 保持你原来的浅色风格
//            container.backgroundColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(1).cgColor
//            baseFill.colors = [
//                UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.35).cgColor,
//                UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.08).cgColor
//            ]
//            gloss.colors = [
//                UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.45).cgColor,
//                UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.06).cgColor,
//                UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.0).cgColor
//            ]
//            innerShadow.shadowColor = UIColor.COLOR_BG_BLACK.withAlphaComponent(0.2).cgColor // 原 0.35
//        }
//    }
    func changeStyle() {
        let isDark = UITraitCollection.current.userInterfaceStyle == .dark
        
        // 动态背景色（你的色值）
        container.backgroundColor = UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.35)
            } else {
                return UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(1)
            }
        }.cgColor
        
        // 动态 baseFill（你的色值）
        baseFill.colors = [
            UIColor { trait in
                if trait.userInterfaceStyle == .dark {
                    return UIColor.white.withAlphaComponent(0.1)
                } else {
                    return UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.35)
                }
            }.cgColor,
            UIColor { trait in
                if trait.userInterfaceStyle == .dark {
                    return UIColor.white.withAlphaComponent(0.03)
                } else {
                    return UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.08)
                }
            }.cgColor
        ]
        
        // 动态 gloss（你的色值）
        gloss.colors = [
            UIColor { trait in
                if trait.userInterfaceStyle == .dark {
                    // 深色模式你没有提供 gloss 值，我保持浅色逻辑不变
                    return UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.45)
                } else {
                    return UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.45)
                }
            }.cgColor,
            UIColor { trait in
                if trait.userInterfaceStyle == .dark {
                    return UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.06)
                } else {
                    return UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.06)
                }
            }.cgColor,
            UIColor.clear.cgColor
        ]
        
        // outerStroke（你的色值）
        outerStroke.strokeColor = UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor.white.withAlphaComponent(0.05)
            } else {
                return UIColor.clear   // 你原代码
            }
        }.cgColor
        
        // innerStroke（你的色值）
        innerStroke.strokeColor = UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor.white.withAlphaComponent(0.15)
            } else {
                return UIColor.clear   // 你原代码
            }
        }.cgColor
        
        // 内阴影（你的色值）
        innerShadow.shadowColor = UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor.black.withAlphaComponent(0.25)
            } else {
                return UIColor.COLOR_BG_BLACK.withAlphaComponent(0.2)
            }
        }.cgColor
    }

    func relayout() {
        guard let view = target else { return }
        let bounds = view.bounds
        let radius = bounds.height / 2

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        // **容器层跟随并裁剪圆角**
        container.frame = bounds
        container.cornerRadius = radius
        
        baseFill.frame = container.bounds
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
