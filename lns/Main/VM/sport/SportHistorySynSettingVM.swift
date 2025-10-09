//
//  SportHistorySynSettingVM.swift
//  lns
//  健康APP  数据同步后开关 
//  Created by Elavatine on 2024/12/16.
//


class SportHistorySynSettingVM: UIView {
    
    let selfHeight = kFitWidth(44)
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var detailLabel: UILabel = {
        let lab = UILabel()
        lab.text = "运动消耗是否计入营养目标？"
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var settinBtn: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("去设置", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        
        return btn
    }()
}

extension SportHistorySynSettingVM{
    func initUI(){
        addSubview(detailLabel)
        addSubview(settinBtn)
        
        setConstrait()
    }
    func setConstrait(){
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-60))
        }
        settinBtn.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-12))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(50))
        }
    }
}
