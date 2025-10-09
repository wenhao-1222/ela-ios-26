//
//  JournalRemarkViewCell.swift
//  lns
//
//  Created by Elavatine on 2025/4/22.
//


class JournalRemarkViewCell: UITableViewCell {
    
    var remarkBlock:(()->())?
    var detalBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        initUI()
    }
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var leftTitleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.text = "注释"
        
        return lab
    }()
    lazy var dottieBgView: DottedRectView = {
        let vi = DottedRectView()
//        vi.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214.cgColor
//        vi.layer.borderWidth = kFitWidth(1)
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var penIcon : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "logs_remark_add_icon")
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var placeHoldLabel : UILabel = {
        let lab = UILabel()
//        lab.text = "这里输入您的注释说明"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_35
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byTruncatingTail
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
//    lazy var detailButton: GJVerButton = {
//        let btn = GJVerButton()
//        btn.backgroundColor = .clear
//        btn.layer.cornerRadius = kFitWidth(12)
//        btn.clipsToBounds = true
//        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
////        btn.setTitle("   营养分析", for: .normal)
//        btn.setTitle("今日营养分析", for: .normal)
//        btn.setTitleColor(.white, for: .normal)
////        btn.setImage(UIImage(named: "logs_natural_icon"), for: .normal)
////        btn.setImage(UIImage(named: "logs_natural_icon_cj"), for: .normal)
////        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
//        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .highlighted)
//
//        btn.addTarget(self, action: #selector(detailTapAction), for: .touchUpInside)
//
//        return btn
//    }()
//    lazy var detailNewIcon: UILabel = {
//        let lab = UILabel()
//        lab.backgroundColor = .COLOR_TIPS
//        lab.textColor = .white
//        lab.text = "新功能"
//        lab.font = .systemFont(ofSize: 9, weight: .medium)
//        lab.textAlignment = .center
//        lab.layer.cornerRadius = kFitWidth(4)
//        lab.clipsToBounds = true
//        return lab
//    }()
    lazy var remarkTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(remarkTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
}

extension JournalRemarkViewCell{
    func updateContent(remark:String,queryDay:String) {
        if remark.count > 0 {
            self.placeHoldLabel.text = remark
            self.placeHoldLabel.textColor = .COLOR_TEXT_TITLE_0f1214
            penIcon.isHidden = true
            placeHoldLabel.snp.makeConstraints { make in
                make.left.equalTo(kFitWidth(48))
                make.top.equalTo(kFitWidth(66))
                make.right.equalTo(kFitWidth(-48))
//                make.bottom.equalTo(kFitWidth(-106))
                make.bottom.equalTo(kFitWidth(-26))
            }
        }else{
//            self.placeHoldLabel.text = "这里输入您的注释说明"
            self.placeHoldLabel.textColor = .COLOR_TEXT_TITLE_0f1214_35
            penIcon.isHidden = false
            placeHoldLabel.snp.makeConstraints { make in
                make.left.equalTo(kFitWidth(48))
                make.top.equalTo(kFitWidth(66))
                make.right.equalTo(kFitWidth(-48))
//                make.bottom.equalTo(kFitWidth(-106))
                make.bottom.equalTo(kFitWidth(-26))
            }
        }
    }
}

extension JournalRemarkViewCell{
    @objc func remarkTapAction() {
        self.remarkBlock?()
    }
//    @objc func detailTapAction() {
//        UserDefaults.set(value: "1", forKey: .isTapTodayNutrion)
//        self.detailNewIcon.isHidden = true
//        self.detalBlock?()
//    }
}

extension JournalRemarkViewCell{
    func initUI() {
        contentView.addSubview(whiteView)
        contentView.addSubview(leftTitleLabel)
        contentView.addSubview(dottieBgView)
        contentView.addSubview(penIcon)
        contentView.addSubview(placeHoldLabel)
        
//        contentView.addSubview(detailButton)
//        contentView.addSubview(detailNewIcon)
        contentView.addSubview(remarkTapView)
        
        setConstrait()
        
//        detailButton.imagePosition(style: .right, spacing: kFitWidth(0))
//        detailButton.imagePosition(style: .left, spacing: kFitWidth(2))
    }
    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(12))
            make.left.equalTo(kFitWidth(10))
            make.right.equalTo(kFitWidth(-10))
//            make.bottom.equalTo(kFitWidth(-90))
            make.bottom.equalToSuperview()
        }
        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(25))
            make.top.equalTo(kFitWidth(24))
        }
        penIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(37))
//            make.top.equalTo(kFitWidth(73))
            make.centerY.lessThanOrEqualTo(placeHoldLabel)
            make.width.height.equalTo(kFitWidth(7))
        }
        placeHoldLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(48))
            make.top.equalTo(kFitWidth(66))
            make.right.equalTo(kFitWidth(-38))
//            make.bottom.equalTo(kFitWidth(-116))
//            make.bottom.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-26))
        }
        
        dottieBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(25))
            make.top.equalTo(kFitWidth(56))
            make.right.equalTo(kFitWidth(-25))
            make.bottom.equalTo(kFitWidth(-16))
//            make.bottom.equalToSuperview()
        }
//        detailButton.snp.makeConstraints { make in
//            make.top.equalTo(whiteView.snp.bottom).offset(kFitWidth(30))
////            make.width.equalTo(SCREEN_WIDHT-kFitWidth(220))
//            make.width.equalTo(kFitWidth(155))
//            make.height.equalTo(kFitWidth(36))
//            make.centerX.lessThanOrEqualToSuperview()
////            make.bottom.equalTo(kFitWidth(-30))
//        }
        remarkTapView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalTo(dottieBgView)
        }
//        detailNewIcon.snp.makeConstraints { make in
//            make.right.equalTo(detailButton).offset(kFitWidth(3))
//            make.top.equalTo(detailButton).offset(kFitWidth(-7))
//            make.width.equalTo(kFitWidth(42))
//            make.height.equalTo(kFitWidth(15))
//        }
    }
}
