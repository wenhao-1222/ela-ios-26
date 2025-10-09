//
//  LogsMealsAlertSetVC.swift
//  lns
//
//  Created by Elavatine on 2024/10/15.
//

import IQKeyboardManagerSwift

class LogsMealsAlertSetVC: WHBaseViewVC {
    
    var dataSourceArray = NSMutableArray()
    var mandatory = ""
    
    var mealsIndex = -1
    
    override func viewDidAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        IQKeyboardManager.shared.enable = true
//    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshPermissionTip()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mandatory = UserInfoModel.shared.mealsTimeAlertDict.stringValueForKey(key: "mandatory")
        dataSourceArray = NSMutableArray(array: UserInfoModel.shared.mealsTimeAlertDict["alert"]as? NSArray ?? [])
        initUI()
        
        refreshPermissionTip()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { complete, error in
            if complete{
                DLLog(message: "有【通知】权限")
                self.refreshPermissionTip()
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                    self.presentAlertVc(confirmBtn: "设置", message: "开启通知权限后才能正常使用", title: "需要开启通知权限", cancelBtn: "取消", handler: { action in
                        self.openUrl(urlString: UIApplication.openSettingsURLString)
                        
                    },cancelHandler: { cancelAction in
                        
                    }, viewController: self)
                })
            }
        }
    }
    
    lazy var tableView: UITableView = {
//        let vi = UITableView.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(2), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight()-kFitWidth(2)))
        let y = getNavigationBarHeight() + kFitWidth(36) + kFitWidth(2)
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT - y))
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        vi.register(LogsMealsAlertSetTableViewCell.classForCoder(), forCellReuseIdentifier: "LogsMealsAlertSetTableViewCell")
        vi.tableFooterView = self.footVm
        
        return vi
    }()
    lazy var footVm: LogsMealsAlertSetFootVM = {
        let vm = LogsMealsAlertSetFootVM.init(frame: .zero)
        vm.updateUI(mandatory: self.mandatory)
        vm.switchBlock = {(status)in
            self.checkAuthoriStatus(isMandatory: true,status: status)
        }
        return vm
    }()
    lazy var alertSetVm: LogsMealsAlertSetPopVM = {
        let vm = LogsMealsAlertSetPopVM.init(frame: .zero)
        vm.confirmBlock = {(dict)in
            self.checkAuthoriStatus(isMandatory: false,dict: dict)
        }
        return vm
    }()
    lazy var permissionTipView: UIView = {
            let vi = UIView(frame: CGRect(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: kFitWidth(36)))
            vi.backgroundColor = .COLOR_BG_F5
            let lab = UILabel(frame: CGRect(x: kFitWidth(16), y: 0, width: SCREEN_WIDHT - kFitWidth(100), height: kFitWidth(36)))
            lab.text = "请开启通知权限，以确保用餐提醒准时送达"
            lab.textColor = .COLOR_TEXT_TITLE_0f1214
            lab.font = .systemFont(ofSize: 12)
            vi.addSubview(lab)
            let btn = UIButton(frame: CGRect(x: SCREEN_WIDHT - kFitWidth(60), y: 0, width: kFitWidth(60), height: kFitWidth(36)))
            btn.setTitle("去设置", for: .normal)
            btn.setTitleColor(.THEME, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 12)
            btn.addTarget(self, action: #selector(openSettingAction), for: .touchUpInside)
            vi.addSubview(btn)
            vi.isHidden = true
            return vi
        }()
}

extension LogsMealsAlertSetVC{
    func initUI() {
        initNavi(titleStr: "轻断食/用餐提醒")
        view.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        
        view.addSubview(permissionTipView)
        view.addSubview(tableView)
        
        view.addSubview(alertSetVm)
    }
}

extension LogsMealsAlertSetVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count > UserInfoModel.shared.mealsNumber ? UserInfoModel.shared.mealsNumber : dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogsMealsAlertSetTableViewCell", for: indexPath) as? LogsMealsAlertSetTableViewCell
        
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict)
        
        
        cell?.switchBlock = {(status)in
            self.mealsIndex = indexPath.row
//            self.switchBtnAction(status: status)
            self.checkAuthoriStatus(isMandatory: false,status: status)
        }
        
        return cell ?? LogsMealsAlertSetTableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mealsIndex = indexPath.row
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        self.alertSetVm.updateTime(dict: dict, mealsIndex: indexPath.row+1)
//        self.alertSetVm.updateTime(time: dict.stringValueForKey(key: "clock"), mealsIndex: indexPath.row+1)
    }
}

