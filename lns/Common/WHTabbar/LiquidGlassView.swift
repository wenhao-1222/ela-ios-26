//
//  LiquidGlassView.swift
//  lns
//
//  Created by LNS2 on 2025/10/9.
//


import UIKit

/// 顶部导航用“液态玻璃”：系统毛玻璃 + 纵向由深到浅（底部为 0）+ 底部羽化 + 轻微高光流动（可关）
final class LiquidGlassView: UIView {

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    private let highlightLayer = CAGradientLayer()
    private let featherMask = CAGradientLayer()
    private var displayLink: CADisplayLink?
    private var t: CGFloat = 0

    /// 可调：底部羽化高度（越大过渡越柔）
    var featherHeight: CGFloat = 22 { didSet { setNeedsLayout() } }

    /// 顶部/中段的亮度（白色 alpha）
    var topAlpha: CGFloat = 0.16 { didSet { setNeedsDisplay() } }
    var midAlpha: CGFloat = 0.07  { didSet { setNeedsDisplay() } }

    /// 是否需要“流动感”
    var enableFlow: Bool = true {
        didSet {
            if enableFlow {
                if displayLink == nil {
                    displayLink = CADisplayLink(target: self, selector: #selector(tick))
                    displayLink?.add(to: .main, forMode: .common)
                }
            } else {
                displayLink?.invalidate()
                displayLink = nil
                highlightLayer.transform = CATransform3DIdentity
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        isUserInteractionEnabled = false
        clipsToBounds = true
        backgroundColor = .clear

        addSubview(blurView)
        blurView.backgroundColor = .clear
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // 纵向高光：上深下浅（底部 0）
        highlightLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        highlightLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        highlightLayer.locations  = [0.0, 0.35, 1.0]
        layer.addSublayer(highlightLayer)

        // 底部羽化：mask 白=可见，黑=不可见
        featherMask.startPoint = CGPoint(x: 0.5, y: 0.0)
        featherMask.endPoint   = CGPoint(x: 0.5, y: 1.0)
        layer.mask = featherMask

        // 默认开启流动
        enableFlow = true

        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()

        // 高光层稍外扩，移动时不抽边
        highlightLayer.frame = bounds.insetBy(dx: -bounds.width * 0.2, dy: -bounds.height * 0.2)

        // 根据当前高度计算羽化位置：最后 featherHeight 渐隐为 0
        featherMask.frame = bounds
        let h = max(bounds.height, 1)
        let fadeStart = max(0, min(1, (h - featherHeight) / h))
        featherMask.locations = [0.0, NSNumber(value: Double(fadeStart)), 1.0]
        featherMask.colors = [
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.black.cgColor
        ]

        // 刷新初始颜色
        updateHighlightColors(pulse: 0.5)
    }

    private func updateHighlightColors(pulse: CGFloat) {
        let aTop = clamp(topAlpha + 0.02 * pulse, 0, 1)
        let aMid = clamp(midAlpha + 0.01 * pulse, 0, 1)
        highlightLayer.colors = [
            UIColor.white.withAlphaComponent(aTop).cgColor,
            UIColor.white.withAlphaComponent(aMid).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
    }

    @objc private func tick() {
        guard enableFlow else { return }
        t += 0.002
        let offsetX = sin(t) * 0.10
        let offsetY = cos(t * 0.8) * 0.10
        highlightLayer.transform = CATransform3DMakeTranslation(bounds.width * offsetX,
                                                                bounds.height * offsetY, 0)
        let pulse = (sin(t * 0.6) + 1) / 2   // 0...1
        updateHighlightColors(pulse: pulse)
    }

    deinit { displayLink?.invalidate() }
}

@inline(__always)
private func clamp<T: Comparable>(_ v: T, _ lo: T, _ hi: T) -> T { max(lo, min(v, hi)) }
