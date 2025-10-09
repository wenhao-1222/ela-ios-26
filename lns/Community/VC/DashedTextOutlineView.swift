//
//  DashedTextOutlineView.swift
//  lns
//
//  Created by Elavatine on 2025/5/14.
//
import UIKit
import CoreText

class TextTracePracticeView: UIView {

    // MARK: - 公共配置
    var text: String = "葛健" { didSet { reloadAll() } }
    var font: UIFont = UIFont.systemFont(ofSize: 80, weight: .bold) { didSet { reloadAll() } }
    var dashColor: UIColor = .gray
    var dashPattern: [NSNumber] = [6, 3]
    var traceColor: UIColor = .blue
    var successColor: UIColor = .green
    var failColor: UIColor = .red

    // MARK: - 私有属性
    private let outlineLayer = CAShapeLayer()
    private let traceLayer = CAShapeLayer()
    private var drawPath = UIBezierPath()
    private var outlinePath: UIBezierPath?

    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear

        // Outline
        outlineLayer.strokeColor = dashColor.cgColor
        outlineLayer.fillColor = UIColor.clear.cgColor
        outlineLayer.lineWidth = 1.0
        outlineLayer.lineDashPattern = dashPattern
        layer.addSublayer(outlineLayer)

        // Trace
        traceLayer.strokeColor = traceColor.cgColor
        traceLayer.fillColor = UIColor.clear.cgColor
        traceLayer.lineWidth = 3.0
        layer.addSublayer(traceLayer)

        // Gesture
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)

        reloadAll()
    }

    // MARK: - 核心方法
    private func reloadAll() {
        let path = bezierPathFrom(text: text, font: font)
        outlinePath = path

        // 自动缩放并居中
        let box = path.bounds
        let scale = min(bounds.width / box.width * 0.8,
                        bounds.height / box.height * 0.8)
        let transform = CGAffineTransform.identity
            .translatedBy(x: -box.minX, y: -box.minY)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: (bounds.width - box.width * scale) / 2,
                          y: (bounds.height - box.height * scale) / 2)
        path.apply(transform)

        outlineLayer.path = path.cgPath
        traceLayer.path = nil
        drawPath = UIBezierPath()
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self)
        switch gesture.state {
        case .began:
            drawPath.move(to: point)
        case .changed:
            drawPath.addLine(to: point)
            traceLayer.path = drawPath.cgPath
        case .ended, .cancelled:
            checkAccuracy()
        default:
            break
        }
    }

    private func checkAccuracy() {
        guard let target = outlinePath else { return }
        let strokeUser = drawPath.cgPath.copy(strokingWithWidth: 10, lineCap: .round, lineJoin: .round, miterLimit: 0)
        let strokeRef = target.cgPath.copy(strokingWithWidth: 10, lineCap: .round, lineJoin: .round, miterLimit: 0)

        if strokeUser.boundingBox.intersects(strokeRef.boundingBox) {
            traceLayer.strokeColor = successColor.cgColor
        } else {
            traceLayer.strokeColor = failColor.cgColor
        }
    }

    public func playStrokeAnimation(duration: CFTimeInterval = 3.0) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        outlineLayer.removeAllAnimations()
        outlineLayer.strokeEnd = 1.0
        outlineLayer.add(animation, forKey: "strokeEnd")
    }

    public func reset() {
        traceLayer.path = nil
        traceLayer.strokeColor = traceColor.cgColor
        drawPath = UIBezierPath()
    }

    private func bezierPathFrom(text: String, font: UIFont) -> UIBezierPath {
        let path = CGMutablePath()
        let attrString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: font])
        let line = CTLineCreateWithAttributedString(attrString)
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]

        for run in runs {
            let runFont = unsafeBitCast(
                CFDictionaryGetValue(CTRunGetAttributes(run), Unmanaged.passUnretained(kCTFontAttributeName).toOpaque()),
                to: CTFont.self
            )

            let glyphCount = CTRunGetGlyphCount(run)
            for i in 0..<glyphCount {
                var glyph = CGGlyph()
                var position = CGPoint.zero
                CTRunGetGlyphs(run, CFRangeMake(i, 1), &glyph)
                CTRunGetPositions(run, CFRangeMake(i, 1), &position)
                if let letter = CTFontCreatePathForGlyph(runFont, glyph, nil) {
                    let transform = CGAffineTransform(translationX: position.x, y: position.y)
                    path.addPath(letter, transform: transform)
                }
            }
        }

        // === 正确坐标转换：垂直翻转并上移原始高度 ===
        let bounds = path.boundingBox
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: 0, y: bounds.height + bounds.origin.y * 2)
        transform = transform.scaledBy(x: 1, y: -1)

        let correctedPath = path.copy(using: &transform)!
        return UIBezierPath(cgPath: correctedPath)
    }
}
