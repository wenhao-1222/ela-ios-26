//
//  CoursePayOrderPayBottomVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/17.
//


class CoursePayOrderPayBottomVM : UIView{
    
    var selfHeight = kFitWidth(55)
    
    var payBlocK:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        selfHeight = WHUtils().getBottomSafeAreaHeight() > 0 ? (WHUtils().getBottomSafeAreaHeight()+kFitWidth(55)) : kFitWidth(66)
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-selfHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var titleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.text = "实付金额（元）"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 11, weight: .semibold)
        
        return lab
    }()
    lazy var payMoneyLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
//        lab.text = "¥ 220.00"
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 18, weight: .semibold)
        
        return lab
    }()
    lazy var discountMoneyLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.layer.borderWidth = kFitWidth(1)
        lab.layer.borderColor = UIColor.THEME.cgColor
        lab.layer.cornerRadius = kFitWidth(4)
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 11, weight: .medium)
        lab.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        lab.textAlignment = .center
        lab.isHidden = true
        lab.customLineHeight = kFitWidth(20)
        
        return lab
    }()
    lazy var payButton: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.setTitle("立即支付", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(payAction), for: .touchUpInside)
        
        return btn
    }()
}

extension CoursePayOrderPayBottomVM{
    @objc func payAction() {
        self.payBlocK?()
    }
    func updateMoney(money:String) {
        payMoneyLabel.text = "¥ \(WHUtils.convertStringToString("\(money)") ?? "")"
        discountMoneyLabel.isHidden = true
    }
    /*
     discountAmount=8:
     payAmount =2:
     totalAmount =10;
     */
    func updateDiscountMonet(dict:NSDictionary) {
        discountMoneyLabel.isHidden = false
        discountMoneyLabel.textInsets = UIEdgeInsets(top: kFitWidth(6), left: kFitWidth(6), bottom: kFitWidth(6), right: kFitWidth(6))
        payMoneyLabel.text = "¥ \(WHUtils.convertStringToString("\(dict.doubleValueForKey(key: "payAmount"))") ?? "")"
        discountMoneyLabel.text = "已优惠¥\(WHUtils.convertStringToString("\(dict.doubleValueForKey(key: "discountAmount"))") ?? "")  "
    }
}

extension CoursePayOrderPayBottomVM{
    func initUI() {
        addSubview(titleLab)
        addSubview(payMoneyLabel)
        addSubview(discountMoneyLabel)
        addSubview(payButton)
        
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(11))
            
        }
        payMoneyLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(28))
        }
        discountMoneyLabel.snp.makeConstraints { make in
            make.left.equalTo(payMoneyLabel.snp.right).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualTo(payMoneyLabel)
            make.height.equalTo(kFitWidth(20))
        }
        payButton.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(11))
            make.right.equalTo(kFitWidth(-16))
            make.width.equalTo(kFitWidth(145))
            make.height.equalTo(kFitWidth(44))
        }
    }
}
