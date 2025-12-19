//
//  ServiceOrderTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2025/12/10.
//


class ServiceOrderTableViewCell: UITableViewCell {
    
    var sendTapBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var orderNoLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var sendLabel: UILabel = {
        let lab = UILabel()
        lab.text = "发送"
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 13, weight: .medium)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var sendTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(sendTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var goodgBgView: UIView = {
        let vi = UIView()
        
        return vi
    }()
    private lazy var goodsImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(6)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
        
        return img
    }()

    private lazy var goodsNameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.numberOfLines = 2
        return lab
    }()

    private lazy var goodsSubtitleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.numberOfLines = 2
        return lab
    }()
    
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_F0
        
        return vi
    }()
}

extension ServiceOrderTableViewCell{
    @objc func sendTapAction() {
        self.sendTapBlock?()
    }
}

extension ServiceOrderTableViewCell{
    func updateUI(dict:NSDictionary) {
        DLLog(message: "刷新订单列表\(dict)")
        orderNoLabel.text = "订单号 \(dict.stringValueForKey(key: "id"))"
        var imgUrl = ""
        if dict.stringValueForKey(key: "bizType") == "1"{//教程
            let coverInfo = dict["coverInfo"] as? NSDictionary ?? [:]
            imgUrl = coverInfo.stringValueForKey(key: "orderListImageOssUrl")
            goodsNameLabel.text = dict.stringValueForKey(key: "title")
            goodsSubtitleLabel.text = dict.stringValueForKey(key: "subtitle")
        }else{//商品订单
            goodsNameLabel.text = dict.stringValueForKey(key: "skuName")
            
            let coverInfo = dict["squareImage"] as? NSArray ?? []
            if coverInfo.count > 0 {
                imgUrl = coverInfo[0]as? String ?? ""
            }
            
            let specList = dict["specValueList"]as? NSArray ?? []
            var spec = ""
            for i in 0..<specList.count{
                let s = specList[i]as? String ?? ""
                spec += s
                if i < specList.count - 1{
                    spec += " | "
                }
            }
            updateDevice(phoneName: spec)
        }
        if imgUrl.count > 0 {
            goodsImgView.setImgUrl(urlString: imgUrl)
        }else{
            goodsImgView.image = nil
        }
    }
    
    func updateDevice(phoneName: String) {
        let attr = NSMutableAttributedString(string: "型号：")
        let attrTime = NSMutableAttributedString(string: phoneName.count > 0 ? phoneName : "-")
        attr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        attrTime.yy_color = .COLOR_TEXT_TITLE_0f1214
        attr.append(attrTime)
        goodsSubtitleLabel.attributedText = attr
    }
    
}

extension ServiceOrderTableViewCell{
    func initUI() {
        contentView.addSubview(orderNoLabel)
        contentView.addSubview(sendLabel)
        contentView.addSubview(sendTapView)
        contentView.addSubview(goodgBgView)
        contentView.addSubview(lineView)
        goodgBgView.addSubview(goodsImgView)

        let infoStack = UIStackView(arrangedSubviews: [goodsNameLabel, goodsSubtitleLabel])
        infoStack.axis = .vertical
        infoStack.spacing = kFitWidth(4)
        infoStack.alignment = .leading
        goodgBgView.addSubview(infoStack)
        
        orderNoLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(10))
            make.height.equalTo(kFitWidth(18))
        }
        sendLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(orderNoLabel)
        }
        sendTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(sendLabel)
            make.width.height.equalTo(kFitWidth(50))
        }

        goodgBgView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: kFitWidth(45), left: kFitWidth(16), bottom: kFitWidth(16), right: kFitWidth(16)))
        }

        goodsImgView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(75))
            make.bottom.lessThanOrEqualToSuperview()
        }
        infoStack.snp.makeConstraints { make in
            make.left.equalTo(goodsImgView.snp.right).offset(kFitWidth(15))
            make.top.equalTo(goodsImgView)
            make.right.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }
}
