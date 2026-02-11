//
//  HabitGuideFiveVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/16.
//


class HabitGuideFiveVM: UIView {
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT*4, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .COLOR_BG_F5
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    lazy var topIconImg: UIImageView = {
//        let img = UIImageView()
//        img.setImgLocal(imgName: "habit_guide_ela_icon")
//        img.contentMode = .scaleAspectFit
//        return img
//    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_guide_5_img")
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var tipLaeb: UILabel = {
        let lab = UILabel()
        lab.text = "不仅如此"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        return lab
    }()
    lazy var titleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.numberOfLines = 2
        lab.adjustsFontSizeToFitWidth = true
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 25, weight: .semibold)
        return lab
    }()
    lazy var detailLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("开始体验", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_WHITE, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.alpha = 0
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        
        return btn
    }()
}

extension HabitGuideFiveVM{
    func initUI() {
        backgroundColor = .COLOR_BG_F5
//        addSubview(topIconImg)
        addSubview(imgView)
        addSubview(whiteView)
        whiteView.addSubview(tipLaeb)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(detailLab)
        whiteView.addSubview(confirmButton)
        
        setConstrait()
        titleLab.setLineHeight(textString: "你的自律\n还将带动身边的人",
                                lineHeight: (titleLab.font.lineHeight) * 1)
        detailLab.setLineHeight(textString: "当你和朋友们同时达到目标时，你们也将一起获得额外的积分",
                                lineHeight: (detailLab.font.lineHeight) * 1.2)
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
            make.left.top.width.height.equalToSuperview()
        }
        whiteView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
//            make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(20))
//            make.top.equalTo(kFitWidth(450))
            make.top.equalTo(WHUtils().getTopSafeAreaHeight() > 0 ? kFitWidth(450) : kFitWidth(380))
        }
        tipLaeb.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(35))
            make.left.equalTo(kFitWidth(24))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
//            make.top.equalTo(kFitWidth(25))
            make.top.equalTo(tipLaeb.snp.bottom).offset(kFitWidth(10))
        }
        detailLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
//            make.top.equalTo(kFitWidth(82.5))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(20))
        }
        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(22))
            make.right.equalTo(kFitWidth(-22))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(kFitWidth(-20)-WHUtils().getBottomSafeAreaHeight())
        }
    }
}

extension HabitGuideFiveVM {
    @objc func tapAction() {
        self.tapBlock?()
    }
}

extension HabitGuideFiveVM {
    /// Prepares subviews for entrance animation
    func prepareEntranceAnimation() {
        imgView.alpha = 0
        whiteView.alpha = 0
        tipLaeb.alpha = 0
        titleLab.alpha = 0
        detailLab.alpha = 0
        confirmButton.alpha = 0
    }

    /// Sequentially fades in the title and image views
    func startEntranceAnimation() {
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
            self.imgView.alpha = 1
        }completion: { _ in
            UIView.animate(withDuration: 0.8, delay: 0.5,options: .curveLinear) {
                self.whiteView.alpha = 1
                self.tipLaeb.alpha = 1
                self.titleLab.alpha = 1
            }completion: { _ in
                UIView.animate(withDuration: 0.8, delay: 0.5,options: .curveLinear) {
                    self.detailLab.alpha = 1
                }completion: { _ in
                    UIView.animate(withDuration: 0.8, delay: 0.6,options: .curveLinear) {
                        self.confirmButton.alpha = 1
                    }completion: { _ in
                        self.isUserInteractionEnabled = true
                    }
                }
            }
        }
        
    }
}
