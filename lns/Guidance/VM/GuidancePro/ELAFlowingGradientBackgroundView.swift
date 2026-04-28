//
//  ELAFlowingGradientBackgroundView.swift
//  lns
//
//  Created by LNS2 on 2026/4/10.
//

import UIKit

public final class ELAFlowingGradientBackgroundView: UIView {

    public struct Style {
        public var topColor: UIColor
        public var midColor: UIColor
        public var bottomColor: UIColor
        public var leftGlowColor: UIColor
        public var rightGlowColor: UIColor
        public var centerGlowColor: UIColor

        public init(
            topColor: UIColor,
            midColor: UIColor,
            bottomColor: UIColor,
            leftGlowColor: UIColor,
            rightGlowColor: UIColor,
            centerGlowColor: UIColor
        ) {
            self.topColor = topColor
            self.midColor = midColor
            self.bottomColor = bottomColor
            self.leftGlowColor = leftGlowColor
            self.rightGlowColor = rightGlowColor
            self.centerGlowColor = centerGlowColor
        }

        /// 你发的浅色背景图
        public static let light = Style(
            topColor: UIColor(red: 138.0 / 255.0, green: 178.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0),
            midColor: UIColor(red: 204.0 / 255.0, green: 219.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0),
            bottomColor: UIColor(red: 228.0 / 255.0, green: 234.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0),
            leftGlowColor: UIColor(red: 102.0 / 255.0, green: 162.0 / 255.0, blue: 1.0, alpha: 0.28),
            rightGlowColor: UIColor(red: 168.0 / 255.0, green: 204.0 / 255.0, blue: 1.0, alpha: 0.22),
            centerGlowColor: UIColor.white.withAlphaComponent(0.16)
        )

        /// 你发的暗色背景图
        public static let dark = Style(
            topColor: UIColor(red: 24.0 / 255.0, green: 31.0 / 255.0, blue: 47.0 / 255.0, alpha: 1.0),
            midColor: UIColor(red: 17.0 / 255.0, green: 23.0 / 255.0, blue: 36.0 / 255.0, alpha: 1.0),
            bottomColor: UIColor(red: 11.0 / 255.0, green: 16.0 / 255.0, blue: 28.0 / 255.0, alpha: 1.0),
            leftGlowColor: UIColor(red: 75.0 / 255.0, green: 116.0 / 255.0, blue: 208.0 / 255.0, alpha: 0.18),
            rightGlowColor: UIColor(red: 46.0 / 255.0, green: 82.0 / 255.0, blue: 162.0 / 255.0, alpha: 0.14),
            centerGlowColor: UIColor.white.withAlphaComponent(0.05)
        )
    }

    private var fixedStyle: Style?

    private let baseGradient = CAGradientLayer()
    private let leftGlow = CAGradientLayer()
    private let rightGlow = CAGradientLayer()
    private let centerGlow = CAGradientLayer()

    public init(style: Style? = nil) {
        self.fixedStyle = style
        super.init(frame: .zero)
        setupUI()
        applyResolvedStyle()
    }

    required init?(coder: NSCoder) {
        self.fixedStyle = nil
        super.init(coder: coder)
        setupUI()
        applyResolvedStyle()
    }

    private func setupUI() {
        isUserInteractionEnabled = false
        backgroundColor = .clear
        layer.masksToBounds = true

        layer.addSublayer(baseGradient)

        configure(glow: leftGlow)
        configure(glow: rightGlow)
        configure(glow: centerGlow)

        layer.addSublayer(leftGlow)
        layer.addSublayer(rightGlow)
        layer.addSublayer(centerGlow)
    }

    private func configure(glow: CAGradientLayer) {
        glow.type = .radial
        glow.locations = [0.0, 0.45, 1.0]
        glow.startPoint = CGPoint(x: 0.5, y: 0.5)
        glow.endPoint = CGPoint(x: 1.0, y: 1.0)
    }

    private var resolvedStyle: Style {
        if let fixedStyle {
            return fixedStyle
        }

        if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            return .dark
        }

