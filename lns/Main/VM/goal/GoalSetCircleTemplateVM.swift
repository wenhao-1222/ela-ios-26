//
//  GoalSetCircleTemplateVM.swift
//  lns
//
//  Created by Elavatine on 2024/10/22.
//


class GoalSetCircleTemplateVM: FeedBackView {
    
    let selfHeight = kFitWidth(56)
    
    var tapBlock:(()->())?
    var todayBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
//        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var todaySelectImgView: UIImageView = {
        let img = UIImageView()
        //circle_today_select_icon
        //circle_today_normal_icon
        img.setImgLocal(imgName: "circle_today_normal_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var todayLabel: UILabel = {
        let lab = UILabel()
        lab.text = "从本日开始"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    lazy var todayTapView: FeedBackView = {
        let vi = FeedBackView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(todayTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var tipsButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setImage(UIImage(named: "goal_circle_question"), for: .normal)
        btn.setTitle("碳循环模板", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT, for: .highlighted)
        btn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        
        return btn
    }()
}

extension GoalSetCircleTemplateVM{
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    @objc func todayTapAction() {
        todaySelectImgView.setImgLocal(imgName: "circle_today_select_icon")
        self.todayBlock?()
    }
}

extension GoalSetCircleTemplateVM{
    func initUI() {
        addSubview(todaySelectImgView)
        addSubview(todayLabel)
        addSubview(todayTapView)
        
        addSubview(tipsButton)
        
        setConstrait()
        tipsButton.imagePosition(style: .right, spacing: kFitWidth(3))
    }
    
    func setConstrait() {
        todaySelectImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(23))
            make.centerY.lessThanOrEqualToSuperview()
        }
        todayLabel.snp.makeConstraints { make in
            make.left.equalTo(todaySelectImgView.snp.right).offset(kFitWidth(3))
            make.centerY.lessThanOrEqualToSuperview()
        }
        todayTapView.snp.makeConstraints { make in
            make.left.top.height.equalToSuperview()
            make.right.equalTo(todayLabel).offset(kFitWidth(20))
        }
        tipsButton.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
    /// 控制“从本日开始”相关视图的显示隐藏
    func setTodayHidden(_ hidden: Bool) {
        todaySelectImgView.isHidden = hidden
        todayLabel.isHidden = hidden
        todayTapView.isHidden = hidden
    }
}
