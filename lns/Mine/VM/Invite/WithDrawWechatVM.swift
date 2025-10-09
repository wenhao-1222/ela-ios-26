//
//  WithDrawWechatVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/21.
//

import Foundation

class WithDrawWechatVM: UIView {
    
    let selfHeight = kFitWidth(56)
    var tapBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    lazy var wechatImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "login_wechat_icon")
        return img
    }()
    lazy var wechatLab: UILabel = {
        let lab = UILabel()
        lab.text = "提现至微信"
        lab.textColor = WHColor_16(colorStr: "222222")
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        return lab
    }()
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.setImgUrl(urlString: UserInfoModel.shared.wxHeadImgUrl)
        img.layer.cornerRadius = kFitWidth(12)
        img.clipsToBounds = true
        
        return img
    }()
    lazy var nickNameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "去关联"
        
        return lab
    }()
    lazy var arrowImgView : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.setImgLocal(imgName: "mine_func_arrow")
        
        return img
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        return vi
    }()
}

extension WithDrawWechatVM{
    func updateUI() {
        if UserInfoModel.shared.isBindWeChat {
            headImgView.isHidden = false
            nickNameLabel.text = UserInfoModel.shared.wxNickName
            
            headImgView.snp.remakeConstraints { make in
                make.right.equalTo(-UserInfoModel.shared.wxNickName.mc_getWidth(font: .systemFont(ofSize: 14, weight: .regular), height: kFitWidth(56)) + kFitWidth(-45))
                make.width.height.equalTo(kFitWidth(24))
                make.centerY.lessThanOrEqualToSuperview()
            }
            arrowImgView.isHidden = true
            self.isUserInteractionEnabled = false
        }else{
            headImgView.isHidden = true
            let str = "去关联"
            nickNameLabel.text = str
            
            headImgView.snp.remakeConstraints { make in
                make.right.equalTo(-str.mc_getWidth(font: .systemFont(ofSize: 14, weight: .regular), height: kFitWidth(56)) + kFitWidth(-45))
                make.width.height.equalTo(kFitWidth(24))
                make.centerY.lessThanOrEqualToSuperview()
            }
        }
    }
//    func refresUI(dict:NSDictionary) {
//        headImgView.setImgUrl(urlString: dict.stringValueForKey(key: "headimgurl"))
//        nickNameLabel.text = dict.stringValueForKey(key: "nickname")
//        
//        headImgView.snp.remakeConstraints { make in
//            make.right.equalTo(-dict.stringValueForKey(key: "nickname").mc_getWidth(font: .systemFont(ofSize: 14, weight: .regular), height: kFitWidth(56)) + kFitWidth(-45))
//            make.width.height.equalTo(kFitWidth(24))
//            make.centerY.lessThanOrEqualToSuperview()
//        }
//    }
}
extension WithDrawWechatVM{
    func initUI() {
        addSubview(wechatImgView)
        addSubview(wechatLab)
        addSubview(arrowImgView)
        addSubview(nickNameLabel)
        addSubview(headImgView)
        addSubview(lineView)
        
        setConstrait()
        
        updateUI()
    }
    func setConstrait() {
        headImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
        wechatImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
        wechatLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(48))
            make.centerY.lessThanOrEqualToSuperview()
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(16))
        }
        nickNameLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-38))
            make.centerY.lessThanOrEqualToSuperview()
        }
        headImgView.snp.makeConstraints { make in
            make.right.equalTo(nickNameLabel.snp.left).offset(kFitWidth(-3))
            make.width.height.equalTo(kFitWidth(24))
            make.centerY.lessThanOrEqualToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(1))
        }
    }
}

extension WithDrawWechatVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = .white
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = .white
    }

   @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
       self.backgroundColor = .white
    }
}
