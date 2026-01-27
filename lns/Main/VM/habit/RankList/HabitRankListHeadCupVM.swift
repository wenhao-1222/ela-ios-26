//
//  HabitRankListHeadCupVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/21.
//


class HabitRankListHeadCupVM: UIView {
    
    let selfHeight = kFitWidth(206) + kFitWidth(12)
    let scroviewHeight = kFitWidth(98)
    
    var pointTapBlock:(()->())?
    
    var timer: Timer?
    var remainSeconds = 3
    private var currentTierIndex: Int = 0
    private var rankTiers: [RankTierModel] = [RankTierModel]()
    private var currentTierImageView: UIImageView?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_F2
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var circleView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var degreeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var tipsBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(4.5)
        vi.layer.borderWidth = kFitWidth(1)
        vi.layer.borderColor = UIColor.white.cgColor
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var pointLabel: UILabel = {
        let lab = UILabel()
        lab.isUserInteractionEnabled = true
        return lab
    }()
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_rank_right_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var timeImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_rank_time_icon")
        
        return img
    }()
    lazy var timeCountLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "00:00:00"
        lab.alpha = 0
        return lab
    }()
    lazy var bottomWhiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: selfHeight-kFitWidth(12), width: SCREEN_WIDHT, height: kFitWidth(24)))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: 0, y: kFitWidth(83), width: SCREEN_WIDHT, height: scroviewHeight))
        scro.backgroundColor = .clear
        
        return scro
    }()
}

extension HabitRankListHeadCupVM{
    ///更新用户段位
    public func setCurrentTier(tier:Int,tierName:String) {
        self.currentTierIndex = tier
        self.degreeLabel.text = tierName
        self.rankTiers.removeAll()
        self.currentTierImageView = nil
        for vi in self.scrollView.subviews{
            vi.removeFromSuperview()
        }
        
        var imgOriginX = kFitWidth(20)
        var imgWidth = kFitWidth(55)
        var imgHeight = kFitWidth(70)
        let imgGap = kFitWidth(27)
        
        for i in 1...9{
            let model = RankTierModel().initModel(tier: i, tierName: "", currentTier: tier)
            self.rankTiers.append(model)
            
            let img = UIImageView()
            img.setImgLocal(imgName: model.tierImg)
            img.alpha = model.tierAlpha
            
            imgWidth = model.isCurrentTier ? kFitWidth(85.5) : kFitWidth(55)
            imgHeight = model.isCurrentTier ? kFitWidth(110) : kFitWidth(70)
            
            img.frame = CGRect.init(x: imgOriginX,
                                    y: scroviewHeight - imgHeight,
                                    width: imgWidth,
                                    height: imgHeight)
            scrollView.addSubview(img)
            imgOriginX += imgWidth + imgGap
            
            if model.isCurrentTier {
                currentTierImageView = img
            }
            
            
            if model.isCurrentTier && img.jf_centerX > SCREEN_WIDHT*0.5{
                scrollView.setContentOffset(CGPoint(x: img.jf_centerX - SCREEN_WIDHT*0.5, y: 0), animated: false)
            }
        }
        scrollView.contentSize = CGSize(width: imgOriginX, height: 0)
    }
    func currentTierBadgeView() -> UIImageView? {
        return currentTierImageView
    }
    func updateUI(champion:String,runnerUp:String,thirdPlace:String,secondsToWeekEnd:Int) {
//        degreeLabel.text = "青铜"

        let attr = NSMutableAttributedString(string: "周结算奖励：冠军 ", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
           .font:UIFont.systemFont(ofSize: 12, weight: .regular)])
        attr.append(NSAttributedString(string: "+\(champion)", attributes: [.foregroundColor:UIColor.THEME,
            .font:UIFont.systemFont(ofSize: 12, weight: .medium)]))
        attr.append(NSAttributedString(string: " 分｜亚军 ", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
          .font:UIFont.systemFont(ofSize: 12, weight: .regular)]))
        attr.append(NSAttributedString(string: "+\(runnerUp)", attributes: [.foregroundColor:UIColor.THEME,
             .font:UIFont.systemFont(ofSize: 12, weight: .medium)]))
        attr.append(NSAttributedString(string: " 分｜季军 ", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
              .font:UIFont.systemFont(ofSize: 12, weight: .regular)]))
        attr.append(NSAttributedString(string: "+\(thirdPlace)", attributes: [.foregroundColor:UIColor.THEME,
             .font:UIFont.systemFont(ofSize: 12, weight: .medium)]))
        attr.append(NSAttributedString(string: " 分", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
      .font:UIFont.systemFont(ofSize: 12, weight: .regular)]))
        pointLabel.attributedText = attr
//        pointLabel.setLineHeight(attr: attr ,lineHeight: kFitWidth(20))
        
        remainSeconds = secondsToWeekEnd
        if remainSeconds > 0 && timer == nil{
            countDownAction()
        }
    }
    private func updateRemainTimeLabel() {
        if remainSeconds <= 0 {
            timeCountLabel.text = "00:00:00"
//            remainTimeLabel.isHidden = true
            
            UIView.animate(withDuration: 0.25) {
                self.timeCountLabel.alpha = 0
            }
            self.timer?.invalidate()
            self.timer = nil
            return
        }
        
        let hours = remainSeconds / 3600
        let minutes = (remainSeconds % 3600) / 60
        let seconds = remainSeconds % 60
        if hours > 23 {
            let days = hours / 24
            timeCountLabel.text = "\(days)天"
        }else{
            timeCountLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        
        remainSeconds -= 1
        
        if self.timeCountLabel.alpha < 1{
            UIView.animate(withDuration: 0.5) {
                self.timeCountLabel.alpha = 1
            }
        }
    }
    func countDownAction() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.updateRemainTimeLabel()
        }
    }
    
    @objc func tapAction() {
        self.pointTapBlock?()
    }
}

extension HabitRankListHeadCupVM{
    func initUI() {
        addSubview(circleView)
        addSubview(degreeLabel)
        addSubview(tipsBgView)
        tipsBgView.addSubview(pointLabel)
        tipsBgView.addSubview(iconImgView)
        addSubview(timeImgView)
        addSubview(timeCountLabel)
        addSubview(bottomWhiteView)
        addSubview(scrollView)
        
        setConstrait()
    }
    func setConstrait() {
        circleView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(37))
            make.width.height.equalTo(kFitWidth(6))
        }
        degreeLabel.snp.makeConstraints { make in
            make.left.equalTo(circleView.snp.right).offset(kFitWidth(6))
            make.centerY.lessThanOrEqualTo(circleView)
        }
        tipsBgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.left.equalTo(kFitWidth(198))
            make.centerY.lessThanOrEqualTo(circleView)
            make.height.equalTo(kFitWidth(20))
        }
        iconImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-3))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(14))
        }
        pointLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(3))
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-20))
        }
        timeCountLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
//            make.centerY.lessThanOrEqualTo(degreeLabel)
            make.top.equalTo(tipsBgView.snp.bottom).offset(kFitWidth(22))
        }
        timeImgView.snp.makeConstraints { make in
            make.right.equalTo(timeCountLabel.snp.left).offset(kFitWidth(-2))
            make.centerY.lessThanOrEqualTo(timeCountLabel)
            make.width.height.equalTo(kFitWidth(15))
        }
        
    }
}
