//
//  AICoachBreathingOrbView.swift
//  lns
//
//  Created by Codex on 2026/3/19.
//

import UIKit

final class AICoachBreathingOrbView: UIView {
    private let ambientGlowLayer = CAShapeLayer()
    private let outerShadowLayer = CAShapeLayer()
    private let outerBreathLayers: [CAShapeLayer] = (0..<4).map { _ in CAShapeLayer() }
    private let outerOrbitLayers: [CAShapeLayer] = (0..<28).map { _ in CAShapeLayer() }
    private let outerHighlightLayer = CAShapeLayer()
    private let outerPulseRingLayer = CAShapeLayer()
    private let innerLoopLayers: [CAShapeLayer] = (0..<14).map { _ in CAShapeLayer() }
    private let innerEdgeLayer = CAShapeLayer()
    private let coreGradientLayer = CAGradientLayer()
    private let coreMaskLayer = CAShapeLayer()
    private let coreBandLayer = CAShapeLayer()
    private let coreLowerGlowLayer = CAShapeLayer()
    private let coreRingLayer = CAShapeLayer()
    private let coreOuterRingLayer = CAShapeLayer()

    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayers()
    }

    deinit {
        stopAnimating()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            stopAnimating()
        } else {
            startAnimatingIfNeeded()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateAnimation(at: CACurrentMediaTime())
        CATransaction.commit()
    }
}

private extension AICoachBreathingOrbView {
    func configureLayers() {
        backgroundColor = .clear
        isOpaque = false

        ambientGlowLayer.fillColor = AICoachBreathingOrbPalette.electricBlue.withAlphaComponent(0.18).cgColor
        ambientGlowLayer.shadowColor = AICoachBreathingOrbPalette.deepBlue.cgColor
        ambientGlowLayer.shadowOpacity = 1
        ambientGlowLayer.shadowOffset = .zero
        layer.addSublayer(ambientGlowLayer)

        outerShadowLayer.fillColor = UIColor.white.withAlphaComponent(0.14).cgColor
        outerShadowLayer.shadowColor = AICoachBreathingOrbPalette.blue.withAlphaComponent(0.34).cgColor
        outerShadowLayer.shadowOpacity = 1
        outerShadowLayer.shadowOffset = CGSize(width: 0, height: 22)
        layer.addSublayer(outerShadowLayer)

        outerBreathLayers.forEach {
            $0.fillColor = UIColor.clear.cgColor
            $0.lineCap = .round
            $0.lineJoin = .round
            $0.shadowColor = AICoachBreathingOrbPalette.blue.cgColor
            $0.shadowOpacity = 1
            $0.shadowOffset = .zero
            layer.addSublayer($0)
        }

        outerOrbitLayers.forEach {
            $0.fillColor = UIColor.clear.cgColor
            $0.lineCap = .round
            $0.lineJoin = .round
            layer.addSublayer($0)
        }

        outerHighlightLayer.fillColor = UIColor.clear.cgColor
        outerHighlightLayer.lineCap = .round
        outerHighlightLayer.lineJoin = .round
        layer.addSublayer(outerHighlightLayer)

        outerPulseRingLayer.fillColor = UIColor.clear.cgColor
        outerPulseRingLayer.shadowColor = AICoachBreathingOrbPalette.aqua.cgColor
        outerPulseRingLayer.shadowOpacity = 1
        outerPulseRingLayer.shadowOffset = .zero
        layer.addSublayer(outerPulseRingLayer)

        innerLoopLayers.forEach {
            $0.fillColor = UIColor.clear.cgColor
            $0.lineCap = .round
            $0.lineJoin = .round
            layer.addSublayer($0)
        }

        innerEdgeLayer.fillColor = UIColor.clear.cgColor
        innerEdgeLayer.lineCap = .round
        innerEdgeLayer.lineJoin = .round
        layer.addSublayer(innerEdgeLayer)

        if #available(iOS 12.0, *) {
            coreGradientLayer.type = .conic
        }
        coreGradientLayer.colors = [
            AICoachBreathingOrbPalette.coreLight.cgColor,
            AICoachBreathingOrbPalette.aqua.cgColor,
            AICoachBreathingOrbPalette.coreLavender.cgColor,
            AICoachBreathingOrbPalette.coreShadow.cgColor,
            AICoachBreathingOrbPalette.coreLight.cgColor
        ]
        coreGradientLayer.locations = [0.0, 0.18, 0.46, 0.76, 1.0]
        coreGradientLayer.mask = coreMaskLayer
        layer.addSublayer(coreGradientLayer)

