//
//  AILimitationTipsAlertVm.swift
//  lns
//
//  Created by Elavatine on 2025/3/19.
//



class AILimitationTipsAlertVm: UIView {
    
    var selfHeight = kFitWidth(0)
    let highLightColor = WHColor_RGB(r: 245, g: 35, b: 85)
    let highLightFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .COLOR_GRAY_BLACK_85
        self.isUserInteractionEnabled = true
        self.selfHeight = SCREEN_HEIGHT-frame.origin.y
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "AI识别限制说明"
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
//        lab.adjustsFontSizeToFitWidth = true
        lab.lineBreakMode = .byWordWrapping
        
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_GRAY_BLACK_85
        return lab
    }()
    lazy var contentLabel2: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
//        lab.adjustsFontSizeToFitWidth = true
        lab.lineBreakMode = .byWordWrapping
        
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_GRAY_BLACK_85
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        
        return vi
    }()
    lazy var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("我知道了", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        
        return btn
    }()
}

extension AILimitationTipsAlertVm{
    func showView() {
        self.isHidden = false
        whiteView.alpha = 0
        self.alpha = 0
        self.setNeedsLayout() // 标记需要更新布局
        self.layoutIfNeeded() // 立即计算布局
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 1
        }
        UIView.animate(withDuration: 0.4, delay: 0.1,options: .curveLinear) {
            self.alpha = 1
        }
    }
    
    @objc func hiddenView() {
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveLinear) {
            self.alpha = 0
        }
        UIView.animate(withDuration: 0.3, delay: 0.2,options: .curveLinear) {
            self.whiteView.alpha = 0
        }completion: { c in
            self.isHidden = true
        }
    }
    
    @objc func nothingToDo() {
        
    }
    func refreshContentFont() {
        let attrCircleFirst = NSMutableAttributedString(string: "·")
//        attrCircleFirst.yy_setBaselineOffset(-2, range: NSRange(location: 0, length: 1))
        attrCircleFirst.yy_font = .systemFont(ofSize: 16, weight: .heavy)
        attrCircleFirst.yy_color = .THEME
        let attr = NSMutableAttributedString(string: "估重\n")
        attr.yy_font = highLightFont
        let attr1 = NSMutableAttributedString(string: "AI 通过图片学习识别各种食物，并匹配相应的营养成分。但在识别过程中，AI 无法准确估算或测量重量。只有配合")
        let attr2 = NSMutableAttributedString(string: "LiDAR（激光雷达）技术")
        attr2.yy_font = highLightFont
        let attr3 = NSMutableAttributedString(string: " 时，才能（相对）准确地估算体积和重量。\n")
        
        let attrCircleSecond = NSMutableAttributedString(string: "·")
//        attrCircleSecond.yy_setBaselineOffset(-2, range: NSRange(location: 0, length: 1))
        attrCircleSecond.yy_font = .systemFont(ofSize: 16, weight: .bold)
        attrCircleSecond.yy_color = .THEME
        let attr4 = NSMutableAttributedString(string: "成分\n")
        attr4.yy_font = highLightFont
        let attr5 = NSMutableAttributedString(string: "外观相同的食物（例如：")
        let attr6 = NSMutableAttributedString(string: "番茄炒蛋")
        attr6.yy_font = highLightFont
        let attr7 = NSMutableAttributedString(string: "，一碗可能")
        let attr8 = NSMutableAttributedString(string: "额外加入了 3 勺糖和大量油")
        attr8.yy_font = highLightFont
        let attr9 = NSMutableAttributedString(string: "，而另一碗则未添加任何调料。尽管两者外观相似，其")
        let attr10 = NSMutableAttributedString(string: "热量差距可能高达多倍")
        attr10.yy_font = highLightFont
        let attr11 = NSMutableAttributedString(string: "。此外，")
        let attr12 = NSMutableAttributedString(string: "拍摄角度和遮挡因素")
        attr12.yy_font = highLightFont
        let attr13 = NSMutableAttributedString(string: "（如番茄炒蛋下方覆盖了一层米饭）")
        let attr14 = NSMutableAttributedString(string: "也可能影响AI识别的准确性。")
        
        attrCircleFirst.append(attr)
        attrCircleFirst.append(attr1)
        attrCircleFirst.append(attr2)
        attrCircleFirst.append(attr3)
        
        attrCircleSecond.append(attr4)
        attrCircleSecond.append(attr5)
        attrCircleSecond.append(attr6)
        attrCircleSecond.append(attr7)
        attrCircleSecond.append(attr8)
        attrCircleSecond.append(attr9)
        attrCircleSecond.append(attr10)
        attrCircleSecond.append(attr11)
        attrCircleSecond.append(attr12)
        attrCircleSecond.append(attr13)
        attrCircleSecond.append(attr14)
        
        attrCircleFirst.append(attrCircleSecond)
//        contentLabel.attributedText = attrCircleFirst
//        contentLabel.sizeToFit()
        
        contentLabel.attributedText = attrCircleFirst
        contentLabel.preferredMaxLayoutWidth = kFitWidth(320) - kFitWidth(40) // 添加此行
        contentLabel.sizeToFit()
//        contentLabel2.attributedText = attrCircleSecond
    }
}

extension AILimitationTipsAlertVm{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(contentLabel)
//        whiteView.addSubview(contentLabel2)
        whiteView.addSubview(lineView)
        whiteView.addSubview(confirmBtn)
        
        refreshContentFont()
        setConstrait()
        
    }
    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(320))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(24))
            make.height.equalTo(kFitWidth(18))
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
//            make.top.equalTo(kFitWidth(50))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(20)) // 修改此处
//            make.height.equalTo(kFitWidth(200))
//            make.bottom.equalTo(kFitWidth(-68))
        }
//        contentLabel2.snp.makeConstraints { make in
//            make.left.right.equalTo(contentLabel)
//            make.top.equalTo(contentLabel.snp.bottom)//.offset(kFitWidth(20))
//        }
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(contentLabel.snp.bottom).offset(kFitWidth(20))
            make.height.equalTo(1)
        }
//        confirmBtn.snp.makeConstraints { make in
//            make.left.right.bottom.equalToSuperview()
//            make.height.equalTo(kFitWidth(48))
//            make.top.equalTo(lineView.snp.bottom)
//        }
        confirmBtn.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(lineView.snp.bottom) // 直接贴在 lineView 下方
            make.height.equalTo(48) // 可选，确保按钮高度固定
        }
    }
}
