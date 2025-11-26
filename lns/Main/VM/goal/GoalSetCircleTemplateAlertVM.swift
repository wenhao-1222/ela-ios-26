//
//  GoalSetCircleTemplateAlertVM.swift
//  lns
//
//  Created by Elavatine on 2024/10/22.
//


class GoalSetCircleTemplateAlertVM: UIView {
    
    var controller = WHBaseViewVC()
    var whiteViewHeight = kFitWidth(378)+WHUtils().getBottomSafeAreaHeight()
    var whiteViewOriginY = kFitWidth(0)
    
    var cirType = ""
    var confirmBlock:((String)->())?
    /// 蒙层目标透明度：浅色 0.15，深色 0.85
    private var targetDimAlpha: CGFloat {
        return traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.15
    }
    // 主题变更时（例如从浅色切到深色）同步调整蒙层透明度
   override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
       super.traitCollectionDidChange(previousTraitCollection)
       if #available(iOS 13.0, *),
          previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle,
          !isHidden {
           UIView.animate(withDuration: 0.2) {
               self.bgView.alpha = self.targetDimAlpha
           }
       }
   }
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0)
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        initUI()
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = .COLOR_ALERT_BG_BLACK//WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenView))
        v.addGestureRecognizer(tap)
        return v
    }()
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.clipsToBounds = true
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        vi.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(12))
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var closeButton : GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        
        return btn
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.text = "碳循环“高-中-低”"
        return lab
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_06//WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
        return vi
    }()
    
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_60
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    
    lazy var nextBtn : UIButton = {
        let btn = UIButton()
//        btn.frame = CGRect.init(x: kFitWidth(16), y: self.centerVm.frame.maxY + kFitWidth(40), width: kFitWidth(288), height: kFitWidth(48))
        btn.setTitle("使用模板", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME, for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .disabled)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.layer.cornerRadius = kFitWidth(4)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        
        return btn
    }()
}

extension GoalSetCircleTemplateAlertVM{
    @objc func showSelf() {
        self.isHidden = false
        bgView.isUserInteractionEnabled = false
        bgView.alpha = 0
        
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight
        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5-kFitWidth(2))
            self.bgView.alpha = self.targetDimAlpha//0.25
        }completion: { t in
            self.bgView.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.15, delay: 0,options: .curveEaseInOut) {
                self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
            }
        }
    }
    @objc func hiddenView() {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
            self.bgView.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
    }
    @objc func nothingAction() {
        
    }
    @objc func confirmAction() {
        if self.confirmBlock != nil{
            self.confirmBlock!(self.cirType)
        }
        hiddenView()
    }
}

extension GoalSetCircleTemplateAlertVM{
    //circleType :
//    1   高-中-低  碳循环
    // 2 低-低-低-高 碳循环
    func updateContent(circleType:String) {
        self.cirType = circleType
        if circleType == "1"{
            let attr = NSMutableAttributedString(string: "碳水安排：\n高：45%\n中：30%\n低：20%\n\n")
            let attr1 = NSMutableAttributedString(string: "优点：更好安排训练，碳水摄入波动相对较小，执行难度低。\n\n缺点：如果训练强度不够或饮食执行不够严格，在低碳日之后，糖原可能尚未完全消耗完，这样进入高碳日时可能会影响效果。")
            attr.append(attr1)
            
            contentLabel.attributedText = attr
            titleLabel.text = "碳循环“高-中-低”"
        }else if circleType == "2"{
            let attr = NSMutableAttributedString(string: "碳水安排：\n低：20%\n高：55%\n\n")
            let attr1 = NSMutableAttributedString(string: "优点：计划简单，只有高碳日和低碳日，容易备餐。\n\n缺点：高碳日如果摄入太高，可能会导致三天的低碳日无法消耗完糖源。")
            
            attr.append(attr1)
            
            contentLabel.attributedText = attr
            titleLabel.text = "碳循环“低-低-低-高”"
        }
    }
}

extension GoalSetCircleTemplateAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(closeButton)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(lineView)
        whiteView.addSubview(contentLabel)
        whiteView.addSubview(nextBtn)
        
//        updateContent(circleType: "1")
        
        setConstrait()
    }
    func setConstrait() {
        closeButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.bottom.equalTo(lineView)
            make.width.equalTo(kFitWidth(56))
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(44))
        }
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(44))
            make.height.equalTo(kFitWidth(1))
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(lineView.snp.bottom).offset(kFitWidth(16))
        }
        nextBtn.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(20))
        }
    }
}
