//
//  GuidanceProFlowBackgroundView.swift
//  lns
//
//  Created by LNS2 on 2026/3/20.
//

class GuidanceProFlowBackgroundView: UIView {

    private struct BeamConfig {
        let color: UIColor
        let alpha: CGFloat
        let frameProvider: (CGRect) -> CGRect
        let fromOffset: CGPoint
        let toOffset: CGPoint
        let scaleRange: (CGFloat, CGFloat)
        let opacityRange: (CGFloat, CGFloat)
        let duration: CFTimeInterval
        let beginTime: CFTimeInterval
    }

    private let baseGradientLayer = CAGradientLayer()
    private let topMistLayer = CAGradientLayer()
    private let canopyGlowLayer = CAGradientLayer()
    private let ambientBeamLayer = CAGradientLayer()
    private let fadeMaskLayer = CAGradientLayer()
    private var beamLayers: [CAGradientLayer] = []
    private var baseBeamFrames: [CGRect] = []
    private var displayLink: CADisplayLink?
    private var phase: CGFloat = 0

    private let beamConfigs: [BeamConfig] = [
        BeamConfig(
            color: GuidanceProPalette.beamWhite,
            alpha: 0.34,
            frameProvider: { bounds in
                CGRect(x: -bounds.width * 0.10,
                       y: -bounds.height * 0.30,
                       width: bounds.width * 0.54,
                       height: bounds.height * 1.44)
            },
            fromOffset: CGPoint(x: -28, y: -10),
            toOffset: CGPoint(x: 44, y: 14),
            scaleRange: (0.92, 1.08),
            opacityRange: (0.18, 0.32),
            duration: 15.8,
            beginTime: 0.0
        ),
        BeamConfig(
            color: GuidanceProPalette.beamBlue,
            alpha: 0.28,
            frameProvider: { bounds in
                CGRect(x: bounds.width * 0.22,
                       y: -bounds.height * 0.22,
                       width: bounds.width * 0.42,
                       height: bounds.height * 1.32)
            },
            fromOffset: CGPoint(x: 18, y: -14),
            toOffset: CGPoint(x: -36, y: 18),
            scaleRange: (0.90, 1.06),
            opacityRange: (0.14, 0.26),
            duration: 18.4,
            beginTime: 1.6
        ),
        BeamConfig(
            color: GuidanceProPalette.beamWhite,
            alpha: 0.26,
            frameProvider: { bounds in
                CGRect(x: bounds.width * 0.50,
                       y: -bounds.height * 0.28,
                       width: bounds.width * 0.48,
                       height: bounds.height * 1.42)
            },
            fromOffset: CGPoint(x: -20, y: -8),
            toOffset: CGPoint(x: 32, y: 12),
            scaleRange: (0.94, 1.10),
            opacityRange: (0.12, 0.24),
            duration: 17.2,
            beginTime: 0.9
        )
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        clipsToBounds = true
        setupLayers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerFrames()
        renderCurrentFrame()
    }

    func startAnimatingIfNeeded() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func pauseAnimating() {
        displayLink?.invalidate()
        displayLink = nil
    }

    deinit {
        displayLink?.invalidate()
    }
}

