//
//  JournalReportFriendWeekTopCell.swift
//  lns
//
//  Created by Elavatine on 2025/7/7.
//



class JournalReportFriendWeekTopCell: UITableViewCell {
    
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
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(16)
        img.clipsToBounds = true
        img.isSkeletonable = true
        
        return img
    }()
    lazy var nickNameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_BG_WHITE
        lab.font = .systemFont(ofSize: 15, weight: .semibold)
        lab.isSkeletonable = true
        
        return lab
    }()
    lazy var titleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .white
        lab.text = "本周营养分析"
        lab.font = .systemFont(ofSize: 18, weight: .semibold)
        
        return lab
    }()
    lazy var contentLab: LineHeightLabel = {
        let lab = LineHeightLabel()
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

extension JournalReportFriendWeekTopCell{
    func updateUI(dict:NSDictionary){
        let startDate = dict.stringValueForKey(key: "startDate")
        
        if startDate.count > 0 {
            hideSkeleton()
            
            headImgView.setImgUrl(urlString: dict.stringValueForKey(key: "headimgurl"))
            nickNameLabel.text = dict.stringValueForKey(key: "nickname")
            let endDate = dict.stringValueForKey(key: "endDate")
            contentLab.text = "\(startDate) ~ \(endDate) "
        }
    }
}

extension JournalReportFriendWeekTopCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(headImgView)
        bgView.addSubview(nickNameLabel)
        bgView.addSubview(titleLab)
        bgView.addSubview(whiteVi)
        contentView.addSubview(contentLab)
        
        setConstrait()
//        titleLab.setLineHeight(textString: "本周营养分析",lineHeight: kFitWidth(31))
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(20))
            make.bottom.equalTo(kFitWidth(12))
        }
        headImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(20))
            make.width.height.equalTo(kFitWidth(32))
        }
        nickNameLabel.snp.makeConstraints { make in
            make.left.equalTo(headImgView.snp.right).offset(kFitWidth(10))
            make.centerY.lessThanOrEqualTo(headImgView)
            make.right.equalTo(kFitWidth(-20))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.width.equalTo(kFitWidth(140))
            make.top.equalTo(kFitWidth(71))
        }
        contentLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
//            make.top.equalTo(kFitWidth(102))
            make.top.equalTo(titleLab.snp.bottom)
            make.right.equalTo(kFitWidth(-32))
            make.bottom.equalTo(kFitWidth(-30))
//            make.height.equalTo(kFitWidth(20))
        }
        whiteVi.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-2))
            make.height.equalTo(kFitWidth(28))
        }
    }
}