extension LogsMealsAlertSetVC{
    func switchBtnAction(status:Bool) {
        let array = NSMutableArray(array: self.dataSourceArray)
        
        let dict = NSMutableDictionary(dictionary: array[self.mealsIndex]as? NSDictionary ?? [:])
        dict.setValue("\(status ? 1 : 0)", forKey: "status")
        array.replaceObject(at: self.mealsIndex, with: dict)
        self.sendUpdateClockRequest(array: array)
    }
    func checkAuthoriStatus(isMandatory:Bool,status:Bool? = false,dict:NSDictionary? = NSDictionary()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { complete, error in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                if complete{
                    DLLog(message: "有【通知】权限")
                    self.refreshPermissionTip()
                    if isMandatory{//设置强制提醒
                        self.sendUpdateClockRequest(mandatoryTemp: "\(status! ? 1 : 0)")
                    }else{//设置闹钟
                        if dict?.allKeys.count ?? 0 > 0 {
                            let array = NSMutableArray(array: self.dataSourceArray)
                            array.replaceObject(at: self.mealsIndex, with: dict ?? NSDictionary())
                            self.sendUpdateClockRequest(array: array)
                        }else{
                            self.switchBtnAction(status: status!)
                        }
                    }
                }else{
//                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                        self.presentAlertVc(confirmBtn: "设置", message: "“通知”可能包括提醒、声音和图标标记。这些可在“设置”中配置", title: "“Elavatine”想给您发送通知", cancelBtn: "取消", handler: { action in
                            self.openUrl(urlString: UIApplication.openSettingsURLString)
                        },cancelHandler: { cancelAction in
                            
                        }, viewController: self)
//                    })
                }
            })
        }
    }
}

extension LogsMealsAlertSetVC{
    func sendUpdateClockRequest(array:NSArray) {
        let param = ["meal_time_alert":["mandatory":"\(self.mandatory)",
                         "alert":array] as [String : Any]]
        
        DLLog(message: "sendUpdateClockRequest:\(param)")
//        DLLog(message: "\(self.getJSONStringFromDictionary(dictionary: param as NSDictionary))")
        WHNetworkUtil.shareManager().POST(urlString: URL_config_set, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "sendUpdateClockRequest:\(responseObject)")
            
            self.dataSourceArray = NSMutableArray(array: array)
            self.tableView.reloadRows(at: [IndexPath(row: self.mealsIndex, section: 0)], with: .fade)
            
            UserInfoModel.shared.mealsTimeAlertDict = ["mandatory":"\(self.mandatory)",
                                                       "alert":self.dataSourceArray]
            LogsMealsAlertSetManage().refreshClockAlertMsg()
        }
    }
    func sendUpdateClockRequest(mandatoryTemp:String) {
        let param = ["meal_time_alert":["mandatory":"\(mandatoryTemp)",
                                        "alert":self.dataSourceArray] as [String : Any]]
        
        DLLog(message: "sendUpdateClockRequest:\(param)")
//        DLLog(message: "\(self.getJSONStringFromDictionary(dictionary: param as NSDictionary))")
        WHNetworkUtil.shareManager().POST(urlString: URL_config_set, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "sendUpdateClockRequest:\(responseObject)")
            
            self.mandatory = mandatoryTemp
            self.footVm.updateUI(mandatory: self.mandatory)
            UserInfoModel.shared.mealsTimeAlertDict = ["mandatory":"\(self.mandatory)",
                                                       "alert":self.dataSourceArray]
            LogsMealsAlertSetManage().refreshClockAlertMsg()
        }
    }
}

extension LogsMealsAlertSetVC{
    @objc func openSettingAction() {
        self.openUrl(urlString: UIApplication.openSettingsURLString)
    }
    func refreshPermissionTip() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.permissionTipView.isHidden = settings.authorizationStatus == .authorized
                if settings.authorizationStatus == .authorized{
                    self.tableView.frame = CGRect.init(x: 0, y: self.getNavigationBarHeight()+kFitWidth(2), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.getNavigationBarHeight()-kFitWidth(2))
                }
            }
        }
    }
}
