//
//  MallOrderAfterSaleMsgCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/22.
//


class MallOrderAfterSaleMsgCell: UITableViewCell {
    
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
    lazy var statusLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 21, weight: .medium)
        
        return lab
    }()
    lazy var statusTimeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
    lazy var dottedLineView: DottedLineView = {
        let vi = DottedLineView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(92), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(1)))
        
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

extension MallOrderAfterSaleMsgCell{
    func updateUI(dict:NSDictionary) {
        statusTimeLabel.text = dict.stringValueForKey(key: "etime").replacingOccurrences(of: "T", with: " ")
        saleTypeLabel.text = dict.stringValueForKey(key: "afterSaleBizType") == "1" ? "退货退款" : "换货"
        saleReasonLabel.text = dict.stringValueForKey(key: "reason")
        saleTimeLabel.text = dict.stringValueForKey(key: "ctime").replacingOccurrences(of: "T", with: " ")
        
        let imgUrls = dict["image"]as? NSArray ?? []
        updateImgs(imgUrls: imgUrls as? [String])
        
        if dict.stringValueForKey(key: "afterSaleBizType") == "1"{
            if dict.stringValueForKey(key: "status") == "1"{
                statusLabel.text = "退货退款中"
            }else if dict.stringValueForKey(key: "status") == "3"{
                statusLabel.text = "不符合退/换货"
            }else{
                statusLabel.text = "退款退款完成"
            }
        }else{
            if dict.stringValueForKey(key: "status") == "1"{
                statusLabel.text = "换货中"
            }else if dict.stringValueForKey(key: "status") == "3"{
                statusLabel.text = "不符合退/换货"
            }else{
                statusLabel.text = "换货完成"
            }
        }
    }
    func updateImgs(imgUrls:[String]?) {
        if imgUrls?.count ?? 0 > 2 {
            let imgUrl = imgUrls?[2]
            imgThree.setImgUrl(urlString: imgUrl ?? "")
            imgThree.isHidden = false
            DSImageUploader().dealImgUrlSignForOss(urlStr: "\(imgUrl ?? "")") { signUrl in
                self.viewModules.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: signUrl, originImgUrl: signUrl))
            }
        }
        if imgUrls?.count  ?? 0 > 1 {
            let imgUrl = imgUrls?[1]
            imgTwo.setImgUrl(urlString: imgUrl ?? "")
            imgTwo.isHidden = false
            DSImageUploader().dealImgUrlSignForOss(urlStr: "\(imgUrl ?? "")") { signUrl in
                self.viewModules.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: signUrl, originImgUrl: signUrl))
            }
        }
        if imgUrls?.count ?? 0 > 0 {
            let imgUrl = imgUrls?[0]
            imgOne.setImgUrl(urlString: imgUrl ?? "")
            imgOne.isHidden = false
            DSImageUploader().dealImgUrlSignForOss(urlStr: "\(imgUrl ?? "")") { signUrl in
                self.viewModules.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: signUrl, originImgUrl: signUrl))
            }
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

extension MallOrderAfterSaleMsgCell{
    func initUI() {
        contentView.backgroundColor = .COLOR_BG_F2
        contentView.addSubview(bgView)
        bgView.addSubview(statusLabel)
        bgView.addSubview(statusTimeLabel)
        bgView.addSubview(dottedLineView)
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
            make.left.right.top.bottom.equalToSuperview()
//            make.bottom.equalTo(kFitWidth(-12))
        }
        statusLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(25))
        }
        statusTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(52))
            make.centerX.lessThanOrEqualToSuperview()
        }
        saleTypeLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(dottedLineView.snp.bottom).offset(kFitWidth(20))
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
            make.top.equalTo(kFitWidth(142))
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
