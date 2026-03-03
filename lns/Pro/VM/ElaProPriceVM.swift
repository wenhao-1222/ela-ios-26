//
//  ElaProPriceVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/3.
//


class ElaProPriceVM: UIView {
    private let selectedBlue = WHColor_16(colorStr: "1677F2")
    private let normalTextColor = WHColor_16(colorStr: "0F1214")
    private let subTextColor = WHColor_16(colorStr: "8C8D94")
    private let lightBorderColor = WHColor_16(colorStr: "EEF1F5")
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_bg")
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        
        return img
    }()
    lazy var scrollView: UIScrollView = {
        let vi = UIScrollView()
        vi.showsVerticalScrollIndicator = false
        return vi
    }()
    lazy var contentView: UIView = {
        let vi = UIView()
        return vi
    }()
    lazy var logoImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_icon")
        img.contentMode = .scaleAspectFit
        return img
    }()
    lazy var subTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "专业健身饮食，助你精准达成目标"
        lab.textColor = subTextColor
        lab.font = .systemFont(ofSize: 18, weight: .regular)
        lab.textAlignment = .center
        return lab
    }()
    lazy var cardContainer: UIView = {
        let vi = UIView()
        return vi
    }()
    lazy var monthCard: ElaProPriceCardView = {
        let vm = ElaProPriceCardView()
        vm.configure(tag: "首月特惠",
                     title: "连续包月",
                     subTitle: nil,
                     price: "¥9",
                     originPrice: "¥19/月",
                     selected: false)
        return vm
    }()
    lazy var yearCard: ElaProPriceCardView = {
        let vm = ElaProPriceCardView()
        vm.configure(tag: "首年特惠",
                     title: "连续包年",
                     subTitle: "每月仅需¥10.66",
                     price: "¥128",
                     originPrice: "¥198/年",
                     selected: true)
        return vm
    }()
    lazy var lifeCard: ElaProPriceCardView = {
        let vm = ElaProPriceCardView()
        vm.configure(tag: nil,
                     title: "终身会员",
                     subTitle: nil,
                     price: "¥598",
                     originPrice: nil,
                     selected: false)
        return vm
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "首年128，随后198/年，可随时取消"
        lab.textColor = subTextColor
        lab.font = .systemFont(ofSize: 19, weight: .regular)
        lab.textAlignment = .center
        return lab
    }()
    lazy var benefitTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "ELA PRO 将帮助你："
        lab.textColor = normalTextColor
        lab.font = .systemFont(ofSize: 22, weight: .semibold)
        return lab
    }()
    lazy var benefitContainer: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        vi.layer.cornerRadius = kFitWidth(16)
        vi.layer.borderWidth = 1
        vi.layer.borderColor = lightBorderColor.cgColor
        vi.clipsToBounds = true
        return vi
    }()
    lazy var benefitOne = makeBenefitRow(title: "定制每周食谱", desc: "每天不重样，照着吃就行")
    lazy var benefitTwo = makeBenefitRow(title: "消除选择困难", desc: "不用每天纠结吃什么")
    lazy var benefitThree = makeBenefitRow(title: "平衡家庭与健康饮食", desc: "和家人同桌，也能精准对齐目标")
    lazy var dividerOne = makeDivider()
    lazy var dividerTwo = makeDivider()
    lazy var bottomBar: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor.white.withAlphaComponent(0.94)
        return vi
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("确认", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = selectedBlue
        btn.layer.cornerRadius = kFitWidth(28)
        btn.clipsToBounds = true
        return btn
    }()
    lazy var dailyPriceLabel: UILabel = {
        let lab = UILabel()
        lab.text = "0.35元/天"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.textAlignment = .center
        lab.backgroundColor = WHColor_16(colorStr: "FF8F29")
        lab.layer.cornerRadius = kFitWidth(13)
        lab.clipsToBounds = true
        return lab
    }()
    lazy var agreeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(makeCircleImage(color: WHColor_16(colorStr: "BFC3CA")), for: .normal)
        btn.setImage(makeCheckedImage(), for: .selected)
        btn.isSelected = false
        btn.addTarget(self, action: #selector(toggleAgreeAction), for: .touchUpInside)
        return btn
    }()
    lazy var agreementLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 1
        let allText = "已阅读并同意《ELA PRO条款》《自动订阅协议》"
        let attr = NSMutableAttributedString(string: allText)
        attr.addAttributes([
            .foregroundColor: subTextColor,
            .font: UIFont.systemFont(ofSize: 11, weight: .regular)
        ], range: NSRange(location: 0, length: allText.count))
        if let range = allText.range(of: "《ELA PRO条款》《自动订阅协议》") {
            let nsRange = NSRange(range, in: allText)
            attr.addAttributes([
                .foregroundColor: selectedBlue
            ], range: nsRange)
        }
        lab.attributedText = attr
        return lab
    }()
}

