//
//  MallOrderAfterSaleSubmitMsgCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/22.
//



class MallOrderAfterSaleSubmitMsgCell: UITableViewCell {
    
    var viewModules:[HeroBrowserViewModule] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var saleTypeLab: UILabel = {
        let lab = UILabel()
        lab.text = "售后类别"
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        
        return lab
    }()
    lazy var saleReasonLab: UILabel = {
        let lab = UILabel()
        lab.text = "申请原因"
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        
        return lab
    }()
    lazy var saleTimeLab: UILabel = {
        let lab = UILabel()
        lab.text = "申请时间"
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        
        return lab
    }()
    lazy var saleImgsLab: UILabel = {
        let lab = UILabel()
        lab.text = "相关图片"
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        
        return lab
    }()
    lazy var saleTypeLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.textAlignment = .right
        
        return lab
    }()
    lazy var saleReasonLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.textAlignment = .right
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var saleTimeLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.textAlignment = .right
        
        return lab
    }()
    lazy var imgOne: UIImageView = {
        let img = UIImageView()
        img.backgroundColor = .clear
        img.layer.cornerRadius = kFitWidth(8)
        img.clipsToBounds = true
        img.isUserInteractionEnabled = true
        img.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(imgOneTapAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var imgTwo: UIImageView = {
        let img = UIImageView()
        img.backgroundColor = .clear
        img.layer.cornerRadius = kFitWidth(8)
        img.clipsToBounds = true
        img.isUserInteractionEnabled = true
        img.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(imgTwoTapAction))
        img.addGestureRecognizer(tap)
        return img
    }()
    lazy var imgThree: UIImageView = {
        let img = UIImageView()
        img.backgroundColor = .clear
        img.layer.cornerRadius = kFitWidth(8)
        img.clipsToBounds = true
        img.isUserInteractionEnabled = true
        img.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(imgThreeTapAction))
        img.addGestureRecognizer(tap)
        return img
    }()
}

extension MallOrderAfterSaleSubmitMsgCell{
    func updateUI(type:String,
                  reason:String,
                  time:String,
                  imgs:[UIImage]?,
                  imgUrls:[String]?) {
        saleTypeLabel.text = type
        saleReasonLabel.text = reason
        saleTimeLabel.text = time
        
        if imgs?.count ?? 0 > 2{
            let img = imgs?[2]
            imgThree.image = img
            imgThree.isHidden = false
            self.viewModules.append(HeroBrowserLocalImageViewModule(image: img ?? UIImage()))
        }
        if imgs?.count ?? 0 > 1{
            let img = imgs?[1]
            imgTwo.image = img
            imgTwo.isHidden = false
            self.viewModules.append(HeroBrowserLocalImageViewModule(image: img ?? UIImage()))
        }
        if imgs?.count ?? 0 > 0{
            let img = imgs?[0]
            imgOne.image = img
            imgOne.isHidden = false
            self.viewModules.append(HeroBrowserLocalImageViewModule(image: img ?? UIImage()))
        }
    }
    @objc func imgOneTapAction() {
        guard let vc = UIApplication.topViewController() else { return }
        vc.hero.browserPhoto(viewModules: viewModules, initIndex: viewModules.count - 1) {
            [
                .pageControlType(.pageControl),
                .heroView(self.imgOne)
            ]
        }
    }
    @objc func imgTwoTapAction() {
        guard let vc = UIApplication.topViewController() else { return }
        vc.hero.browserPhoto(viewModules: viewModules, initIndex: viewModules.count - 2) {
            [
                .pageControlType(.pageControl),
                .heroView(self.imgTwo)
            ]
        }
    }
    @objc func imgThreeTapAction() {
        guard let vc = UIApplication.topViewController() else { return }
        vc.hero.browserPhoto(viewModules: viewModules, initIndex: 0) {
            [
                .pageControlType(.pageControl),
                .heroView(self.imgThree)
            ]
        }
    }
}

extension MallOrderAfterSaleSubmitMsgCell{
    func initUI() {
        contentView.backgroundColor = .COLOR_BG_F2
        contentView.addSubview(bgView)
        bgView.addSubview(saleTypeLab)
        bgView.addSubview(saleTypeLabel)
        bgView.addSubview(saleReasonLab)
        bgView.addSubview(saleReasonLabel)
        bgView.addSubview(saleTimeLab)
        bgView.addSubview(saleTimeLabel)
        bgView.addSubview(saleImgsLab)
        bgView.addSubview(imgOne)
        bgView.addSubview(imgTwo)
        bgView.addSubview(imgThree)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.top.equalToSuperview()
        }
        saleTypeLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(20))
            make.height.equalTo(kFitWidth(20))
        }
        saleTypeLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(saleTypeLab)
        }
        saleReasonLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(saleTypeLab.snp.bottom).offset(kFitWidth(10))
            make.height.equalTo(kFitWidth(20))
        }
        saleReasonLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.left.equalTo(kFitWidth(114))
            make.top.equalTo(kFitWidth(50))
            make.bottom.equalTo(kFitWidth(-110))
        }
        saleTimeLab.snp.makeConstraints { make in
            make.bottom.equalTo(kFitWidth(-80))
            make.left.equalTo(kFitWidth(16))
            make.height.equalTo(kFitWidth(20))
        }
        saleTimeLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(saleTimeLab)
        }
        saleImgsLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.height.equalTo(kFitWidth(20))
            make.bottom.equalTo(kFitWidth(-50))
        }
        imgOne.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(saleImgsLab)
            make.width.height.equalTo(kFitWidth(50))
        }
        imgTwo.snp.makeConstraints { make in
            make.right.equalTo(imgOne.snp.left).offset(kFitWidth(-12))
            make.width.height.top.equalTo(imgOne)
        }
        imgThree.snp.makeConstraints { make in
            make.right.equalTo(imgTwo.snp.left).offset(kFitWidth(-12))
            make.width.height.top.equalTo(imgOne)
        }
    }
}
