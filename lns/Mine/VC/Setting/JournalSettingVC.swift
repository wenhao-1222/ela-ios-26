//
//  JournalSettingVC.swift
//  lns
//
//  Created by Elavatine on 2024/9/23.
//

import Foundation
import UIKit
import MCToast
import HealthKit

class JournalSettingVC: WHBaseViewVC {
    
    let healthStore = HKHealthStore()
    let healthKitTypesToRead = HKObjectType.workoutType()
    let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)
    let activeEnergyBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        UserDefaults.standard.set("1", forKey: "settingNewFuncRead")
        UserInfoModel.shared.settingNewFuncRead = true
    }
    lazy var logsTitleLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(12), y: 0, width: kFitWidth(200), height: kFitWidth(44)))
        lab.text = "日志"
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
    lazy var resetLogsVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.logsTitleLabel.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "重置日志列表"
        vm.leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
        vm.detailLabel.text = ""
        vm.tapBlock = {()in
            self.clearLogsAction()
        }
        return vm
    }()
    
    lazy var resetLogsMealsVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.logsTitleLabel.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "每日饮食餐数"
        vm.detailLabel.text = "\(UserInfoModel.shared.mealsNumber)餐"
        vm.leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
        vm.tapBlock = {()in
            self.mealsAlertVm.showSelf()
        }
        return vm
    }()
//    lazy var hiddenQuestionnaireVm : MaterialItemVM = {
//        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.resetLogsMealsVm.frame.maxY, width: 0, height: 0))
//        vm.leftLabel.text = "隐藏获取计划功能"
//        vm.leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
//        vm.detailLabel.text = ""
//        vm.arrowImgView.isHidden = true
//        vm.switchButton.isHidden = false
//        vm.switchButton.setSelectStatus(status: UserInfoModel.shared.hidden_survery_button_status)
//        vm.tapBlock = {()in
//            
//        }
//        vm.switchButton.tapBlock = {(isSelect)in
//            self.sendSaveSurveryStatusRequest(statu: isSelect)
//        }
//        return vm
//    }()
    lazy var hiddenLogsTimeVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.resetLogsMealsVm.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "记录进餐时间"
        vm.leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
        vm.detailLabel.text = ""
        vm.arrowImgView.isHidden = true
//        vm.switchButton.isHidden = false
//        vm.switchButton.setSelectStatus(status: UserInfoModel.shared.hiddenMeaTimeStatus)
        vm.switchBtn.isHidden = false
        vm.switchBtn.setOn(UserInfoModel.shared.hiddenMeaTimeStatus, animated: false)
        vm.switchBlock = {(isSelect)in
            self.sendSaveLogsTimeRequest(statu: isSelect)
        }
        vm.tapBlock = {()in
            
        }
        vm.switchButton.tapBlock = {(isSelect)in
            self.sendSaveLogsTimeRequest(statu: isSelect)
        }
        return vm
    }()
    lazy var caloriesShowVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.hiddenLogsTimeVm.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "显示剩余摄入"
        vm.leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
        vm.detailLabel.text = ""
        vm.arrowImgView.isHidden = true
//        vm.switchButton.isHidden = false
//        vm.switchButton.setSelectStatus(status: UserInfoModel.shared.showRemainCalories)
        vm.switchBtn.isHidden = false
        vm.switchBtn.setOn(UserInfoModel.shared.showRemainCalories, animated: false)
        vm.switchBlock = {(isSelect)in
            self.sendNatGoalStyleRequest(statu: isSelect)
        }
        vm.tapBlock = {()in
            
        }
        vm.switchButton.tapBlock = {(isSelect)in
            self.sendNatGoalStyleRequest(statu: isSelect)
        }
        return vm
    }()
    lazy var waterShowVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.caloriesShowVm.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "饮水记录"
        vm.leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
        vm.detailLabel.text = ""
        vm.arrowImgView.isHidden = true
//        vm.switchButton.isHidden = false
//        vm.switchButton.setSelectStatus(status: UserInfoModel.shared.show_water_status)
        vm.switchBtn.isHidden = false
        vm.switchBtn.setOn(UserInfoModel.shared.show_water_status, animated: false)
        vm.switchBlock = {(isSelect)in
            self.sendWaterConfigRequest(statu: isSelect)
        }
        vm.tapBlock = {()in
            
        }
        vm.switchButton.tapBlock = {(isSelect)in
            self.sendWaterConfigRequest(statu: isSelect)
        }
        return vm
    }()
    lazy var nextMealShowVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.waterShowVm.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "下餐饮食建议"
        vm.leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
        vm.detailLabel.text = ""
        vm.arrowImgView.isHidden = true
