//
//  JournalReportDailyMsgVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/12.
//

class JournalReportDailyMsgVM: UIView {
    
    var controller = WHBaseViewVC()
    var selfHeight = kFitWidth(44)
    var detailDict = NSDictionary()
    var reportMsgDict = NSDictionary()
    var shouldShowNutritionOnlyWhenDailyReportNoData = false
    var tableHeight = kFitWidth(0)
    private var isDailyReportLoading = false
    private var dailyReportLoadingStartTime: TimeInterval = 0
    private let minDailyReportSkeletonDuration: TimeInterval = 0.35
    private var pendingScrollToNutritionDetail = false
    private var pendingScrollToNutritionDetailAnimated = false
    private var didReceiveDailyReportNoData = false
    private var dailyReportNoDataMessage = "请先记录至少一种食物"
    private var isShowingNutritionNoProOnlyForDailyNoData = false
    private var isWaitingForDailyReportDisplayDecision = false
    private var isHoldingContentForInitialNutritionScroll = false
    private var hasTrackedDailyOtherNutritionPageView = false
    
    var offsetChangeBlock:((CGFloat)->())?
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle == .dark{
            self.backgroundColor = .COLOR_BG_WHITE
        }else{
            self.backgroundColor = .COLOR_BG_F5
        }
    }
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        
        if traitCollection.userInterfaceStyle == .dark{
            self.backgroundColor = .COLOR_BG_WHITE
        }else{
            self.backgroundColor = .COLOR_BG_F5
        }
        self.isUserInteractionEnabled = true
        selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        reportMsgDict = ["achieved":"no",
                         "gaps":[""],
                         "advice":["text":""]]
        
        initUI()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNutritionDetailState), name: NOTIFI_NAME_REFRESH_VIP_STATUS, object: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        scro.backgroundColor = .clear
        scro.showsVerticalScrollIndicator = false
        scro.delegate = self
        
        return scro
    }()
    lazy var tableView: ForumCommentListTableView = {
        let vi = ForumCommentListTableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight), style: .plain)
        vi.backgroundColor = .clear
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.register(JournalReportDailyGoalCell.classForCoder(), forCellReuseIdentifier: "JournalReportDailyGoalCell")
        vi.register(JournalReportDailyDesCell.classForCoder(), forCellReuseIdentifier: "JournalReportDailyDesCell")
        vi.register(JournalReportDailyNaturalCell.classForCoder(), forCellReuseIdentifier: "JournalReportDailyNaturalCell")
        vi.register(JournalReportDailyDetailCell.classForCoder(), forCellReuseIdentifier: "JournalReportDailyDetailCell")
        vi.register(JournalReportDailyCaloriesMealsCell.classForCoder(), forCellReuseIdentifier: "JournalReportDailyCaloriesMealsCell")
        vi.register(JournalReportDailyAchievedCell.classForCoder(), forCellReuseIdentifier: "JournalReportDailyAchievedCell")
        
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        
        vi.reloadCompletion = {()in
            let size = self.tableView.contentSize
            if abs(self.tableHeight - size.height) > 1{
                self.tableHeight = size.height
                self.updateFrame(shouldPerformPendingScroll: self.shouldShowNutritionOnlyWhenDailyReportNoData == false)
            }
        }
        
        return vi
    }()
    lazy var rankingButton: RankingListButton = {
        let vm = RankingListButton.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(111), y: kFitWidth(71), width: 0, height: 0))
