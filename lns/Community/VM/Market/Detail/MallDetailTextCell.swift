//
//  MallDetailTextCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/8.
//


class MallDetailTextCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .COLOR_BG_WHITE
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var mallTextLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.customLineHeight = 1.2
        return lab
    }()
}
extension MallDetailTextCell{
    func updateText(text:String,textColor:UIColor,textFont:UIFont,topGap:CGFloat,bottomGap:CGFloat=kFitWidth(0)) {
        mallTextLabel.textColor = textColor
        mallTextLabel.font = textFont
        mallTextLabel.text = text
        mallTextLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(topGap)
            make.right.equalTo(kFitWidth(-15))
            make.bottom.equalTo(-bottomGap)
        }
    }
}

extension MallDetailTextCell{
    func initUI() {
        contentView.addSubview(mallTextLabel)
        
        mallTextLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(15))
            make.right.equalTo(kFitWidth(-15))
        }
    }
}
