//
//  HabitSettleMentVM.swift
//  lns
//  段位结算页面
//  Created by LNS2 on 2026/1/22.
//

class HabitSettleMentVM: UIView {
    
    var currentRank = 1
    var tapCount = 0
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .COLOR_CARD_BG_WHITE//.clear
        self.isUserInteractionEnabled = true
//        self.isHidden = true
        self.alpha = 0
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgs: [UIImage] = {
        var imgT = [UIImage]()
        
        for i in 1...9{
            imgT.append(UIImage(named: "rank_\(i)")!)
        }
        return imgT
    }()
    lazy var settleView: RankSettleView = {
        return RankSettleView.init(frame: CGRect.init(x: 0, y: kFitWidth(180), width: SCREEN_WIDHT, height: kFitWidth(240)),
                                   rankImages: imgs,
                                   currentRank: self.currentRank)
    }()
    lazy var resultLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.numberOfLines = 0
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var pointLabel: UILabel = {
        let lab = UILabel()
        
        return lab
    }()
    
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(4)
        btn.clipsToBounds = true
        btn.setTitle("继续", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_WHITE, for: .normal)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        
        return btn
    }()
}

extension HabitSettleMentVM{
    @objc func tapAction() {
        confirmButton.isUserInteractionEnabled = false
        if tapCount == 0{
            tapCount = 1
            startAnimation()
        }else{
            
        }
    }
}

extension HabitSettleMentVM{
    func updateUI(dict:NSDictionary) {
        
    }
    func updateCurrentTier(tier:Int,sn:Int,point:String,rankList:NSArray) {
        self.currentRank = tier
        self.addSubview(settleView)
        settleView.transform = CGAffineTransform.identity
            .scaledBy(x: 0.75, y: 0.75)
            .translatedBy(x: 0, y: -kFitWidth(220))
        
        let attr = NSMutableAttributedString(string: "恭喜你进入榜单", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214,
             .font:UIFont.systemFont(ofSize: 21, weight: .semibold)])
        attr.append(NSAttributedString(string: " top \(sn)\n", attributes: [.foregroundColor:UIColor.THEME,
             .font:UIFont.systemFont(ofSize: 21, weight: .regular)]))
        attr.append(NSAttributedString(string: "将进入水晶杯", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214,
             .font:UIFont.systemFont(ofSize: 21, weight: .semibold)]))
        resultLabel.attributedText = attr
        
        let attrPoint = NSMutableAttributedString(string: "+\(point)", attributes: [.foregroundColor:UIColor.THEME,
                                                                                    .font:UIFont().DDInFontBold(fontSize: 50)])
        attrPoint.append(NSAttributedString(string: "积分", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
             .font:UIFont.systemFont(ofSize: 14, weight: .semibold)]))
        pointLabel.attributedText = attrPoint
        
        setConstrait()
    }
}

extension HabitSettleMentVM{
    func initUI() {
        addSubview(resultLabel)
        addSubview(pointLabel)
        addSubview(confirmButton)
    }
    func setConstrait() {
        resultLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(settleView.snp.bottom).offset(kFitWidth(-180))
        }
        pointLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(resultLabel.snp.bottom).offset(kFitWidth(40))
        }
        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }
    }
    func startAnimation() {
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.resultLabel.transform = CGAffineTransform(translationX: 0, y: kFitWidth(10))
            self.pointLabel.transform = CGAffineTransform(translationX: 0, y: kFitWidth(10))
            self.resultLabel.alpha = 0
            self.pointLabel.alpha = 0
        }
        UIView.animate(withDuration: 0.75, delay: 0) {
            self.settleView.transform = .identity
        }completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                //段位上升
                self.settleView.playRankUpAnimation()
                //段位下降
    //            settleView.playRankDownAnimation()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.confirmButton.isUserInteractionEnabled = true
            }
        }
    }
}
