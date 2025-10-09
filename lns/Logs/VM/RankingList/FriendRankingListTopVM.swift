//
//  FriendRankingListTopVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/30.
//


class FriendRankingListTopVM: UIView {
    
    var friendTapBlock:(()->())?
    var backTapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: kFitWidth(200)))
        self.backgroundColor = .THEME
        self.isUserInteractionEnabled = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "friend_top_bg_img")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var huizhangImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "friend_list_img")
        return img
    }()
    lazy var backImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "navi_back_white_icon")
        
        return img
    }()
    lazy var backTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(backTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var addFriendButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("添加好友", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(13.5)
        btn.clipsToBounds = true
        btn.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.2)
        
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(friendTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var newFriendMsgRedIcon: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "FE2C21")
        vi.layer.cornerRadius = kFitWidth(4.5)
        vi.clipsToBounds = true

        return vi
    }()
    lazy var friendTextLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.text = "好友榜"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 28, weight: .semibold)
        
        return lab
    }()
}

extension FriendRankingListTopVM{
    @objc func friendTapAction() {
        self.friendTapBlock?()
    }
    @objc func backTapAction() {
        self.backTapBlock?()
    }
}
extension FriendRankingListTopVM{
    func initUI() {
        addSubview(bgImgView)
        addSubview(backImgView)
        addSubview(backTapView)
        bgImgView.addSubview(huizhangImgView)
        bgImgView.addSubview(addFriendButton)
        bgImgView.addSubview(newFriendMsgRedIcon)
        bgImgView.addSubview(friendTextLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        huizhangImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-35))
            make.bottom.equalTo(kFitWidth(-11))
            make.width.height.equalTo(kFitWidth(102))
        }
        backImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12.5))
            make.top.equalTo(statusBarHeight+kFitWidth(7))
            make.width.height.equalTo(kFitWidth(30))
        }
        backTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(backImgView)
            make.width.height.equalTo(kFitWidth(54))
        }
        addFriendButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(backImgView)
            make.right.equalTo(kFitWidth(-15))
            make.width.equalTo(kFitWidth(80))
            make.height.equalTo(kFitWidth(27))
        }
        newFriendMsgRedIcon.snp.makeConstraints { make in
            make.right.equalTo(addFriendButton).offset(kFitWidth(-2))
            make.width.height.equalTo(kFitWidth(9))
            make.top.equalTo(addFriendButton).offset(kFitWidth(-3.5))
        }
        friendTextLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(21))
            make.bottom.equalTo(kFitWidth(-48))
        }
    }
}
