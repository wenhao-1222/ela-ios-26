//
//  PublishWidgetCell.swift
//  lns
//
//  Created by Elavatine on 2024/12/6.
//


class PublishWidgetCell: UITableViewCell {
    
    var heightChangeBlock:((String)->())?
    var tapBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var pollButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("投票", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_65, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .highlighted)
        btn.setTitleColor(.THEME, for: .selected)
        btn.setImage(UIImage(named: "forum_poll_icon"), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .WIDGET_COLOR_GRAY_BLACK_04), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_GRAY_BLACK_25), for: .highlighted)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_GRAY_BLACK_25), for: .selected)
        btn.setImage(UIImage(named: "forum_poll_icon")?.WHImageWithTintMainColor(), for: .selected)
        
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        btn.imagePosition(style: .right, spacing: kFitWidth(2))
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        
        btn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        return btn
    }()
    lazy var pollTitleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
}

extension PublishWidgetCell{
    @objc func tapAction() {
        pollButton.isSelected = !pollButton.isSelected
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    func updateStatus(isPoll:Bool,title:String?="") {
        pollButton.isSelected = isPoll
        pollTitleLabel.text = isPoll ? title : ""
    }
}

extension PublishWidgetCell{
    func initUI() {
        contentView.addSubview(pollButton)
        contentView.addSubview(pollTitleLabel)
        
        setConstrait()
        pollButton.imagePosition(style: .left, spacing: kFitWidth(2))
    }
    func setConstrait() {
        pollButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(10))
//            make.bottom.equalTo(kFitWidth(-10))
            make.width.equalTo(kFitWidth(56))
            make.height.equalTo(kFitWidth(24))
        }
        pollTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(44))
            make.bottom.equalTo(kFitWidth(-10))
        }
    }
}
