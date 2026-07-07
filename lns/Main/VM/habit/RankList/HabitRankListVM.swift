//
//  HabitRankListVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/30.
//

import Kingfisher


class HabitRankListVM: UIView {
    
    var selfHeight = kFitWidth(600)
    var controller = WHBaseViewVC()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var dataSourceArray = NSArray()
    private var displayedDataArray = NSArray()
    
    var promotionLine = -1//排名以上的升段
    var relegationLine = -1//排名以下的降段
    
//    private let leaderboardCacheKey = "HabitRankListVM.leaderboardCache"
    public var isCurrentlyVisible = false
    
    //段位变化动画  需要
    private var currentTierIndex: Int = 0
    private var unlockedTierIndex: Int = 0
    private let rankTiers: [RankTier] = RankTier.defaultNine()
    private var isAnimatingToDemo: Bool = false
    private var isAnimatingBackFromDemo: Bool = false
    private var pendingSettlementDict: NSDictionary?
    private var pendingSettlementWeekStartDate: String?
    private var headTierName: String?
    private var pendingFirstUnlockSettlementDict: NSDictionary?
    private var pendingFirstUnlockRankList: NSArray?
    private var pendingFirstUnlockRankIndex: Int?
    private var hasReceivedEmptyLeaderboard = false
    private var shouldMarkFirstUnlockSettlementShown = false
    
    private var rankMoveAnimator: UIViewPropertyAnimator?
    private var isRankMoveAnimating = false
    private var leaderboardRequestID = UUID()
    private var pendingRankMoveFromIndex: Int?
    private var pendingRankMoveToIndex: Int?
    private var isPreparingLeaderboardForDisplay = false
    private var isLeaderboardPreparedForDisplay = false
    private var leaderboardPreparationCompletions: [() -> Void] = []
    var canShowPreparedLeaderboard: Bool {
        return isLeaderboardPreparedForDisplay
    }
    
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
//        let vi = UITableView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight), style: .plain)
        let vi = UITableView(frame: CGRect.init(x: 0, y: self.headCupVm.frame.maxY-kFitWidth(12), width: SCREEN_WIDHT, height: selfHeight-self.headCupVm.selfHeight+kFitWidth(12)), style: .grouped)
        vi.backgroundColor = .COLOR_CARD_BG_WHITE//.COLOR_BG_F2
        
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.clipsToBounds = true
        vi.layer.cornerRadius = kFitWidth(12)
//        if #available(iOS 11.0, *) {
            vi.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        }
        vi.contentInsetAdjustmentBehavior = .never
        vi.estimatedRowHeight = 0
        vi.estimatedSectionHeaderHeight = 0
        vi.estimatedSectionFooterHeight = 0
        vi.sectionHeaderHeight = 0
        vi.sectionFooterHeight = 0

        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        vi.register(HabitRankTableViewCell.classForCoder(), forCellReuseIdentifier: HabitRankTableViewCell.identifier)
        
        return vi
    }()
    lazy var emptyVm: HabitRankListEmptyVM = {
        let vm = HabitRankListEmptyVM.init(frame: CGRect.init(x: 0, y: self.headCupVm.frame.maxY, width: SCREEN_WIDHT, height: selfHeight-self.headCupVm.frame.maxY))
//        vm.togoRecordBlock = {()in
            
//            self.controller.navigationController?.tabBarController?.selectedIndex = 1
//            self.controller.navigationController?.popToRootViewController(animated: true)
//            
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "activePlan"), object: nil)
//        }
        return vm
    }()
    lazy var headCupVm: HabitRankListHeadCupVM = {
        let vm = HabitRankListHeadCupVM.init(frame: .zero)
        vm.backgroundColor = .clear
        vm.pointTapBlock = {()in
            self.rewardPointAlertVm.showSelf()
        }
        
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
    lazy var rewardPointAlertVm: HabitWeeklyRewardPointAlertVM = {
        let vm = HabitWeeklyRewardPointAlertVM.init(frame: .zero)
        return vm
    }()
    lazy var settlementVm: HabitSettleVM = {
        let vm = HabitSettleVM.init(frame: .zero)
        vm.headCupVm = headCupVm

        return vm
    }()
}

private typealias RankMirrorBundle = (
    container: UIView,
    cardView: UIView?,
    shadowHostView: UIView?,
    mirrorCell: HabitRankTableViewCell
)

extension HabitRankListVM{
    func updateUI(dict:NSDictionary) {
        let weekStartDate = dict.stringValueForKey(key: "weekStartDate")
        if weekStartDate.count > 0 &&
            UserDefaults.standard.getTierWeekStartDate() != weekStartDate{
            pendingSettlementDict = dict
            pendingSettlementWeekStartDate = weekStartDate
            updateSettlementVmIfReady()
        }
    }
    
    private func markPendingSettlementShown() {
        guard let weekStartDate = pendingSettlementWeekStartDate,
              weekStartDate.count > 0 else {
            return
        }
        UserDefaults.setTierData(tierStartDate: weekStartDate)
        pendingSettlementWeekStartDate = nil
        pendingSettlementDict = nil
    }

    private func updateSettlementVmIfReady() {
        guard let dict = pendingSettlementDict,
              let headTierName = headTierName else {
            return
        }
        let leaderboard = dict["leaderboard"]as? NSArray ?? []
        let newIndex = (self.indexOfCurrentUser(in: leaderboard) ?? 0) + 1
        let dataArray = self.initialDisplayArray(
            for: leaderboard,
            previousIndex: 0,
            newIndex: newIndex,
            shouldAnimate: false
        )
        
        var point = "0"
        let weeklyRewardPoint = dict["weeklyRewardPoint"]as? NSDictionary ?? [:]
        if newIndex == 1{
            point = weeklyRewardPoint.stringValueForKey(key: "champion")
        }else if newIndex == 2{
            point = weeklyRewardPoint.stringValueForKey(key: "runnerUp")
        }else if newIndex == 3{
            point = weeklyRewardPoint.stringValueForKey(key: "thirdPlace")
        }
        
        var type = RANK_TYPE.REMAIN //默认保持段位不变
        if self.currentTierIndex > dict.stringValueForKey(key: "tier").intValue{
            type = .RISE
        }else if self.currentTierIndex < dict.stringValueForKey(key: "tier").intValue{
            type = .DECLINE
        }
        settlementVm.rankUpType = type
        settlementVm.updateCurrentTier(tier: dict.stringValueForKey(key: "tier").intValue,
                                       sn: newIndex,
                                       point: point,
                                       lastRankName: dict.stringValueForKey(key: "tierName"),
                                       rankName: headTierName,
                                       promotionLine: dict.stringValueForKey(key: "promotionLine").intValue,
                                       rankList: dataArray)
        showSettlementIfNeeded()
    }
    
