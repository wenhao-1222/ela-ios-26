//
//  JournalNaturalDetailCell.swift
//  lns
//
//  Created by Elavatine on 2025/5/29.
//


class JournalNaturalDetailCell: UITableViewCell {
    
    var detalBlock:(()->())?
    var detalOldBlock:(()->())?
    
    var bottomGap = kFitWidth(0)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        if #available(iOS 26.0, *) {
            bottomGap = WHUtils().getTabbarHeight()
        }
        initUI()
    }
    lazy var detailButton: UIButton = {
        let btn = UIButton()
        btn.enablePressEffect(style: UIImpactFeedbackGenerator(style: .soft),weight: 1)
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = kFitWidth(20)
        btn.clipsToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.setTitle("今日营养分析", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .highlighted)
                
        btn.addTarget(self, action: #selector(detailTapAction), for: .touchUpInside)
//        btn.enablePressEffect()
        
        return btn
    }()
    lazy var detailNewIcon: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .COLOR_TIPS
        lab.textColor = .white
        lab.text = "新功能"
        lab.font = .systemFont(ofSize: 9, weight: .medium)
        lab.textAlignment = .center
        lab.layer.cornerRadius = kFitWidth(4)
        lab.clipsToBounds = true
        return lab
    }()
    lazy var detailOldButton: GJVerButton = {
        let btn = GJVerButton()
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = kFitWidth(12)
        btn.clipsToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.setTitle(" 营养详情", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setImage(UIImage(named: "logs_natural_icon"), for: .normal)
//        btn.setImage(UIImage(named: "logs_natural_icon_cj"), for: .normal)
//        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
//        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .highlighted)

        btn.addTarget(self, action: #selector(detailOldTapAction), for: .touchUpInside)
        

        return btn
    }()
}
//
extension JournalNaturalDetailCell{
    @objc func detailTapAction() {
        UserDefaults.set(value: "1", forKey: .isTapTodayNutrion)
        self.detailNewIcon.isHidden = true
        self.detalBlock?()
    }
    @objc func detailOldTapAction() {
        self.detalOldBlock?()
    }
}

extension JournalNaturalDetailCell{
    func initUI() {
        contentView.addSubview(detailButton)
        contentView.addSubview(detailNewIcon)
        setConstrait()
        
//        detailButton.imagePosition(style: .right, spacing: kFitWidth(0))
        
        let isTapTodayNutrion = UserDefaults.getString(forKey: .isTapTodayNutrion)
        if isTapTodayNutrion?.count ?? 0 > 0 {
            detailNewIcon.isHidden = true
        }
        
        
//        contentView.addSubview(detailOldButton)
//        detailOldButton.snp.makeConstraints { make in
//            make.top.equalTo(kFitWidth(30))
//            make.width.equalTo(kFitWidth(155))
//            make.height.equalTo(kFitWidth(36))
//            make.centerX.lessThanOrEqualToSuperview()
//            make.bottom.equalTo(kFitWidth(-30))
//        }
//        detailOldButton.imagePosition(style: .left, spacing: kFitWidth(2))
    }
    func setConstrait() {
        detailButton.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(30))
            make.width.equalTo(kFitWidth(200))
            make.height.equalTo(kFitWidth(40))
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(-30)-self.bottomGap)
        }
        detailNewIcon.snp.makeConstraints { make in
            make.right.equalTo(detailButton).offset(kFitWidth(3))
            make.top.equalTo(detailButton).offset(kFitWidth(-7))
            make.width.equalTo(kFitWidth(42))
            make.height.equalTo(kFitWidth(15))
        }
    }
}
