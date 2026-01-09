//
//  HabitRankListVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/30.
//


class HabitRankListVM: UIView {
    
    var selfHeight = kFitWidth(600)
    var controller = WHBaseViewVC()
    
    var dataSourceArray = NSArray()
    private var displayedDataArray = NSArray()
    
    var promotionLine = -1
    var relegationLine = -1
    
//    private let leaderboardCacheKey = "HabitRankListVM.leaderboardCache"
    private var isCurrentlyVisible = false
    
    //段位变化动画  需要
    private var currentTierIndex: Int = 0
    private var unlockedTierIndex: Int = 0
    private let rankTiers: [RankTier] = RankTier.defaultNine()
    private var isAnimatingToDemo: Bool = false
    private var isAnimatingBackFromDemo: Bool = false
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        initUI()
        loadCachedLeaderboard()
        sendDataRequestForHeadMsg()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        headVm.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: headVm.selfHeight)

        tableView.frame = CGRect(
            x: 0,
            y: headVm.frame.maxY,
            width: SCREEN_WIDHT,
            height: selfHeight - headVm.frame.maxY
        )
    }

    lazy var tableView: UITableView = {
//        let vi = UITableView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight), style: .plain)
        let vi = UITableView(frame: CGRect.init(x: 0, y: self.headVm.frame.maxY, width: SCREEN_WIDHT, height: selfHeight-self.headVm.selfHeight), style: .grouped)
        vi.backgroundColor = .COLOR_CARD_BG_WHITE//.COLOR_BG_F2
//        vi.tableHeaderView = headVm
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.clipsToBounds = true
        vi.contentInsetAdjustmentBehavior = .never
        vi.estimatedRowHeight = 0
        vi.estimatedSectionHeaderHeight = 0
        vi.estimatedSectionFooterHeight = 0

        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        vi.register(HabitRankTableViewCell.classForCoder(), forCellReuseIdentifier: HabitRankTableViewCell.identifier)
        
        return vi
    }()
    lazy var emptyVm: HabitRankListEmptyVM = {
        let vm = HabitRankListEmptyVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight-self.headVm.selfHeight))
        return vm
    }()
    lazy var headVm: HabitRankListHeadVM = {
        let vm = HabitRankListHeadVM.init(frame: .zero)
        return vm
    }()
    lazy var upDegreeeVm: HabitRankListSectionVM = {
        let vm = HabitRankListSectionVM.init(frame: .zero)
        vm.updateUI(isUp: true)
        return vm
    }()
    lazy var downDegreeeVm: HabitRankListSectionVM = {
        let vm = HabitRankListSectionVM.init(frame: .zero)
        vm.updateUI(isUp: false)
        return vm
    }()
}

extension HabitRankListVM{
    func updateUI(dict:NSDictionary) {
        
    }
}

extension HabitRankListVM{
    private func loadCachedLeaderboard() {
        let dataArray = UserDefaults.getHabitRankListVMDataArray()
        if dataArray.count > 0 {
            
        }else{
            sendDataRequest()
            return
        }
//        guard let data = UserDefaults.standard.data(forKey: leaderboardCacheKey),
//              let cache = try? JSONSerialization.jsonObject(with: data) as? [NSDictionary] else {
//            sendDataRequest()
//            return
//        }

//        dataSourceArray = dataArray//cache as NSArray
        dataSourceArray = prepareLeaderboardData(from: dataArray)//cache as NSArray
        displayedDataArray = dataSourceArray
        
        if dataSourceArray.count == 0 {
            sendDataRequest()
        }
//        tableView.reloadData()
    }

    private func cacheLeaderboard(_ leaderboard: NSArray) {
        guard JSONSerialization.isValidJSONObject(leaderboard),
              let data = try? JSONSerialization.data(withJSONObject: leaderboard, options: []) else {
            return
        }
        
//        UserDefaults.standard.setValue(data, forKey: leaderboardCacheKey)
        UserDefaults.setHabitRankListVMDataArray(leaderboard)
    }

