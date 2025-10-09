//
//  PlanDetailVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/11.
//

import Foundation
import MCToast
import IQKeyboardManagerSwift

class PlanDetailVC: WHBaseViewVC {
    
    var currentday = 1
    var currentDayForRequest = 1
    var planDictMsg = NSDictionary()
    
    var lastTopMsgVm = PlanDetailTopVM()
    var currentTopMsgVm = PlanDetailTopVM()
    var nextTopMsgVm = PlanDetailTopVM()
    
    var lastMealsMsgVm = PlanDetailDayMealsVM()
    var currentMealsMsgVm = PlanDetailDayMealsVM()
    var nextMealsMsgVm = PlanDetailDayMealsVM()
    
    var edgePanChangeX = CGFloat(0)
    
    var dataSourceArray = NSMutableArray()
    var daysIndex = 0//
    var currentDayDict = NSDictionary()
    
    var isEdit = false
    var nameChangeBlock:((String)->())?
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.currentMealsMsgVm.removeNotifiCenter()
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        if isEdit {
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendPlanDetailRequest()
    }
    lazy var naviVm : PlanDetailNaviVM = {
        let vm = PlanDetailNaviVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "\(self.planDictMsg["pname"]as? String ?? "")"
        vm.pname = "\(self.planDictMsg["pname"]as? String ?? "")"
//        vm.backButton.addTarget(self, action: #selector(backTapAction), for: .touchUpInside)
        vm.backButton.tapBlock = {()in
            self.backTapAction()
        }
        vm.deleteBlock = {()in
            if self.planDictMsg["state"]as? Int ?? 0 == 1{
                //删除激活中的计划，将清空今日往后的日志数据
                self.presentAlertVc(confirmBtn: "删除", message: "删除该计划同时会清空今日往后的日志内容", title: "温馨提示", cancelBtn: "取消", handler: { action in
                    self.sendDelPlanRequest()
                }, viewController: self)
            }else{
                self.presentAlertVc(confirmBtn: "删除", message: "", title: "删除计划“\(self.planDictMsg["pname"]as? String ?? "")”？", cancelBtn: "取消", handler: { action in
                    self.sendDelPlanRequest()
                }, viewController: self)
            }
            
        }
        vm.shareBlock = {()in
            let vc = PlanShareVC()
            vc.sid = "\(self.currentDayDict["sid"]as? String ?? "")"
            vc.placeDetailsDict = self.currentDayDict
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.cancelBlock = {()in
            self.isEdit = false
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
            self.bottomVm.changeStatus(isUpdate: false)
            self.naviVm.changeStatus(isUpdate: false)
            self.dayVm.changeStatus(isUpdate: false)
            self.dayTopVm.changeStatus(isUpdate: false)
            self.currentMealsMsgVm.changeUpdate(isUpdate: false)
            self.dayVm.updateUI(currentIndex: self.daysIndex, totalDay: self.currentDayDict["totaldays"]as? Int ?? 0)
            self.dayTopVm.updateUI(currentIndex: self.daysIndex, totalDay: self.currentDayDict["totaldays"]as? Int ?? 0)
            let dict = self.dataSourceArray[self.daysIndex]as? NSDictionary ?? [:]
            self.currentMealsMsgVm.setDataSource(dict: dict, index: self.daysIndex)
            self.topVm.updateUI(dict: dict)
        }
        vm.updateTitleBlock = {()in
            self.nameAlertVm.showView()
            self.nameAlertVm.textField.text = self.planDictMsg.stringValueForKey(key: "pname")
            self.nameAlertVm.startCountdown()
        }
        return vm
    }()
    lazy var topVm : PlanDetailTopVM = {
        let vm = PlanDetailTopVM.init(frame: .zero)
        
        return vm
    }()
    lazy var dayVm : PlanDetailDaysVM = {
        let vm = PlanDetailDaysVM.init(frame: CGRect.init(x: 0 ,y: self.topVm.frame.maxY, width: 0, height: 0))
        vm.nextBlock = {()in
            if self.daysIndex < self.currentDayDict["totaldays"]as? Int ?? 0 - 1{
                self.daysIndex = self.daysIndex + 1
                self.sendNextPlanDetailRequest { responseObject in
                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                        self.currentMealsMsgVm.center = CGPoint.init(x: -SCREEN_WIDHT*0.5, y: self.currentMealsMsgVm.center.y)
                        self.nextMealsMsgVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.nextMealsMsgVm.center.y)
                    }completion: { t in
                        self.scrollEndUpdateData()
                        self.dayVm.nextButton.isEnabled = true
                        self.dayVm.lastButton.isEnabled = true
                        self.dayTopVm.nextButton.isEnabled = true
                        self.dayTopVm.lastButton.isEnabled = true
                    }
                }
            }
            
        }
        vm.lastBlock = {()in
            if self.daysIndex > 0 {
                self.daysIndex = self.daysIndex - 1
                UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                    self.currentMealsMsgVm.center = CGPoint.init(x: SCREEN_WIDHT*1.5, y: self.currentMealsMsgVm.center.y)
                    self.lastMealsMsgVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.lastMealsMsgVm.center.y)
                }completion: { t in
                    self.scrollEndUpdateData()
                }
            }
        }
        return vm
    }()
    lazy var dayTopVm : PlanDetailDaysVM = {
        let vm = PlanDetailDaysVM.init(frame: CGRect.init(x: 0 ,y: self.getNavigationBarHeight(), width: 0, height: 0))
        vm.isHidden = true
        vm.nextBlock = {()in
            if self.daysIndex < self.dataSourceArray.count - 1{
                self.daysIndex = self.daysIndex + 1
                self.sendNextPlanDetailRequest { responseObject in
                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                        self.currentMealsMsgVm.center = CGPoint.init(x: -SCREEN_WIDHT*0.5, y: self.currentMealsMsgVm.center.y)
                        self.nextMealsMsgVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.nextMealsMsgVm.center.y)
                    }completion: { t in
                        self.scrollEndUpdateData()
                        self.dayVm.nextButton.isEnabled = true
                        self.dayVm.lastButton.isEnabled = true
                        self.dayTopVm.nextButton.isEnabled = true
                        self.dayTopVm.lastButton.isEnabled = true
                    }
                }
            }
        }
        vm.lastBlock = {()in
            if self.daysIndex > 0 {
                self.daysIndex = self.daysIndex - 1
                UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                    self.currentMealsMsgVm.center = CGPoint.init(x: SCREEN_WIDHT*1.5, y: self.currentMealsMsgVm.center.y)
                    self.lastMealsMsgVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.lastMealsMsgVm.center.y)
                }completion: { t in
                    self.scrollEndUpdateData()
                }
            }
        }
        return vm
    }()
    lazy var bottomVm : PlanDetailBottomVM = {
        let vm = PlanDetailBottomVM.init(frame: .zero)
        vm.activeBlock = {()in
            if self.planDictMsg["state"]as? Int ?? 0 == 0{
                self.presentAlertVc(confirmBtn: "激活", message: "确认从今日开始激活计划？\n注意：此操作将覆盖所有未来计划\n会清除碳循环目标", title: "提示", cancelBtn: "取消", handler: { action in
                    self.sendActivePlanRequest()
                }, viewController: self)
            }else{
                self.presentAlertVc(confirmBtn: "停止", message: "确认停止计划？\n注意：此操作将清除今日往后的所有日志\n会清除碳循环目标", title: "提示", cancelBtn: "取消", handler: { action in
                    self.sendClearLogsRequest()
                }, viewController: self)
            }
        }
        vm.updateBlock = {()in
            if self.planDictMsg["state"]as? Int ?? 0 == 0 && (self.daysIndex < self.dataSourceArray.count){
                self.isEdit = true
                self.bottomVm.changeStatus(isUpdate: true)
                self.naviVm.changeStatus(isUpdate: true)
                self.dayVm.changeStatus(isUpdate: true)
                self.dayTopVm.changeStatus(isUpdate: true)
                self.currentMealsMsgVm.changeUpdate(isUpdate: true)
                
                let dict = self.dataSourceArray[self.daysIndex]as? NSDictionary ?? [:]
                self.currentMealsMsgVm.setDataSource(dict: dict, index: self.daysIndex)
                self.currentMealsMsgVm.refresSelfFrame()
                
//                self.navigationController?.fd_interactivePopDisabled = true
                self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
            }else{
                self.presentAlertVc(confirmBtn: "确定", message: "若您仍想修改此计划，请先停止计划。", title: "当前计划执行中", cancelBtn: nil, handler: { action in
                    
                }, viewController: self)
            }
        }
        vm.saveBlock = {()in
            self.isEdit = false
            
//            self.navigationController?.fd_interactivePopDisabled = true
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
            self.updateCheckValue()
        }
        return vm
    }()
    lazy var nameAlertVm: MaterialNickNameAlertVM = {
        let vm = MaterialNickNameAlertVM.init(frame: .zero)
        vm.textField.placeholder = "计划名称15字以内"
        vm.maxLength = 15
        vm.isUpdatePlanName = true
//        vm.textField.delegate = nil
        
        vm.confirmBlock = {(name)in
            if name == "" || name.count == 0{
                return
            }
            self.sendRenamePlanRequest(name: self.nameAlertVm.textField.text ?? "")
        }
        return vm
    }()
}

