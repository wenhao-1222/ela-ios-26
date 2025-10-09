//
//  ReportNoDataVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/19.
//

class ReportNoDataVM: UIView {
    
    var recordBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: frame.size.height))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
//        self.alpha = 0
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteCoverView: GradientView = {
        let vi = GradientView()
        vi.addGradientBackground(startColor: UIColor.init(white: 1, alpha: 0.4), endColor: UIColor.init(white: 1, alpha: 1))
        vi.isHidden = true
        vi.alpha = 0
        return vi
    }()
    lazy var blurEffect: UIBlurEffect = {
        let vi = UIBlurEffect(style:.extraLight)
        
        return vi
    }()
    lazy var blurEffectView: UIVisualEffectView = {
        let vi = UIVisualEffectView(effect: blurEffect)
        vi.alpha = 0.35//0.73
//        vi.isHidden = true
        return vi
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

extension ReportNoDataVM{
    func showView() {
        self.isHidden = false
        self.whiteCoverView.isHidden = false
//        self.blurEffectView.isHidden = false
        UIView.animate(withDuration: 0.15, animations: {
//            self.whiteCoverView.isHidden = false
//            self.blurEffectView.isHidden = false
            self.alpha = 1
            self.whiteCoverView.alpha = 1
        })
    }
    @objc func recordAction() {
        self.recordBlock?()
    }
}

extension ReportNoDataVM{
    func initUI() {
        addSubview(blurEffectView)
        addSubview(whiteCoverView)
        addSubview(nodataLabel)
        addSubview(tipsLabel)
        addSubview(recordButton)
        
        setConstrait()
    }
    func setConstrait() {
        whiteCoverView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        blurEffectView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
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
