//
//  CoursePayTipsPopupView.swift
//  lns
//
//  Created by LNS2 on 2025/10/22.
//

class CoursePayTipsPopupView: UIView {
    
    let selfWidth = kFitWidth(284)
    let selfHeight = kFitWidth(365)
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
//        super.init(frame: CGRect.init(x: SCREEN_WIDHT*0.5-selfWidth*0.5, y: SCREEN_HEIGHT*0.5-selfHeight*0.5-kFitWidth(80), width: selfWidth, height: selfHeight))
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.alpha = 0
//        self.layer.cornerRadius = kFitWidth(40)
//        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var blurEffect: UIBlurEffect = {
        let vi = UIBlurEffect(style:.systemThinMaterialLight)//systemChromeMaterialLight
        return vi
    }()
    lazy var blurEffectView: UIVisualEffectView = {
        let vi = UIVisualEffectView(effect: blurEffect)
        vi.alpha = 0.98
        vi.layer.cornerRadius = kFitWidth(40)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var elaIconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "course_pay_tips_ela_icon")
        return img
    }()
    lazy var closeImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "course_pay_tips_close_icon")
        img.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var titleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
//        lab.customLineHeight = 1.5
        lab.text = "100%的课程收入\n将用于支持"
        lab.textColor = .colorText0F1214
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
//        lab.customLineHeight = 1.5
        lab.font = .systemFont(ofSize: 21, weight: .medium)
        return lab
    }()
    lazy var tipsLab: LineHeightLabel = {
        let lab = LineHeightLabel()
//        lab.customLineHeight = 1.5
        lab.text = "技术：服务器、AI接口调用等必要支出。\n团队：程序员与运营团队成员及场地。\n研发：产品的持续研发与优化。"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.numberOfLines = 3
        lab.lineBreakMode = .byWordWrapping
//        lab.customLineHeight = 1.5
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        
        return lab
    }()
    lazy var detailLab: LineHeightLabel = {
        let lab = LineHeightLabel()
//        lab.customLineHeight = 1.5
        lab.text = "课程收入能够让elavatine在不借助外部资金的情况下正常运作，并保持产品优先的原则下持续提供高质量服务。"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var elavatineIconImgView: UIImageView = {
        let img = UIImageView()
        let logoImg  = UIImage(named: "main_top_logo_cj")
//        img.setImgLocal(imgName: "ela_icon_img")
//        img.tintColor = .THEME
        img.image = logoImg?.withRenderingMode(.alwaysTemplate)
        img.tintColor = .THEME
        img.contentMode = .scaleAspectFit
        
        return img
    }()
}

extension CoursePayTipsPopupView{
    func showSelf() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        }
    }
}

extension CoursePayTipsPopupView{
    func initUI() {
        addSubview(bgView)
        addSubview(blurEffectView)
        addSubview(elaIconImgView)
        addSubview(closeImgView)
        addSubview(titleLab)
        addSubview(tipsLab)
        addSubview(detailLab)
        addSubview(elavatineIconImgView)
        
        setConstrait()
        
        titleLab.setLineHeight(textString: "100%的课程收入\n将用于支持",lineHeight: 22)
        tipsLab.setLineHeight(textString: "技术：服务器、AI接口调用等必要支出。\n团队：程序员与运营团队成员及场地。\n研发：产品的持续研发与优化。",lineHeight: 17)
        detailLab.setLineHeight(textString: "课程收入能够让elavatine在不借助外部资金的情况下正常运作，并保持产品优先的原则下持续提供高质量服务。",lineHeight: 18)
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        blurEffectView.snp.makeConstraints { make in
//            make.left.top.right.bottom.equalToSuperview()
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(selfWidth)
            make.height.equalTo(selfHeight)
            make.centerY.lessThanOrEqualToSuperview().offset(kFitWidth(-50))
        }
        elaIconImgView.snp.makeConstraints { make in
            make.right.equalTo(blurEffectView).offset(kFitWidth(-21))
            make.top.equalTo(blurEffectView).offset(kFitWidth(32))
            make.width.equalTo(kFitWidth(157))
            make.height.equalTo(kFitWidth(80))
        }
        closeImgView.snp.makeConstraints { make in
            make.right.equalTo(blurEffectView).offset(kFitWidth(-21))
            make.top.equalTo(blurEffectView).offset(kFitWidth(20))
            make.width.height.equalTo(kFitWidth(25))
        }
        titleLab.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(35))
//            make.top.equalTo(kFitWidth(62))
//            make.right.equalTo(kFitWidth(-34))
            make.left.equalTo(blurEffectView).offset(kFitWidth(35))
            make.top.equalTo(blurEffectView).offset(kFitWidth(62))
            make.right.equalTo(blurEffectView).offset(kFitWidth(-34))
        }
        tipsLab.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(35))
//            make.right.equalTo(kFitWidth(-34))
            make.left.equalTo(blurEffectView).offset(kFitWidth(35))
            make.right.equalTo(blurEffectView).offset(kFitWidth(-34))
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(21))
        }
        detailLab.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(35))
            make.top.equalTo(tipsLab.snp.bottom).offset(kFitWidth(21))
//            make.right.equalTo(kFitWidth(-34))
            make.left.equalTo(blurEffectView).offset(kFitWidth(35))
            make.right.equalTo(blurEffectView).offset(kFitWidth(-34))
        }
        elavatineIconImgView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(35))
//            make.bottom.equalTo(kFitWidth(-52))
            make.left.equalTo(blurEffectView).offset(kFitWidth(35))
            make.bottom.equalTo(blurEffectView).offset(kFitWidth(-52))
            make.width.equalTo(kFitWidth(71.5))
            make.height.equalTo(kFitWidth(13))
        }
    }
}