//        vm.switchButton.isHidden = false
//        vm.switchButton.setSelectStatus(status: UserInfoModel.shared.show_next_advice)
        vm.switchBtn.isHidden = false
        vm.switchBtn.setOn(UserInfoModel.shared.show_next_advice, animated: false)
        vm.switchBlock = {(isSelect)in
            self.sendNextMealAdviceConfigRequest(statu: isSelect)
        }
        vm.tapBlock = {()in
            
        }
        vm.switchButton.tapBlock = {(isSelect)in
            self.sendNextMealAdviceConfigRequest(statu: isSelect)
        }
        return vm
    }()
    lazy var mealsAlertSetVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.nextMealShowVm.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "轻断食/用餐提醒"
        vm.leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
        vm.detailLabel.text = ""
//        vm.isHidden = true
        vm.tapBlock = {()in
            let vc = LogsMealsAlertSetVC()
//            self.present(vc, animated: true)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    
//    lazy var waterAlertVm : MaterialItemVM = {
//        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.mealsAlertSetVm.frame.maxY, width: 0, height: 0))
//        vm.leftLabel.text = "喝水提醒"
//        vm.leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
//        vm.detailLabel.text = ""
//        vm.tapBlock = {()in
//            let vc = WaterAlertSetVC()
//            self.navigationController?.pushViewController(vc, animated: true)
////            self.present(vc, animated: true)
//        }
//        return vm
//    }()

    lazy var bodydataTitleLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(12), y: self.mealsAlertSetVm.frame.maxY, width: kFitWidth(200), height: kFitWidth(44)))
        lab.text = "身体数据"
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
    
    lazy var resetWeightUnitVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.bodydataTitleLabel.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "体重单位"
        vm.leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
        vm.detailLabel.text = "\(UserInfoModel.shared.weightUnitName)"
        vm.tapBlock = {()in
            self.weightUnitAlertVM.showSelf()
        }
        return vm
    }()
    
    lazy var healthAppAuthoriLabel : UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(12), y: self.resetWeightUnitVm.frame.maxY, width: kFitWidth(200), height: kFitWidth(44)))
        lab.text = "运动记录"
//        lab.text = "苹果“健康”APP"
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        
        return lab
    }()
    lazy var healtAlertSetVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.healthAppAuthoriLabel.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "苹果健康权限"
        vm.leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        let isAuthori = UserDefaults.getString(forKey: .health_sport_Authori)
        if isAuthori == "1"{
            vm.detailLabel.text = "已授权"
//            if UserInfoModel.shared.statSportDataFromHealth == "0"{
//                self.sendSportCaloriesUpdateRequest(statu: false)
//            }
        }else{
            vm.detailLabel.text = ""
        }
        
//        vm.isHidden = true
        vm.tapBlock = {()in
            let isAuthori = UserDefaults.getString(forKey: .health_sport_Authori)
            if isAuthori == "1"{
                self.presentAlertVcNoAction(title: "手动管理权限，请到：健康->右上角头像->隐私->APP->Elavatine，进行管理。", viewController: self)
            }else{
                self.authorizeHealthKitWorkouts { success, error in
                    
                }
            }
        }
        return vm
    }()
    lazy var hiddenStatSportDataVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.healtAlertSetVm.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "运动消耗计入营养目标"
        vm.leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
        vm.detailLabel.text = ""
        vm.arrowImgView.isHidden = true
//        vm.switchButton.isHidden = false
//        vm.switchButton.setSelectStatus(status: UserInfoModel.shared.statSportDataToTarget == "1" ? true : false)
        vm.switchBtn.isHidden = false
        vm.switchBtn.setOn(UserInfoModel.shared.statSportDataToTarget == "1" ? true : false, animated: false)
        vm.switchBlock = {(isSelect)in
            self.sendSportCaloriesUpdateRequest(statu: isSelect)
        }
        vm.tapBlock = {()in
            
        }
        vm.switchButton.tapBlock = {(isSelect)in
            self.sendSportCaloriesUpdateRequest(statu: isSelect)
//            self.hiddenStatSportDataVm.switchButton.setSelectStatus(status: isSelect)
        }
        return vm
    }()
    lazy var exportWeightVm : MaterialItemVM = {
        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.hiddenStatSportDataVm.frame.maxY, width: 0, height: 0))
        vm.leftLabel.text = "导出体重记录"
        vm.leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
        vm.tapBlock = { [weak self] in
            self?.exportWeightData()
        }
        return vm
    }()
