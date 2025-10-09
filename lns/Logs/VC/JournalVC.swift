//
//  JournalVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/10.
//

import Foundation
import UMCommon
import StoreKit
import MCToast

class JournalVC: WHBaseViewVC {
    /**
     记录APP首次打开时  ，今日的日期
     因为APP可能在后台长时间运行，第二天的时候，会出问题
     */
    var toDayDate = Date().nextDay(days: 0)
    var queryDay = Date().nextDay(days: 0)
    var todayIndex = 0
    var selecteIndex = 0
    
    var daySourceArray = NSMutableArray()
    var offsetYArray:[CGFloat] = [CGFloat]()
    var isEdit = false
    
    var logsGuideStep = 0
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        self.naviVm.bgView.addShadow(opacity: 0.05)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.judegeToDay()
        
        MobClick.beginLogPageView("journal")

        self.sendUserCenterForMineRedView()
        
//        LogsSQLiteUploadManager().checkDataUploadStatus()
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        WidgetMsgModel.shared.mealsIndex = 0
        sendNutritionsDefaultRequest()
        self.navigationController?.fd_interactivePopDisabled = false
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        
        if UserInfoModel.shared.showNotifiAuthoriAlertVM {
            self.notifiAuthoriAlertVm.showView()
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hiddenBottomFuncVm()
//        self.winnerPopView.closeSelfAction()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if self.isEdit == true{
            self.isEdit = false
            self.changeEditStatus()
        }else{
            let indexPath = IndexPath(row: self.selecteIndex, section: 0)
            let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionCell
            cell?.goalVm.winnerPopView.closeSelfAction()
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closeEditStatus"), object: nil)
        MobClick.endLogPageView("journal")
        
//        self.winnerPopView.closeSelfAction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let arr = UserDefaults.getArray(forKey: .fitness_label_array) {
            ConstantModel.shared.fitness_label_array = arr as NSArray
        }
//        ConstantModel.shared.fitness_label_array = UserDefaults.getArray(forKey: .fitness_label_array)! as NSArray
        
        refreshDataSource()
//        sendTutorialMenuListRequest()
        sendUserCenterRequest()
        getUserConfigRequest()
        sendSaveRegistIdRequest()
        sendOssStsRequest()
        judgeLogsData()
        getPostAllowedListRequest()
        sendHistoryFoodsListRequest()
        sendConstantRequest()
        sendNutritionsDefaultCircleRequest()

//        BodyDataUploadManager().dealOldSqlData()
        
        initUI()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(showAddFoodsAlert), name: NOTIFI_NAME_REPORT_ADD_FOODS, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(judegeToDay), name: NOTIFI_NAME_DID_BECOME_ACTIVE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresMsgNotifi), name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresMsgNotifi), name: NSNotification.Name(rawValue: "updateLogsCaloriesStyleMsg"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresMsgNotifi), name: NOTIFI_NAME_ABTEST, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeNaviButtonStatus(notify: )), name: NSNotification.Name(rawValue: "msgCalculateEnd"),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gotoLogsNotification), name: NSNotification.Name(rawValue: "activePlan"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(createPlan), name: NSNotification.Name(rawValue: "fullPlanSave"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addFoodsNotifi(notify: )), name: NSNotification.Name(rawValue: "foodsAddForLogs"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addFoodsFastNotifi(notify: )), name: NSNotification.Name(rawValue: "fastAddFoods"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelEditNotifi), name: NSNotification.Name(rawValue: "cancelEditStatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showBottomFuncVm), name: NSNotification.Name(rawValue: "editFoodsHasSelect"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hiddenBottomFuncVm), name: NSNotification.Name(rawValue: "editFoodsHasSelectNone"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(gotoLogsNotification), name: NSNotification.Name(rawValue: "widgetAddFoodsForLogs"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editStatus), name: NSNotification.Name(rawValue: "longPressCellForEdit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTodayData), name: NOTIFI_NAME_REFRESH_TODAY_JOUNAL, object: nil)
        
//        let launchInt = UserDefaults.standard.value(forKey: launchNum) as? Int ?? 0
        
//        let is_guide_goal = UserDefaults.standard.value(forKey: guide_goal_week_set) as? String ?? ""
//        //如果不需要“免费获取计划”和添加食物的引导功能
//        if is_guide_goal.count > 0 || Date().judgeMin(firstTime: UserInfoModel.shared.registDate, secondTime: "2025-04-02",formatter: "yyyy-MM-dd"){
//            //请求版本更新接口
            sendVersionRequest()