extension PlanDetailVC{
    func initUI() {
        view.addSubview(naviVm)
        view.addSubview(scrollViewBase)
        view.addSubview(dayTopVm)
        view.addSubview(bottomVm)
//        view.addSubview(panGestureView)
        scrollViewBase.frame = CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight()-kFitWidth(56)-getBottomSafeAreaHeight())
        
        if self.planDictMsg["state"]as? Int ?? 0 == 0{
            
        }else{
//            scrollViewBase.frame = CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight())
            bottomVm.activeButton.setTitle("停止计划", for: .normal)
        }
        
        scrollViewBase.delegate = self
        scrollViewBase.contentInsetAdjustmentBehavior = .never
        
        scrollViewBase.addSubview(topVm)
        scrollViewBase.addSubview(dayVm)
     
        view.addSubview(nameAlertVm)
    }
    func refreshUI() {
//        SQLiteManager.getInstance().updatePlan(planId: "\(self.planDictMsg["pid"]as? String ?? "")", details: self.getJSONStringFromArray(array: self.dataSourceArray))
        currentDayDict = self.dataSourceArray[self.daysIndex]as? NSDictionary ?? [:]
        topVm.updateUI(dict: currentDayDict)
        dayTopVm.updateUI(currentIndex: self.daysIndex, totalDay: currentDayDict["totaldays"]as? Int ?? 0)
        dayVm.updateUI(currentIndex: self.daysIndex, totalDay: currentDayDict["totaldays"]as? Int ?? 0)
        updateDaysData()
        
        if self.currentDayForRequest < currentDayDict["totaldays"]as? Int ?? 0{
//            sendNextPlanDetailRequest()
            self.sendNextPlanDetailRequest { responseObject in
                
            }
        }
    }
    func updateDaysData() {
        currentDayDict = self.dataSourceArray[self.daysIndex]as? NSDictionary ?? [:]
        topVm.updateUI(dict: currentDayDict)
        
        currentMealsMsgVm = PlanDetailDayMealsVM.init(frame: CGRect.init(x: 0, y: self.dayVm.frame.maxY, width: 0, height: 0))
        scrollViewBase.addSubview(currentMealsMsgVm)
        currentMealsMsgVm.controller = self
        
        let dict = self.dataSourceArray[0]as? NSDictionary ?? [:]
        
        currentMealsMsgVm.updateBlock = {(height)in
            self.scrollViewBase.contentSize = CGSize.init(width: 0, height: height+self.dayVm.frame.maxY)
        }
        currentMealsMsgVm.numberUpdateBlock = {(dict)in
//            self.topVm.updateUI(dict: dict)
            self.topVm.updateNumber(dict: dict)
        }
        currentMealsMsgVm.setDataSource(dict: dict,index: 0)
//        self.scrollViewBase.contentSize = CGSize.init(width: 0, height: currentMealsMsgVm.selfHeight+self.dayVm.frame.maxY)
        if self.dataSourceArray.count > 1 {
            nextMealsMsgVm = PlanDetailDayMealsVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.dayVm.frame.maxY, width: 0, height: 0))
            scrollViewBase.addSubview(nextMealsMsgVm)
            
            let dict = self.dataSourceArray[1]as? NSDictionary ?? [:]
            nextMealsMsgVm.setDataSource(dict: dict,index: 1)
        }
    }
    func scrollEndUpdateData() {
        lastMealsMsgVm.removeFromSuperview()
        nextMealsMsgVm.removeFromSuperview()
        currentMealsMsgVm.removeFromSuperview()
        
        currentDayDict = self.dataSourceArray[self.daysIndex]as? NSDictionary ?? [:]
        topVm.updateUI(dict: currentDayDict)
        
        self.dayVm.updateUI(currentIndex: self.daysIndex, totalDay: currentDayDict["totaldays"]as? Int ?? 0)
        self.dayTopVm.updateUI(currentIndex: self.daysIndex, totalDay: currentDayDict["totaldays"]as? Int ?? 0)
        
        currentMealsMsgVm = PlanDetailDayMealsVM.init(frame: CGRect.init(x: 0, y: self.dayVm.frame.maxY, width: 0, height: 0))
        scrollViewBase.addSubview(currentMealsMsgVm)
        currentMealsMsgVm.controller = self
        
        let dict = self.dataSourceArray[self.daysIndex]as? NSDictionary ?? [:]
        currentMealsMsgVm.updateBlock = {(height)in
            self.scrollViewBase.contentSize = CGSize.init(width: 0, height: height+self.dayVm.frame.maxY)
        }
        currentMealsMsgVm.numberUpdateBlock = {(dict)in
//            self.topVm.updateUI(dict: dict)
            self.topVm.updateNumber(dict: dict)
        }
        currentMealsMsgVm.setDataSource(dict: dict,index: self.daysIndex)
//        self.scrollViewBase.contentSize = CGSize.init(width: 0, height: currentMealsMsgVm.selfHeight+self.dayVm.frame.maxY)
        
        if self.daysIndex > 0 {
            lastMealsMsgVm = PlanDetailDayMealsVM.init(frame: CGRect.init(x: -SCREEN_WIDHT, y: self.dayVm.frame.maxY, width: 0, height: 0))
            scrollViewBase.addSubview(lastMealsMsgVm)
            
            let dict = self.dataSourceArray[self.daysIndex-1]as? NSDictionary ?? [:]
            lastMealsMsgVm.setDataSource(dict: dict,index: self.daysIndex-1)
        }
        if self.daysIndex < self.dataSourceArray.count - 1{
            nextMealsMsgVm = PlanDetailDayMealsVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.dayVm.frame.maxY, width: 0, height: 0))
            scrollViewBase.addSubview(nextMealsMsgVm)
            
            let dict = self.dataSourceArray[self.daysIndex+1]as? NSDictionary ?? [:]
            nextMealsMsgVm.setDataSource(dict: dict,index:self.daysIndex+1)
        }
    }
    @objc func updateCheckValue(){
        var hasFoods = false
        for i in 0..<self.currentMealsMsgVm.mealsDataArray.count{
            let foodsArr = self.currentMealsMsgVm.mealsDataArray[i]as? NSArray ?? []
            if foodsArr.count > 0 {
                hasFoods = true
                break
            }
        }
        if hasFoods{
            self.sendPlanUpdateRequest()
        }else{
            self.presentAlertVcNoAction(title: "请至少添加一种食物", viewController: self)
        }
    }
}

