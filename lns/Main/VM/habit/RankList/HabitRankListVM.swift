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
                                 secondsToWeekEnd:dataDict.stringValueForKey(key: "secondsToWeekEnd").intValue,
                                     tier:dataDict.stringValueForKey(key: "tier").intValue)
                var newIndex = self.indexOfCurrentUser(in: self.dataSourceArray)
                
//                if previousSelfIndex != nil  {
//                    if previousSelfIndex! + 8 > 20{
//                        newIndex = previousSelfIndex! - 8
//                    }else{
//                        newIndex = previousSelfIndex! + 8
//                    }
//                }
                
                self.displayedDataArray = self.initialDisplayArray(
                    for: self.dataSourceArray,
                    previousIndex: previousSelfIndex,
                    newIndex: newIndex,
                    shouldAnimate: animateSelfChange
                )
//                self.displayedDataArray = self.dataSourceArray
                self.tableView.reloadData()
                if animateSelfChange {
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
                
                let weeklyRewardPoint = dataDict["weeklyRewardPoint"]as? NSDictionary ?? [:]
                
                self.headVm.updateUI(champion: weeklyRewardPoint.stringValueForKey(key: "champion"),
                                runnerUp: weeklyRewardPoint.stringValueForKey(key: "runnerUp"),
                                thirdPlace: weeklyRewardPoint.stringValueForKey(key: "thirdPlace"),
                                 secondsToWeekEnd:dataDict.stringValueForKey(key: "secondsToWeekEnd").intValue,
                                     tier:dataDict.stringValueForKey(key: "tier").intValue)
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

    private func animateSelfRankChange(from oldIndex: Int?, to newIndex: Int?) {
        guard let oldIndex, let newIndex, oldIndex != newIndex else { return }

        DispatchQueue.main.async {
            let targetIndexPath = IndexPath(row: 0, section: newIndex)
            if self.tableView.cellForRow(at: targetIndexPath) == nil {
                self.tableView.scrollToRow(at: targetIndexPath, at: .middle, animated: false)
                self.tableView.layoutIfNeeded()
            }

            guard let cell = self.tableView.cellForRow(at: targetIndexPath) else { return }
            let offset = CGFloat(oldIndex - newIndex) * kFitWidth(70)
            cell.contentView.transform = CGAffineTransform(translationX: 0, y: offset)
            UIView.animate(withDuration: 0.75,
                           delay: 0.15,
                           usingSpringWithDamping: 0.75,
                           initialSpringVelocity: 0.6,
                           options: [.curveEaseInOut]) {
                cell.contentView.transform = .identity
            }
        }
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

//    private func performSelfRankMove(from oldIndex: Int?, to newIndex: Int?) {
//        DLLog(message: "移动前后Index: \(oldIndex ?? -1) -- \(newIndex ?? -1)")
//        guard let oldIndex  else { return }
//        DispatchQueue.main.async {
//            let fromIndexPath = IndexPath(row: 0, section: oldIndex)
//
//            self.tableView.reloadData()
//            self.tableView.layoutIfNeeded()
//            self.tableView.scrollToRow(at: fromIndexPath, at: .middle, animated: false)
//            self.tableView.layoutIfNeeded()
//        }
//        guard let newIndex, oldIndex != newIndex else { return }
//
//        DispatchQueue.main.async {
//            self.animateHighlightMove(from: oldIndex, to: newIndex)
//        }
//    }
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
        DispatchQueue.main.async {
            // ✅ 调用三段式动画
            self.animateHighlightMove3Stage(from: oldIndex, to: newIndex, extraVertical: 20)
        }
    }
}