private extension GuidanceProFlowBackgroundView {
    func setupLayers() {
        baseGradientLayer.colors = [
            GuidanceProPalette.topSky.cgColor,
            GuidanceProPalette.midSky.cgColor,
            GuidanceProPalette.midSky.cgColor,
            UIColor.white.cgColor
        ]
        baseGradientLayer.locations = [0.0, 0.22, 0.60, 1.0]
        baseGradientLayer.startPoint = CGPoint(x: 0.50, y: 0.0)
        baseGradientLayer.endPoint = CGPoint(x: 0.50, y: 1.0)
        layer.addSublayer(baseGradientLayer)

        topMistLayer.type = .radial
        topMistLayer.colors = [
            GuidanceProPalette.topMist.withAlphaComponent(0.78).cgColor,
            GuidanceProPalette.topMist.withAlphaComponent(0.22).cgColor,
            UIColor.clear.cgColor
        ]
        topMistLayer.locations = [0.0, 0.42, 1.0]
        topMistLayer.startPoint = CGPoint(x: 0.50, y: 0.08)
        topMistLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.addSublayer(topMistLayer)

        canopyGlowLayer.type = .radial
        canopyGlowLayer.colors = [
            UIColor.white.withAlphaComponent(0.42).cgColor,
            GuidanceProPalette.topMist.withAlphaComponent(0.18).cgColor,
            UIColor.clear.cgColor
        ]
        canopyGlowLayer.locations = [0.0, 0.30, 1.0]
        canopyGlowLayer.startPoint = CGPoint(x: 0.50, y: 0.02)
        canopyGlowLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        canopyGlowLayer.opacity = 0.86
        layer.addSublayer(canopyGlowLayer)

        ambientBeamLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.10).cgColor,
            GuidanceProPalette.beamBlue.withAlphaComponent(0.14).cgColor,
            UIColor.white.withAlphaComponent(0.12).cgColor,
            UIColor.clear.cgColor
        ]
        ambientBeamLayer.locations = [0.0, 0.18, 0.50, 0.84, 1.0]
        ambientBeamLayer.startPoint = CGPoint(x: 0.50, y: 0.0)
        ambientBeamLayer.endPoint = CGPoint(x: 0.50, y: 1.0)
        ambientBeamLayer.opacity = 0.68
        layer.addSublayer(ambientBeamLayer)

        beamLayers = beamConfigs.map { config in
            let beamLayer = CAGradientLayer()
            beamLayer.type = .radial
            beamLayer.colors = [
                config.color.withAlphaComponent(config.alpha).cgColor,
                config.color.withAlphaComponent(config.alpha * 0.34).cgColor,
                config.color.withAlphaComponent(0.0).cgColor
            ]
            beamLayer.locations = [0.0, 0.22, 1.0]
            beamLayer.startPoint = CGPoint(x: 0.50, y: 0.03)
            beamLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            beamLayer.opacity = Float(config.opacityRange.0)
            layer.addSublayer(beamLayer)
            return beamLayer
        }

        fadeMaskLayer.colors = [
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.white.withAlphaComponent(0.82).cgColor,
            UIColor.clear.cgColor
        ]
        fadeMaskLayer.locations = [0.0, 0.68, 0.84, 1.0]
        fadeMaskLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        fadeMaskLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.mask = fadeMaskLayer
    }

    func updateLayerFrames() {
        baseGradientLayer.frame = bounds
        fadeMaskLayer.frame = bounds
        topMistLayer.frame = CGRect(
            x: -bounds.width * 0.42,
            y: -bounds.height * 0.78,
            width: bounds.width * 1.84,
            height: bounds.height * 1.36
        )
        canopyGlowLayer.frame = CGRect(
            x: -bounds.width * 0.36,
            y: -bounds.height * 0.86,
            width: bounds.width * 1.72,
            height: bounds.height * 1.14
        )
        ambientBeamLayer.frame = CGRect(
            x: bounds.width * 0.12,
            y: -bounds.height * 0.08,
            width: bounds.width * 0.76,
            height: bounds.height * 1.20
        )
        baseBeamFrames = []

        for (index, beamLayer) in beamLayers.enumerated() {
            let frame = beamConfigs[index].frameProvider(bounds)
            beamLayer.frame = frame
            baseBeamFrames.append(frame)
        }
    }

    @objc func tick() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        phase += 0.0105
        renderCurrentFrame()
    }

    func renderCurrentFrame() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        let primaryWave = (sin(phase * 0.42) + 1) * 0.5
        let secondaryWave = (cos(phase * 0.34) + 1) * 0.5
        let tertiaryWave = (sin(phase * 0.56 + 0.8) + 1) * 0.5

        let topColor = GuidanceProPalette.topSky.mix(with: GuidanceProPalette.topMist, progress: primaryWave * 0.28)
        let middleColor = GuidanceProPalette.midSky.mix(with: GuidanceProPalette.beamBlue, progress: secondaryWave * 0.16)
        let lowerColor = GuidanceProPalette.midSky.mix(with: UIColor.white, progress: tertiaryWave * 0.30)
        baseGradientLayer.colors = [
            topColor.cgColor,
            middleColor.cgColor,
            lowerColor.cgColor,
            UIColor.white.cgColor
        ]

        baseGradientLayer.startPoint = CGPoint(
            x: 0.46 + sin(phase * 0.10) * 0.04,
            y: 0.0
        )
        baseGradientLayer.endPoint = CGPoint(
            x: 0.54 + cos(phase * 0.10) * 0.04,
            y: 1.0
        )
        baseGradientLayer.locations = [
            0.0,
            NSNumber(value: Double(0.18 + secondaryWave * 0.05)),
            NSNumber(value: Double(0.58 + primaryWave * 0.08)),
            1.0
        ]

        topMistLayer.position = CGPoint(
            x: bounds.midX + sin(phase * 0.24) * bounds.width * 0.08,
            y: bounds.height * 0.02 + cos(phase * 0.18) * 8
        )
        topMistLayer.opacity = Float(0.68 + secondaryWave * 0.12)

        canopyGlowLayer.position = CGPoint(
            x: bounds.midX + cos(phase * 0.20) * bounds.width * 0.10,
            y: bounds.height * 0.01 + sin(phase * 0.16) * 6
        )
        canopyGlowLayer.opacity = Float(0.78 + primaryWave * 0.12)

        ambientBeamLayer.position = CGPoint(
            x: bounds.midX + sin(phase * 0.30) * bounds.width * 0.14,
            y: bounds.midY
        )
        ambientBeamLayer.opacity = Float(0.50 + tertiaryWave * 0.16)

        for (index, beamLayer) in beamLayers.enumerated() {
            let config = beamConfigs[index]
            guard index < baseBeamFrames.count else { continue }
            let baseFrame = baseBeamFrames[index]
            let time = phase + CGFloat(config.beginTime)
            let progress = (sin(time * CGFloat(8.0 / config.duration)) + 1) * 0.5
            let secondary = (cos(time * CGFloat(6.0 / config.duration)) + 1) * 0.5

            let offsetX = config.fromOffset.x + (config.toOffset.x - config.fromOffset.x) * progress
            let offsetY = config.fromOffset.y + (config.toOffset.y - config.fromOffset.y) * secondary
            let scale = config.scaleRange.0 + (config.scaleRange.1 - config.scaleRange.0) * progress
            let opacity = config.opacityRange.0 + (config.opacityRange.1 - config.opacityRange.0) * secondary

            let scaledWidth = baseFrame.width * scale
            let scaledHeight = baseFrame.height * scale
            beamLayer.frame = CGRect(
                x: baseFrame.midX - scaledWidth * 0.5 + offsetX,
                y: baseFrame.midY - scaledHeight * 0.5 + offsetY,
                width: scaledWidth,
                height: scaledHeight
            )
            beamLayer.opacity = Float(opacity)
        }
    }
}

private enum GuidanceProPalette {
    static let topSky = UIColor(hex: 0xCFE2FF)
    static let midSky = UIColor(hex: 0xF4F8FF)
    static let topMist = UIColor(hex: 0xC5D9FF)
    static let beamWhite = UIColor.white
    static let beamBlue = UIColor(hex: 0xDCEBFF)
}

private extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    func mix(with color: UIColor, progress: CGFloat) -> UIColor {
        let clamped = max(0, min(1, progress))

        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0
        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0

        guard getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1),
              color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2) else {
            return self
        }

        return UIColor(
            red: red1 + (red2 - red1) * clamped,
            green: green1 + (green2 - green1) * clamped,
            blue: blue1 + (blue2 - blue1) * clamped,
            alpha: alpha1 + (alpha2 - alpha1) * clamped
        )
    }
}
