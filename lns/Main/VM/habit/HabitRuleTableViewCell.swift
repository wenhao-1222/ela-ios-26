//
//  HabitRuleTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2025/12/30.
//



class HabitRuleTableViewCell: FeedBackTableViewCell {
    
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
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var dottlView: UIView = {
        let lab = UIView()
        lab.backgroundColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.layer.cornerRadius = kFitWidth(1)
        lab.clipsToBounds = true
        lab.isHidden = true
        
        return lab
    }()
}

extension HabitRuleTableViewCell{
    func updateUI(contentStr:String,isTitle:Bool = false,bottomGap:CGFloat) {
        dottlView.isHidden = isTitle
        titleLab.textColor = isTitle ? .COLOR_TEXT_TITLE_0f1214 :
            .COLOR_TEXT_TITLE_0f1214_50
        titleLab.font = isTitle ? .systemFont(ofSize: 14, weight: .medium) :
            .systemFont(ofSize: 12, weight: .regular)
        if isTitle{
            titleLab.setLineHeight(textString: contentStr,lineHeight: 26)
            titleLab.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(32))
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
                make.right.equalTo(kFitWidth(-32))
            }
        }else{
            titleLab.setLineHeight(textString: contentStr,lineHeight: 24)
            titleLab.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(46))
                make.top.equalToSuperview()
                make.right.equalTo(kFitWidth(-32))
                make.bottom.equalTo(bottomGap)
            }
        }
        setNeedsDisplay()
    }
}

extension HabitRuleTableViewCell{
    func initUI() {
        contentView.addSubview(titleLab)
        contentView.addSubview(dottlView)
        
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalToSuperview()
            make.right.equalTo(kFitWidth(-32))
        }
        dottlView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(36))
            make.top.equalTo(kFitWidth(7))
            make.width.height.equalTo(kFitWidth(2))
        }
    }
}

