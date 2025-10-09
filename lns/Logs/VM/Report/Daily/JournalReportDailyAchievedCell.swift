//
//  JournalReportDailyAchievedCell.swift
//  lns
//  日报--目标达成
//  Created by Elavatine on 2025/5/13.
//


class JournalReportDailyAchievedCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.clipsToBounds = true
        
        initUI()
    }
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var daysLab: UILabel = {
        let lab = UILabel()
        lab.text = "已经连续"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    lazy var daysLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 13, weight: .semibold)
        return lab
    }()
    lazy var percentLab: UILabel = {
        let lab = UILabel()
        lab.text = "打败了elavatine内"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    lazy var percentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 13, weight: .semibold)
        return lab
    }()
}

extension JournalReportDailyAchievedCell{
    func updateUI(dict:NSDictionary) {
        let streakDict = dict["streak"]as? NSDictionary ?? [:]
        let defeatedDict = dict["defeated"]as? NSDictionary ?? [:]
        
        var streakAttr = NSMutableAttributedString(string: streakDict.stringValueForKey(key: "text"))
        var streakAttr1 = NSMutableAttributedString(string: "天")
        streakAttr.yy_font = UIFont().DDInFontBold(fontSize: 28)
        streakAttr.append(streakAttr1)
        daysLabel.attributedText = streakAttr
        
        var defeatAttr = NSMutableAttributedString(string: defeatedDict.stringValueForKey(key: "text"))
        var defeatAttr1 = NSMutableAttributedString(string: "%用户")
        defeatAttr.yy_font = UIFont().DDInFontBold(fontSize: 28)
        defeatAttr.append(defeatAttr1)
        percentLabel.attributedText = defeatAttr
    }
}

extension JournalReportDailyAchievedCell{
    func initUI() {
        contentView.addSubview(whiteView)
        whiteView.addSubview(daysLab)
        whiteView.addSubview(daysLabel)
        whiteView.addSubview(percentLab)
        whiteView.addSubview(percentLabel)
        
        setConstrait()
    }
    func setConstrait(){
        whiteView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(-12))
            make.bottom.equalToSuperview()
        }
        daysLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(12))
            make.bottom.equalTo(kFitWidth(-59))
        }
        daysLabel.snp.makeConstraints { make in
            make.left.equalTo(daysLab)
            make.top.equalTo(daysLab.snp.bottom).offset(kFitWidth(6))
        }
        percentLab.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-15))
            make.width.equalTo(kFitWidth(140))
            make.centerY.lessThanOrEqualTo(daysLab)
        }
        percentLabel.snp.makeConstraints { make in
            make.left.equalTo(percentLab)
            make.top.equalTo(percentLab.snp.bottom).offset(kFitWidth(6))
        }
    }
}
