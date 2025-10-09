//
//  JournalReportWeekTopCell.swift
//  lns
//
//  Created by Elavatine on 2025/5/14.
//


class JournalReportWeekTopCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.clipsToBounds = true
        isSkeletonable = true
        contentView.isSkeletonable = true
        
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
//        lab.text = "每周营养分析"
        lab.font = .systemFont(ofSize: 18, weight: .semibold)
        
        return lab
    }()
    lazy var contentLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.isSkeletonable = true
        
        return lab
    }()
    lazy var whiteVi: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        
        return vi
    }()
}

extension JournalReportWeekTopCell{
    func updateUI(dict:NSDictionary){
        let startDate = dict.stringValueForKey(key: "startDate")
        
        if startDate.count > 0 {
            hideSkeleton()
            contentLab.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(32))
                make.top.equalTo(kFitWidth(79))
                make.right.equalTo(kFitWidth(-32))
                make.bottom.equalTo(kFitWidth(-30))
            }
            let endDate = dict.stringValueForKey(key: "endDate")
            contentLab.setLineHeight(textString: "\(startDate) ~ \(endDate) ",lineHeight: kFitWidth(20))
        }
        
        
//        contentLab.setLineHeight(textString: "\(startDate.replacingOccurrences(of: "-", with: ".")) ~ \(endDate.replacingOccurrences(of: "-", with: "."))",lineHeight: kFitWidth(20))
    }
    func updateUIShare(dict:NSDictionary){
        let startDate = dict.stringValueForKey(key: "startDate")
        bgView.layer.cornerRadius = 0
        bgView.clipsToBounds = false
        bgView.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalToSuperview()
            make.bottom.equalTo(kFitWidth(12))
        }
        if startDate.count > 0 {
            hideSkeleton()
            contentLab.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(32))
                make.top.equalTo(kFitWidth(79))
                make.right.equalTo(kFitWidth(-32))
                make.bottom.equalTo(kFitWidth(-30))
            }
            let endDate = dict.stringValueForKey(key: "endDate")
            contentLab.setLineHeight(textString: "\(startDate) ~ \(endDate) ",lineHeight: kFitWidth(20))
        }
        
        
//        contentLab.setLineHeight(textString: "\(startDate.replacingOccurrences(of: "-", with: ".")) ~ \(endDate.replacingOccurrences(of: "-", with: "."))",lineHeight: kFitWidth(20))
    }
}

extension JournalReportWeekTopCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(whiteVi)
        contentView.addSubview(contentLab)
        
        setConstrait()
        titleLab.setLineHeight(textString: "本周营养分析",lineHeight: kFitWidth(31))
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(20))
            make.bottom.equalTo(kFitWidth(12))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(24))
        }
        contentLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(79))
            make.right.equalTo(kFitWidth(-32))
            make.bottom.equalTo(kFitWidth(-30))
            make.height.equalTo(kFitWidth(20))
        }
        whiteVi.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-2))
            make.height.equalTo(kFitWidth(28))
        }
    }
}
