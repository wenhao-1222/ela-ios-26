//
//  MallConfirmOrderAddressCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/11.
//


class MallConfirmOrderAddressCell: UITableViewCell {
    
    var tapBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        initUI()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
    }
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        
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
        img.setImgLocal(imgName: "plan_arrow_gray")
        img.isUserInteractionEnabled = true
        
        return img
    }()
}

extension MallConfirmOrderAddressCell{
    func updateAddress(model:AddressModel) {
        addressIcon.setImgLocal(imgName: "mall_order_address_icon")
        if model.contactName.count > 0 {
            addressLabel.textColor = .COLOR_TEXT_TITLE_0f1214
            addressLabel.text = "\(model.contactName) \(model.detailAddressWhole)"
        }else{
            addressLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
            addressLabel.text = "请添加收件地址"
        }
    }
    func updateIdcMsg(authenDict:NSDictionary) {
        addressIcon.setImgLocal(imgName: "mall_order_idcard_icon")
        
        if authenDict.stringValueForKey(key: "legalName").count > 0{
            addressLabel.textColor = .COLOR_TEXT_TITLE_0f1214
            addressLabel.text = authenDict.stringValueForKey(key: "legalName") + "  " + authenDict.stringValueForKey(key: "identifyNum")
        }else{
            addressLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
            addressLabel.text = "请提交清关信息"
        }
    }
}

extension MallConfirmOrderAddressCell{
    @objc func tapAction() {
        self.tapBlock?()
    }
}

extension MallConfirmOrderAddressCell{
    func initUI() {
        contentView.backgroundColor = .COLOR_BG_F2
        contentView.addSubview(whiteView)
        whiteView.addSubview(addressIcon)
        whiteView.addSubview(addressLabel)
        whiteView.addSubview(arrowImgView)
        
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
//            make.top.equalTo(kFitWidth(33))
            make.top.equalTo(kFitWidth(15))
            make.bottom.equalTo(kFitWidth(-15))
            make.right.equalTo(kFitWidth(-48))
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
    }
}
