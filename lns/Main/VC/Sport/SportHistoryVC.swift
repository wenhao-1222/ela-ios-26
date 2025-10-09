//
//  SportHistoryVC.swift
//  lns
//
//  Created by Elavatine on 2024/11/25.
//

import MCToast
import HealthKit

class SportHistoryVC: WHBaseViewVC {
    
    var date = Date()
    var dateString = Date().todayDate
    
    var dataSourceArray:[SportHistoryModel] = [SportHistoryModel]()
    var isDisplayArray:[Int] = [Int]()
    var editModel = SportHistoryModel()
    
    var isCanAdd = false
    var parentVc = WHBaseViewVC()
    var addBlock:(()->())?
    
    override func viewWillAppear(_ animated: Bool) {
        if UserInfoModel.shared.statSportDataFromHealth == "0"{
            tableView.tableHeaderView = settingHeadView
        }else{
            tableView.tableHeaderView = nil
        }
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        NotificationCenter.default.removeObserver(self)
//    }
//    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendSportListRequest()
    }
    
    lazy var timeButton : GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: kFitWidth(80), y: statusBarHeight, width: kFitWidth(215), height: kFitWidth(44)))
        
        btn.setTitleColor(WHColor_16(colorStr: "222222"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        
        btn.addTarget(self, action: #selector(timeTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var addButton : UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.setBackgroundImage(UIImage.init(named: "main_add_data_button"), for: .normal)
//        btn.addTarget(self, action: #selector(selfTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var addTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(addAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight()), style: .plain)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .white
        table.register(SportHistoryTableViewCell.classForCoder(), forCellReuseIdentifier: "SportHistoryTableViewCell")
        table.separatorStyle = .none
        
        if UserInfoModel.shared.statSportDataFromHealth == "0"{
            table.tableHeaderView = settingHeadView
        }
        
        return table
    }()
    lazy var settingHeadView: SportHistorySynSettingVM = {
        let vi = SportHistorySynSettingVM.init(frame: .zero)
        vi.settinBtn.addTarget(self, action: #selector(authoriHealthAction), for: .touchUpInside)
        
        return vi
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.noDataLabel.text = "- 暂无运动数据 -"
        vi.isHidden = true
        return vi
    }()
    lazy var dateFilterAlertVm : DataAddDateAlertVM = {
        let vm = DataAddDateAlertVM.init(frame: .zero)
        vm.datePicker.maximumDate = Date().getLastYearsAgo(lastYears: 3)
        vm.setDate(dateString: self.dateString)
        
        vm.confirmBlock = {(weekDay)in
            self.setTime(time: weekDay)
            self.sendSportListRequest()
        }
        return vm
    }()
    lazy var addAlertVm: SportAddAlertVM = {
        let vm = SportAddAlertVM.init(frame: .zero)
        vm.titleLab.text = "修改运动"
        vm.confirmBlock = {()in
            self.sendUpdateSportRequest()
        }
        return vm
    }()
    lazy var updateHealthDataAlertVm: SportHealthDataUpdateAlertVM = {
        let vm = SportHealthDataUpdateAlertVM.init(frame: .zero)
        vm.tipsTapBlock = {(sportNum)in
            self.exampleAlertVm.showView(sportNum: sportNum)
        }
        vm.confirmBlock = {()in
            self.sendUpdateHealthSportRequest(isSyn: self.updateHealthDataAlertVm.isSyn)
        }
        return vm
    }()
    lazy var exampleAlertVm: SportHealthDataExampleAlertVM = {
        let vm = SportHealthDataExampleAlertVM.init(frame: .zero)
        return vm
    }()
}

extension SportHistoryVC{
    @objc func timeTapAction() {
        self.dateFilterAlertVm.showView()
    }
    @objc func addAction() {
        TouchGenerator.shared.touchGeneratorMedium()
        let vc = SportVC()
        vc.isCanAdd = true
//        vc.sendCatogaryListRequest()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func setTime(time:String) {
        timeButton.setTitle("\(time)", for: .normal)
        timeButton.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        timeButton.imagePosition(style: .right, spacing: kFitWidth(5))
    }
}

extension SportHistoryVC{
    func initUI() {
        view.backgroundColor = .white
        view.addSubview(backArrowButton)
        view.addSubview(timeButton)
        view.addSubview(tableView)
        
        tableView.addSubview(noDataView)
        noDataView.center = CGPoint.init(x: self.tableView.frame.width * 0.5, y: kFitWidth(150))
        
        view.addSubview(dateFilterAlertVm)
        view.addSubview(addAlertVm)
        view.addSubview(updateHealthDataAlertVm)
        view.addSubview(exampleAlertVm)
        
        setTime(time: dateFilterAlertVm.weekDay)
        
        if isCanAdd{
            view.addSubview(addButton)
            view.addSubview(addTapView)
            
            setConstrait()
        }
    }
    func setConstrait() {
        addButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
//            make.top.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(24))
            make.centerY.lessThanOrEqualTo(statusBarHeight+kFitWidth(22))
        }
        addTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(addButton)
            make.width.height.equalTo(kFitWidth(50))
        }
    }
    @objc func authoriHealthAction() {
        let vc = JournalSettingVC()
        self.navigationController?.pushViewController(vc, animated: true)
//        let healthStore = HKHealthStore()
//        let healthKitTypesToRead = HKObjectType.workoutType()
//        healthStore.requestAuthorization(toShare: [healthKitTypesToRead], read: [healthKitTypesToRead]) { success, error in
////            completion(success, error)
//            DLLog(message: "\(success) -- \(error)")
//        }
    }
}

