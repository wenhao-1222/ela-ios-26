//
//  MallPaySuccessTopCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/16.
//


class MallPaySuccessTopCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .COLOR_BG_WHITE
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(6)
        img.backgroundColor = .COLOR_BG_F5
        img.clipsToBounds = true
        
        
        return img
    }()
    lazy var nameLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.customLineHeight = 1.2
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var subTitleLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.customLineHeight = 1.2
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        return lab
    }()
    lazy var numberLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.customLineHeight = 1.2
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        return lab
    }()
    lazy var dottedLineView: DottedLineView = {
        let vi = DottedLineView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(134), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(1)))
        
        return vi
    }()
}
extension MallPaySuccessTopCell{
    func updateUI(model:MallDetailModel,number:Int) {
        imgView.setImgUrl(urlString: model.image_order)
        nameLabel.text = model.skuName
        subTitleLabel.text = model.subtitle
        numberLabel.text = "数量：\(number)"
    }
}

extension MallPaySuccessTopCell{
    func initUI() {
        contentView.addSubview(imgView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(numberLabel)
        contentView.addSubview(dottedLineView)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(25))
            make.width.height.equalTo(kFitWidth(90))
            make.bottom.equalTo(kFitWidth(-30))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(kFitWidth(20))
            make.centerY.lessThanOrEqualTo(kFitWidth(48))
            make.right.equalTo(kFitWidth(-16))
        }
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(nameLabel.snp.bottom).offset(kFitWidth(4))
        }
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(subTitleLabel.snp.bottom).offset(kFitWidth(2))
        }
    }
}
