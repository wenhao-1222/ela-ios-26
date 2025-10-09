//
//  GoalOtherSetTypeVM.swift
//  lns
//  智能生成目标、碳循环/欺骗日
//  Created by Elavatine on 2025/6/3.
//


class GoalOtherSetTypeVM: UIView {
    
    let selfHeight = kFitWidth(77)
    var dataDict = NSDictionary()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
//        self.layer.cornerRadius = kFitWidth(12)
//        self.clipsToBounds = true
        
        initUI()
//        self.addShadow()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var zhiNengButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("智能生成目标", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT, for: .highlighted)
        btn.setImage(UIImage(named: "goal_zhineng_icon"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        
        return btn
    }()
    lazy var circleButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("碳循环/欺骗日", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT, for: .highlighted)
        btn.setImage(UIImage(named: "goal_circle_icon"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
        
        return vi
    }()
}

extension GoalOtherSetTypeVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(zhiNengButton)
        whiteView.addSubview(circleButton)
        whiteView.addSubview(lineView)
     
        setConstrait()
        zhiNengButton.imagePosition(style: .top, spacing: kFitWidth(4))
        circleButton.imagePosition(style: .top, spacing: kFitWidth(4))
    }
    func setConstrait() {
        let btnWidth = (SCREEN_WIDHT-kFitWidth(32))*0.5
        whiteView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
//            make.top.bottom.equalToSuperview()
//            make.right.equalTo(kFitWidth(-16))
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo((SCREEN_WIDHT-kFitWidth(32)))
            make.height.equalTo(selfHeight)
        }
        zhiNengButton.snp.makeConstraints { make in
            make.left.bottom.top.equalToSuperview()
            make.width.equalTo(btnWidth)
        }
        circleButton.snp.makeConstraints { make in
            make.right.bottom.top.equalToSuperview()
            make.width.equalTo(btnWidth)
        }
        lineView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(55))
            make.width.equalTo(kFitWidth(0.5))
        }
        
    }
}
