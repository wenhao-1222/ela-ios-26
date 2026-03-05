//
//  ElaProPriceCardView.swift
//  lns
//
//  Created by LNS2 on 2026/3/4.
//

class ElaProPriceCardView: UIView {
    private let blueColor = UIColor.THEME
    private let borderColor = UIColor(named: "color_white_20_pro_border")
    private let titleColor = UIColor.COLOR_TEXT_TITLE_0f1214
    private let subColor = UIColor.COLOR_TEXT_TITLE_0f1214_50
    private let borderLayer = CAShapeLayer()
    private var isCardSelected = false
    
    lazy var tagLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textColor = .white
        lab.textAlignment = .center
        lab.backgroundColor = blueColor
        lab.layer.cornerRadius = kFitWidth(11.5)
        lab.clipsToBounds = true
        return lab
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 14, weight: .medium)
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
        lab.font = .systemFont(ofSize: 26, weight: .semibold)
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
        layer.cornerRadius = kFitWidth(12)
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
            make.top.equalTo(kFitWidth(-11.5))
            make.height.equalTo(kFitWidth(23))
            make.width.greaterThanOrEqualTo(kFitWidth(65))
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(kFitWidth(18))
            make.left.greaterThanOrEqualTo(kFitWidth(8))
            make.right.lessThanOrEqualTo(kFitWidth(-8))
        }
        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(2))
            make.left.greaterThanOrEqualTo(kFitWidth(8))
            make.right.lessThanOrEqualTo(kFitWidth(-8))
        }
        priceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-32))
//            make.bottom.equalTo(originLabel.snp.top).offset(kFitWidth(-9))
        }
        originLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-7))
            make.left.greaterThanOrEqualTo(kFitWidth(8))
            make.right.lessThanOrEqualTo(kFitWidth(-8))
        }
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
        
        let lineWidth: CGFloat = kFitWidth(1.5)//isCardSelected ? kFitWidth(1.5) : 1
        let radius = min(kFitWidth(12), min(bounds.width, bounds.height) * 0.5)
        let insetRect = bounds.insetBy(dx: lineWidth * 0.5, dy: lineWidth * 0.5)
        let topY = insetRect.minY
        let leftX = insetRect.minX
        let rightX = insetRect.maxX
        let bottomY = insetRect.maxY
        let topLeftStart = CGPoint(x: leftX + radius, y: topY)
        
        let path = UIBezierPath()
        
        if !tagLabel.isHidden {
            // 缺口紧贴 tag 两侧边缘，不再用估算宽度。
            let minGapX = leftX + radius + 1
            let maxGapX = rightX - radius - 1
            let rawStartX = tagLabel.frame.minX
            let rawEndX = tagLabel.frame.maxX
            let gapStartX = max(minGapX, min(rawStartX, maxGapX))
            let gapEndX = min(maxGapX, max(rawEndX, minGapX))
            
            path.move(to: topLeftStart)
            if gapEndX > gapStartX {
                path.addLine(to: CGPoint(x: gapStartX, y: topY))
                path.move(to: CGPoint(x: gapEndX, y: topY))
            }
        } else {
            path.move(to: topLeftStart)
        }
        
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
        tagLabel.isHidden = tag == nil
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
        setNeedsLayout()
    }
}
