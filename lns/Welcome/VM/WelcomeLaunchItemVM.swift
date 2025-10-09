//
//  WelcomeLaunchItemVM.swift
//  lns
//
//  Created by Elavatine on 2024/10/25.
//



class WelcomeLaunchItemVM: UIView {
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "launch_welcome_img_1")
        
        return img
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "欢迎来到 Elavatine"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 26, weight: .medium)
        
        return lab
    }()
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
//        lab.text = "这是由营养师和运动员共同打造的\n专业饮食记录工具"
        
        
        return lab
    }()
    lazy var startBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("开始吧", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = kFitWidth(24)
        btn.isHidden = true
        btn.clipsToBounds = true
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .highlighted)
        return btn
    }()
}

extension WelcomeLaunchItemVM{
    func setContentString(textString:String) {
        contentLabel.setLineSpace(lineSpcae: kFitWidth(4), textString: textString)
        contentLabel.textAlignment = .center
    }
}
extension WelcomeLaunchItemVM{
    func initUI() {
        addSubview(iconImgView)
        addSubview(titleLabel)
        addSubview(contentLabel)
        addSubview(startBtn)
        
        setConstrait()
        
        setContentString(textString: "这是由营养师和运动员共同打造的\n专业饮食记录系统")
    }
    func setConstrait() {
        iconImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight()+kFitWidth(68))
            make.width.height.equalTo(kFitWidth(280))
            make.height.equalTo(kFitWidth(200))
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(iconImgView.snp.bottom).offset(kFitWidth(32))
        }
        contentLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(16))
        }
        startBtn.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(-24)-WHUtils().getBottomSafeAreaHeight())
            make.width.equalTo(kFitWidth(148))
            make.height.equalTo(kFitWidth(48))
        }
    }
}
