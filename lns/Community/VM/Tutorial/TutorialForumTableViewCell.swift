//
//  TutorialForumTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2024/11/8.
//


class TutorialForumTableViewCell: UITableViewCell {
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleToFill
//        img.setImgLocal(imgName: "forum_ tutorial_img")
        img.layer.cornerRadius = kFitWidth(8)
        img.clipsToBounds = true
        img.layer.borderWidth = kFitWidth(0.2)
        
        return img
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 20, weight: .bold)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.adjustsFontSizeToFitWidth = true
        lab.isHidden = true
        
        return lab
    }()
    lazy var detailLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.65)
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.adjustsFontSizeToFitWidth = true
        lab.isHidden = true
        return lab
    }()
    lazy var blurEffect: UIBlurEffect = {
        let vi = UIBlurEffect(style: .extraLight)
        return vi
    }()
    lazy var blurEffectView: UIVisualEffectView = {
        let vi = UIVisualEffectView(effect: blurEffect)
        vi.isHidden = true
        vi.alpha = 0.85
        return vi
    }()
    lazy var blurContentView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "E37318")
        vi.layer.cornerRadius = kFitWidth(4)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var visibleImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "tutorial_visible_icon")
        return img
    }()
    lazy var visibleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "敬请期待"
        lab.textColor = .white
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 10, weight: .medium)
        return lab
    }()
}

extension TutorialForumTableViewCell{
    func updateUI(dict:NSDictionary) {
//        blurEffectView.isHidden = true
        let materialDict = dict["material"]as? NSDictionary ?? [:]
        let imgArray = materialDict["image"]as? NSArray ?? []
        if imgArray.count > 0{
            let imgDict = imgArray[0]as? NSDictionary ?? [:]
            imgView.setImgUrl(urlString: imgDict.stringValueForKey(key: "ossUrl"))
        }
        titleLab.text = dict.stringValueForKey(key: "title")
        detailLabel.text = dict.stringValueForKey(key: "subtitle")
        
        if dict.stringValueForKey(key: "status") == "1"{
            blurEffectView.isHidden = false
            blurContentView.isHidden = false
            imgView.layer.borderColor = UIColor.clear.cgColor
        }else{
            blurEffectView.isHidden = true
            blurContentView.isHidden = true
            imgView.layer.borderColor = UIColor.COLOR_GRAY_BLACK_25.cgColor
        }
    }
}
extension TutorialForumTableViewCell{
    func initUI() {
        contentView.addSubview(imgView)
        imgView.addSubview(titleLab)
        imgView.addSubview(detailLabel)
        
        imgView.addSubview(blurEffectView)
        contentView.addSubview(blurContentView)
        blurContentView.addSubview(visibleImgView)
        blurContentView.addSubview(visibleLabel)
        
        setConstrait()
    }
    func setConstrait() {
        let imgHeight = (SCREEN_WIDHT-kFitWidth(21))*(kFitWidth(148)/kFitWidth(354))
        imgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(11))
            make.right.equalTo(kFitWidth(-10))
            make.top.equalTo(kFitWidth(12))
            make.bottom.equalToSuperview()
            make.height.equalTo(imgHeight)
//            make.height.equalTo(kFitWidth(148))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(52))
            make.right.equalTo(kFitWidth(-50))
        }
        detailLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(12))
        }
        blurEffectView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        blurContentView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
//            make.width.equalTo(kFitWidth(140))
            make.height.equalTo(kFitWidth(24))
        }
        visibleImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(8))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(12))
        }
        visibleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-8))
        }
    }
}