////            let is_guide_goal = UserDefaults.standard.value(forKey: guide_goal_week_set) as? String ?? ""
//            //如果不需要显示营养目标的引导功能，则弹健康APP的授权请求框
//            if is_guide_goal.count > 0 && launchInt > 1{
//                HealthKitManager.init().getLatestWeightSample { entity in
//                    //            DLLog(message: "HealthKitManager:\(String(describing: entity))")
//                }
//            }
//        }
        
        if UserDefaults.standard.string(forKey: guide_total) != nil {
            HealthKitManager.init().getLatestWeightSample { entity in
                //            DLLog(message: "HealthKitManager:\(String(describing: entity))")
            }
        }
        
        dealsWidgetTapAction()
    }
    lazy var naviVm : LogsNaviVM = {
        let vm = LogsNaviVM.init(frame: .zero)
        vm.controller = self
        vm.backgroundColor = UIColor(named: "color_bg_f5")
        vm.choiceTimeBlock = {()in
//            self.sendJpushTestRequest()
            UIApplication.shared.windows.first?.addSubview(self.dateFilterAlertVm)
            self.dateFilterAlertVm.showView()
        }
        vm.lastDayBlock = {()in
            if self.selecteIndex <= 0 {
                self.selecteIndex = 0
                return
            }
            self.isEdit = false
            self.selecteIndex = self.selecteIndex - 1
            
            if self.selecteIndex == 0 {
                self.naviVm.lastButton.isHidden = true
                self.naviVm.nextButton.isHidden = false
            }else{
                self.naviVm.lastButton.isHidden = false
                self.naviVm.nextButton.isHidden = false
            }
            
            self.queryDay = Date().nextDay(days: -1, baseDate: self.queryDay)
//            self.refreshNaviDayText()
            self.collectView.setContentOffsetPage(index: self.selecteIndex, animated: true, direction: .right)
//            self.collectView.scrollToItem(at: IndexPath.init(row: self.selecteIndex, section: 0), at: .right, animated: true)
            self.changeEditStatus()
        }
        vm.nextDayBlock = {()in
            if self.selecteIndex >= self.daySourceArray.count - 1 {
                self.selecteIndex = self.daySourceArray.count - 1
                return
            }
            self.isEdit = false
            self.selecteIndex = self.selecteIndex + 1
            
            if self.selecteIndex == self.daySourceArray.count - 1 {
                self.naviVm.lastButton.isHidden = false
                self.naviVm.nextButton.isHidden = true
            }else{
                self.naviVm.lastButton.isHidden = false
                self.naviVm.nextButton.isHidden = false
            }
            self.queryDay = Date().nextDay(days: 1, baseDate: self.queryDay)
//            self.refreshNaviDayText()
            self.collectView.setContentOffsetPage(index: self.selecteIndex, animated: true, direction: .left)
//            self.collectView.scrollToItem(at: IndexPath.init(row: self.selecteIndex, section: 0), at: .left, animated: true)
            self.changeEditStatus()
            
        }
        vm.delBlock = {()in
            self.editStatus()
        }
        vm.shareBlock = {()in
//            let vc = QuestionnairePreVC()
//            self.navigationController?.pushViewController(vc, animated: true)
            self.collectView.layoutIfNeeded()
            
            let indexPath = IndexPath(row: self.selecteIndex, section: 0)
            let cell = self.collectView.cellForItem(at: indexPath)as! JounalCollectionCell
            
            let vc = JournalShareVC()
//            let vc = JournalShareNewVC()
            vc.detailsDict = cell.currentDayMsg
            vc.dayString = cell.queryDay
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.fitnessBlock = {()in
            self.collectView.layoutIfNeeded()
            
            let indexPath = IndexPath(row: self.selecteIndex, section: 0)
//            if let cell = self.collectView.cellForItem(at: indexPath) as? JounalCollectionCell{
//                cell.updateFitnessBlock = {(fitnessType)in
//    //                if fitnessType == "[]"{
//    //                    return
//    //                }
//                    if fitnessType.count > 0 {
//                        self.naviVm.fitnessLabel.text = fitnessType.mc_clipFromPrefix(to: 1)
//                    }else{
//                        self.naviVm.fitnessLabel.text = "-"
//                    }
//                }
//                cell.showFitnessAlertVm()
//            }
            let cell = self.collectView.cellForItem(at: indexPath)as! JounalCollectionCell
            cell.updateFitnessBlock = {(fitnessType)in
//                if fitnessType == "[]"{
//                    return
//                }
                if fitnessType.count > 0 {
                    self.naviVm.fitnessLabel.text = fitnessType.mc_clipFromPrefix(to: 1)
                }else{
                    self.naviVm.fitnessLabel.text = "-"
                }
            }
            cell.showFitnessAlertVm()
        }
//        vm.fitnessBlock = { [weak self] in
//            guard let self = self else { return }
//
//            self.collectView.layoutIfNeeded()
//            let indexPath = IndexPath(row: self.selecteIndex, section: 0)
//
//            let handleCell: (JounalCollectionCell) -> Void = { cell in
//                cell.updateFitnessBlock = { fitnessType in
//                    self.naviVm.fitnessLabel.text =
//                        fitnessType.count > 0 ? fitnessType.mc_clipFromPrefix(to: 1) : "-"
//                }
//                cell.showFitnessAlertVm()
//            }
//
//            if let cell = self.collectView.cellForItem(at: indexPath) as? JounalCollectionCell {
//                handleCell(cell)
//            } else {
//                // cell 不在可见区域或尚未创建，滚动并强制布局后再次获取
////                self.collectView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
////                self.collectView.layoutIfNeeded()
//                
//                self.collectView.reloadData()
//                self.collectView.layoutIfNeeded()
//                self.collectView.setContentOffsetPage(index: indexPath.row, animated: false, direction: .right)
//                if let cell = self.collectView.cellForItem(at: indexPath) as? JounalCollectionCell {
//                    handleCell(cell)
//                }
//            }
//        }

        return vm
    }()
    lazy var naviEditStatusVm : LogsNaviEditVM = {
        let vm = LogsNaviEditVM.init(frame: .zero)
        vm.backgroundColor = UIColor(named: "color_bg_f5")
        vm.doneBlock = {()in
            self.isEdit = false
            self.changeEditStatus()
        }
        vm.deleteBlock = {()in
            self.collectView.layoutIfNeeded()
            let indexPath = IndexPath(row: self.selecteIndex, section: 0)
            let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionCell
            cell?.editDelAction()
            self.isEdit = false
            self.changeEditStatus()
        }
        return vm
    }()
    let collectView : JournalCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: SCREEN_WIDHT, height: SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()-WHUtils().getTabbarHeight())
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let vi = JournalCollectionView.init(frame: CGRect.init(x: 0, y:WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()-WHUtils().getTabbarHeight()), collectionViewLayout: layout)
        
        vi.collectionViewLayout = layout
        vi.isPagingEnabled = true
        vi.backgroundColor = .clear
