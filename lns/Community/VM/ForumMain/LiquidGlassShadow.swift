//
//  LiquidGlassShadow.swift
//  lns
//
//  Created by LNS2 on 2025/10/23.
//
//
//  LiquidGlass.swift
//  UIKit-only Liquid/Glassmorphism helper
//

//  使用方法：
//  someView.backgroundColor = .clear
//  someView.clipsToBounds = false
//  someView.addLiquidGlass(
//      cornerRadius: 22,
//      blurStyle: .systemMaterial,
//      tint: .auto,
//      showInnerStroke: true,
//      showHighlight: true,
//      shadow: .init(opacity: 0.18, radius: 16, y: 6)
//  )
//
//  移除：someView.removeLiquidGlass()
//

import UIKit
import ObjectiveC // 关联对象

// MARK: - Public Models

public enum LiquidGlassTint: Equatable {
    case auto                       // 明暗自适应
    case custom(UIColor, CGFloat)   // 自定义颜色 + alpha(0~1)
}

public struct LiquidGlassShadow: Equatable {
    public var color: UIColor = .black
    public var opacity: Float = 0.12
    public var radius: CGFloat = 12
    public var x: CGFloat = 0
    public var y: CGFloat = 8

    public init(color: UIColor = .black, opacity: Float = 0.12, radius: CGFloat = 12, x: CGFloat = 0, y: CGFloat = 8) {
        self.color = color; self.opacity = opacity; self.radius = radius; self.x = x; self.y = y
    }
}

// MARK: - UIView Extension

public extension UIView {

