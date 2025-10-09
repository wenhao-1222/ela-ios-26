//
//  SynMyFoodsVM.swift
//  lns
//  同步到食物
//  Created by Elavatine on 2025/3/10.
//   


class SynMyFoodsVM: UIView {
    
    let selfHeight = kFitHeight(54)
    
    var typeChangeBlock:((Int)->())?
    var tapIndex = 0
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "保存到我的食物"
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    lazy var switchButton: SwitchButton = {
        let btn = SwitchButton.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(16)-SwitchButton().selfWidth, y: (selfHeight-SwitchButton().selfHeight)*0.5, width: 0, height: 0))
        btn.tapBlock = {(status)in
            self.switchButton.setSelectStatus(status: status)
            UserDefaults.set(value: "\(status ? 1 : 0)", forKey: .aiFoodsSyn)
        }
        
        return btn
    }()
}

extension SynMyFoodsVM{
    func initUI() {
        addSubview(titleLab)
        addSubview(switchButton)
        
        switchButton.setSelectStatus(status: UserDefaults.getAISynFoods())
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}
