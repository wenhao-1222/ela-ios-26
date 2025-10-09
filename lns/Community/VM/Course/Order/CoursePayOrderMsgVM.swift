//
//  CoursePayOrderMsgVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/17.
//

class CoursePayOrderMsgVM : UIView{
    
    var selfHeight = kFitWidth(154)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
        initUI()
    }
    lazy var coverImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(12)
        img.clipsToBounds = true
        
        return img
    }()
    lazy var titleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var subtitleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var priceLab: UILabel = {
        let lab = UILabel()
        lab.text = "¥"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .semibold)
        return lab
    }()
    lazy var priceLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .semibold)
        return lab
    }()
}

extension CoursePayOrderMsgVM{
    func updateUI(dict:NSDictionary) {
        let coverInfo = dict["coverInfo"]as? NSDictionary ?? [:]
        coverImgView.setImgUrl(urlString: coverInfo.stringValueForKey(key: "placeOrderImageOssUrl"))
        
        titleLab.text = dict.stringValueForKey(key: "detailTitle")
        subtitleLab.text = dict.stringValueForKey(key: "detailSubtitle")
//        titleLab.text = dict.stringValueForKey(key: "title")
//        subtitleLab.text = dict.stringValueForKey(key: "subtitle")
        priceLabel.text = dict.stringValueForKey(key: "price")
    }
}

extension CoursePayOrderMsgVM{
    func initUI() {
        addSubview(coverImgView)
        addSubview(titleLab)
        addSubview(subtitleLab)
        addSubview(priceLab)
        addSubview(priceLabel)
        
        setConstrait()
    }
    func setConstrait() {
        coverImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(20))
            make.width.equalTo(kFitWidth(90))
            make.height.equalTo(kFitWidth(114))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(coverImgView.snp.right).offset(kFitWidth(20))
            make.top.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-16))
        }
        subtitleLab.snp.makeConstraints { make in
            make.left.equalTo(titleLab)
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(55))
        }
        priceLab.snp.makeConstraints { make in
            make.left.equalTo(titleLab)
            make.bottom.equalTo(kFitWidth(-27))
        }
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(priceLab.snp.right).offset(kFitWidth(3.5))
            make.centerY.lessThanOrEqualTo(priceLab)
        }
    }
}
