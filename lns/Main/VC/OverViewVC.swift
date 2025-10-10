//
//  OverViewVC.swift
//  lns
//
//  Created by Elavatine on 2025/5/27.
//


import Foundation
import MCToast
import IQKeyboardManagerSwift
import CryptoKit
//import UMCommon
import HealthKit

class OverViewVC : WHBaseViewVC {
//    override func viewDidAppear(_ animated: Bool) {
//        self.navigationController?.fd_interactivePopDisabled = true
//        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
//    }
    let launchInt = UserDefaults.standard.value(forKey: launchNum) as? Int ?? 0
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        sendUserCenterRequest()
        
        getNutritionDataRequest()
        sendNutritionsDefaultRequest()
        BodyDataUploadManager().checkDayaUploadStatus()
        
        let bodyDataArray = BodyDataSQLiteManager.getInstance().queryLast14Datas()
        
        dataLineChartView.setDataSourceArray(dataArray: bodyDataArray[1]as? NSArray ?? [])
        weightLineChartView.setDataSourceArray(dataArray: bodyDataArray[0]as? NSArray ?? [])
        if (bodyDataArray[0]as? NSArray ?? []).count == 0{
            sendBodyDataLast14Request(qtype: "1")
        }else{
            let weightDict = (bodyDataArray[0]as? NSArray ?? []).lastObject as? NSDictionary ?? [:]
            UserInfoModel.shared.lastWeight = weightDict.doubleValueForKey(key: "weight")
        }
        if (bodyDataArray[1]as? NSArray ?? []).count == 0{
            sendBodyDataLast14Request(qtype: "2")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
//        trainingDataTest()
        if launchInt == 1{
            trainingDataTest()
            HealthKitManager().fetchBodyFatPercentage()
            HealthKitManager().fetchWaistCircumference()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.getAllBodyDataIsLoad() == false {
            DispatchQueue.main.asyncAfter(deadline: .now()+5, execute: {
                self.sendBodyAllStatRequest()
            })
        }
//        sendBodyAllStatRequest()
        initUI()
        
        if launchInt > 1{
            trainingDataTest()
            HealthKitManager().fetchBodyFatPercentage()
            HealthKitManager().fetchWaistCircumference()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTodayNutrition(notify:)), name: NSNotification.Name(rawValue: "refreshTodayNutrition"), object: nil)
    }
    lazy var scrollView : UIScrollView = {
        let vi = UIScrollView()
        vi.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
//        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")
//        vi.backgroundColor = .COLOR_BG_F5
        vi.backgroundColor = .clear
        vi.showsVerticalScrollIndicator = false
        vi.contentInsetAdjustmentBehavior = .never
        vi.delegate = self
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var logoVm: OverViewLogoVM = {
        let vm = OverViewLogoVM.init(frame: .zero)
        return vm
    }()
    lazy var topBgImgView : UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(276)+getTopSafeAreaHeight()))
        img.setImgLocal(imgName: "main_top_bg_cj")
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    lazy var topMsgVm : MainTopMsgVM = {
        let vm = MainTopMsgVM.init(frame: CGRect.init(x: 0, y: kFitWidth(38)+statusBarHeight, width: 0, height: 0))
        vm.planButton.setTitle("数据统计", for: .normal)
        vm.editBlock = {()in
//            TouchGenerator.shared.touchGenerator()
            let vc = GoalSetVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.planTapBlock = {()in
            let vc = NaturalStatVC()
            self.navigationController?.pushViewController(vc, animated: true)
//            let vc = PlanListVC()
//            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var sportVm: MainSportVM = {
        let vm = MainSportVM.init(frame: CGRect.init(x: 0, y: self.topMsgVm.frame.maxY+kFitWidth(12), width: 0, height: 0))
        vm.tapBlock = {()in
            let vc = SportHistoryVC()
            vc.isCanAdd = true
            vc.parentVc = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.tipsTapBlock = {()in
            self.tipsAlertVm.showView()
        }
        vm.addTapBlock = {()in
            let vc = SportVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var weightLineChartView : MainWeightLineChartView = {
        let vi = MainWeightLineChartView.init(frame: CGRect.init(x: 0, y: self.sportVm.frame.maxY+kFitWidth(12), width: 0, height: 0))
        vi.tapBlock = {()in
            let vc = BodyDataDetailVC()
            vc.dataType = .weight
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vi.addBlock = {()in
            self.addDataAction()
        }
        return vi
    }()
    lazy var dataLineChartView : MainDataLineChartView = {
        let vi = MainDataLineChartView.init(frame: CGRect.init(x: 0, y: self.weightLineChartView.frame.maxY+kFitWidth(12), width: 0, height: 0))
        vi.tapBlock = {()in
            let vc = BodyDataDetailVC()
            vc.dataType = .waistline
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vi.addBlock = {()in
            self.addDataAction()
        }
        return vi
    }()
    
    lazy var saveNutrationAlertVm : MainSaveNutrationAlertVM = {
        let vm = MainSaveNutrationAlertVM.init(frame: .zero)
        vm.saveBlock = {()in
//            MobClick.event("createNutrition")
            self.sendSaveNutrationRequest()
        }
        return vm
    }()
//    lazy var guidGoalAlertVm: GuideMainNaturalGoalAlertVM = {
//        let vm = GuideMainNaturalGoalAlertVM.init(frame: .zero)
//        return vm
//    }()
    lazy var tipsAlertVm : QuestionnairePlanTipsAlertVM = {
        let vm = QuestionnairePlanTipsAlertVM.init(frame: .zero)
        vm.titleLabel.text = "运动净消耗"
        vm.contentLabel.attributedText = TutorialAttr.shared.sportTipsAttr
        
        return vm
    }()
}

extension OverViewVC{
    @objc func refreshTodayNutrition(notify:Notification) {
//        let nutritionDict = notify.object as? NSDictionary ?? [:]
//        self.topMsgVm.updateUI(dict: nutritionDict)
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
//            let logsModel = LogsSQLiteManager.getInstance().getLogsByDate(sDate: Date().todayDate)!
//            let sportDict = SportDataSQLiteManager.getInstance().querySportsData(sDate: Date().todayDate)
//            DLLog(message: "SportDataSQLiteManager:\(sportDict)")
//
//            let dict = NSMutableDictionary(dictionary: logsModel.modelToDict())
//            if UserInfoModel.shared.statSportDataToTarget == "1"{
//                dict.setValue("\(sportDict.stringValueForKey(key: "sportCalories"))", forKey: "sportCalories")
//            }else{
//                dict.setValue("", forKey: "sportCalories")
//            }
//            self.topMsgVm.updateUI(dict: dict)
//        })
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.getNutritionDataRequest()
        })
    }
    @objc func addDataAction() {
//        TouchGenerator.shared.touchGeneratorMedium()
        let vc = DataAddVC()
        vc.isFromOverview = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func trainingDataTest() {
        // 使用示例
        let healthManager = HealthKitManager()
        healthManager.authorizeHealthKitWorkouts { success, error in
            if success {
                healthManager.getWorkouts { array, error in
                    if error == nil{
                        healthManager.hkWorkouts.removeAll()
                        for i in 0..<(array?.count ?? 0){
                            let result = array?[i] as? HKWorkout
                            healthManager.hkWorkouts.append(HKWorkoutActivityType(rawValue: (result?.workoutActivityType)!.rawValue) ?? HKWorkoutActivityType.other)
                        }
                        healthManager.getAllRunningWorkOutsData()
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                            self.sendNutritionsDefaultRequest()
                        })
                    }
                }
            }else if let error = error {
                print("Error getTrainingData: \(error.localizedDescription)")
            }
        }
    }
}

extension OverViewVC{
    func initUI(){
//        view.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        view.backgroundColor = .COLOR_BG_F5
        
        view.addSubview(topBgImgView)
        view.addSubview(scrollView)
        view.addSubview(logoVm)
        
//        scrollView.addSubview(topBgImgView)
        scrollView.addSubview(topMsgVm)
//        scrollView.addSubview(logoImgView)
        
        scrollView.addSubview(sportVm)
        scrollView.addSubview(dataLineChartView)
        scrollView.addSubview(weightLineChartView)
        
        [topMsgVm, sportVm, dataLineChartView, weightLineChartView].forEach { setupExclusiveTouch(in: $0) }
        
        scrollView.contentSize = CGSize.init(width: 0, height: self.dataLineChartView.frame.maxY + kFitWidth(32) + getTabbarHeight())
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.getKeyWindow().addSubview(self.tipsAlertVm)
        })
    }
}

extension OverViewVC:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y < 0{
//            scrollView.contentOffset.y = 0
//        }
//        self.logoVm.updateAlpha(offsetY: scrollView.contentOffset.y)
        
        let offsetY = scrollView.contentOffset.y
        
        if offsetY < 0 {
            // keep logo and background fixed
            topBgImgView.frame.origin.y = 0
            logoVm.frame.origin.y = 0
            topBgImgView.setNeedsDisplay()
            topBgImgView.layoutIfNeeded()
        } else {
            // background moves up with content
            topBgImgView.frame.origin.y = -offsetY
        }
        
        self.logoVm.updateAlpha(offsetY: max(0, offsetY))
    }
}