    func updateVisibility(isVisible: Bool) {
        if isVisible && !isCurrentlyVisible {
            isCurrentlyVisible = true
            sendDataRequest(animateSelfChange: true)
        }
    }
}
extension HabitRankListVM:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return displayedDataArray.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == promotionLine{
            return upDegreeeVm.selfHeight
        }else if section == relegationLine - 1{
            return downDegreeeVm.selfHeight
        }
        return section > 0 ? kFitWidth(25) : 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == promotionLine{
            return upDegreeeVm
        }else if section == relegationLine - 1{
            return downDegreeeVm
        }
        return nil
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        emptyVm.isHidden = dataSourceArray.count > 0
//        headVm.isHidden = dataSourceArray.count == 0
//        return dataSourceArray.count
        
        emptyVm.isHidden = displayedDataArray.count > 0
        headVm.isHidden = displayedDataArray.count == 0
        return 1//displayedDataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                withIdentifier: HabitRankTableViewCell.identifier,
                for: indexPath
            ) as! HabitRankTableViewCell
        cell.isHidden = false        // ✅ 复位，避免复用导致隐藏
        cell.alpha = 1               // ✅ 保险一点
        cell.contentView.alpha = 1
        
//        let dict = dataSourceArray[indexPath.row] as? NSDictionary ?? [:]
        let dict = displayedDataArray[indexPath.section] as? NSDictionary ?? [:]
        
        cell.configure(
//            rank: dict.stringValueForKey(key: "sn"),
            rank: "\(indexPath.section + 1)",
            avatar: dict.stringValueForKey(key: "headimgurl"),
            name: dict.stringValueForKey(key: "nickname"),
            fireCount: dict.stringValueForKey(key: "donateCount").intValue,
            score: dict.stringValueForKey(key: "rankPointBalance")
        )
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(45)
    }
}

extension HabitRankListVM{
    func initUI() {
        addSubview(tableView)
        addSubview(headVm)
//        tableView.addSubview(emptyVm)
        
    }
}