        coreBandLayer.fillColor = AICoachBreathingOrbPalette.violet.withAlphaComponent(0.38).cgColor
        layer.addSublayer(coreBandLayer)

        coreLowerGlowLayer.fillColor = UIColor.white.withAlphaComponent(0.10).cgColor
        coreLowerGlowLayer.shadowColor = AICoachBreathingOrbPalette.aqua.cgColor
        coreLowerGlowLayer.shadowOpacity = 0.8
        coreLowerGlowLayer.shadowOffset = .zero
        layer.addSublayer(coreLowerGlowLayer)

        coreOuterRingLayer.fillColor = UIColor.clear.cgColor
        coreOuterRingLayer.strokeColor = AICoachBreathingOrbPalette.aqua.withAlphaComponent(0.56).cgColor
        layer.addSublayer(coreOuterRingLayer)

        coreRingLayer.fillColor = UIColor.clear.cgColor
        coreRingLayer.strokeColor = AICoachBreathingOrbPalette.rimGlow.cgColor
        coreRingLayer.shadowColor = AICoachBreathingOrbPalette.rimGlow.cgColor
        coreRingLayer.shadowOpacity = 0.9
        coreRingLayer.shadowOffset = .zero
        layer.addSublayer(coreRingLayer)
    }

    func startAnimatingIfNeeded() {
        guard displayLink == nil else { return }
        startTime = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(step))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stopAnimating() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc
    func step(_ link: CADisplayLink) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateAnimation(at: link.timestamp)
        CATransaction.commit()
    }

    func updateAnimation(at timestamp: CFTimeInterval) {
        guard bounds.width > 0, bounds.height > 0 else { return }

        if startTime == 0 {
            startTime = timestamp
        }

        let time = CGFloat(timestamp - startTime)
        let breathCycleDuration: CGFloat = 10.2
        let breathe = asymmetricBreathProgress(time: time, cycleDuration: breathCycleDuration, inhalePortion: 0.66)
        let pulse = asymmetricBreathProgress(time: time + breathCycleDuration * 0.12, cycleDuration: breathCycleDuration, inhalePortion: 0.66)
        let shimmer = 0.5 + 0.5 * sin(time * 1.24 + 0.8)

        transform = CGAffineTransform(scaleX: 0.975 + breathe * 0.05, y: 0.975 + breathe * 0.05)

        let size = min(bounds.width, bounds.height)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        let ambientRect = CGRect(
            x: center.x - size * 0.42,
            y: center.y - size * 0.42,
            width: size * 0.84,
            height: size * 0.84
        )
        ambientGlowLayer.path = UIBezierPath(ovalIn: ambientRect).cgPath
        ambientGlowLayer.shadowRadius = 50 + pulse * 20
        ambientGlowLayer.opacity = Float(0.16 + shimmer * 0.05)

        let outerRadius = size * 0.33
        let outerAmplitude = size * 0.055
        let outerRect = CGRect(
            x: center.x - outerRadius * 1.08,
            y: center.y - outerRadius * 1.04,
            width: outerRadius * 2.16,
            height: outerRadius * 2.08
        )

        outerShadowLayer.path = UIBezierPath(ovalIn: outerRect.insetBy(dx: -14, dy: -10)).cgPath
        outerShadowLayer.shadowRadius = 34 + pulse * 12
        outerShadowLayer.opacity = Float(0.18 + pulse * 0.08)

        for (index, breathLayer) in outerBreathLayers.enumerated() {
            let progress = CGFloat(index) / CGFloat(max(outerBreathLayers.count - 1, 1))
            let phase = 0.5 + 0.5 * sin(time * 0.62 - progress * 0.26)
            let radialSpread = size * (0.030 + progress * 0.070) * phase
            let xInset = -(18 + radialSpread * 0.75 + progress * 10)
            let yInset = -(16 + radialSpread * 0.66 + progress * 8)
            let breathRect = outerRect.insetBy(dx: xInset, dy: yInset)
            breathLayer.path = UIBezierPath(ovalIn: breathRect).cgPath
            breathLayer.lineWidth = 20 + progress * 14
            breathLayer.strokeColor = AICoachBreathingOrbPalette.blue.withAlphaComponent(0.035 + phase * 0.020 - progress * 0.006).cgColor
            breathLayer.shadowRadius = 20 + progress * 10 + phase * 8
            breathLayer.opacity = Float(0.08 + phase * 0.05 - progress * 0.012)
        }

        for (index, orbitLayer) in outerOrbitLayers.enumerated() {
            let progress = CGFloat(index) / CGFloat(max(outerOrbitLayers.count - 1, 1))
            let layerTime = time + progress * 0.9
            let radius = outerRadius + (progress - 0.5) * size * 0.028 + pulse * size * 0.010
            let path = makeOrbitPath(
                center: center,
                radius: radius,
                amplitude: outerAmplitude * (1.0 - progress * 0.22),
                time: layerTime,
                harmonic: 5.0 + progress * 1.4,
                offset: progress * .pi * 2.0,
                xScale: 1.0 + 0.06 * sin(layerTime * 0.26),
                yScale: 1.0 - 0.04 * cos(layerTime * 0.22),
                twist: 0.06
            )
            orbitLayer.path = path.cgPath
            orbitLayer.lineWidth = 0.85 + progress * 0.9

            let leadColor = UIColor.orbInterpolate(
                from: AICoachBreathingOrbPalette.aqua,
                to: AICoachBreathingOrbPalette.indigo,
                amount: progress
            )
            orbitLayer.strokeColor = leadColor.withAlphaComponent(0.18 + (1.0 - progress) * 0.18).cgColor
            orbitLayer.opacity = Float(0.74 - progress * 0.22 + breathe * 0.06)
        }

        outerHighlightLayer.path = makeOrbitPath(
            center: center,
            radius: outerRadius + size * 0.012 + pulse * size * 0.008,
            amplitude: outerAmplitude * 0.72,
            time: time + 0.18,
            harmonic: 4.4,
            offset: 0.35,
            xScale: 1.02,
            yScale: 0.98,
            twist: 0.034
        ).cgPath
        outerHighlightLayer.lineWidth = 2.4
        outerHighlightLayer.strokeColor = AICoachBreathingOrbPalette.rimGlow.withAlphaComponent(0.74).cgColor
        outerHighlightLayer.opacity = Float(0.46 + breathe * 0.16)

        outerPulseRingLayer.path = UIBezierPath(
            ovalIn: outerRect.insetBy(dx: -(22 + pulse * 30), dy: -(22 + pulse * 30))
        ).cgPath
        outerPulseRingLayer.lineWidth = 42 + pulse * 22
        outerPulseRingLayer.strokeColor = AICoachBreathingOrbPalette.aqua.withAlphaComponent(0.018 + pulse * 0.015).cgColor
        outerPulseRingLayer.shadowRadius = 26 + pulse * 12
        outerPulseRingLayer.opacity = Float(0.04 + pulse * 0.03)

        let innerRadius = size * 0.215
        for (index, loopLayer) in innerLoopLayers.enumerated() {
            let progress = CGFloat(index) / CGFloat(max(innerLoopLayers.count - 1, 1))
            let localTime = time * 1.28 - progress * 0.32
            let loopPath = makeInnerLoopPath(
                center: center,
                radius: innerRadius + (progress - 0.5) * size * 0.032,
                thickness: size * (0.032 - progress * 0.010),
                verticalStretch: 0.88 + progress * 0.20,
                time: localTime,
                offset: progress * 0.7
            )
            loopLayer.path = loopPath.cgPath
            loopLayer.lineWidth = 1.6 + progress * 1.6
            let tint = UIColor.orbInterpolate(
                from: AICoachBreathingOrbPalette.cyan,
                to: AICoachBreathingOrbPalette.blue,
                amount: progress
            )
            loopLayer.strokeColor = tint.withAlphaComponent(0.16 + (1.0 - progress) * 0.24).cgColor
            loopLayer.opacity = Float(0.58 - progress * 0.18 + breathe * 0.08)
        }

        innerEdgeLayer.path = makeInnerLoopPath(
            center: center,
            radius: innerRadius + size * 0.01,
            thickness: size * 0.028,
            verticalStretch: 0.96,
            time: time + 0.24,
            offset: 0.22
        ).cgPath
        innerEdgeLayer.lineWidth = 4.0
        innerEdgeLayer.strokeColor = AICoachBreathingOrbPalette.rimGlow.withAlphaComponent(0.92).cgColor
        innerEdgeLayer.opacity = Float(0.84)

        let coreRect = CGRect(
            x: center.x - size * 0.20,
            y: center.y - size * 0.20,
            width: size * 0.40,
            height: size * 0.40
        )
        coreMaskLayer.path = makeCoreBlobPath(in: coreRect, time: time).cgPath
        coreGradientLayer.frame = coreRect.insetBy(dx: -22, dy: -22)
        coreGradientLayer.startPoint = CGPoint(x: 0.16 + pulse * 0.08, y: 0.12)
        coreGradientLayer.endPoint = CGPoint(x: 0.88, y: 0.9 - breathe * 0.06)
        coreGradientLayer.opacity = Float(0.95)

        coreBandLayer.path = UIBezierPath(
            roundedRect: CGRect(
                x: coreRect.midX - coreRect.width * 0.08 + sin(time * 0.72) * 4,
                y: coreRect.minY - coreRect.height * 0.04,
                width: coreRect.width * 0.20,
                height: coreRect.height * 1.06
            ),
            cornerRadius: coreRect.width * 0.14
        ).cgPath
        coreBandLayer.opacity = Float(0.52 + breathe * 0.10)

        coreLowerGlowLayer.path = UIBezierPath(
            ovalIn: CGRect(
                x: coreRect.minX + coreRect.width * 0.10,
                y: coreRect.maxY - coreRect.height * 0.28,
                width: coreRect.width * 0.74,
                height: coreRect.height * 0.20
            )
        ).cgPath
        coreLowerGlowLayer.shadowRadius = 18 + pulse * 8
        coreLowerGlowLayer.opacity = Float(0.28 + pulse * 0.10)

        let ringRect = coreRect.insetBy(dx: coreRect.width * 0.07, dy: coreRect.height * 0.07)
        coreOuterRingLayer.path = UIBezierPath(ovalIn: ringRect.insetBy(dx: -10, dy: -8)).cgPath
        coreOuterRingLayer.lineWidth = 12 + pulse * 5
        coreOuterRingLayer.opacity = Float(0.28 + pulse * 0.08)

        coreRingLayer.path = UIBezierPath(ovalIn: ringRect).cgPath
        coreRingLayer.lineWidth = 7.0
        coreRingLayer.shadowRadius = 14 + shimmer * 8
        coreRingLayer.opacity = Float(0.92)
    }

    func makeOrbitPath(
        center: CGPoint,
        radius: CGFloat,
        amplitude: CGFloat,
        time: CGFloat,
        harmonic: CGFloat,
        offset: CGFloat,
        xScale: CGFloat,
        yScale: CGFloat,
        twist: CGFloat
    ) -> UIBezierPath {
        let pointCount = 132
        var points: [CGPoint] = []
        points.reserveCapacity(pointCount)

        for index in 0..<pointCount {
            let progress = CGFloat(index) / CGFloat(pointCount)
            let angle = progress * .pi * 2.0
            let rippleA = sin(angle * harmonic + time * 1.18 + offset)
            let rippleB = sin(angle * (harmonic * 0.55 + 1.2) - time * 1.42 + offset * 1.5)
            let rippleC = cos(angle * 3.0 + time * 0.66 - offset * 0.7)
            let radialMix = 0.56 * rippleA + 0.28 * rippleB + 0.16 * rippleC
            let localRadius = radius + amplitude * radialMix
            let rolledAngle = angle + twist * sin(angle * 2.0 - time * 0.78 + offset)
            let x = center.x + cos(rolledAngle) * localRadius * xScale
            let y = center.y + sin(rolledAngle) * localRadius * yScale
            points.append(CGPoint(x: x, y: y))
        }

        return makeClosedSmoothPath(points)
    }

    func makeInnerLoopPath(
        center: CGPoint,
        radius: CGFloat,
        thickness: CGFloat,
        verticalStretch: CGFloat,
        time: CGFloat,
        offset: CGFloat
    ) -> UIBezierPath {
        let points = makePolarPoints(center: center, count: 120) { angle, progress in
            let localAngle = angle + offset + sin(angle * 2.0 - time * 0.6) * 0.05
            let wave = sin(localAngle * 4.0 + time * 1.42 + progress * 3.0) * thickness
            let secondary = cos(localAngle * 2.0 - time * 0.92) * thickness * 0.5
            let radial = radius + wave + secondary
            return CGPoint(
                x: center.x + cos(localAngle) * radial * 1.02,
                y: center.y + sin(localAngle) * radial * verticalStretch
            )
        }
        return makeClosedSmoothPath(points)
    }

    func makeCoreBlobPath(in rect: CGRect, time: CGFloat) -> UIBezierPath {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = rect.width * 0.48
        let points = makePolarPoints(center: center, count: 88) { angle, _ in
            let waveA = sin(angle * 2.0 + time * 1.18) * rect.width * 0.035
            let waveB = cos(angle * 3.0 - time * 0.76) * rect.width * 0.022
            let radial = baseRadius + waveA + waveB
            let xScale = 0.98 + 0.05 * sin(time * 0.54)
            let yScale = 1.02 - 0.06 * cos(time * 0.40)
            return CGPoint(
                x: center.x + cos(angle) * radial * xScale,
                y: center.y + sin(angle) * radial * yScale
            )
        }
        return makeClosedSmoothPath(points)
    }

    func makePolarPoints(
        center: CGPoint,
        count: Int,
        point: (_ angle: CGFloat, _ progress: CGFloat) -> CGPoint
    ) -> [CGPoint] {
        var points: [CGPoint] = []
        points.reserveCapacity(count)

        for index in 0..<count {
            let progress = CGFloat(index) / CGFloat(count)
            let angle = progress * .pi * 2.0
            points.append(point(angle, progress))
        }

        return points
    }

    func makeClosedSmoothPath(_ points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        guard points.count > 2 else { return path }

        let count = points.count
        let start = midpoint(points[count - 1], points[0])
        path.move(to: start)

        for index in 0..<count {
            let current = points[index]
            let next = points[(index + 1) % count]
            path.addQuadCurve(to: midpoint(current, next), controlPoint: current)
        }

        path.close()
        return path
    }

    func midpoint(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        CGPoint(x: (lhs.x + rhs.x) * 0.5, y: (lhs.y + rhs.y) * 0.5)
    }

    func asymmetricBreathProgress(
        time: CGFloat,
        cycleDuration: CGFloat,
        inhalePortion: CGFloat
    ) -> CGFloat {
        let safeCycle = max(cycleDuration, 0.01)
        let inhale = min(max(inhalePortion, 0.1), 0.9)
        let normalizedPhase = (time / safeCycle).truncatingRemainder(dividingBy: 1)
        let phase = normalizedPhase >= 0 ? normalizedPhase : normalizedPhase + 1

        if phase < inhale {
            let local = phase / inhale
            return 0.5 - 0.5 * cos(local * .pi)
        } else {
            let local = (phase - inhale) / (1 - inhale)
            return 0.5 + 0.5 * cos(local * .pi)
        }
    }
}