//        vm.isHidden = true
        vm.alpha = 0
        vm.tapBlock = {()in
            let vc = FriendRankingVC()
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var naturalHeadVm: JournalReportTableHeadVM = {
        let vm = JournalReportTableHeadVM.init(frame: .zero)
        vm.titleLab.text = "其他营养成分"
        vm.alpha = 0
        return vm
    }()
    lazy var nutritionDistributionHeadVm: JournalReportTableHeadVM = {
        let vm = JournalReportTableHeadVM.init(frame: .zero)
        vm.titleLab.text = "营养分布"
        return vm
    }()
//    let vm = JournalReportTableHeadVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
    lazy var caloriesMealMsgVm: JournalReportDailyCaloriesMealsVM = {
        let vm = JournalReportDailyCaloriesMealsVM.init(frame: .zero)
//        vm.isHidden = true
        vm.alpha = 0
        vm.heightChangeBlock = {()in
            self.updateFrame()
        }
        return vm
    }()
    lazy var caloriesSourceMsgVm: JournalReportDailyCaloriesSourceVM = {
        let vm = JournalReportDailyCaloriesSourceVM.init(frame: CGRect.init(x: 0, y: self.caloriesMealMsgVm.frame.maxY, width: 0, height: 0))
//        vm.isHidden = true
        vm.alpha = 0
        return vm
    }()
    lazy var nutritionNoProVm: JournalReportDailyNutritionNoProVM = {
        let vm = JournalReportDailyNutritionNoProVM.init(frame: .zero)
        vm.alpha = 0
        vm.tapBlock = {()in
            let vc = ElaProElementsVC()
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var nutritionProVm: JournalReportDailyNutritionProVM = {
        let vm = JournalReportDailyNutritionProVM.init(frame: .zero)
        vm.alpha = 0
        vm.hintTapBlock = { [weak self] in
            guard let self = self else { return }
            self.nutritionRecommendAlertVm.showSelf(in: self.controller.view)
        }
        vm.itemTapBlock = { [weak self] item in
            guard let self = self else { return }
            let vc = DefaultNutritionMineralsTargetVC()
//            vc.selectedItemKey = item.key
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var nutritionRecommendAlertVm: JournalReportNutritionRecommendAlertVM = {
        let vm = JournalReportNutritionRecommendAlertVM.init(frame: .zero)
        return vm
    }()
    lazy var nodataVm: ReportNoDataVM = {
        let vm = ReportNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        vm.isHidden = true
        return vm
    }()
}

extension JournalReportDailyMsgVM:UITableViewDelegate,UITableViewDataSource{
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView.isScrollEnabled = false
        if isDailyReportLoading {
            return 4
        }
        if self.reportMsgDict.stringValueForKey(key: "achieved") == "yes"{
            return 3
        }else{
            var rows = 2
            let dataArr = self.reportMsgDict["gaps"]as? NSArray ?? []
            if dataArr.count > 0 {
                rows += 1
            }
            
            let dict = self.reportMsgDict["advice"]as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "text").count > 0 {
                rows += 1
            }
            return rows
        }
//        return self.reportMsgDict.stringValueForKey(key: "achieved") == "yes" ? 3 : 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportDailyGoalCell") as? JournalReportDailyGoalCell
                let dict = self.reportMsgDict["title"]as? NSDictionary ?? [:]
                cell?.updateUI(dict: dict)
                cell?.refreshLabelFrame(isAchieved: self.reportMsgDict.stringValueForKey(key: "achieved") == "yes")
                
                return cell ?? JournalReportDailyGoalCell()
            }else if indexPath.row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportDailyDesCell") as? JournalReportDailyDesCell
                let dict = self.reportMsgDict["desc"]as? NSDictionary ?? [:]
                cell?.updateUI(dict: dict,gapsArray: self.reportMsgDict["gaps"]as? NSArray ?? [],adviceDict: self.reportMsgDict["advice"]as? NSDictionary ?? [:],isAchieved: self.reportMsgDict.stringValueForKey(key: "achieved") == "yes")

                return cell ?? JournalReportDailyDesCell()
            }else if indexPath.row == 2{
                if isDailyReportLoading {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportDailyNaturalCell") as? JournalReportDailyNaturalCell
                    cell?.showSkeletonUI()

                    return cell ?? JournalReportDailyNaturalCell()
                }
                if self.reportMsgDict.stringValueForKey(key: "achieved") == "yes"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportDailyAchievedCell") as? JournalReportDailyAchievedCell
                    cell?.updateUI(dict: self.reportMsgDict)

                    return cell ?? JournalReportDailyAchievedCell()
                }else{
                    let dataArr = self.reportMsgDict["gaps"]as? NSArray ?? []
                    
                    if dataArr.count > 0 {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportDailyNaturalCell") as? JournalReportDailyNaturalCell
                        cell?.updateUI(dataArr: dataArr)
                        
                        return cell ?? JournalReportDailyNaturalCell()
                    }else{
                        let dict = self.reportMsgDict["advice"]as? NSDictionary ?? [:]
                        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportDailyDetailCell") as? JournalReportDailyDetailCell
                        cell?.updateUI(dict: dict)
                        
                        return cell ?? JournalReportDailyDetailCell()
                    }
                }
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportDailyDetailCell") as? JournalReportDailyDetailCell
                if isDailyReportLoading {
                    cell?.showSkeletonUI()

                    return cell ?? JournalReportDailyDetailCell()
                }
                let dict = self.reportMsgDict["advice"]as? NSDictionary ?? [:]
                cell?.updateUI(dict: dict)
                
                return cell ?? JournalReportDailyDetailCell()
            }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vm = JournalReportTableHeadVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.titleLab.text = "每日营养分析"

        return vm
    }
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let vm = JournalReportTableHeadVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
//        vm.titleLab.text = "营养详情"
//        vm.clipsToBounds = true
//        return vm
//    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFitWidth(56)
    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return kFitWidth(56)
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension JournalReportDailyMsgVM:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y < 0{
//            scrollView.contentOffset.y = 0
//        }else{
            self.offsetChangeBlock?(self.scrollView.contentOffset.y)
            trackDailyOtherNutritionPageViewIfNeeded()
//        }
    }

    private func trackDailyOtherNutritionPageViewIfNeeded() {
        guard hasTrackedDailyOtherNutritionPageView == false else { return }
        guard UserInfoModel.shared.vipModel.isValidVip else { return }
        guard naturalHeadVm.isHidden == false, nutritionProVm.isHidden == false else { return }
        guard naturalHeadVm.frame.minY > 0, nutritionProVm.frame.height > 0 else { return }

        let triggerOffsetY = naturalHeadVm.frame.minY - scrollView.adjustedContentInset.top
        guard scrollView.contentOffset.y >= triggerOffsetY else { return }

        hasTrackedDailyOtherNutritionPageView = true
        EventLogUtils().sendEventLogRequest(
            eventName: .PAGE_VIEW,
            scenarioType: .daily_report_other_nutrition,
            text: "",
            resultText: ""
        )
    }
}

