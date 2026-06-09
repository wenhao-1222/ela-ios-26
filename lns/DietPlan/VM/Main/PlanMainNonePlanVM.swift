//
//  PlanMainNonePlanVM.swift
//  lns
//  没有计划的显示页面
//  Created by LNS2 on 2026/3/11.
//


class PlanMainNonePlanVM: UIView {
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-WHUtils().getTabbarHeight()))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        updateActionButtonAppearance()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateActionButtonAppearance()
    }
    
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_progress_bg")
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFill
        return img
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "饮食计划"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 17, weight: .medium)
        
        return lab
    }()
    
    lazy var createPlanButton: GJVerButtonNoneFeedBack = {
        let frame = CGRect(x: kFitWidth(16),
                           y: kFitWidth(61) + statusBarHeight,
                           width: kFitWidth(106),
                           height: kFitWidth(71))
        return makeRecipeActionButton(title: "创建",
                                      imageName: "dietplan_create_icon",
                                      imageSize: CGSize(width: kFitWidth(30), height: kFitWidth(30)),
                                      frame: frame)
    }()
    lazy var buyListButton: GJVerButtonNoneFeedBack = {
        let frame = CGRect(x: kFitWidth(134),
                           y: createPlanButton.frame.minY,
                           width: createPlanButton.frame.width,
                           height: createPlanButton.frame.height)
        return makeRecipeActionButton(title: "购物清单",
                                      imageName: "dietplan_buy_list_disable_icon",
                                      imageSize: CGSize(width: kFitWidth(30), height: kFitWidth(30)),
                                      frame: frame)
    }()
    lazy var sauceButton: GJVerButtonNoneFeedBack = {
        let frame = CGRect(x: kFitWidth(252),
                           y: createPlanButton.frame.minY,
                           width: createPlanButton.frame.width,
                           height: createPlanButton.frame.height)
        return makeRecipeActionButton(title: "酱料",
                                      imageName: "dietplan_sauce_disable_icon",
                                      imageSize: CGSize(width: kFitWidth(30), height: kFitWidth(30)),
                                      frame: frame)
    }()
    lazy var bottomCoverImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "dietplan_disable_cover_img")
        img.contentMode = .scaleAspectFill
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        
        let text = "点击“创建”\n开始计划"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        paragraphStyle.alignment = .center
        let attr = NSMutableAttributedString(string: text)
        attr.addAttributes([
            .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
            .font: UIFont.systemFont(ofSize: 21, weight: .medium),
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: text.count))
        lab.attributedText = attr
        
        lab.textAlignment = .center
        
        return lab
    }()
}

extension PlanMainNonePlanVM {
    func updateActionButtonAppearance() {
        applyActionButtonStyle(createPlanButton,
                               imageName: "dietplan_create_icon")
        applyActionButtonStyle(buyListButton,
                               imageName: "dietplan_buy_list_disable_icon")
        applyActionButtonStyle(sauceButton,
                               imageName: "dietplan_sauce_disable_icon")
        titleLab.textColor = .COLOR_TEXT_TITLE_0f1214
        updateTipsLabelAppearance()
    }
}

private extension PlanMainNonePlanVM {
    func applyActionButtonStyle(_ button: GJVerButtonNoneFeedBack,
                                imageName: String) {
        let image = resizedImage(named: imageName, size: CGSize(width: kFitWidth(30), height: kFitWidth(30))) ?? UIImage(named: imageName)
        button.setImage(image, for: .normal)
        button.setImage(image, for: .disabled)
        button.backgroundColor = .COLOR_CARD_BG_WHITE
        button.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        button.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .disabled)
    }
    
    func updateTipsLabelAppearance() {
        let text = "点击“创建”\n开始计划"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        paragraphStyle.alignment = .center
        let attr = NSMutableAttributedString(string: text)
        attr.addAttributes([
            .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
            .font: UIFont.systemFont(ofSize: 21, weight: .medium),
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: text.count))
        tipsLabel.attributedText = attr
    }
    
    func makeRecipeActionButton(title: String,
                                imageName: String,
                                imageSize: CGSize,
                                frame: CGRect) -> GJVerButtonNoneFeedBack {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = frame
        btn.setTitle(title, for: .normal)
        let image = resizedImage(named: imageName, size: imageSize) ?? UIImage(named: imageName)
        btn.setImage(image, for: .normal)
        btn.setImage(image, for: .disabled)
        btn.backgroundColor = .COLOR_CARD_BG_WHITE
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.layer.cornerRadius = kFitWidth(16)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.layoutIfNeeded()
        btn.imagePosition(style: .top, spacing: kFitWidth(8))
        return btn
    }
    
    func resizedImage(named: String, size: CGSize) -> UIImage? {
        guard let image = UIImage(named: named, in: nil, compatibleWith: traitCollection) ?? UIImage(named: named),
              size.width > 0,
              size.height > 0 else { return nil }
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension PlanMainNonePlanVM{
    func initUI() {
        addSubview(bgImgView)
        addSubview(bottomCoverImgView)
        addSubview(titleLab)
        addSubview(createPlanButton)
        addSubview(buyListButton)
        addSubview(sauceButton)
        bottomCoverImgView.addSubview(tipsLabel)
     
        buyListButton.isEnabled = false
        sauceButton.isEnabled = false
        updateActionButtonAppearance()
        
        setConstrait()
    }
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(20)+statusBarHeight)
            make.height.equalTo(kFitWidth(25))
        }
        bottomCoverImgView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(WHUtils().getBottomSafeAreaHeight())
            make.top.equalTo(createPlanButton.snp.bottom).offset(kFitWidth(15))
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
//            make.centerY.lessThanOrEqualToSuperview().offset(kFitWidth(75))
            make.top.equalTo(kFitWidth(280))
        }
    }
}