    private func prepareFirstUnlockSettlementIfNeeded(dataDict: NSDictionary,
                                                      previousSelfIndex: Int?,
                                                      previousLeaderboardCount: Int,
                                                      rankList: NSArray,
                                                      newIndex: Int?) {
        guard hasReceivedEmptyLeaderboard,
              previousSelfIndex == nil,
              previousLeaderboardCount == 0,
              let newIndex = newIndex,
              !UserDefaults.standard.getHabitRankFirstUnlockSettleShown(),
              !settlementVm.hasData else {
            return
        }
        
        pendingFirstUnlockSettlementDict = dataDict
        pendingFirstUnlockRankList = rankList
        pendingFirstUnlockRankIndex = newIndex
        updateFirstUnlockSettlementVmIfReady()
    }
    
    private func updateFirstUnlockSettlementVmIfReady() {
        guard let dict = pendingFirstUnlockSettlementDict,
              let rankList = pendingFirstUnlockRankList,
              let newIndex = pendingFirstUnlockRankIndex,
              rankList.count > 0 else {
            return
        }
        
        let currentTier = dict.stringValueForKey(key: "tier").intValue
        let tierName = dict.stringValueForKey(key: "tierName")
        let settleTier = max(currentTier, 1)
        let settleOldTierName = tierName.count > 0 ? tierName : headTierName ?? ""
        let settleNewTierName = tierName.count > 0 ? tierName : settleOldTierName
        let rankSn = newIndex + 1
        var point = "0"
        let weeklyRewardPoint = dict["weeklyRewardPoint"]as? NSDictionary ?? [:]
        if rankSn == 1{
            point = weeklyRewardPoint.stringValueForKey(key: "champion")
        }else if rankSn == 2{
            point = weeklyRewardPoint.stringValueForKey(key: "runnerUp")
        }else if rankSn == 3{
            point = weeklyRewardPoint.stringValueForKey(key: "thirdPlace")
        }
        
        settlementVm.rankUpType = .FIRST_UNLOCK
        settlementVm.updateCurrentTier(tier: settleTier,
                                       sn: rankSn,
                                       point: point,
                                       lastRankName: settleOldTierName,
                                       rankName: settleNewTierName,
                                       promotionLine: dict.stringValueForKey(key: "promotionLine").intValue,
                                       rankList: rankList)
        shouldMarkFirstUnlockSettlementShown = true
        showSettlementIfNeeded()
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
        dataSourceArray = prepareLeaderboardData(from: dataArray)//cache as NSArray
        displayedDataArray = dataSourceArray
        
        if dataSourceArray.count == 0 {
            sendDataRequest()
        }
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
//            if self.settlementVm.hasData {
//                appDelegate.getKeyWindow().addSubview(settlementVm)
//                UIView.animate(withDuration: 0.15) {
//                    self.settlementVm.alpha = 1
//                }
//            }
            showSettlementIfNeeded()
            playPreparedRankMoveIfNeeded()
        }else if isVisible {
            playPreparedRankMoveIfNeeded()
        }else if !isVisible {
            isCurrentlyVisible = false
        }
    }
    private func showSettlementIfNeeded() {
        guard isCurrentlyVisible,
              settlementVm.hasData,
              settlementVm.superview == nil else {
            return
        }
        appDelegate.getKeyWindow().addSubview(settlementVm)
        markPendingSettlementShown()
        if settlementVm.rankUpType == .FIRST_UNLOCK && shouldMarkFirstUnlockSettlementShown {
            UserDefaults.setHabitRankFirstUnlockSettleShown()
            shouldMarkFirstUnlockSettlementShown = false
        }
        UIView.animate(withDuration: 0.15) {
            self.settlementVm.alpha = 1
        }
    }

    private func reloadLeaderboardAfterPreparingAvatars(completion: (() -> Void)? = nil) {
        preloadLeaderboardAvatars(in: displayedDataArray) { [weak self] in
            guard let self = self else { return }

            UIView.performWithoutAnimation {
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
            }
            completion?()
        }
    }

    private func preloadLeaderboardAvatars(in leaderboard: NSArray,
                                           completion: @escaping () -> Void) {
        var seenURLs = Set<String>()
        var avatarURLs: [String] = []

        for element in leaderboard {
            guard let dict = element as? NSDictionary else { continue }
            let avatarURL = dict.stringValueForKey(key: "headimgurl")
            guard avatarURL.count > 0,
                  !seenURLs.contains(avatarURL) else {
                continue
            }
            seenURLs.insert(avatarURL)
            avatarURLs.append(avatarURL)
        }

        guard avatarURLs.count > 0 else {
            DispatchQueue.main.async {
                completion()
            }
            return
        }

        let group = DispatchGroup()
        var preloaders: [UIImageView] = []

        for avatarURL in avatarURLs {
            group.enter()
            let preloader = UIImageView()
            preloaders.append(preloader)
            preloader.setImgUrlWithComplete(urlString: avatarURL) {
                group.leave()
            }
        }

        var didFinish = false
        let finishOnce = {
            guard !didFinish else { return }
            didFinish = true
            _ = preloaders
            completion()
        }

        group.notify(queue: .main) {
            finishOnce()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            finishOnce()
        }
    }

    private func nextLeaderboardRequestID() -> UUID {
        let requestID = UUID()
        leaderboardRequestID = requestID
        return requestID
    }

    func prepareLeaderboardForDisplay(completion: (() -> Void)? = nil) {
        if isLeaderboardPreparedForDisplay && displayedDataArray.count > 0 {
            completion?()
            return
        }

        if let completion = completion {
            leaderboardPreparationCompletions.append(completion)
        }

        guard !isPreparingLeaderboardForDisplay else {
            return
        }

        isPreparingLeaderboardForDisplay = true
        sendDataRequest(animateSelfChange: true) { [weak self] in
            self?.finishPreparingLeaderboardForDisplay()
        }
    }

    private func finishPreparingLeaderboardForDisplay() {
        isPreparingLeaderboardForDisplay = false
        isLeaderboardPreparedForDisplay = true

        let completions = leaderboardPreparationCompletions
        leaderboardPreparationCompletions.removeAll()
        completions.forEach { $0() }
    }

    private func setPendingRankMove(from oldIndex: Int?, to newIndex: Int?) {
        guard let oldIndex = oldIndex,
              let newIndex = newIndex,
              oldIndex != newIndex else {
            pendingRankMoveFromIndex = nil
            pendingRankMoveToIndex = nil
            return
        }

        pendingRankMoveFromIndex = oldIndex
        pendingRankMoveToIndex = newIndex
    }

    private func scrollRankCellToMiddleIfPossible(section: Int?) {
        guard let section = section,
              displayedDataArray.count > 0 else {
            return
        }

        let targetSection = min(max(0, section), displayedDataArray.count - 1)
        let indexPath = IndexPath(row: 0, section: targetSection)

        UIView.performWithoutAnimation {
            tableView.layoutIfNeeded()
            let rect = tableView.rectForRow(at: indexPath)
            let offset = endContentOffsetToShow(rect: rect, position: .middle)
            tableView.setContentOffset(offset, animated: false)
            tableView.layoutIfNeeded()
        }
    }

    private func playPreparedRankMoveIfNeeded() {
        guard let fromIndex = pendingRankMoveFromIndex,
              let toIndex = pendingRankMoveToIndex else {
            return
        }

        pendingRankMoveFromIndex = nil
        pendingRankMoveToIndex = nil
        performSelfRankMove(from: fromIndex, to: toIndex)
    }
}
extension HabitRankListVM:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        emptyVm.isHidden = displayedDataArray.count > 0
        return displayedDataArray.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == promotionLine{
            return upDegreeeVm.selfHeight
        }else if section == relegationLine - 1{
            return downDegreeeVm.selfHeight
        }
        return CGFloat.leastNormalMagnitude//section > 0 ? kFitWidth(25) : 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == promotionLine{
            return upDegreeeVm
        }else if section == relegationLine - 1{
            return downDegreeeVm
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
            score: dict.stringValueForKey(key: "rankPointBalance"),
            isCurrentUser: isCurrentUser(dict)
        )
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(70)
    }
}

