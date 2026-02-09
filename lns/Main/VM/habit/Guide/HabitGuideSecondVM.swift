//
//  HabitGuideSecondVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/16.
//


class HabitGuideSecondVM: UIView {
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .COLOR_BG_F5
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var topIconImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_guide_ela_icon")
        img.contentMode = .scaleAspectFit
        img.isHidden = true
        return img
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_guide_2_img")
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear//.COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "规律饮食最难的是坚持"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 25, weight: .semibold)
        return lab
    }()
    lazy var detailLab: UILabel = {
        let lab = UILabel()
        lab.adjustsFontSizeToFitWidth = true
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        let attr = NSMutableAttributedString(string: "80",
                                             attributes: [.font:UIFont.systemFont(ofSize: 21, weight: .heavy)])
        attr.append(NSAttributedString(string: "%的人没能达到理想身材，原因是无法坚持",
                                       attributes: [.font:UIFont.systemFont(ofSize: 16, weight: .regular)]))
        lab.attributedText = attr
        
        return lab
    }()
    
    lazy var detailLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 14, weight: .light)
        
        return lab
    }()
    lazy var tipsLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        
        return lab
    }()
    
}

extension HabitGuideSecondVM {
    @objc func tapAction() {
        self.tapBlock?()
    }
}

extension HabitGuideSecondVM{
    func initUI() {
        backgroundColor = .COLOR_BG_F5
//        addSubview(topIconImg)
        addSubview(imgView)
        addSubview(whiteView)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(detailLab)
        whiteView.addSubview(detailLabel)
        whiteView.addSubview(tipsLab)
        
        setConstrait()
        
        detailLabel.setLineHeight(textString: "我们会通过帮助你养成习惯，提高规律饮食的\n自动化程度，进而提升执行力及坚持率。", lineHeight: kFitWidth(22))
        tipsLab.setLineHeight(textString: "Wing RR, Phelan S. Long-term weight loss maintenance, American Journal of Clinical Nutrition, 2005。", lineHeight: kFitWidth(17))
    }
    func setConstrait() {
//        topIconImg.snp.makeConstraints { make in
//            make.top.equalToSuperview()
//            make.centerX.lessThanOrEqualToSuperview()
//            make.height.equalTo(kFitWidth(68))
//            make.width.equalToSuperview()
//        }
//        imgView.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(topIconImg.snp.bottom).offset(kFitWidth(22))
//            make.width.equalTo(kFitWidth(305))
//            make.height.equalTo(kFitWidth(290))
//        }
        imgView.snp.makeConstraints { make in
            make.left.right.top.height.equalToSuperview()
//            make.height.equalTo(kFitWidth(300))
        }
        whiteView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
//            make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(20))
            make.top.equalTo(WHUtils().getTopSafeAreaHeight() > 0 ? kFitWidth(450) : kFitWidth(380))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.top.equalTo(kFitWidth(25))
        }
        detailLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.top.equalTo(kFitWidth(82.5))
            make.right.equalTo(kFitWidth(-20))
        }
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.top.equalTo(kFitWidth(127))
        }
        tipsLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.bottom.equalTo(kFitWidth(-30)-WHUtils().getBottomSafeAreaHeight())
        }
    }
}

extension HabitGuideSecondVM {
    /// Prepares subviews for entrance animation
    func prepareEntranceAnimation() {
        imgView.alpha = 0
        whiteView.alpha = 0
        titleLab.alpha = 0
        detailLab.alpha = 0
        detailLabel.alpha = 0
        tipsLab.alpha = 0
    }

    /// Sequentially fades in the title and image views
    func startEntranceAnimation() {
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
            self.imgView.alpha = 1
        }completion: { _ in
            UIView.animate(withDuration: 0.8, delay: 0.5,options: .curveLinear) {
                self.whiteView.alpha = 1
                self.titleLab.alpha = 1
            }completion: { _ in
                UIView.animate(withDuration: 0.8, delay: 0.5,options: .curveLinear) {
                    self.detailLab.alpha = 1
                }completion: { _ in
                    UIView.animate(withDuration: 0.8, delay: 0.5,options: .curveLinear) {
                        self.detailLabel.alpha = 1
                        self.tipsLab.alpha = 1
                    }completion: { _ in
                        self.isUserInteractionEnabled = true
                    }
                }
            }
        }
        
    }
}
