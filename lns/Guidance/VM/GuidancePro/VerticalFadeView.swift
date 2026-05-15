//
//  VerticalFadeView.swift
//  lns
//
//  Created by LNS2 on 2026/5/15.
//

class VerticalFadeView: UIView {

    var startColor: UIColor = .clear {
        didSet { updateGradient() }
    }

    var endColor: UIColor = .white {
        didSet { updateGradient() }
    }

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(gradientLayer)
        updateGradient()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private func updateGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0,0.2, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
}
