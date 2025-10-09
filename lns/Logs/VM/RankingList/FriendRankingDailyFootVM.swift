//
//  FriendRankingDailyFootVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/3.
//


class FriendRankingDailyFootVM: UIView {
    
    var selfHeight = kFitWidth(170)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.text = "166 名成人随机对照试验"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 13, weight: .medium)
        return lab
    }()
    lazy var contentLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var tipsLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.text = "来源：Wing RR, Jeffery RW. J Consult Clin Psychol 1999;67(1):132-138."
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
}

extension FriendRankingDailyFootVM{
    func updateSkeleton(isLoading:Bool) {
        if isLoading{
            titleLabel.text = ""
            contentLabel.text = ""
            tipsLabel.text = ""
            // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            titleLabel.showSkeleton(cfg)
            contentLabel.showSkeleton(cfg)
            tipsLabel.showSkeleton(cfg)
        }else{
            titleLabel.text = "166 名成人随机对照试验"
            tipsLabel.text = "来源：Wing RR, Jeffery RW. J Consult Clin Psychol 1999;67(1):132-138."
            initAttr()
            // 3) 最后统一把骨架优雅淡出 + 内容淡入
            [titleLabel, tipsLabel, contentLabel].forEach { $0.hideSkeletonWithCrossfade() }
        }
    }
}
extension FriendRankingDailyFootVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(contentLabel)
        addSubview(tipsLabel)
        
        initAttr()
        setConstrait()
        
        updateSkeleton(isLoading: true)
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(16))
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(43.5))
            make.right.equalTo(kFitWidth(-16))
        }
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(contentLabel.snp.bottom).offset(kFitWidth(16))
        }
    }
    func initAttr() {
        let attr = NSMutableAttributedString(string: "与 3 位好友一起记录饮食时，记录坚持率 ")
        let atr1 = NSMutableAttributedString(string: "95 % ")
        let atr2 = NSMutableAttributedString(string: "(对照 76%)")
        let atr3 = NSMutableAttributedString(string: "，体重维持成功率高达 ")
        let atr4 = NSMutableAttributedString(string: "66 % ")
        let atr5 = NSMutableAttributedString(string: "(对照 24%) ")
        let atr6 = NSMutableAttributedString(string: "—提升近 3 倍！ \n快去添加好友吧！")
        
        atr1.yy_color = .THEME
        atr2.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        atr4.yy_color = .THEME
        atr5.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        
        attr.append(atr1)
        attr.append(atr2)
        attr.append(atr3)
        attr.append(atr4)
        attr.append(atr5)
        attr.append(atr6)
        
        contentLabel.attributedText = attr
    }
}
