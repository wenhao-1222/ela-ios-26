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
            topColor: UIColor(red: 158.0 / 255.0, green: 195.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0),
            midColor: UIColor(red: 224.0 / 255.0, green: 232.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0),
            bottomColor: UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0),
            leftGlowColor: UIColor(red: 123.0 / 255.0, green: 176.0 / 255.0, blue: 1.0, alpha: 0.16),
            rightGlowColor: UIColor(red: 190.0 / 255.0, green: 214.0 / 255.0, blue: 1.0, alpha: 0.12),
            centerGlowColor: UIColor.white.withAlphaComponent(0.10)
        )

        /// 你发的暗色背景图
        public static let dark = Style(
            topColor: UIColor(red: 9.0 / 255.0, green: 13.0 / 255.0, blue: 24.0 / 255.0, alpha: 1.0),
            midColor: UIColor(red: 7.0 / 255.0, green: 10.0 / 255.0, blue: 18.0 / 255.0, alpha: 1.0),
            bottomColor: UIColor(red: 5.0 / 255.0, green: 7.0 / 255.0, blue: 13.0 / 255.0, alpha: 1.0),
            leftGlowColor: UIColor(red: 61.0 / 255.0, green: 96.0 / 255.0, blue: 185.0 / 255.0, alpha: 0.14),
            rightGlowColor: UIColor(red: 38.0 / 255.0, green: 70.0 / 255.0, blue: 140.0 / 255.0, alpha: 0.10),
            centerGlowColor: UIColor.white.withAlphaComponent(0.03)
        )
    }

    private var style: Style

    private let baseGradient = CAGradientLayer()
    private let leftGlow = CAGradientLayer()
    private let rightGlow = CAGradientLayer()
    private let centerGlow = CAGradientLayer()

    public init(style: Style = .light) {
        self.style = style
        super.init(frame: .zero)
        setupUI()
        applyStyle()
    }

    required init?(coder: NSCoder) {
        self.style = .light
        super.init(coder: coder)
        setupUI()
        applyStyle()
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

    private func applyStyle() {
        baseGradient.colors = [
            style.topColor.cgColor,
            style.midColor.cgColor,
            style.bottomColor.cgColor
        ]
        baseGradient.locations = [0.0, 0.30, 1.0]

        leftGlow.colors = [
            style.leftGlowColor.cgColor,
            style.leftGlowColor.withAlphaComponent(0.05).cgColor,
            UIColor.clear.cgColor
        ]

        rightGlow.colors = [
            style.rightGlowColor.cgColor,
            style.rightGlowColor.withAlphaComponent(0.04).cgColor,
            UIColor.clear.cgColor
        ]

        centerGlow.colors = [
            style.centerGlowColor.cgColor,
            style.centerGlowColor.withAlphaComponent(0.03).cgColor,
            UIColor.clear.cgColor
        ]
    }

    public func updateStyle(_ style: Style) {
        self.style = style
        applyStyle()
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

        if window == nil {
            stopAnimating()
        } else {
            startAnimating()
        }
    }

    public func startAnimating() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        guard baseGradient.animation(forKey: "bg.startPoint") == nil else { return }

        animateBaseGradient()

        animate(
            glow: leftGlow,
            x: 12,
            y: 10,
            scale: 1.05,
            opacityFrom: 1.0,
            opacityTo: 0.82,
            duration: 20,
            delay: 0
        )

        animate(
            glow: rightGlow,
            x: -10,
            y: 8,
            scale: 1.04,
            opacityFrom: 0.95,
            opacityTo: 0.78,
            duration: 24,
            delay: 1.6
        )

        animate(
            glow: centerGlow,
            x: 0,
            y: 12,
            scale: 1.03,
            opacityFrom: 0.75,
            opacityTo: 0.55,
            duration: 22,
            delay: 0.8
        )
    }

    public func stopAnimating() {
        [baseGradient, leftGlow, rightGlow, centerGlow].forEach {
            $0.removeAllAnimations()
        }
    }

    private func animateBaseGradient() {
        let startPoint = CABasicAnimation(keyPath: "startPoint")
        startPoint.fromValue = CGPoint(x: 0.08, y: -0.02)
        startPoint.toValue = CGPoint(x: 0.16, y: 0.05)
        startPoint.duration = 20
        startPoint.autoreverses = true
        startPoint.repeatCount = .infinity
        startPoint.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let endPoint = CABasicAnimation(keyPath: "endPoint")
        endPoint.fromValue = CGPoint(x: 0.80, y: 1.0)
        endPoint.toValue = CGPoint(x: 0.92, y: 1.02)
        endPoint.duration = 20
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
        _ style: ELAFlowingGradientBackgroundView.Style = .light
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
        _ style: ELAFlowingGradientBackgroundView.Style = .light
    ) -> ELAFlowingGradientBackgroundView {
        view.addELAFlowingBackground(style)
    }
}