extension JournalReportDailyMsgVM{
    func initUI() {
        addSubview(scrollView)
        scrollView.addSubview(tableView)
//        scrollView.addSubview(rankingButton)
        scrollView.addSubview(nutritionDistributionHeadVm)
        scrollView.addSubview(caloriesMealMsgVm)
        scrollView.addSubview(caloriesSourceMsgVm)
        scrollView.addSubview(naturalHeadVm)
        scrollView.addSubview(nutritionNoProVm)
        scrollView.addSubview(nutritionProVm)
        addSubview(nutritionRecommendAlertVm)
        tableView.isScrollEnabled = false
        
        addSubview(nodataVm)
        
    }
    
    func updateFrame(shouldPerformPendingScroll: Bool = true) {
        if shouldShowNutritionOnlyWhenDailyReportNoData, didReceiveDailyReportNoData {
            if UserInfoModel.shared.vipModel.isValidVip {
                showDailyNoDataOnly(message: dailyReportNoDataMessage)
            } else {
                showNutritionNoProOnlyForDailyNoData()
            }
            return
        }
        if self.detailDict.stringValueForKey(key: "sdate") == Date().todayDate{
            self.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.tableHeight)
            self.nutritionDistributionHeadVm.frame = CGRect.init(x: 0, y: self.tableHeight, width: SCREEN_WIDHT, height: self.nutritionDistributionHeadVm.selfHeight)
            self.caloriesMealMsgVm.frame = CGRect.init(x: 0, y: self.nutritionDistributionHeadVm.frame.maxY, width: SCREEN_WIDHT, height: self.caloriesMealMsgVm.selfHeight)
            self.caloriesSourceMsgVm.frame = CGRect.init(x: 0, y: self.caloriesMealMsgVm.frame.maxY+kFitWidth(12), width: SCREEN_WIDHT, height: self.caloriesSourceMsgVm.selfHeight)
            let contentMaxY = layoutNutritionDetail(startY: self.caloriesSourceMsgVm.frame.maxY+kFitWidth(12))

            self.scrollView.contentSize = CGSize.init(width: 0, height: contentMaxY+kFitWidth(20)+WHUtils().getBottomSafeAreaHeight())
            if shouldPerformPendingScroll {
                self.performPendingNutritionDetailScrollIfNeeded()
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                self.caloriesMealMsgVm.alpha = 1
                self.fadeInNutritionDetailViews()
            })
        }else{
            self.hiddenTableView(animated: false, shouldPerformPendingScroll: shouldPerformPendingScroll)
        }
    }
    func hiddenTableView(animated: Bool = true, shouldPerformPendingScroll: Bool = true) {
        self.tableView.isHidden = true
        self.tableHeight = 0
        
        if animated {
            self.naturalHeadVm.alpha = 0
            self.caloriesMealMsgVm.alpha = 0
            self.caloriesSourceMsgVm.alpha = 0
            self.nutritionNoProVm.alpha = 0
            self.nutritionProVm.alpha = 0
        }
        self.caloriesMealMsgVm.isHidden = false
        self.caloriesSourceMsgVm.isHidden = false
        
        self.nutritionDistributionHeadVm.frame = CGRect.init(x: 0, y: self.tableHeight, width: SCREEN_WIDHT, height: self.nutritionDistributionHeadVm.selfHeight)
        self.caloriesMealMsgVm.frame = CGRect.init(x: 0, y: self.nutritionDistributionHeadVm.frame.maxY, width: SCREEN_WIDHT, height: self.caloriesMealMsgVm.selfHeight)
        self.caloriesSourceMsgVm.frame = CGRect.init(x: 0, y: self.caloriesMealMsgVm.frame.maxY+kFitWidth(12), width: SCREEN_WIDHT, height: self.caloriesSourceMsgVm.selfHeight)
        let contentMaxY = layoutNutritionDetail(startY: self.caloriesSourceMsgVm.frame.maxY+kFitWidth(12))
        
        self.scrollView.contentSize = CGSize.init(width: 0, height: contentMaxY+kFitWidth(20)+WHUtils().getBottomSafeAreaHeight())
        if shouldPerformPendingScroll {
            self.performPendingNutritionDetailScrollIfNeeded()
        }
        
        let showViews = {
            self.naturalHeadVm.alpha = 1
            self.caloriesMealMsgVm.alpha = 1
            self.caloriesSourceMsgVm.alpha = 1
            self.nutritionNoProVm.alpha = 1
            self.nutritionProVm.alpha = 1
        }
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear, animations: showViews)
        } else {
            showViews()
        }
    }
    
    @objc func refreshNutritionDetailState() {
        if shouldShowNutritionOnlyWhenDailyReportNoData,
           isShowingNutritionNoProOnlyForDailyNoData,
           UserInfoModel.shared.vipModel.isValidVip {
            sendDayliReposrtRequest()
            return
        }
        updateFrame()
    }
    
    @discardableResult
    func layoutNutritionDetail(startY: CGFloat) -> CGFloat {
        if shouldShowNutritionOnlyWhenDailyReportNoData, isWaitingForDailyReportDisplayDecision {
            naturalHeadVm.isHidden = true
            nutritionNoProVm.isHidden = true
            nutritionProVm.isHidden = true
            naturalHeadVm.frame = CGRect(x: 0, y: startY, width: SCREEN_WIDHT, height: 0)
            nutritionNoProVm.frame = CGRect(x: 0, y: startY, width: SCREEN_WIDHT, height: 0)
            nutritionProVm.frame = CGRect(x: 0, y: startY, width: SCREEN_WIDHT, height: 0)
            return startY
        }
        let showNoPro = UserInfoModel.shared.vipModel.isValidVip == false
        let showPro = !showNoPro
        naturalHeadVm.isHidden = false
        nutritionNoProVm.isHidden = !showNoPro
        nutritionProVm.isHidden = !showPro
        
        naturalHeadVm.frame = CGRect.init(x: 0, y: startY, width: SCREEN_WIDHT, height: naturalHeadVm.selfHeight)
        
        if showPro {
            nutritionNoProVm.frame = CGRect.init(x: 0, y: startY, width: SCREEN_WIDHT, height: 0)
            nutritionProVm.frame = CGRect.init(x: 0, y: naturalHeadVm.frame.maxY, width: SCREEN_WIDHT, height: nutritionProVm.selfHeight)
            return nutritionProVm.frame.maxY
        }
        
        nutritionNoProVm.frame = CGRect.init(x: 0, y: naturalHeadVm.frame.maxY, width: SCREEN_WIDHT, height: nutritionNoProVm.selfHeight)
        nutritionProVm.frame = CGRect.init(x: 0, y: startY, width: SCREEN_WIDHT, height: 0)
        return nutritionNoProVm.frame.maxY
    }

    func scrollToNutritionDetail(animated: Bool) {
        pendingScrollToNutritionDetail = true
        pendingScrollToNutritionDetailAnimated = animated
        if shouldShowNutritionOnlyWhenDailyReportNoData {
            isHoldingContentForInitialNutritionScroll = true
            scrollView.alpha = 0
        }
        DispatchQueue.main.async {
            self.performPendingNutritionDetailScrollIfNeeded()
        }
    }

    private func performPendingNutritionDetailScrollIfNeeded() {
        guard pendingScrollToNutritionDetail else { return }
        guard naturalHeadVm.isHidden == false, naturalHeadVm.frame.maxY > 0 else { return }
        guard scrollView.contentSize.height > 0, scrollView.bounds.height > 0 else { return }

        pendingScrollToNutritionDetail = false
        let minOffsetY = -scrollView.adjustedContentInset.top
        let maxOffsetY = max(minOffsetY, scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom)
        let targetOffsetY = min(max(naturalHeadVm.frame.minY, minOffsetY), maxOffsetY)
        scrollView.setContentOffset(CGPoint(x: 0, y: targetOffsetY), animated: pendingScrollToNutritionDetailAnimated)
        offsetChangeBlock?(targetOffsetY)
    }

    private func finishPendingNutritionDetailScrollAtTop() {
        guard pendingScrollToNutritionDetail else { return }
        pendingScrollToNutritionDetail = false
        scrollView.setContentOffset(.zero, animated: false)
        offsetChangeBlock?(0)
    }

    private func revealHeldContentIfNeeded() {
        guard isHoldingContentForInitialNutritionScroll else { return }
        isHoldingContentForInitialNutritionScroll = false
        scrollView.alpha = 1
    }

    private func visibleNutritionDetailViews() -> [UIView] {
        return [caloriesSourceMsgVm, naturalHeadVm, nutritionNoProVm, nutritionProVm].filter {
            $0.isHidden == false && $0.frame.height > 0
        }
    }

    private func fadeInNutritionDetailViews(animated: Bool = true) {
        let views = visibleNutritionDetailViews()
        guard views.isEmpty == false else { return }
        guard animated else {
            views.forEach { $0.alpha = 1 }
            return
        }

        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            views.forEach { $0.alpha = 1 }
        }
    }
}