//        vi.dataSource = self
        vi.showsHorizontalScrollIndicator = false
        vi.register(JounalCollectionCell.classForCoder(), forCellWithReuseIdentifier: "JounalCollectionCell")
        
        return vi
    }()
    lazy var dateFilterAlertVm : DataAddDateAlertVM = {
        let vm = DataAddDateAlertVM.init(frame: .zero)
        vm.isWeekDay = false
        vm.confirmBlock = {(weekDay)in
            self.queryDay = self.dateFilterAlertVm.dateStringYear
            self.getQueryDayIndex()
//            self.winnerPopView.closeSelfAction()
            if self.selecteIndex == 0 {
                self.naviVm.lastButton.isHidden = true
                self.naviVm.nextButton.isHidden = false
            }else if self.selecteIndex == self.daySourceArray.count - 1 {
                self.naviVm.lastButton.isHidden = false
                self.naviVm.nextButton.isHidden = true
            }else{
                self.naviVm.lastButton.isHidden = false
                self.naviVm.nextButton.isHidden = false
            }
        }
        return vm
    }()
    lazy var bottomFuncVm: JournalBottomFuncAlertVM = {
        let vm = JournalBottomFuncAlertVM.init(frame: .zero)
        vm.copyBlock = {()in
            self.copyMealsAlertVm.refreshPicker(selectIndex:self.selecteIndex)
            self.copyMealsAlertVm.showSelf()
        }
        vm.saveBlock = {()in
            let indexPath = IndexPath(row: self.selecteIndex, section: 0)
            let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionCell
            
            let vc = MealsDetailsVC()
            self.navigationController?.pushViewController(vc, animated: true)
            vc.setFoodsArray(foodsArray: cell?.mealsArray ?? NSArray())
        }
        return vm
    }()
    lazy var funcAlertVm: JournalFuncAlertVM = {
        let vm = JournalFuncAlertVM.init(frame: .zero)
        return vm
    }()
    lazy var copyMealsAlertVm: JournalFuncCopyMealsAlertVM = {
        let vm = JournalFuncCopyMealsAlertVM.init(frame: .zero)
        vm.daysArray = self.daySourceArray
        vm.tomorrowIndex = self.todayIndex + 1
        vm.refreshPicker(selectIndex:self.selecteIndex)
        
        vm.copyBlock = {()in
            let indexPath = IndexPath(row: self.selecteIndex, section: 0)
            let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionCell
            self.copyMealsAlertVm.copyFoods(mealsArray: cell?.mealsArray ?? NSArray())
        }
        vm.updateBlock = {()in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                let indexPath = IndexPath(row: self.copyMealsAlertVm.selectIndex, section: 0)
                let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionCell
                cell?.setQueryDate(date: self.copyMealsAlertVm.queryDay, isEdit: false)
                
                self.isEdit = false
                self.changeEditStatus()
                
                WidgetUtils().reloadWidgetData()
            })
        }
        
        return vm
    }()
//    lazy var guideGoalAlertVm: GuideSetWeekGoalAlertVM = {
//        let vm = GuideSetWeekGoalAlertVM.init(frame: .zero)
//        vm.clickBlock = {()in
//            if UserInfoModel.shared.hidden_survery_button_status == false{
//                UIApplication.shared.windows.first?.addSubview(self.guideCreatePlanAlertVm)
//            }
//        }
//        return vm
//    }()
//    lazy var guideAddFoodsAlertVm: GuideAddFoodsAlertVM = {
//        let vm = GuideAddFoodsAlertVM.init(frame: .zero)
//        
//        vm.addBlock = {()in
//            WidgetMsgModel.shared.mealsIndex = 1
//            
//            WidgetUtils().saveMealsData(mealsIndex: 1)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
////            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "widgetAddFoodsForLogs"), object: nil)
//            
//            self.logsGuideStep = 1
//        }
//        return vm
//    }()
//    lazy var guideCreatePlanAlertVm: GuideJournalGotPlanAlertVM = {
//        let vm = GuideJournalGotPlanAlertVM.init(frame: .zero)
//        return vm
//    }()
    lazy var addFoodsAlertVm: AddFoodsAlertVM = {
        let vm = AddFoodsAlertVM.init(frame: .zero)
        
        vm.addBlock = {()in
            WidgetMsgModel.shared.mealsIndex = 1
            WidgetUtils().saveMealsData(mealsIndex: 1)
            let vc = FoodsListNewVC()
            vc.sourceType = .logs
            self.navigationController?.pushViewController(vc, animated: true)
            WidgetMsgModel.shared.mealsIndex = WidgetUtils().readMealsData()
            WidgetUtils().saveMealsData(mealsIndex: -1)
        }
        return vm
    }()
    lazy var notifiAuthoriAlertVm: NotifiAuthoriAlertVM = {
        let vm = NotifiAuthoriAlertVM.init(frame: .zero)
        vm.controller = self
        vm.acceptBlock = { [weak self] in
            self?.sendSaveRegistIdRequest()
        }
        return vm
    }()
}