extension HabitRankListVM{
    func sendDataRequest(animateSelfChange: Bool = false){
        let previousSelfIndex = animateSelfChange ? indexOfCurrentUser(in: dataSourceArray) : nil
        WHNetworkUtil.shareManager().POST(urlString: URL_user_habit_leaderboard, parameters: nil,isNeedToast: true,vc: self.controller) { responseObject in
            
            let code = responseObject["code"]as? Int ?? -1
            if code == 200 {
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
                
                DLLog(message: "sendDataRequest:\(dataDict)")
                
//                self.dataSourceArray = dataDict["leaderboard"]as? NSArray ?? []
                self.dataSourceArray = self.prepareLeaderboardData(from: dataDict["leaderboard"]as? NSArray ?? [])
                self.cacheLeaderboard(self.dataSourceArray)
                let weeklyRewardPoint = dataDict["weeklyRewardPoint"]as? NSDictionary ?? [:]
                
                self.headVm.updateUI(champion: weeklyRewardPoint.stringValueForKey(key: "champion"),
                                runnerUp: weeklyRewardPoint.stringValueForKey(key: "runnerUp"),
                                thirdPlace: weeklyRewardPoint.stringValueForKey(key: "thirdPlace"),
                                 secondsToWeekEnd:dataDict.stringValueForKey(key: "secondsToWeekEnd").intValue)
                self.headVm.updateDegree(tier: self.currentTierIndex)
                
                let newIndex = self.indexOfCurrentUser(in: self.dataSourceArray)
                
                self.displayedDataArray = self.initialDisplayArray(
                    for: self.dataSourceArray,
                    previousIndex: previousSelfIndex,
                    newIndex: newIndex,
                    shouldAnimate: animateSelfChange
                )
//                self.displayedDataArray = self.dataSourceArray
                self.tableView.reloadData()
                if animateSelfChange {
                    self.onTapRank()
                    self.promotionLine = dataDict.stringValueForKey(key: "promotionLine").intValue
                    self.relegationLine = dataDict.stringValueForKey(key: "relegationLine").intValue
                    self.performSelfRankMove(from: previousSelfIndex, to: newIndex)
                }else{
                    guard let oldIndex = previousSelfIndex else { return  }
                    let fromIndexPath = IndexPath(row: 0, section: oldIndex)
                    
                    self.tableView.layoutIfNeeded()
                    self.tableView.scrollToRow(at: fromIndexPath, at: .middle, animated: false)
                    self.tableView.layoutIfNeeded()
                }
            }else{
                self.dataSourceArray = NSArray()
                self.cacheLeaderboard(self.dataSourceArray)
                self.displayedDataArray = self.dataSourceArray
                self.tableView.reloadData()
            }
        }
    }
    func sendDataRequestForHeadMsg(){
        WHNetworkUtil.shareManager().POST(urlString: URL_user_habit_leaderboard, parameters: nil,isNeedToast: true,vc: self.controller) { responseObject in
            let code = responseObject["code"]as? Int ?? -1
            if code == 200 {
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
                DLLog(message: "sendDataRequest:\(dataDict)")
                UserDefaults.setTierData(tier: dataDict.stringValueForKey(key: "tier"), isRefresh: false)
                self.currentTierIndex = 9//dataDict.stringValueForKey(key: "tier").intValue
                let weeklyRewardPoint = dataDict["weeklyRewardPoint"]as? NSDictionary ?? [:]
                
                self.headVm.updateUI(champion: weeklyRewardPoint.stringValueForKey(key: "champion"),
                                runnerUp: weeklyRewardPoint.stringValueForKey(key: "runnerUp"),
                                thirdPlace: weeklyRewardPoint.stringValueForKey(key: "thirdPlace"),
                                 secondsToWeekEnd:dataDict.stringValueForKey(key: "secondsToWeekEnd").intValue)
                self.headVm.updateDegree(tier: self.currentTierIndex)
            }
        }
    }
}

extension HabitRankListVM{
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
    private func initialDisplayArray(for leaderboard: NSArray, previousIndex: Int?, newIndex: Int?, shouldAnimate: Bool) -> NSArray {
        guard shouldAnimate,
              let previousIndex,
              let newIndex,
              previousIndex != newIndex,
              leaderboard.count > 0,
              let mutable = leaderboard.mutableCopy() as? NSMutableArray,
              newIndex < mutable.count else {
            return leaderboard
        }

        let selfEntry = mutable.object(at: newIndex)
        mutable.removeObject(at: newIndex)
        let targetIndex = max(0, min(previousIndex, mutable.count))
        mutable.insert(selfEntry, at: targetIndex)

        return mutable
    }
    private func performSelfRankMove(from oldIndex: Int?, to newIndex: Int?) {
        DLLog(message: "移动前后Index: \(oldIndex ?? -1) -- \(newIndex ?? -1)")
        guard let oldIndex  else { return }
        
        DispatchQueue.main.async {
            let fromIndexPath = IndexPath(row: 0, section: oldIndex)

            self.tableView.layoutIfNeeded()

            // ✅ 用 rect + clamp 算 offset，避免 scrollToRow 在估算高度时产生空白
            guard oldIndex < self.displayedDataArray.count else { return }
            let fromRect = self.tableView.rectForRow(at: fromIndexPath)
            let offset = self.endContentOffsetToShow(rect: fromRect, position: .middle)
            self.tableView.setContentOffset(offset, animated: false)
            self.tableView.layoutIfNeeded()
        }
        guard let newIndex, oldIndex != newIndex else { return }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
            self.animateHighlightMove3Stage(from: oldIndex, to: newIndex, extraVertical: 20)
        })
//        DispatchQueue.main.async {
//            // ✅ 调用三段式动画
//            self.animateHighlightMove3Stage(from: oldIndex, to: newIndex, extraVertical: 20)
//        }
    }
}

