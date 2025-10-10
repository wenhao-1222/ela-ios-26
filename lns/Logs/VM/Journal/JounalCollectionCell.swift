
import Foundation
import UIKit

class JounalCollectionCell: UICollectionViewCell {
    
    var queryDay = ""
    var logsModel = LogsModel(uid: UserInfoModel.shared.uId,
                              sdate: Date().nextDay(days: 0),
                              date: Date().changeDateStringToDate(dateString: Date().nextDay(days: 0)),
                              ctime: "", etime: Date().currentSeconds,
                              foods: "",
                              calori: "",
                              protein: "",
                              carbohydrate: "",
                              fat: "",
                              notes: "",
                              caloriTarget: "",
                              proteinTarget: "",
                              carbohydrateTarget: "",
                              fatTarget: "",
                              isUpload: false,
                              waterNum:"",
                              waterUpload:"0",
                              waterETime: "",
                              circleTag: "",
                              fitnessTag: "",
                              notesTag: "")
    var controller = WHBaseViewVC()
    var isEdit = false
    var isDelete = false
//    static var selectMealsIndex = 0
    var currentDayMsg = NSDictionary()
    var currentMealTimeMsg = NSDictionary()
    var mealsArray = NSMutableArray.init(array: [[],[],[],[],[],[]])
    var mealsForUpload = NSArray()
    var selectMealsIndex = 0
    var selectFoodsIndex = -1
    
    var offsetChangeBlock:((CGFloat)->())?
    var updateFitnessBlock:((String)->())?
    
//    /// 最大收缩偏移
//    private let maxShrinkOffset: CGFloat = kFitWidth(120)
//    /// 最小缩放比例
//    private let minGoalScale: CGFloat = 0.6
    
    
    /// Height of ``goalVm`` when fully expanded
    private var goalOriginalHeight: CGFloat = 0
    /// Minimum height when collapsed
    private var goalMinHeight: CGFloat = 0
    /// Current height used for comparison
    private var currentGoalHeight: CGFloat = 0
    /// Distance that triggers full collapse
    private let goalShrinkRange: CGFloat = kFitWidth(80)
    /// Minimum scale of the circle when collapsed
    private let circleMinScale: CGFloat = 0.7
    
    
    override init(frame: CGRect) {
//        selectMealsIndex = 0
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadStreakMsg), name: NSNotification.Name(rawValue: "reloadStreakMsg"), object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        tableView.bringSubviewToFront(addFirstFoodsAlertVm)
        updateTableViewFrame()
        contentView.bringSubviewToFront(addFirstFoodsAlertVm)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var goalVm: LogsNaturalGoalVM = {
        let vm = LogsNaturalGoalVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        vm.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: vm.frame.height)
        vm.calcuBlock = {()in
//            self.saveDataToSqlDB()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "msgCalculateEnd"), object: nil)
            self.dealParamForRequest()
            HealthKitNaturnalManager().saveNutritionData(calories: self.goalVm.caloriCircleVm.currentNumFloat,
                                                         carbs: self.goalVm.carboCircleVm.currentNumFloat,
                                                                     protein: self.goalVm.proteinCircleVm.currentNumFloat,
                                                                     fat: self.goalVm.fatCircleVm.currentNumFloat,
                                                                     cTime: self.queryDay)
            if self.queryDay == Date().todayDate{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshTodayNutrition"), object: nil)
            }
        }
        vm.updateDataBlock = {()in
            let dict = NSMutableDictionary(dictionary: self.currentDayMsg)
            dict.setValue("\(self.goalVm.caloriCircleVm.currentNum)", forKey: "calories")
            dict.setValue("\(self.goalVm.carboCircleVm.currentNum)", forKey: "carbohydrate")
            dict.setValue("\(self.goalVm.proteinCircleVm.currentNum)", forKey: "protein")
            dict.setValue("\(self.goalVm.fatCircleVm.currentNum)", forKey: "fat")
            dict.setValue("\(self.goalVm.caloriCircleVm.currentNumFloat)", forKey: "caloriesDouble")
            dict.setValue("\(self.goalVm.carboCircleVm.currentNumFloat)", forKey: "carbohydrateDouble")
            dict.setValue("\(self.goalVm.proteinCircleVm.currentNumFloat)", forKey: "proteinDouble")
            dict.setValue("\(self.goalVm.fatCircleVm.currentNumFloat)", forKey: "fatDouble")
            self.currentDayMsg = dict
            HealthKitNaturnalManager().saveNutritionData(calories: self.goalVm.caloriCircleVm.currentNumFloat,
                                                         carbs: self.goalVm.carboCircleVm.currentNumFloat,
                                                                     protein: self.goalVm.proteinCircleVm.currentNumFloat,
                                                                     fat: self.goalVm.fatCircleVm.currentNumFloat,
                                                                     cTime: self.queryDay)
            if self.queryDay == Date().todayDate{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshTodayNutrition"), object: nil)
            }
        }
        vm.addPlanBlock = {()in
            let vc = QuestionnairePreVC()
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }
        vm.goalTapBlock = {()in
            let vc = GoalSetVC()
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }
        vm.updateGoalBlock = {()in
            DLLog(message: "点击修改今日营养目标")
//            if Date().daysDifference(from: self.queryDay) ?? 0 <= 0{
                self.changeCircleTempAlertVm.showSelf()
//            }
        }
        return vm
    }()
    lazy var editSelectAllVm : LogsEditHeadView = {
//        let vm = LogsEditHeadView.init(frame: CGRect.init(x: 0, y: self.goalVm.frame.maxY, width: 0, height: 0))
        let vm = LogsEditHeadView.init(frame: .zero)
        vm.isHidden = true
        vm.tapBlock = {(isSelect)in
            self.allTapAction(isSelect: isSelect)
        }
        return vm
    }()
    lazy var editHeadView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.goalVm.frame.maxY))
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
//        vi.addSubview(editSelectAllVm)
        vi.addSubview(goalVm)
        
        return vi
    }()
    lazy var remarkVm : LogsRemarkNewVM = {
        let vm = LogsRemarkNewVM.init(frame: CGRect.init(x: 0, y: kFitWidth(8), width: 0, height: 0))
        vm.tapBlock = {()in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelEditStatus"), object: nil)
            self.remarkAlertVm.showView()
        }
        return vm
    }()
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()), style: .grouped)
//        let vi = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()-WHUtils().getTabbarHeight()), style: .grouped)
        vi.backgroundColor = .clear//WHColor_16(colorStr: "FAFAFA")
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.sectionFooterHeight = 0
        vi.register(JournalTableViewCell.classForCoder(), forCellReuseIdentifier: "JournalTableViewCell")
        vi.register(JournalWaterViewCell.classForCoder(), forCellReuseIdentifier: "JournalWaterViewCell")
