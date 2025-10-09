//
//  JournalShareMsgNameVM.swift
//  lns
//
//  Created by Elavatine on 2025/4/30.
//


class JournalShareMsgNameVM: UIView {
    
    var selfHeight = kFitWidth(29)+kFitWidth(46)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: frame.size.width, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(23)
        img.clipsToBounds = true
        
        
        return img
    }()
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 15, weight: .semibold)
        
        return lab
    }()
    lazy var descriptLabel: UILabel = {
        let lab = UILabel()
        lab.text = "给你分享了一个饮食日志"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        
        return lab
    }()
    lazy var circleTagLabel: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .THEME
        lab.layer.cornerRadius = kFitWidth(4)
        lab.clipsToBounds = true
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 11, weight: .semibold)
        lab.textAlignment = .center
        lab.isHidden = true
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var winnerBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var winnerIconImg: UIImageView = {
        let img = UIImageView()
        
        return img
    }()
    lazy var winnerDayLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_BG_WHITE
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
}

extension JournalShareMsgNameVM{
    func updateUI() {
        self.nameLabel.text = UserInfoModel.shared.nickname
        self.headImgView.setImgUrl(urlString: UserInfoModel.shared.headimgurl)
        
        let dict = UserInfoModel.shared.streakDict
        if dict.stringValueForKey(key: "protection_period") == "0"{
            winnerIconImg.setImgLocal(imgName: "streak_icon_\(dict.doubleValueForKey(key: "level") - 1)")
//            winnerDayLabel.textColor = .COLOR_TEXT_TITLE_0f1214//.COLOR_BG_WHITE//WHColor_16(colorStr: "FF9500")
        }else{
            winnerIconImg.setImgLocal(imgName: "streak_icon_gray_\(dict.doubleValueForKey(key: "level") - 1)")
//            winnerDayLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50//WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.45)
        }
        winnerDayLabel.text = dict.stringValueForKey(key: "streak")
        
        if dict.doubleValueForKey(key: "level") < 2 || dict.doubleValueForKey(key: "streak") == 0{
            self.winnerBgView.isHidden = true
        }else{
            self.winnerBgView.isHidden = false
        }
    }
    func updateCircleTag(dict:NSDictionary) {
        if dict.stringValueForKey(key: "carbLabel").count > 0 {
            circleTagLabel.isHidden = false
            winnerBgView.isHidden = true
            circleTagLabel.text = "\(dict.stringValueForKey(key: "carbLabel"))日"
        }else if dict.stringValueForKey(key: "circleTag").count > 0 {
            circleTagLabel.isHidden = false
            winnerBgView.isHidden = true
            circleTagLabel.text = "\(dict.stringValueForKey(key: "circleTag"))日"
        }
    }
}

extension JournalShareMsgNameVM{
    func initUI() {
        addSubview(headImgView)
        addSubview(nameLabel)
        addSubview(descriptLabel)
        addSubview(winnerBgView)
        addSubview(circleTagLabel)
        winnerBgView.addSubview(winnerIconImg)
        winnerBgView.addSubview(winnerDayLabel)
        
        setConstrait()
        
        updateUI()
    }
    func setConstrait() {
        headImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(29))
            make.width.equalTo(kFitWidth(46))
            make.height.equalTo(kFitWidth(46))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(72))
            make.top.equalTo(headImgView).offset(kFitWidth(5))
            make.right.equalTo(kFitWidth(-60))
        }
        descriptLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(72))
            make.bottom.equalTo(kFitWidth(-6))
        }
        circleTagLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(43))
            make.width.equalTo(kFitWidth(41))
            make.height.equalTo(kFitWidth(16))
        }
        winnerBgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(43))
            make.height.equalTo(kFitWidth(16))
        }
        winnerDayLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-4))
//            make.top.equalTo(kFitWidth(1))
            make.centerY.lessThanOrEqualToSuperview().offset(kFitWidth(-0.5))
            make.left.equalTo(kFitWidth(15))
        }
        winnerIconImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(2))
            make.width.height.equalTo(kFitWidth(13))
//            make.centerY.lessThanOrEqualToSuperview()
            make.centerY.lessThanOrEqualToSuperview().offset(kFitWidth(-0.5))
        }
    }
}
