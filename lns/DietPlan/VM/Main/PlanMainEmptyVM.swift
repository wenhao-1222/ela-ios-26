//
//  PlanMainEmptyVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/6.
//


class PlanMainEmptyVM: UIView {
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-WHUtils().getTabbarHeight()))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "dietplan_bg_img")
        img.contentMode = .scaleAspectFill
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "dietplan_pro_icon")
        img.contentMode = .scaleAspectFit
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var centerImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "dietplan_empty_img")
        img.contentMode = .scaleAspectFit
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var tipsOneLabel: UILabel = {
        let lab = UILabel()
        lab.text = "你的专属健身食谱"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        
        return lab
    }()
    lazy var tipsTwoLabel: UILabel = {
        let lab = UILabel()
        lab.text = "告别猜测和纠结，把注意力留给坚持。"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var startButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.setTitle("开始探索", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .THEME
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.enablePressEffect()

        return btn
    }()
    
}

extension PlanMainEmptyVM{
    func initUI() {
        backgroundColor = .COLOR_BG_F2
        
        addSubview(bgImgView)
        addSubview(iconImgView)
        addSubview(centerImgView)
        
        addSubview(tipsOneLabel)
        addSubview(tipsTwoLabel)
        addSubview(startButton)
        
        setConstrait()
    }
    func setConstrait() {
        let p = WHUtils().getTopSafeAreaHeight() > 0 ? 1 : 0.5
        bgImgView.snp.makeConstraints { make in
            make.left.width.top.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT)
        }
        iconImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(statusBarHeight+kFitWidth(20)*p)
            make.width.equalTo(kFitWidth(96))
            make.height.equalTo(kFitWidth(35))
        }
        centerImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(iconImgView.snp.bottom).offset(kFitWidth(21)*p)
            make.width.equalTo(kFitWidth(254.5))
            make.height.equalTo(kFitWidth(402.5))
        }
        startButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(335))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(kFitWidth(-27)*p)
        }
        tipsTwoLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(startButton.snp.top).offset(kFitWidth(-41)*p)
            make.height.equalTo(kFitWidth(21))
        }
        tipsOneLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(tipsTwoLabel.snp.top).offset(kFitWidth(-3)*p)
            make.height.equalTo(kFitWidth(32))
        }
    }
}