//        vi.register(JournalRemarkViewCell.classForCoder(), forCellReuseIdentifier: "JournalRemarkViewCell")
        vi.register(JournalRemarkTableViewCell.classForCoder(), forCellReuseIdentifier: "JournalRemarkTableViewCell")
        vi.register(JournalNaturalDetailCell.classForCoder(), forCellReuseIdentifier: "JournalNaturalDetailCell")
        vi.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        return vi
    }()
    lazy var remarkAlertVm : LogsRemarkAlertVM = {
        let vm = LogsRemarkAlertVM.init(frame: .zero)
        vm.placeHoldLabel.text = "   "
//        vm.remarkBlock = {(text)in
//            let msgDict = NSMutableDictionary(dictionary: self.currentDayMsg)
//            msgDict.setValue("\(text)", forKey: "notes")
//            self.currentDayMsg = msgDict
//            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
//            self.logsModel.isUpload = false
//            LogsSQLiteManager.getInstance().insertNotes(sDate: self.queryDay, notestr: text)
//            LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: false)
//            LogsSQLiteUploadManager().uploadLogsBySDate(sdate: self.queryDay)
//        }
        vm.hideBlock = {(models,text)in
            let notesTagArray = NSMutableArray()
            models.forEach {
                if $0.hasValue == true{
                    notesTagArray.add(["key":"\($0.name)","value":$0.valueArr])
                }
            }
            DLLog(message: "notesTagArray:\(notesTagArray)")
            let msgDict = NSMutableDictionary(dictionary: self.currentDayMsg)
            msgDict.setValue("\(WHUtils.getJSONStringFromArray(array: notesTagArray))", forKey: "notesTag")
            msgDict.setValue("\(text)", forKey: "notes")
            self.currentDayMsg = msgDict
//            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
            let remarkSection = UserInfoModel.shared.show_water_status ? 2 : 1
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: remarkSection)], with: .none)
            self.logsModel.isUpload = false
            LogsSQLiteManager.getInstance().insertNotes(sDate: self.queryDay, notestr: text)
            LogsSQLiteManager.getInstance().insertNotesTag(sDate: self.queryDay, notesTag: WHUtils.getJSONStringFromArray(array: notesTagArray))
            LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: false)
            LogsSQLiteUploadManager().uploadLogsBySDate(sdate: self.queryDay)
        }
        return vm
    }()
    lazy var fitnessTypeAlertVm: LogsFitnessTypeAlertVM = {
        let vm = LogsFitnessTypeAlertVM.init(frame: .zero)
        vm.confirmBlock = {(fitnessType)in
            self.updateFitnessBlock?(fitnessType)
            let msgDict = NSMutableDictionary(dictionary: self.currentDayMsg)
            msgDict.setValue("\(fitnessType)", forKey: "fitnessLabel")
            self.currentDayMsg = msgDict
            self.logsModel.isUpload = false
            LogsSQLiteManager.getInstance().updateFitnessType(fitnessType: fitnessType, sDate: self.queryDay)
            LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: false)
            LogsSQLiteUploadManager().uploadLogsBySDate(sdate: self.queryDay)
        }
        return vm
    }()
    lazy var fitnessTypeMultipleAlertVm: JournalFitnessTypeAlertVM = {
        let vm = JournalFitnessTypeAlertVM.init(frame: .zero)
        vm.confirmBlock = {(arr)in
            DLLog(message: "fitnessTypeMultipleAlertVm:\(arr)")
            
            let fitnessType = arr.count > 0 ? arr.first : ""
            self.updateFitnessBlock?(fitnessType ?? "")
            let msgDict = NSMutableDictionary(dictionary: self.currentDayMsg)
            msgDict.setValue("\(WHUtils.getJSONStringFromArray(array: arr as NSArray))", forKey: "fitnessLabel")
            self.currentDayMsg = msgDict
            self.logsModel.isUpload = false
//            LogsSQLiteManager.getInstance().updateFitnessType(fitnessType: fitnessType ?? "", sDate: self.queryDay)
            LogsSQLiteManager.getInstance().updateFitnessType(fitnessType: WHUtils.getJSONStringFromArray(array: arr as NSArray), sDate: self.queryDay)
            LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: false)
            LogsSQLiteUploadManager().uploadLogsBySDate(sdate: self.queryDay)
        }
        return vm
    }()
    lazy var timeAlertVm: LogsTimeAlertVM = {
        let vm = LogsTimeAlertVM.init(frame: .zero)
        vm.setAlertBlock = {()in
            let vc = LogsMealsAlertSetVC()
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var addFirstFoodsAlertVm: GuideAddFirstFoodsAlertVM = {
//        let vm = GuideAddFirstFoodsAlertVM.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(160), y: self.goalVm.frame.maxY-kFitWidth(20)-WHUtils().getNavigationBarHeight(), width: 0, height: 0))
        let y = editHeadView.frame.maxY + kFitWidth(12) - kFitWidth(100) 
        let vm = GuideAddFirstFoodsAlertVM.init(frame: CGRect(x: SCREEN_WIDHT - kFitWidth(160), y: y, width: 0, height: 0))
        return vm
    }()
    lazy var changeCircleTempAlertVm: JournalCircleTemplateAlertVM = {
        let vm = JournalCircleTemplateAlertVM.init(frame: .zero)
        vm.confirmBlock = {(dict)in
            self.sendUpdateGoalRequest(dict: dict)
        }
        return vm
    }()
    
    private var idleWorkItem: DispatchWorkItem?
    private var hasShownFirstFoodsGuide = UserDefaults.standard.string(forKey: guide_add_first_foods) == "1"
}

extension JounalCollectionCell{
    func initUI() {
        contentView.addSubview(tableView)
        contentView.addSubview(editHeadView)
        contentView.addSubview(addFirstFoodsAlertVm)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getKeyWindow().addSubview(remarkAlertVm)
        
        appDelegate.getKeyWindow().addSubview(timeAlertVm)
//        appDelegate.getKeyWindow().addSubview(fitnessTypeAlertVm)
        appDelegate.getKeyWindow().addSubview(fitnessTypeMultipleAlertVm)
        appDelegate.getKeyWindow().addSubview(changeCircleTempAlertVm)
        
//        tableView.insertSubview(addFirstFoodsAlertVm, aboveSubview: editHeadView)
//        tableView.bringSubviewToFront(addFirstFoodsAlertVm)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
//            self.addFirstFoodsAlertVm.showSelf()
//            self.tableView.bringSubviewToFront(self.addFirstFoodsAlertVm)
            self.contentView.bringSubviewToFront(self.addFirstFoodsAlertVm)
            
        })
//        startIdleTimer()
//        goalOriginalHeight = goalVm.frame.height
//        goalMinHeight = goalOriginalHeight - kFitWidth(60)
//        currentGoalHeight = goalOriginalHeight
        updateFirstFoodsAlert()
        updateTableViewFrame()
    }
    func showFitnessAlertVm() {
//        self.fitnessTypeAlertVm.fitnessType = currentDayMsg.stringValueForKey(key: "fitnessLabel")
//        self.fitnessTypeAlertVm.showSelf()
        
        let fitnessType = currentDayMsg.stringValueForKey(key: "fitnessLabel")
        
        self.fitnessTypeMultipleAlertVm.selectFitnessType.removeAll()
        //新版本，为json字符串
        let fitnessArray = WHUtils.getArrayFromJSONString(jsonString: fitnessType)
        if fitnessArray.count > 0 {
            for i in 0..<fitnessArray.count{
                self.fitnessTypeMultipleAlertVm.selectFitnessType.append(fitnessArray[i]as? String ?? "")
            }
        }else{
            if fitnessType.count > 0 {
                self.fitnessTypeMultipleAlertVm.selectFitnessType.append(fitnessType)
            }
        }
        
        self.fitnessTypeMultipleAlertVm.showSelf()
    }
    private func startIdleTimer() {
//        guard !hasShownFirstFoodsGuide else { return }
        guard !hasShownFirstFoodsGuide, !hasFoods() ,!UserInfoModel.shared.onboarding_flow_status else { return }
        idleWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            if UserDefaults.standard.string(forKey: guide_total) == nil {
                self.startIdleTimer()
                return
            }
            self.addFirstFoodsAlertVm.showSelf()
            self.hasShownFirstFoodsGuide = true
            UserDefaults.standard.setValue("1", forKey: guide_add_first_foods)
        }
        idleWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: work)
    }

    private func resetIdleTimer() {
        guard !hasShownFirstFoodsGuide else { return }
        startIdleTimer()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        resetIdleTimer()
    }
    
    private func hasFoods() -> Bool {
        for item in mealsArray {
            if let arr = item as? NSArray, arr.count > 0 {
                for i in 0..<arr.count{
                    let foods = arr[i] as? NSDictionary ?? [:]
                    if foods["isSelect"]as? String ?? "" == "1"{
                        return true
                    }
                }
            }
        }
        return false
    }

    private func updateTableViewFrame() {
        let headerHeight = editHeadView.frame.maxY
        tableView.frame = CGRect(x: 0,
                                 y: headerHeight,
                                 width: contentView.bounds.width,
                                 height: contentView.bounds.height - headerHeight)
        addFirstFoodsAlertVm.frame.origin.y = goalVm.frame.maxY - kFitWidth(20) - WHUtils().getNavigationBarHeight()
    }
    
    private func updateFirstFoodsAlert() {
//        tableView.bringSubviewToFront(addFirstFoodsAlertVm)
        contentView.bringSubviewToFront(addFirstFoodsAlertVm)
        if hasFoods() {
            idleWorkItem?.cancel()
            addFirstFoodsAlertVm.closeSelfAction()
            addFirstFoodsAlertVm.isHidden = true
        } else {
            addFirstFoodsAlertVm.isHidden = false
            startIdleTimer()
        }
    }
    @objc func reloadStreakMsg() {
        goalVm.winnerVm.updateUI(dict: UserInfoModel.shared.streakDict)
        goalVm.winnerPopView.updateUI(dict: UserInfoModel.shared.streakDict)
        goalVm.winnerPopView.closeSelfAction()
    }
    func reloadTableView() {
        self.editSelectAllVm.selecImgView.setImgLocal(imgName: "logs_edit_normal")
        self.goalVm.winnerPopView.closeSelfAction()
        if self.isEdit{
            self.goalVm.winnerVm.isHidden = true
            self.editSelectAllVm.isHidden = false
//            self.editHeadView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.editSelectAllVm.frame.maxY)
        }else{
//            self.goalVm.winnerVm.isHidden = false
            goalVm.winnerVm.updateUI(dict: UserInfoModel.shared.streakDict)
            self.editSelectAllVm.isHidden = true
//            self.editHeadView.frame = self.goalVm.frame
            self.allTapAction(isSelect: false)
        }
        self.tableView.reloadData()
//        self.tableView.bringSubviewToFront(self.addFirstFoodsAlertVm)
        contentView.bringSubviewToFront(self.addFirstFoodsAlertVm)
        updateFirstFoodsAlert()
        updateTableViewFrame()
    }
    func setQueryDate(date:String,isEdit:Bool) {
        self.goalVm.refreshHiddenSurveyButton()
        self.changeCircleTempAlertVm.sdate = date
        
        goalOriginalHeight = goalVm.frame.height
        goalMinHeight = goalOriginalHeight - kFitWidth(60)
        currentGoalHeight = goalOriginalHeight

//        let editSelectAllVmFrame = editSelectAllVm.frame
//        editSelectAllVm.frame = CGRect.init(x: editSelectAllVmFrame.origin.x, y: self.goalVm.frame.maxY, width: editSelectAllVmFrame.width, height: editSelectAllVmFrame.height)
        
        self.isEdit = isEdit
        self.queryDay = date
        self.editSelectAllVm.selecImgView.setImgLocal(imgName: "logs_edit_normal")
//        if self.isEdit{
//            self.editSelectAllVm.isHidden = false
//            self.editHeadView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.editSelectAllVm.frame.maxY)
//        }else{
//            self.editSelectAllVm.isHidden = true
//            self.editHeadView.frame = self.goalVm.frame
//        }
        self.editSelectAllVm.isHidden = !self.isEdit

        self.editHeadView.frame = self.goalVm.frame

        self.dealData()
        tableView.setContentOffset(.zero, animated: false)
        goalVm.changeBgAlpha(offsetY: 0)
        goalVm.winnerVm.updateUI(dict: UserInfoModel.shared.streakDict)
        goalVm.winnerPopView.updateUI(dict: UserInfoModel.shared.streakDict)
        
//        self.tableView.bringSubviewToFront(self.addFirstFoodsAlertVm)
        contentView.bringSubviewToFront(self.addFirstFoodsAlertVm)
//        self.dealData()
        updateTableViewFrame()
    }
    func addFoods(foodsMsg:NSDictionary) {
        if foodsMsg.doubleValueForKey(key: "caloriesNumber") >= 100000 || foodsMsg.doubleValueForKey(key: "calories") >= 100000 {
            return
        }
        if foodsMsg.doubleValueForKey(key: "carbohydrateNumber") >= 100000 || foodsMsg.doubleValueForKey(key: "carbohydrate") >= 100000 {
            return
        }
        if foodsMsg.doubleValueForKey(key: "proteinNumber") >= 100000 || foodsMsg.doubleValueForKey(key: "protein") >= 100000 {
            return
        }
        if foodsMsg.doubleValueForKey(key: "fatNumber") >= 100000 || foodsMsg.doubleValueForKey(key: "fat") >= 100000 {
            return
        }
        LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: false)
        logsModel.isUpload = false
        
        let foodsArray = NSMutableArray.init(array: mealsArray[self.selectMealsIndex] as? NSArray ?? [])
        if self.selectFoodsIndex == -1 {
            if foodsMsg.stringValueForKey(key: "fname") == "快速添加"{
                foodsArray.add(foodsMsg)
            }else{
                var hasData = false
                for i in 0..<foodsArray.count{
                    let dict = foodsArray[i]as? NSDictionary ?? [:]
                    
                    let dictFid = dict.stringValueForKey(key: "fid")
                    
                    if dictFid != "-1" &&  dictFid == foodsMsg.stringValueForKey(key: "fid") && (dict["spec"]as? String ?? "" == foodsMsg["spec"]as? String ?? "" || (dict["spec"]as? String ?? "" == "" && foodsMsg["spec"]as? String ?? "" == "g")){
                        let foodsDict = NSMutableDictionary.init(dictionary: dict)
                        let specNum = foodsMsg.doubleValueForKey(key: "qty")
                        foodsDict.setValue(foodsMsg["foods"]as? NSDictionary ?? [:], forKey: "foods")
                        
                        if dict.stringValueForKey(key: "state") == "1"{
                            var dictNum = dict.doubleValueForKey(key: "qty")
                            if dictNum == 0 {
                                dictNum = dict.doubleValueForKey(key: "weight")
                            }
                            let num = dictNum + specNum
                            
                            foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                            foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                            
                            let caloriesNumber = foodsMsg.doubleValueForKey(key: "caloriesNumber")
                            let calories = caloriesNumber/specNum * num
                            
                            let calori = calories
                            let carbo = foodsDict.doubleValueForKey(key: "carbohydrate") + foodsMsg.doubleValueForKey(key: "carbohydrateNumber")
                            let protein = foodsDict.doubleValueForKey(key: "protein") + foodsMsg.doubleValueForKey(key: "proteinNumber")
                            let fat = foodsDict.doubleValueForKey(key: "fat") + foodsMsg.doubleValueForKey(key: "fatNumber")
                            
                            foodsDict.setValue("\(WHUtils.convertStringToStringNoDigit("\(calori)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                            foodsDict.setValue("\(carbo)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                            foodsDict.setValue("\(protein)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                            foodsDict.setValue("\(fat)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                            foodsDict.setValue("1", forKey: "state")
                        }else{
                            foodsDict.setValue("\(specNum)".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                            foodsDict.setValue("\(specNum)".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                            let calori = foodsMsg.doubleValueForKey(key: "caloriesNumber")
                            let carbo = foodsMsg.doubleValueForKey(key: "carbohydrateNumber")
                            let protein = foodsMsg.doubleValueForKey(key: "proteinNumber")
                            let fat = foodsMsg.doubleValueForKey(key: "fatNumber")
                            
                            foodsDict.setValue("\(WHUtils.convertStringToStringNoDigit("\(calori)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                            foodsDict.setValue("\(carbo)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                            foodsDict.setValue("\(protein)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                            foodsDict.setValue("\(fat)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                            foodsDict.setValue("1", forKey: "state")
                        }
                        if foodsArray.count > i {
                            if foodsMsg.doubleValueForKey(key: "specNum") > 0{
                                foodsArray.replaceObject(at: i, with: foodsDict)
                            }else{
                                foodsArray.removeObject(at: i)
                            }
                            hasData = true
                        }else{
//                            self.addFoods(foodsMsg:foodsMsg)
                            return
                        }
                        
                        break
                    }
                }
                if hasData == false{
                    if foodsMsg.stringValueForKey(key: "fname") == "快速添加"{
                        foodsArray.add(foodsMsg)
                    }else if foodsMsg.doubleValueForKey(key: "specNum") > 0{
                        foodsArray.add(foodsMsg)
                    }
                }
            }
        }else{
            var hasData = false
            if foodsMsg.stringValueForKey(key: "fname") == "快速添加"{
                foodsArray.replaceObject(at: self.selectFoodsIndex, with: foodsMsg)
            }else{
                for i in 0..<foodsArray.count{
                    let dict = foodsArray[i]as? NSDictionary ?? [:]
                    
                    var dictFid = dict["fid"]as? String ?? "\(dict["fid"]as? Int ?? -1)"
                    
                    if dictFid != "-1" &&  dictFid == foodsMsg["fid"]as? String ?? "\(foodsMsg["fid"]as? Int ?? -2)" && dict["spec"]as? String ?? "" == foodsMsg["spec"]as? String ?? ""{
                        let foodsDict = NSMutableDictionary.init(dictionary: dict)
                        foodsDict.setValue(foodsMsg["foods"]as? NSDictionary ?? [:], forKey: "foods")
                        if self.selectFoodsIndex == i {
                            foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "qty"))".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                            foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "qty"))".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                            foodsDict.setValue("\(WHUtils.convertStringToStringNoDigit("\(foodsMsg.doubleValueForKey(key: "caloriesNumber"))") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                            foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "carbohydrateNumber"))".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                            foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "proteinNumber"))".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                            foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "fatNumber"))".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                            foodsDict.setValue("1", forKey: "state")
                            if foodsArray.count > i {
                                if foodsMsg.doubleValueForKey(key: "specNum") > 0{
                                    foodsArray.replaceObject(at: i, with: foodsDict)
                                }else{
                                    foodsArray.removeObject(at: i)
                                }
                            }else{
//                                self.addFoods(foodsMsg:foodsMsg)
                                return
                            }
                        }else{
                            let specNum = foodsMsg.doubleValueForKey(key: "qty")
                            var dictNum = dict.doubleValueForKey(key: "qty")
                            if dictNum == 0 {
                                dictNum = Double(((dict["qty"]as? String ?? "0") as NSString).intValue)
                            }
                            let num = dictNum + specNum
                            
                            foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                            foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                            
                            let caloriesNumber = foodsMsg.doubleValueForKey(key: "caloriesNumber")
                            let calories = caloriesNumber/specNum * num
                            
                            let calori = calories
                            
                            let carbo = foodsDict.doubleValueForKey(key: "carbohydrate") + foodsMsg.doubleValueForKey(key: "carbohydrateNumber")
                            let protein = foodsDict.doubleValueForKey(key: "protein") + foodsMsg.doubleValueForKey(key: "proteinNumber")
                            let fat = foodsDict.doubleValueForKey(key: "fat") + foodsMsg.doubleValueForKey(key: "fatNumber")
                            
                            foodsDict.setValue("\(WHUtils.convertStringToStringNoDigit("\(calori)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                            foodsDict.setValue("\(carbo)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                            foodsDict.setValue("\(protein)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                            foodsDict.setValue("\(fat)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                            foodsDict.setValue("1", forKey: "state")
                            
                            if foodsArray.count > i{
                                if foodsMsg.doubleValueForKey(key: "specNum") > 0{
                                    foodsArray.replaceObject(at: i, with: foodsDict)
                                    foodsArray.removeObject(at: self.selectFoodsIndex)
                                }else{
                                    foodsArray.removeObject(at: self.selectFoodsIndex)
                                }
                            }else{
//                                self.addFoods(foodsMsg:foodsMsg)
                                return
                            }
                        }
                        hasData = true
                        break
                    }
                }
                if hasData == false{
                    if foodsArray.count > self.selectFoodsIndex{
                        if foodsMsg.doubleValueForKey(key: "specNum") > 0{
                            foodsArray.replaceObject(at: self.selectFoodsIndex, with: foodsMsg)
                        }else{
                            foodsArray.removeObject(at: self.selectFoodsIndex)
                        }
                    }else{
//                        self.addFoods(foodsMsg:foodsMsg)
                        return
                    }
                }
            }
        }
        
        if mealsArray.count > self.selectMealsIndex{
            if foodsMsg.stringValueForKey(key: "fname") != "快速添加" && foodsMsg.stringValueForKey(key: "fid").count > 0{
                WHUtils().sendAddFoodsForCountRequest(fids: [foodsMsg.stringValueForKey(key: "fid")])
                WHUtils().sendAddHistoryFoods(foodsMsgArray: [foodsMsg])
            }
            
            mealsArray.replaceObject(at: self.selectMealsIndex, with: foodsArray)
            saveDataToSqlDB()
            self.tableView.reloadData()
            updateFirstFoodsAlert()
            self.calculateNaturalNum()
            self.checkPushAuthAfterSecondMeal()
        }else{
//            self.addFoods(foodsMsg: foodsMsg)
        }
    }
    private func checkPushAuthAfterSecondMeal() {
        let key = UserDefaults.AccountKeys.push_authori_second_foods.rawValue
        if UserDefaults.standard.string(forKey: key) == "14" { return }

        var count = 0
        for item in mealsArray {
//            if let arr = item as? NSArray, arr.count > 0 { count += 1 }
            if let arr = item as? NSArray {
                count += arr.count
            }
        }
        if count < 2 { return }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus != .authorized {
                UserInfoModel.shared.showNotifiAuthoriAlertVM = true
                DispatchQueue.main.async {
                    if let vc = self.controller as? JournalVC,
                       UIApplication.topViewController() === vc {
                        vc.notifiAuthoriAlertVm.showView()
                    }
                }
            }
        }
        
        UserDefaults.standard.setValue("1", forKey: key)
    }
}

extension JounalCollectionCell:UITableViewDelegate,UITableViewDataSource{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closeEditStatus"), object: nil)
        self.goalVm.winnerPopView.closeSelfAction()
        self.addFirstFoodsAlertVm.closeSelfAction()
        
        let offsetY = scrollView.contentOffset.y
        self.offsetChangeBlock?(offsetY)
        
        if isEdit {
           let minY = goalVm.frame.maxY
           let headerHeight = editSelectAllVm.frame.height
           if offsetY > 0 {
               // Move the select all view and table view upward along with the scroll
               editSelectAllVm.frame.origin.y = minY - offsetY
//               tableView.frame.origin.y = minY + headerHeight - offsetY
           } else {
               // Reset positions when scrolled back to top
               editSelectAllVm.frame.origin.y = minY
//               tableView.frame.origin.y = minY + headerHeight
           }
       }
        
        goalVm.changeBgAlpha(offsetY: offsetY)
        resetIdleTimer()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        var sectionNum = 1
        
        if UserInfoModel.shared.show_water_status{
            sectionNum += 1
        }
        
        if UserInfoModel.shared.abTestModel.diet_log_note == .A{
            sectionNum += 1
        }
//        if self.queryDay == Date().todayDate{
            sectionNum += 1
//        }
        return sectionNum
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return UserInfoModel.shared.mealsNumber
        }else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "JournalTableViewCell") as? JournalTableViewCell
            
            if self.mealsArray.count > 0 && self.mealsArray.count > indexPath.row{
                let foodsArr = self.mealsArray[indexPath.row]as? NSArray ?? []
                cell?.updateUI(array: foodsArr,isEdit:self.isEdit,isToday: self.queryDay==Date().todayDate,sn: "\(indexPath.row)", queryDate: self.queryDay)
            }else{
                cell?.updateUI(array: [],isEdit:self.isEdit,isToday: self.queryDay==Date().todayDate,sn: "\(indexPath.row)", queryDate: self.queryDay)
            }
            cell?.titleLabel.text = "第 \(indexPath.row+1) 餐"
//            cell?.refreshTodayAdvice(isToday: self.queryDay == Date().todayDate, sn: "\(indexPath.row+1)")
            cell?.updateMealsTime(mealsDict: self.currentMealTimeMsg,mealsIndex:indexPath.row+1)
    //        let mealsTime = self.currentDayMsg.stringValueForKey(key: "mealTimeSn1")
            cell?.controller = UIApplication.topViewController() ?? self.controller//self.controller
            
            cell?.timeChangeBlock = {(time)in
                self.timeAlertVm.showView()
                self.timeAlertVm.updateTime(time: time, mealsIndex: indexPath.row+1,sDate:self.currentDayMsg.stringValueForKey(key: "sdate"))
            }
            cell?.addBlock = {()in
                self.selectMealsIndex = indexPath.row
                self.selectFoodsIndex = -1
                let vc = FoodsListNewVC()//FoodsListVC()
                vc.sourceType = .logs
                self.controller.navigationController?.pushViewController(vc, animated: true)
            }
            cell?.deleteBlock = {(dict)in
                self.selectMealsIndex = indexPath.row
                self.delecteFoods(foodsMsg: dict)
            }
            cell?.deleteCellBlock = {(dict,index)in
                self.selectMealsIndex = indexPath.row
                self.delecteFoodsCell(foodsMsg: dict, index: index)
            }
            cell?.selectCellBlock = {(isSelect,index)in
                self.selectMealsIndex = indexPath.row
                self.singelCellTapAction(isSelect: isSelect, cellIndex: index)
            }
            cell?.selectBlock = {(isSelect)in
                self.selectMealsIndex = indexPath.row
                self.mealsSelectAction(isSelect: isSelect)
            }
            cell?.selectMeaslIndexBlock = {(foodsIndex)in
                self.selectMealsIndex = indexPath.row
                self.selectFoodsIndex = foodsIndex
            }
            cell?.eatTapBlock = {(foodsIndex)in
                self.selectMealsIndex = indexPath.row
                self.eatCellTapAction(cellIndex: foodsIndex)
            }
            cell?.closeMealAdviceBlock = {()in
                self.sendNextMealAdviceConfigRequest(statu: false,indexPath: indexPath)
            }
            return cell ?? JournalTableViewCell()
        }else{
            if indexPath.section == 1{
                if UserInfoModel.shared.show_water_status{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JournalWaterViewCell")as? JournalWaterViewCell
                    cell?.updateUI(num: self.currentDayMsg.stringValueForKey(key: "waterNum"))
                    cell?.addBlock = {()in
                        DLLog(message: "添加饮水量")
                        let vc = JournalWaterVC()
                        vc.sDate = self.queryDay
                        vc.totalNum = 0
                        vc.numChangeBlock = {(waterNum)in
                            self.currentDayMsg.setValue(waterNum, forKey: "waterNum")
                            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                        }
                        self.controller.navigationController?.pushViewController(vc, animated: true)
                    }
                    cell?.totalBlock = {()in
                        let vc = JournalWaterVC()
                        vc.sDate = self.queryDay
                        vc.totalNum = self.currentDayMsg.stringValueForKey(key: "waterNum").intValue
                        vc.numChangeBlock = {(waterNum)in
                            self.currentDayMsg.setValue(waterNum, forKey: "waterNum")
                            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                        }
                        self.controller.navigationController?.pushViewController(vc, animated: true)
                    }
                    cell?.deleteBlock = {()in
                        HealthKitNaturnalManager().saveWaterData(sdate: self.queryDay, waterNum: 0, isTotal: true)
                        self.sendWaterSynRequest(waterNum: "0")
                        LogsSQLiteManager.getInstance().insertWater(sDate: self.queryDay, waterNum: "0")
                    }
                    return cell ?? JournalWaterViewCell()
                }else if UserInfoModel.shared.abTestModel.diet_log_note == .A{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JournalRemarkTableViewCell") as? JournalRemarkTableViewCell
                    cell?.updateContent(remark: self.currentDayMsg.stringValueForKey(key: "notes"),
                                        notesTag: self.currentDayMsg.stringValueForKey(key: "notesTag"),
                                        queryDay: self.queryDay)
                    
                    cell?.remarkBlock = {()in
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelEditStatus"), object: nil)
                        self.remarkAlertVm.showView()
                    }
//                    
//                    cell?.detalBlock = {()in
//                        self.naturalDetailTapAction()
//                    }
//                    
                    return cell ?? JournalRemarkTableViewCell()
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JournalNaturalDetailCell") as? JournalNaturalDetailCell
                    cell?.detalBlock = {()in
                        self.naturalDetailTapAction()
                    }
                    cell?.detalOldBlock = {()in
                        self.naturalDetailOldTapAction()
                    }
                    
                    return cell ?? JournalNaturalDetailCell()
                }
            }else if indexPath.section == 2{
                if UserInfoModel.shared.abTestModel.diet_log_note == .A{
                    if UserInfoModel.shared.show_water_status {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalRemarkTableViewCell") as? JournalRemarkTableViewCell
                        cell?.updateContent(remark: self.currentDayMsg.stringValueForKey(key: "notes"),
                                            notesTag: self.currentDayMsg.stringValueForKey(key: "notesTag"),
                                            queryDay: self.queryDay)

                        cell?.remarkBlock = {()in
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelEditStatus"), object: nil)
                            self.remarkAlertVm.showView()
                        }
//                        
//                        cell?.detalBlock = {()in
//                            self.naturalDetailTapAction()
//                        }
                        
                        return cell ?? JournalRemarkTableViewCell()
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalNaturalDetailCell") as? JournalNaturalDetailCell
                        cell?.detalBlock = {()in
                            self.naturalDetailTapAction()
                        }
                        cell?.detalOldBlock = {()in
                            self.naturalDetailOldTapAction()
                        }
                        
                        return cell ?? JournalNaturalDetailCell()
                    }
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JournalNaturalDetailCell") as? JournalNaturalDetailCell
                    cell?.detalBlock = {()in
                        self.naturalDetailTapAction()
                    }
                    cell?.detalOldBlock = {()in
                        self.naturalDetailOldTapAction()
                    }
                    
                    return cell ?? JournalNaturalDetailCell()
                }
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "JournalNaturalDetailCell") as? JournalNaturalDetailCell
                cell?.detalBlock = {()in
                    self.naturalDetailTapAction()
                }
                cell?.detalOldBlock = {()in
                    self.naturalDetailOldTapAction()
                }
                
                return cell ?? JournalNaturalDetailCell()
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if self.mealsArray.count > 0 && self.mealsArray.count > indexPath.row{
                let foodsArr = self.mealsArray[indexPath.row]as? NSArray ?? []
                if foodsArr.count > 0 {
                    return kFitWidth(143)+CGFloat(foodsArr.count)*kFitWidth(55)+kFitWidth(12)
                }else{
//                    return kFitWidth(82)
                    var labelText = "请添加食物"
                    var btnHeight = kFitWidth(0)
                    if self.queryDay == Date().todayDate && UserInfoModel.shared.show_next_advice{
                        let adviceDict = UserDefaults.getDictionary(forKey: .jounal_meal_advice) as? NSDictionary ?? [:]
                        if "\(indexPath.row)" == adviceDict.stringValueForKey(key: "sn") && adviceDict.stringValueForKey(key: "uid") == UserInfoModel.shared.uId && self.queryDay == adviceDict.stringValueForKey(key: "sdate") && adviceDict.stringValueForKey(key: "advice").count > 0 {
                            labelText = adviceDict.stringValueForKey(key: "advice")
                            btnHeight = kFitWidth(20)
                        }
                    }
                    let labelWidth = SCREEN_WIDHT - kFitWidth(20) - kFitWidth(30)
                    let labelHeight = labelText.mc_getHeight(font: .systemFont(ofSize: 12, weight: .regular), width: labelWidth)
                    return kFitWidth(42)+labelHeight+kFitWidth(12)+kFitWidth(12)+btnHeight
                }
            }else{
                var labelText = "请添加食物"
                var btnHeight = kFitWidth(0)
                if self.queryDay == Date().todayDate && UserInfoModel.shared.show_next_advice{
                    let adviceDict = UserDefaults.getDictionary(forKey: .jounal_meal_advice) as? NSDictionary ?? [:]
                    if "\(indexPath.row)" == adviceDict.stringValueForKey(key: "sn") && adviceDict.stringValueForKey(key: "uid") == UserInfoModel.shared.uId && self.queryDay == adviceDict.stringValueForKey(key: "sdate") && adviceDict.stringValueForKey(key: "advice").count > 0 {
                        labelText = adviceDict.stringValueForKey(key: "advice")
                        btnHeight = kFitWidth(20)
                    }
                }
                let labelWidth = SCREEN_WIDHT - kFitWidth(20) - kFitWidth(30)
                let labelHeight = labelText.mc_getHeight(font: .systemFont(ofSize: 12, weight: .regular), width: labelWidth)
                return kFitWidth(42)+labelHeight+kFitWidth(12)+kFitWidth(12)+btnHeight
            }
        }else{
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            var headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderViewIdentifier")
//            
//            if headerView == nil{
//                headerView = UITableViewHeaderFooterView(reuseIdentifier: "HeaderViewIdentifier")
//                headerView?.addSubview(self.editHeadView)
//            }
//            return headerView
//        }else{
//            return nil
//        }
        if section == 0 && isEdit {
            return editSelectAllVm
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return self.editHeadView.frame.height
//        }else{
//            return 0
//        }
        if section == 0 && isEdit {
            return editSelectAllVm.frame.height
        }
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension JounalCollectionCell{
    func editDelAction() {
        LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: false)
        logsModel.isUpload = false
        self.isDelete = true
        for i in 0..<self.mealsArray.count{
            if self.mealsArray.count > i{
                let foodsArray = NSMutableArray.init(array: mealsArray[i]as? NSArray ?? [])
                let saveFoodsArray = NSMutableArray.init(array: mealsArray[i]as? NSArray ?? [])
                for j in 0..<foodsArray.count{
                    let index = foodsArray.count-1-j
                    let foodsDi = NSMutableDictionary.init(dictionary: foodsArray[index]as? NSDictionary ?? [:])
                    if foodsDi["isSelect"]as? String ?? "" == "1"{
                        saveFoodsArray.removeObject(at: index)
                    }
                }
                mealsArray.replaceObject(at: i, with: saveFoodsArray)
            }
        }
        saveDataToSqlDB()
        self.isEdit = false
        self.editSelectAllVm.selecImgView.setImgLocal(imgName: "logs_edit_normal")
        self.editSelectAllVm.isHidden = true
        self.editHeadView.frame = self.goalVm.frame
        
        tableView.reloadData()
        calculateNaturalNum()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelEditStatus"), object: nil)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelEditStatus"), object: nil)
        updateTableViewFrame()
    }
}

extension JounalCollectionCell{
    func dealData(){
        logsModel = LogsSQLiteManager.getInstance().getLogsByDate(sDate: self.queryDay)!
        let sportDict = SportDataSQLiteManager.getInstance().querySportsData(sDate: self.queryDay)
        DLLog(message: "SportDataSQLiteManager:\(sportDict)")
        
        let dict = NSMutableDictionary(dictionary: logsModel.modelToDict())
        if UserInfoModel.shared.statSportDataToTarget == "1"{
            dict.setValue("\(sportDict.stringValueForKey(key: "sportCalories"))", forKey: "sportCalories")
        }else{
            dict.setValue("", forKey: "sportCalories")
        }
        self.currentDayMsg = dict//logsModel.modelToDict()
        setTodayGoal()
        self.currentMealTimeMsg = LogsSQLiteManager.getInstance().queryLogsDataForMealsTime(sDate: self.queryDay)
//        if logsModel.foods == "[[],[],[],[],[],[]]" && logsModel.notes == "" {
//            sendLogsDetailRequest()
//        }else{
            goalVm.updateUI(dict: self.currentDayMsg,isUpload: false)
            
            mealsArray.removeAllObjects()
            mealsArray.addObjects(from: (self.currentDayMsg["foods"]as? NSArray ?? []) as! [Any])
            if mealsArray.count == 0 {
                mealsArray = NSMutableArray.init(array: [[],[],[],[],[],[]])
            }
            self.tableView.reloadData()
        updateFirstFoodsAlert()
        self.remarkVm.updateContent(text: self.currentDayMsg["notes"]as? String ?? "")
        self.remarkAlertVm.updateContext(text: self.currentDayMsg["notes"]as? String ?? "",
                                         notesTag: self.currentDayMsg.stringValueForKey(key: "notesTag"))
//        }
        
        if self.queryDay == Date().nextDay(days: 0){
            WidgetUtils().dealCurrentMealsDataForWidget(mealsArray: mealsArray)
        }
        
//        LogsSQLiteUploadManager().saveLocalNaturalData(dict: currentDayMsg)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.sendLogsDetailRequest()
        })
//        setTodayGoal()
    }
    func setTodayGoal() {
        if self.queryDay == Date().nextDay(days: 0){
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
    }
    func dealServerData(dict:NSDictionary) {
        if self.queryDay != dict.stringValueForKey(key: "sdate"){
            return
        }
        var serverETime = dict.stringValueForKey(key: "etime")
        //本地etime 小于 服务器的etime ，说明本地数据需要更新
        logsModel = LogsSQLiteManager.getInstance().getLogsByDate(sDate: self.queryDay)!
        
        let waterDict = dict["dietLogWater"]as? NSDictionary ?? [:]
        let serverWaterETime = waterDict.stringValueForKey(key: "etime").replacingOccurrences(of: "T", with: " ")
        
        let dictTemp = NSMutableDictionary(dictionary: logsModel.modelToDict())
        if UserInfoModel.shared.statSportDataToTarget == "1"{
            dictTemp.setValue(dict.stringValueForKey(key: "sportCalories"), forKey: "sportCalories")
        }else{
            dictTemp.setValue("", forKey: "sportCalories")
        }
        
        if serverWaterETime.count > 0 && (logsModel.waterETime == "" || Date().judgeMin(firstTime: logsModel.waterETime, secondTime: serverWaterETime)) {
            dictTemp.setValue(waterDict.stringValueForKey(key: "qty"), forKey: "waterNum")
            dictTemp.setValue("1", forKey: "waterUpload")
            dictTemp.setValue(serverWaterETime, forKey: "waterEtime")
        }
        self.currentDayMsg = dictTemp//logsModel.modelToDict()
        self.currentMealTimeMsg = LogsSQLiteManager.getInstance().queryLogsDataForMealsTime(sDate: self.queryDay)
        mealsArray.removeAllObjects()
        mealsArray.addObjects(from: (self.currentDayMsg["foods"]as? NSArray ?? []) as! [Any])
        if mealsArray.count == 0 {
            mealsArray = NSMutableArray.init(array: [[],[],[],[],[],[]])
        }
        SportDataSQLiteManager.getInstance().updateSportsNumber(sDate: dict.stringValueForKey(key: "sdate"), calories: dict.stringValueForKey(key: "sportCalories"), duration: dict.stringValueForKey(key: "sportDuration"))
        if serverETime.contains("T"){
            serverETime = serverETime.replacingOccurrences(of: "T", with: " ")
        }
        //本地更新时间早于服务器的etime，或者本地的热量摄入/热量目标为空，此时用服务器返回的数据显示
        if Date().judgeMin(firstTime: logsModel.etime, secondTime: serverETime) ||
            logsModel.caloriTarget.intValue != dict.stringValueForKey(key: "caloriesden").intValue ||
            logsModel.carbohydrateTarget.intValue != dict.stringValueForKey(key: "carbohydrateden").intValue ||
            logsModel.proteinTarget.intValue != dict.stringValueForKey(key: "proteinden").intValue ||
            logsModel.fatTarget.intValue != dict.stringValueForKey(key: "fatden").intValue{//} || logsModel.caloriTarget == "0" {//}|| logsModel.etime == serverETime{
            //TODO:  || logsModel.etime == serverETime  因为同时提交多种食物的时候，后台数据处理会出错
            // TODO:  通过餐食/食谱等功能添加食物时，先将本地数据库更新，再一起提交日志到后台
//            let waterDict = dict["dietLogWater"]as? NSDictionary ?? [:]
            
            let msgDict = NSMutableDictionary(dictionary: dict)
            msgDict.setValue(waterDict.stringValueForKey(key: "qty"), forKey: "waterNum")
            msgDict.setValue("1", forKey: "waterUpload")
            msgDict.setValue(serverWaterETime, forKey: "eTime")
            if let notesLabelArr = dict["notesLabel"] as? NSArray{
                msgDict.setValue(WHUtils.getJSONStringFromArray(array: notesLabelArr ), forKey: "notesTag")
            }else{
                msgDict.setValue(dict.stringValueForKey(key: "notesLabel"), forKey: "notesTag")
            }
            var fitnessLabelArray = NSMutableArray(array: msgDict["fitnessLabelArray"]as? NSArray ?? [])
            for i in 0..<fitnessLabelArray.count{
                let str = fitnessLabelArray[i]as? String ?? ""
                if str == "-" || str == "[]"{
                    fitnessLabelArray.removeObject(at: i)
                    break
                }
            }
            
            var fitnessLabel = msgDict.stringValueForKey(key: "fitnessLabel")
            if fitnessLabelArray.count > 0{
                fitnessLabel = WHUtils.getJSONStringFromArray(array: fitnessLabelArray)
                msgDict.setValue(fitnessLabel, forKey: "fitnessLabel")
                self.updateFitnessBlock?(fitnessLabelArray[0]as? String ?? "")
            }else{
                if fitnessLabel == "-"{
                    fitnessLabel = ""
                }
                self.updateFitnessBlock?(fitnessLabel)
            }
            
            self.currentDayMsg = msgDict
            self.currentMealTimeMsg = dict
            goalVm.updateUI(dict: self.currentDayMsg,isUpload: false)
            LogsSQLiteUploadManager().saveNaturalData(dict: dict, isServerData: true)
            self.remarkVm.updateContent(text: self.currentDayMsg["notes"]as? String ?? "")
            self.remarkAlertVm.updateContext(text: self.currentDayMsg["notes"]as? String ?? "",
                                             notesTag: self.currentDayMsg.stringValueForKey(key: "notesTag"))
            mealsArray.removeAllObjects()
            mealsArray.addObjects(from: (self.currentDayMsg["foods"]as? NSArray ?? []) as! [Any])
            if mealsArray.count == 0 {
                mealsArray = NSMutableArray.init(array: [[],[],[],[],[],[]])
            }
            setTodayGoal()
            self.tableView.reloadData()
            updateFirstFoodsAlert()
            
            if self.currentDayMsg.stringValueForKey(key: "etime") == "" && (WHUtils.getJSONStringFromArray(array: self.currentDayMsg["foods"]as? NSArray ?? []) == "[]" || WHUtils.getJSONStringFromArray(array: self.currentDayMsg["foods"]as? NSArray ?? []) == ""){
                return
            }
            
            LogsSQLiteManager.getInstance().updateLogs(sDate: self.queryDay,
                                                       eTime: serverETime,
                                                       calori: self.currentDayMsg.stringValueForKey(key: "calories"),
                                                       protein: self.currentDayMsg.stringValueForKey(key: "protein"),
                                                       carbohydrates: self.currentDayMsg.stringValueForKey(key: "carbohydrate"),
                                                       fats: self.currentDayMsg.stringValueForKey(key: "fat"),
                                                       notes: self.currentDayMsg.stringValueForKey(key: "notes"),
                                                       foods: WHUtils.getJSONStringFromArray(array: self.currentDayMsg["foods"]as? NSArray ?? []),
                                                       caloriTar: self.currentDayMsg.stringValueForKey(key: "caloriesden"),
                                                       proteinTar: self.currentDayMsg.stringValueForKey(key: "proteinden"),
                                                       carboTar: self.currentDayMsg.stringValueForKey(key: "carbohydrateden"),
                                                       fatsTar: self.currentDayMsg.stringValueForKey(key: "fatden"),
                                                       circleTag: self.currentDayMsg.stringValueForKey(key: "carbLabel"),
//                                                       fitnessTag: self.currentDayMsg.stringValueForKey(key: "fitnessLabel"),
                                                       fitnessTag: fitnessLabel,
                                                       notesTag: self.currentDayMsg.stringValueForKey(key: "notesTag"))
            LogsSQLiteManager.getInstance().updateMealsTime(logsDict: self.currentDayMsg)
            LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: true)
            LogsSQLiteManager.getInstance().updateWaterMsgWithServer(sDate: self.queryDay,
                                                                     waterNum: self.currentDayMsg.stringValueForKey(key: "waterNum"),
                                                                     update: true,
                                                                     eTime: serverWaterETime)
            logsModel = LogsSQLiteManager.getInstance().getLogsByDate(sDate: self.queryDay)!
            return
        }else if logsModel.etime != serverETime{
            logsModel.isUpload = false
            LogsSQLiteUploadManager().saveNaturalData(dict: currentDayMsg, isServerData: false)
//            self.dealParamForRequest()
        }
        goalVm.updateUI(dict: self.currentDayMsg,isUpload: true)
        self.tableView.reloadData()
        updateFirstFoodsAlert()
    }
    //重新计算营养目标数值
    func calculateNaturalNum() {
        let dict = NSMutableDictionary(dictionary: self.currentDayMsg)
        dict.setValue(mealsArray, forKey: "foods")
        self.currentDayMsg = dict
        logsModel.isUpload = false
        goalVm.updateUI(dict: self.currentDayMsg,isUpload: true)
    }
    func dealParamForRequest() {
        let param = NSMutableArray()
        
        let dict = NSMutableDictionary(dictionary: self.currentDayMsg)
        dict.setValue("\(self.goalVm.caloriCircleVm.currentNum)".replacingOccurrences(of: ",", with: "."), forKey: "calories")
        dict.setValue("\(self.goalVm.carboCircleVm.currentNum)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
        dict.setValue("\(self.goalVm.proteinCircleVm.currentNum)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
        dict.setValue("\(self.goalVm.fatCircleVm.currentNum)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
        dict.setValue("\(self.goalVm.caloriCircleVm.currentNumFloat)".replacingOccurrences(of: ",", with: "."), forKey: "caloriesDouble")
        dict.setValue("\(self.goalVm.carboCircleVm.currentNumFloat)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrateDouble")
        dict.setValue("\(self.goalVm.proteinCircleVm.currentNumFloat)".replacingOccurrences(of: ",", with: "."), forKey: "proteinDouble")
        dict.setValue("\(self.goalVm.fatCircleVm.currentNumFloat)".replacingOccurrences(of: ",", with: "."), forKey: "fatDouble")
        self.currentDayMsg = dict
        
        for i in 0..<self.mealsArray.count{
            let foodsArray = NSMutableArray.init(array: self.mealsArray[i]as? NSArray ?? [])
            
            for j in 0..<foodsArray.count{
                let foodsDi = foodsArray[j]as? NSDictionary ?? [:]
                let dic = NSMutableDictionary.init(dictionary: foodsDi)
                dic.setValue("\(i+1)", forKey: "sn")
                dic.setValue("\(WHUtils.convertStringToStringOneDigit(dic.stringValueForKey(key: "calories")) ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                let qty = "\(dic["specNum"]as? String ?? "")".replacingOccurrences(of: ",", with: ".")
                if qty.count > 0 {
                    dic.setValue(qty, forKey: "qty")
//                    dic.setValue("\(dic["specName"]as? String ?? "")", forKey: "spec")
                }
                foodsArray.replaceObject(at: j, with: dic)
            }
            
            param.add(foodsArray)
        }
        self.mealsArray = param
    }
    func saveDataToSqlDB(){
        let param = NSMutableArray()
        
        for i in 0..<mealsArray.count{
            let foodsArray = NSMutableArray.init(array: mealsArray[i]as? NSArray ?? [])
            
            for j in 0..<foodsArray.count{
                let foodsDi = foodsArray[j]as? NSDictionary ?? [:]
                let dic = NSMutableDictionary.init(dictionary: foodsDi)
                dic.setValue("\(i+1)", forKey: "sn")
                
                foodsArray.replaceObject(at: j, with: dic)
            }
            
            param.add(foodsArray)
        }
        DLLog(message: "self.currentDayMsg:\(self.currentDayMsg)")
        LogsSQLiteManager.getInstance().updateLogs(sDate: self.queryDay,
                                                   eTime: Date().currentSeconds,
                                                   calori: "\(self.goalVm.caloriCircleVm.currentNumFloat)",
                                                   protein: "\(self.goalVm.proteinCircleVm.currentNumFloat)",
                                                   carbohydrates: "\(self.goalVm.carboCircleVm.currentNumFloat)",
                                                   fats: "\(self.goalVm.fatCircleVm.currentNumFloat)",
                                                   notes: self.currentDayMsg.stringValueForKey(key: "notes"),
                                                   foods: WHUtils.getJSONStringFromArray(array: param),
                                                   caloriTar: "\(self.goalVm.caloriCircleVm.totalNum)",
                                                   proteinTar: "\(self.goalVm.proteinCircleVm.totalNum)",
                                                   carboTar: "\(self.goalVm.carboCircleVm.totalNum)",
                                                   fatsTar: "\(self.goalVm.fatCircleVm.totalNum)",
                                                   circleTag: self.currentDayMsg.stringValueForKey(key: "carbLabel"),
                                                   fitnessTag: self.currentDayMsg.stringValueForKey(key: "fitnessLabel"),
                                                   notesTag: self.currentDayMsg.stringValueForKey(key: "notesTag"))
        LogsSQLiteManager.getInstance().updateMealsTime(foodsArray: param,sDate: self.queryDay)
        self.currentMealTimeMsg = LogsSQLiteManager.getInstance().queryLogsDataForMealsTime(sDate: self.queryDay)
        LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: false)
        let uploadDict = ["sdate":"\(self.queryDay)",
                          "fitnessLabel":self.currentDayMsg.stringValueForKey(key: "fitnessLabel"),
                     "notes":self.currentDayMsg.stringValueForKey(key: "notes"),
                          "foods":WHUtils.getJSONStringFromArray(array: param)] as [String : Any]
        
        LogsSQLiteUploadManager().dealLogsDataForUpload(dict: uploadDict as NSDictionary)
//        LogsSQLiteUploadManager().sendUpdateLogsMealsTimeRequest(sDate: self.queryDay)
        LogsMealsAlertSetManage().refreshClockAlertMsg()
    }
    //左滑删除一种食物
    func delecteFoods(foodsMsg:NSDictionary) {
        let foodsArray = NSMutableArray(array: mealsArray[self.selectMealsIndex] as? NSArray ?? [])
        LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: false)
        logsModel.isUpload = false
        for i in 0..<foodsArray.count{
            let dict = foodsArray[i]as? NSDictionary ?? [:]
            if dict["fname"]as? String ?? "" == "快速添加" &&
                (dict["calories"]as? Int ?? 0 == foodsMsg["calories"]as? Int ?? 0) &&
                (dict["carbohydrate"]as? Double ?? 0 == foodsMsg["carbohydrate"]as? Double ?? 0) &&
                (dict["protein"]as? Double ?? 0 == foodsMsg["protein"]as? Double ?? 0) &&
                (dict["fat"]as? Double ?? 0 == foodsMsg["fat"]as? Double ?? 0){
                foodsArray.removeObject(at: i)
                break
            }else{
                var fidStr = "\(dict["fid"]as? Int ?? -1)"
                if fidStr == "-1"{
                    fidStr = dict["fid"]as? String ?? "-1"
                }
                
                var foodsMsgIdStr = "\(foodsMsg["fid"]as? Int ?? -1)"
                if foodsMsgIdStr == "-1"{
                    foodsMsgIdStr = foodsMsg["fid"]as? String ?? "-1"
                }
                if fidStr == foodsMsgIdStr && dict["spec"]as? String ?? "" == foodsMsg["spec"]as? String ?? ""{
                    foodsArray.removeObject(at: i)
                    break
                }
            }
        }
        if mealsArray.count > self.selectMealsIndex{
            mealsArray.replaceObject(at: self.selectMealsIndex, with: foodsArray)
            saveDataToSqlDB()
            self.tableView.reloadData()
            updateFirstFoodsAlert()
            self.calculateNaturalNum()
        }else{
            self.delecteFoods(foodsMsg: foodsMsg)
        }
    }
    //左滑删除一种食物
    func delecteFoodsCell(foodsMsg:NSDictionary,index:Int) {
        let foodsArray = NSMutableArray(array: mealsArray[self.selectMealsIndex] as? NSArray ?? [])
        LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: false)
        logsModel.isUpload = false
        foodsArray.removeObject(at: index)
        
        if mealsArray.count > self.selectMealsIndex{
            mealsArray.replaceObject(at: self.selectMealsIndex, with: foodsArray)
            
            saveDataToSqlDB()
            self.tableView.reloadData()
            updateFirstFoodsAlert()
//            saveDataToSqlDB()
            self.calculateNaturalNum()
        }else{
            self.delecteFoodsCell(foodsMsg: foodsMsg, index: index)
        }
    }
    //  某个食物  点击了“用餐”
    func eatCellTapAction(cellIndex:Int) {
        let foodsArray = NSMutableArray(array: mealsArray[self.selectMealsIndex] as? NSArray ?? [])
        let foodsDict = NSMutableDictionary.init(dictionary: foodsArray[cellIndex]as? NSDictionary ?? [:])
        foodsDict.setValue("1", forKey: "state")
        foodsArray.replaceObject(at: cellIndex, with: foodsDict)
        
        WHUtils().sendAddFoodsForCountRequest(fids: [foodsDict.stringValueForKey(key: "fid")])
        WHUtils().sendAddHistoryFoods(foodsMsgArray: [foodsDict])
        UserDefaults.saveFoods(foodsDict: foodsDict)
        
        mealsArray.replaceObject(at: self.selectMealsIndex, with: foodsArray)
        logsModel.isUpload = false
        
        let msgDict = NSMutableDictionary.init(dictionary: self.currentDayMsg)
        msgDict.setValue(mealsArray, forKey: "foods")
        self.currentDayMsg = msgDict
        
        saveDataToSqlDB()
        tableView.reloadData()
        goalVm.updateUI(dict: self.currentDayMsg)
    }
    //单独选中/取消选中 一种食物
    func singelCellTapAction(isSelect:Bool,cellIndex:Int) {
        let foodsArray = NSMutableArray(array: mealsArray[self.selectMealsIndex] as? NSArray ?? [])
        let foodsDict = NSMutableDictionary.init(dictionary: foodsArray[cellIndex]as? NSDictionary ?? [:])
        if isSelect == true{
            foodsDict.setValue("1", forKey: "isSelect")
        }else{
            foodsDict.setValue("0", forKey: "isSelect")
        }
        foodsArray.replaceObject(at: cellIndex, with: foodsDict)
        mealsArray.replaceObject(at: self.selectMealsIndex, with: foodsArray)
        
        tableView.reloadData()
        judgeAllSelectStatus()
    }
    
    //某一餐  全选或取消全选
    func mealsSelectAction(isSelect:Bool) {
        let foodsArray = NSMutableArray(array: mealsArray[self.selectMealsIndex] as? NSArray ?? [])
        let selecStatus = isSelect ? "1" : "0"
        for i in 0..<foodsArray.count{
            let foodsDi = NSMutableDictionary.init(dictionary: foodsArray[i]as? NSDictionary ?? [:])
            foodsDi.setValue(selecStatus, forKey: "isSelect")
            foodsArray.replaceObject(at: i, with: foodsDi)
        }
        mealsArray.replaceObject(at: self.selectMealsIndex, with: foodsArray)
        tableView.reloadData()
        judgeAllSelectStatus()
    }
    //当天的  全选  或  取消全选
    func allTapAction(isSelect:Bool){
        let selecStatus = isSelect ? "1" : "0"
        for i in 0..<self.mealsArray.count{
            let foodsArray = NSMutableArray.init(array: mealsArray[i]as? NSArray ?? [])
            for j in 0..<foodsArray.count{
                let foodsDi = NSMutableDictionary.init(dictionary: foodsArray[j]as? NSDictionary ?? [:])
                foodsDi.setValue(selecStatus, forKey: "isSelect")
                foodsArray.replaceObject(at: j, with: foodsDi)
            }
            mealsArray.replaceObject(at: i, with: foodsArray)
        }
        tableView.reloadData()
        
        if isSelect{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "editFoodsHasSelect"), object: nil)
        }else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "editFoodsHasSelectNone"), object: nil)
        }
    }
    //判断是否食物全选
    func judgeAllSelectStatus() {
        var isAllSelect = true
        for i in 0..<self.mealsArray.count{
            let foodsArray = NSMutableArray.init(array: mealsArray[i]as? NSArray ?? [])
            for j in 0..<foodsArray.count{
                let foodsDi = foodsArray[j]as? NSDictionary ?? [:]
                if foodsDi["isSelect"]as? String ?? "" != "1"{
                    isAllSelect = false
                    break
                }
            }
            
            if isAllSelect == false{
                break
            }
        }
        
        self.editSelectAllVm.setSelectStatus(isAllSelect: isAllSelect)
        self.judgeHasFoodsSelect()
    }
    func judgeHasFoodsSelect() {
        var hasSelect = false
        for i in 0..<self.mealsArray.count{
            let foodsArray = NSMutableArray.init(array: mealsArray[i]as? NSArray ?? [])
            for j in 0..<foodsArray.count{
                let foodsDi = foodsArray[j]as? NSDictionary ?? [:]
                if foodsDi["isSelect"]as? String ?? "" == "1"{
                    hasSelect = true
                    break
                }
            }
            
            if hasSelect == true{
                break
            }
        }
        if hasSelect{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "editFoodsHasSelect"), object: nil)
        }else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "editFoodsHasSelectNone"), object: nil)
        }
    }
    @objc func naturalDetailTapAction() {
//        let vc = NaturalDetailVC()
        let vc = JournalReportVC()
        vc.detailDict = self.currentDayMsg
        self.controller.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func naturalDetailOldTapAction() {
        let vc = NaturalDetailVC()
        vc.detailDict = self.currentDayMsg
//        let vc = FriendRankingVC()
//        self.controller.navigationController?.pushViewController(vc, animated: true)
    }
}

