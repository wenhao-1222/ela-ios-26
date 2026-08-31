//
//  ElaProPriceCardView.swift
//  lns
//
//  Created by LNS2 on 2026/3/4.
//

import SnapKit

class ElaProPriceCardView: UIView {
    private let blueColor = UIColor.THEME
    private let borderColor = UIColor(named: "color_white_20_pro_border")
    private let titleColor = UIColor.COLOR_TEXT_TITLE_0f1214
    private let subColor = UIColor.COLOR_TEXT_TITLE_0f1214_50
    private let borderLayer = CAShapeLayer()
    private var isCardSelected = false
    private var titleTopConstraint: Constraint?
    private var priceCenterYConstraint: Constraint?
    private var priceBottomConstraint: Constraint?
    private var originBottomConstraint: Constraint?
    private let fadeInDuration: TimeInterval = 0.25
    
    lazy var tagLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 13, weight: .semibold)
        lab.textColor = .white
        lab.textAlignment = .center
        lab.backgroundColor = blueColor
        lab.layer.cornerRadius = kFitWidth(12.5)
        lab.clipsToBounds = true
        return lab
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 15, weight: .semibold)
        lab.textColor = titleColor
        return lab
    }()
    lazy var subTitleLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.textColor = subColor
        return lab
    }()
    lazy var priceLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 28, weight: .semibold)
        lab.textColor = blueColor
        return lab
    }()
    lazy var originLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.textColor = subColor
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(named: "color_white_20_pro")
        layer.cornerRadius = kFitWidth(16)
        clipsToBounds = false
        
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineJoin = .round
        borderLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(borderLayer)
        
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(priceLabel)
        addSubview(originLabel)
        addSubview(tagLabel)
        
        tagLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(kFitWidth(-12.5))
            make.height.equalTo(kFitWidth(25))
            make.width.greaterThanOrEqualTo(kFitWidth(90))
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            self.titleTopConstraint = make.top.equalTo(kFitWidth(28)).constraint
            make.left.greaterThanOrEqualTo(kFitWidth(10))
            make.right.lessThanOrEqualTo(kFitWidth(-10))
            make.height.equalTo(kFitWidth(21))
        }
        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            make.left.greaterThanOrEqualTo(kFitWidth(10))
            make.right.lessThanOrEqualTo(kFitWidth(-10))
        }
        priceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            self.priceCenterYConstraint = make.centerY.equalToSuperview().offset(kFitWidth(22)).constraint
            self.priceBottomConstraint = make.bottom.equalTo(kFitWidth(-42)).constraint
        }
        originLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            self.originBottomConstraint = make.bottom.equalTo(kFitWidth(-24)).constraint
            make.left.greaterThanOrEqualTo(kFitWidth(10))
            make.right.lessThanOrEqualTo(kFitWidth(-10))
        }
        
        priceBottomConstraint?.deactivate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = bounds
        updateBorderPath()
    }
    
    private func updateBorderPath() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        
        let lineWidth: CGFloat = kFitWidth(1.5)
        // 外部页面可能会覆写卡片圆角（例如 Guide0820 使用 12pt）。
        // 边框路径跟随实际圆角，并扣除半个线宽，让描边外沿与背景边界重合。
        let radius = min(max(0, layer.cornerRadius - lineWidth * 0.5),
                         min(bounds.width, bounds.height) * 0.5)
        let insetRect = bounds.insetBy(dx: lineWidth * 0.5, dy: lineWidth * 0.5)
        let topY = insetRect.minY
        let leftX = insetRect.minX
        let rightX = insetRect.maxX
        let bottomY = insetRect.maxY
        let topLeftStart = CGPoint(x: leftX + radius, y: topY)
        
        let path = UIBezierPath()
        path.move(to: topLeftStart)
        path.addLine(to: CGPoint(x: rightX - radius, y: topY))
        path.addArc(withCenter: CGPoint(x: rightX - radius, y: topY + radius),
                    radius: radius,
                    startAngle: -.pi * 0.5,
                    endAngle: 0,
                    clockwise: true)
        path.addLine(to: CGPoint(x: rightX, y: bottomY - radius))
        path.addArc(withCenter: CGPoint(x: rightX - radius, y: bottomY - radius),
                    radius: radius,
                    startAngle: 0,
                    endAngle: .pi * 0.5,
                    clockwise: true)
        path.addLine(to: CGPoint(x: leftX + radius, y: bottomY))
        path.addArc(withCenter: CGPoint(x: leftX + radius, y: bottomY - radius),
                    radius: radius,
                    startAngle: .pi * 0.5,
                    endAngle: .pi,
                    clockwise: true)
        path.addLine(to: CGPoint(x: leftX, y: topY + radius))
        path.addArc(withCenter: CGPoint(x: leftX + radius, y: topY + radius),
                    radius: radius,
                    startAngle: .pi,
                    endAngle: .pi * 1.5,
                    clockwise: true)
        
        borderLayer.path = path.cgPath
        borderLayer.strokeColor = (isCardSelected ? blueColor : borderColor)?.cgColor
        borderLayer.lineWidth = lineWidth
    }
    
    func configure(tag: String?,
                   title: String,
                   subTitle: String?,
                   price: String,
                   originPrice: String?,
                   selected: Bool) {
        tagLabel.text = "  \(tag ?? "")  "
        setTagLabelHidden(tag == nil)
        titleLabel.text = title
        subTitleLabel.text = subTitle
        subTitleLabel.isHidden = (subTitle?.isEmpty ?? true)
        priceLabel.text = price
        backgroundColor = selected ? UIColor(named: "color_white_20_pro_select") : UIColor(named: "color_white_20_pro")
        
        if let originPrice = originPrice, !originPrice.isEmpty {
            let attr = NSMutableAttributedString(string: originPrice)
            attr.addAttributes([
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: subColor
            ], range: NSRange(location: 0, length: originPrice.count))
            originLabel.attributedText = attr
            originLabel.isHidden = false
        } else {
            originLabel.attributedText = nil
            originLabel.text = nil
            originLabel.isHidden = true
        }
        
        isCardSelected = selected
        updateLayoutForCurrentContent()
        setNeedsLayout()
    }

    private func setTagLabelHidden(_ isHidden: Bool) {
        let shouldFadeIn = tagLabel.isHidden && !isHidden
        tagLabel.layer.removeAllAnimations()

        if isHidden {
            tagLabel.isHidden = true
            tagLabel.alpha = 1
            return
        }

        tagLabel.isHidden = false
        guard shouldFadeIn else {
            tagLabel.alpha = 1
            return
        }

        tagLabel.alpha = 0
        UIView.animate(withDuration: fadeInDuration,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction]) {
            self.tagLabel.alpha = 1
        }
    }
    
    private func updateLayoutForCurrentContent() {
        let hasTag = !tagLabel.isHidden
        let hasSubTitle = !subTitleLabel.isHidden
        let hasOriginPrice = !originLabel.isHidden
        
//        titleTopConstraint?.update(offset: hasTag ? kFitWidth(42) : kFitWidth(28))
        
        if hasOriginPrice {
            priceCenterYConstraint?.deactivate()
            priceBottomConstraint?.activate()
            originBottomConstraint?.update(offset: kFitWidth(-24))
        } else {
            priceBottomConstraint?.deactivate()
            priceCenterYConstraint?.activate()
            priceCenterYConstraint?.update(offset: hasSubTitle ? kFitWidth(16) : kFitWidth(22))
        }
    }
}