extension SportHistoryVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noDataView.isHidden = dataSourceArray.count > 0 ? true : false
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var cellFrameStart = cell.contentView.frame
        let isDisplay = self.isDisplayArray[indexPath.row]
        if isDisplay == 1 {
            return
        }
        cellFrameStart.origin.x = cellFrameStart.size.width
        cell.contentView.frame = cellFrameStart
        
        let time = Float(indexPath.row) * 0.05
        UIView.animate(withDuration: 0.3, delay: TimeInterval(time),options: .curveEaseInOut) {
            var cellFrameEnd = cell.contentView.frame
            cellFrameEnd.origin.x = 0
            cell.contentView.frame = cellFrameEnd
        }
        self.isDisplayArray[indexPath.row] = 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SportHistoryTableViewCell") as? SportHistoryTableViewCell
        
        let model = self.dataSourceArray[indexPath.row]
        cell?.updateUI(model: model)
        
//        var cellFrameStart = cell?.contentView.frame
//        let isDisplay = self.isDisplayArray[indexPath.row]
//        if isDisplay == 0 {
//            cellFrameStart?.origin.x = SCREEN_WIDHT
//            cell?.contentView.frame = cellFrameStart ?? CGRect()
//            
//            let time = Float(indexPath.row) * 0.05
//            UIView.animate(withDuration: 0.3, delay: TimeInterval(time),options: .curveEaseInOut) {
//                var cellFrameEnd = cell?.contentView.frame
//                cellFrameEnd?.origin.x = 0
//                cell?.contentView.frame = cellFrameEnd ?? CGRect()
//            }
//            self.isDisplayArray[indexPath.row] = 1
//        }
        
        return cell ?? SportHistoryTableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.editModel = self.dataSourceArray[indexPath.row]
        self.judgeSport(sModel: self.editModel)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(56)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        self.editModel = self.dataSourceArray[indexPath.row]
        let editAction  = UIContextualAction.init(style: .normal, title: "修改运动") { _,_,_ in
            self.tableView.setEditing(false, animated: true)
            self.judgeSport(sModel: self.editModel)
        }
        let deleteAction  = UIContextualAction.init(style: .destructive, title: "删除") { _,_,_ in
            self.sendDelSportRequest(model: self.editModel) {
                if self.editModel.sdate == Date().todayDate{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
                }
                self.dataSourceArray.remove(at: indexPath.row)
                self.isDisplayArray.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.sendSportListRequest()
                
                if self.editModel.source == "2"{
                    UserDefaults.deleteSportUUID(uuid: self.editModel.sportItemId)
                }
//                var prancerciseWorkout = PrancerciseWorkout(calories: "\(self.editModel.calories)")
//                prancerciseWorkout.duration = "\(self.editModel.duration)"
//                prancerciseWorkout.end = Date().changeDateStringToDate(dateString: "\(self.editModel.ctime)".replacingOccurrences(of: "T", with: " "),
//                                                                       formatter: "yyyy-MM-dd HH:mm:ss")
//                prancerciseWorkout.getStartDate()
//                let healthManager = HealthKitManager()
//                healthManager.deleteRunningDataForHealthKitApp(workoutType: .other, prancerciseWorkout: prancerciseWorkout)
            }
        }
        editAction.backgroundColor = .COLOR_BUTTON_HIGHLIGHT_BG_THEME
        var actions = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        if self.editModel.source == "2"{
            actions = UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        actions.performsFirstActionWithFullSwipe = false
        
        return actions
    }
    func judgeSport(sModel:SportHistoryModel) {
        if sModel.source == "2"{
            MCToast.mc_text("\(sModel.name) 数据从“健康”APP获取\n不支持修改。")
//            self.updateHealthDataAlertVm.updateUIForHistort(sModel: sModel)
//            self.updateHealthDataAlertVm.showSelf()
            return
        }
        if sModel.met.count == 0 && sModel.caloriesUser.count == 0 && sModel.durationUser.count == 0{
            MCToast.mc_text("\(sModel.name) 已删除，不能修改历史数据。")
            return
        }
        self.addAlertVm.updateUIForHistort(sModel: self.editModel)
        self.addAlertVm.showSelf()
    }
}

