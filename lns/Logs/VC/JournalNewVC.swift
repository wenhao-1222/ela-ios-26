//
//  JournalNewVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/10.
//

import Foundation
import UMCommon
import StoreKit

class JournalNewVC: WHBaseViewVC {
    /**
     记录APP首次打开时  ，今日的日期
     因为APP可能在后台长时间运行，第二天的时候，会出问题
     */
    var toDayDate = Date().nextDay(days: 0)
    var queryDay = Date().nextDay(days: 0)
    var todayIndex = 0
    var selecteIndex = 0
    
    var daySourceArray = NSMutableArray()
    var isEdit = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.judegeToDay()
        MobClick.beginLogPageView("journal")
//        UIApplication.shared.windows.first?.addSubview(self.guideCreatePlanAlertVm)
        self.sendUserCenterForMineRedView()
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
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
            let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionViewCell
            cell?.goalVm.winnerPopView.closeSelfAction()
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closeEditStatus"), object: nil)
        MobClick.endLogPageView("journal")
        
//        self.winnerPopView.closeSelfAction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshDataSource()
        sendUserCenterRequest()
        sendSaveRegistIdRequest()
        sendNutritionsDefaultRequest()
        
        let launchInt = UserDefaults.standard.value(forKey: launchNum) as? Int ?? 0
        if launchInt > 1 {
            HealthKitManager.init().getLatestWeightSample { entity in
    //            DLLog(message: "HealthKitManager:\(String(describing: entity))")
            }
        }
        
