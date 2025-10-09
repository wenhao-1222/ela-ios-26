//
//  PublishPollHeadVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/18.
//


class PublishPollHeadVM: UIView {
    
    var selfHeight = kFitWidth(30)//kFitWidth(80)
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.text = "最多可选择"
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    lazy var numberButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        
        return btn
    }()
    lazy var unitLabel: UILabel = {
        let lab = UILabel()
        lab.text = "项"
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    lazy var tapView:UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
}

extension PublishPollHeadVM{
    func updateNumber(number:String) {
        
        numberButton.setTitle(number, for: .normal)
        numberButton.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        numberButton.imagePosition(style: .right, spacing: kFitWidth(3))
    }
    @objc func tapAction(){
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension PublishPollHeadVM{
    func initUI() {
        addSubview(unitLabel)
        addSubview(numberButton)
        addSubview(numberLabel)
        
        addSubview(tapView)
        
        setConstrait()
        updateNumber(number: "2")
//        numberButton.
    }
    func setConstrait()  {
        unitLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        numberButton.snp.makeConstraints { make in
            make.right.equalTo(unitLabel.snp.left).offset(kFitWidth(-4))
            make.centerY.lessThanOrEqualToSuperview()
        }
        numberLabel.snp.makeConstraints { make in
            make.right.equalTo(numberButton.snp.left).offset(kFitWidth(-6))
            make.centerY.lessThanOrEqualToSuperview()
        }
        tapView.snp.makeConstraints { make in
            make.right.top.height.equalToSuperview()
            make.left.equalTo(numberLabel)
        }
    }
}
