//
//  MainVC.swift
//  lns
//
//  Created by LNS2 on 2024/3/21.
//

import Foundation
import MCToast
import IQKeyboardManagerSwift
import CryptoKit
import UMCommon
import HealthKit

class MainVC : WHBaseViewVC {
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
        trainingDataTest()
        if launchInt == 1{
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
        sendBodyAllStatRequest()
        initUI()
        
        if launchInt > 1{
            HealthKitManager().fetchBodyFatPercentage()
            HealthKitManager().fetchWaistCircumference()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTodayNutrition(notify:)), name: NSNotification.Name(rawValue: "refreshTodayNutrition"), object: nil)
    }
    lazy var topVM : MainTopVM = {
        let vm = MainTopVM.init(frame: .zero)
        vm.tapBlock = {()in
            let vc = FoodsListNewVC()
            vc.isFromMain = true
            vc.sourceType = .main
            vc.createVm.refreshButtonFrame()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var scrollView : UIScrollView = {
        let vi = UIScrollView()
        vi.frame = CGRect.init(x: 0, y: topVM.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-topVM.frame.maxY-getTabbarHeight())
//        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        vi.backgroundColor = .white
        vi.showsVerticalScrollIndicator = false
        vi.contentInsetAdjustmentBehavior = .never
        vi.delegate = self
        vi.clipsToBounds = false
        
        return vi
    }()
    lazy var topBgView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: kFitWidth(-244), width: SCREEN_WIDHT, height: kFitWidth(420)))
        vi.backgroundColor = .THEME
        
        return vi
    }()
    lazy var topBgImgView : UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: 0, y: kFitWidth(-344), width: SCREEN_WIDHT, height: kFitWidth(520)))
        img.setImgLocal(imgName: "mian_top_bg_whole")
        
        return img
    }()
    lazy var topMsgVm : MainTopMsgVM = {
        let vm = MainTopMsgVM.init(frame: .zero)
//        vm.goalVm.editBlock = {()in
//            let vc = GoalSetVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//            self.saveNutrationAlertVm.showView()
//        }
        vm.editBlock = {()in
//            TouchGenerator.shared.touchGenerator()
            let vc = GoalSetVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.planTapBlock = {()in
            let vc = PlanListVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var weightVm : MainWeightVM = {
        let vm = MainWeightVM.init(frame: CGRect.init(x: 0, y: self.topMsgVm.frame.maxY+kFitWidth(12), width: 0, height: 0))
        vm.addButton.addTarget(self, action: #selector(addDataAction), for: .touchUpInside)
        vm.tapBlock = {()in
            let vc = BodyDataDetailVC()
            vc.dataType = .weight
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.addBlock = {()in
            self.addDataAction()
        }
        return vm
    }()
    lazy var sanWeiVm : MainHeightVM = {
        let vm = MainHeightVM.init(frame: CGRect.init(x: 0, y: self.weightVm.frame.maxY+kFitWidth(12), width: 0, height: 0))
        vm.addButton.addTarget(self, action: #selector(addDataAction), for: .touchUpInside)
        vm.tapBlock = {()in
            let vc = BodyDataDetailVC()
            vc.dataType = .waistline
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.addBlock = {()in
            self.addDataAction()
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
            MobClick.event("createNutrition")
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

extension MainVC{
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
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func trainingDataTest() {
//        HealthKitManager.init().getTrainingData { enerBurned in
//            DLLog(message: "\(enerBurned)")
//        }
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

extension MainVC{
    func initUI(){
//        view.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        view.addSubview(topVM)
        
//        scrollView.addSubview(topBgView)
        scrollView.addSubview(topBgImgView)
        scrollView.addSubview(topMsgVm)
//        scrollView.addSubview(weightVm)
//        scrollView.addSubview(sanWeiVm)
        scrollView.addSubview(sportVm)
        scrollView.addSubview(dataLineChartView)
        scrollView.addSubview(weightLineChartView)
        
        scrollView.contentSize = CGSize.init(width: 0, height: self.dataLineChartView.frame.maxY + kFitWidth(32))
        
//        UIApplication.shared.keyWindow?.addSubview(saveNutrationAlertVm)
//        UIApplication.shared.keyWindow?.addSubview(guidGoalAlertVm)
//        UIApplication.shared.keyWindow?.addSubview(tipsAlertVm)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.getKeyWindow().addSubview(self.tipsAlertVm)
        })
    }
}

extension MainVC:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 0 {
            self.topVM.bgImgView.isHidden = false
            self.topVM.backgroundColor = .THEME
            self.topBgImgView.frame = CGRect.init(x: 0, y: kFitWidth(-344)+self.scrollView.contentOffset.y, width: SCREEN_WIDHT, height: kFitWidth(520))
        }else{
            self.topBgImgView.frame = CGRect.init(x: 0, y: kFitWidth(-344), width: SCREEN_WIDHT, height: kFitWidth(520))
            self.topVM.bgImgView.isHidden = true
            self.topVM.backgroundColor = .clear
        }
    }
}

extension MainVC{
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

extension MainVC{
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

//extension MainVC{
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
