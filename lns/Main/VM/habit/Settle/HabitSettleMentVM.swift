//
//  HabitSettleMentVM.swift
//  lns
//  段位结算页面
//  Created by LNS2 on 2026/1/22.
//

class HabitSettleMentVM: UIView {
    
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
    lazy var tableView: UITableView = {
        let vi = UITableView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(100)), style: .plain)
        vi.backgroundColor = .clear//.COLOR_BG_F2
        vi.layer.borderWidth = kFitWidth(1)
        vi.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_10.cgColor
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.contentInsetAdjustmentBehavior = .never
        vi.estimatedRowHeight = 0
        vi.estimatedSectionHeaderHeight = 0
        vi.estimatedSectionFooterHeight = 0
        vi.sectionHeaderHeight = 0

        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        vi.register(HabitRankTableViewCell.classForCoder(), forCellReuseIdentifier: HabitRankTableViewCell.identifier)
        
        return vi
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
            guard !isAnimatingToHeadCup else { return }
           isAnimatingToHeadCup = true
           animateRankIconToHeadCup { [weak self] in
               guard let self else { return }
               self.isAnimatingToHeadCup = false
//               self.confirmButton.isUserInteractionEnabled = true
//               self.tapBlock?()
               
           }
        }
    }
    private func animateRankIconToHeadCup(completion: @escaping () -> Void) {
        guard let headCupVm,
              let targetImageView = headCupVm.currentTierBadgeView(),
              let sourceBadge = settleView.currentRankBadgeView(),
              let sourceImage = sourceBadge.image,
              let window = self.window else {
            completion()
            return
        }

        window.layoutIfNeeded()
        headCupVm.layoutIfNeeded()
        settleView.layoutIfNeeded()
        targetImageView.layoutIfNeeded()
        sourceBadge.layoutIfNeeded()

        let startFrame = sourceBadge.convert(sourceBadge.bounds, to: window)
        let endFrame = targetImageView.convert(targetImageView.bounds, to: window)
        let movingImageView = UIImageView(image: sourceImage)
        movingImageView.contentMode = .scaleAspectFit
        movingImageView.frame = startFrame
        window.addSubview(movingImageView)

        let targetAlpha = targetImageView.alpha
        targetImageView.alpha = 0
        sourceBadge.alpha = 0
        UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseInOut]) {
            movingImageView.frame = endFrame
            movingImageView.alpha = 0.9
            self.alpha = 0
        } completion: { _ in
            targetImageView.alpha = targetAlpha
            movingImageView.removeFromSuperview()
            completion()
        }
    }
}

extension HabitSettleMentVM{
    func updateUI(dict:NSDictionary) {
        
    }
    func updateCurrentTier(tier:Int,sn:Int,point:String,rankList:NSArray) {
        self.hasData = true
        self.currentRank = tier
        self.addSubview(settleView)
        self.displayedDataArray = rankList
        self.tableView.reloadData()
        
        let newIndex = self.indexOfCurrentUser(in: self.displayedDataArray)
        if newIndex ?? 0 > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: newIndex!, section: 0), at: .middle, animated: false)
        }
                
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
        addSubview(tableView)
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
        tableView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(28))
            make.right.equalTo(kFitWidth(-28))
            make.top.equalTo(pointLabel.snp.bottom).offset(kFitWidth(40))
            make.bottom.equalTo(confirmButton.snp.top).offset(kFitWidth(-20))
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
            self.resultLabel.transform = CGAffineTransform(translationX: 0, y: kFitWidth(15))
            self.pointLabel.transform = CGAffineTransform(translationX: 0, y: kFitWidth(20))
            self.resultLabel.alpha = 0
            self.pointLabel.alpha = 0
        }
        UIView.animate(withDuration: 0.55, delay: 0) {
            self.tableView.transform = CGAffineTransform(translationX: 0, y: kFitWidth(40))
            self.tableView.alpha = 0
        }
        UIView.animate(withDuration: 0.65, delay: 0,options: .curveEaseInOut) {
            self.settleView.transform = .identity
        }completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
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

extension HabitSettleMentVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedDataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                withIdentifier: HabitRankTableViewCell.identifier,
                for: indexPath
            ) as! HabitRankTableViewCell
        cell.isHidden = false        // ✅ 复位，避免复用导致隐藏
        cell.alpha = 1               // ✅ 保险一点
        cell.contentView.alpha = 1
        
        let dict = displayedDataArray[indexPath.row] as? NSDictionary ?? [:]
        
        cell.configure(
            rank: "\(indexPath.row + 1)",
            avatar: dict.stringValueForKey(key: "headimgurl"),
            name: dict.stringValueForKey(key: "nickname"),
            fireCount: dict.stringValueForKey(key: "donateCount").intValue,
            score: dict.stringValueForKey(key: "rankPointBalance"),
            isCurrentUser: isCurrentUser(dict)
        )
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(70)
    }
    private func indexOfCurrentUser(in leaderboard: NSArray) -> Int? {
        let uid = UserDefaults.standard.value(forKey: userId) as? String ?? ""
        guard !uid.isEmpty else { return nil }

        for (index, element) in leaderboard.enumerated() {
            guard let dict = element as? NSDictionary else { continue }
            let elementId = extractUserId(from: dict)
            if !elementId.isEmpty && elementId == uid {
                return index
            }
        }

        return nil
    }
    private func isCurrentUser(_ dict: NSDictionary) -> Bool {
        let uid = UserDefaults.standard.value(forKey: userId) as? String ?? ""
        guard !uid.isEmpty else { return false }
        let elementId = extractUserId(from: dict)
        return !elementId.isEmpty && elementId == uid
    }
    private func extractUserId(from dict: NSDictionary) -> String {
        if let uid = dict["uid"] as? String, !uid.isEmpty {
            return uid
        }
        if let uid = dict["userId"] as? String, !uid.isEmpty {
            return uid
        }
        if let uid = dict["user_id"] as? String, !uid.isEmpty {
            return uid
        }
        if let uid = dict["id"] as? String, !uid.isEmpty {
            return uid
        }

        return dict.stringValueForKey(key: "uid")
    }
}
