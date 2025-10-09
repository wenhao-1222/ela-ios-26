//
//  MallConfirmOrderAddressCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/11.
//


class MallConfirmOrderAddressCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        initUI()
    }
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        
        return vi
    }()
    lazy var addressIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "mall_order_address_icon")
        
        
        return img
    }()
    lazy var addressLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.customLineHeight = 1.2
//        lab.numberOfLines = 0
//        lab.lineBreakMode = .byWordWrapping
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "请添加收件地址"
        
        return lab
    }()
    lazy var arrowImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "mine_func_arrow_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
}

extension MallConfirmOrderAddressCell{
    func updateAddress(model:AddressModel) {
        if model.contactName.count > 0 {
            addressLabel.textColor = .COLOR_TEXT_TITLE_0f1214
            addressLabel.text = "\(model.contactName) \(model.detailAddressWhole)"
        }else{
            addressLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
            addressLabel.text = "请添加收件地址"
        }
    }
}

extension MallConfirmOrderAddressCell{
    func initUI() {
        contentView.backgroundColor = .COLOR_BG_F2
        contentView.addSubview(whiteView)
        contentView.addSubview(addressIcon)
        contentView.addSubview(addressLabel)
        contentView.addSubview(arrowImgView)
        
        setConstrait()
    }
    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kFitWidth(8))
            make.bottom.equalTo(kFitWidth(0))
        }
        addressIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
//            make.top.equalTo(kFitWidth(15))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(25))
        }
        addressLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(47))
            make.top.equalTo(kFitWidth(25))
            make.bottom.equalTo(kFitWidth(-25))
            make.right.equalTo(kFitWidth(-48))
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
    }
}