        initUI()
        
//        decryptData()
        NotificationCenter.default.addObserver(self, selector: #selector(judegeToDay), name: NOTIFI_NAME_DID_BECOME_ACTIVE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresMsgNotifi), name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeNaviButtonStatus(notify: )), name: NSNotification.Name(rawValue: "msgCalculateEnd"),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gotoLogsNotification), name: NSNotification.Name(rawValue: "activePlan"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(createPlan), name: NSNotification.Name(rawValue: "fullPlanSave"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addFoodsNotifi(notify: )), name: NSNotification.Name(rawValue: "foodsAddForLogs"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addFoodsFastNotifi(notify: )), name: NSNotification.Name(rawValue: "fastAddFoods"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelEditNotifi), name: NSNotification.Name(rawValue: "cancelEditStatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showBottomFuncVm), name: NSNotification.Name(rawValue: "editFoodsHasSelect"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hiddenBottomFuncVm), name: NSNotification.Name(rawValue: "editFoodsHasSelectNone"), object: nil)
        
        let is_guide = UserDefaults.standard.value(forKey: guide_logs_plan) as? String ?? ""
        if is_guide.count > 0 || Date().judgeMin(firstTime: UserInfoModel.shared.registDate, secondTime: "2024-07-02",formatter: "yyyy-MM-dd"){
            sendVersionRequest()
        }
    }
    lazy var naviVm : LogsNaviVM = {
        let vm = LogsNaviVM.init(frame: .zero)
        vm.controller = self
        vm.choiceTimeBlock = {()in
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
            self.collectView.scrollToItem(at: IndexPath.init(row: self.selecteIndex, section: 0), at: .right, animated: true)
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
            self.collectView.scrollToItem(at: IndexPath.init(row: self.selecteIndex, section: 0), at: .left, animated: true)
            self.changeEditStatus()
            
        }
        vm.delBlock = {()in
            self.isEdit = true
            self.naviEditStatusVm.delButton.isHidden = true
            self.changeEditStatus()
        }
        vm.shareBlock = {()in
            self.collectView.layoutIfNeeded()
            
            let indexPath = IndexPath(row: self.selecteIndex, section: 0)
            let cell = self.collectView.cellForItem(at: indexPath)as! JounalCollectionViewCell
            
//            let vc = JournalShareVC()
            let vc = JournalShareNewVC()
            vc.detailsDict = cell.currentDayMsg
            vc.dayString = cell.queryDay
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var naviEditStatusVm : LogsNaviEditVM = {
        let vm = LogsNaviEditVM.init(frame: .zero)
        
        vm.doneBlock = {()in
            self.isEdit = false
            self.changeEditStatus()
        }
        vm.deleteBlock = {()in
            self.collectView.layoutIfNeeded()
            let indexPath = IndexPath(row: self.selecteIndex, section: 0)
            let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionViewCell
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
//        vi.dataSource = self
        vi.showsHorizontalScrollIndicator = false
        vi.register(JounalCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "JounalCollectionViewCell")
        
        
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
    lazy var guideCreatePlanAlertVm: GuideJournalGotPlanAlertVM = {
        let vm = GuideJournalGotPlanAlertVM.init(frame: .zero)
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
            let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionViewCell
            
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
            let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionViewCell
            self.copyMealsAlertVm.copyFoods(mealsArray: cell?.mealsArray ?? NSArray())
        }
        vm.updateBlock = {()in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                let indexPath = IndexPath(row: self.copyMealsAlertVm.selectIndex, section: 0)
                let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionViewCell
                cell?.setQueryDate(date: self.copyMealsAlertVm.queryDay, isEdit: false)
                
                self.isEdit = false
                self.changeEditStatus()
            })
        }
        
        return vm
    }()
//    lazy var winnerVm: WinnerStreakVM = {
//        let vm = WinnerStreakVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: 0, height: 0))
//        vm.tapBlock = {()in
//            self.winnerPopView.showSelf()
//        }
//        return vm
//    }()
//    lazy var winnerPopView: WinnerStreakAlertVM = {
//        let vm = WinnerStreakAlertVM.init(frame: CGRect.init(x: 0, y: self.winnerVm.frame.maxY-kFitWidth(5), width: 0, height: 0))
//        vm.isHidden = true
//        return vm
//    }()
    lazy var guideGoalAlertVm: GuideSetWeekGoalAlertVM = {
        let vm = GuideSetWeekGoalAlertVM.init(frame: .zero)
        return vm
    }()
}

extension JournalNewVC{
    @objc func judegeToDay() {
        if toDayDate != Date().nextDay(days: 0) {
            queryDay = Date().nextDay(days: 0)
            refreshDataSource()
            self.collectView.reloadData()
            self.toDayDate = Date().nextDay(days: 0)
            self.collectView.scrollToItem(at: IndexPath.init(row: todayIndex, section: 0), at: .right, animated: false)
            
            self.copyMealsAlertVm.daysArray = self.daySourceArray
            self.copyMealsAlertVm.tomorrowIndex = self.todayIndex + 1
            self.copyMealsAlertVm.refreshPicker(selectIndex:self.selecteIndex)
        }
    }
    func refreshDataSource() {
        let arr = NSMutableArray()
        let minDay = Date().getLastYearsAgo(lastYears: -3)
        let maxDay = Date().getLastYearsAgo(lastYears: 3)
        
        let minGapDays = Date().daysBetweenDate(toDate: minDay)
        let maxGapDays = Date().daysBetweenDate(toDate: maxDay)
        
        todayIndex = abs(minGapDays)
        selecteIndex = todayIndex
        
        for i in minGapDays...maxGapDays+1{
            let day = Date().nextDay(days: i, baseDate: queryDay)
            arr.add(day)
        }
        
        daySourceArray = arr
    }
    func refreshNaviDayText() {
        if self.queryDay == Date().nextDay(days: 0){
            self.naviVm.changeDate(date: "今日")
        }else{
            self.naviVm.changeDate(date: self.queryDay)
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
        self.collectView.scrollToItem(at: IndexPath.init(row: self.selecteIndex, section: 0), at: .right, animated: false)
    }
}

extension JournalNewVC{
    @objc func refresMsgNotifi() {
        self.collectView.reloadData()
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
    @objc func gotoLogsNotification(){
        self.queryDay = Date().nextDay(days: 0)
        self.naviVm.changeDate(date: "今日")
        if toDayDate != Date().nextDay(days: 0){
            refreshDataSource()
            self.collectView.reloadData()
            self.toDayDate = Date().nextDay(days: 0)
            self.collectView.scrollToItem(at: IndexPath.init(row: todayIndex, section: 0), at: .right, animated: false)
        }else{
            self.selecteIndex = self.todayIndex
            self.collectView.reloadData()
            self.collectView.scrollToItem(at: IndexPath.init(row: todayIndex, section: 0), at: .right, animated: false)
        }
    }
    @objc func addFoodsNotifi(notify:Notification) {
        let foodsDict = notify.object ?? [:]
//        DLLog(message: "\(foodsDict)")
        DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
            self.collectView.layoutIfNeeded()
            let indexPath = IndexPath(row: self.selecteIndex, section: 0)
//            let cell = self.collectView.dequeueReusableCell(withReuseIdentifier: "JounalCollectionViewCell", for: indexPath)as! JounalCollectionViewCell
            let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionViewCell
            cell?.addFoods(foodsMsg: foodsDict as! NSDictionary)
        }
    }
    @objc func addFoodsFastNotifi(notify:Notification) {
        self.collectView.layoutIfNeeded()
        let foodsDict = notify.object ?? [:]
        DLLog(message: "\(foodsDict)")
        let indexPath = IndexPath(row: self.selecteIndex, section: 0)
//        let cell = self.collectView.dequeueReusableCell(withReuseIdentifier: "JounalCollectionViewCell", for: indexPath)as! JounalCollectionViewCell
        let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionViewCell
        cell?.addFoods(foodsMsg: foodsDict as! NSDictionary)
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
        let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionViewCell
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

extension JournalNewVC{
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

extension JournalNewVC{
//    func decryptData(){
//        let string = "5b57f371e517d8737e3b47f248c83af74454835336bd23a295e90bb77f5b8f959b69ee7b1e9fccd305d57faeb8c8cd4e5ef8bcf8ec3bc1a96010234e133f229350fbe634d53bdff5ac89d72bcbf12cd25a3a49a7930f36eead82259e0867d2ae0c74502953e000a7528cbdd4b85e14af7500f69658fe36b49f4e1e78c56e2904f1f1fdfcab3457c8488f051fe42169b9dae79999854a7a1fa2674676e41337c0ae637b7c097ca79e299c17080d38d4af5397e2aaee8a359edb422caac19a83c76557f14b71ffff9278d0e6c9b6b3efacfb7ce84ba147f6cdefb479e93822b4c71e8b70f54208810311658bffdbbd50047579acdec19eee2efdfe87a71b038f1a1107cc83851a74d2c3956f687fe96a909912cd16dbeca89a2766b446f67eafbfada26d4e6c96012085f4896c4b81bd72be5155680937e07e83b4558821b05f82fd666fd3d96e3bc2e80f9d11c7123a9bf8a1222a5c5659570f98e0ef78bb6b26b3c1fa36d12377d0f41dbc808390fdaea3bba860c469e19cae5f604adf838ccb2a47f688bd6fb0792487b394f04a2d327e44fed043c76dbaf77d501d476e60c0aa798553eb7904abb35a1d5562fe43151e8fdfdf51a15682ec83af78b5d18b47e81c18f0bb2fe9de5280ddc69a14125b6973dcd8d02f03fd3e2c22fb9baa27ed01f1717bf71dc206fc19e2ea352d7275682541e4daee581dc542f83bd196ecd3fcce7df07969eb66c6a5a9c9e1d6c6de41020407fb56c145c7e110a5ddfc0d87"
//        let dataString = AESEncyptUtil.aesDecrypt(hexString: string)
//        let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
////        let dataObj = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
//        
////        DLLog(message: "decryptData:\(dataObj)")
//    }
    func sendUserCenterRequest() {
        let param = ["uid":"\(UserInfoModel.shared.uId)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_User_Center, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: "sendUserCenterRequest:\(responseObject)")
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            UserInfoModel.shared.updateMsg(dict: dataObj)
            
            if Date().judgeMin(firstTime: UserInfoModel.shared.registDate, secondTime: "2024-07-02",formatter: "yyyy-MM-dd") == false{
                UIApplication.shared.windows.first?.addSubview(self.guideCreatePlanAlertVm)
            }else{
                UserDefaults.standard.setValue("1", forKey: guide_logs_plan)
            }
            
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
            DLLog(message: "sendUserCenterRequest:\(responseObject)")
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            UserInfoModel.shared.updateMsg(dict: dataObj)
//            
            let streakDict = dataObj["streak"]as? NSDictionary ?? [:]
            
            let indexPath = IndexPath(row: self.selecteIndex, section: 0)
            let cell = self.collectView.cellForItem(at: indexPath)as? JounalCollectionViewCell
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
        let param = ["jpush_regid_ios":"\(JPUSHService.registrationID())"]
        DLLog(message: "sendSaveRegistIdRequest(param):\(param)")
       WHNetworkUtil.shareManager().POST(urlString: URL_User_Material_Update, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: "sendSaveRegistIdRequest:\(responseObject)")
        }
    }
    func sendNutritionsDefaultRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_get_default_nutrition, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendNutritionsDefaultRequest:\(dataArray)")
            UserDefaults.set(value: WHUtils.getJSONStringFromArray(array: dataArray), forKey: .nutritionDefaultArray)
        }
    }
}

extension JournalNewVC{
    func initUI(){
        view.addSubview(naviVm)
        view.addSubview(naviEditStatusVm)
        
        view.addSubview(collectView)
//        view.addSubview(winnerVm)
//        view.addSubview(winnerPopView)
        
        collectView.delegate = self
        collectView.dataSource = self
        collectView.scrollToItem(at: IndexPath.init(row: todayIndex, section: 0), at: .right, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.7, execute: {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.getKeyWindow().addSubview(self.bottomFuncVm)
            
            appDelegate.getKeyWindow().addSubview(self.copyMealsAlertVm)
            appDelegate.getKeyWindow().addSubview(self.guideGoalAlertVm)
        })
//        UIApplication.shared.windows.first?.addSubview(self.guideGoalAlertVm)
    }
}
extension JournalNewVC:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daySourceArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.cellForItem(at: indexPath) as? JounalCollectionViewCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JounalCollectionViewCell", for: indexPath)as? JounalCollectionViewCell
        
        let day = daySourceArray[indexPath.row]as? String ?? "\(Date().nextDay(days: 0))"
        cell?.setQueryDate(date: day,isEdit: self.isEdit)
        cell?.controller = self
        
        return cell ?? JounalCollectionViewCell()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int((collectView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
//        DLLog(message: "scrollViewDidEndDecelerating:\(currentPage)  -- \(daySourceArray[currentPage]as? String ?? "")")
        self.queryDay = daySourceArray[currentPage]as? String ?? ""
        self.selecteIndex = currentPage
        self.refreshNaviDayText()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = Int((collectView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
        self.queryDay = daySourceArray[currentPage]as? String ?? ""
        self.selecteIndex = currentPage
        self.refreshNaviDayText()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closeEditStatus"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadStreakMsg"), object: nil)
    }
}
