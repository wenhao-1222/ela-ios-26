//
//  AICoachBreathingOrbDemoViewController.swift
//  lns
//
//  Created by Codex on 2026/3/19.
//

import UIKit

final class AICoachBreathingOrbDemoViewController: UIViewController {
    private let backdropView = AICoachBreathingBackdropView()
    private let orbView = AICoachBreathingOrbView()
    private let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        navigationItem.title = "AI教练"
        navigationItem.largeTitleDisplayMode = .never

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "AI教练"
        titleLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.08, alpha: 1.0)

        backdropView.translatesAutoresizingMaskIntoConstraints = false

        orbView.translatesAutoresizingMaskIntoConstraints = false
        orbView.backgroundColor = .clear

        view.addSubview(backdropView)
        view.addSubview(titleLabel)
        view.addSubview(orbView)

        NSLayoutConstraint.activate([
            backdropView.topAnchor.constraint(equalTo: view.topAnchor),
            backdropView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdropView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.15),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            orbView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 44),
            orbView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            orbView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.84),
            orbView.heightAnchor.constraint(equalTo: orbView.widthAnchor)
        ])
    }
}

private final class AICoachBreathingBackdropView: UIView {
    private let haloLayers: [CAShapeLayer] = (0..<2).map { _ in CAShapeLayer() }
    private let topGlowLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        topGlowLayer.frame = bounds

        let width = bounds.width
        let center = CGPoint(x: bounds.midX, y: bounds.height * 0.36)
        let baseDiameter = width * 1.10
        let lineWidths: [CGFloat] = [1.0, 1.25]
        let scaleFactors: [CGFloat] = [1.0, 0.72]

        for (index, haloLayer) in haloLayers.enumerated() {
            let diameter = baseDiameter * scaleFactors[index]
            let rect = CGRect(
                x: center.x - diameter / 2,
                y: center.y - diameter / 2,
                width: diameter,
                height: diameter
            )
            haloLayer.path = UIBezierPath(ovalIn: rect).cgPath
            haloLayer.lineWidth = lineWidths[index]
        }

        CATransaction.commit()
    }
}

private extension AICoachBreathingBackdropView {
    func configure() {
        backgroundColor = .clear
        isUserInteractionEnabled = false

        if #available(iOS 12.0, *) {
            topGlowLayer.type = .radial
        }
        topGlowLayer.colors = [
            UIColor.white.withAlphaComponent(0.12).cgColor,
            UIColor.white.withAlphaComponent(0.04).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        topGlowLayer.locations = [0.0, 0.42, 1.0]
        topGlowLayer.startPoint = CGPoint(x: 0.5, y: 0.34)
        topGlowLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.addSublayer(topGlowLayer)

        haloLayers.forEach {
            $0.fillColor = UIColor.clear.cgColor
            $0.strokeColor = AICoachBreathingOrbPalette.haloStroke.cgColor
            layer.addSublayer($0)
        }
    }
}
