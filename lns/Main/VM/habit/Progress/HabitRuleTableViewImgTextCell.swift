//
//  HabitRuleTableViewImgTextCell.swift
//  lns
//
//  Created by LNS2 on 2026/2/2.
//


class HabitRuleTableViewImgTextCell: FeedBackTableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var titleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
}

extension HabitRuleTableViewImgTextCell{
    func updateUI(contentStr:String,
                  imgString:String,
                  bottomGap:CGFloat) {
        imgView.setImgLocal(imgName: imgString)
        titleLab.text = contentStr
        
        setNeedsDisplay()
    }
}

extension HabitRuleTableViewImgTextCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(imgView)
        bgView.addSubview(titleLab)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-12))
        }
        imgView.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(12))
            make.width.equalTo(kFitWidth(287))
            make.height.equalTo(kFitWidth(56))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.top.equalTo(kFitWidth(68))
            make.bottom.equalTo(kFitWidth(-12))
        }
    }
}