extension PlanDetailVC{
    func sendPlanDetailRequest() {
//        MCToast.mc_loading()
        let param = ["pid":"\(self.planDictMsg["pid"]as? String ?? "")",
                     "currentday":"\(currentday)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_dietplan_detail, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: "\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
//            let arr = responseObject["data"]as? NSArray ?? []
            
            DLLog(message: "sendPlanDetailRequest:\(dataObj)")
            self.dataSourceArray.addObjects(from: dataObj as! [Any])
            self.refreshUI()
        }
    }
    func sendNextPlanDetailRequest(success :@escaping (_ responseObject : [String : AnyObject]) -> ()){
        if currentDayForRequest < currentDayDict["totaldays"]as? Int ?? 0{
            if currentDayForRequest - daysIndex >= 3{
                success(["code":"200"]as [String : AnyObject])
                return
            }
            currentDayForRequest = currentDayForRequest + 1
        }else{
            success(["code":"200"]as [String : AnyObject])
            return
        }
        let param = ["pid":"\(self.planDictMsg["pid"]as? String ?? "")",
                     "currentday":"\(currentDayForRequest)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_dietplan_detail, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: "\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
//            let arr = responseObject["data"]as? NSArray ?? []
            self.dataSourceArray.addObjects(from: dataObj as! [Any])
            
            if self.currentDayForRequest == 2 {
                if self.dataSourceArray.count > 1 {
                    self.nextMealsMsgVm = PlanDetailDayMealsVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.dayVm.frame.maxY, width: 0, height: 0))
                    self.scrollViewBase.addSubview(self.nextMealsMsgVm)
                    
                    let dict = self.dataSourceArray[1]as? NSDictionary ?? [:]
                    self.nextMealsMsgVm.setDataSource(dict: dict,index: 1)
                }
            }
            success(["code":"200"]as [String : AnyObject])
            
