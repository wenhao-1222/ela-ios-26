//
//  DietPlanCreateSexVM.swift
//  lns
//
//  Created by LNS2 on 2026/2/25.
//



class DietPlanCreateSexVM: UIView {
    
    var manTapBlock:(()->())?
    var femanTapBlock:(()->())?
    var showTipsBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.text = "你的性别是？"
        
        return lab
    }()
    lazy var tipsButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("荷尔蒙：无法被忽略的变量", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(showTipsAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var sexManButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05//WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        btn.layer.cornerRadius = kFitWidth(40)
        btn.clipsToBounds = true
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT), for: .highlighted)
        btn.addTarget(self, action: #selector(manTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var sexManIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "sex_icon_man_normal")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var sexManLabel : UILabel = {
        let lab = UILabel()
        lab.text = "男"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50//WHColor_16(colorStr: "595959")
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        
        return lab
    }()
    lazy var sexFeManButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.backgroundColor = .COLOR_BG_BLACK_04//WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        btn.layer.cornerRadius = kFitWidth(40)
        btn.clipsToBounds = true
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT), for: .highlighted)
        
        btn.addTarget(self, action: #selector(femanTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var sexFeManIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "sex_icon_feman_normal")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var sexFeManLabel : UILabel = {
        let lab = UILabel()
        lab.text = "女"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50//WHColor_16(colorStr: "595959")
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        
        return lab
    }()
}

extension DietPlanCreateSexVM{
    @objc func manTapAction(){
        if QuestinonaireMsgModel.shared.sex == "2"{
            QuestinonaireMsgModel.shared.clearMsg()
        }
        QuestinonaireMsgModel.shared.sex = "1"
        
        sexManButton.backgroundColor = .THEME
        sexManIcon.setImgLocal(imgName: "sex_icon_man")//sex_icon_man_normal
        sexManLabel.textColor = .COLOR_TEXT_WHITE
        
        sexFeManButton.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05//WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        sexFeManIcon.setImgLocal(imgName: "sex_icon_feman_normal")//sex_icon_feman_normal
        sexFeManLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50//WHColor_16(colorStr: "595959")
        
        if self.manTapBlock != nil{
            self.manTapBlock!()
        }
    }
    @objc func femanTapAction(){
        if QuestinonaireMsgModel.shared.sex == "1"{
            QuestinonaireMsgModel.shared.clearMsg()
        }
        QuestinonaireMsgModel.shared.sex = "2"
        
        sexManButton.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05//WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        sexManIcon.setImgLocal(imgName: "sex_icon_man_normal")//
        sexManLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50//WHColor_16(colorStr: "595959")
        
        sexFeManButton.backgroundColor = UIColor(named: "color_sex_femal")!//WHColor_16(colorStr: "FE5A7D")
        sexFeManIcon.setImgLocal(imgName: "sex_icon_feman")//sex_icon_feman_normal
        sexFeManLabel.textColor = .COLOR_TEXT_WHITE
        
        if self.femanTapBlock != nil{
            self.femanTapBlock!()
        }
    }
    @objc func showTipsAction(){
        self.showTipsBlock?()
    }
}

extension DietPlanCreateSexVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(tipsButton)
        addSubview(sexManButton)
        sexManButton.addSubview(sexManIcon)
        sexManButton.addSubview(sexManLabel)
        addSubview(sexFeManButton)
        sexFeManButton.addSubview(sexFeManIcon)
        sexFeManButton.addSubview(sexFeManLabel)
        
        setConstrait()
    }
    
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(kFitWidth(36))
            make.top.equalTo(WHUtils().getNavigationBarHeight()+kFitWidth(59))
        }
        tipsButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(12))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(200))
            make.height.equalTo(kFitWidth(21))
        }
        sexManButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(kFitWidth(232))
            make.top.equalTo(tipsButton.snp.bottom).offset(kFitWidth(158))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(80))
        }
        sexManIcon.snp.makeConstraints { make in
            make.left.equalTo((SCREEN_WIDHT-kFitWidth(32))*0.5-kFitWidth(26))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
        sexManLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(177))
            make.left.equalTo(sexManIcon.snp.right).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualToSuperview()
        }
        sexFeManButton.snp.makeConstraints { make in
            make.width.height.equalTo(sexManButton)
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(sexManButton.snp.bottom).offset(kFitWidth(12))
        }
        sexFeManIcon.snp.makeConstraints { make in
            make.left.equalTo((SCREEN_WIDHT-kFitWidth(32))*0.5-kFitWidth(26))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
        sexFeManLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(177))
            make.left.equalTo(sexFeManIcon.snp.right).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}

//
//extension DietPlanCreateSexVM{
//    func initUI() {
//        addSubview(titleLabel)
//        addSubview(sexManButton)
//        sexManButton.addSubview(sexManIcon)
//        sexManButton.addSubview(sexManLabel)
//        addSubview(sexFeManButton)
//        sexFeManButton.addSubview(sexFeManIcon)
//        sexFeManButton.addSubview(sexFeManLabel)
//    
//        setConstrait()
//    }
//    
//    func setConstrait() {
//        titleLabel.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(WHUtils().getNavigationBarHeight()+kFitWidth(76))
//        }
//        sexManButton.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
////            make.top.equalTo(kFitWidth(232))
//            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(127))
//            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
//            make.height.equalTo(kFitWidth(80))
//        }
//        sexManIcon.snp.makeConstraints { make in
//            make.left.equalTo((SCREEN_WIDHT-kFitWidth(32))*0.5-kFitWidth(26))
//            make.centerY.lessThanOrEqualToSuperview()
//            make.width.height.equalTo(kFitWidth(24))
//        }
//        sexManLabel.snp.makeConstraints { make in
////            make.left.equalTo(kFitWidth(177))
//            make.left.equalTo(sexManIcon.snp.right).offset(kFitWidth(8))
//            make.centerY.lessThanOrEqualToSuperview()
//        }
//        sexFeManButton.snp.makeConstraints { make in
//            make.width.height.equalTo(sexManButton)
//            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(sexManButton.snp.bottom).offset(kFitWidth(12))
//        }
//        sexFeManIcon.snp.makeConstraints { make in
//            make.left.equalTo((SCREEN_WIDHT-kFitWidth(32))*0.5-kFitWidth(26))
//            make.centerY.lessThanOrEqualToSuperview()
//            make.width.height.equalTo(kFitWidth(24))
//        }
//        sexFeManLabel.snp.makeConstraints { make in
////            make.left.equalTo(kFitWidth(177))
//            make.left.equalTo(sexFeManIcon.snp.right).offset(kFitWidth(8))
//            make.centerY.lessThanOrEqualToSuperview()
//        }
//    }
//}
