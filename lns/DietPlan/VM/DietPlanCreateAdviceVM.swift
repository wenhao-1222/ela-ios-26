//
//  DietPlanCreateAdviceVM.swift
//  lns
//
//  Created by Codex on 2026/2/26.
//

class DietPlanCreateAdviceVM: UIView {

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
        clipsToBounds = true

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
        drawDashLine()
    }

    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.setImgLocal(imgName: "homebg")
        img.alpha = 0.12
        return img
    }()

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "做到以下几点"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .semibold)
        lab.textAlignment = .center
        return lab
    }()

    lazy var subTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "可以很大降低规律饮食的难度"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 17, weight: .regular)
        lab.textAlignment = .center
        return lab
    }()

    lazy var scrollView: UIScrollView = {
        let vi = UIScrollView()
        vi.showsVerticalScrollIndicator = false
        return vi
    }()
    
    lazy var topGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    
    lazy var topGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    
    lazy var bottomGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    
    lazy var bottomGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()

    lazy var contentView: UIView = {
        let vi = UIView()
        return vi
    }()

    lazy var card1: UIView = makeCardView()
    lazy var card2: UIView = makeCardView()
    lazy var card3: UIView = makeCardView()

    lazy var icon1: UIImageView = makeDotIcon()
    lazy var icon2: UIImageView = makeDotIcon()
    lazy var icon3: UIImageView = makeDotIcon()

    lazy var card1Title: UILabel = makeCardTitle("减少日常压力")
    lazy var card2Title: UILabel = makeCardTitle("规律睡眠，避免过度疲劳")
    lazy var card3Title: UILabel = makeCardTitle("使用食谱内的购物清单提前备餐")

    lazy var card1Desc: UILabel = makeCardDesc("压力会放大对高刺激食物的渴求。TSST 压力任务后，皮质醇反应更强的人，随后摄入 854 vs 586 kcal，约多 46%。")
    lazy var card2Desc: UILabel = makeCardDesc("睡眠不足会让你更容易饿。受控实验里，连续2晚睡4小时，瘦素下降18%，对高碳水食物的食欲上升33%到45%。")
    lazy var card3Desc: UILabel = makeCardDesc("训练后食欲和食物奖励感更强，临时做选择更容易选高热量。40分钟有氧后，对高脂食物的隐性想要 15.3→21.8，约+42%。")

    lazy var referenceDashView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        return vi
    }()

    lazy var referenceTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "参考文献"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        return lab
    }()

    lazy var referenceDescLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        lab.text = "Spiegel K, Tasali E, Penev P, Van Cauter E. Ann Intern Med. 2004;141(11):846-850. doi:10.7326/0003-4819-141-11-200412070-00008.\nHerhaus B, Ullmann E, Chrousos G, Petrowski K. Transl Psychiatry. 2020;10:40. doi:10.1038/s41398-020-0729-6.\nHsieh SS, Bala A, Layzell K, et al. Eur J Clin Nutr. 2025;79(12):1204-1210. doi:10.1038/s41430-025-01574-5."
        return lab
    }()
}

extension DietPlanCreateAdviceVM {
    func initUI() {
        addSubview(bgImgView)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(scrollView)
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        scrollView.addSubview(contentView)
        topGradientView.layer.addSublayer(topGradientLayer)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)

        contentView.addSubview(card1)
        contentView.addSubview(card2)
        contentView.addSubview(card3)
        contentView.addSubview(referenceDashView)
        contentView.addSubview(referenceTitleLabel)
        contentView.addSubview(referenceDescLabel)

        [icon1, card1Title, card1Desc].forEach { card1.addSubview($0) }
        [icon2, card2Title, card2Desc].forEach { card2.addSubview($0) }
        [icon3, card3Title, card3Desc].forEach { card3.addSubview($0) }

        setConstraint()
        drawDashLine()
    }

    func setConstraint() {
        let bottomSafe = WHUtils().getBottomSafeAreaHeight()
        let nextButtonTopOffset = bottomSafe + kFitWidth(58)

        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(55))
        }

        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(12))
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom)//.offset(kFitWidth(18))
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(nextButtonTopOffset + kFitWidth(8)))
        }
        
        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(scrollView.snp.top)
            make.height.equalTo(kFitWidth(35))
        }
        
        bottomGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(scrollView.snp.bottom)
            make.height.equalTo(kFitWidth(35))
        }

        contentView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.top.equalTo(kFitWidth(28))
            make.bottom.equalTo(kFitWidth(-28))
            make.width.equalToSuperview()
        }

        card1.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(8))
        }

        card2.snp.makeConstraints { make in
            make.left.right.equalTo(card1)
            make.top.equalTo(card1.snp.bottom).offset(kFitWidth(10))
        }

        card3.snp.makeConstraints { make in
            make.left.right.equalTo(card1)
            make.top.equalTo(card2.snp.bottom).offset(kFitWidth(10))
        }

        layoutCard(icon: icon1, title: card1Title, desc: card1Desc, card: card1)
        layoutCard(icon: icon2, title: card2Title, desc: card2Desc, card: card2)
        layoutCard(icon: icon3, title: card3Title, desc: card3Desc, card: card3)

        referenceDashView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(1))
            make.top.equalTo(card3.snp.bottom).offset(kFitWidth(16))
        }

        referenceTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(referenceDashView.snp.bottom).offset(kFitWidth(14))
        }

        referenceDescLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(referenceTitleLabel.snp.bottom).offset(kFitWidth(8))
            make.bottom.equalToSuperview().offset(kFitWidth(-16))
        }
    }

    func layoutCard(icon: UIImageView, title: UILabel, desc: UILabel, card: UIView) {
        icon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(24))
        }

        title.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(kFitWidth(10))
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalTo(icon)
        }

        desc.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(icon.snp.bottom).offset(kFitWidth(12))
            make.bottom.equalTo(kFitWidth(-16))
        }
    }

    func makeCardView() -> UIView {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        return vi
    }

    func makeDotIcon() -> UIImageView {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.backgroundColor = WHColor_16(colorStr: "D0D0D0")
        img.layer.cornerRadius = kFitWidth(12)
        img.clipsToBounds = true
        return img
    }

    func makeCardTitle(_ text: String) -> UILabel {
        let lab = UILabel()
        lab.text = text
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        return lab
    }

    func makeCardDesc(_ text: String) -> UILabel {
        let lab = UILabel()
        lab.text = text
        lab.numberOfLines = 0
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        return lab
    }

    func drawDashLine() {
        referenceDashView.layoutIfNeeded()
        let lineWidth = referenceDashView.bounds.width
        guard lineWidth > 0 else { return }
        let shape = CAShapeLayer()
        shape.strokeColor = WHColor_16(colorStr: "CFCFCF").cgColor
        shape.lineWidth = 1
        shape.lineDashPattern = [4, 3]
        shape.fillColor = UIColor.clear.cgColor

        let path = CGMutablePath()
        path.addLines(between: [
            CGPoint(x: 0, y: 0.5),
            CGPoint(x: lineWidth, y: 0.5)
        ])
        shape.path = path
        referenceDashView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        referenceDashView.layer.addSublayer(shape)
    }
}