extension HabitRankListVM{
    func initUI() {
        addSubview(headCupVm)
        addSubview(tableView)
        addSubview(emptyVm)
        
//        tableView.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(12))
        
        appDelegate.getKeyWindow().addSubview(rewardPointAlertVm)
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
    private func transitionDisplayArray(for leaderboard: NSArray,
                                        previousIndex: Int?,
                                        newIndex: Int?,
                                        preservedSelfEntry: NSDictionary?) -> NSArray {
        guard leaderboard.count > 0,
              let mutable = leaderboard.mutableCopy() as? NSMutableArray else {
            return leaderboard
        }

        guard let newIndex,
              newIndex >= 0,
              newIndex < mutable.count else {
            return leaderboard
        }

        let selfEntry = preservedSelfEntry ?? (mutable.object(at: newIndex) as? NSDictionary ?? [:])
        mutable.removeObject(at: newIndex)

        let targetIndex: Int
        if let previousIndex, previousIndex >= 0 {
            targetIndex = max(0, min(previousIndex, mutable.count))
        } else {
            targetIndex = max(0, min(newIndex, mutable.count))
        }

        mutable.insert(selfEntry, at: targetIndex)
        return mutable
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
//        
//        DispatchQueue.main.async {
//            let fromIndexPath = IndexPath(row: 0, section: oldIndex)
//
//            self.tableView.layoutIfNeeded()
//
//            // ✅ 用 rect + clamp 算 offset，避免 scrollToRow 在估算高度时产生空白
//            guard oldIndex < self.displayedDataArray.count else { return }
//            let fromRect = self.tableView.rectForRow(at: fromIndexPath)
//            let offset = self.endContentOffsetToShow(rect: fromRect, position: .middle)
//            self.tableView.setContentOffset(offset, animated: false)
//            self.tableView.layoutIfNeeded()
//        }
//        guard let newIndex, oldIndex != newIndex else { return }
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
//            self.waitUntilAvatarReadyForHighlight(at: oldIndex, timeout: 1.0) { [weak self] avatarImage in
//                guard let self = self else { return }
//                self.animateHighlightMove3Stage(from: oldIndex,
//                                                to: newIndex,
//                                                extraVertical: 0,
//                                                avatarOverride: avatarImage)
//            }
//        })
//    }
    private func performSelfRankMove(from oldIndex: Int?, to newIndex: Int?) {
        DLLog(message: "移动前后Index: \(oldIndex ?? -1) 到 \(newIndex ?? -1)")
        guard let oldIndex = oldIndex else { return }

        DispatchQueue.main.async {
            guard oldIndex >= 0,
                  oldIndex < self.displayedDataArray.count else {
                return
            }

            self.tableView.layoutIfNeeded()

            let fromIndexPath = IndexPath(row: 0, section: oldIndex)
            let fromRect = self.tableView.rectForRow(at: fromIndexPath)
            let startOffset = self.endContentOffsetToShow(rect: fromRect, position: .middle)

            UIView.performWithoutAnimation {
                self.tableView.setContentOffset(startOffset, animated: false)
                self.tableView.layoutIfNeeded()
            }

            guard let newIndex = newIndex,
                  newIndex >= 0,
                  newIndex < self.dataSourceArray.count,
                  oldIndex != newIndex else {
                UIView.performWithoutAnimation {
                    self.displayedDataArray = self.dataSourceArray
                    self.tableView.reloadData()
                    self.tableView.layoutIfNeeded()
                }
                return
            }

//            DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
//                self.animateHighlightMove3Stage(from: oldIndex,
//                                                to: newIndex,
//                                                extraVertical: 0,
//                                                avatarOverride: avatarImage)
//            })
            DispatchQueue.main.async {
                self.animateHighlightMove3Stage(from: oldIndex,
                                                to: newIndex,
                                                extraVertical: 0,
                                                avatarOverride: nil)
            }
        }
    }
    private func waitUntilAvatarReadyForHighlight(at index: Int,
                                                   timeout: TimeInterval = 1.0,
                                                   completion: @escaping (UIImage?) -> Void) {
        guard index >= 0, index < displayedDataArray.count else {
            completion(nil)
            return
        }
        
        let dict = displayedDataArray[index] as? NSDictionary ?? [:]
        let avatarURL = dict.stringValueForKey(key: "headimgurl")
        guard avatarURL.count > 0 else {
            completion(nil)
            return
        }
        
        let indexPath = IndexPath(row: 0, section: index)
        if let cell = tableView.cellForRow(at: indexPath) as? HabitRankTableViewCell,
           let avatar = cell.currentAvatarImage() {
            completion(avatar)
            return
        }
        
        var isFinished = false
        let finish: (UIImage?) -> Void = { image in
            guard !isFinished else { return }
            isFinished = true
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        let preloader = UIImageView()
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            finish(preloader.image)
        }
        
        preloader.setImgUrlWithComplete(urlString: avatarURL) {
            finish(preloader.image)
        }
    }
}

extension HabitRankListVM{
    //MARK: 造假数据
    private func prepareLeaderboardData(from array: NSArray) -> NSArray {
        return array
//        var entries = array.compactMap { $0 as? NSDictionary }
//        var placeholderIndex = 1
//
//        while entries.count < 20 {
//            let randomScore = Int.random(in: 1...8)
//            let placeholder: NSDictionary = [
//                "headimgurl": "",
//                "nickname": "Tester \(placeholderIndex)",
//                "donateCount": 0,
//                "rankPointBalance": "\(randomScore)"
//            ]
//            entries.append(placeholder)
//            placeholderIndex += 1
//        }
//
//        let sortedEntries = entries.sorted {
//            $0.stringValueForKey(key: "rankPointBalance").intValue > $1.stringValueForKey(key: "rankPointBalance").intValue
//        }
//
//        return Array(sortedEntries.prefix(20)) as NSArray
    }
}

extension HabitRankListVM {
    /// ⭐️ 三段式（不贴边、不回头）：Lift → Move+Scroll → Drop
//    private func animateHighlightMove3Stage(from oldIndex: Int,
//                                            to newIndex: Int,
//                                            extraVertical: CGFloat = 20,
//                                            avatarOverride: UIImage? = nil) {
//
//        let fromIndexPath = IndexPath(row: 0, section: oldIndex)
//        let toIndexPath   = IndexPath(row: 0, section: newIndex)
//
//        guard
//            oldIndex != newIndex,
//            displayedDataArray.count > 0,
//            oldIndex >= 0, oldIndex < displayedDataArray.count,
//            newIndex >= 0, newIndex < displayedDataArray.count,
//            let fromCell = tableView.cellForRow(at: fromIndexPath),
//            let container = tableView.superview
//        else { return }
//
//        tableView.layoutIfNeeded()
//
//        // ✅ overlay：裁剪区域 = tableView 可视区域
//        let overlay = UIView(frame: tableView.frame)
//        overlay.backgroundColor = .clear
//        overlay.isUserInteractionEnabled = false
//        overlay.clipsToBounds = true
//        container.addSubview(overlay)
//
//        // ✅ 高亮卡片（外扩上下 extraVertical）
////        let highlightView = makeHighlightSnapshotView(from: fromCell, extraVertical: extraVertical)
//        let highlightView: UIView
//        if let habitCell = fromCell as? HabitRankTableViewCell {
//            highlightView = makeHighlightMirrorCellView(from: oldIndex,
//                                                        fromCell: habitCell,
//                                                        extraVertical: extraVertical,
//                                                        avatarOverride: avatarOverride)
//        } else {
//            highlightView = makeHighlightSnapshotView(from: fromCell, extraVertical: extraVertical)
//        }
//
//        let startOffset = tableView.contentOffset
//        let startCellFrameInOverlay = tableView.convert(fromCell.frame, to: overlay)
//        var startFrame = startCellFrameInOverlay.insetBy(dx: 0, dy: -extraVertical)
//        startFrame = clamp(frame: startFrame, inside: overlay.bounds, margin: 2)
//
//        highlightView.frame = startFrame
//        overlay.addSubview(highlightView)
//
//        // 隐藏源 cell（⚠️记得在 cellForRowAt 里强制 cell.isHidden=false 防复用）
//        fromCell.isHidden = true
//
//        // 目标 rect（content 坐标）
//        let targetRectInContent = tableView.rectForRow(at: toIndexPath)
//
//        // ✅ 关键：算一个 endOffset，让“扩高后的高亮卡片”也能完整显示在可视区
//        let endOffset = endContentOffsetToFullyShow(rect: targetRectInContent,
//                                                    extraVertical: extraVertical)
//
//        // endFrame（overlay 坐标）= contentRect - endOffset
//        var endFrame = targetRectInContent.offsetBy(dx: -endOffset.x, dy: -endOffset.y)
//        endFrame = endFrame.insetBy(dx: 0, dy: -extraVertical)
//        endFrame.size.width = startFrame.size.width
//        endFrame.origin.x = startFrame.origin.x
//        endFrame = clamp(frame: endFrame, inside: overlay.bounds, margin: 2)
//
//        // 动画期间禁用交互，避免用户滚动打断
//        tableView.isUserInteractionEnabled = false
//        tableView.isScrollEnabled = false
//
//        // 时长：滚动越远段2越长
//        let distance = abs(endOffset.y - startOffset.y)
//        let liftDuration: TimeInterval = 0.16
//        let moveDuration: TimeInterval = (distance < 30) ? 0.22 : min(max(distance / 900.0, 0.45), 0.95)
//        let dropDuration: TimeInterval = 0.16
//
//        // --- 段1：Lift（只放大，不“跑到边缘”）
//        UIView.animate(withDuration: liftDuration,
//                       delay: 0,
//                       usingSpringWithDamping: 0.85,
//                       initialSpringVelocity: 0.6,
//                       options: [.curveEaseInOut, .beginFromCurrentState]) {
//            highlightView.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
//        } completion: { _ in
//
//            // --- 段2：Move + Scroll（同时从 start -> end，路径直达，不回头）
////            let moveAnimator = UIViewPropertyAnimator(duration: moveDuration, curve: .easeInOut) {
////                self.tableView.contentOffset = endOffset
////                highlightView.frame = endFrame
////            }
////
////            moveAnimator.addCompletion { _ in
//            // --- 段2：Move + Scroll（系统滚动更稳，避免远距离出现空白）
//            CATransaction.begin()
//            CATransaction.setAnimationDuration(moveDuration)
//            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
//            CATransaction.setCompletionBlock {
//
//                // --- 段3：Drop（只回到正常 scale，不改位置）
//                UIView.animate(withDuration: dropDuration,
//                               delay: 0,
//                               usingSpringWithDamping: 0.85,
//                               initialSpringVelocity: 0.7,
//                               options: [.curveEaseInOut, .beginFromCurrentState]) {
//                    highlightView.transform = .identity
//                } completion: { _ in
//
//                    // ✅ 动画结束：数据归位 + moveSection + 刷新
//                    let item = self.displayedDataArray.object(at: oldIndex)
//                    let mutable = self.displayedDataArray.mutableCopy() as! NSMutableArray
//                    mutable.removeObject(at: oldIndex)
//                    mutable.insert(item, at: newIndex)
//                    self.displayedDataArray = mutable
//
//                    UIView.performWithoutAnimation {
//                        self.tableView.performBatchUpdates({
//                            self.tableView.moveSection(oldIndex, toSection: newIndex)
//                        }, completion: { _ in
//                            // 固定最终滚动位置，避免 batchUpdates 后抖动/空白
//                            self.tableView.setContentOffset(endOffset, animated: false)
//
//                            // 只刷新受影响区间（比 reloadData 更稳更轻）
//                            let lo = min(oldIndex, newIndex)
//                            let hi = max(oldIndex, newIndex)
//                            self.tableView.reloadSections(IndexSet(integersIn: lo...hi), with: .none)
//
//                            // 还原
//                            fromCell.isHidden = false
//                            overlay.removeFromSuperview()
//
//                            self.tableView.isScrollEnabled = true
//                            self.tableView.isUserInteractionEnabled = true
//                        })
//                    }
//                }
//            }
//
////            moveAnimator.startAnimation()
//            self.tableView.setContentOffset(endOffset, animated: true)
//            UIView.animate(withDuration: moveDuration,
//                           delay: 0,
//                           options: [.curveEaseInOut, .beginFromCurrentState]) {
//                highlightView.frame = endFrame
//            }
//            CATransaction.commit()
//        }
//    }
    private func animateHighlightMove3Stage(from oldIndex: Int,
                                            to newIndex: Int,
                                            extraVertical: CGFloat = 0,
                                            avatarOverride: UIImage? = nil) {

        guard oldIndex != newIndex,
              displayedDataArray.count > 0,
              oldIndex >= 0,
              oldIndex < displayedDataArray.count,
              newIndex >= 0,
              newIndex < displayedDataArray.count,
              let container = tableView.superview else {
            UIView.performWithoutAnimation {
                self.displayedDataArray = self.dataSourceArray
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
            }
            return
        }

        guard !isRankMoveAnimating else { return }

        tableView.layoutIfNeeded()

        let fromIndexPath = IndexPath(row: 0, section: oldIndex)
        let toIndexPath = IndexPath(row: 0, section: newIndex)

        guard let fromCell = tableView.cellForRow(at: fromIndexPath) as? HabitRankTableViewCell else {
            UIView.performWithoutAnimation {
                self.displayedDataArray = self.dataSourceArray
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
            }
            return
        }

        isRankMoveAnimating = true

        let finalDataArray = dataSourceArray.copy() as? NSArray ?? dataSourceArray

        let startOffset = tableView.contentOffset
        let targetRect = tableView.rectForRow(at: toIndexPath)
        let endOffset = endContentOffsetToFullyShow(rect: targetRect, extraVertical: extraVertical)

        let overlay = UIView(frame: tableView.frame)
        overlay.backgroundColor = .clear
        overlay.isUserInteractionEnabled = false
        overlay.clipsToBounds = true
        container.addSubview(overlay)

        var hiddenCells: [UITableViewCell] = []
        var shiftedSnapshots: [(view: UIView, endFrame: CGRect)] = []

        let hideCell: (UITableViewCell) -> Void = { cell in
            if !hiddenCells.contains(where: { $0 === cell }) {
                cell.isHidden = true
                hiddenCells.append(cell)
            }
        }

        let lower = min(oldIndex, newIndex)
        let upper = max(oldIndex, newIndex)
        let changedSections = IndexSet(integersIn: lower...upper)
        for sourceSection in lower...upper {
            guard sourceSection != oldIndex else {
                continue
            }

            let targetSection: Int
            if oldIndex < newIndex {
                targetSection = sourceSection - 1
            } else {
                targetSection = sourceSection + 1
            }

            guard targetSection >= 0,
                  targetSection < displayedDataArray.count else {
                continue
            }

            let indexPath = IndexPath(row: 0, section: sourceSection)
            let cell = tableView.cellForRow(at: indexPath) as? HabitRankTableViewCell
            let startFrame = frameForRankRow(section: sourceSection,
                                             contentOffset: startOffset,
                                             extraVertical: 0)
            let endFrame = frameForRankRow(section: targetSection,
                                           contentOffset: endOffset,
                                           extraVertical: 0)

            let snapshot = makeRankMirrorView(dataIndex: sourceSection,
                                              displayRank: sourceSection + 1,
                                              baseCell: cell,
                                              extraVertical: 0,
                                              avatarOverride: cell?.currentAvatarImage(),
                                              wrapped: false,
                                              elevated: false)

            snapshot.container.frame = startFrame
            overlay.addSubview(snapshot.container)

            if let cell = cell {
                hideCell(cell)
            }
            shiftedSnapshots.append((view: snapshot.container, endFrame: endFrame))
        }

        let movingStartFrame = frameForRankRow(section: oldIndex,
                                               contentOffset: startOffset,
                                               extraVertical: extraVertical)

        let movingEndFrame = frameForRankRow(section: newIndex,
                                             contentOffset: endOffset,
                                             extraVertical: extraVertical)

        let movingBundle = makeRankMirrorView(dataIndex: oldIndex,
                                              displayRank: oldIndex + 1,
                                              baseCell: fromCell,
                                              extraVertical: extraVertical,
                                              avatarOverride: avatarOverride ?? fromCell.currentAvatarImage(),
                                              wrapped: true,
                                              elevated: false)

        let movingView = movingBundle.container
        movingView.frame = movingStartFrame
        overlay.addSubview(movingView)
        overlay.bringSubviewToFront(movingView)

        hideCell(fromCell)

        tableView.isUserInteractionEnabled = false
        tableView.isScrollEnabled = false

        let moveDuration = rankMoveDuration(startFrame: movingStartFrame,
                                            endFrame: movingEndFrame,
                                            startOffset: startOffset,
                                            endOffset: endOffset)
        let rankRefreshDuration: TimeInterval = 0.28
        let liftDuration: TimeInterval = 0.18
        let landingDuration: TimeInterval = 0.18
        let liftedTransform = CGAffineTransform(translationX: 0, y: -kFitWidth(6))
            .scaledBy(x: 1.02, y: 1.02)
        let liftedVisualView = movingBundle.cardView ?? movingBundle.mirrorCell

        let updateLiftedStyle: (Bool) -> Void = { lifted in
            let targetCornerRadius = lifted ? CGFloat(0) : kFitWidth(12)
            movingBundle.cardView?.layer.cornerRadius = targetCornerRadius
            movingBundle.shadowHostView?.layer.cornerRadius = targetCornerRadius
            movingBundle.shadowHostView?.layer.shadowColor = UIColor.black.cgColor
            movingBundle.shadowHostView?.layer.shadowRadius = lifted ? 12 : 8
            movingBundle.shadowHostView?.layer.shadowOffset = lifted ? CGSize(width: 0, height: 8) : CGSize(width: 0, height: 4)
            movingBundle.shadowHostView?.layer.shadowOpacity = lifted ? 0.2 : 0
        }

        let finishAnimation: () -> Void = { [weak self] in
            guard let self = self else { return }

            for cell in hiddenCells {
                cell.isHidden = false
                cell.alpha = 1
                cell.contentView.alpha = 1
            }

            UIView.performWithoutAnimation {
                self.displayedDataArray = finalDataArray
                self.tableView.reloadSections(changedSections, with: .none)
                self.tableView.layoutIfNeeded()
                self.tableView.setContentOffset(endOffset, animated: false)
                self.tableView.layoutIfNeeded()
            }

            self.animateVisibleRankRefresh(changedSections: changedSections)

            UIView.animate(withDuration: 0.18,
                           delay: 0,
                           options: [.curveEaseOut, .beginFromCurrentState]) {
                overlay.alpha = 0
            } completion: { _ in
                overlay.removeFromSuperview()
            }

            self.tableView.isScrollEnabled = true
            self.tableView.isUserInteractionEnabled = true

            self.rankMoveAnimator = nil
            self.isRankMoveAnimating = false
        }

        let startMoveStage: () -> Void = { [weak self] in
            guard let self = self else { return }

            let timing = UISpringTimingParameters(dampingRatio: 1.0,
                                                  initialVelocity: CGVector(dx: 0, dy: 0))
            let animator = UIViewPropertyAnimator(duration: moveDuration, timingParameters: timing)
            self.rankMoveAnimator = animator

            animator.addAnimations {
                self.tableView.setContentOffset(endOffset, animated: false)
                movingView.frame = movingEndFrame

                for item in shiftedSnapshots {
                    item.view.frame = item.endFrame
                }
            }

            animator.addCompletion { _ in
                UIView.animate(withDuration: landingDuration,
                               delay: 0,
                               options: [.curveEaseOut, .beginFromCurrentState]) {
                    liftedVisualView.transform = .identity
                    updateLiftedStyle(false)
                } completion: { _ in
                    finishAnimation()
                }
            }

            animator.startAnimation()
        }

        let startLiftStage: () -> Void = {
            UIView.animate(withDuration: liftDuration,
                           delay: 0,
                           options: [.curveEaseOut, .beginFromCurrentState]) {
                liftedVisualView.transform = liftedTransform
                updateLiftedStyle(true)
            } completion: { _ in
                startMoveStage()
            }
        }

        movingBundle.mirrorCell.animateRankTransition(to: newIndex + 1,
                                                      duration: rankRefreshDuration) {
            startLiftStage()
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
    private func frameForRankRow(section: Int,
                                 contentOffset: CGPoint,
                                 extraVertical: CGFloat,
                                 forcedX: CGFloat? = nil,
                                 forcedWidth: CGFloat? = nil) -> CGRect {

        let maxSection = max(displayedDataArray.count - 1, 0)
        let safeSection = max(0, min(section, maxSection))
        let rect = tableView.rectForRow(at: IndexPath(row: 0, section: safeSection))

        var frame = CGRect(x: rect.minX - contentOffset.x,
                           y: rect.minY - contentOffset.y - extraVertical,
                           width: rect.width,
                           height: rect.height + extraVertical * 2)

        if let forcedX = forcedX {
            frame.origin.x = forcedX
        }

        if let forcedWidth = forcedWidth {
            frame.size.width = forcedWidth
        }

        return frame
    }

    private func rankMoveDuration(startFrame: CGRect,
                                  endFrame: CGRect,
                                  startOffset: CGPoint,
                                  endOffset: CGPoint) -> TimeInterval {

        let visualDistance = abs(endFrame.midY - startFrame.midY)
        let scrollDistance = abs(endOffset.y - startOffset.y)
        let distance = max(visualDistance, scrollDistance)

        let visibleHeight = max(tableView.bounds.height, 1)
        let normalized = min(distance / visibleHeight, 1)

        let duration = 0.34 + TimeInterval(normalized) * 0.28
        return min(max(duration, 0.34), 0.72)
    }

    private func makeRankMirrorView(dataIndex: Int,
                                    displayRank: Int,
                                    baseCell: HabitRankTableViewCell?,
                                    extraVertical: CGFloat,
                                    avatarOverride: UIImage?,
                                    wrapped: Bool,
                                    elevated: Bool) -> RankMirrorBundle {
        guard displayedDataArray.count > 0 else {
            let mirror = HabitRankTableViewCell(style: .default, reuseIdentifier: nil)
            return (mirror, nil, nil, mirror)
        }

        let maxIndex = displayedDataArray.count - 1
        let safeIndex = max(0, min(dataIndex, maxIndex))
        let dict = displayedDataArray.object(at: safeIndex) as? NSDictionary ?? [:]

        let cellWidth = baseCell?.bounds.width ?? tableView.bounds.width
        let cellHeight = baseCell?.bounds.height ?? kFitWidth(70)

        let mirror = HabitRankTableViewCell(style: .default, reuseIdentifier: nil)
        mirror.frame = CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight)
        mirror.isUserInteractionEnabled = false

        let avatarURL = dict.stringValueForKey(key: "headimgurl")
        mirror.configure(rank: "\(displayRank)",
                         avatar: avatarURL,
                         name: dict.stringValueForKey(key: "nickname"),
                         fireCount: dict.stringValueForKey(key: "donateCount").intValue,
                         score: dict.stringValueForKey(key: "rankPointBalance"),
                         needAvatarTransition: false,
                         isCurrentUser: isCurrentUser(dict))

        if let image = ImageCache.default.retrieveImageInMemoryCache(forKey: avatarURL) ?? avatarOverride ?? baseCell?.currentAvatarImage() {
            mirror.applyAvatarImage(image)
        }

        mirror.setNeedsLayout()
        mirror.layoutIfNeeded()
        mirror.contentView.setNeedsLayout()
        mirror.contentView.layoutIfNeeded()

        guard wrapped || elevated || extraVertical > 0 else {
            return (mirror, nil, nil, mirror)
        }

        let innerHeight = cellHeight + extraVertical * 2

        let inner = UIView(frame: CGRect(x: 0,
                                         y: 0,
                                         width: cellWidth,
                                         height: innerHeight))
        inner.backgroundColor = .COLOR_CELL_HIGHLIGHT_BG
        inner.layer.cornerRadius = kFitWidth(12)
        inner.clipsToBounds = true
        inner.isUserInteractionEnabled = false

        mirror.frame = CGRect(x: 0,
                              y: extraVertical,
                              width: cellWidth,
                              height: cellHeight)
        inner.addSubview(mirror)

        let outer = UIView(frame: inner.bounds)
        outer.backgroundColor = .clear
        outer.isUserInteractionEnabled = false
        outer.layer.cornerRadius = kFitWidth(12)
        outer.layer.shadowColor = UIColor.black.cgColor
        outer.layer.shadowOpacity = elevated ? 0.16 : 0
        outer.layer.shadowRadius = elevated ? 10 : 8
        outer.layer.shadowOffset = elevated ? CGSize(width: 0, height: 5) : CGSize(width: 0, height: 4)

        outer.addSubview(inner)
        return (outer, inner, outer, mirror)
    }

    private func animateVisibleRankRefresh(changedSections: IndexSet) {
        let visibleRankCells = tableView.visibleCells
            .compactMap { $0 as? HabitRankTableViewCell }
            .filter { cell in
                guard let section = tableView.indexPath(for: cell)?.section else { return false }
                return changedSections.contains(section)
            }
            .sorted { lhs, rhs in
                let lhsSection = tableView.indexPath(for: lhs)?.section ?? 0
                let rhsSection = tableView.indexPath(for: rhs)?.section ?? 0
                return lhsSection < rhsSection
            }

        for (index, cell) in visibleRankCells.enumerated() {
            let delay = min(TimeInterval(index) * 0.035, 0.18)
            cell.animateRankRefreshReveal(delay: delay)
        }
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
                                             extraVertical: CGFloat,
                                             avatarOverride: UIImage?) -> UIView {

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
            needAvatarTransition: false , // ✅ 高亮不fade，像拖拽
            isCurrentUser: isCurrentUser(dict)
        )
        // 优先使用已就绪头像，避免弱网下高亮移动时头像空白
        if let image = avatarOverride ?? fromCell.currentAvatarImage() {
            mirror.applyAvatarImage(image)
        }

        mirror.layoutIfNeeded()

        // 包装成上下+20的高亮卡片（你之前那套）
        let inner = UIView(frame: CGRect(x: 0, y: 0,
                                         width: mirror.bounds.width,
                                         height: mirror.bounds.height + extraVertical * 2))
        inner.backgroundColor = .COLOR_CELL_HIGHLIGHT_BG
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

extension HabitRankListVM{
    func sendDataRequest(animateSelfChange: Bool = false,
                         completion: (() -> Void)? = nil){
        if !animateSelfChange {
            isLeaderboardPreparedForDisplay = false
        }
        let previousLeaderboard = displayedDataArray.count > 0 ? displayedDataArray : dataSourceArray
        let previousSelfIndex = indexOfCurrentUser(in: previousLeaderboard)
        let requestID = nextLeaderboardRequestID()
        WHNetworkUtil.shareManager().POST(urlString: URL_user_habit_leaderboard, parameters: nil,isNeedToast: true,vc: self.controller) { responseObject in
            guard self.leaderboardRequestID == requestID else { return }
            
            let code = responseObject["code"]as? Int ?? -1
            if code == 200 {
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
                DLLog(message: "sendDataRequest:\(dataDict)")
                self.headCupVm.setCurrentTier(tier: self.currentTierIndex,
                                              tierName: dataDict.stringValueForKey(key: "tierName"))
                let weeklyRewardPoint = dataDict["weeklyRewardPoint"]as? NSDictionary ?? [:]
                if weeklyRewardPoint.stringValueForKey(key: "champion").count > 0 {
                    self.headCupVm.updateUI(champion: weeklyRewardPoint.stringValueForKey(key: "champion"),
                                    runnerUp: weeklyRewardPoint.stringValueForKey(key: "runnerUp"),
                                    thirdPlace: weeklyRewardPoint.stringValueForKey(key: "thirdPlace"),
                                     secondsToWeekEnd:dataDict.stringValueForKey(key: "secondsToWeekEnd").intValue)
                }
                if (dataDict["leaderboard"]as? NSArray ?? []).count > 0 {
                    self.dataSourceArray = self.prepareLeaderboardData(from: dataDict["leaderboard"]as? NSArray ?? [])
                    self.cacheLeaderboard(self.dataSourceArray)
                    let newIndex = self.indexOfCurrentUser(in: self.dataSourceArray)
                    self.prepareFirstUnlockSettlementIfNeeded(dataDict: dataDict,
                                                              previousSelfIndex: previousSelfIndex,
                                                              previousLeaderboardCount: previousLeaderboard.count,
                                                              rankList: self.dataSourceArray,
                                                              newIndex: newIndex)
                    
                    if animateSelfChange {
                        self.promotionLine = dataDict.stringValueForKey(key: "promotionLine").intValue
                        self.relegationLine = dataDict.stringValueForKey(key: "relegationLine").intValue
                        self.displayedDataArray = self.transitionDisplayArray(for: self.dataSourceArray,
                                                                             previousIndex: previousSelfIndex,
                                                                             newIndex: newIndex,
                                                                             preservedSelfEntry: nil)
                        self.reloadLeaderboardAfterPreparingAvatars {
                            self.setPendingRankMove(from: previousSelfIndex, to: newIndex)
                            self.scrollRankCellToMiddleIfPossible(section: previousSelfIndex ?? newIndex)
                            completion?()
                        }
                    }else{
                        self.displayedDataArray = self.dataSourceArray
                        self.reloadLeaderboardAfterPreparingAvatars {
                            guard let oldIndex = previousSelfIndex,
                                  self.displayedDataArray.count > 0 else {
                                completion?()
                                return
                            }
                            let targetSection = min(max(0, oldIndex), self.displayedDataArray.count - 1)
                            let fromIndexPath = IndexPath(row: 0, section: targetSection)

                            self.tableView.layoutIfNeeded()
                            self.tableView.scrollToRow(at: fromIndexPath, at: .middle, animated: true)
                            self.tableView.layoutIfNeeded()
                            completion?()
                        }
                    }
                }else{
                    self.hasReceivedEmptyLeaderboard = true
                    self.dataSourceArray = NSArray()
                    self.cacheLeaderboard(self.dataSourceArray)
                    self.displayedDataArray = self.dataSourceArray
                    UIView.performWithoutAnimation {
                        self.tableView.reloadData()
                        self.tableView.layoutIfNeeded()
                    }
                    completion?()
                }
            }
            else{
                self.dataSourceArray = NSArray()
//                self.cacheLeaderboard(self.dataSourceArray)
                self.displayedDataArray = self.dataSourceArray
                UIView.performWithoutAnimation {
                    self.tableView.reloadData()
                    self.tableView.layoutIfNeeded()
                }
                completion?()
            }
        }
    }
    func sendDataRequestForHeadMsg(){
        isPreparingLeaderboardForDisplay = true
        isLeaderboardPreparedForDisplay = false
        let requestID = nextLeaderboardRequestID()
        WHNetworkUtil.shareManager().POST(urlString: URL_user_habit_leaderboard, parameters: nil,isNeedToast: true,vc: self.controller) { responseObject in
            guard self.leaderboardRequestID == requestID else { return }

            let code = responseObject["code"]as? Int ?? -1
            if code == 200 {
                let previousLeaderboard = self.displayedDataArray.count > 0 ? self.displayedDataArray : self.dataSourceArray
                let previousSelfIndex = self.indexOfCurrentUser(in: previousLeaderboard)
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
                DLLog(message: "sendDataRequest:\(dataDict)")
                UserDefaults.setTierData(tier: dataDict.stringValueForKey(key: "tier"), isRefresh: false)
                self.currentTierIndex = dataDict.stringValueForKey(key: "tier").intValue
                self.headCupVm.setCurrentTier(tier: dataDict.stringValueForKey(key: "tier").intValue, tierName: dataDict.stringValueForKey(key: "tierName"))
//                DispatchQueue.main.asyncAfter(deadline: .now()+10, execute: {
                    self.headTierName = dataDict.stringValueForKey(key: "tierName")
                    self.updateSettlementVmIfReady()
                    self.updateFirstUnlockSettlementVmIfReady()
//                })
                
                let weeklyRewardPoint = dataDict["weeklyRewardPoint"]as? NSDictionary ?? [:]
                if weeklyRewardPoint.stringValueForKey(key: "champion").count > 0 {
                    self.headCupVm.updateUI(champion: weeklyRewardPoint.stringValueForKey(key: "champion"),
                                    runnerUp: weeklyRewardPoint.stringValueForKey(key: "runnerUp"),
                                    thirdPlace: weeklyRewardPoint.stringValueForKey(key: "thirdPlace"),
                                     secondsToWeekEnd:dataDict.stringValueForKey(key: "secondsToWeekEnd").intValue)
                }
                if (dataDict["leaderboard"]as? NSArray ?? []).count > 0 {
                    self.promotionLine = dataDict.stringValueForKey(key: "promotionLine").intValue
                    self.relegationLine = dataDict.stringValueForKey(key: "relegationLine").intValue
                    self.dataSourceArray = self.prepareLeaderboardData(from: dataDict["leaderboard"]as? NSArray ?? [])
                    self.cacheLeaderboard(self.dataSourceArray)
                    let newIndex = self.indexOfCurrentUser(in: self.dataSourceArray)
                    self.prepareFirstUnlockSettlementIfNeeded(dataDict: dataDict,
                                                              previousSelfIndex: previousSelfIndex,
                                                              previousLeaderboardCount: previousLeaderboard.count,
                                                              rankList: self.dataSourceArray,
                                                              newIndex: newIndex)
                    self.displayedDataArray = self.transitionDisplayArray(for: self.dataSourceArray,
                                                                         previousIndex: previousSelfIndex,
                                                                         newIndex: newIndex,
                                                                         preservedSelfEntry: nil)
                    self.reloadLeaderboardAfterPreparingAvatars {
                        self.setPendingRankMove(from: previousSelfIndex, to: newIndex)
                        self.scrollRankCellToMiddleIfPossible(section: previousSelfIndex ?? newIndex)
                        self.finishPreparingLeaderboardForDisplay()
                    }
                }else{
                    self.hasReceivedEmptyLeaderboard = true
                    self.dataSourceArray = NSArray()
                    self.displayedDataArray = self.dataSourceArray
                    UIView.performWithoutAnimation {
                        self.tableView.reloadData()
                        self.tableView.layoutIfNeeded()
                    }
                    self.finishPreparingLeaderboardForDisplay()
                    return
                }
            }else{
                UIView.performWithoutAnimation {
                    self.tableView.reloadData()
                    self.tableView.layoutIfNeeded()
                }
                self.finishPreparingLeaderboardForDisplay()
            }
        }
    }
}