extension JournalVC{
    @objc func judegeToDay() {
        if toDayDate != Date().nextDay(days: 0) {
            queryDay = Date().nextDay(days: 0)
            refreshDataSource()
//            self.collectView.reloadData()
            UIView.performWithoutAnimation {
                self.collectView.reloadData()
                self.collectView.layoutIfNeeded()
                self.collectView.setContentOffsetPage(index: self.todayIndex, animated: false, direction: .right)
//                self.collectView.scrollToItem(at: IndexPath.init(row: todayIndex, section: 0), at: .right, animated: false)
            }
            self.toDayDate = Date().nextDay(days: 0)
//            self.collectView.scrollToItem(at: IndexPath.init(row: todayIndex, section: 0), at: .right, animated: false)
            
            self.copyMealsAlertVm.daysArray = self.daySourceArray
            self.copyMealsAlertVm.tomorrowIndex = self.todayIndex + 1
            self.copyMealsAlertVm.refreshPicker(selectIndex:self.selecteIndex)
        }
    }
    func refreshDataSource() {
        let arr = NSMutableArray()
        offsetYArray.removeAll()
        let minDay = Date().getLastYearsAgo(lastYears: -3)
        let maxDay = Date().getLastYearsAgo(lastYears: 3)
        
        let minGapDays = Date().daysBetweenDate(toDate: minDay)
        let maxGapDays = Date().daysBetweenDate(toDate: maxDay)
        
        todayIndex = abs(minGapDays)
        selecteIndex = todayIndex
        
        for i in minGapDays...maxGapDays+1{
            let day = Date().nextDay(days: i, baseDate: queryDay)
            arr.add(day)
            offsetYArray.append(0)
        }
        
        daySourceArray = arr
//        for i in 0..<self.daySourceArray.count{
//            self.collectView.register(JounalCollectionCell.classForCoder(), forCellWithReuseIdentifier: "JounalCollectionCell")
////            self.collectView.register(JounalCollectionCell.classForCoder(), forCellWithReuseIdentifier: "JounalCollectionCell\(i)")
//        }
    }
    func refreshNaviDayText() {
        if self.queryDay == Date().nextDay(days: 0){
            self.naviVm.changeDate(date: "今日")
        }else{
            self.naviVm.changeDate(date: self.queryDay)
        }
        let fitnessType = LogsSQLiteManager.getInstance().queryLogsDataForFitness(sDate: self.queryDay)
        if fitnessType == ""{
            self.naviVm.fitnessLabel.text = "-"
        }else{
            if fitnessType.contains("[") && fitnessType.contains("]"){
                let fitnessArray = WHUtils.getArrayFromJSONString(jsonString: fitnessType)
                if fitnessArray.count > 0 {
                    self.naviVm.fitnessLabel.text = (fitnessArray[0]as? String ?? "-").mc_clipFromPrefix(to: 1)
                }else{
                    self.naviVm.fitnessLabel.text = "-"
                }
            }else{
//                if fitnessType.count > 1 {
                    self.naviVm.fitnessLabel.text = fitnessType.mc_clipFromPrefix(to: 1)
//                }else{
//                    self.naviVm.fitnessLabel.text = fitnessType
//                }
            }
            
//            if fitnessType.count == 1 {
//                self.naviVm.fitnessLabel.text = fitnessType
//            }else{
//                let fitnessArray = WHUtils.getArrayFromJSONString(jsonString: fitnessType)
//                if fitnessArray.count > 0 {
//                    self.naviVm.fitnessLabel.text = fitnessArray[0]as? String ?? "-"
//                }else{
//                    self.naviVm.fitnessLabel.text = "-"
//                }
//            }
        }
    }
    func getQueryDayIndex(){
        for i in 0..<daySourceArray.count{
            let day = daySourceArray[i]as? String ?? ""
            if day == self.queryDay{
                selecteIndex = i
                break
            }
        }
        self.collectView.setContentOffsetPage(index: self.selecteIndex, animated: false, direction: .right)
//        self.collectView.scrollToItem(at: IndexPath.init(row: self.selecteIndex, section: 0), at: .right, animated: false)
    }
}

