//
//  HabitDetailTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2025/12/24.
//


class HabitDetailTableViewCell: FeedBackTableViewCell {
    private enum CornerStyle {
        case none
        case top
        case bottom
        case all
    }
    
    private var cornerStyle: CornerStyle = .none
    
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
        lab.font = .systemFont(ofSize: 15, weight: .medium)
        lab.numberOfLines = 1
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
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        lab.textAlignment = .right
        lab.text = "-783"
        return lab
    }()
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "F1F2F4")
        return view
    }()
}

extension HabitDetailTableViewCell{
    override func layoutSubviews() {
        super.layoutSubviews()
        applyCornerStyle()
    }
    
    func updateUI(dict:NSDictionary, isFirst: Bool, isLast: Bool) {
        titleLab.text = dict.stringValueForKey(key: "bizTypeValue")
        timeLab.text = dict.stringValueForKey(key: "ctime")
        
        let changeValue = dict.stringValueForKey(key: "changeValue")
        if changeValue.contains("-"){
            numberLab.text = changeValue
            numberLab.textColor = UIColor(hex: "A0A3AA")
        }else{
            numberLab.text = "+\(changeValue)"
            numberLab.textColor = UIColor(hex: "2997FF")
        }
        
        separatorView.isHidden = isLast
        if isFirst && isLast {
            cornerStyle = .all
        } else if isFirst {
            cornerStyle = .top
        } else if isLast {
            cornerStyle = .bottom
        } else {
            cornerStyle = .none
        }
        
        setNeedsLayout()
    }
}

extension HabitDetailTableViewCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(timeLab)
        bgView.addSubview(numberLab)
        bgView.addSubview(separatorView)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.right.equalTo(kFitWidth(-14))
            make.top.bottom.equalToSuperview()
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(11))
            make.right.lessThanOrEqualTo(numberLab.snp.left).offset(kFitWidth(-12))
        }
        timeLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(4))
            make.right.lessThanOrEqualTo(numberLab.snp.left).offset(kFitWidth(-12))
            make.bottom.equalTo(kFitWidth(-11))
        }
        numberLab.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(kFitWidth(52))
        }
        separatorView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func applyCornerStyle() {
        bgView.layer.cornerRadius = 0
        bgView.layer.maskedCorners = []
        
        switch cornerStyle {
        case .none:
            break
        case .top:
            bgView.layer.cornerRadius = kFitWidth(12)
            bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottom:
            bgView.layer.cornerRadius = kFitWidth(12)
            bgView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .all:
            bgView.layer.cornerRadius = kFitWidth(12)
            bgView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        }
        bgView.layer.masksToBounds = cornerStyle != .none
    }
}
