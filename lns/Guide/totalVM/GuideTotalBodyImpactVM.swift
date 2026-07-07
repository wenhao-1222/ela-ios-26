//
//  GuideTotalBodyImpactVM.swift
//  lns
//
//  Created by Codex on 2026/7/6.
//

class GuideTotalBodyImpactVM: UIView {
    
    var selfHeight = SCREEN_HEIGHT
    var nextBlock:(()->())?
    
    private var selectedIndex = 0
    private let tabTitles = ["健康", "约会", "事业", "社交"]
    private lazy var tabButtons: [UIButton] = [healthButton, dateButton, careerButton, socialButton]
    
    private let impactSections: [[ImpactItem]] = [
        [
            ImpactItem(title: "更长寿命",
                       detail: "体重和体脂处于健康范围的人，全因死亡风险更低。",
                       source: "Global BMI Mortality Collaboration. The Lancet. 2016."),
            ImpactItem(title: "更低心脏病风险",
                       detail: "腰腹脂肪越多，心肌梗死等心血管事件风险越高。",
                       source: "Yusuf et al. The Lancet. 2005."),
            ImpactItem(title: "更低糖尿病风险",
                       detail: "BMI 和腰围越高，2 型糖尿病发生风险越高。",
                       source: "Jayedi et al. BMJ. 2022."),
            ImpactItem(title: "更低癌症风险",
                       detail: "避免过量体脂，可降低多种常见癌症的发生风险。",
                       source: "Lauby-Secretan et al. New England Journal of Medicine. 2016, IARC Working Group.")
        ],
        [
            ImpactItem(title: "更强第一眼吸引",
                       detail: "外貌吸引力是初始浪漫吸引的最强预测因素之一。",
                       source: "Luo & Zhang, Journal of Personality, 2009."),
            ImpactItem(title: "更高线上约会优势",
                       detail: "线上交友数据中，外貌评分、身高、体重和 BMI 都会影响伴侣偏好。",
                       source: "Hitsch, Hortacsu & Ariely, American Economic Review, 2010."),
            ImpactItem(title: "更有吸引力的身体线条",
                       detail: "女性样本中，腰臀比和体脂分布会影响身体吸引力评分。",
                       source: "Singh, Journal of Personality and Social Psychology, 1993."),
            ImpactItem(title: "更强力量吸引",
                       detail: "男性样本中，上肢力量线索解释了超过 70% 的身体吸引力差异，精瘦度也更受偏好。",
                       source: "Sell et al., Proceedings of the Royal Society B, 2017.")
        ],
        [
            ImpactItem(title: "更高收入机会",
                       detail: "研究发现，外貌吸引力与收入存在显著关联。",
                       source: "Hamermesh & Biddle, American Economic Review, 1994."),
            ImpactItem(title: "更好招聘评价",
                       detail: "职场实验的荟萃分析发现，外貌吸引力会影响招聘和工作相关评价。",
                       source: "Hosoda, Stone Romero & Coats, Personnel Psychology, 2003."),
            ImpactItem(title: "更容易获得面试回应",
                       detail: "实地招聘实验中，肥胖形象的求职者受到差异化对待。",
                       source: "Rooth, Journal of Human Resources, 2009."),
            ImpactItem(title: "更少工作损失",
                       detail: "肥胖与更多病假和生产力损失相关。",
                       source: "Goettler et al., PharmacoEconomics, 2017.")
        ],
        [
            ImpactItem(title: "更好的第一印象",
                       detail: "外貌吸引力会带来光环效应，让人被赋予更积极的性格判断。",
                       source: "Dion, Berscheid & Walster, Journal of Personality and Social Psychology, 1972."),
            ImpactItem(title: "更高社交评价",
                       detail: "荟萃分析显示，更有吸引力的人通常会获得更积极的社会判断和对待。",
                       source: "Langlois et al., Psychological Bulletin, 2000."),
            ImpactItem(title: "更少身材偏见",
                       detail: "高体重人群在社交和公共场景中更容易遭遇污名与歧视。",
                       source: "Puhl & Heuer, Obesity, 2009."),
            ImpactItem(title: "更自在的社交状态",
                       detail: "运动干预能改善身体形象，身体形象越好，社交中的自我感受通常也更稳定。",
                       source: "Campbell & Hausenblas, Journal of Health Psychology, 2009; Zartaloudi et al., 2021.")
        ]
    ]
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_F5
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.text = "欢迎来到 Elavatine\n你的身材影响的不只是外表"
        lab.numberOfLines = 2
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 25, weight: .semibold)
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
    
    lazy var tabStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()
    
    lazy var healthButton: UIButton = {
        return createTabButton(title: tabTitles[0], tag: 0)
    }()
    
    lazy var dateButton: UIButton = {
        return createTabButton(title: tabTitles[1], tag: 1)
    }()
    
    lazy var careerButton: UIButton = {
        return createTabButton(title: tabTitles[2], tag: 2)
    }()
    
    lazy var socialButton: UIButton = {
        return createTabButton(title: tabTitles[3], tag: 3)
    }()
    
    lazy var dividerView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_06
        return vi
    }()
    
    lazy var contentScrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.bounces = true
        scro.alwaysBounceVertical = true
        scro.showsVerticalScrollIndicator = false
        return scro
    }()
    
    lazy var cardsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = kFitWidth(16)
        return stack
    }()
    
    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        return btn
    }()
}

extension GuideTotalBodyImpactVM {
    @objc private func nextButtonAction() {
        nextBlock?()
    }
    