extension JournalVC{
    @objc func showAddFoodsAlert() {
        let indexPath = IndexPath(row: self.selecteIndex, section: 0)
        let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionCell
        cell?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            self.addFoodsAlertVm.showView()
        })
    }
    @objc func refresMsgNotifi() {
        self.refreshNaviDayText()
        self.collectView.reloadData()
        
        let model = LogsSQLiteManager.getInstance().getLogsByDate(sDate: Date().nextDay(days: 0))!
        let currentDayMsg = NSMutableDictionary(dictionary: model.modelToDict())
        let caloriTarget = Int(currentDayMsg.stringValueForKey(key: "caloriesden")) ?? 0
        let carboTarget = Float(currentDayMsg.stringValueForKey(key: "carbohydrateden")) ?? 0
        let proteinTarget = Float(currentDayMsg.stringValueForKey(key: "proteinden")) ?? 0
        let fatTarget = Float(currentDayMsg.stringValueForKey(key: "fatden")) ?? 0
        
        if carboTarget > 0 || proteinTarget > 0 || fatTarget > 0{
            UserDefaults.set(value: ["calories":"\(caloriTarget)",
                                     "carbohydrate":"\(Int(carboTarget.rounded()))",
                                     "protein":"\(Int(proteinTarget.rounded()))",
                                     "fat":"\(Int(fatTarget.rounded()))"], forKey: .todayGoal)
        }
    }
    @objc func changeNaviButtonStatus(notify:Notification) {
        self.naviVm.enableButton()
//        self.isEdit = false
//        self.changeEditStatus()
    }
    @objc func createPlan() {
        let vc = PlanListVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func editStatus() {
        self.isEdit = true
        self.naviEditStatusVm.delButton.isHidden = true
        self.changeEditStatus()
    }
    @objc func gotoLogsNotification(){
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
            self.getUserConfigRequest()
        })
        DispatchQueue.main.asyncAfter(deadline: .now()+10, execute: {
            self.getUserConfigRequest()
        })
        self.queryDay = Date().nextDay(days: 0)
        self.naviVm.changeDate(date: "今日")
        if toDayDate != Date().nextDay(days: 0){
            refreshDataSource()
//            self.collectView.reloadData()
            UIView.performWithoutAnimation {
                self.collectView.reloadData()
                self.collectView.layoutIfNeeded()
                self.collectView.setContentOffsetPage(index: self.todayIndex, animated: false, direction: .right)
//                self.collectView.scrollToItem(at: IndexPath.init(row: todayIndex, section: 0), at: .right, animated: false)
            }
            self.toDayDate = Date().nextDay(days: 0)
//            self.collectView.scrollToItem(at: IndexPath.init(row: todayIndex, section: 0), at: .right, animated: false)
        }else{
            self.selecteIndex = self.todayIndex
            UIView.performWithoutAnimation {
                self.collectView.reloadData()
                self.collectView.layoutIfNeeded()
                self.collectView.setContentOffsetPage(index: self.todayIndex, animated: false, direction: .right)
//                self.collectView.scrollToItem(at: IndexPath.init(row: todayIndex, section: 0), at: .right, animated: false)
            }
//            self.collectView.reloadData()
//            self.collectView.scrollToItem(at: IndexPath.init(row: todayIndex, section: 0), at: .right, animated: false)
        }
    }
    ///刷新进入日志数据
    @objc func refreshTodayData(){
        let indexPath = IndexPath(row: self.todayIndex, section: 0)
        let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionCell
        cell?.reloadTableView()
    }
    @objc func addFoodsNotifi(notify:Notification) {
        let foodsDict = notify.object ?? [:]
        DLLog(message: "\(foodsDict)")
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.collectView.layoutIfNeeded()
            
            var indexPath = IndexPath(row: self.selecteIndex, section: 0)
            if WidgetMsgModel.shared.mealsIndex > 0 {
                indexPath = IndexPath(row: self.todayIndex, section: 0)
                let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionCell
                
                cell?.selectMealsIndex = WidgetMsgModel.shared.mealsIndex - 1
                cell?.selectFoodsIndex = -1
                cell?.addFoods(foodsMsg: foodsDict as! NSDictionary)
            }else{
                let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionCell
                cell?.addFoods(foodsMsg: foodsDict as! NSDictionary)
            }
        }
    }
    @objc func addFoodsFastNotifi(notify:Notification) {
        self.collectView.layoutIfNeeded()
        let foodsDict = notify.object ?? [:]
        DLLog(message: "\(foodsDict)")
        var indexPath = IndexPath(row: self.selecteIndex, section: 0)
        if WidgetMsgModel.shared.mealsIndex > 0 {
            indexPath = IndexPath(row: self.todayIndex, section: 0)
            let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionCell
            
            cell?.selectMealsIndex = WidgetMsgModel.shared.mealsIndex - 1
            cell?.selectFoodsIndex = -1
            cell?.addFoods(foodsMsg: foodsDict as! NSDictionary)
        }else{
            let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionCell
            cell?.addFoods(foodsMsg: foodsDict as! NSDictionary)
        }
    }
    @objc func cancelEditNotifi(){
        self.isEdit = false
        self.changeEditStatus()
    }
    func changeEditStatus() {
//        self.winnerPopView.closeSelfAction()
        if self.isEdit == true{
//            self.winnerVm.isHidden = true
            self.naviEditStatusVm.isHidden = false
            self.naviVm.isHidden = true
            self.collectView.canScroll = false
        }else{
//            self.winnerVm.isHidden = false
            self.naviEditStatusVm.isHidden = true
            self.naviVm.isHidden = false
            self.collectView.canScroll = true
            
            self.bottomFuncVm.hiddenSelf()
        }
        self.collectView.layoutIfNeeded()
        
        let indexPath = IndexPath(row: self.selecteIndex, section: 0)
        let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionCell
        cell?.isEdit = self.isEdit
        cell?.reloadTableView()
//        cell?.winnerPopView.closeSelfAction()
        
//        self.collectView.reloadItems(at: [indexPath])
    }
    @objc func showBottomFuncVm() {
        self.bottomFuncVm.showSelf()
        self.naviEditStatusVm.delButton.isHidden = false
    }
    @objc func hiddenBottomFuncVm() {
        self.bottomFuncVm.hiddenSelf()
        self.naviEditStatusVm.delButton.isHidden = true
    }
}