            self.sendNextPlanDetailRequest { responseObject in
                
            }
        }
    }
    func sendDelPlanRequest() {
        MCToast.mc_loading()
        let param = ["pid":"\(self.planDictMsg["pid"]as? String ?? "")"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_dietplan_del, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshListData"), object: nil)
            MCToast.mc_remove()
            MCToast.mc_text("“\(self.planDictMsg["pname"]as? String ?? "")”计划已删除")
            
            if self.planDictMsg["state"]as? Int ?? 0 == 1{
                //删除激活中的计划，将清空今日往后的日志数据
                LogsSQLiteManager.getInstance().deleteTableData(sDate: Date().nextDay(days: 0))
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
            }
            
            self.backTapAction()
        }
    }
    func sendActivePlanRequest() {
        MCToast.mc_loading(text: "计划激活中...",duration: 30)
        let param = ["pid":"\(self.planDictMsg["pid"]as? String ?? "")"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_dietplan_active, parameters: param as [String : AnyObject],isNeedToast: true,vc: self,timeOut: 30) { responseObject in
            MCToast.mc_text("“\(self.planDictMsg["pname"]as? String ?? "")”计划已激活",respond: .forbid)
            self.getUserConfigRequest()
            self.bottomVm.isHidden = true
            self.scrollViewBase.frame = CGRect.init(x: 0, y: self.getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.getNavigationBarHeight())
            
            LogsSQLiteManager.getInstance().deleteTableData(sDate: Date().nextDay(days: 0))
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshListData"), object: nil)
                self.navigationController?.tabBarController?.selectedIndex = 1
                self.navigationController?.popToRootViewController(animated: true)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "activePlan"), object: nil)
            })
        }
    }
    func getUserConfigRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_config_msg, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "getUserConfigRequest:\(dataObj)")
            UserInfoModel.shared.updateUserConfig(dict: dataObj)
        }
    }
    func sendClearLogsRequest() {
        LogsSQLiteManager.getInstance().deleteTableData(sDate: Date().nextDay(days: 0))
        let param = ["cleartype":"today"]
        WHNetworkUtil.shareManager().POST(urlString: URL_clear_logs, parameters: param as [String: AnyObject],isNeedToast: true,vc: self) { responseObject in
//            MCToast.mc_text("已重置日志列表数据",respond: .respond)
            HealthKitNaturnalManager().clearWaterDataFromToday { t in
                
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshListData"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
            self.backTapAction()
        }
    }
    func sendPlanUpdateRequest(){
        MCToast.mc_loading()
        let param = ["sid":"\(self.currentMealsMsgVm.sid)",
                     "totalProteins":"\(Int(self.currentMealsMsgVm.proteinTotalNum.rounded()))",
                     "totalCarbohydrates":"\(Int(self.currentMealsMsgVm.carboTotalNum.rounded()))",
                     "totalFats":"\(Int(self.currentMealsMsgVm.fatTotalNum.rounded()))",
                     "totalCalories":"\(Int(self.currentMealsMsgVm.caloriesTotalNum.rounded()))",
                     "meals":self.currentMealsMsgVm.mealsDataArray] as [String : Any]
        WHNetworkUtil.shareManager().POST(urlString: URL_dietplan_update, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            self.bottomVm.changeStatus(isUpdate: false)
            self.naviVm.changeStatus(isUpdate: false)
            self.dayVm.changeStatus(isUpdate: false)
            self.dayTopVm.changeStatus(isUpdate: false)
            self.currentMealsMsgVm.changeUpdate(isUpdate: false)
            self.dayVm.updateUI(currentIndex: self.daysIndex, totalDay: self.currentDayDict["totaldays"]as? Int ?? 0)
            self.dayTopVm.updateUI(currentIndex: self.daysIndex, totalDay: self.currentDayDict["totaldays"]as? Int ?? 0)
            
            let dict = NSMutableDictionary(dictionary: self.dataSourceArray[self.daysIndex]as? NSDictionary ?? [:])
            dict.setValue(self.currentMealsMsgVm.mealsDataArray, forKey: "meals")
            self.dataSourceArray.replaceObject(at: self.daysIndex, with: dict)
//            let dict = self.dataSourceArray[self.daysIndex]as? NSDictionary ?? [:]
            self.currentMealsMsgVm.setDataSource(dict: dict, index: self.daysIndex)
        }
    }
}

