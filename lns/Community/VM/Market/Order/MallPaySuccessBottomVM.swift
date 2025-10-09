//
//  MallPaySuccessBottomVM.swift
//  lns
//
//  Created by Elavatine on 2025/9/18.
//



class MallPaySuccessBottomVM : UIView{
    
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
    lazy var payButton: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.setTitle("查看订单", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(payAction), for: .touchUpInside)
        
        return btn
    }()
}

extension MallPaySuccessBottomVM{
    @objc func payAction() {
        self.payBlocK?()
    }
}

extension MallPaySuccessBottomVM{
    func initUI() {
        addSubview(payButton)
        
        setConstrait()
    }
    func setConstrait() {
        payButton.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(11))
            make.right.equalTo(kFitWidth(-57))
            make.left.equalTo(kFitWidth(57))
            make.height.equalTo(kFitWidth(44))
        }
    }
}
