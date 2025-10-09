//
//  MallConfirmOrderMsgCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/11.
//


class MallConfirmOrderMsgCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        initUI()
    }
    lazy var imgView : UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(12)
        img.backgroundColor = .COLOR_BG_F5
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    lazy var nameLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.customLineHeight = 1.2
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var specLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var priceLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .semibold)
        
        return lab
    }()
    lazy var expressDescLabel: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .COLOR_BUTTON_HIGHLIGHT_BG_THEME_10
        lab.layer.cornerRadius = kFitWidth(4)
        lab.clipsToBounds = true
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        lab.textColor = .THEME
        lab.isHidden = true
        
        return lab
    }()
}

extension MallConfirmOrderMsgCell{
    func updateUI(model:MallDetailModel,spec:String,number:Int) {
        imgView.setImgUrl(urlString: model.image_order)
        nameLabel.text = model.skuName
        specLabel.text = spec
        numberLabel.text = "数量：\(number)"
        expressDescLabel.text = ""//" 满49元，免运费    "
        
        let attr = NSMutableAttributedString(string: "¥")
        let priceAttr = NSMutableAttributedString(string: WHUtils.convertStringToString("\(model.price_sale.floatValue * Float(number))") ?? "0")
        attr.yy_font = .systemFont(ofSize: 13, weight: .semibold)
        priceAttr.yy_font = .systemFont(ofSize: 18, weight: .semibold)
        attr.append(priceAttr)
        priceLabel.attributedText = attr
    }
}

extension MallConfirmOrderMsgCell{
    func initUI() {
        contentView.addSubview(imgView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(specLabel)
        contentView.addSubview(numberLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(expressDescLabel)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(20))
            make.height.equalTo(kFitWidth(114))
            make.width.equalTo(kFitWidth(90))
            make.bottom.equalTo(kFitWidth(-20))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.centerY.lessThanOrEqualTo(kFitWidth(42))
        }
        specLabel.snp.makeConstraints { make in
            make.left.right.equalTo(nameLabel)
//            make.top.equalTo(nameLabel.snp.bottom).offset(kFitWidth(7))
            make.bottom.equalTo(numberLabel.snp.top)
        }
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
//            make.top.equalTo(specLabel.snp.bottom)
            make.bottom.equalTo(priceLabel.snp.top).offset(kFitWidth(-12))
        }
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
//            make.top.equalTo(specLabel.snp.bottom).offset(kFitWidth(12))
            make.bottom.equalTo(imgView).offset(kFitWidth(-4))
        }
        expressDescLabel.snp.makeConstraints { make in
            make.left.equalTo(priceLabel.snp.right).offset(kFitWidth(12))
            make.centerY.lessThanOrEqualTo(priceLabel)
            make.height.equalTo(kFitWidth(15))
        }
    }
}
