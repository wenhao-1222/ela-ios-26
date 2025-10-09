//
//  ForumNaviVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/4.
//


class ForumNaviVM : UIView{
    
    let selfHeight = WHUtils().getNavigationBarHeight()
    
    var shareBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        initUI()
    }
    lazy var backArrowButton: NaviBackButton = {
        let btn = NaviBackButton.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: kFitWidth(44), height: kFitWidth(44)))
        
        return btn
    }()
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = true
        img.layer.cornerRadius = kFitWidth(18)
        
        return img
    }()
    
    lazy var authorLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .bold)
        
        return lab
    }()
    lazy var verifyImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "forum_user_verify_icon")
        
        return img
    }()
    lazy var timeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        return lab
    }()
    lazy var shareButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "forum_share_black_icon"), for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME, for: .highlighted)
        
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT, for: .highlighted)
        
        btn.addTarget(self, action: #selector(shareTapAction), for: .touchUpInside)
        
        return btn
    }()
}

extension ForumNaviVM{
    func updateUI(model:ForumModel) {
        headImgView.setImgUrl(urlString: model.headImgUrl)
        authorLabel.text = model.createBy
        verifyImgView.isHidden = !(model.keyUser == .pass)
//        timeLabel.text = model.showTime
        
    }
    @objc func shareTapAction() {
        if self.shareBlock != nil{
            self.shareBlock!()
        }
    }
}
extension ForumNaviVM{
    func initUI() {
        addSubview(backArrowButton)
        addSubview(headImgView)
        addSubview(authorLabel)
        addSubview(verifyImgView)
        addSubview(timeLabel)
        addSubview(shareButton)
        
        setConstrait()
    }
    func setConstrait() {
        backArrowButton.snp.makeConstraints { make in
            make.width.height.equalTo(kFitWidth(44))
            make.top.equalTo(statusBarHeight)
            make.left.equalTo(kFitWidth(2))
        }
        headImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(48))
            make.centerY.lessThanOrEqualTo(backArrowButton)
            make.width.height.equalTo(kFitWidth(36))
        }
        authorLabel.snp.makeConstraints { make in
            make.left.equalTo(headImgView.snp.right).offset(kFitWidth(8))
//            make.top.equalTo(headImgView)
            make.centerY.lessThanOrEqualTo(headImgView)
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(authorLabel)
            make.bottom.equalTo(headImgView)
        }
        verifyImgView.snp.makeConstraints { make in
            make.left.equalTo(authorLabel.snp.right).offset(kFitWidth(3))
            make.centerY.lessThanOrEqualTo(authorLabel)
            make.width.height.equalTo(kFitWidth(16))
        }
        shareButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-12))
            make.width.height.equalTo(kFitWidth(24))
            make.centerY.lessThanOrEqualTo(backArrowButton)
        }
    }
}
