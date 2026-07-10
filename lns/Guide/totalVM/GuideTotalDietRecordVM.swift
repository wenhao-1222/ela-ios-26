//
//  GuideTotalDietRecordVM.swift
//  lns
//
//  Created by Codex on 2026/7/6.
//

class GuideTotalDietRecordVM: UIView {
    
    var selfHeight = SCREEN_HEIGHT
    var nextBlock:(() -> Void)?
    var backBlock:(() -> Void)?
    var shouldAutoStartChartAnimation = true
    
    private let chartAnimationDuration: TimeInterval = 2.4
    private let nextButtonFadeDuration: TimeInterval = 0.45
    
    private let tipsLines = [
        "*2 分钟为 Elavatine 用户每日记录平均用时",
        "† Kaiser Permanente Center for Health Research， Am J Prev Med",
        "2008； 200 % 表示效果约为对照组的两倍"
    ]
    
    let chart = ProgressChartView()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateChartGradient()
    }
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = UIColor(named: "color_bg_f5")
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.bounces = false
        scro.alwaysBounceVertical = true
        scro.showsVerticalScrollIndicator = false
        return scro
    }()
    
//    lazy var backButtonView: UIView = {
//        let vi = UIView()
//        vi.backgroundColor = .COLOR_CARD_BG_WHITE.withAlphaComponent(0.6)
//        vi.layer.cornerRadius = kFitWidth(23)
//        vi.layer.borderWidth = 1
//        vi.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
//        vi.clipsToBounds = true
//        vi.isUserInteractionEnabled = true
//        let tap = FeedBackTapGestureRecognizer(target: self, action: #selector(backTapAction))
//        vi.addGestureRecognizer(tap)
//        return vi
//    }()
//    
//    lazy var backImgView: UIImageView = {
//        let img = UIImageView()
//        img.image = UIImage(named: "guide_back_button")?.withTintColor(.COLOR_TEXT_TITLE_0f1214)
//        img.contentMode = .scaleAspectFit
//        return img
//    }()
    
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "记录饮食能帮助你\n用更短的时间达到目标"
        lab.numberOfLines = 2
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 25, weight: .semibold)
        lab.lineBreakMode = .byWordWrapping
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.minimumLineHeight = kFitWidth(36)
        paragraphStyle.maximumLineHeight = kFitWidth(36)
        lab.attributedText = NSAttributedString(
            string: lab.text ?? "",
            attributes: [
                .font: lab.font as Any,
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .paragraphStyle: paragraphStyle
            ]
        )
        return lab
    }()
    
    lazy var downImgIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_first_page_down_icon")
        return img
    }()
    
    lazy var downLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .medium)
        
        let attr = NSMutableAttributedString(string: "通过记录饮食，每天\n")
        let timeAttr = NSMutableAttributedString(string: "仅需2分钟")
        let tailAttr = NSMutableAttributedString(string: "*")
        timeAttr.yy_color = .THEME
        attr.append(timeAttr)
        attr.append(tailAttr)
        attr.yy_setLineHeightMultiple(1.2, range: NSMakeRange(0, attr.length))
        lab.attributedText = attr
        return lab
    }()
    
    lazy var upImgIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_first_page_up_icon")
        return img
    }()
    
    lazy var upLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .medium)
        
        let attr = NSMutableAttributedString(string: "可将体重管理成效提\n高到原本的")
        let timeAttr = NSMutableAttributedString(string: "200%")
        let tailAttr = NSMutableAttributedString(string: "†")
        timeAttr.yy_color = WHColor_16(colorStr: "FF8C3B")
        attr.append(timeAttr)
        attr.append(tailAttr)
        attr.yy_setLineHeightMultiple(1.2, range: NSMakeRange(0, attr.length))
        lab.attributedText = attr
        return lab
    }()
    
    lazy var logoImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_first_page_logo_icon")
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    private func createTipsLabel() -> UILabel {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.numberOfLines = 1
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        return lab
    }
    
    lazy var tipsLabel1: UILabel = {
        return createTipsLabel()
    }()
    
    lazy var tipsLabel2: UILabel = {
        return createTipsLabel()
    }()
    
    lazy var tipsLabel3: UILabel = {
        return createTipsLabel()
    }()
    
    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(12)
        btn.clipsToBounds = true
        btn.alpha = 0
        btn.isUserInteractionEnabled = false
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        return btn
    }()
}

extension GuideTotalDietRecordVM {
    @objc private func nextButtonAction() {
        nextBlock?()
    }
    
    @objc private func backTapAction() {
        backBlock?()
    }
}

extension GuideTotalDietRecordVM {
    func initUI() {
        addSubview(scrollView)
//        addSubview(backButtonView)
        addSubview(nextButton)
//        backButtonView.addSubview(backImgView)
        
        scrollView.addSubview(titleLab)
        scrollView.addSubview(downImgIcon)
        scrollView.addSubview(downLabel)
        scrollView.addSubview(upImgIcon)
        scrollView.addSubview(upLabel)
        
        chart.translatesAutoresizingMaskIntoConstraints = false
        updateChartGradient()
        chart.backgroundColor = UIColor(named: "color_card_bg_f5_guide")
        scrollView.addSubview(chart)
        
        scrollView.addSubview(logoImgView)
        scrollView.addSubview(tipsLabel1)
        scrollView.addSubview(tipsLabel2)
        scrollView.addSubview(tipsLabel3)
        
        tipsLabel1.text = tipsLines[0]
        tipsLabel2.text = tipsLines[1]
        tipsLabel3.text = tipsLines[2]
        
        NSLayoutConstraint.activate([
           chart.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: kFitWidth(25)),
           chart.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: kFitWidth(-25)),
           chart.topAnchor.constraint(equalTo: downLabel.bottomAnchor, constant: kFitWidth(35)),
           chart.widthAnchor.constraint(equalToConstant: SCREEN_WIDHT - kFitWidth(50)),
           chart.heightAnchor.constraint(equalTo: chart.widthAnchor, multiplier: 1/1.36)
       ])
        
        setConstrait()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            guard self.shouldAutoStartChartAnimation else { return }
            self.startChartAnimationThenShowNextButton()
        }
    }
    
    func setConstrait(){
        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(kFitWidth(-18))
        }
        nextButton.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(46))