    @objc private func tabButtonAction(_ button: UIButton) {
        guard selectedIndex != button.tag else { return }
        selectedIndex = button.tag
        updateTabs()
        reloadCards()
    }
}

extension GuideTotalBodyImpactVM {
    func initUI() {
        addSubview(titleLab)
        addSubview(tabStackView)
        addSubview(dividerView)
        addSubview(contentScrollView)
        addSubview(nextButton)
        
        tabButtons.forEach { tabStackView.addArrangedSubview($0) }
        contentScrollView.addSubview(cardsStackView)
        
        setConstrait()
        updateTabs()
        reloadCards()
    }
    
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(statusBarHeight + kFitWidth(41))
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
        }
        tabStackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(25))
            make.height.equalTo(kFitWidth(32))
        }
        dividerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tabStackView.snp.bottom).offset(kFitWidth(25))
            make.height.equalTo(0.5)
        }
        nextButton.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(37))
//            make.right.equalTo(kFitWidth(-37))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(302))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(10))
        }
        contentScrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dividerView.snp.bottom)
            make.bottom.equalTo(nextButton.snp.top).offset(kFitWidth(-22))
        }
        cardsStackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(24))
            make.bottom.equalTo(kFitWidth(-24))
            make.width.equalTo(SCREEN_WIDHT - kFitWidth(32))
        }
    }
    
    private func createTabButton(title: String, tag: Int) -> UIButton {
        let btn = UIButton()
        btn.tag = tag
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        btn.layer.cornerRadius = kFitWidth(16)
        btn.clipsToBounds = true
        btn.snp.makeConstraints { make in
            make.width.equalTo(kFitWidth(85))
            make.height.equalTo(kFitWidth(32))
        }
        btn.addTarget(self, action: #selector(tabButtonAction(_:)), for: .touchUpInside)
        return btn
    }
    
    private func updateTabs() {
        for (index, button) in tabButtons.enumerated() {
            let isSelected = index == selectedIndex
            button.isSelected = isSelected
            button.backgroundColor = isSelected ? .THEME : .clear
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: isSelected ? .semibold : .medium)
        }
    }
    
    private func reloadCards() {
        cardsStackView.arrangedSubviews.forEach { view in
            cardsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for item in impactSections[selectedIndex] {
            cardsStackView.addArrangedSubview(GuideImpactCardView(item: item))
        }
        contentScrollView.setContentOffset(.zero, animated: false)
    }
}

extension GuideTotalBodyImpactVM {
    func prepareEntranceAnimation() {
        titleLab.alpha = 0
        tabStackView.alpha = 0
        contentScrollView.alpha = 0
        nextButton.alpha = 0
        contentScrollView.setContentOffset(.zero, animated: false)
    }

    func startEntranceAnimation() {
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveLinear) {
            self.titleLab.alpha = 1
            self.tabStackView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.55, delay: 0.05, options: .curveLinear) {
                self.contentScrollView.alpha = 1
                self.nextButton.alpha = 1
            }
        }
    }
}

private struct ImpactItem {
    let title: String
    let detail: String
    let source: String
}

private class GuideImpactCardView: UIView {
    
    private let item: ImpactItem
    private let sourceIconSize: CGFloat = kFitWidth(15)
    
    init(item: ImpactItem) {
        self.item = item
        super.init(frame: .zero)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = item.title
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.numberOfLines = 0
        return lab
    }()
    
    lazy var detailLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = sourceIconSize
        paragraphStyle.maximumLineHeight = sourceIconSize
        paragraphStyle.lineBreakMode = .byWordWrapping
        lab.attributedText = NSAttributedString(
            string: item.detail,
            attributes: [
                .font: lab.font as Any,
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50,
                .paragraphStyle: paragraphStyle
            ]
        )
        return lab
    }()
    
    lazy var sourceIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_source_icon")
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    lazy var sourcePrefixLabel: UILabel = {
        let lab = UILabel()
        lab.text = "来源："
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_35
        lab.font = .systemFont(ofSize: kFitWidth(9), weight: .regular)
        lab.numberOfLines = 1
        lab.setContentHuggingPriority(.required, for: .horizontal)
        lab.setContentCompressionResistancePriority(.required, for: .horizontal)
        return lab
    }()
    
    lazy var sourceLabel: UILabel = {
        let lab = UILabel()
        lab.text = item.source
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_35
        lab.font = .systemFont(ofSize: kFitWidth(9), weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return lab
    }()
    
    private func initUI() {
        backgroundColor = .COLOR_CARD_BG_WHITE
        layer.cornerRadius = kFitWidth(14)
        clipsToBounds = true
        
        addSubview(titleLabel)
        addSubview(detailLabel)
        addSubview(sourceIcon)
        addSubview(sourcePrefixLabel)
        addSubview(sourceLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(12))
            make.height.equalTo(kFitWidth(24))
        }
        detailLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
        }
        sourceIcon.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(detailLabel.snp.bottom).offset(kFitWidth(10))
            make.width.height.equalTo(sourceIconSize)
        }
        sourcePrefixLabel.snp.makeConstraints { make in
            make.left.equalTo(sourceIcon.snp.right).offset(kFitWidth(1))
            make.centerY.equalTo(sourceIcon)
        }
        sourceLabel.snp.makeConstraints { make in
            make.left.equalTo(sourcePrefixLabel.snp.right).offset(kFitWidth(1))
            make.right.equalTo(titleLabel)
            make.firstBaseline.equalTo(sourcePrefixLabel.snp.firstBaseline)
            make.bottom.equalTo(kFitWidth(-13))
        }
    }
}