extension JournalVC{
    func appMarkAlertVm() {
        let alertVc = UIAlertController(title: "喜欢“Elavatine”吗", message: "您的支持是我们能维持免费服务的关键\n请评分鼓励一下吧:)", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "喜欢，去评分", style: .default) { action in
            self.sendSaveMaterialAppMarkRequest()
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            SKStoreReviewController.requestReview(in: appDelegate.getKeyWindow().windowScene!)
            let urlString = "itms-apps://itunes.apple.com/app/id6503123667?action=write-review"
            self.openUrl(urlString: urlString)
            MobClick.event("appstoreratedLike")
        }
        let action2 = UIAlertAction(title: "不喜欢，去反馈", style: .default) { action in
            self.sendSaveMaterialAppMarkRequest()
            let vc = ServiceContactVC()
            self.navigationController?.pushViewController(vc, animated: true)
            MobClick.event("appstoreratedUnLike")
        }
        let action3 = UIAlertAction(title: "下次再说", style: .default) { action in
            MobClick.event("appstoreratedNextTime")
        }
        
        alertVc.addAction(action2)
        alertVc.addAction(action3)
        alertVc.addAction(action1)
        
        action2.setTextColor(WHColorWithAlpha(colorStr: "007AFF", alpha: 0.4))
        action3.setTextColor(WHColorWithAlpha(colorStr: "007AFF", alpha: 0.4))
        
        self.present(alertVc, animated: true)
    }
}

extension JournalVC{
    func sendUserCenterRequest() {
        let param = ["uid":"\(UserInfoModel.shared.uId)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_User_Center, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            UserInfoModel.shared.updateMsg(dict: dataObj)
            
            let forumLocalId = UserDefaults.getString(forKey: .forumLocalId)
            if forumLocalId != nil && forumLocalId?.contains(UserInfoModel.shared.phone) == true{
                ForumPublishManager.shared.forumLocalId = forumLocalId ?? ""
            }else{
                ForumPublishManager.shared.forumLocalId = ""
            }
            
//            if Date().judgeMin(firstTime: UserInfoModel.shared.registDate, secondTime: "2025-02-01",formatter: "yyyy-MM-dd") == false{
//                UIApplication.shared.windows.first?.addSubview(self.guideAddFoodsAlertVm)
////                self.guideAddFoodsAlertVm.showView()
//            }else{
//                UserDefaults.standard.setValue("1", forKey: guide_foods_add)
//            }
            
            if UserInfoModel.shared.isAppStoreMark == "0" && UserInfoModel.shared.phone != "11111111111"{
                let launchInt = UserDefaults.standard.value(forKey: launchNum) as? Int ?? 0
                if launchInt == 4 || launchInt == 10 || launchInt == 20 || launchInt == 50 {
                    self.appMarkAlertVm()
                }
            }
        }
    }
    func sendUserCenterForMineRedView() {
        let param = ["uid":"\(UserInfoModel.shared.uId)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_User_Center, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            UserInfoModel.shared.updateMsg(dict: dataObj)
//
            let streakDict = dataObj["streak"]as? NSDictionary ?? [:]
            
            let indexPath = IndexPath(row: self.selecteIndex, section: 0)
            let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionCell
            cell?.goalVm.winnerVm.updateUI(dict: streakDict)
            cell?.goalVm.winnerPopView.updateUI(dict: streakDict)
            
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadStreakMsg"), object: nil)
        }
    }
    func sendVersionRequest()  {
        WHNetworkUtil.shareManager().POST(urlString: URL_app_version_new, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dict = self.getDictionaryFromJSONString(jsonString: dataString ?? "")
        
            DLLog(message: "sendVersionRequest:\(dict)")
            
            let latest_ver_code = dict.stringValueForKey(key: "latest_ver_code")
            let buildVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            
            if dict.stringValueForKey(key: "pop_window") == "1" && buildVersion != latest_ver_code{
                let versionName = dict.stringValueForKey(key: "latest_ver_name")
                let release_logs = dict.stringValueForKey(key: "release_log")
                let releaseLogArray = WHUtils.getArrayFromJSONString(jsonString: release_logs)
                var releaseString = ""
                
                for i in 0..<releaseLogArray.count{
                    let str = releaseLogArray[i]as? String ?? ""
                    releaseString.append(str)
                    if i < releaseLogArray.count - 1{
                        releaseString.append("\n")
                    }
                }
                if dict.stringValueForKey(key: "force_upgrade") == "1"{
                    self.presentAlertVc(confirmBtn: "去更新", message: releaseString, title: "最新版本 V\(versionName)", cancelBtn: nil,textAlignLeft: true, handler: { action in
                        let urlString = "itms-apps://itunes.apple.com/app/id6503123667"
                        self.openUrl(urlString: urlString)
                    }, viewController: self)
                }else{
                    self.presentAlertVc(confirmBtn: "去更新", message: releaseString, title: "最新版本 V\(versionName)", cancelBtn: "取消",textAlignLeft: true, handler: { action in
                        let urlString = "itms-apps://itunes.apple.com/app/id6503123667"
                        self.openUrl(urlString: urlString)
                    }, viewController: self)
                }
            }
        }
    }
    func sendSaveMaterialAppMarkRequest() {
        let param = ["appstorerated":"1"]
        UserInfoModel.shared.isAppStoreMark = "1"
       WHNetworkUtil.shareManager().POST(urlString: URL_User_Material_Update, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
           
        }
    }
    