extension JournalReportDailyMsgVM{
    private func hideNoDataView() {
        nodataVm.isHidden = true
        nodataVm.alpha = 0
        nodataVm.whiteCoverView.isHidden = true
        nodataVm.whiteCoverView.alpha = 0
    }

    private func restoreDailyReportContentVisibility() {
        scrollView.isScrollEnabled = true
        tableView.isHidden = false
        nutritionDistributionHeadVm.isHidden = false
        caloriesMealMsgVm.isHidden = false
        caloriesSourceMsgVm.isHidden = false
        naturalHeadVm.isHidden = false
        rankingButton.removeFromSuperview()
        rankingButton.alpha = 0
        isShowingNutritionNoProOnlyForDailyNoData = false
        isWaitingForDailyReportDisplayDecision = false
        hideNoDataView()
    }

    private func hideDailyReportContentForNoData() {
        tableView.isHidden = true
        nutritionDistributionHeadVm.isHidden = true
        caloriesMealMsgVm.isHidden = true
        caloriesSourceMsgVm.isHidden = true
        naturalHeadVm.isHidden = true
        nutritionNoProVm.isHidden = true
        nutritionProVm.isHidden = true
        scrollView.setContentOffset(.zero, animated: false)
        scrollView.isScrollEnabled = false
        scrollView.contentSize = CGSize(width: 0, height: selfHeight)
        offsetChangeBlock?(0)
    }