extension JounalCollectionCell{
    func sendLogsDetailRequest() {
        let param = ["sdate":"\(queryDay)"]
        DLLog(message: "sendLogsDetailRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_User_logs_detail, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            self.dealServerData(dict:dataObj)
            DLLog(message: "sendLogsDetailRequest:\(dataObj)")
//            self.dealServerData(dict:responseObject["data"]as? NSDictionary ?? [:])
        }
    }
    func sendUpdateNotesReqeust() {
        let param = ["sdate":"\(self.currentDayMsg["sdate"]as? String ?? "\(self.queryDay)")",
                     "notes":"\(self.remarkAlertVm.textView.text ?? "")"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_User_logs_update_notes, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: responseObject)
            LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: true)
            self.logsModel.isUpload = true
        }
    }
    func sendWaterSynRequest(waterNum:String) {
        let param = ["sdate":self.queryDay,
                     "qty":waterNum]
        WHNetworkUtil.shareManager().POST(urlString: URL_User_logs_update_water, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendWaterSynRequest:\(dataObj)")
            
            LogsSQLiteManager.shared.updateWaterUploadStatus(sDate: self.queryDay,
                                                             update: true,
                                                             eTime: dataObj.stringValueForKey(key: "etime").replacingOccurrences(of: "T", with: " "))
        }
    }
    @objc func sendNextMealAdviceConfigRequest(statu:Bool,indexPath:IndexPath) {
//        MCToast.mc_loading()
        let param = ["next_meal_advice_status":"\(statu ? 1 : 0)"]
        DLLog(message: "sendNextMealAdviceConfigRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_config_set, parameters: param as [String : AnyObject],isNeedToast: true,vc: self.controller) { responseObject in
            DLLog(message: "sendNextMealAdviceConfigRequest:\(responseObject)")
           
            UserInfoModel.shared.show_next_advice = statu
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
            self.tableView.reloadRows(at: [indexPath], with: .top)
        }
    }
    func sendUpdateGoalRequest(dict:NSDictionary) {
        let date = self.queryDay
        let param = ["carbohydrateDen":"\(dict.stringValueForKey(key: "carbohydrates"))",
                     "proteinDen":"\(dict.stringValueForKey(key: "proteins"))",
                     "fatDen":"\(dict.stringValueForKey(key: "fats"))",
                     "caloriesDen":"\(dict.stringValueForKey(key: "calories"))",
                     "carbLabel":"\(dict.stringValueForKey(key: "carbLabel"))",
                     "sdate":"\(date)"]
        
        DLLog(message: "sendUpdateGoalRequest:(param)\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_User_logs_goal_update, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "sendUpdateGoalRequest:(responseObject)\(responseObject)")
            DLLog(message: "sendUpdateGoalRequest:(dict)\(dict)")
            LogsSQLiteManager.getInstance().updateSingelDateGoal(caloriTar: dict.stringValueForKey(key: "calories"),
                                                                 carbohydrateTar: dict.stringValueForKey(key: "carbohydrates"),
                                                                 proteinTar: dict.stringValueForKey(key: "proteins"),
                                                                 fatTar: dict.stringValueForKey(key: "fats"),
                                                                 circleTag: dict.stringValueForKey(key: "carbLabel"),
                                                                 sdate: date)
            self.setQueryDate(date: date, isEdit: false)
        }
    }
}

extension JounalCollectionCell{
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = super.hitTest(point, with: event)
        for vi in self.subviews{
            let tp = vi.convert(point, from: self)
            let centerImgFrame = self.goalVm.winnerPopView.frame
            if CGRectContainsPoint(centerImgFrame, tp){
                
            }else{
                self.goalVm.winnerPopView.closeSelfAction()
            }
        }
        return view
    }
}

