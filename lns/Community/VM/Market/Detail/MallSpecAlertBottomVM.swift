//
//  MallSpecAlertBottomVM.swift
//  lns
//
//  Created by Elavatine on 2025/9/11.
//


class MallSpecAlertBottomVM : UIView{
    
    var selfHeight = kFitWidth(140)+WHUtils().getBottomSafeAreaHeight()
    
    var number = 1
    
    var numChangeBlock:((Bool)->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        
        initUI()
    }
    lazy var numLab: UILabel = {
        let lab = UILabel()
        lab.text = "购买数量"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var numSubButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "mall_order_num_sub_icon"), for: .normal)
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(subNumAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.text = "\(number)"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .center
        return lab
    }()
    lazy var numAddButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "mall_order_num_add_icon"), for: .normal)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(addNumAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F2
        return vi
    }()
    lazy var buyButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("继续", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .THEME
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        
        btn.enablePressEffect()
        
        return btn
    }()
}

extension MallSpecAlertBottomVM{
    @objc func subNumAction() {
        self.numChangeBlock?(false)
    }
    @objc func addNumAction() {
        self.numChangeBlock?(true)
    }
    func updateNumber(num:Int) {
        self.number = num
        self.numberLabel.text = "\(self.number)"
    }
}

extension MallSpecAlertBottomVM{
    func initUI() {
        addSubview(numLab)
        addSubview(numAddButton)
        addSubview(numberLabel)
        addSubview(numSubButton)
        addSubview(lineView)
        addSubview(buyButton)
        
        setConstrait()
    }
    func setConstrait() {
        numLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(32))
            make.height.equalTo(kFitWidth(23))
        }
        numAddButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.centerY.lessThanOrEqualTo(numLab)
            make.width.height.equalTo(kFitWidth(23))
        }
        numberLabel.snp.makeConstraints { make in
            make.right.equalTo(numAddButton.snp.left)
            make.width.equalTo(kFitWidth(40))
            make.centerY.lessThanOrEqualTo(numLab)
        }
        numSubButton.snp.makeConstraints { make in
            make.right.equalTo(numberLabel.snp.left)
            make.width.height.equalTo(numAddButton)
            make.centerY.lessThanOrEqualTo(numLab)
        }
        let bottomGap = WHUtils().getBottomSafeAreaHeight() > 0 ? 0 : kFitWidth(10)
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(55)-bottomGap)
        }
        buyButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(57))
            make.right.equalTo(kFitWidth(-57))
            make.top.equalTo(lineView.snp.bottom).offset(kFitWidth(11))
            make.height.equalTo(kFitWidth(44))
        }
    }
}