//            make.right.equalTo(kFitWidth(-46))
//            make.height.equalTo(kFitWidth(60))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(10))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(302))
            make.height.equalTo(kFitWidth(48))
        }
//        backButtonView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(30))
//            make.top.equalTo(statusBarHeight + kFitWidth(30))
//            make.width.height.equalTo(kFitWidth(46))
//        }
//        backImgView.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//            make.width.height.equalTo(kFitWidth(24))
//        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(kFitWidth(41)+WHUtils().getNavigationBarHeight())
        }
        downImgIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(30))
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(50))
            make.width.equalTo(kFitWidth(14))
            make.height.equalTo(kFitWidth(20))
        }
        downLabel.snp.makeConstraints { make in
            make.left.equalTo(downImgIcon.snp.right).offset(kFitWidth(10))
            make.centerY.equalTo(downImgIcon)
        }
        upImgIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(200))
            make.centerY.equalTo(downImgIcon)
            make.width.height.equalTo(downImgIcon)
        }
        upLabel.snp.makeConstraints { make in
            make.left.equalTo(upImgIcon.snp.right).offset(kFitWidth(10))
            make.centerY.equalTo(downImgIcon)
            make.right.lessThanOrEqualTo(kFitWidth(-22))
        }
        logoImgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(chart.snp.bottom).offset(kFitWidth(35))
            make.width.equalTo(kFitWidth(111))
        }
        tipsLabel1.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(kFitWidth(22))
            make.top.equalTo(logoImgView.snp.bottom).offset(kFitWidth(35))
        }
        tipsLabel2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.right.equalTo(tipsLabel1)
            make.top.equalTo(tipsLabel1.snp.bottom).offset(kFitWidth(7))
        }
        tipsLabel3.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.right.equalTo(tipsLabel1)
            make.top.equalTo(tipsLabel2.snp.bottom).offset(kFitWidth(7))
            make.bottom.equalToSuperview().offset(kFitWidth(-24))
        }
    }
    
    private func updateChartGradient() {
        if traitCollection.userInterfaceStyle == .dark {
            chart.setRecordedLineGradient(start: WHColor_16(colorStr: "0066D5"),
                                          end: WHColorWithAlpha(colorStr: "3686FF", alpha: 0))
            chart.setUnRecordedLineGradient(start: WHColorWithAlpha(colorStr: "FF6900", alpha: 0.48),
                                            end: WHColor_16(colorStr: "141416"))
        } else {
            chart.setRecordedLineGradient(start: UIColor(red: 155/255, green: 193/255, blue: 255/255, alpha: 1),
                                          end: UIColor(red: 238/255, green: 247/255, blue: 255/255, alpha: 1))
            chart.setUnRecordedLineGradient(start: UIColor(red: 252/255, green: 142/255, blue: 83/255, alpha: 1),
                                            end: UIColor(red: 251/255, green: 242/255, blue: 228/255, alpha: 1))
        }
    }
    
    private func resetNextButtonPresentation() {
        nextButton.layer.removeAllAnimations()
        nextButton.alpha = 0
        nextButton.isUserInteractionEnabled = false
    }
    
    private func fadeInNextButton() {
        nextButton.isUserInteractionEnabled = true
        UIView.animate(withDuration: nextButtonFadeDuration, delay: 0, options: .curveLinear) {
            self.nextButton.alpha = 1
        }
    }
    
    private func startChartAnimationThenShowNextButton() {
        layoutIfNeeded()
        chart.layoutIfNeeded()
        resetNextButtonPresentation()
        chart.startGradientAnimation(duration: chartAnimationDuration) { [weak self] in
            self?.fadeInNextButton()
        }
    }
}

extension GuideTotalDietRecordVM {
    func prepareEntranceAnimation() {
        scrollView.setContentOffset(.zero, animated: false)
        titleLab.alpha = 0
        downImgIcon.alpha = 0
        downLabel.alpha = 0
        upImgIcon.alpha = 0
        upLabel.alpha = 0
        chart.alpha = 0
        logoImgView.alpha = 0
        tipsLabel1.alpha = 0
        tipsLabel2.alpha = 0
        tipsLabel3.alpha = 0
        resetNextButtonPresentation()
    }
    
    func startEntranceAnimation() {
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveLinear) {
            self.titleLab.alpha = 1
            self.downImgIcon.alpha = 1
            self.downLabel.alpha = 1
            self.upImgIcon.alpha = 1
            self.upLabel.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.05, options: .curveLinear) {
                self.chart.alpha = 1
                self.logoImgView.alpha = 1
                self.tipsLabel1.alpha = 1
                self.tipsLabel2.alpha = 1
                self.tipsLabel3.alpha = 1
            }
            self.startChartAnimationThenShowNextButton()
        }
    }
}
