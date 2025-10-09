//
//  GuideTotalSixthVM.swift
//  lns
// guide_img_step_7_circle
//  Created by Elavatine on 2025/6/10.
//



class GuideTotalSixthVM: UIView {
    
    var selfHeight = SCREEN_HEIGHT
    
    var nextBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT*5, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
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
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "就是这么简单！ \n10秒不到，食物就添加完成了"
        lab.numberOfLines = 2
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 25, weight: .semibold)

        return lab
    }()
    lazy var tipsLab: UILabel = {
        let lab = UILabel()
        lab.text = "科学研究表明，坚持某件事，只需完成第一\n步，成功概率即可提升约 80 %"
        lab.numberOfLines = 2
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .light)

        return lab
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_img_step_6")
        
        
        return img
    }()
    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.backgroundColor = .THEME
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(12)
        btn.clipsToBounds = true
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(addTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var tipsBottomLab: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.text = "Nunes & Drèze 2006 Endowed Progress Effect \n20 % 进度让完成率 19 → 34 %。"
        lab.numberOfLines = 2
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 10, weight: .light)

        return lab
    }()
}

extension GuideTotalSixthVM{
    @objc func addTapAction() {
        self.nextBlock?()
    }
}

extension GuideTotalSixthVM{
    func initUI() {
        addSubview(scrollView)
        scrollView.frame = CGRect.init(x: 0, y: statusBarHeight+kFitWidth(30), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-statusBarHeight-kFitWidth(30))
        scrollView.addSubview(titleLab)
        scrollView.addSubview(tipsLab)
        scrollView.addSubview(imgView)
        scrollView.addSubview(nextButton)
        scrollView.addSubview(tipsBottomLab)
        
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.top.equalTo(kFitWidth(42))
        }
        tipsLab.snp.makeConstraints { make in
            make.left.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(7))
        }
        imgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(327))
            make.top.equalTo(tipsLab.snp.bottom).offset(kFitWidth(25))
        }
        nextButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(222))
            make.height.equalTo(kFitWidth(44))
            make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(58))
        }
        tipsBottomLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(nextButton.snp.bottom).offset(kFitWidth(26))
        }
    }
}
extension GuideTotalSixthVM {
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = CGRect(x: 0,
                                   y: statusBarHeight + kFitWidth(30),
                                   width: bounds.width,
                                   height: bounds.height - statusBarHeight - kFitWidth(30))
        layoutIfNeeded()
        if WHUtils().getBottomSafeAreaHeight() == 0 {
            let extra = kFitWidth(20) //+ WHUtils().getBottomSafeAreaHeight()
            scrollView.contentSize = CGSize(width: 0, height: tipsBottomLab.frame.maxY + extra)
        }
    }
}

extension GuideTotalSixthVM {
    /// Resets alpha for entrance animation
    func prepareEntranceAnimation() {
        titleLab.alpha = 0
        tipsLab.alpha = 0
        tipsBottomLab.alpha = 0
        imgView.alpha = 0
        nextButton.alpha = 0
        self.scrollView.setContentOffset(.zero, animated: false)
    }

    /// Fades in title labels followed by image view
    func startEntranceAnimation() {
//        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
            self.titleLab.alpha = 1
            self.tipsLab.alpha = 1
//            self.nextButton.alpha = 1
        }completion: { _ in
            UIView.animate(withDuration: 0.8, delay: 0.5,options: .curveLinear) {
                self.imgView.alpha = 1
                self.nextButton.alpha = 1
                self.tipsBottomLab.alpha = 1
            }completion: { _ in
                self.isUserInteractionEnabled = true
            }
        }
    }
}