        return .light
    }

    private func applyResolvedStyle() {
        let style = resolvedStyle

        baseGradient.colors = [
            style.topColor.cgColor,
            style.midColor.cgColor,
            style.bottomColor.cgColor
        ]
        baseGradient.locations = [0.0, 0.30, 1.0]

        leftGlow.colors = [
            style.leftGlowColor.cgColor,
            style.leftGlowColor.withAlphaComponent(0.18).cgColor,
            UIColor.clear.cgColor
        ]

        rightGlow.colors = [
            style.rightGlowColor.cgColor,
            style.rightGlowColor.withAlphaComponent(0.15).cgColor,
            UIColor.clear.cgColor
        ]

        centerGlow.colors = [
            style.centerGlowColor.cgColor,
            style.centerGlowColor.withAlphaComponent(0.12).cgColor,
            UIColor.clear.cgColor
        ]
    }

    public func updateStyle(_ style: Style?) {
        self.fixedStyle = style
        applyResolvedStyle()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let w = bounds.width
        let h = bounds.height

        baseGradient.frame = bounds.insetBy(dx: -40, dy: -40)
        baseGradient.startPoint = CGPoint(x: 0.10, y: 0.0)
        baseGradient.endPoint = CGPoint(x: 0.82, y: 1.0)

        leftGlow.frame = CGRect(
            x: -w * 0.42,
            y: -h * 0.12,
            width: w * 1.00,
            height: h * 0.38
        )

        rightGlow.frame = CGRect(
            x: w * 0.38,
            y: -h * 0.10,
            width: w * 0.88,
            height: h * 0.32
        )

        centerGlow.frame = CGRect(
            x: -w * 0.02,
            y: -h * 0.08,
            width: w * 1.04,
            height: h * 0.24
        )

        CATransaction.commit()
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()

        applyResolvedStyle()

        if window == nil {
            stopAnimating()
        } else {
            startAnimating()
        }
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard fixedStyle == nil else { return }
        guard #available(iOS 13.0, *) else { return }
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }

        applyResolvedStyle()
    }

    public func startAnimating() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        guard baseGradient.animation(forKey: "bg.startPoint") == nil else { return }

        animateBaseGradient()

        animate(
            glow: leftGlow,
            x: 46,
            y: 26,
            scale: 1.20,
            opacityFrom: 1.0,
            opacityTo: 0.56,
            duration: 9.5,
            delay: 0
        )

        animate(
            glow: rightGlow,
            x: -40,
            y: 24,
            scale: 1.18,
            opacityFrom: 1.0,
            opacityTo: 0.54,
            duration: 10.5,
            delay: 0.6
        )

        animate(
            glow: centerGlow,
            x: 0,
            y: 32,
            scale: 1.16,
            opacityFrom: 0.96,
            opacityTo: 0.44,
            duration: 8.8,
            delay: 0.35
        )
    }

    public func stopAnimating() {
        [baseGradient, leftGlow, rightGlow, centerGlow].forEach {
            $0.removeAllAnimations()
        }
    }

    private func animateBaseGradient() {
        let startPoint = CABasicAnimation(keyPath: "startPoint")
        startPoint.fromValue = CGPoint(x: -0.10, y: -0.16)
        startPoint.toValue = CGPoint(x: 0.32, y: 0.18)
        startPoint.duration = 8.5
        startPoint.autoreverses = true
        startPoint.repeatCount = .infinity
        startPoint.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let endPoint = CABasicAnimation(keyPath: "endPoint")
        endPoint.fromValue = CGPoint(x: 0.66, y: 0.88)
        endPoint.toValue = CGPoint(x: 1.08, y: 1.18)
        endPoint.duration = 8.5
        endPoint.autoreverses = true
        endPoint.repeatCount = .infinity
        endPoint.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        baseGradient.add(startPoint, forKey: "bg.startPoint")
        baseGradient.add(endPoint, forKey: "bg.endPoint")
    }

    private func animate(
        glow layer: CALayer,
        x: CGFloat,
        y: CGFloat,
        scale: CGFloat,
        opacityFrom: Float,
        opacityTo: Float,
        duration: CFTimeInterval,
        delay: CFTimeInterval
    ) {
        let beginTime = CACurrentMediaTime() + delay

        let moveX = CABasicAnimation(keyPath: "transform.translation.x")
        moveX.fromValue = -x
        moveX.toValue = x
        moveX.duration = duration
        moveX.autoreverses = true
        moveX.repeatCount = .infinity
        moveX.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        moveX.beginTime = beginTime

        let moveY = CABasicAnimation(keyPath: "transform.translation.y")
        moveY.fromValue = -y
        moveY.toValue = y
        moveY.duration = duration * 0.85
        moveY.autoreverses = true
        moveY.repeatCount = .infinity
        moveY.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        moveY.beginTime = beginTime

        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 1.0
        scaleAnim.toValue = scale
        scaleAnim.duration = duration * 0.90
        scaleAnim.autoreverses = true
        scaleAnim.repeatCount = .infinity
        scaleAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleAnim.beginTime = beginTime

        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.fromValue = opacityFrom
        opacity.toValue = opacityTo
        opacity.duration = duration
        opacity.autoreverses = true
        opacity.repeatCount = .infinity
        opacity.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        opacity.beginTime = beginTime

        layer.add(moveX, forKey: "glow.x")
        layer.add(moveY, forKey: "glow.y")
        layer.add(scaleAnim, forKey: "glow.scale")
        layer.add(opacity, forKey: "glow.opacity")
    }
}

public extension UIView {
    @discardableResult
    func addELAFlowingBackground(
        _ style: ELAFlowingGradientBackgroundView.Style? = nil
    ) -> ELAFlowingGradientBackgroundView {
        if let old = subviews.first(where: { $0 is ELAFlowingGradientBackgroundView }) as? ELAFlowingGradientBackgroundView {
            old.updateStyle(style)
            return old
        }

        let backgroundView = ELAFlowingGradientBackgroundView(style: style)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(backgroundView, at: 0)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        return backgroundView
    }
}

public extension UIViewController {
    @discardableResult
    func addELAFlowingBackground(
        _ style: ELAFlowingGradientBackgroundView.Style? = nil
    ) -> ELAFlowingGradientBackgroundView {
        view.addELAFlowingBackground(style)
    }
}