extension ElaProPriceVM{
    @objc func toggleAgreeAction() {
        agreeButton.isSelected.toggle()
    }
    
    func initUI() {
        addSubview(bgImgView)
        addSubview(scrollView)
        addSubview(bottomBar)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(logoImgView)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(cardContainer)
        contentView.addSubview(tipsLabel)
        contentView.addSubview(benefitTitleLabel)
        contentView.addSubview(benefitContainer)
        
        cardContainer.addSubview(monthCard)
        cardContainer.addSubview(yearCard)
        cardContainer.addSubview(lifeCard)
        
        benefitContainer.addSubview(benefitOne)
        benefitContainer.addSubview(benefitTwo)
        benefitContainer.addSubview(benefitThree)
        benefitContainer.addSubview(dividerOne)
        benefitContainer.addSubview(dividerTwo)
        
        bottomBar.addSubview(confirmButton)
        bottomBar.addSubview(dailyPriceLabel)
        bottomBar.addSubview(agreeButton)
        bottomBar.addSubview(agreementLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bottomBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(145) + WHUtils().getBottomSafeAreaHeight())
        }
        
        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(20))
            make.height.equalTo(kFitWidth(56))
        }
        
        dailyPriceLabel.snp.makeConstraints { make in
            make.right.equalTo(confirmButton.snp.right)
            make.bottom.equalTo(confirmButton.snp.top).offset(kFitWidth(5))
            make.width.equalTo(kFitWidth(70))
            make.height.equalTo(kFitWidth(26))
        }
        
        agreeButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(84))
            make.top.equalTo(confirmButton.snp.bottom).offset(kFitWidth(17))
            make.width.height.equalTo(kFitWidth(16))
        }
        
        agreementLabel.snp.makeConstraints { make in
            make.centerY.equalTo(agreeButton)
            make.left.equalTo(agreeButton.snp.right).offset(kFitWidth(10))
            make.right.lessThanOrEqualTo(kFitWidth(-20))
        }
        
        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(bottomBar.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        logoImgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(28))
            make.width.equalTo(kFitWidth(220))
            make.height.equalTo(kFitWidth(52))
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImgView.snp.bottom).offset(kFitWidth(24))
            make.centerX.equalToSuperview()
        }
        
        cardContainer.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(subTitleLabel.snp.bottom).offset(kFitWidth(34))
            make.height.equalTo(kFitWidth(182))
        }
        
        let cardGap = kFitWidth(14)
        monthCard.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }
        yearCard.snp.makeConstraints { make in
            make.left.equalTo(monthCard.snp.right).offset(cardGap)
            make.top.bottom.width.equalTo(monthCard)
        }
        lifeCard.snp.makeConstraints { make in
            make.left.equalTo(yearCard.snp.right).offset(cardGap)
            make.right.equalToSuperview()
            make.top.bottom.width.equalTo(monthCard)
        }
        
        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cardContainer.snp.bottom).offset(kFitWidth(30))
        }
        
        benefitTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(tipsLabel.snp.bottom).offset(kFitWidth(42))
        }
        
        benefitContainer.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(benefitTitleLabel.snp.bottom).offset(kFitWidth(18))
            make.bottom.equalToSuperview().offset(kFitWidth(-20))
        }
        
        benefitOne.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(100))
        }
        dividerOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(72))
            make.right.equalToSuperview()
            make.top.equalTo(benefitOne.snp.bottom)
            make.height.equalTo(kFitWidth(1))
        }
        
        benefitTwo.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dividerOne.snp.bottom)
            make.height.equalTo(kFitWidth(100))
        }
        dividerTwo.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(72))
            make.right.equalToSuperview()
            make.top.equalTo(benefitTwo.snp.bottom)
            make.height.equalTo(kFitWidth(1))
        }
        
        benefitThree.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dividerTwo.snp.bottom)
            make.height.equalTo(kFitWidth(100))
            make.bottom.equalToSuperview()
        }
    }
    
    func makeBenefitRow(title: String, desc: String) -> UIView {
        let row = UIView()
        let dot = UIView()
        dot.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        dot.layer.cornerRadius = kFitWidth(18)
        dot.clipsToBounds = true
        
        let titleLab = UILabel()
        titleLab.text = title
        titleLab.textColor = normalTextColor
        titleLab.font = .systemFont(ofSize: 24, weight: .semibold)
        
        let descLab = UILabel()
        descLab.text = desc
        descLab.textColor = subTextColor
        descLab.font = .systemFont(ofSize: 18, weight: .regular)
        
        row.addSubview(dot)
        row.addSubview(titleLab)
        row.addSubview(descLab)
        
        dot.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.top.equalTo(kFitWidth(18))
            make.width.height.equalTo(kFitWidth(36))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(72))
            make.top.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
        }
        descLab.snp.makeConstraints { make in
            make.left.right.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(8))
        }
        
        return row
    }
    
    func makeDivider() -> UIView {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "E7EAF0")
        return vi
    }
    
    func makeCircleImage(color: UIColor) -> UIImage {
        let size = CGSize(width: kFitWidth(24), height: kFitWidth(24))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(color.cgColor)
        context?.setLineWidth(2)
        context?.addEllipse(in: CGRect(x: 1, y: 1, width: size.width - 2, height: size.height - 2))
        context?.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
    
    func makeCheckedImage() -> UIImage {
        let size = CGSize(width: kFitWidth(24), height: kFitWidth(24))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        
        context.setFillColor(selectedBlue.cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2.4)
        context.setLineCap(.round)
        context.move(to: CGPoint(x: size.width * 0.28, y: size.height * 0.53))
        context.addLine(to: CGPoint(x: size.width * 0.45, y: size.height * 0.69))
        context.addLine(to: CGPoint(x: size.width * 0.72, y: size.height * 0.36))
        context.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}

class ElaProPriceCardView: UIView {
    private let blueColor = UIColor.THEME
    private let borderColor = UIColor.COLOR_WHITE_65
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
        lab.layer.cornerRadius = kFitWidth(14)
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
        layer.cornerRadius = kFitWidth(18)
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
            make.top.equalTo(kFitWidth(-15))
            make.height.equalTo(kFitWidth(28))
            make.width.greaterThanOrEqualTo(kFitWidth(86))
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(kFitWidth(28))
            make.left.greaterThanOrEqualTo(kFitWidth(8))
            make.right.lessThanOrEqualTo(kFitWidth(-8))
        }
        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            make.left.greaterThanOrEqualTo(kFitWidth(8))
            make.right.lessThanOrEqualTo(kFitWidth(-8))
        }
        priceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(originLabel.snp.top).offset(kFitWidth(-10))
        }
        originLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-18))
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
        
        let lineWidth: CGFloat = isCardSelected ? 2 : 1
        let radius = min(kFitWidth(18), min(bounds.width, bounds.height) * 0.5)
        let insetRect = bounds.insetBy(dx: lineWidth * 0.5, dy: lineWidth * 0.5)
        let topY = insetRect.minY
        let leftX = insetRect.minX
        let rightX = insetRect.maxX
        let bottomY = insetRect.maxY
        let topLeftStart = CGPoint(x: leftX + radius, y: topY)
        
        let path = UIBezierPath()
        
        if !tagLabel.isHidden {
            let tagWidth = max(kFitWidth(86), tagLabel.bounds.width)
            let maxGap = max(0, insetRect.width - radius * 2 - 6)
            let gapWidth = min(tagWidth + kFitWidth(18), maxGap)
            let gapStartX = insetRect.midX - gapWidth * 0.5
            let gapEndX = insetRect.midX + gapWidth * 0.5
            path.move(to: topLeftStart)
            path.addLine(to: CGPoint(x: gapStartX, y: topY))
            path.move(to: CGPoint(x: gapEndX, y: topY))
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
        borderLayer.strokeColor = (isCardSelected ? blueColor : borderColor).cgColor
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
