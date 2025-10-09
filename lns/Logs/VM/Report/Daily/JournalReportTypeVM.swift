//
//  JournalReportTypeVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/9.
//


class JournalReportTypeVM: UIView {
    
    let selfHeight = kFitWidth(44)
    
    var currentIndex = 0
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        
        initUI()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            if self.currentIndex == 0 {
                self.dailyTapAction()
                self.bottomLineView.center = CGPoint.init(x: self.dailyButton.jf_centerX, y: self.selfHeight-kFitWidth(2))
            }else{
                self.weekTapAction()
                self.bottomLineView.center = CGPoint.init(x: self.weeklyButton.jf_centerX, y: self.selfHeight-kFitWidth(2))
            }
            self.bottomLineView.isHidden = false
        })
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.alpha = 0
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var dailyButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("日", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .selected)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.titleLabel?.font = .MEDIUM_16
        btn.isSelected = true
        btn.addTarget(self, action: #selector(dailyTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var weeklyButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("周", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .selected)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.titleLabel?.font = .REGULAY_16
        btn.addTarget(self, action: #selector(weekTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var bottomLineView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(36), height: kFitWidth(4)))
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        vi.isHidden = true
        
        return vi
    }()
}

extension JournalReportTypeVM{
    @objc func dailyTapAction() {
        if currentIndex == 0 {
            return
        }
        currentIndex = 0
        self.changeType()
        self.tapBlock?()
    }
    @objc func weekTapAction() {
        if currentIndex == 1 {
            return
        }
        currentIndex = 1
        self.changeType()
        self.tapBlock?()
    }
    func changeBgAlpha(offsetY:CGFloat) {
        if offsetY > 0 {
            let percent = offsetY/selfHeight
            self.bgView.alpha = percent
        }else{
            self.bgView.alpha = 0
        }
    }
    func changeType() {
        if self.currentIndex == 0 {
            EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW,
                                                scenarioType: .report_daily,
                                                text: "")
            dailyButton.isSelected = true
            weeklyButton.isSelected = false
            UIView.animate(withDuration: 0.25, delay: 0) {
                self.bottomLineView.center = CGPoint.init(x: self.dailyButton.jf_centerX, y: self.selfHeight-kFitWidth(2))
            }
//            bottomLineView.snp.remakeConstraints { make in
//                make.centerX.lessThanOrEqualTo(dailyButton)
//                make.bottom.equalToSuperview()
//                make.width.equalTo(kFitWidth(36))
//                make.height.equalTo(kFitWidth(4))
//            }
        }else{
            EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW,
                                                scenarioType: .report_weekly,
                                                text: "")
            weeklyButton.isSelected = true
            dailyButton.isSelected = false
            UIView.animate(withDuration: 0.25, delay: 0) {
                self.bottomLineView.center = CGPoint.init(x: self.weeklyButton.jf_centerX, y: self.selfHeight-kFitWidth(2))
            }
//            bottomLineView.snp.remakeConstraints { make in
//                make.centerX.lessThanOrEqualTo(weeklyButton)
//                make.bottom.equalToSuperview()
//                make.width.equalTo(kFitWidth(36))
//                make.height.equalTo(kFitWidth(4))
//            }
        }
    }
}

extension JournalReportTypeVM{
    func initUI() {
        addSubview(bgView)
        addSubview(dailyButton)
        addSubview(weeklyButton)
        addSubview(bottomLineView)
        
        setConstrait()
//        bgView.addShadow()
//        bgView.addShadow(opacity: 0.2,offset: CGSize.init(width: 0, height: 5))
        bgView.addShadow(opacity: 0.05,offset: CGSize.init(width: 0, height: 5))
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.top.left.width.bottom.equalToSuperview()
//            make.top.equalTo(kFitWidth(20))
        }
        dailyButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(75))
            make.right.equalTo(-SCREEN_WIDHT*0.5 - kFitWidth(7))
            make.top.bottom.equalToSuperview()
        }
        weeklyButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-75))
            make.top.width.height.equalTo(dailyButton)
        }
//        bottomLineView.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualTo(dailyButton)
//            make.bottom.equalToSuperview()
//            make.width.equalTo(kFitWidth(36))
//            make.height.equalTo(kFitWidth(4))
//        }
    }
}
