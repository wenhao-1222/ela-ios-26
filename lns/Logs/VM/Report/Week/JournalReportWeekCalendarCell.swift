//
//  JournalReportWeekCalendarCell.swift
//  lns
//
//  Created by Elavatine on 2025/5/15.
//


class JournalReportWeekCalendarCell: UITableViewCell {
    
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
        vi.isSkeletonable = true
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
        
        return lab
    }()
    ///周三执行的最好
    lazy var bestDayLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.numberOfLines = 3
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var calendarBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        
        return vi
    }()
    lazy var calendarVm: JournalReportWeekCalendarVM = {
        let vm = JournalReportWeekCalendarVM.init(frame: .zero)
        return vm
    }()
    lazy var detailCaloriesLabel: KeywordHighlightLabel = {
        let lab = KeywordHighlightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.preferredMaxLayoutWidth = lab.bounds.width
        lab.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: kFitWidth(4), right: 0)
        
        return lab
    }()
    lazy var detailProteinLabel: KeywordHighlightLabel = {
        let lab = KeywordHighlightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: kFitWidth(4), right: 0)
        
        return lab
    }()
}

extension JournalReportWeekCalendarCell{
    func updateUI(dict:NSDictionary) {
        if dict.stringValueForKey(key: "weeklyLogDays").count > 0{
            hideSkeleton()
            titleLabel.text = dict.stringValueForKey(key: "weeklyLogDays")
            
            let perfectDayDict = dict["perfectDayText"]as? NSDictionary ?? [:]
            let string = perfectDayDict.stringValueForKey(key: "text")
            bestDayLabel.numberOfLines = 0
            if string.count > 0 {
                let keyWords = perfectDayDict["keywords"]as? NSArray ?? []
                bestDayLabel.attributedText = string.attributedText(text: "\(string)", keywords: keyWords as! [String], font: .systemFont(ofSize: 14, weight: .semibold),color: .THEME)
            }
            
            let weeklyAvgCalDict = dict["weeklyAvgCal"]as? NSDictionary ?? [:]
            detailCaloriesLabel.numberOfLines = 0
            detailCaloriesLabel.setText(weeklyAvgCalDict.stringValueForKey(key: "text"),
                                        keywords: weeklyAvgCalDict["keywords"]as? [String] ?? [])
//            detailCaloriesLabel.setText("这周平均每天摄入2000 kcal，与 “卷福”本尼迪克特·康伯巴奇 为拍摄《神探夏洛克》保持瘦削体态时日常摄入的热量接近。",
//                                        keywords: ["“卷福”本尼迪克特·康伯巴奇 为拍摄《神探夏洛克》保持瘦削体态时日常摄入"])
            let weeklyTotalProDict = dict["weeklyTotalPro"]as? NSDictionary ?? [:]
            detailProteinLabel.setText(weeklyTotalProDict.stringValueForKey(key: "text"),
                                        keywords: weeklyTotalProDict["keywords"]as? [String] ?? [])
            if let (startMonth, endMonth) = Date().getStartAndEndMonth(from: dict.stringValueForKey(key: "startDate"), to: dict.stringValueForKey(key: "endDate")) {
                print("Start: \(startMonth), End: \(endMonth)")
                self.calendarVm.updateUI(startDate: startMonth, endDate: endMonth,perfectDay:dict.stringValueForKey(key: "perfectDay"), logsDate: dict["dietLogList"]as? NSArray ?? [])
    //            self.calendarVm.updateUI(startDate: "2024-12-28", endDate: "2025-1-5")
    //            self.calendarVm.updateUI(startDate: "2025-5-25", endDate: "2025-6-2")
            }
        }
    }
    func styledText(
        from text: String,
        highlighting keywords: [String],
        underLineColor:UIColor = .THEME,
        lineSpacing: CGFloat = 6.0,
        baseFont: UIFont = .systemFont(ofSize: 12, weight: .regular),
        foregroundColor:UIColor = .COLOR_TEXT_TITLE_0f1214,
        highlightFont: UIFont = .systemFont(ofSize: 16, weight: .semibold),
        foregroundColorHighLight:UIColor = .COLOR_TEXT_TITLE_0f1214
    ) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedString = NSMutableAttributedString(string: text, attributes: baseAttributes)
//        let underLineShadow = NSShadow()
//        underLineShadow.shadowColor = UIColor.THEME
//        underLineShadow.shadowBlurRadius = 0
//        underLineShadow.shadowOffset = CGSize.init(width: 0, height: 1)
        
        for keyword in keywords {
            let pattern = NSRegularExpression.escapedPattern(for: keyword)
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: (text as NSString).length))
                for match in matches {
                    let highlightAttributes: [NSAttributedString.Key: Any] = [
                        .font: highlightFont,
                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                        .underlineColor:underLineColor,
//                        .shadow:underLineShadow,
                        .foregroundColor: foregroundColorHighLight
                    ]
                    attributedString.addAttributes(highlightAttributes, range: match.range)
                }
            }
        }

        return attributedString
    }
}
extension JournalReportWeekCalendarCell{
    func initUI() {
        contentView.addSubview(bgView)
        contentView.addSubview(circleView)
        bgView.addSubview(titleLabel)
        contentView.addSubview(bestDayLabel)
        contentView.addSubview(calendarBgView)
        calendarBgView.addSubview(calendarVm)
        contentView.addSubview(detailCaloriesLabel)
        contentView.addSubview(detailProteinLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalToSuperview()
//            make.height.equalTo(kFitWidth(465))
            make.bottom.equalToSuperview()
        }
        circleView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(27))
            make.width.height.equalTo(kFitWidth(6))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(29))
//            make.left.equalTo(kFitWidth(44))
            make.centerY.lessThanOrEqualTo(circleView)
//            make.height.equalTo(kFitWidth(28))
        }
        bestDayLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(45))
            make.right.equalTo(kFitWidth(-45))
//            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(8))
//            make.top.equalTo(kFitWidth(47))
            make.top.equalTo(kFitWidth(52))
//            make.height.equalTo(kFitWidth(24))
        }
        calendarBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(bestDayLabel.snp.bottom).offset(kFitWidth(25))
            make.height.equalTo(kFitWidth(178))
        }
        detailProteinLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(45))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(detailCaloriesLabel.snp.bottom).offset(kFitWidth(20))
            make.bottom.equalTo(kFitWidth(-16))
        }
        detailCaloriesLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(45))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(calendarBgView.snp.bottom).offset(kFitWidth(25))
        }
    }
}
