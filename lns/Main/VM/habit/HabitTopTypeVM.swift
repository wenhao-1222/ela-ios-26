//
//  HabitTopTypeVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/23.
//

class HabitTopTypeVM: UIView {
    
    let selfHeight = kFitWidth(41)
    let buttonWidth = kFitWidth(105)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var leftTitleBtn: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("进度", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .selected)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.isSelected = true
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        
        btn.addTarget(self, action: #selector(leftTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var rightTitleBtn: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("排行榜", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .selected)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(rightTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var bottomLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        
        return vi
    }()
}

extension HabitTopTypeVM{
    @objc func leftTapAction() {
        if leftTitleBtn.isSelected{
            return
        }
        leftTitleBtn.isSelected = true
        rightTitleBtn.isSelected = false
        
        leftTitleBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        rightTitleBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
            self.bottomLineView.center = CGPoint(x: SCREEN_WIDHT*0.5-kFitWidth(20)-self.buttonWidth*0.5, y: self.selfHeight-kFitWidth(2))
        }completion: { _ in
            self.isUserInteractionEnabled = true
        }
    }
    @objc func rightTapAction() {
        if rightTitleBtn.isSelected{
            return
        }
        rightTitleBtn.isSelected = true
        leftTitleBtn.isSelected = false
        
        rightTitleBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        leftTitleBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
            self.bottomLineView.center = CGPoint(x: SCREEN_WIDHT*0.5+kFitWidth(20)+self.buttonWidth*0.5, y: self.selfHeight-kFitWidth(2))
        }completion: { _ in
            self.isUserInteractionEnabled = true
        }
    }
}

extension HabitTopTypeVM{
    func initUI() {
        addSubview(leftTitleBtn)
        addSubview(rightTitleBtn)
        addSubview(bottomLineView)
        
        setConstrait()
    }
    func setConstrait() {
        leftTitleBtn.snp.makeConstraints { make in
            make.top.height.equalToSuperview()
            make.right.equalTo(-SCREEN_WIDHT*0.5-kFitWidth(20))
            make.width.equalTo(buttonWidth)
        }
        rightTitleBtn.snp.makeConstraints { make in
            make.top.height.equalToSuperview()
            make.width.equalTo(buttonWidth)
            make.left.equalTo(SCREEN_WIDHT*0.5+kFitWidth(20))
        }
        bottomLineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(leftTitleBtn)
            make.height.equalTo(kFitWidth(4))
            make.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(36))
        }
    }
}

