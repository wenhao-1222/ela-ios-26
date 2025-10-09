//
//  FriendRankingListTypeVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/30.
//


class FriendRankingListTypeVM: UIView {
    
    let selfHeight = kFitWidth(45)
    
    var currentIndex = 0
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: kFitWidth(45)))
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
//        vi.alpha = 0
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var dailyButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("日榜", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .selected)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.titleLabel?.font = .MEDIUM_16
        btn.isSelected = true
        btn.addTarget(self, action: #selector(dailyTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var weeklyButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("周榜", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .selected)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.titleLabel?.font = .REGULAY_16
        btn.addTarget(self, action: #selector(weekTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var bottomLineView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(24), height: kFitWidth(4)))
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        vi.isHidden = true
        
        return vi
    }()
}


extension FriendRankingListTypeVM{
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
    func changeType(duration:Double=0.25) {
        if self.currentIndex == 0 {
            dailyButton.isSelected = true
            weeklyButton.isSelected = false
            UIView.animate(withDuration: duration, delay: 0) {
                self.bottomLineView.center = CGPoint.init(x: self.dailyButton.jf_centerX, y: self.selfHeight-kFitWidth(2))
            }
        }else{
            weeklyButton.isSelected = true
            dailyButton.isSelected = false
            UIView.animate(withDuration: duration, delay: 0) {
                self.bottomLineView.center = CGPoint.init(x: self.weeklyButton.jf_centerX, y: self.selfHeight-kFitWidth(2))
            }
        }
    }
}

extension FriendRankingListTypeVM{
    func initUI() {
        addSubview(bgView)
        addSubview(dailyButton)
        addSubview(weeklyButton)
        addSubview(bottomLineView)
        
        setConstrait()
        bgView.addShadow(opacity: 0.05,offset: CGSize.init(width: 0, height: 5))
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.top.left.width.bottom.equalToSuperview()
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
    }
}
