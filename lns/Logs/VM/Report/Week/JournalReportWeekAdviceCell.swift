//
//  JournalReportWeekAdviceCell.swift
//  lns
//
//  Created by Elavatine on 2025/5/15.
//


class JournalReportWeekAdviceCell: UITableViewCell {
    
    let whiteViewWidth = SCREEN_WIDHT-kFitWidth(32)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.clipsToBounds = true
        self.isSkeletonable = true
        contentView.isSkeletonable = true
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        
        return vi
    }()
    lazy var circleView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        lab.adjustsFontSizeToFitWidth = true
        lab.isSkeletonable = true
        lab.text = "饮食建议"
        
        return lab
    }()
    lazy var deviceTitleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
    lazy var deviceTipsLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
    lazy var deviceContentLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
}

extension JournalReportWeekAdviceCell{
    func updateUI(dict:NSDictionary) {
//        deviceTitleLabel.text = dict.stringValueForKey(key: "nextWeekAdviceTitle")
//        deviceContentLabel.text = dict.stringValueForKey(key: "nextWeekAdviceContent")
        
        deviceTitleLabel.setLineSpace(lineSpcae: 0,
                                      textString: dict.stringValueForKey(key: "nextWeekAdviceTitle"),
                                      lineHeight: 1.6)
        
        deviceContentLabel.setLineSpace(lineSpcae: 0,
                                      textString: dict.stringValueForKey(key: "nextWeekAdviceContent"),
                                      lineHeight: 1.6)
        let tipsString = dict.stringValueForKey(key: "nextWeekAdviceSubTitle")//"如果偶尔有一天漏记，可以用拍照方式简单留存，晚上快速补一下即可轻松完成。"
        deviceTipsLabel.attributedText = styledText(from: tipsString, highlighting: [])
    }
    func styledText(
        from text: String,
        highlighting keywords: [String],
        underLineColor:UIColor = .COLOR_TEXT_TITLE_0f1214_50,
        lineSpacing: CGFloat = 3.0,
        baseFont: UIFont = .systemFont(ofSize: 12, weight: .regular),
        foregroundColor:UIColor = .COLOR_TEXT_TITLE_0f1214_50,
        highlightFont: UIFont = .systemFont(ofSize: 16, weight: .semibold),
        foregroundColorHighLight:UIColor = .COLOR_TEXT_TITLE_0f1214
    ) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = 1.6
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor:underLineColor,
        ]
        
        let attributedString = NSMutableAttributedString(string: text, attributes: baseAttributes)
        return attributedString
    }
}
extension JournalReportWeekAdviceCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(circleView)
        bgView.addSubview(titleLabel)
        
        contentView.addSubview(deviceTitleLabel)
        contentView.addSubview(deviceTipsLabel)
        contentView.addSubview(deviceContentLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        circleView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(26))
            make.width.height.equalTo(kFitWidth(6))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(29))
            make.centerY.lessThanOrEqualTo(circleView)
        }
        deviceTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(45))
            make.top.equalTo(kFitWidth(55))
            make.right.equalTo(kFitWidth(-32))
        }
        deviceTipsLabel.snp.makeConstraints { make in
            make.left.equalTo(deviceTitleLabel)
            make.top.equalTo(deviceTitleLabel.snp.bottom).offset(kFitWidth(12))
            make.right.equalTo(kFitWidth(-32))
        }
        deviceContentLabel.snp.makeConstraints { make in
            make.left.right.equalTo(deviceTitleLabel)
            make.top.equalTo(deviceTipsLabel.snp.bottom).offset(kFitWidth(20))
            make.bottom.equalTo(kFitWidth(-16))
        }
    }
}