//    lazy var weightAuthoriVm : MaterialItemVM = {
//        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.healthAppAuthoriLabel.frame.maxY, width: 0, height: 0))
//        vm.leftLabel.text = "同步体重数据"
//        vm.leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
//        vm.detailLabel.text = ""
//        vm.arrowImgView.isHidden = true
//        vm.switchButton.isHidden = false
//        
//        vm.tapBlock = {()in
//            
//        }
//        vm.switchButton.tapBlock = {(isSelect)in
//            self.authorizeWeightWorkouts { success, error in
//                DispatchQueue.main.async {
//                    if success{
//                        self.weightAuthoriVm.switchButton.setSelectStatus(status: true)
//                    }else{
//                        self.weightAuthoriVm.switchButton.setSelectStatus(status: false)
//                    }
//                }
//            }
//        }
//        return vm
//    }()
//    lazy var sportAuthoriVm : MaterialItemVM = {
//        let vm = MaterialItemVM.init(frame: CGRect.init(x: 0, y: self.weightAuthoriVm.frame.maxY, width: 0, height: 0))
//        vm.leftLabel.text = "同步运动消耗"
//        vm.leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
//        vm.detailLabel.text = ""
//        vm.arrowImgView.isHidden = true
//        vm.switchButton.isHidden = false
//        
//        vm.tapBlock = {()in
//            
//        }
//        vm.switchButton.tapBlock = {(isSelect)in
//            self.authorizeHealthKitWorkouts { success, error in
//                DispatchQueue.main.async {
//                    if success{
//                        self.sportAuthoriVm.switchButton.setSelectStatus(status: true)
//                    }else{
//                        self.sportAuthoriVm.switchButton.setSelectStatus(status: false)
//                    }
//                }
//                
//            }
//        }
//        return vm
//    }()
    lazy var mealsAlertVm: LogsMealsSetAlertVM = {
        let vm = LogsMealsSetAlertVM.init(frame: .zero)
        vm.confirmBlock = {(mealsNum)in
            self.sendSaveMealsNumRequest(mealsNum: mealsNum)
        }
        return vm
    }()
    lazy var weightUnitAlertVM: BodyDataWeightUnitSetAlertVM = {
        let vm = BodyDataWeightUnitSetAlertVM.init(frame: .zero)
        vm.confirmBlock = {(unit)in
            self.sendSaveWeightUnitRequest(unit: unit)
        }
        return vm
    }()
}
extension JournalSettingVC{
    func clearLogsAction() {
        let alertVc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popover = alertVc.popoverPresentationController {
            // 锚点设置为触发按钮
            popover.sourceView = self.resetLogsVm
            popover.permittedArrowDirections = [.up]
        }
        let clearNextAction = UIAlertAction(title: "清空今日开始往后的数据", style: .default) { action in
            self.presentAlertVc(confirmBtn: "是", message: "是否继续？", title: "点击“是”将清空今日往后的日志内容", cancelBtn: "否", handler: { action in
                LogsSQLiteManager.getInstance().deleteTableData(sDate: Date().nextDay(days: 0))
                self.sendClearLogsRequest(type: "today")
            }, viewController: self)
        }
        let clearAllAction = UIAlertAction(title: "清空所有数据", style: .default) { action in
            self.presentAlertVc(confirmBtn: "是", message: "是否继续？", title: "点击“是”将清空全部日志内容", cancelBtn: "否", handler: { action in
                LogsSQLiteManager.getInstance().deleteAllData()
                self.sendClearLogsRequest(type: "all")
            }, viewController: self)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alertVc.addAction(clearNextAction)
        alertVc.addAction(clearAllAction)
        alertVc.addAction(cancelAction)
        self.present(alertVc, animated: true)
    }
    func authorizeHealthKitWorkouts(completion: @escaping (Bool, Error?) -> Void) {
        healthStore.requestAuthorization(toShare: [healthKitTypesToRead], read: [healthKitTypesToRead]) { success, error in
            completion(success, error)
            UserDefaults.set(value: "1", forKey: .health_sport_Authori)
            DispatchQueue.main.async {
                self.healtAlertSetVm.detailLabel.text = "已授权"
            }
        }
    }
    
    func authorizeWeightWorkouts(completion: @escaping (Bool, Error?) -> Void) {
        healthStore.requestAuthorization(toShare: [weightType!], read: [weightType!]) { success, error in
            completion(success, error)
        }
    }
}

extension JournalSettingVC{
    func initUI() {
        initNavi(titleStr: "个性化设置")
        view.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        
        view.addSubview(scrollViewBase)
        scrollViewBase.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        scrollViewBase.frame = CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight())
        