extension HabitRankListVM{
    private func prepareLeaderboardData(from array: NSArray) -> NSArray {
        var entries = array.compactMap { $0 as? NSDictionary }
        var placeholderIndex = 1

        while entries.count < 20 {
            let randomScore = Int.random(in: 1...20)
            let placeholder: NSDictionary = [
                "headimgurl": "",
                "nickname": "Tester \(placeholderIndex)",
                "donateCount": 0,
                "rankPointBalance": "\(randomScore)"
            ]
            entries.append(placeholder)
            placeholderIndex += 1
        }

        let sortedEntries = entries.sorted {
            $0.stringValueForKey(key: "rankPointBalance").intValue > $1.stringValueForKey(key: "rankPointBalance").intValue
        }

        return Array(sortedEntries.prefix(20)) as NSArray
    }
}

extension HabitRankListVM {
    /// ⭐️ 三段式（不贴边、不回头）：Lift → Move+Scroll → Drop
    private func animateHighlightMove3Stage(from oldIndex: Int,
                                            to newIndex: Int,
                                            extraVertical: CGFloat = 20) {

        let fromIndexPath = IndexPath(row: 0, section: oldIndex)
        let toIndexPath   = IndexPath(row: 0, section: newIndex)

        guard
            oldIndex != newIndex,
            displayedDataArray.count > 0,
            oldIndex >= 0, oldIndex < displayedDataArray.count,
            newIndex >= 0, newIndex < displayedDataArray.count,
            let fromCell = tableView.cellForRow(at: fromIndexPath),
            let container = tableView.superview
        else { return }

        tableView.layoutIfNeeded()

        // ✅ overlay：裁剪区域 = tableView 可视区域
        let overlay = UIView(frame: tableView.frame)
        overlay.backgroundColor = .clear
        overlay.isUserInteractionEnabled = false
        overlay.clipsToBounds = true
        container.addSubview(overlay)

        // ✅ 高亮卡片（外扩上下 extraVertical）
//        let highlightView = makeHighlightSnapshotView(from: fromCell, extraVertical: extraVertical)
        let highlightView: UIView
        if let habitCell = fromCell as? HabitRankTableViewCell {
            highlightView = makeHighlightMirrorCellView(from: oldIndex, fromCell: habitCell, extraVertical: extraVertical)
        } else {
            highlightView = makeHighlightSnapshotView(from: fromCell, extraVertical: extraVertical)
        }

        let startOffset = tableView.contentOffset
        let startCellFrameInOverlay = tableView.convert(fromCell.frame, to: overlay)
        var startFrame = startCellFrameInOverlay.insetBy(dx: 0, dy: -extraVertical)
        startFrame = clamp(frame: startFrame, inside: overlay.bounds, margin: 2)

        highlightView.frame = startFrame
        overlay.addSubview(highlightView)

        // 隐藏源 cell（⚠️记得在 cellForRowAt 里强制 cell.isHidden=false 防复用）
        fromCell.isHidden = true

        // 目标 rect（content 坐标）
        let targetRectInContent = tableView.rectForRow(at: toIndexPath)

        // ✅ 关键：算一个 endOffset，让“扩高后的高亮卡片”也能完整显示在可视区
        let endOffset = endContentOffsetToFullyShow(rect: targetRectInContent,
                                                    extraVertical: extraVertical)

        // endFrame（overlay 坐标）= contentRect - endOffset
        var endFrame = targetRectInContent.offsetBy(dx: -endOffset.x, dy: -endOffset.y)
        endFrame = endFrame.insetBy(dx: 0, dy: -extraVertical)
        endFrame.size.width = startFrame.size.width
        endFrame.origin.x = startFrame.origin.x
        endFrame = clamp(frame: endFrame, inside: overlay.bounds, margin: 2)

        // 动画期间禁用交互，避免用户滚动打断
        tableView.isUserInteractionEnabled = false
        tableView.isScrollEnabled = false

        // 时长：滚动越远段2越长
        let distance = abs(endOffset.y - startOffset.y)
        let liftDuration: TimeInterval = 0.16
        let moveDuration: TimeInterval = (distance < 30) ? 0.22 : min(max(distance / 900.0, 0.45), 0.95)
        let dropDuration: TimeInterval = 0.16

        // --- 段1：Lift（只放大，不“跑到边缘”）
        UIView.animate(withDuration: liftDuration,
                       delay: 0,
                       usingSpringWithDamping: 0.85,
                       initialSpringVelocity: 0.6,
                       options: [.curveEaseInOut, .beginFromCurrentState]) {
            highlightView.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
        } completion: { _ in

            // --- 段2：Move + Scroll（同时从 start -> end，路径直达，不回头）
            let moveAnimator = UIViewPropertyAnimator(duration: moveDuration, curve: .easeInOut) {
                self.tableView.contentOffset = endOffset
                highlightView.frame = endFrame
            }

            moveAnimator.addCompletion { _ in

                // --- 段3：Drop（只回到正常 scale，不改位置）
                UIView.animate(withDuration: dropDuration,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.7,
                               options: [.curveEaseInOut, .beginFromCurrentState]) {
                    highlightView.transform = .identity
                } completion: { _ in

                    // ✅ 动画结束：数据归位 + moveSection + 刷新
                    let item = self.displayedDataArray.object(at: oldIndex)
                    let mutable = self.displayedDataArray.mutableCopy() as! NSMutableArray
                    mutable.removeObject(at: oldIndex)
                    mutable.insert(item, at: newIndex)
                    self.displayedDataArray = mutable

                    UIView.performWithoutAnimation {
                        self.tableView.performBatchUpdates({
                            self.tableView.moveSection(oldIndex, toSection: newIndex)
                        }, completion: { _ in
                            // 固定最终滚动位置，避免 batchUpdates 后抖动/空白
                            self.tableView.setContentOffset(endOffset, animated: false)

                            // 只刷新受影响区间（比 reloadData 更稳更轻）
                            let lo = min(oldIndex, newIndex)
                            let hi = max(oldIndex, newIndex)
                            self.tableView.reloadSections(IndexSet(integersIn: lo...hi), with: .none)

                            // 还原
                            fromCell.isHidden = false
                            overlay.removeFromSuperview()

                            self.tableView.isScrollEnabled = true
                            self.tableView.isUserInteractionEnabled = true
                        })
                    }
                }
            }

            moveAnimator.startAnimation()
        }
    }
    private func safeSnapshot(of view: UIView) -> UIView {

        if let snapshot = view.snapshotView(afterScreenUpdates: true) {
            return snapshot
        }

        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }

        return UIImageView(image: image)
    }

}

extension HabitRankListVM{
    /// 让某个 rect 最终出现在 tableView 的 .middle（或你想要的位置）
    /// 这里用 contentOffset 直接动画，滚动会和 snapshot 同步
    private func endContentOffsetToShow(rect: CGRect, position: UITableView.ScrollPosition) -> CGPoint {

        let inset = tableView.adjustedContentInset
        let visibleHeight = tableView.bounds.height

        var targetY: CGFloat

        switch position {
        case .top:
            targetY = rect.minY - inset.top
        case .bottom:
            targetY = rect.maxY - visibleHeight + inset.bottom
        default:
            // .middle / 其他：居中
            targetY = rect.midY - visibleHeight * 0.5
        }

        // clamp 到可滚动范围
        let minY = -inset.top
        let maxY = max(minY, tableView.contentSize.height - visibleHeight + inset.bottom)
        targetY = min(max(targetY, minY), maxY)

        return CGPoint(x: tableView.contentOffset.x, y: targetY)
    }

    /// 保证 snapshot frame 完全在 overlay 可视区域内
    private func clamp(frame: CGRect, inside bounds: CGRect, margin: CGFloat = 0) -> CGRect {
        var f = frame
        let minY = bounds.minY + margin
        let maxY = bounds.maxY - margin - f.height
        f.origin.y = min(max(f.origin.y, minY), maxY)

        let minX = bounds.minX + margin
        let maxX = bounds.maxX - margin - f.width
        f.origin.x = min(max(f.origin.x, minX), maxX)

        return f
    }
    private func makeHighlightMirrorCellView(from index: Int,
                                             fromCell: HabitRankTableViewCell,
                                             extraVertical: CGFloat) -> UIView {

        let dict = displayedDataArray[index] as? NSDictionary ?? [:]
        let avatarURL = dict.stringValueForKey(key: "headimgurl")

        let mirror = HabitRankTableViewCell(style: .default, reuseIdentifier: nil)
        mirror.frame = fromCell.bounds

        mirror.configure(
            rank: "\(index + 1)",
            avatar: avatarURL, // ✅ 用正确URL
            name: dict.stringValueForKey(key: "nickname"),
            fireCount: dict.stringValueForKey(key: "donateCount").intValue,
            score: dict.stringValueForKey(key: "rankPointBalance"),
            needAvatarTransition: false // ✅ 高亮不fade，像拖拽
        )

        mirror.layoutIfNeeded()

        // 包装成上下+20的高亮卡片（你之前那套）
        let inner = UIView(frame: CGRect(x: 0, y: 0,
                                         width: mirror.bounds.width,
                                         height: mirror.bounds.height + extraVertical * 2))
        inner.backgroundColor = .COLOR_CARD_BG_WHITE
        inner.layer.cornerRadius = 12
        inner.clipsToBounds = true

        mirror.frame = CGRect(x: 0, y: extraVertical,
                              width: mirror.bounds.width,
                              height: mirror.bounds.height)
        inner.addSubview(mirror)

        let outer = UIView(frame: inner.bounds)
        outer.backgroundColor = .clear
        outer.layer.shadowColor = UIColor.black.cgColor
        outer.layer.shadowOpacity = 0.22
        outer.layer.shadowRadius = 10
        outer.layer.shadowOffset = CGSize(width: 0, height: 6)
        outer.layer.cornerRadius = 12
        outer.addSubview(inner)

        return outer
    }

