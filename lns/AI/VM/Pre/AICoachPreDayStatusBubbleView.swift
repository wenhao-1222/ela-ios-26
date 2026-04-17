//
//  AICoachPreDayStatusBubbleView.swift
//  lns
//
//  Created by LNS2 on 2026/4/17.
//

class AICoachPreDayStatusBubbleView: UIView {

    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let tintView = UIView()
    private let borderLayer = CAShapeLayer()
    private let cornerRadius = kFitWidth(14)
    private var arrowCenterX = AICoachPrePopupLayout.minWidth * 0.5
    private let blurMaskLayer = CAShapeLayer()
    private let tintMaskLayer = CAShapeLayer()

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        refreshColors()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(blurEffectView)
        addSubview(tintView)
        layer.addSublayer(borderLayer)
        blurEffectView.layer.mask = blurMaskLayer
        tintView.layer.mask = tintMaskLayer
        blurEffectView.isUserInteractionEnabled = false
        tintView.isUserInteractionEnabled = false
        refreshColors()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateArrowPosition(centerX: CGFloat) {
        arrowCenterX = centerX
        setNeedsLayout()
    }

    func refreshColors() {
        tintView.backgroundColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.94)
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.COLOR_CARD_BG_WHITE.withAlphaComponent(0.98).cgColor
        borderLayer.lineWidth = 2
        borderLayer.lineJoin = .round
        borderLayer.lineCap = .round
        borderLayer.zPosition = 10
        layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 16
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let path = bubblePath(in: bounds)
        blurEffectView.frame = bounds
        tintView.frame = bounds
        blurMaskLayer.frame = bounds
        blurMaskLayer.path = path.cgPath
        tintMaskLayer.frame = bounds
        tintMaskLayer.path = path.cgPath
        borderLayer.frame = bounds
        borderLayer.path = path.cgPath
        layer.shadowPath = path.cgPath
    }

    private func bubblePath(in rect: CGRect) -> UIBezierPath {
        let lineWidth = borderLayer.lineWidth
        let insetRect = rect.insetBy(dx: lineWidth * 0.5, dy: lineWidth * 0.5)
        let topY = insetRect.minY + AICoachPrePopupLayout.arrowHeight
        let leftX = insetRect.minX
        let rightX = insetRect.maxX
        let bottomY = insetRect.maxY
        let radius = min(cornerRadius, (bottomY - topY) * 0.5)

        let arrowHalfWidth = AICoachPrePopupLayout.arrowWidth * 0.5
        let tipX = min(max(arrowCenterX, leftX + radius + arrowHalfWidth), rightX - radius - arrowHalfWidth)
        let leftShoulderX = tipX - arrowHalfWidth
        let rightShoulderX = tipX + arrowHalfWidth
        let tipY = insetRect.minY + 1

        let path = UIBezierPath()
        path.move(to: CGPoint(x: leftX + radius, y: topY))
        path.addLine(to: CGPoint(x: leftShoulderX, y: topY))
        path.addCurve(
            to: CGPoint(x: tipX, y: tipY),
            controlPoint1: CGPoint(x: tipX - arrowHalfWidth * 0.62, y: topY),
            controlPoint2: CGPoint(x: tipX - arrowHalfWidth * 0.28, y: tipY)
        )
        path.addCurve(
            to: CGPoint(x: rightShoulderX, y: topY),
            controlPoint1: CGPoint(x: tipX + arrowHalfWidth * 0.28, y: tipY),
            controlPoint2: CGPoint(x: tipX + arrowHalfWidth * 0.62, y: topY)
        )
        path.addLine(to: CGPoint(x: rightX - radius, y: topY))
        path.addArc(withCenter: CGPoint(x: rightX - radius, y: topY + radius), radius: radius, startAngle: -.pi * 0.5, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: rightX, y: bottomY - radius))
        path.addArc(withCenter: CGPoint(x: rightX - radius, y: bottomY - radius), radius: radius, startAngle: 0, endAngle: .pi * 0.5, clockwise: true)
        path.addLine(to: CGPoint(x: leftX + radius, y: bottomY))
        path.addArc(withCenter: CGPoint(x: leftX + radius, y: bottomY - radius), radius: radius, startAngle: .pi * 0.5, endAngle: .pi, clockwise: true)
        path.addLine(to: CGPoint(x: leftX, y: topY + radius))
        path.addArc(withCenter: CGPoint(x: leftX + radius, y: topY + radius), radius: radius, startAngle: .pi, endAngle: -.pi * 0.5, clockwise: true)
        path.close()
        return path
    }
}
