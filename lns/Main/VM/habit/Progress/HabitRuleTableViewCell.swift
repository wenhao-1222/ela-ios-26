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
}

extension HabitRuleTableViewCell{
    func updateUI(contentStr:String,isTitle:Bool = false,bottomGap:CGFloat) {
        titleLab.textColor = isTitle ? .COLOR_TEXT_TITLE_0f1214 :
            .COLOR_TEXT_TITLE_0f1214_50
        titleLab.font = isTitle ? .systemFont(ofSize: 17, weight: .semibold) :
            .systemFont(ofSize: 13, weight: .regular)
//        if isTitle{
            titleLab.setLineHeight(textString: contentStr,lineHeight: titleLab.font.lineHeight)
//        }else{
//            titleLab.setLineHeight(textString: contentStr,lineHeight: titleLab.font.lineHeight * 1.5)
//        }
        setNeedsDisplay()
    }
}

extension HabitRuleTableViewCell{
    func initUI() {
        contentView.addSubview(titleLab)
        
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalToSuperview()
            make.right.equalTo(kFitWidth(-32))
            make.bottom.equalTo(kFitWidth(-15))
        }
    }
}

