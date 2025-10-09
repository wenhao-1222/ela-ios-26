//
//  AITipsDonationTypeCell.swift
//  lns
//
//  Created by Elavatine on 2025/3/6.
//


class AITipsDonationTypeCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "捐款方式：微信公众号搜索“Elavatine”-点击右下角“捐赠”"
        lab.textColor = .black
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        return lab
    }()
    lazy var contentLab: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColor_16(colorStr: "808080")
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
}

extension AITipsDonationTypeCell{
    func initUI() {
        contentView.addSubview(titleLab)
        contentView.addSubview(contentLab)
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(10))
        }
        contentLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(35))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-20))
        }
    }
}
