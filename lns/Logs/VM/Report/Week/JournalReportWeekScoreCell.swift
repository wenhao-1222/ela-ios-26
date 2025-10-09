//
//  JournalReportWeekScoreCell.swift
//  lns
//  评分
//  Created by Elavatine on 2025/5/14.
//  report_ela_img


class JournalReportWeekScoreCell: UITableViewCell {
    
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
//        vi.isSkeletonable = true
        
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
    lazy var scoreLab: UILabel = {
        let lab = UILabel()
        lab.text = "本周饮食执行评分"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var percentLab: UILabel = {
        let lab = UILabel()
        lab.text = "超越了"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var scoreLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = UIFont().DDInFontBold(fontSize: 28)
        lab.isSkeletonable = true
//        lab.updateAnimatedSkeleton(usingColor: .THEME)
        
        return lab
    }()
    lazy var percentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = UIFont().DDInFontBold(fontSize: 28)
        lab.isSkeletonable = true
        lab.updateSkeleton(usingColor: .THEME)
        
        return lab
    }()
}

extension JournalReportWeekScoreCell{
    func updateUI(dict:NSDictionary) {
        if dict.stringValueForKey(key: "encourageSentence").count > 0 {
            hideSkeleton()
            titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(45))
                make.centerY.lessThanOrEqualTo(circleView)
            }
            scoreLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(49))
                make.bottom.equalTo(kFitWidth(-16))
            }
            percentLabel.snp.remakeConstraints { make in
                make.left.equalTo((SCREEN_WIDHT-kFitWidth(32))*0.5+kFitWidth(36))
                make.bottom.equalTo(scoreLabel)
            }
            titleLabel.text = dict.stringValueForKey(key: "encourageSentence")
            
            let scoreAttr = NSMutableAttributedString(string: "\(dict.stringValueForKey(key: "weeklyScore"))")
            let scoreAttr1 = NSMutableAttributedString(string: "分")
            scoreAttr1.yy_font = .systemFont(ofSize: 13, weight: .semibold)
            scoreAttr.append(scoreAttr1)
            scoreLabel.attributedText = scoreAttr
            
            let percentAttr = NSMutableAttributedString(string: "\(WHUtils.convertStringToString("\(dict.doubleValueForKey(key: "defeatUserRate"))") ?? "0")")
            let percentAttr1 = NSMutableAttributedString(string: "%用户")
            percentAttr1.yy_font = .systemFont(ofSize: 13, weight: .semibold)
            percentAttr.append(percentAttr1)
            percentLabel.attributedText = percentAttr
        }
    }
}

extension JournalReportWeekScoreCell{
    func initUI() {
        contentView.addSubview(bgView)
        contentView.addSubview(circleView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(scoreLab)
        contentView.addSubview(scoreLabel)
        bgView.addSubview(percentLab)
        contentView.addSubview(percentLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.bottom.equalToSuperview()
        }
        circleView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(16))
            make.right.equalTo(-(SCREEN_WIDHT-kFitWidth(38)))
            make.width.height.equalTo(kFitWidth(6))
            make.bottom.equalTo(kFitWidth(-93))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(45))
            make.centerY.lessThanOrEqualTo(circleView)
            make.width.equalTo(kFitWidth(180))
            make.height.equalTo(kFitWidth(24))
        }
        scoreLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(49))
            make.top.equalTo(kFitWidth(48))
        }
        percentLab.snp.makeConstraints { make in
            make.left.equalTo((SCREEN_WIDHT-kFitWidth(32))*0.5+kFitWidth(20))
            make.centerY.lessThanOrEqualTo(scoreLab)
        }
        scoreLabel.snp.makeConstraints { make in
//            make.left.equalTo(scoreLab)
            make.left.equalTo(kFitWidth(49))
            make.height.equalTo(kFitWidth(20))
            make.width.equalTo(kFitWidth(80))
            make.bottom.equalTo(kFitWidth(-16))
        }
        percentLabel.snp.makeConstraints { make in
//            make.left.equalTo(percentLab)
            make.left.equalTo((SCREEN_WIDHT-kFitWidth(32))*0.5+kFitWidth(36))
            make.bottom.equalTo(scoreLabel)
            make.height.equalTo(kFitWidth(20))
            make.width.equalTo(kFitWidth(80))
        }
    }
}
