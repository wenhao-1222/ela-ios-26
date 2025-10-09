//
//  PlanListVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/11.
//

import Foundation
import IQKeyboardManagerSwift
import MCToast

class PlanListVC: WHBaseViewVC {
    
    var dataSourceArray = NSMutableArray()
    var activePlanData = NSDictionary()
    var keyWords = ""
    
    var planName = ""
    var planIndex = 0
    var isFirstLoad = true
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.fd_interactivePopDisabled = false
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
    }
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
//        self.topVm.textField.startCountdown()
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(sendPlanListRequest), name: NSNotification.Name(rawValue: "leadIntoPlan"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: "refreshListData"), object: nil)
        
        
        initUI()
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
            self.sendPlanListRequest()
            self.sendGetActivePlanRequest()
//        })
    }
    lazy var topVm : PlanListSearchVM = {
        let vm = PlanListSearchVM.init(frame: .zero)
        vm.backBlock = {()in
            self.backTapAction()
        }
        vm.searchBlock = {()in
            self.keyWords = self.topVm.textField.text ?? ""
//            self.sendPlanListRequest()
            let vc = PlanListSearchVC()
            vc.keyWords = self.keyWords.disable_emoji(text: self.keyWords as NSString)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.getPlanBlock = {()in
            if UserInfoModel.shared.birthDay.count > 0 && (UserInfoModel.shared.gender == "1" || UserInfoModel.shared.gender == "2"){
                QuestinonaireMsgModel.shared.sex = UserInfoModel.shared.gender
                QuestinonaireMsgModel.shared.weight = ""
                QuestinonaireMsgModel.shared.birthDay = Date().changeDateFormatter(dateString: UserInfoModel.shared.birthDay, formatter: "yyyy-MM-dd", targetFormatter: "yyyy")
                let vc = PlanGetNoSexVC()
                vc.savePlanBlock = {()in
                    self.refreshData()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                let vc = PlanGetVC()
                vc.savePlanBlock = {()in
                    self.refreshData()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        vm.createPlanBlock = {()in
            let vc = PlanCreateVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.leadPlanBlock = {()in
            self.leadPlanAlertVm.showAlertVM()
        }
        return vm
    }()
    lazy var tableView : UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: self.topVm.frame.maxY+kFitWidth(8), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.topVm.frame.maxY), style: .plain)
        vi.backgroundColor = .white
        vi.register(PlanListTableViewCell.classForCoder(), forCellReuseIdentifier: "PlanListTableViewCell")
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        
        return vi
    }()
    lazy var headActiveVm: PlanListActiveCellVM = {
        let vm = PlanListActiveCellVM.init(frame: .zero)
        vm.tapBlock = {()in
            let vc = PlanDetailVC()
            vc.planDictMsg = self.activePlanData
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.isHidden = true
        return vi
    }()
    lazy var leadPlanAlertVm : PlanLeadIntoAlertVM = {
        let vm = PlanLeadIntoAlertVM.init(frame: .zero)
        vm.controller = self
        vm.leadBlock = {()in
            
            self.dataSourceArray.removeAllObjects()
            self.sendPlanListRequest()
            self.sendGetActivePlanRequest()
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
            
//            self.nameAlertVm.disableTimer()
            if name == "" || name.count == 0{
//                MCToast.mc_failure("计划名称不能为空！")
                return
            }
            self.planName = self.nameAlertVm.textField.text ?? ""
            self.sendRenamePlanRequest()
//            self.sendSaveMaterialRequest()
        }
        return vm
    }()
}

extension PlanListVC{
    @objc func refreshData() {
        self.activePlanData = NSDictionary()
        self.dataSourceArray.removeAllObjects()
        self.tableView.reloadData()
        self.sendPlanListRequest()
        self.sendGetActivePlanRequest()
    }
}
extension PlanListVC{
    func initUI() {
        view.backgroundColor = WHColor_16(colorStr: "F5F5F5")
        view.addSubview(topVm)
        view.addSubview(tableView)
        tableView.addSubview(noDataView)
        
        view.addSubview(leadPlanAlertVm)
        view.addSubview(nameAlertVm)
        
        initSkeletonData()
    }
    func initSkeletonData() {
        dataSourceArray.add([:])
        dataSourceArray.add([:])
        dataSourceArray.add([:])
        dataSourceArray.add([:])
        dataSourceArray.add([:])
        dataSourceArray.add([:])
        dataSourceArray.add([:])
        dataSourceArray.add([:])
        tableView.reloadData()
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.03, execute: {
//            self.tableView.showAnimatedGradientSkeleton()
//        })
    }
}

extension PlanListVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFirstLoad == false{
            noDataView.isHidden = self.dataSourceArray.count > 0 ? true : false
        }
        return self.dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanListTableViewCell", for: indexPath) as? PlanListTableViewCell
        
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict)
        return cell ?? PlanListTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(92)//indexPath.row == 0 ? kFitWidth(92) : kFitWidth(112)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = NSMutableDictionary(dictionary: self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:])
        if dict.stringValueForKey(key: "pname").isEmpty {
            return
        }
        let vc = PlanDetailVC()
        vc.planDictMsg = dict
        self.navigationController?.pushViewController(vc, animated: true)
        
        vc.nameChangeBlock = {(name)in
            dict.setValue(name, forKey: "pname")
            self.dataSourceArray.replaceObject(at: indexPath.row, with: dict)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.topVm.textField.resignFirstResponder()
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        if dict.stringValueForKey(key: "pname").isEmpty {
            return false
        }
        return true
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        if dict.stringValueForKey(key: "pname").isEmpty {
            return nil
        }
        let editAction  = UIContextualAction.init(style: .normal, title: "修改计划名") { _,_,_ in
            TouchGenerator.shared.touchGenerator()
            self.tableView.setEditing(false, animated: true)
            self.planIndex = indexPath.row
            self.nameAlertVm.showView()
            self.nameAlertVm.textField.text = dict.stringValueForKey(key: "pname")
            self.nameAlertVm.startCountdown()
            DLLog(message: "修改 \(dict["pname"]as? String ?? "")")
        }
        let deleteAction  = UIContextualAction.init(style: .destructive, title: "删除") { _,_,_ in
            TouchGenerator.shared.touchGenerator()
            if dict["state"]as? Int ?? 0 == 1{
                //删除激活中的计划，将清空今日往后的日志数据
                self.presentAlertVc(confirmBtn: "删除", message: "删除该计划同时会清空今日往后的日志内容", title: "温馨提示", cancelBtn: "取消", handler: { action in
                    self.sendDelPlanRequest(planDictMsg: dict, success: {
                        self.dataSourceArray.removeObject(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    })
                }, viewController: self)
                return
            }
            
            self.sendDelPlanRequest(planDictMsg: dict, success: {
                self.dataSourceArray.removeObject(at: indexPath.row)
//                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .fade)
//                self.tableView.endUpdates()
            })
        }
        editAction.backgroundColor = .COLOR_BUTTON_HIGHLIGHT_BG_THEME
        
        let actions = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        actions.performsFirstActionWithFullSwipe = false
        
        return actions
    }
}

extension PlanListVC{
    @objc func sendPlanListRequest() {
//        MCToast.mc_loading()
        let param = ["uid":"\(UserInfoModel.shared.uId)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_dietplan_list, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: "\(responseObject)")
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendPlanListRequest:\(dataArray)")
            self.isFirstLoad = false
            
            if self.activePlanData.stringValueForKey(key: "pname").count > 0{
                self.dataSourceArray = NSMutableArray(array: dataArray)
                self.dataSourceArray.insert(self.activePlanData, at: 0)
            }else{
                self.dataSourceArray = NSMutableArray(array: dataArray)
            }
            
//            self.dataSourceArray.addObjects(from: dataArray as! [Any])
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
            }
        }
    }
    func sendGetActivePlanRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_dietplan_plan_active, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            self.isFirstLoad = false
            self.activePlanData = dataObj
            self.dataSourceArray.insert(dataObj, at: 0)
//            self.headActiveVm.updateUI(dict: self.activePlanData)
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
            }
        }
    }
    func sendDelPlanRequest(planDictMsg:NSDictionary,success : @escaping () -> ()) {
        let param = ["pid":"\(planDictMsg.stringValueForKey(key: "pid"))"]
        MCToast.mc_loading()
        WHNetworkUtil.shareManager().POST(urlString: URL_dietplan_del, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
            MCToast.mc_remove()
            if planDictMsg["state"]as? Int ?? 0 == 1{
                //删除激活中的计划，将清空今日往后的日志数据
                LogsSQLiteManager.getInstance().deleteTableData(sDate: Date().nextDay(days: 0))
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
            }
            
            success()
        }
    }
    func sendRenamePlanRequest() {
        if self.dataSourceArray.count <= self.planIndex{
            return
        }
        let dict = self.dataSourceArray[self.planIndex]as? NSDictionary ?? [:]
        let param = ["pid":"\(dict.stringValueForKey(key: "pid"))",
                     "pname":self.planName]
        WHNetworkUtil.shareManager().POST(urlString: URL_dietplan_rename, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
            
            dict.setValue(self.planName, forKey: "pname")
            self.dataSourceArray.replaceObject(at: self.planIndex, with: dict)
//            self.dataSourceArray.removeObject(at: indexPath.row)
//            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [IndexPath(row: self.planIndex, section: 0)], with: .middle)
//            self.tableView.endUpdates()
        }
    }
}
