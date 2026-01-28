//
//  HabitSettleVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/28.
//


class HabitSettleVM: UIView {
    
    var hasData = false
    var currentRank = 1
    var tapCount = 0
    var tapBlock:(()->())?
    weak var headCupVm: HabitRankListHeadCupVM?
    private var isAnimatingToHeadCup = false
    var displayedDataArray = NSArray()
    
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
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_settle_bg_img")
        img.contentMode = .scaleAspectFit
        
        return img
    }()
    lazy var imgs: [UIImage] = {
        var imgT = [UIImage]()
        
        for i in 1...9{
            imgT.append(UIImage(named: "rank_\(i)")!)
        }
        return imgT
    }()
    lazy var settleView: RankSettleView = {
        return RankSettleView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_WIDHT),
                                   rankImages: imgs,
                                   currentRank: self.currentRank)
    }()
    
    lazy var deskImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_settle_desk")
        img.contentMode = .scaleAspectFit
        
        return img
    }()
    lazy var cupShadowImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "habit_settle_cup_shadow")
        
        return img
    }()
}

extension HabitSettleVM{
    func initUI() {
        addSubview(bgImgView)
        addSubview(deskImgView)
        
        setConstrait()
    }
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        deskImgView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(SCREEN_WIDHT+WHUtils().getTopSafeAreaHeight())
        }
    }
}

extension HabitSettleVM{
    func updateCurrentTier(tier:Int,sn:Int,point:String,rankList:NSArray) {
        self.hasData = true
        self.currentRank = tier
        self.addSubview(settleView)
        self.displayedDataArray = rankList
//        self.tableView.reloadData()
        
//        let newIndex = self.indexOfCurrentUser(in: self.displayedDataArray)
//        if newIndex ?? 0 > 0 {
//            self.tableView.scrollToRow(at: IndexPath(row: newIndex!, section: 0), at: .middle, animated: false)
//        }
//                
//        settleView.transform = CGAffineTransform.identity
//            .scaledBy(x: 0.75, y: 0.75)
//            .translatedBy(x: 0, y: -kFitWidth(220))
//        
//        let attr = NSMutableAttributedString(string: "恭喜你进入榜单", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214,
//             .font:UIFont.systemFont(ofSize: 21, weight: .semibold)])
//        attr.append(NSAttributedString(string: " top \(sn)\n", attributes: [.foregroundColor:UIColor.THEME,
//             .font:UIFont.systemFont(ofSize: 21, weight: .regular)]))
//        attr.append(NSAttributedString(string: "将进入水晶杯", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214,
//             .font:UIFont.systemFont(ofSize: 21, weight: .semibold)]))
//        resultLabel.attributedText = attr
//        
//        let attrPoint = NSMutableAttributedString(string: "+\(point)", attributes: [.foregroundColor:UIColor.THEME,
//                                                                                    .font:UIFont().DDInFontBold(fontSize: 50)])
//        attrPoint.append(NSAttributedString(string: "积分", attributes: [.foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
//             .font:UIFont.systemFont(ofSize: 14, weight: .semibold)]))
//        pointLabel.attributedText = attrPoint
//        
//        setConstrait()
    }
}
