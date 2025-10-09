//
//  MarketListGridCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/5.
//


class MarketListGridCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(12)
        img.clipsToBounds = true
        img.backgroundColor = .COLOR_BG_F2
        
        return img
    }()
    lazy var nameLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()
    lazy var detailLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()
    lazy var priceLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()
}

extension MarketListGridCell{
    func updateUI(model:MarketListModel) {
        imgView.setImgUrl(urlString: model.imgUrlForListShow)
        nameLabel.text = model.name
        detailLabel.text = model.descript
        priceLabel.text = "¥\(model.price)"
    }
}

extension MarketListGridCell{
    func initUI() {
        contentView.addSubview(imgView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(priceLabel)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(kFitWidth(11))
            make.width.equalTo(kFitWidth(162))
            make.height.equalTo(kFitWidth(203))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(11))
            make.top.equalTo(imgView.snp.bottom).offset(kFitWidth(11))
            make.right.equalTo(kFitWidth(-10))
        }
        detailLabel.snp.makeConstraints { make in
            make.left.right.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(kFitWidth(1))
        }
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(detailLabel.snp.bottom).offset(kFitWidth(3))
        }
    }
}
