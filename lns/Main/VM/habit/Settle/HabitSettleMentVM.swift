//
//  HabitSettleMentVM.swift
//  lns
//  段位结算页面
//  Created by LNS2 on 2026/1/22.
//

class HabitSettleMentVM: UIView {
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .COLOR_CARD_BG_WHITE//.clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HabitSettleMentVM{
    func initUI() {
        var imgs = [UIImage]()
        
        for i in 1...9{
            imgs.append(UIImage(named: "rank_\(i)")!)
        }
        
        let settleView = RankSettleView.init(frame: CGRect.init(x: 0, y: kFitWidth(180), width: SCREEN_WIDHT, height: kFitWidth(240)),
                                             rankImages: imgs,
                                             currentRank: 7)
        
//        let settleView = RankSettleView.init(frame: self.bounds,
//                                             rankImages: imgs,
//                                             currentRank: 7)
        self.addSubview(settleView)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            //段位上升
            settleView.playRankUpAnimation()
            //段位下降
//            settleView.playRankDownAnimation()
        }
    }
}