    /// ✅ 高亮卡片：上下各+extraVertical，不拉伸 snapshot
    private func makeHighlightSnapshotView(from cell: UITableViewCell, extraVertical: CGFloat) -> UIView {

        let snap = safeSnapshot(of: cell)
        snap.frame = CGRect(x: 0,
                            y: extraVertical,
                            width: cell.bounds.width,
                            height: cell.bounds.height)

        // 内层：负责圆角裁剪
        let inner = UIView(frame: CGRect(x: 0,
                                         y: 0,
                                         width: cell.bounds.width,
                                         height: cell.bounds.height + extraVertical * 2))
        inner.backgroundColor = cell.contentView.backgroundColor ?? cell.backgroundColor ?? .white
        inner.layer.cornerRadius = 12
        inner.clipsToBounds = true
        inner.addSubview(snap)

        // 外层：负责阴影（不能 clipsToBounds）
        let outer = UIView(frame: inner.bounds)
        outer.backgroundColor = .clear
        outer.layer.shadowColor = UIColor.black.cgColor
        outer.layer.shadowOpacity = 0.22
        outer.layer.shadowRadius = 10
        outer.layer.shadowOffset = CGSize(width: 0, height: 6)
        outer.layer.cornerRadius = 12
        outer.addSubview(inner)

        return outer
    }
    /// 让 rect（扩大上下 extraVertical 后）也尽可能完整显示在 tableView 可视区域内
    private func endContentOffsetToFullyShow(rect: CGRect, extraVertical: CGFloat) -> CGPoint {

        let inset = tableView.adjustedContentInset
        let visibleH = tableView.bounds.height

        // 扩大后的 rect（用于确保高亮卡片不出界）
        let expanded = rect.insetBy(dx: 0, dy: -extraVertical)

        // 先按“居中”算一个理想 offset
        var desiredY = expanded.midY - visibleH * 0.5

        // 再把 desiredY 夹到“expanded 能完整显示”的可行区间内
        // 条件：expanded.minY - offsetY >= 0  且 expanded.maxY - offsetY <= visibleH
        // => offsetY <= expanded.minY  且 offsetY >= expanded.maxY - visibleH
        let feasibleMin = expanded.maxY - visibleH
        let feasibleMax = expanded.minY
        if feasibleMin <= feasibleMax {
            desiredY = min(max(desiredY, feasibleMin), feasibleMax)
        }

        // 最后 clamp 到 tableView 可滚动范围
        let minY = -inset.top
        let maxY = max(minY, tableView.contentSize.height - visibleH + inset.bottom)
        desiredY = min(max(desiredY, minY), maxY)

        return CGPoint(x: tableView.contentOffset.x, y: desiredY)
    }

}

