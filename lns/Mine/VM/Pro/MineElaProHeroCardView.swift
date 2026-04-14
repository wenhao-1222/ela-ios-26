//
//  MineElaProHeroCardView.swift
//  lns
//
//  Created by LNS2 on 2026/4/14.
//

class MineElaProHeroCardView: UIView {
    var planTapBlock: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.cornerRadius = kFitWidth(20)
        layer.masksToBounds = true
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_equity_bg")
        img.contentMode = .scaleAspectFit
        
        return img
    }()
    private lazy var logoImageView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_equity_icon")
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    private lazy var myPlanButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("我的订阅", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 10, weight: .regular)
        btn.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_35
        btn.layer.cornerRadius = kFitWidth(10)
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(planButtonTapAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var descLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textColor = UIColor.COLOR_TEXT_WHITE
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.text = "解锁 Elavatine 的所有强大功能，为你的健身旅程提供便捷、全面的专业支持。"
        return lab
    }()
}

private extension MineElaProHeroCardView {
    func initUI() {
        addSubview(bgImgView)
        addSubview(logoImageView)
        addSubview(myPlanButton)
        addSubview(descLabel)
        
        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        logoImageView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(20))
            make.width.equalTo(kFitWidth(90))
            make.height.equalTo(kFitWidth(16))
        }
        
        myPlanButton.snp.makeConstraints { make in
            make.centerY.equalTo(logoImageView)
            make.right.equalTo(kFitWidth(-16))
            make.width.equalTo(kFitWidth(64))
            make.height.equalTo(kFitWidth(20))
        }
        
        descLabel.snp.makeConstraints { make in
            make.left.equalTo(logoImageView)
            make.right.equalTo(kFitWidth(-16))
//            make.top.equalTo(logoImageView.snp.bottom).offset(kFitWidth(20))
            make.bottom.equalToSuperview().offset(-kFitWidth(32))
        }
    }
    
    @objc func planButtonTapAction() {
        planTapBlock?()
    }
}