extension OverViewVC{
    @objc func getNutritionDataRequest() {
        let param = ["sdate":"\(Date().nextDay(days: 0))"]
        WHNetworkUtil.shareManager().POST(urlString: URL_get_current_nutrition, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "getNutritionDataRequest：\(dataObj)")
//            DLLog(message: "test:\(targetCalories) - \(currentCalories)   ===== \(targetCalories - currentCalories)")
            self.topMsgVm.updateUI(dict: dataObj)
//            self.guidGoalAlertVm.goalVm.numberLabel.text = "\(Int(dataObj.doubleValueForKey(key: "caloriesden").rounded()))"
            self.saveNutrationAlertVm.updateUI(msgDict: dataObj)
            self.sportVm.updateUI(dict: dataObj)
        }
    }
    func sendSaveNutrationRequest() {
        MCToast.mc_loading()
        let param = ["uid":"\(UserInfoModel.shared.uId)",
                     "surveytype":"custom",
                     "calories":"\(QuestinonaireMsgModel.shared.calories)",
                 "protein":"\(QuestinonaireMsgModel.shared.protein)",
                 "carbohydrate":"\(QuestinonaireMsgModel.shared.carbohydrates)",
                 "fat":"\(QuestinonaireMsgModel.shared.fats)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_question_custom_save, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: "\(responseObject)")
            self.saveNutrationAlertVm.clearText()
            self.getNutritionDataRequest()
            LogsSQLiteManager.getInstance().refreshDataTarget(sDate: Date().nextDay(days: 0),
                                                              caloriTar: QuestinonaireMsgModel.shared.calories,
                                                              proteinTar: QuestinonaireMsgModel.shared.protein,
                                                              carboTar: QuestinonaireMsgModel.shared.carbohydrates,
                                                              fatsTar: QuestinonaireMsgModel.shared.fats)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        }
    }
    func sendBodyAllStatRequest(){
        //"qtype": "0"// 0-全部；1-一个星期内；2-一个月内；3-两个月内；4-三个月内；5-半年内；6-一年内
        let param = ["uid":"\(UserInfoModel.shared.uId)",
                     "qtype":"0"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_bodystat_query, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendBodyAllStatRequest:\(dataArr)")
//            let dataArr = responseObject["data"]as? NSArray ?? []
            BodyDataSQLiteManager.getInstance().saveBodyDataToDataBase(dataArray: dataArr)
            UserDefaults.setAllBodyDataIsLoad()
        }
    }
    func sendBodyDataLast14Request(qtype:String) {
        let param = ["qtype":qtype]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_bodystat_query_14, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendBodyDataLast14Request  \(qtype):\(dataArr)")
            
            if qtype == "1"{
                self.weightLineChartView.setDataSourceArray(dataArray: dataArr)
                if dataArr.count > 0 {
                    let weightDict = dataArr.lastObject as? NSDictionary ?? [:]
                    UserInfoModel.shared.lastWeight = weightDict.doubleValueForKey(key: "weight")
                }
            }else if qtype == "2"{
                self.dataLineChartView.setDataSourceArray(dataArray: dataArr)
            }
        }
    }
    func sendUserCenterRequest() {
        let param = ["uid":"\(UserInfoModel.shared.uId)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_User_Center, parameters: param as [String : AnyObject]) { responseObject in
//            DLLog(message: "sendUserCenterRequest:\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            UserInfoModel.shared.updateMsg(dict: dataObj)
        }
    }
    
    func sendNutritionsDefaultRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_get_default_nutrition, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