    /// 在当前视图“底层”铺一块 Liquid Glass 背景
    @discardableResult
    func addLiquidGlass(
        cornerRadius: CGFloat = 20,
        blurStyle: UIBlurEffect.Style = .systemMaterial,
        tint: LiquidGlassTint = .auto,
        showInnerStroke: Bool = true,
        showHighlight: Bool = true,
        shadow: LiquidGlassShadow = .init(),
        inset: UIEdgeInsets = .zero
    ) -> LiquidGlassBackground {

        // 已存在则更新
        if let bg = liquidGlassBackground {
            bg.update(
                cornerRadius: cornerRadius,
                blurStyle: blurStyle,
                tint: tint,
                showInnerStroke: showInnerStroke,
                showHighlight: showHighlight,
                shadow: shadow,
                inset: inset
            )
            return bg
        }

        let bg = LiquidGlassBackground(
            cornerRadius: cornerRadius,
            blurStyle: blurStyle,
            tint: tint,
            showInnerStroke: showInnerStroke,
            showHighlight: showHighlight,
            shadow: shadow,
            inset: inset
        )
        bg.isUserInteractionEnabled = false

        insertSubview(bg, at: 0)
        bg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: topAnchor, constant: inset.top),
            bg.leftAnchor.constraint(equalTo: leftAnchor, constant: inset.left),
            bg.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset.bottom),
            bg.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset.right),
        ])

        liquidGlassBackground = bg
        return bg
    }

    func removeLiquidGlass() {
        liquidGlassBackground?.removeFromSuperview()
        liquidGlassBackground = nil
    }

    // 关联对象保存
    private struct Assoc { static var key = "liquid.glass.background" }
    private var liquidGlassBackground: LiquidGlassBackground? {
        get { objc_getAssociatedObject(self, &Assoc.key) as? LiquidGlassBackground }
        set { objc_setAssociatedObject(self, &Assoc.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

// MARK: - Core View

public final class LiquidGlassBackground: UIView {

    // 子视图/图层
    private let blurView: UIVisualEffectView
    private let tintView = UIView()
    private let highlightLayer = CAGradientLayer()
    private let strokeLayer = CAShapeLayer()

    // 配置
    private var cornerRadius: CGFloat
    private var blurStyle: UIBlurEffect.Style
    private var tint: LiquidGlassTint
    private var showInnerStroke: Bool
    private var showHighlight: Bool
    private var shadowConfig: LiquidGlassShadow
    private var inset: UIEdgeInsets

    // MARK: Init

    public init(
        cornerRadius: CGFloat,
        blurStyle: UIBlurEffect.Style,
        tint: LiquidGlassTint,
        showInnerStroke: Bool,
        showHighlight: Bool,
        shadow: LiquidGlassShadow,
        inset: UIEdgeInsets
    ) {
        self.cornerRadius = cornerRadius
        self.blurStyle = blurStyle
        self.tint = tint
        self.showInnerStroke = showInnerStroke
        self.showHighlight = showHighlight
        self.shadowConfig = shadow
        self.inset = inset

        self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        super.init(frame: .zero)
        isOpaque = false

        // 外层不要 mask，避免“静态化”；只做阴影/几何
        layer.masksToBounds = false
        layer.cornerCurve = .continuous

        // build
        addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leftAnchor.constraint(equalTo: leftAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        addSubview(tintView)
        tintView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tintView.topAnchor.constraint(equalTo: topAnchor),
            tintView.leftAnchor.constraint(equalTo: leftAnchor),
            tintView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tintView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        // 高光与内描边挂到外层（不会阻止模糊实时更新）
        layer.addSublayer(highlightLayer)
        strokeLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(strokeLayer)

        applyColors()
        applyCornerAndShadow()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Public

    public func update(
        cornerRadius: CGFloat,
        blurStyle: UIBlurEffect.Style,
        tint: LiquidGlassTint,
        showInnerStroke: Bool,
        showHighlight: Bool,
        shadow: LiquidGlassShadow,
        inset: UIEdgeInsets
    ) {
        self.cornerRadius = cornerRadius
        self.blurStyle = blurStyle
        self.tint = tint
        self.showInnerStroke = showInnerStroke
        self.showHighlight = showHighlight
        self.shadowConfig = shadow
        self.inset = inset

        blurView.effect = UIBlurEffect(style: blurStyle)
        applyColors()
        applyCornerAndShadow()
        setNeedsLayout()
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()

        let r = cornerRadius

        // 关键：圆角裁剪交给 blurView / tintView 自己，模糊实时更新
        blurView.layer.cornerRadius = r
        blurView.clipsToBounds = true
        tintView.layer.cornerRadius = r
        tintView.clipsToBounds = true

        // 顶部柔和高光
        highlightLayer.frame = bounds
        highlightLayer.cornerRadius = r
        highlightLayer.isHidden = !showHighlight
        highlightLayer.type = .axial
        highlightLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        highlightLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        highlightLayer.colors = [
            UIColor.white.withAlphaComponent(0.50).cgColor,
            UIColor.white.withAlphaComponent(0.12).cgColor,
            UIColor.clear.cgColor
        ]
        highlightLayer.locations = [0, 0.08, 0.25]

        // 内描边（内收 0.5pt 防锯齿）
        let inset: CGFloat = 0.5
        let innerRect = bounds.insetBy(dx: inset, dy: inset)
        let path = UIBezierPath(roundedRect: innerRect, cornerRadius: max(0, r - inset))
        strokeLayer.path = path.cgPath
        strokeLayer.lineWidth = 1.0
        strokeLayer.isHidden = !showInnerStroke

        let strokeColor: UIColor = {
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.white.withAlphaComponent(0.18)
            } else {
                return UIColor.white.withAlphaComponent(0.35)
            }
        }()
        strokeLayer.strokeColor = strokeColor.cgColor

        // 阴影路径
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: r).cgPath
    }

    // MARK: - Appearance

    private func applyColors() {
//        switch tint {
            tintView.backgroundColor = .clear
//        case .auto:
//            tintView.backgroundColor = (traitCollection.userInterfaceStyle == .dark)
//                ? UIColor.white.withAlphaComponent(0.08)
//                : UIColor.white.withAlphaComponent(0.25)
//        case let .custom(color, alpha):
//            tintView.backgroundColor = color.withAlphaComponent(alpha)
//        }
    }

    private func applyCornerAndShadow() {
        layer.cornerRadius = cornerRadius // 仅用于视觉与 shadowPath 配合
        layer.shadowColor = shadowConfig.color.cgColor
        layer.shadowOpacity = shadowConfig.opacity
        layer.shadowRadius = shadowConfig.radius
        layer.shadowOffset = CGSize(width: shadowConfig.x, height: shadowConfig.y)
    }

    // MARK: - Trait changes

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyColors()
            setNeedsLayout()
        }
    }
}