extension PlanDetailVC:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= self.dayVm.frame.minY{
            dayTopVm.isHidden = false
        }else{
            dayTopVm.isHidden = true
        }
    }
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        // 获取当前手势所在的view
        if let view = gesture.view {
            // 根据手势移动view的位置
            switch gesture.state {
            case .began:
                self.edgePanChangeX = CGFloat(0)
            case .changed:
                let translation = gesture.translation(in: view)
                DLLog(message: "translation.x:\(translation.x)")
                self.edgePanChangeX = self.edgePanChangeX + translation.x
                
                if self.edgePanChangeX < 0 && self.daysIndex == self.dataSourceArray.count - 1{
                    return
                }
                if self.edgePanChangeX > 0 && self.daysIndex == 0 {
                    return
                }
                DLLog(message: "\(SCREEN_WIDHT*0.5)   +    \(self.edgePanChangeX)")
                self.currentMealsMsgVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5+self.edgePanChangeX, y: self.currentMealsMsgVm.center.y)
                self.lastMealsMsgVm.center = CGPoint.init(x: -SCREEN_WIDHT*0.5+self.edgePanChangeX, y: self.lastMealsMsgVm.center.y)
                self.nextMealsMsgVm.center = CGPoint.init(x: SCREEN_WIDHT*1.5+self.edgePanChangeX, y: self.nextMealsMsgVm.center.y)
                
                gesture.setTranslation(.zero, in: view)
                
            case .ended:
                DLLog(message: "handlePanGesture  ended:\(self.edgePanChangeX)")
                DLLog(message: "currentMealsMsgVm.center.x:\(self.currentMealsMsgVm.center.x)")
                
                if self.edgePanChangeX > 0 && self.daysIndex == 0{
//                    self.backTapAction()
                    return
                }
                
                if self.edgePanChangeX < 0 && self.daysIndex < self.dataSourceArray.count - 1 {
                    self.daysIndex = self.daysIndex + 1
                    if self.daysIndex > self.dataSourceArray.count - 1{
                        self.daysIndex = self.dataSourceArray.count - 1
                    }
                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                        self.currentMealsMsgVm.center = CGPoint.init(x: -SCREEN_WIDHT*0.5, y: self.currentMealsMsgVm.center.y)
                        self.nextMealsMsgVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.nextMealsMsgVm.center.y)
                    }completion: { t in
                        self.scrollEndUpdateData()
                    }
                }
                if self.edgePanChangeX > 0 && self.daysIndex > 0 {
                    self.daysIndex = self.daysIndex - 1
                    if self.daysIndex < 0 {
                        self.daysIndex = 0
                    }
                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                        self.currentMealsMsgVm.center = CGPoint.init(x: SCREEN_WIDHT*1.5, y: self.currentMealsMsgVm.center.y)
                        self.lastMealsMsgVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.lastMealsMsgVm.center.y)
                    }completion: { t in
                        self.scrollEndUpdateData()
                    }
                }
                break
            default:
                break
            }
        }
    }
    func sendRenamePlanRequest(name:String) {
        let param = ["pid":"\(self.planDictMsg.stringValueForKey(key: "pid"))",
                     "pname":name]
        WHNetworkUtil.shareManager().POST(urlString: URL_dietplan_rename, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
            self.naviVm.titleLabel.text = name
            self.naviVm.pname = name
            if self.nameChangeBlock != nil{
                self.nameChangeBlock!(name)
            }
        }
    }
}
