//
//  AITipsAlertHeadImgVM.swift
//  lns
//
//  Created by Elavatine on 2025/3/6.
//


class AITipsAlertHeadImgVM: UIView {
    
    let selfHeight = kFitWidth(364)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var rightIconImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ai_tips_alert_right_icon")
        return img
    }()
    lazy var rightLabel: UILabel = {
        let lab = UILabel()
        lab.text = "正确"
        lab.textColor = .black
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        
        return lab
    }()
    lazy var rightImgBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F4F5F7")
        vi.layer.cornerRadius = kFitWidth(20)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var rightContentImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ai_tips_alert_right_img")
        return img
    }()
    
    lazy var errorIconImg: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ai_tips_alert_error_icon")
        return img
    }()
    lazy var errorLabel: UILabel = {
        let lab = UILabel()
        lab.text = "错误"
        lab.textColor = .black
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        
        return lab
    }()
    lazy var errorImgBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F4F5F7")
        vi.layer.cornerRadius = kFitWidth(20)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var errorContentImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ai_tips_alert_error_img")
        return img
    }()
}

extension AITipsAlertHeadImgVM{
    func initUI() {
        addSubview(rightIconImg)
        addSubview(rightLabel)
        addSubview(rightImgBgView)
        rightImgBgView.addSubview(rightContentImgView)
        
        addSubview(errorIconImg)
        addSubview(errorLabel)
        addSubview(errorImgBgView)
        errorImgBgView.addSubview(errorContentImgView)
        
        setConstrait()
    }
    func setConstrait() {
        rightIconImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(70))
            make.top.equalTo(kFitWidth(11))
            make.width.height.equalTo(kFitWidth(30))
        }
        rightLabel.snp.makeConstraints { make in
            make.left.equalTo(rightIconImg.snp.right).offset(kFitWidth(5))
            make.centerY.lessThanOrEqualTo(rightIconImg)
        }
        rightImgBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(25))
            make.top.equalTo(kFitWidth(50))
            make.width.equalTo(kFitWidth(157))
            make.height.equalTo(kFitWidth(296))
        }
        rightContentImgView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(127))
            make.height.equalTo(kFitWidth(265))
        }
        if isIpad(){
            errorIconImg.snp.makeConstraints { make in
                make.left.equalTo(kFitWidth(288))
                make.centerY.lessThanOrEqualTo(rightIconImg)
                make.width.height.equalTo(rightIconImg)
            }
            errorImgBgView.snp.makeConstraints { make in
    //            make.right.equalTo(kFitWidth(-25))
                make.centerX.lessThanOrEqualTo(errorIconImg)
                make.centerY.lessThanOrEqualTo(rightImgBgView)
                make.width.height.equalTo(rightImgBgView)
            }
        }else{
            errorIconImg.snp.makeConstraints { make in
                make.left.equalTo(kFitWidth(238))
                make.centerY.lessThanOrEqualTo(rightIconImg)
                make.width.height.equalTo(rightIconImg)
            }
            errorImgBgView.snp.makeConstraints { make in
                make.right.equalTo(kFitWidth(-25))
//                make.centerX.lessThanOrEqualTo(errorIconImg)
                make.centerY.lessThanOrEqualTo(rightImgBgView)
                make.width.height.equalTo(rightImgBgView)
            }
        }
        
        errorLabel.snp.makeConstraints { make in
            make.left.equalTo(errorIconImg.snp.right).offset(kFitWidth(5))
            make.centerY.lessThanOrEqualTo(errorIconImg)
        }
        errorContentImgView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.height.equalTo(rightContentImgView)
        }
    }
}
