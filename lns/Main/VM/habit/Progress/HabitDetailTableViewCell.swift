//
//  HabitDetailTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2025/12/24.
//


class HabitDetailTableViewCell: FeedBackTableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "捐赠 1 餐"
        
        return lab
    }()
    lazy var timeLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.text = "12月24日16:50:48"
        return lab
    }()
    lazy var numberLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.text = "-783"
        return lab
    }()
}

extension HabitDetailTableViewCell{
    func updateUI(dict:NSDictionary) {
        titleLab.text = dict.stringValueForKey(key: "bizTypeValue")
        timeLab.text = dict.stringValueForKey(key: "ctime")
        
        if dict.stringValueForKey(key: "changeValue").contains("-"){
            numberLab.text = "\(dict.stringValueForKey(key: "changeValue"))"
            numberLab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        }else{
            numberLab.text = "+\(dict.stringValueForKey(key: "changeValue"))"
            numberLab.textColor = .THEME
        }
    }
}

extension HabitDetailTableViewCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(timeLab)
        bgView.addSubview(numberLab)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.bottom.equalToSuperview()
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(63))
        }
        timeLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(titleLab.snp.bottom)
            make.height.equalTo(kFitWidth(33))
        }
        numberLab.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(8.5))
//            make.centerY.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(21))
        }
    }
}

