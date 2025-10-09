//
//  WeekReportNoDataVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/19.
//


class WeekReportNoDataVM: UIView {
    
    var selfHeight = kFitWidth(0)
    var recordBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: frame.size.height))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        selfHeight = frame.size.height
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView()//.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        img.setImgLocal(imgName: "report_week_nodata_img")
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    lazy var nodataLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.text = "数据不足"
        lab.font = .systemFont(ofSize: 18, weight: .semibold)
        
        return lab
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var recordButton: UIButton = {
        let btn = UIButton()
//        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .highlighted)
        btn.setTitle("去记录饮食", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(recordAction), for: .touchUpInside)
        
        return btn
    }()
}

extension WeekReportNoDataVM{
    func showView() {
        self.isHidden = false
//        self.whiteCoverView.isHidden = false
//        self.blurEffectView.isHidden = false
//        UIView.animate(withDuration: 0.2, animations: {
//            self.whiteCoverView.isHidden = false
//            self.blurEffectView.isHidden = false
//        })
    }
    @objc func recordAction() {
        self.recordBlock?()
    }
}

extension WeekReportNoDataVM{
    func initUI() {
        addSubview(imgView)
        addSubview(nodataLabel)
        addSubview(tipsLabel)
        addSubview(recordButton)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.top.left.width.equalToSuperview()
        }
        nodataLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(tipsLabel.snp.top).offset(kFitWidth(-8))
        }
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(recordButton.snp.top).offset(kFitWidth(-15))
        }
        recordButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(-44)-WHUtils().getBottomSafeAreaHeight())
            make.width.equalTo(kFitWidth(205))
            make.height.equalTo(kFitWidth(44))
        }
    }
}
