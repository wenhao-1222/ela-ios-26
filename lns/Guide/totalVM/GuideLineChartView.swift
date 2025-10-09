//
//  GuideLineChartView.swift
//  lns
//
//  Created by Elavatine on 2025/6/9.
//

import UIKit

/// Simple animated line chart used on the first guide page
class GuideLineChartView: UIView {
    private let lineLayer1 = CAShapeLayer()
    private let lineLayer2 = CAShapeLayer()

    /// Normalised points (0-1 range) for line paths
    private let data1: [CGPoint] = [
        CGPoint(x: 0.0, y: 0.8),
        CGPoint(x: 0.2, y: 0.65),
        CGPoint(x: 0.4, y: 0.5),
        CGPoint(x: 0.6, y: 0.4),
        CGPoint(x: 0.8, y: 0.3),
        CGPoint(x: 1.0, y: 0.2)
    ]
    private let data2: [CGPoint] = [
        CGPoint(x: 0.0, y: 0.8),
        CGPoint(x: 0.2, y: 0.75),
        CGPoint(x: 0.4, y: 0.72),
        CGPoint(x: 0.6, y: 0.70),
        CGPoint(x: 0.8, y: 0.68),
        CGPoint(x: 1.0, y: 0.66)
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.addSublayer(lineLayer1)
        layer.addSublayer(lineLayer2)
        configure(layer: lineLayer1, color: UIColor.THEME.cgColor)
        configure(layer: lineLayer2, color: UIColor.COLOR_HIGHTLIGHT_GRAY.cgColor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        lineLayer1.frame = bounds
        lineLayer2.frame = bounds
        lineLayer1.path = createPath(for: data1).cgPath
        lineLayer2.path = createPath(for: data2).cgPath
    }

    private func configure(layer: CAShapeLayer, color: CGColor) {
        layer.strokeColor = color
        layer.fillColor = nil
        layer.lineWidth = 2
        layer.lineJoin = .round
        layer.lineCap = .round
    }

    private func convert(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x * bounds.width,
                       y: bounds.height - point.y * bounds.height)
    }

    private func createPath(for points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        guard let first = points.first else { return path }
        path.move(to: convert(first))
        for p in points.dropFirst() {
            path.addLine(to: convert(p))
        }
        return path
    }

    /// Animates the drawing of the chart lines
    func startAnimation() {
        for layer in [lineLayer1, lineLayer2] {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            layer.add(animation, forKey: "draw")
        }
    }
}
