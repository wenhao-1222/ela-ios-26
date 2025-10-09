//
//  CourseOrderListTypeVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/22.
//


class CourseOrderListTypeVM: UIView {
    
    var selfHeight = kFitWidth(44)
    var tapIndex = 0
    
    var typeChangeBlock:((Int)->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        
        initUI()
        self.addShadow(opacity: 0.05)
    }
    lazy var topLineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        return vi
    }()
    lazy var statusAllButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("全部", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.tag = 4601
        
        btn.addTarget(self, action: #selector(buttonTapAction(btnSender:)), for: .touchUpInside)
        
        return btn
    }()
    lazy var statusNotPayButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("待支付", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        btn.tag = 4602
        
        btn.addTarget(self, action: #selector(buttonTapAction(btnSender:)), for: .touchUpInside)
        
        return btn
    }()
    lazy var statusPaidButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("已支付", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        btn.tag = 4603
        
        btn.addTarget(self, action: #selector(buttonTapAction(btnSender:)), for: .touchUpInside)
        
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

extension CourseOrderListTypeVM{
    @objc func buttonTapAction(btnSender:FeedBackButton)  {
        let btnTag = btnSender.tag - 4600
        if tapIndex == btnTag - 1{
            return
        }
        self.isUserInteractionEnabled = false
        tapIndex = btnTag - 1
        
        self.typeChangeBlock?(self.tapIndex)
        
        statusAllButton.isSelected = false
        statusNotPayButton.isSelected = false
        statusPaidButton.isSelected = false
        statusAllButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        statusNotPayButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        statusPaidButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        
        var bottomLineViewCenterX = kFitWidth(0)
        var bottomLineViewWidth = kFitWidth(0)
        if tapIndex == 0{
            statusAllButton.isSelected = true
            statusAllButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            bottomLineViewCenterX = kFitWidth(68)*0.5
            bottomLineViewWidth = kFitWidth(36)
        }else if tapIndex == 1{
            statusNotPayButton.isSelected = true
            statusNotPayButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            bottomLineViewCenterX = kFitWidth(68)*1.5
            bottomLineViewWidth = kFitWidth(48)
        }else if tapIndex == 2{
            statusPaidButton.isSelected = true
            statusPaidButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            bottomLineViewCenterX = kFitWidth(68)*2.5
            bottomLineViewWidth = kFitWidth(48)
        }
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
            self.bottomLineView.center = CGPoint(x: bottomLineViewCenterX, y: self.selfHeight-kFitWidth(2))
//            self.bottomLineView.frame = CGRect.init(x: bottomLineViewCenterX-bottomLineViewWidth*0.5, y: self.selfHeight-kFitWidth(4), width: bottomLineViewWidth, height: kFitWidth(4))
        }completion: { _ in
            self.isUserInteractionEnabled = true
        }
    }
}

extension CourseOrderListTypeVM{
    func initUI() {
        addSubview(statusAllButton)
        addSubview(statusNotPayButton)
        addSubview(statusPaidButton)
        addSubview(topLineView)
        addSubview(bottomLineView)
        
        setConstrait()
    }
    func setConstrait()  {
        statusAllButton.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(68))
        }
        statusNotPayButton.snp.makeConstraints { make in
            make.left.equalTo(statusAllButton.snp.right)
            make.top.width.bottom.equalTo(statusAllButton)
        }
        statusPaidButton.snp.makeConstraints { make in
            make.left.equalTo(statusNotPayButton.snp.right)
            make.top.width.bottom.equalTo(statusAllButton)
        }
        topLineView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
        bottomLineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(statusAllButton)
            make.height.equalTo(kFitWidth(4))
            make.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(36))
        }
    }
}