// MARK: - 段位变化动画
extension HabitRankListVM {
    @objc private func onTapRank() {
        guard !isAnimatingToDemo else { return }
        let fromIndex: Int = UserDefaults().getTierData().intValue
        
        guard fromIndex != currentTierIndex,
        fromIndex > 0 else { return }
        
        let mode: RankResultViewController.Mode = fromIndex < currentTierIndex ? .promote : .demote
        unlockedTierIndex = currentTierIndex//max(unlockedTierIndex, currentTierIndex)
        playTransitionToDemo(mode: mode,
                             fromIndex: fromIndex - 1,
                             toIndex: currentTierIndex - 1)
        UserDefaults.setTierData(tier: "\(currentTierIndex)", isRefresh: true)
//        self.headVm.updateDegree(tier: currentTierIndex)
    }

    private func playTransitionToDemo(mode: RankResultViewController.Mode, fromIndex: Int, toIndex: Int) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.keyWindow else { return }
        isAnimatingToDemo = true

        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        window.addSubview(overlay)

        let snapshot = UIImageView(image: self.headVm.rankImgView.image)
        snapshot.contentMode = .scaleAspectFit
        snapshot.frame = self.headVm.rankImgView.convert(self.headVm.rankImgView.bounds, to: window)
        overlay.addSubview(snapshot)
        self.headVm.rankImgView.isHidden = true
        let demoVC = DemoViewController()
       demoVC.configure(currentIndex: fromIndex, unlockedMaxIndex: toIndex)
//       let preparedTargetFrame = targetBadgeFrame(in: window, using: demoVC)
//        demoVC.configure(currentIndex: currentTierIndex, unlockedMaxIndex: unlockedTierIndex)
        let preparedTargetFrame = targetBadgeFrame(in: window, using: demoVC)

        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.curveEaseInOut]) {
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.15)
            
            if let targetFrame = preparedTargetFrame {
                            snapshot.frame = targetFrame
                        } else {
                            snapshot.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                            snapshot.center = CGPoint(x: window.bounds.midX, y: window.bounds.midY)
                        }
        } completion: { _ in
            self.presentDemoPage(using: snapshot,
                                 overlay: overlay,
                                 mode: mode,
                                 fromIndex: fromIndex,
                                 toIndex: toIndex,
                                 demoVC: demoVC,
                                 preparedTargetFrame: preparedTargetFrame)
        }
    }

    private func presentDemoPage(using snapshot: UIImageView,
                                 overlay: UIView,
                                 mode: RankResultViewController.Mode,
                                 fromIndex: Int,
                                 toIndex: Int,
                                  demoVC: DemoViewController,
                                  preparedTargetFrame: CGRect?) {
        demoVC.modalPresentationStyle = .fullScreen
        demoVC.onRequestDismiss = { [weak self, weak demoVC] badgeFrame, badgeImage in
            guard let self, let demoVC else { return }
            self.animateBackToRank(from: badgeFrame, badgeImage: badgeImage, demoVC: demoVC)
        }

        let hostVC = WHTool.shared.getCurrentViewController()
        hostVC.present(demoVC, animated: false) {
            demoVC.view.layoutIfNeeded()
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.keyWindow else {
                overlay.removeFromSuperview()
                snapshot.removeFromSuperview()
                demoVC.play(mode: mode, fromIndex: fromIndex, toIndex: toIndex)
                self.headVm.updateDegree(tier: self.currentTierIndex)
                self.isAnimatingToDemo = false
                return
            }
            let targetInWindow = preparedTargetFrame ?? {
                guard let targetFrame = demoVC.badgeFrame(in: demoVC.view) else { return nil }
                return demoVC.view.convert(targetFrame, to: window)
            }()

            guard let finalFrame = targetInWindow else {
                overlay.removeFromSuperview()
                snapshot.removeFromSuperview()
                demoVC.play(mode: mode, fromIndex: fromIndex, toIndex: toIndex)
                self.headVm.updateDegree(tier: self.currentTierIndex)
                self.isAnimatingToDemo = false
                return
            }
            
            demoVC.updateCurrentIndex(currentIndex: fromIndex)
            UIView.animate(withDuration: 0.15,
                           delay: 0,
                           options: [.curveEaseInOut]) {
                snapshot.transform = .identity
                snapshot.frame = finalFrame
                overlay.backgroundColor = .clear
//                demoVC.play(mode: mode, fromIndex: fromIndex, toIndex: toIndex)
            } completion: { _ in
                overlay.removeFromSuperview()
                snapshot.removeFromSuperview()
                demoVC.play(mode: mode, fromIndex: fromIndex, toIndex: toIndex)
                self.headVm.updateDegree(tier: self.currentTierIndex)
                self.isAnimatingToDemo = false
            }
        }
    }
    private func animateBackToRank(from badgeFrame: CGRect, badgeImage: UIImage?, demoVC: DemoViewController) {
        guard !isAnimatingBackFromDemo else { return }
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.keyWindow else {
            demoVC.dismiss(animated: true)
            return
        }
        isAnimatingBackFromDemo = true

        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        window.addSubview(overlay)

        let snapshot = UIImageView(image: badgeImage ?? self.headVm.rankImgView.image)
        snapshot.contentMode = .scaleAspectFit
        snapshot.frame = badgeFrame
        overlay.addSubview(snapshot)

        demoVC.dismiss(animated: false) {
            let targetFrame = self.headVm.rankImgView.convert(self.headVm.rankImgView.bounds, to: window)
            UIView.animate(withDuration: 0.32,
                           delay: 0,
                           options: [.curveEaseInOut]) {
                overlay.backgroundColor = UIColor.black.withAlphaComponent(0.08)
                snapshot.frame = targetFrame
            } completion: { _ in
                overlay.removeFromSuperview()
                self.headVm.rankImgView.isHidden = false
                self.isAnimatingBackFromDemo = false
            }
        }
    }
    private func targetBadgeFrame(in window: UIWindow, using demoVC: DemoViewController) -> CGRect? {
//       demoVC.loadViewIfNeeded()
//       demoVC.view.frame = window.bounds
//       demoVC.view.layoutIfNeeded()
//       guard let targetFrame = demoVC.badgeFrame(in: demoVC.view) else { return nil }
//       return demoVC.view.convert(targetFrame, to: window)
        demoVC.loadViewIfNeeded()
        demoVC.view.frame = window.bounds
        demoVC.view.isHidden = true
        window.addSubview(demoVC.view)
        demoVC.view.setNeedsLayout()
        demoVC.view.layoutIfNeeded()
        guard let targetFrame = demoVC.badgeFrame(in: demoVC.view) else {
            demoVC.view.removeFromSuperview()
            demoVC.view.isHidden = false
            return nil
        }
        let convertedFrame = demoVC.view.convert(targetFrame, to: window)
        demoVC.view.removeFromSuperview()
        demoVC.view.isHidden = false
        return convertedFrame
   }
}
