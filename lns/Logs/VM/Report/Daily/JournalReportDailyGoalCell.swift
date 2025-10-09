//
//  JournalReportDailyGoalCell.swift
//  lns
//
//  Created by Elavatine on 2025/5/12.
//


class JournalReportDailyGoalCell: UITableViewCell {
    
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
//        vi.isSkeletonable = true
        
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.text = "你今天比计划"
        lab.isHidden = true
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.textAlignment = .center
        lab.layer.cornerRadius = kFitWidth(3)
        lab.clipsToBounds = true
        lab.layer.borderColor = UIColor.white.cgColor
        lab.layer.borderWidth = kFitWidth(1)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var caloriesImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "report_daily_calories_bg_icon")
        
        return img
    }()
    lazy var contentLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
//        lab.numberOfLines = 2
//        lab.lineBreakMode = .byWordWrapping
        lab.isSkeletonable = true
        lab.adjustsFontSizeToFitWidth = true
        lab.updateSkeleton(usingColor: .red)
        
        return lab
    }()
    lazy var whiteVi: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        
        return vi
    }()
}

extension JournalReportDailyGoalCell{
    func updateUI(dict:NSDictionary) {
        let string = dict.stringValueForKey(key: "text")
        if string.count > 0 {
            hideSkeleton()
            titleLab.isHidden = false
            
            let keyWords = dict["keywords"]as? NSArray ?? []
            
            contentLab.attributedText = string.attributedText(text: string, keywords: keyWords as! [String], font: UIFont().DDInFontSemiBold(fontSize: 28),color: .white)
        }
    }
    func refreshLabelFrame(isAchieved:Bool) {
        if isAchieved{
            titleLab.snp.remakeConstraints { make in
                make.left.top.equalTo(kFitWidth(16))
                make.width.equalTo(kFitWidth(130))
                make.height.equalTo(kFitWidth(28))
            }
            let attr = NSMutableAttributedString(string: "达成目标 ")
            let attr1 = NSMutableAttributedString(string: "±100千卡")
            attr1.yy_font = .systemFont(ofSize: 12, weight: .medium)
            attr.append(attr1)
            titleLab.attributedText = attr
        }else{
            titleLab.snp.remakeConstraints { make in
                make.left.top.equalTo(kFitWidth(16))
                make.width.equalTo(kFitWidth(104))
                make.height.equalTo(kFitWidth(28))
            }
            titleLab.text = "你今天比计划"
        }
    }
}

extension JournalReportDailyGoalCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(caloriesImg)
        bgView.addSubview(titleLab)
        bgView.addSubview(whiteVi)
        contentView.addSubview(contentLab)
        
        setConstrait()
        
//        bgView.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(12))
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalToSuperview()
//            make.bottom.equalToSuperview()
            make.bottom.equalTo(kFitWidth(12))
        }
        titleLab.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
//            make.width.equalTo(kFitWidth(104))
            make.width.equalTo(kFitWidth(130))
            make.height.equalTo(kFitWidth(28))
        }
        contentLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(56))
            make.right.equalTo(kFitWidth(-31))
//            make.width.equalTo(kFitWidth(200))
            make.height.equalTo(kFitWidth(30))
            make.bottom.equalTo(kFitWidth(-25))
        }
        caloriesImg.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-22))
            make.width.equalTo(kFitWidth(125))
            make.height.equalTo(kFitWidth(88))
        }
        whiteVi.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(kFitWidth(2))
            make.height.equalTo(kFitWidth(24))
        }
    }
}
