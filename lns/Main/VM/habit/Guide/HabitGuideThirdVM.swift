//
//  HabitGuideThirdVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/16.
//


class HabitGuideThirdVM: UIView {
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT*2, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .COLOR_BG_F5
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
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
        img.setImgLocal(imgName: "habit_guide_3_img")
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
        lab.text = "接下来"
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
}

extension HabitGuideThirdVM{
    func initUI() {
        backgroundColor = .COLOR_BG_F5
//        addSubview(topIconImg)
        addSubview(imgView)
        addSubview(whiteView)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(detailLab)
        
        setConstrait()
        detailLab.setLineHeight(textString: "我们会给到你一些每日目标，搭配激励积分去帮助你养成习惯",
                                lineHeight: (detailLab.font.lineHeight) * 1)
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
            make.top.equalTo(kFitWidth(450))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.top.equalTo(kFitWidth(35))
        }
        detailLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.top.equalTo(kFitWidth(82.5))
            make.right.equalTo(kFitWidth(-20))
        }
    }
}

extension HabitGuideThirdVM {
    @objc func tapAction() {
        self.tapBlock?()
    }
}

extension HabitGuideThirdVM {
    /// Prepares subviews for entrance animation
    func prepareEntranceAnimation() {
        imgView.alpha = 0
        whiteView.alpha = 0
        titleLab.alpha = 0
        detailLab.alpha = 0
    }

    /// Sequentially fades in the title and image views
    func startEntranceAnimation() {
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
            self.imgView.alpha = 1
            self.whiteView.alpha = 1
            self.titleLab.alpha = 1
        }completion: { _ in
//            UIView.animate(withDuration: 0.1, delay: 0.1,options: .curveLinear) {
//                self.whiteView.alpha = 1
//            }completion: { _ in
                UIView.animate(withDuration: 0.8, delay: 0.75,options: .curveLinear) {
                    self.detailLab.alpha = 1
                }completion: { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.4, execute: {
                        self.isUserInteractionEnabled = true
                    })
                }
//            }
        }
        
    }
}
