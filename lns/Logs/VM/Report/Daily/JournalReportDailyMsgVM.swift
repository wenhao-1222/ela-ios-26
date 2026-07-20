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
    var tableHeight = kFitWidth(0)
    private var isDailyReportLoading = false
    private var dailyReportLoadingStartTime: TimeInterval = 0
    private let minDailyReportSkeletonDuration: TimeInterval = 0.35
    
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
                self.updateFrame()
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
        vm.titleLab.text = "营养详情"
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
//        }
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
        tableView.isScrollEnabled = false
        
        addSubview(nodataVm)
        
    }
    
    func updateFrame() {
        if self.detailDict.stringValueForKey(key: "sdate") == Date().todayDate{
            self.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.tableHeight)
            self.nutritionDistributionHeadVm.frame = CGRect.init(x: 0, y: self.tableHeight, width: SCREEN_WIDHT, height: self.nutritionDistributionHeadVm.selfHeight)
            self.caloriesMealMsgVm.frame = CGRect.init(x: 0, y: self.nutritionDistributionHeadVm.frame.maxY, width: SCREEN_WIDHT, height: self.caloriesMealMsgVm.selfHeight)
            self.caloriesSourceMsgVm.frame = CGRect.init(x: 0, y: self.caloriesMealMsgVm.frame.maxY+kFitWidth(12), width: SCREEN_WIDHT, height: self.caloriesSourceMsgVm.selfHeight)
            let contentMaxY = layoutNutritionDetail(startY: self.caloriesSourceMsgVm.frame.maxY+kFitWidth(12))

            self.scrollView.contentSize = CGSize.init(width: 0, height: contentMaxY+kFitWidth(20)+WHUtils().getBottomSafeAreaHeight())
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                self.caloriesMealMsgVm.alpha = 1
                self.caloriesSourceMsgVm.alpha = 1
                self.nutritionNoProVm.alpha = 1
            })
        }else{
//            self.hiddenTableView()
        }
    }
    func hiddenTableView() {
        self.tableView.isHidden = true
        self.tableHeight = 0
        
        self.naturalHeadVm.alpha = 0
        self.caloriesMealMsgVm.alpha = 0
        self.caloriesSourceMsgVm.alpha = 0
        self.caloriesMealMsgVm.isHidden = false
        self.caloriesSourceMsgVm.isHidden = false
        
        self.nutritionDistributionHeadVm.frame = CGRect.init(x: 0, y: self.tableHeight, width: SCREEN_WIDHT, height: self.nutritionDistributionHeadVm.selfHeight)
        self.caloriesMealMsgVm.frame = CGRect.init(x: 0, y: self.nutritionDistributionHeadVm.frame.maxY, width: SCREEN_WIDHT, height: self.caloriesMealMsgVm.selfHeight)
        self.caloriesSourceMsgVm.frame = CGRect.init(x: 0, y: self.caloriesMealMsgVm.frame.maxY+kFitWidth(12), width: SCREEN_WIDHT, height: self.caloriesSourceMsgVm.selfHeight)
        let contentMaxY = layoutNutritionDetail(startY: self.caloriesSourceMsgVm.frame.maxY+kFitWidth(12))
        
        self.scrollView.contentSize = CGSize.init(width: 0, height: contentMaxY+kFitWidth(20)+WHUtils().getBottomSafeAreaHeight())
        
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.naturalHeadVm.alpha = 1
            self.caloriesMealMsgVm.alpha = 1
            self.caloriesSourceMsgVm.alpha = 1
            self.nutritionNoProVm.alpha = 1
        }
    }
    
    @objc func refreshNutritionDetailState() {
        updateFrame()
    }
    
    @discardableResult
    func layoutNutritionDetail(startY: CGFloat) -> CGFloat {
        let showNoPro = UserInfoModel.shared.vipModel.isValidVip == false
        naturalHeadVm.isHidden = !showNoPro
        nutritionNoProVm.isHidden = !showNoPro
        
        guard showNoPro else {
            naturalHeadVm.frame = CGRect.init(x: 0, y: startY, width: SCREEN_WIDHT, height: 0)
            nutritionNoProVm.frame = CGRect.init(x: 0, y: startY, width: SCREEN_WIDHT, height: 0)
            return self.caloriesSourceMsgVm.frame.maxY
        }
        
        naturalHeadVm.frame = CGRect.init(x: 0, y: startY, width: SCREEN_WIDHT, height: naturalHeadVm.selfHeight)
        nutritionNoProVm.frame = CGRect.init(x: 0, y: naturalHeadVm.frame.maxY, width: SCREEN_WIDHT, height: nutritionNoProVm.selfHeight)
        return nutritionNoProVm.frame.maxY
    }
}

extension JournalReportDailyMsgVM{
    private func showRankingButton(in containerView: UIView) {
        let shouldFadeIn = rankingButton.superview !== containerView || rankingButton.alpha == 0
        containerView.addSubview(rankingButton)
        rankingButton.alpha = shouldFadeIn ? 0 : 1
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.rankingButton.alpha = 1
        }
    }
    
    func sendDayliReposrtRequest() {
        isDailyReportLoading = true
        dailyReportLoadingStartTime = Date().timeIntervalSince1970
        tableView.isHidden = false
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
                    self.tableView.reloadData()
                    self.nodataVm.tipsLabel.text = "\(responseObject["message"] as? String ?? "请先记录至少一种食物")"
                    self.nodataVm.showView()
                    self.showRankingButton(in: self.nodataVm)

                    self.rankingButton.addFriendButton.backgroundColor = .COLOR_CARD_BG_WHITE
                    self.rankingButton.addFriendButton.setTitleColor(.THEME, for: .normal)
//                    self.rankingButton.isHidden = true
                }else{
                    let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                    let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
                    DLLog(message: "sendDayliReposrtRequest:\(dataObj)")

//                    self.rankingButton.isHidden = false
                    self.showRankingButton(in: self.scrollView)
                    self.reportMsgDict = dataObj
                    self.tableView.reloadData()
                }
            }
        }
    }
}