extension SportHistoryVC{
    func sendSportListRequest(animation:UITableView.RowAnimation? = UITableView.RowAnimation.none) {
        let param = ["sdate":"\(self.dateFilterAlertVm.dateStringYear)"]
        DLLog(message: "sendSportListRequest param:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_sport_list, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = self.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendSportListRequest:\(dataArray)")
            
            self.dataSourceArray.removeAll()
            self.isDisplayArray.removeAll()
            
            let maxNumberPerScreen = Int((SCREEN_HEIGHT-self.getNavigationBarHeight())/kFitWidth(56)+1)
            
            for i in 0..<dataArray.count{
                let model = SportHistoryModel().dealDict(dict: dataArray[i]as? NSDictionary ?? [:])
                self.dataSourceArray.append(model)
                if i < maxNumberPerScreen && animation != UITableView.RowAnimation.none{
                    self.isDisplayArray.append(0)
                }else{
                    self.isDisplayArray.append(1)
                }
            }
            if animation == UITableView.RowAnimation.none{
                self.tableView.reloadData()
            }else{
                self.tableView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: false)
                self.tableView.reloadData()
//                self.tableView.reloadSections(IndexSet(integer: 0), with: animation ?? UITableView.RowAnimation.none)
            }
            
            SportDataSQLiteManager.getInstance().updateSportsData(ctime: self.dateFilterAlertVm.dateStringYear, sportsData: self.getJSONStringFromArray(array: dataArray))
        }
    }
    func sendDelSportRequest(model:SportHistoryModel,success : @escaping () -> ()) {
        let param = ["id":"\(model.id)"]
//        MCToast.mc_loading()
        WHNetworkUtil.shareManager().POST(urlString: URL_sport_delete, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: "\(responseObject)")
            MCToast.mc_remove()
            WidgetUtils().reloadWidgetData()
            success()
        }
    }
    func sendUpdateSportRequest() {
        let param = ["id":"\(self.editModel.id)",
                     "duration":"\(self.addAlertVm.minute)".replacingOccurrences(of: ",", with: "."),
                     "weight":"\(self.addAlertVm.weight)".replacingOccurrences(of: ",", with: "."),
//                     "sportCaloriesInTarget":UserInfoModel.shared.statSportDataToTarget,
                     "calories":WHUtils.convertStringToString("\(self.addAlertVm.calories)".replacingOccurrences(of: ",", with: "."))]
        DLLog(message: "sendAddSportRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_sport_update, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "sendAddSportRequest:\(responseObject)")
            if self.editModel.sdate == Date().todayDate{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
            }
            WidgetUtils().reloadWidgetData()
            self.sendSportListRequest(animation: .middle)
//            MCToast.mc_text("运动数据已修改！",respond: .allow)
        }
    }
    func sendUpdateHealthSportRequest(isSyn:Bool) {
        let param = ["id":"\(self.editModel.id)",
                     "sportCaloriesInTarget":"\(isSyn ? 1 : 0)"]
        DLLog(message: "sendAddSportRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_sport_update, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "sendAddSportRequest:\(responseObject)")
            if self.editModel.sdate == Date().todayDate{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
            }
            WidgetUtils().reloadWidgetData()
            self.sendSportListRequest(animation: .middle)
//            MCToast.mc_text("运动数据已修改！",respond: .allow)
        }
    }
}