    func sendSaveRegistIdRequest() {
        if JPUSHService.registrationID().count > 0 {
            let param = ["jpush_regid_ios":"\(JPUSHService.registrationID())"]
            DLLog(message: "sendSaveRegistIdRequest(param):\(param)")
           WHNetworkUtil.shareManager().POST(urlString: URL_User_Material_Update, parameters: param as [String : AnyObject]) { responseObject in
                DLLog(message: "sendSaveRegistIdRequest:\(responseObject)")
            }
        }
    }
    func sendNutritionsDefaultRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_get_default_nutrition, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
//            DLLog(message: "sendNutritionsDefaultRequest:\(dataArray)")
            UserDefaults.set(value: WHUtils.getJSONStringFromArray(array: dataArray), forKey: .nutritionDefaultArray)
        }
    }
}

extension JournalVC{
    func initUI(){
        view.backgroundColor = .COLOR_BG_F5
        view.addSubview(naviVm)
        view.addSubview(naviEditStatusVm)
        
        view.insertSubview(collectView, belowSubview: naviVm)
        
        collectView.delegate = self
        collectView.dataSource = self
        if isIpad(){
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self.collectView.setContentOffsetPage(index: self.todayIndex, animated: false, direction: .right)
            })
        }else{
            self.collectView.setContentOffsetPage(index: self.todayIndex, animated: false, direction: .right)
        }
        
//        collectView.scrollToItem(at: IndexPath.init(row: todayIndex, section: 0), at: .right, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.getKeyWindow().addSubview(self.bottomFuncVm)
            appDelegate.getKeyWindow().addSubview(self.copyMealsAlertVm)
            appDelegate.getKeyWindow().addSubview(self.dateFilterAlertVm)
            appDelegate.getKeyWindow().addSubview(self.addFoodsAlertVm)
            appDelegate.getKeyWindow().addSubview(self.notifiAuthoriAlertVm)
        })
    }
}
extension JournalVC:UICollectionViewDelegate,UICollectionViewDataSource{
    func isCellVisible(indexPath:IndexPath) -> Bool {
        let visibleIndexPaths = collectView.indexPathsForVisibleItems
        if visibleIndexPaths.count == 0{
            return false
        }
        
        return visibleIndexPaths.contains(indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daySourceArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JounalCollectionCell", for: indexPath)as? JounalCollectionCell
//        cell?.isVisible = isCellVisible(indexPath: indexPath)
        
        let day = daySourceArray[indexPath.row]as? String ?? "\(Date().nextDay(days: 0))"
        cell?.setQueryDate(date: day,isEdit: self.isEdit)
        cell?.controller = self
        
        cell?.offsetChangeBlock = {(offsetY)in
            if day == self.queryDay{
                self.naviVm.changeBgAlpha(offsetY: offsetY)
                self.naviEditStatusVm.changeBgAlpha(offsetY: offsetY)
            }
//            if self.offsetYArray.count > indexPath.row{
//                self.offsetYArray[indexPath.row] = offsetY
//            }
        }
        cell?.updateFitnessBlock = {(fitnessType)in
//            if fitnessType == "[]"{
//                return
//            }
            if self.queryDay == day{
                if fitnessType.count > 0 {
                    self.naviVm.fitnessLabel.text = fitnessType.mc_clipFromPrefix(to: 1)
                }else{
                    self.naviVm.fitnessLabel.text = "-"
                }
            }
        }
        
        return cell ?? JounalCollectionCell()
    }
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JounalCollectionCell", for: indexPath)as? JounalCollectionCell
////        let cell = self.collectView.dequeueReusableCell(withReuseIdentifier: "JounalCollectionCell", for: IndexPath(row: currentPage, section: 0))as? JounalCollectionCell
//    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int((collectView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
//        DLLog(message: "scrollViewDidEndDecelerating:\(currentPage)  -- \(daySourceArray[currentPage]as? String ?? "")")
        self.queryDay = daySourceArray[currentPage]as? String ?? ""
        self.selecteIndex = currentPage
        self.refreshNaviDayText()
        
        if let visibleIndexPath = collectView.indexPathsForVisibleItems.first {
            if let cell = collectView.cellForItem(at: visibleIndexPath) as? JounalCollectionCell {
//                cell.tableView.setContentOffset(.zero, animated: false)
                let contentOffsetY = cell.tableView.contentOffset.y
                DLLog(message: "changeBgAlpha :\(self.queryDay)  -  \(contentOffsetY)")
                self.naviVm.changeBgAlpha(offsetY: contentOffsetY)
                self.naviEditStatusVm.changeBgAlpha(offsetY: contentOffsetY)
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = Int((collectView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
        self.queryDay = daySourceArray[currentPage]as? String ?? ""
        self.selecteIndex = currentPage
        self.refreshNaviDayText()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closeEditStatus"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadStreakMsg"), object: nil)
    }
    
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        guard scrollView == collectView else { return }
//        let currentPage = Int((collectView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
//        self.queryDay = daySourceArray[currentPage]as? String ?? ""
//        self.selecteIndex = currentPage
//        self.refreshNaviDayText()
//        if let cell = collectView.cellForItem(at: IndexPath(row: currentPage, section: 0)) as? JounalCollectionCell {
//            cell.tableView.setContentOffset(.zero, animated: false)
//            let offsetY = cell.tableView.contentOffset.y
//            self.naviVm.changeBgAlpha(offsetY: offsetY)
//            self.naviEditStatusVm.changeBgAlpha(offsetY: offsetY)
//        }
//    }
}

extension JournalVC{
    //判断本地的数据是否已从服务器全部拉取
    func judgeLogsData() {
        let hasLoadLogsData = UserDefaults.standard.value(forKey: "\(UserInfoModel.shared.uId)LogsData") as? String ?? ""
        
        if hasLoadLogsData == "1"{
            
        }else{
            sendLogsAllDataRequest()
        }
    }
    func sendLogsAllDataRequest() {
        DLLog(message: "sendLogsAllDataRequest:\(Date().currentSeconds)")
        WHNetworkUtil.shareManager().POST(urlString: URL_User_logs_all, parameters: nil) { responseObject in
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
//                DispatchQueue.main.sync(execute: {
                let dataObj = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
                    DLLog(message: "sendLogsAllDataRequest:\(Date().currentSeconds)")
                    LogsSQLiteManager.getInstance().saveServerDataToDB(dataArray: dataObj)
//                })
            }
        }
    }
    func getUserConfigRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_config_msg, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "getUserConfigRequest:\(dataObj)")
            if dataObj.stringValueForKey(key: "onboarding_flow_status") == "0"{
                NotificationCenter.default.post(name: NOTIFI_NAME_GUIDE, object: nil)
                UserInfoModel.shared.onboarding_flow_status = false
            }else{
                UserDefaults.standard.setValue("1", forKey: guide_total)
                UserInfoModel.shared.onboarding_flow_status = true
            }
            UserInfoModel.shared.updateUserConfig(dict: dataObj)
            
