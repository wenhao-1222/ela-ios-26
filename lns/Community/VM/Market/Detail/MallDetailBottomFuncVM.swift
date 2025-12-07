//
//  MallDetailBottomFuncVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/4.
//


class MallDetailBottomFuncVM : UIView{
    
    var selfHeight = kFitWidth(55)+WHUtils().getBottomSafeAreaHeight()
    
    var detailModel = MallDetailModel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        if WHUtils().getBottomSafeAreaHeight() == 0 {
            selfHeight = kFitWidth(66)
        }
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-selfHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_CARD_BG_WHITE
        
        initUI()
    }
    lazy var serviceImgView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "mall_detail_service_icon")?.withTintColor(.COLOR_TEXT_TITLE_0f1214)
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var serviceLabel: UILabel = {
        let lab = UILabel()
        lab.text = "客服"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 10, weight: .regular)
        
        return lab
    }()
    lazy var serviceTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        return vi
    }()
    lazy var buyButton: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(70), y: kFitWidth(11), width: SCREEN_WIDHT-kFitWidth(86), height: kFitWidth(44))
        
        btn.enablePressEffect()
//        btn.backgroundColor = .THEME
        btn.setTitle("立即购买", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.titleLabel?.numberOfLines = 2
        btn.titleLabel?.lineBreakMode = .byWordWrapping
        btn.titleLabel?.textAlignment = .center
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.alpha = 0
        
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        
//        btn.addTarget(self, action: #selector(buyAction), for: .touchUpInside)
        
        return btn
    }()
}

extension MallDetailBottomFuncVM{
    func updateButtonStatus() {
        buyButton.setTitle(self.detailModel.buyButtonText, for: .normal)
        buyButton.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        switch self.detailModel.buyButtonStatus{
        case .sale_pre_no_stoke :
            buyButton.isEnabled = false
        case .sale_pre:
            let attr = NSMutableAttributedString(string: detailModel.buyButtonText)
            let timeAttr = NSMutableAttributedString(string: "\n \(detailModel.deliveryNotice)")
            attr.yy_font = .systemFont(ofSize: 16, weight: .regular)
            timeAttr.yy_font = .systemFont(ofSize: 12, weight: .regular)
            attr.append(timeAttr)
            buyButton.setAttributedTitle(attr, for: .normal)
//            buyButton.titleLabel?.attributedText = attr
//            buyButton.setTitle("\(detailModel.buyButtonText) \n \(detailModel.deliveryNotice)", for: .normal)
        case .sale_remind, .sale_normal,.sale_no_stoke:
            break
        case .sale_no_stoke_subscribe,.sale_remind_subscribe:
            buyButton.setBackgroundImage(createImageWithColor(color: .COLOR_GRAY_C4C4C4), for: .normal)
        }
        UIView.animate(withDuration: 0.15, animations: {
            self.buyButton.alpha = 1
        })
    }
}

extension MallDetailBottomFuncVM{
    func initUI() {
        addSubview(serviceImgView)
        addSubview(serviceLabel)
        addSubview(serviceTapView)
        addSubview(buyButton)
        
        setConstrait()
    }
    func setConstrait() {
        serviceImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(22))
            make.top.equalTo(kFitWidth(13.5))
            make.width.height.equalTo(kFitWidth(25))
        }
        serviceLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(serviceImgView)
            make.top.equalTo(serviceImgView.snp.bottom).offset(kFitWidth(2))
        }
        serviceTapView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.right.equalTo(buyButton)
            make.bottom.equalTo(serviceLabel).offset(kFitWidth(10))
        }
    }
}
