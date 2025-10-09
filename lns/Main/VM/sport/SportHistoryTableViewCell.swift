//
//  SportHistoryTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2024/11/25.
//


class SportHistoryTableViewCell: FeedBackTableViewCell {
    
    var tapBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
//        self.addGestureRecognizer(tap)
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var caloriesIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "sport_calories_icon")
        return img
    }()
    lazy var caloriesLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14, weight: .bold)
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()
    
    lazy var timeIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "sport_time_icon")
        return img
    }()
    lazy var timeLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14, weight: .bold)
        lab.textColor = .COLOR_GRAY_BLACK_85
        return lab
    }()
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_45
        return lab
    }()
    lazy var sourceLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        return vi
    }()
}

extension SportHistoryTableViewCell{
    func updateUI(model:SportHistoryModel) {
        caloriesLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(model.calories.doubleValue.rounded())") ?? "0")千卡"
        timeLabel.text = "\(model.duration)分钟"
        nameLabel.text = model.name
        
        if model.source == "2"{
            if model.isSyn == false{
                sourceLabel.text = "-来自苹果“健康”，未计入营养目标"
            }else{
                sourceLabel.text = "-来自苹果“健康”APP"
            }
        }else{
            sourceLabel.text = ""
        }
    }
}

extension SportHistoryTableViewCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(caloriesIcon)
        bgView.addSubview(caloriesLabel)
        bgView.addSubview(timeIcon)
        bgView.addSubview(timeLabel)
        bgView.addSubview(nameLabel)
        bgView.addSubview(sourceLabel)
        bgView.addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        caloriesIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(11))
            make.width.height.equalTo(kFitWidth(14))
        }
        caloriesLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriesIcon.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(caloriesIcon)
            make.right.equalTo(timeIcon.snp.left).offset(kFitWidth(-4))
        }
        timeIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(110))
            make.centerY.lessThanOrEqualTo(caloriesIcon)
            make.width.height.equalTo(caloriesIcon)
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(timeIcon.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(timeIcon)
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(33))
        }
        sourceLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
//            make.centerY.lessThanOrEqualTo(nameLabel)
            make.bottom.equalTo(nameLabel)
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }
}
