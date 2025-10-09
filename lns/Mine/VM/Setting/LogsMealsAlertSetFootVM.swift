//
//  LogsMealsAlertSetFootVM.swift
//  lns
//
//  Created by Elavatine on 2024/10/18.
//


class LogsMealsAlertSetFootVM: UIView {
    
    let selfHeight = kFitWidth(50)
    var mandatory = ""
    
    var switchBlock:((Bool)->())?
    required init?(coder: NSCoder) {
        fatalError("CancelAccountItemVM  required init?(coder: NSCoder)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var leftTitleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
    
    lazy var switchButton: SwitchButton = {
        let btn = SwitchButton.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(28)-SwitchButton().selfWidth, y: (selfHeight-SwitchButton().selfHeight)*0.5, width: 0, height: 0))
        btn.tapBlock = {(isSelect)in
            self.switchBtnAction()
        }
        return btn
    }()
}

extension LogsMealsAlertSetFootVM{
    func updateUI(mandatory:String) {
        if mandatory == "1"{
            switchButton.setSelectStatus(status: true)
            leftTitleLabel.text = "强制提醒（已开启：无论用餐与否，都提醒）"
        }else{
            switchButton.setSelectStatus(status: false)
            leftTitleLabel.text = "强制提醒（已关闭：若已用餐，则不提醒）"
        }
    }
    @objc func switchBtnAction() {
        if self.switchBlock != nil{
            self.switchBlock!(!self.switchButton.isSelect)
        }
//        self.switchButton.setSelectStatus(status: !self.switchButton.isSelect)
//        if self.switchButton.isSelect{
//            leftTitleLabel.text = "强制提醒（开启：无论用餐与否，都提醒）"
//        }else{
//            leftTitleLabel.text = "强制提醒（关闭：若已用餐，则不提醒）"
//        }
    }
}

extension LogsMealsAlertSetFootVM{
    func initUI() {
        addSubview(leftTitleLabel)
        addSubview(switchButton)
        
        setConstrait()
    }
    func setConstrait() {
        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(28))
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(switchButton.snp.left).offset(kFitWidth(-4))
        }
    }
}
