//
//  MallOrderAfterSaleNotSupportCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/19.
//


class MallOrderAfterSaleNotSupportCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = .COLOR_BG_F2
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        
        return vi
    }()
    lazy var detailLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
}

extension MallOrderAfterSaleNotSupportCell{
    func updateUI(titleStr:String,detailString:String) {
        let attr = NSMutableAttributedString(string: "\(titleStr)\n")
        let detailAttr = NSMutableAttributedString(string: detailString)
        
        attr.yy_font = .systemFont(ofSize: 14, weight: .medium)
        attr.yy_color = .COLOR_TEXT_TITLE_0f1214
        detailAttr.yy_font = .systemFont(ofSize: 12, weight: .regular)
        detailAttr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        
        attr.append(detailAttr)
        
        detailLabel.attributedText = attr
    }
}

extension MallOrderAfterSaleNotSupportCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(detailLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(kFitWidth(11))
        }
        detailLabel.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.right.bottom.equalTo(kFitWidth(-16))
        }
    }
}
