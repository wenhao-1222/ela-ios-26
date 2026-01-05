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
    lazy var tableView: UITableView = {
        let vi = UITableView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight), style: .plain)
//        let vi = UITableView(frame: CGRect.init(x: 0, y: self.headVm.frame.maxY, width: SCREEN_WIDHT, height: selfHeight-self.headVm.selfHeight), style: .plain)
        vi.backgroundColor = .COLOR_BG_F2
//        vi.tableHeaderView = headVm
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.clipsToBounds = true
        vi.contentInsetAdjustmentBehavior = .never
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
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headVm.selfHeight
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headVm
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        emptyVm.isHidden = dataSourceArray.count > 0
//        headVm.isHidden = dataSourceArray.count == 0
//        return dataSourceArray.count
        
        emptyVm.isHidden = displayedDataArray.count > 0
        headVm.isHidden = displayedDataArray.count == 0
        return displayedDataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                withIdentifier: HabitRankTableViewCell.identifier,
                for: indexPath
            ) as! HabitRankTableViewCell

//        let dict = dataSourceArray[indexPath.row] as? NSDictionary ?? [:]
        let dict = displayedDataArray[indexPath.row] as? NSDictionary ?? [:]
        
        cell.configure(
//            rank: dict.stringValueForKey(key: "sn"),
            rank: "\(indexPath.row + 1)",
            avatar: dict.stringValueForKey(key: "headimgurl"),
            name: dict.stringValueForKey(key: "nickname"),
            fireCount: dict.stringValueForKey(key: "donateCount").intValue,
            score: dict.stringValueForKey(key: "rankPointBalance")
        )
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(70)
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
                    self.performSelfRankMove(from: previousSelfIndex, to: newIndex)
//                    let newIndex = self.indexOfCurrentUser(in: self.dataSourceArray)
//    //                self.animateSelfRankChange(from: 2, to: 0)
//                    self.animateSelfRankChange(from: previousSelfIndex, to: newIndex)
//                }else{
//                    self.tableView.reloadData()
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
            let targetIndexPath = IndexPath(row: newIndex, section: 0)
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

    private func performSelfRankMove(from oldIndex: Int?, to newIndex: Int?) {
        guard let oldIndex, let newIndex, oldIndex != newIndex else { return }

        DispatchQueue.main.async {
            let fromIndexPath = IndexPath(row: oldIndex, section: 0)

            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            self.tableView.scrollToRow(at: fromIndexPath, at: .middle, animated: false)
            self.tableView.layoutIfNeeded()

            self.animateHighlightMove(from: oldIndex, to: newIndex)
        }
//        guard let oldIndex, let newIndex, oldIndex != newIndex else { return }
//
//        DispatchQueue.main.async {
//            guard oldIndex < self.displayedDataArray.count,
//                  newIndex < self.dataSourceArray.count else {
//                self.displayedDataArray = self.dataSourceArray
//                self.tableView.reloadData()
//                return
//            }
//
//            let fromIndexPath = IndexPath(row: oldIndex, section: 0)
//            let toIndexPath = IndexPath(row: newIndex, section: 0)
//
////            self.tableView.performBatchUpdates({
////                self.displayedDataArray = self.dataSourceArray
////                self.tableView.moveRow(at: fromIndexPath, to: toIndexPath)
////            }, completion: { _ in
//////                    self.animateSelfRankChange(from: oldIndex, to: newIndex)
////            })
//            self.tableView.scrollToRow(at: fromIndexPath, at: .middle, animated: true)
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//                self.tableView.performBatchUpdates({
//                    self.displayedDataArray = self.dataSourceArray
//                    self.tableView.moveRow(at: fromIndexPath, to: toIndexPath)
//                }, completion: { _ in
//                    self.tableView.scrollToRow(at: toIndexPath, at: .middle, animated: true)
//                })
//            }
//        }
    }
}

extension HabitRankListVM{
    private func prepareLeaderboardData(from array: NSArray) -> NSArray {
        var entries = array.compactMap { $0 as? NSDictionary }
        var placeholderIndex = 1

        while entries.count < 20 {
            let randomScore = Int.random(in: 2...20)
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
    private func animateHighlightMove(from oldIndex: Int, to newIndex: Int) {

        let fromIndexPath = IndexPath(row: oldIndex, section: 0)
        let toIndexPath   = IndexPath(row: newIndex, section: 0)

        guard
            let cell = tableView.cellForRow(at: fromIndexPath),
            let container = tableView.superview
        else { return }
        let snapshot = safeSnapshot(of: cell)
        snapshot.frame = tableView.convert(cell.frame, to: container)
        snapshot.layer.shadowColor = UIColor.black.cgColor
        snapshot.layer.shadowOpacity = 0.25
        snapshot.layer.shadowRadius = 8
        snapshot.layer.cornerRadius = 12
        
//        let containerFrame = container.frame
//        let containerReal = UIView.init(frame: container.frame)
//        containerReal.clipsToBounds = true
//        addSubview(containerReal)
//        insertSubview(containerReal, belowSubview: self.tableView)
//        containerReal.frame = CGRect.init(x: 0, y: self.headVm.selfHeight, width: SCREEN_WIDHT, height: containerFrame.size.height)
//        let snapshotFrame = snapshot.frame
//        snapshot.frame = CGRect.init(x: 0, y: snapshotFrame.origin.y-self.headVm.selfHeight, width: snapshotFrame.size.width, height: snapshotFrame.size.height)

//        containerReal.addSubview(snapshot)
        container.addSubview(snapshot)
        cell.isHidden = true

        let targetRect = tableView.rectForRow(at: toIndexPath)
        var targetFrame = tableView.convert(targetRect, to: container)
        
        if targetFrame.origin.y < self.headVm.selfHeight{
            let targetFrameT = targetFrame
            targetFrame = CGRect.init(x: 0, y: self.headVm.selfHeight, width: targetFrameT.size.width, height: targetFrameT.size.height)
        }

        UIView.animate(withDuration: 0.8, delay: 0, options: [.curveEaseInOut]) {
            snapshot.frame = targetFrame
            self.tableView.scrollRectToVisible(targetRect, animated: false)
        } completion: { _ in

            cell.isHidden = false
            snapshot.removeFromSuperview()

            // 数据一次性归位
            let item = self.displayedDataArray.object(at: oldIndex)
            let mutable = self.displayedDataArray.mutableCopy() as! NSMutableArray
            mutable.removeObject(at: oldIndex)
            mutable.insert(item, at: newIndex)
            self.displayedDataArray = mutable

            UIView.performWithoutAnimation {
                self.tableView.performBatchUpdates {
                    self.tableView.moveRow(at: fromIndexPath, to: toIndexPath)
                } completion: { _ in
                    self.tableView.scrollToRow(at: toIndexPath, at: .middle, animated: true)
                    self.tableView.reloadData()
//                    containerReal.removeFromSuperview()
                }
            }
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