    private func showNutritionNoProOnlyForDailyNoData() {
        hideNoDataView()
        rankingButton.removeFromSuperview()
        rankingButton.alpha = 0
        hideDailyReportContentForNoData()
        isShowingNutritionNoProOnlyForDailyNoData = true
        naturalHeadVm.isHidden = false
        naturalHeadVm.alpha = 0
        naturalHeadVm.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: naturalHeadVm.selfHeight)
        nutritionNoProVm.isHidden = false
        nutritionNoProVm.alpha = 0
        nutritionNoProVm.frame = CGRect(x: 0, y: naturalHeadVm.frame.maxY, width: SCREEN_WIDHT, height: nutritionNoProVm.selfHeight)
        scrollView.contentSize = CGSize(width: 0, height: naturalHeadVm.frame.maxY+nutritionNoProVm.selfHeight)
        finishPendingNutritionDetailScrollAtTop()
        revealHeldContentIfNeeded()
        fadeInNutritionDetailViews()
    }

    private func showDailyNoDataOnly(message: String) {
        let shouldShowNoDataWithAnimation = nodataVm.isHidden || nodataVm.alpha == 0
        isShowingNutritionNoProOnlyForDailyNoData = false
        scrollView.isScrollEnabled = true
        scrollView.setContentOffset(.zero, animated: false)
        offsetChangeBlock?(0)
        finishPendingNutritionDetailScrollAtTop()
        revealHeldContentIfNeeded()
        tableView.isHidden = false
        nutritionDistributionHeadVm.isHidden = false
        caloriesMealMsgVm.isHidden = false
        caloriesSourceMsgVm.isHidden = false
        naturalHeadVm.isHidden = true
        nutritionNoProVm.isHidden = true
        nutritionProVm.isHidden = true
        nutritionDistributionHeadVm.alpha = 1
        caloriesMealMsgVm.alpha = 1
        caloriesSourceMsgVm.alpha = 1

        tableView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: tableHeight)
        nutritionDistributionHeadVm.frame = CGRect(x: 0, y: tableView.frame.maxY, width: SCREEN_WIDHT, height: nutritionDistributionHeadVm.selfHeight)
        caloriesMealMsgVm.frame = CGRect(x: 0, y: nutritionDistributionHeadVm.frame.maxY, width: SCREEN_WIDHT, height: caloriesMealMsgVm.selfHeight)
        caloriesSourceMsgVm.frame = CGRect(x: 0, y: caloriesMealMsgVm.frame.maxY+kFitWidth(12), width: SCREEN_WIDHT, height: caloriesSourceMsgVm.selfHeight)
        scrollView.contentSize = CGSize(width: 0, height: caloriesSourceMsgVm.frame.maxY+kFitWidth(20)+WHUtils().getBottomSafeAreaHeight())
        nodataVm.tipsLabel.text = message
        if shouldShowNoDataWithAnimation {
            nodataVm.showView()
        } else {
            nodataVm.isHidden = false
            nodataVm.alpha = 1
            nodataVm.whiteCoverView.isHidden = false
            nodataVm.whiteCoverView.alpha = 1
        }
        showRankingButton(in: nodataVm)
        rankingButton.addFriendButton.backgroundColor = .COLOR_CARD_BG_WHITE
        rankingButton.addFriendButton.setTitleColor(.THEME, for: .normal)
    }

    private func showRankingButton(in containerView: UIView) {
        let shouldFadeIn = rankingButton.superview !== containerView || rankingButton.alpha == 0
        containerView.addSubview(rankingButton)
        rankingButton.alpha = shouldFadeIn ? 0 : 1
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.rankingButton.alpha = 1
        }
    }

    private func updateTableHeightFromCurrentContent() {
        tableView.layoutIfNeeded()
        let size = tableView.contentSize
        if abs(tableHeight - size.height) > 1 {
            tableHeight = size.height
        }
    }
    
    func sendDayliReposrtRequest() {
        isDailyReportLoading = true
        didReceiveDailyReportNoData = false
        dailyReportLoadingStartTime = Date().timeIntervalSince1970
        restoreDailyReportContentVisibility()
        isWaitingForDailyReportDisplayDecision = shouldShowNutritionOnlyWhenDailyReportNoData
        tableView.reloadForSkeleton()

        let param = ["sdate":self.detailDict.stringValueForKey(key: "sdate")]
        WHNetworkUtil.shareManager().POST(urlString: URL_daily_nutrition_report, parameters: param as [String:AnyObject]) { responseObject in
            let code = responseObject["code"] as? Int ?? -1
            DLLog(message: "sendDayliReposrtRequest:\(responseObject)")

            let elapsed = Date().timeIntervalSince1970 - self.dailyReportLoadingStartTime
            let delay = max(0, self.minDailyReportSkeletonDuration - elapsed)
            DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
                self.isDailyReportLoading = false
                if code == 400 {
                    self.isWaitingForDailyReportDisplayDecision = false
                    self.didReceiveDailyReportNoData = true
                    self.dailyReportNoDataMessage = "\(responseObject["message"] as? String ?? "请先记录至少一种食物")"
                    if self.shouldShowNutritionOnlyWhenDailyReportNoData,
                       UserInfoModel.shared.vipModel.isValidVip == false {
                        self.showNutritionNoProOnlyForDailyNoData()
                    } else if self.shouldShowNutritionOnlyWhenDailyReportNoData,
                              UserInfoModel.shared.vipModel.isValidVip {
                        self.tableView.reloadData()
                        self.showDailyNoDataOnly(message: self.dailyReportNoDataMessage)
                    } else {
                        self.tableView.reloadData()
                        self.nodataVm.tipsLabel.text = self.dailyReportNoDataMessage
                        self.nodataVm.showView()
                        self.showRankingButton(in: self.nodataVm)

                        self.rankingButton.addFriendButton.backgroundColor = .COLOR_CARD_BG_WHITE
                        self.rankingButton.addFriendButton.setTitleColor(.THEME, for: .normal)
                    }
//                    self.rankingButton.isHidden = true
                }else{
                    self.isWaitingForDailyReportDisplayDecision = false
                    let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                    let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
                    DLLog(message: "sendDayliReposrtRequest:\(dataObj)")

//                    self.rankingButton.isHidden = false
                    self.didReceiveDailyReportNoData = false
                    self.restoreDailyReportContentVisibility()
                    self.showRankingButton(in: self.scrollView)
                    self.reportMsgDict = dataObj
                    self.nutritionProVm.updateData(reportMsgDict: dataObj)
                    self.tableView.reloadData()
                    self.updateTableHeightFromCurrentContent()
                    self.updateFrame(shouldPerformPendingScroll: false)
                    self.performPendingNutritionDetailScrollIfNeeded()
                    self.revealHeldContentIfNeeded()
                }
            }
        }
    }
}