            LogsMealsAlertSetManage().refreshClockAlertMsg()
        }
    }
    func getPostAllowedListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_allowes_poster, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "") ?? ""
            DLLog(message: "getPostAllowedListRequest:\(dataString)")
            if dataString == "1"{
                UserInfoModel.shared.isAllowedPosterForum = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hasAllowedPosterForum"), object: nil)
            }else{
                UserInfoModel.shared.isAllowedPosterForum = false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hasAllowedPosterForum"), object: nil)
            }
        }
    }
    func sendOssStsRequest() {
        WHNetworkUtil.shareManager().GET(urlString: URL_OSS_sts) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            UserInfoModel.shared.updateOssParams(dict: self.getDictionaryFromJSONString(jsonString: dataString ?? ""))
        }
    }
    /*
     提前请求教程的数据，视频数据解析要时间
     */
    func sendTutorialMenuListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_tutorial_menu_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendDataListRequest:\(dataArr)")
            
            UserConfigModel.shared.tutorialsListArray = dataArr
            
            for i in 0..<dataArr.count{
                let dict = dataArr[i]as? NSDictionary ?? [:]
                if dict.stringValueForKey(key: "status") != "1"{
                    self.sendTutorialDataListReqeust(parentId: dict.stringValueForKey(key: "id"))
                }
            }
        }
    }
    func sendTutorialDataListReqeust(parentId:String) {
        let param = ["parentId":"\(parentId)"]
        var modelArray = NSMutableArray()
        WHNetworkUtil.shareManager().POST(urlString: URL_tutorial_menu_catogary_list, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = self.getArrayFromJSONString(jsonString: dataString ?? "")
            UserConfigModel.shared.tutorialsTypeDict["\(parentId)"] = dataArr
            DLLog(message: "sendDataListReqeust:\(dataArr)")
            let serialQueue = DispatchQueue(label: "com.tutorials.parse")
            serialQueue.async {
                for i in 0..<dataArr.count{
                    let dict = dataArr[i]as? NSDictionary ?? [:]
                    let tutorials = dict["tutorials"]as? NSArray ?? []
                    
                    let dataArrTemp = NSMutableArray()
                    for j in 0..<tutorials.count{
                        let dictTuto = tutorials[j]as? NSDictionary ?? [:]
                        let model = ForumTutorialModel().dealDictForModel(dict: dictTuto)
                        dataArrTemp.add(model)
                    }
                    modelArray.add(dataArrTemp)
                }
                UserConfigModel.shared.tutorialsDataDict["\(parentId)"] = modelArray
//                UserDefaults.standard.set(modelArray, forKey: "\(parentId)")
//                UserConfigModel.shared.tutorialsDataArray.add(modelArray)
            }
            serialQueue.async {
                UserConfigModel.shared.tutorialsDataParse = true
            }
//            serialQueue.async {
//                
//            }
        }
    }
    func sendHistoryFoodsListRequest(){
        let param = ["fname":""]
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_history_list, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            UserDefaults.set(value: WHUtils.getJSONStringFromArray(array: dataArr), forKey: .hidsoryFoodsAdd)
        }
    }
    
    func sendJpushTestRequest() {
        let param = ["delay":"8000"]
        WHNetworkUtil.shareManager().POST(urlString: URL_jpush_test, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendJpushTestRequest\(dataDict)")
        }
    }
    func sendConstantRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_constant_get, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            ConstantModel.shared.dealDataSource(dict: dataDict)
        }
    }
    func sendNutritionsDefaultCircleRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_get_default_nutrition_circle, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendNutritionsDefaultCircleRequest:\(dataArray)")
            UserDefaults.set(value: dataArray, forKey: .circleGoalArray)
        }
    }
}
