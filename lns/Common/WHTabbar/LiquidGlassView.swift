//
//  LiquidGlassView.swift
//  lns
//
//  Created by LNS2 on 2025/10/9.
//
import UIKit

/// TabBar 底层“液态玻璃”视图：系统毛玻璃 + 轻微流动高光
final class LiquidGlassView: UIView {

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    private let highlightLayer = CAGradientLayer()
    private var displayLink: CADisplayLink?
    private var t: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        clipsToBounds = true

        addSubview(blurView)

        // 柔和的移动高光，模拟“液态”质感（很轻量，如不需要可整段注释）
        highlightLayer.startPoint = CGPoint(x: 0, y: 0)
        highlightLayer.endPoint = CGPoint(x: 1, y: 1)
        highlightLayer.colors = [
            UIColor.white.withAlphaComponent(0.08).cgColor,
            UIColor.white.withAlphaComponent(0.02).cgColor,
            UIColor.white.withAlphaComponent(0.08).cgColor
        ]
        highlightLayer.locations = [0.0, 0.5, 1.0]
        layer.addSublayer(highlightLayer)

        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        highlightLayer.frame = bounds.insetBy(dx: -bounds.width * 0.2, dy: -bounds.height * 0.2)
        if #available(iOS 13.0, *) { layer.cornerCurve = .continuous }
    }

    @objc private func tick() {
        t += 0.002
        let offsetX = sin(t) * 0.15
        let offsetY = cos(t * 0.8) * 0.15
        highlightLayer.transform = CATransform3DMakeTranslation(bounds.width * offsetX,
                                                                bounds.height * offsetY, 0)
        let a: CGFloat = 0.06 + 0.02 * (sin(t * 0.6) + 1) / 2
        highlightLayer.colors = [
            UIColor.white.withAlphaComponent(a + 0.02).cgColor,
            UIColor.white.withAlphaComponent(a - 0.04).cgColor,
            UIColor.white.withAlphaComponent(a + 0.02).cgColor
        ]
    }

    deinit { displayLink?.invalidate() }
}