//            DLLog(message: "nutrition/default:\(dataObj)")
//            UserDefaults.set(value: self.getJSONStringFromDictionary(dictionary: dataObj), forKey: .nutritionDefault)
//            NutritionDefaultModel.shared.saveGoals(dict: dataArray)
            UserDefaults.set(value: WHUtils.getJSONStringFromArray(array: dataArray), forKey: .nutritionDefaultArray)
        }
    }
}

extension OverViewVC{
    func dealBodyStatData(dataArray:NSArray) {
        let weightArray = NSMutableArray()
        let dimensionalityArray = NSMutableArray()
        for i in 0..<dataArray.count{
            let dict = dataArray[i]as? NSDictionary ?? [:]
            
            if dict.doubleValueForKey(key: "weight") > 0 {
                weightArray.add(dict)
            }
            if dict.doubleValueForKey(key: "waistline") > 0 || dict.doubleValueForKey(key: "hips") > 0 || dict.doubleValueForKey(key: "armcircumference") > 0{
                dimensionalityArray.add(dict)
            }
        }
        dataLineChartView.setDataSourceArray(dataArray: dimensionalityArray)
        weightLineChartView.setDataSourceArray(dataArray: weightArray)
    }
}

//extension OverViewVC{
//    //判断本地的数据是否已从服务器全部拉取
//    func judgeLogsData() {
//        let hasLoadLogsData = UserDefaults.standard.value(forKey: "\(UserInfoModel.shared.uId)") as? String ?? ""
//        
//        if hasLoadLogsData == "1"{
//            
//        }else{
//            sendLogsAllDataRequest()
//        }
//    }
//    func sendLogsAllDataRequest() {
//        DLLog(message: "sendLogsAllDataRequest:\(Date().currentSeconds)")
//        WHNetworkUtil.shareManager().POST(urlString: URL_User_logs_all, parameters: nil) { responseObject in
//            DispatchQueue.global(qos: .userInitiated).async { [self] in
//                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
////                DispatchQueue.main.sync(execute: {
//                let dataObj = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
//                    DLLog(message: "sendLogsAllDataRequest:\(Date().currentSeconds)")
//                    LogsSQLiteManager.getInstance().saveServerDataToDB(dataArray: dataObj)
////                })
//            }
//        }
//    }
//}
