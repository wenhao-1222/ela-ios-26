//
//  HabitGuideFirstVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/16.
//



class HabitGuideFirstVM: UIView {
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColor_16(colorStr: "F0F7FF")
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_guide_1_bg")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var detailLabelOne: UILabel = {
        let lab = UILabel()
        lab.text = "Hello"
        lab.font = .systemFont(ofSize: 50, weight: .semibold)
        
        return lab
    }()
    lazy var detailLabelTwo: UILabel = {
        let lab = UILabel()
        lab.text = "欢迎来到自律习惯养成"
        lab.font = .systemFont(ofSize: 26, weight: .semibold)
        
        return lab
    }()
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "ela_icon_img")?.withTintColor(.THEME)
        return img
    }()
}

extension HabitGuideFirstVM {
    @objc func tapAction() {
        self.tapBlock?()
    }
}

extension HabitGuideFirstVM{
    func initUI() {
        addSubview(bgImgView)
        addSubview(detailLabelOne)
        addSubview(detailLabelTwo)
        addSubview(iconImgView)
        
        setConstrait()
    }
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        detailLabelOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(40))
            make.top.equalTo(kFitWidth(280))
        }
        detailLabelTwo.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(40))
            make.top.equalTo(detailLabelOne.snp.bottom).offset(kFitWidth(20))
        }
        iconImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(132))
            make.bottom.equalTo(kFitWidth(-115)-WHUtils().getBottomSafeAreaHeight())
        }
    }
}

extension HabitGuideFirstVM {
    /// Prepares subviews for entrance animation
    func prepareEntranceAnimation() {
        self.isUserInteractionEnabled = false
        detailLabelOne.alpha = 0
        detailLabelTwo.alpha = 0
    }

    /// Sequentially fades in the title and image views
    func startEntranceAnimation() {
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.55, delay: 0.05,options: .curveLinear) {
            self.detailLabelOne.alpha = 1
        }completion: { _ in
            UIView.animate(withDuration: 0.65, delay: 0.35,options: .curveLinear) {
                self.detailLabelTwo.alpha = 1
            }completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    self.isUserInteractionEnabled = true
                })
            }
        }
    }
}