        scrollViewBase.addSubview(logsTitleLabel)
        scrollViewBase.addSubview(resetLogsMealsVm)
//        scrollViewBase.addSubview(hiddenQuestionnaireVm)
        scrollViewBase.addSubview(hiddenLogsTimeVm)
        scrollViewBase.addSubview(caloriesShowVm)
        scrollViewBase.addSubview(waterShowVm)
        scrollViewBase.addSubview(nextMealShowVm)
        scrollViewBase.addSubview(mealsAlertSetVm)
//        scrollViewBase.addSubview(waterAlertVm)
        
        scrollViewBase.addSubview(bodydataTitleLabel)
        scrollViewBase.addSubview(resetWeightUnitVm)
        scrollViewBase.addSubview(hiddenStatSportDataVm)
//        scrollViewBase.addSubview(exportWeightVm)
        
        view.addSubview(mealsAlertVm)
        view.addSubview(weightUnitAlertVM)
        scrollViewBase.contentSize = CGSize.init(width: 0, height: hiddenStatSportDataVm.frame.maxY + kFitWidth(20))
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }
        
        scrollViewBase.addSubview(healthAppAuthoriLabel)
        scrollViewBase.addSubview(healtAlertSetVm)
        scrollViewBase.addSubview(hiddenStatSportDataVm)
//        scrollViewBase.addSubview(exportWeightVm)
//        scrollViewBase.addSubview(weightAuthoriVm)
//        scrollViewBase.addSubview(sportAuthoriVm)
        
        scrollViewBase.contentSize = CGSize.init(width: 0, height: hiddenStatSportDataVm.frame.maxY + kFitWidth(20))
        
//        updateAuthoriStatus()
    }
//    func updateAuthoriStatus() {
//        DispatchQueue.main.async {
//            if HKHealthStore.isHealthDataAvailable() {
//                if self.healthStore.authorizationStatus(for: self.weightType!) == HKAuthorizationStatus.sharingAuthorized{
//                    self.weightAuthoriVm.switchButton.setSelectStatus(status: true)
//                }else{
//                    self.weightAuthoriVm.switchButton.setSelectStatus(status: false)
//                }
//                
//                if self.healthStore.authorizationStatus(for: self.healthKitTypesToRead) == HKAuthorizationStatus.sharingAuthorized{
//                    self.sportAuthoriVm.switchButton.setSelectStatus(status: true)
//                }else{
//                    self.sportAuthoriVm.switchButton.setSelectStatus(status: false)
//                }
//            }
//        }
//    }
}

