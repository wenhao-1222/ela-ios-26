//
//  MallConfirmOrderExpCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/16.
//


class MallConfirmOrderExpCell: UITableViewCell {
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        initUI()
    }
    lazy var topLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        return vi
    }()
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        
        return vi
    }()
    lazy var leftTitleLab: UILabel = {
        let lab = UILabel()
        lab.text = "运费"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        
        return lab
    }()
    lazy var expressLineLabel: UILabel = {
        let lab = UILabel()
        let text = "¥13"
        lab.text = text
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        let attributeString = NSMutableAttributedString(string: text)
       attributeString.addAttribute(.strikethroughStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: NSMakeRange(0, attributeString.length))
       lab.attributedText = attributeString
        return lab
    }()
    lazy var expressLabel: UILabel = {
        let lab = UILabel()
        lab.text = "免运费"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .semibold)
        return lab
    }()
}

extension MallConfirmOrderExpCell{
    func updateExpress(shippingFee:String,isfreeShipping:Bool) {
        if isfreeShipping {
            expressLineLabel.isHidden = false
            expressLabel.text = "免运费"
            
            var attributeString = NSMutableAttributedString(string: "¥ \(shippingFee)")
            if shippingFee.floatValue == 0 {
                attributeString = NSMutableAttributedString(string: "¥ 13")
            }
           attributeString.addAttribute(.strikethroughStyle,
                                        value: NSUnderlineStyle.single.rawValue,
                                        range: NSMakeRange(0, attributeString.length))
            expressLineLabel.attributedText = attributeString
        }else{
            expressLineLabel.isHidden = true
            expressLabel.text = "¥ \(shippingFee)"
        }
    }
}

extension MallConfirmOrderExpCell{
    func initUI() {
        contentView.backgroundColor = .COLOR_BG_F2
        contentView.addSubview(whiteView)
        contentView.addSubview(topLineView)
        contentView.addSubview(leftTitleLab)
        contentView.addSubview(expressLineLabel)
        contentView.addSubview(expressLabel)
        
        setConstrait()
    }
    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-8))
        }
        topLineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
        leftTitleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(47))
            make.top.equalTo(kFitWidth(12))
            make.bottom.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(20))
        }
        expressLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-36))
            make.centerY.lessThanOrEqualTo(leftTitleLab)
        }
        expressLineLabel.snp.makeConstraints { make in
            make.right.equalTo(expressLabel.snp.left).offset(kFitWidth(-10))
            make.centerY.lessThanOrEqualTo(leftTitleLab)
        }
    }
}
