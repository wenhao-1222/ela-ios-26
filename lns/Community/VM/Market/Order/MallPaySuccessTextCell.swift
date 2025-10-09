//
//  MallPaySuccessTextCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/16.
//


class MallPaySuccessTextCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .COLOR_BG_WHITE
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var leftTitleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        
        return lab
    }()
    lazy var rightDetailLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.customLineHeight = 1.2
        lab.textAlignment = .right
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
}

extension MallPaySuccessTextCell{
    func updateUI(leftTitle:String,detailString:String,textColor:UIColor = .COLOR_TEXT_TITLE_0f1214) {
        leftTitleLabel.text = leftTitle
        rightDetailLabel.text = detailString
        rightDetailLabel.textColor = textColor
    }
}

extension MallPaySuccessTextCell{
    func initUI() {
        contentView.addSubview(leftTitleLabel)
        contentView.addSubview(rightDetailLabel)
        
        setConstrait()
    }
    func setConstrait() {
        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(10))
        }
        rightDetailLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.left.equalTo(kFitWidth(110))
            make.top.equalTo(kFitWidth(10))
            make.bottom.equalTo(kFitWidth(-4))
        }
    }
}