extension HabitRankListVM{
    private func prepareLeaderboardData(from array: NSArray) -> NSArray {
        var entries = array.compactMap { $0 as? NSDictionary }
        var placeholderIndex = 1

        while entries.count < 20 {
            let randomScore = Int.random(in: 3...40)
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
    /// ⭐️ 核心动画：高亮 + 跟随滚动移动
//    private func animateHighlightMove(from oldIndex: Int, to newIndex: Int) {
//
//        let fromIndexPath = IndexPath(row: 0, section: oldIndex)
//        let toIndexPath   = IndexPath(row: 0, section: newIndex)
//        
//        DLLog(message: "移动前后Index: \(oldIndex)  ---  \(newIndex)")
//
//        guard
//            let cell = tableView.cellForRow(at: fromIndexPath),
//            let container = tableView.superview
//        else { return }
//        let snapshot = safeSnapshot(of: cell)
//        snapshot.frame = tableView.convert(cell.frame, to: container)
//        snapshot.layer.shadowColor = UIColor.black.cgColor
//        snapshot.layer.shadowOpacity = 0.25
//        snapshot.layer.shadowRadius = 8
//        snapshot.layer.cornerRadius = 12
//        container.addSubview(snapshot)
//        cell.isHidden = true
//
//        let targetRect = tableView.rectForRow(at: toIndexPath)
//        var targetFrame = tableView.convert(targetRect, to: container)
//        
//        if targetFrame.origin.y < self.headVm.selfHeight{
//            let targetFrameT = targetFrame
//            targetFrame = CGRect.init(x: 0, y: self.headVm.selfHeight, width: targetFrameT.size.width, height: targetFrameT.size.height)
//        }
//
//        UIView.animate(withDuration: 0.8, delay: 0, options: [.curveEaseInOut]) {
//            snapshot.frame = targetFrame
//            self.tableView.scrollRectToVisible(targetRect, animated: false)
//        } completion: { _ in
//
//            cell.isHidden = false
//            snapshot.removeFromSuperview()
//
//            // 数据一次性归位
//            let item = self.displayedDataArray.object(at: oldIndex)
//            let mutable = self.displayedDataArray.mutableCopy() as! NSMutableArray
//            mutable.removeObject(at: oldIndex)
//            mutable.insert(item, at: newIndex)
//            self.displayedDataArray = mutable
//
//            UIView.performWithoutAnimation {
//                self.tableView.performBatchUpdates {
////                    self.tableView.moveRow(at: fromIndexPath, to: toIndexPath)
//                    self.tableView.moveSection(oldIndex, toSection: newIndex)
//                } completion: { _ in
//                    self.tableView.scrollToRow(at: toIndexPath, at: .middle, animated: true)
//                    self.tableView.reloadData()
////                    containerReal.removeFromSuperview()
//                }
//            }
//        }
//    }
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
        let highlightView = makeHighlightSnapshotView(from: fromCell, extraVertical: extraVertical)

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

    /// ⭐️ 三段式拖拽特效：靠边 → 自动滚动 → 落位
    private func animateHighlightMove3Stagettt(from oldIndex: Int, to newIndex: Int, extraVertical: CGFloat = 20) {

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

        // ✅ overlay：裁剪区域 = tableView 的可视区域
        let overlay = UIView(frame: tableView.frame)
        overlay.backgroundColor = .clear
        overlay.isUserInteractionEnabled = false
        overlay.clipsToBounds = true
        container.addSubview(overlay)

        // ✅ 高亮卡片（上下各+extraVertical，不拉伸原 snapshot）
        let highlightView = makeHighlightSnapshotView(from: fromCell, extraVertical: extraVertical)

        let startOffset = tableView.contentOffset
        let startCellFrameInOverlay = tableView.convert(fromCell.frame, to: overlay)
        var startFrame = startCellFrameInOverlay.insetBy(dx: 0, dy: -extraVertical)
        startFrame = clamp(frame: startFrame, inside: overlay.bounds, margin: 2)

        highlightView.frame = startFrame
        overlay.addSubview(highlightView)

        // 隐藏源 cell（注意你 cellForRow 已要做 isHidden=false 的复位，见后文）
        fromCell.isHidden = true

        // 目标 rect（content 坐标）
        let targetRectInContent = tableView.rectForRow(at: toIndexPath)

        // 计算最终滚动到哪（让目标尽量在 middle）
        let endOffset = endContentOffsetToShow(rect: targetRectInContent, position: .middle)

        // 目标 frame（overlay 坐标）= contentRect - endOffset
        var endFrame = targetRectInContent.offsetBy(dx: -endOffset.x, dy: -endOffset.y)
        endFrame = endFrame.insetBy(dx: 0, dy: -extraVertical)
        endFrame.size.width = startFrame.size.width
        endFrame.origin.x = startFrame.origin.x
        endFrame = clamp(frame: endFrame, inside: overlay.bounds, margin: 2)

        // 段1：靠边位置
        let movingUp = newIndex < oldIndex
        let edgePadding: CGFloat = 10
        var edgeFrame = startFrame
        edgeFrame.origin.y = movingUp ? edgePadding : (overlay.bounds.height - startFrame.height - edgePadding)
        edgeFrame = clamp(frame: edgeFrame, inside: overlay.bounds, margin: 2)

        // 段2：给一个中间 offset，让滚动更“拖拽感”
        let midOffsetY = startOffset.y + (endOffset.y - startOffset.y) * 0.65
        let midOffset = CGPoint(x: startOffset.x, y: midOffsetY)

        // 时长：根据滚动距离动态调整（越远段2越长）
        let distance = abs(endOffset.y - startOffset.y)
        let stage1: TimeInterval = 0.22
        let stage3: TimeInterval = 0.26
        let stage2: TimeInterval = (distance < 30) ? 0.12 : min(max(distance / 900.0, 0.40), 0.95)
        let total = stage1 + stage2 + stage3
        let stage2a = stage2 * 0.55
        let stage2b = stage2 - stage2a

        // 动画期间禁用交互，避免用户滚动打断
        tableView.isUserInteractionEnabled = false
        tableView.isScrollEnabled = false

        UIView.animateKeyframes(withDuration: total,
                                delay: 0,
                                options: [.calculationModeCubic, .beginFromCurrentState, .allowUserInteraction]) {

            // 1) Lift + 靠边
            UIView.addKeyframe(withRelativeStartTime: 0,
                               relativeDuration: stage1 / total) {
                highlightView.frame = edgeFrame
                highlightView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            }

            // 2a) 自动滚动到中间 offset（卡片贴边轻微“顶住”感）
            UIView.addKeyframe(withRelativeStartTime: stage1 / total,
                               relativeDuration: stage2a / total) {
                self.tableView.contentOffset = midOffset
                highlightView.frame = edgeFrame.offsetBy(dx: 0, dy: movingUp ? 2 : -2)
            }

            // 2b) 继续滚到最终 offset（卡片回到贴边基准位）
            UIView.addKeyframe(withRelativeStartTime: (stage1 + stage2a) / total,
                               relativeDuration: stage2b / total) {
                self.tableView.contentOffset = endOffset
                highlightView.frame = edgeFrame
            }

            // 3) Drop 落位
            UIView.addKeyframe(withRelativeStartTime: (stage1 + stage2) / total,
                               relativeDuration: stage3 / total) {
                highlightView.frame = endFrame
                highlightView.transform = .identity
            }

        } completion: { _ in

            // ✅ 动画结束后：更新数据 + moveSection + 刷新 rank
            let item = self.displayedDataArray.object(at: oldIndex)
            let mutable = self.displayedDataArray.mutableCopy() as! NSMutableArray
            mutable.removeObject(at: oldIndex)
            mutable.insert(item, at: newIndex)
            self.displayedDataArray = mutable

            UIView.performWithoutAnimation {
                self.tableView.performBatchUpdates({
                    self.tableView.moveSection(oldIndex, toSection: newIndex)
                }, completion: { _ in

                    // 固定最终滚动位置，避免 batchUpdates 后 contentOffset 抖动
                    self.tableView.setContentOffset(endOffset, animated: false)

                    // 只刷新受影响区间即可（比 reloadData 更稳更轻）
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

    private func animateHighlightMove(from oldIndex: Int, to newIndex: Int) {

        let fromIndexPath = IndexPath(row: 0, section: oldIndex)
        let toIndexPath   = IndexPath(row: 0, section: newIndex)

        DLLog(message: "移动前后Index: \(oldIndex)  ---  \(newIndex)")

        guard
            let fromCell = tableView.cellForRow(at: fromIndexPath),
            let container = tableView.superview
        else { return }

        // 确保 rectForRow / cell.frame 都是最新的
        tableView.layoutIfNeeded()

        // ✅ overlay：完全覆盖 tableView 可视区域，并裁剪
        let overlay = UIView(frame: tableView.frame)
        overlay.backgroundColor = .clear
        overlay.isUserInteractionEnabled = false
        overlay.clipsToBounds = true
        container.addSubview(overlay)

        // ✅ snapshot 放进 overlay，这样永远不会超出 tableView 显示区域
        let snapshot = safeSnapshot(of: fromCell)
        snapshot.layer.shadowColor = UIColor.black.cgColor
        snapshot.layer.shadowOpacity = 0.25
        snapshot.layer.shadowRadius = 8
        snapshot.layer.cornerRadius = 12
        snapshot.layer.masksToBounds = false

        let startOffset = tableView.contentOffset
        // fromCell.frame 是 content 坐标，转成 overlay(可视坐标)
        let startFrameInOverlay = tableView.convert(fromCell.frame, to: overlay)
        snapshot.frame = startFrameInOverlay
        overlay.addSubview(snapshot)

        // 隐藏源 cell（注意：cellForRowAt 已经做了复位防复用）
        fromCell.isHidden = true

        // 目标 rect（content 坐标）
        let targetRectInContent = tableView.rectForRow(at: toIndexPath)

        // ✅ 计算动画结束时 tableView 应该滚到哪（建议：让目标行尽量靠近 middle）
        let endOffset = self.endContentOffsetToShow(rect: targetRectInContent, position: .middle)

        // ✅ 动画结束时 snapshot 的位置（overlay 可视坐标）= contentRect - endOffset
        var endFrameInOverlay = targetRectInContent.offsetBy(dx: -endOffset.x, dy: -endOffset.y)

        // 保持和原 cell 宽高一致（防止 grouped/Inset 变化导致跳动）
        endFrameInOverlay.size = startFrameInOverlay.size
        endFrameInOverlay.origin.x = startFrameInOverlay.origin.x

        // ✅ 再做一次 clamp，保证 snapshot “完全在 overlay 内部”
        endFrameInOverlay = clamp(frame: endFrameInOverlay, inside: overlay.bounds)

        // 为了更像拖拽：轻微放大 + 回弹
        snapshot.transform = .identity

        // 你可以调这个时长和阻尼
        let duration: TimeInterval = 0.85

        // 禁止用户在动画期间手动滚动打断
        tableView.isUserInteractionEnabled = false
        tableView.isScrollEnabled = false

        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            snapshot.frame = endFrameInOverlay
            snapshot.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
            self.tableView.contentOffset = endOffset   // ✅ 同步滚动动画
        }

        animator.addCompletion { _ in

            // 回到正常大小
            UIView.animate(withDuration: 0.12) {
                snapshot.transform = .identity
            } completion: { _ in

                fromCell.isHidden = false
                overlay.removeFromSuperview()

                // 数据一次性归位（沿用你原来的逻辑）
                let item = self.displayedDataArray.object(at: oldIndex)
                let mutable = self.displayedDataArray.mutableCopy() as! NSMutableArray
                mutable.removeObject(at: oldIndex)
                mutable.insert(item, at: newIndex)
                self.displayedDataArray = mutable

                UIView.performWithoutAnimation {
                    self.tableView.performBatchUpdates({
                        self.tableView.moveSection(oldIndex, toSection: newIndex)
                    }, completion: { _ in
                        // 保持最终位置稳定（避免 moveSection 后轻微偏移）
                        self.tableView.setContentOffset(endOffset, animated: false)
                        self.tableView.reloadData()

                        self.tableView.isScrollEnabled = true
                        self.tableView.isUserInteractionEnabled = true
                    })
                }
            }
        }

        animator.startAnimation()
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
