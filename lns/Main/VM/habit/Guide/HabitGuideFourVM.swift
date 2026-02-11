//
//  HabitGuideFourVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/16.
//


class HabitGuideFourVM: UIView {
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT*3, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .COLOR_BG_F5
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_guide_4_img")
        
        return img
    }()
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear//.COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var tipLaeb: UILabel = {
        let lab = UILabel()
        lab.text = "在elavatine"
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
}

extension HabitGuideFourVM{
    func initUI() {
        backgroundColor = .COLOR_BG_F5
        addSubview(imgView)
        addSubview(whiteView)
        whiteView.addSubview(tipLaeb)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(detailLab)
        
        setConstrait()
        titleLab.setLineHeight(textString: "我们相信你能\n改变不仅限于自己",
                                lineHeight: (titleLab.font.lineHeight) * 1)
        detailLab.setLineHeight(textString: "积分每到达一定分数，我们将代表你向贫困山区捐赠一份营养餐",
                                lineHeight: (detailLab.font.lineHeight) * 1.2)
    }
    func setConstrait() {
//        let imgHeight = kFitWidth(400)*SCREEN_WIDHT/kFitWidth(375)
        imgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
//            make.height.equalTo(imgHeight)
        }
        whiteView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
//            make.top.equalTo(imgView.snp.bottom)
            make.top.equalTo(kFitWidth(450))
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
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(30))
            make.right.equalTo(kFitWidth(-20))
        }
    }
}

extension HabitGuideFourVM {
    @objc func tapAction() {
        self.tapBlock?()
    }
}

extension HabitGuideFourVM {
    /// Prepares subviews for entrance animation
    func prepareEntranceAnimation() {
        imgView.alpha = 0
        whiteView.alpha = 0
        tipLaeb.alpha = 0
        titleLab.alpha = 0
        detailLab.alpha = 0
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
                self.tipLaeb.alpha = 1
            }completion: { _ in
                UIView.animate(withDuration: 0.8, delay: 0.5,options: .curveLinear) {
                    self.detailLab.alpha = 1
                }completion: { _ in
                    self.isUserInteractionEnabled = true
                }
            }
        }
        
    }
}