extension JournalSettingVC{
    func sendClearLogsRequest(type:String) {
        let param = ["cleartype":type]
        WHNetworkUtil.shareManager().POST(urlString: URL_clear_logs, parameters: param as [String: AnyObject],isNeedToast: true,vc: self) { responseObject in
            MCToast.mc_text("已重置日志列表数据",respond: .allow)//clearWaterDataFromToday
            HealthKitNaturnalManager().clearWaterDataFromToday { t in
                
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        }
    }
    @objc func sendSaveMealsNumRequest(mealsNum:Int) {
//        MCToast.mc_loading()
        let param = ["show_meals":"\(mealsNum)"]
        
       WHNetworkUtil.shareManager().POST(urlString: URL_User_Material_Update, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
           
           UserInfoModel.shared.mealsNumber = mealsNum
           self.resetLogsMealsVm.detailLabel.text = "\(UserInfoModel.shared.mealsNumber)餐"
           UserDefaults.set(value: "\(UserInfoModel.shared.mealsNumber)", forKey: .mealsNumber)
           NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        }
    }
    @objc func sendSaveWeightUnitRequest(unit:Int) {
//        MCToast.mc_loading()
        let param = ["weight_unit":"\(unit)"]
        
       WHNetworkUtil.shareManager().POST(urlString: URL_User_Material_Update, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
           
//           if unit == 2{
//               UserInfoModel.shared.weightUnit = unit
//               UserInfoModel.shared.weightUnitName = "斤"
//           }else if unit == 3{
//               UserInfoModel.shared.weightUnit = unit
//               UserInfoModel.shared.weightUnitName = "磅"
//           }else{
//               UserInfoModel.shared.weightUnit = 1
//               UserInfoModel.shared.weightUnitName = "kg"
//           }
           
           UserDefaults.set(value: "\(unit)", forKey: .weightUnit)
           UserDefaults.initWeightUnit()
           self.resetWeightUnitVm.detailLabel.text = "\(UserInfoModel.shared.weightUnitName)"
           
           
//           NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        }
    }
//    @objc func sendSaveSurveryStatusRequest(statu:Bool) {
////        MCToast.mc_loading()
//        let param = ["survey_button_status":"\(statu ? 0 : 1)"]
//        
//       WHNetworkUtil.shareManager().POST(urlString: URL_User_Material_Update, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: "\(responseObject)")
//           
//           UserInfoModel.shared.hidden_survery_button_status = statu
//           self.hiddenQuestionnaireVm.switchButton.setSelectStatus(status: UserInfoModel.shared.hidden_survery_button_status)
//           UserDefaults.set(value: "\(UserInfoModel.shared.hidden_survery_button_status ? 0 : 1)", forKey: .isShowSurveryButton)
//           NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
//        }
//    }
    @objc func sendSaveLogsTimeRequest(statu:Bool) {
//        MCToast.mc_loading()
        let param = ["meal_time_status":"\(statu ? 0 : 1)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_config_set, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
           
            UserInfoModel.shared.hiddenMeaTimeStatus = statu
            self.hiddenLogsTimeVm.switchButton.setSelectStatus(status: UserInfoModel.shared.hiddenMeaTimeStatus)
           UserDefaults.set(value: "\(UserInfoModel.shared.hiddenMeaTimeStatus ? 0 : 1)", forKey: .isShowLogsTime)
            
           NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        }
    }
    @objc func sendNatGoalStyleRequest(statu:Bool) {
//        MCToast.mc_loading()
        let param = ["nut_goal_style":"\(statu ? 2 : 1)"]
        DLLog(message: "sendNatGoalStyleRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_config_set, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "sendNatGoalStyleRequest:\(responseObject)")
           
            UserInfoModel.shared.showRemainCalories = statu
            self.caloriesShowVm.switchButton.setSelectStatus(status: UserInfoModel.shared.showRemainCalories)
           UserDefaults.set(value: "\(UserInfoModel.shared.showRemainCalories ? 2 : 1)", forKey: .isShowLogsRemainCalories)
            
           NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsCaloriesStyleMsg"), object: nil)
        }
    }
    @objc func sendWaterConfigRequest(statu:Bool) {
//        MCToast.mc_loading()
        let param = ["drinking_water_status":"\(statu ? 1 : 0)"]
        DLLog(message: "sendWaterConfigRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_config_set, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "sendWaterConfigRequest:\(responseObject)")
           
            UserInfoModel.shared.show_water_status = statu
            self.waterShowVm.switchButton.setSelectStatus(status: UserInfoModel.shared.show_water_status)
            NotificationCenter.default.post(name: NOTIFI_NAME_SHORTCUTITEMS, object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        }
    }
    @objc func sendNextMealAdviceConfigRequest(statu:Bool) {
//        MCToast.mc_loading()
        let param = ["next_meal_advice_status":"\(statu ? 1 : 0)"]
        DLLog(message: "sendNextMealAdviceConfigRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_config_set, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "sendNextMealAdviceConfigRequest:\(responseObject)")
           
            UserInfoModel.shared.show_next_advice = statu
            self.nextMealShowVm.switchButton.setSelectStatus(status: UserInfoModel.shared.show_next_advice)
//            NotificationCenter.default.post(name: NOTIFI_NAME_SHORTCUTITEMS, object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        }
    }
    @objc func sendSportCaloriesUpdateRequest(statu:Bool) {
//        let param = ["sport_calories_in_target":"\(statu ? 2 : 1)"]
        let param = ["target_include_sport_calories":"\(statu ? 1 : 0)",
                     "sport_calories_in_target":"\(statu ? 2 : 1)"]
        DLLog(message: "sendSportCaloriesUpdateRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_config_set, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
           
            UserInfoModel.shared.statSportDataFromHealth = "\(statu ? 2 : 1)"
            UserInfoModel.shared.statSportDataToTarget = "\(statu ? 1 : 0)"
//            self.hiddenStatSportDataVm.switchButton.setSelectStatus(status: UserInfoModel.shared.statSportDataFromHealth == "2" ? true : false)
            self.hiddenStatSportDataVm.switchButton.setSelectStatus(status: UserInfoModel.shared.statSportDataToTarget == "1" ? true : false)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
            WidgetUtils().saveSportInTargetStatus(status: UserInfoModel.shared.statSportDataToTarget)
            WidgetUtils().reloadWidgetData()
        }
    }
    @objc func exportWeightData() {
        if let url = BodyDataSQLiteManager.getInstance().exportWeightDataCSV() {
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let popover = vc.popoverPresentationController {
                popover.sourceView = self.exportWeightVm
            }
            self.present(vc, animated: true)
        } else {
            MCToast.mc_text("导出失败", respond: .allow)
        }
    }
}
