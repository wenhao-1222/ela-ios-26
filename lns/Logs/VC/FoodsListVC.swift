//
//  FoodsListVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import MCToast
import MJRefresh

class FoodsListVC: WHBaseViewVC {
    
    var foodsArray = NSMutableArray()
    var myFoodsArray = NSArray()
    var uid = ""
    var isFromPlan = false
    var isFromMain = false
    var sourceType = ADD_FOODS_SOURCE.other
//    var oneSectionLabel = ""
    
    var isFirstLoad = true
    
    override func viewDidAppear(_ animated: Bool) {
        UserInfoModel.shared.currentVcName = "FoodsListVC"
        if self.historyFoodsVm.foodsArray.count == 0 && isFirstLoad == true{
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.naviVm.textField.becomeFirstResponder()
            })
            isFirstLoad = false
        }
        
        self.naviVm.textField.startCountdown()
    }
    override func viewDidDisappear(_ animated: Bool) {
        UserInfoModel.shared.currentVcName = ""
        self.naviVm.textField.disableTimer()
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        UserInfoModel.shared.currentVcName = ""
//        self.naviVm.textField.disableTimer()
//    }
//    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        myFoodsArray = UserDefaults.getMyFoods()
        NotificationCenter.default.addObserver(self, selector: #selector(createFoodsNotifi), name: NSNotification.Name(rawValue: "createFoodsSuccess"), object: nil)
        
    }
    lazy var naviVm : FoodsSearchVM = {
        let vm = FoodsSearchVM.init(frame: .zero)
        vm.backArrowButton.addTarget(self, action: #selector(backTapAction), for: .touchUpInside)
        
        vm.searchBlock = {()in
            let searchString = self.naviVm.textField.text?.replacingOccurrences(of: " ", with: "")
            if searchString == "" && self.topTypeVM.foodsType == "all"{
                self.naviVm.textField.text = ""
                self.historyFoodsVm.isHidden = false
                self.foodsArray.removeAllObjects()
                self.tableView.reloadData()
                self.tableView.isHidden = true
                self.moveHistory(isTop: false)
            }else{
                if self.topTypeVM.foodsType == "all"{
                    self.sendFoodsListRequest()
                }else{
                    if self.myFoodsArray.count > 0 {
                        self.searchMyFoodsList()
                    }else{
                        self.sendMyFoodsRequest()
                    }
                }
                self.historyFoodsVm.isHidden = true
                self.tableView.isHidden = false
            }
        }
        vm.searchHistoryBlock = {()in
            self.moveHistory(isTop: true)
        }
        return vm
    }()
    lazy var topTypeVM : FoodsListTypeVM = {
        let vm = FoodsListTypeVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.allFoodsTapBlock = {()in
            self.uid = ""
            self.foodsArray.removeAllObjects()
            self.tableView.reloadData()
            self.naviVm.textField.resignFirstResponder()
            if self.naviVm.textField.text == "" {
                self.historyFoodsVm.isHidden = false
                self.tableView.isHidden = true
            }else{
                self.historyFoodsVm.isHidden = true
                self.sendFoodsListRequest()
                self.tableView.isHidden = false
            }
        }
        vm.myFoodsTapBlock = {()in
//            self.naviVm.textField.text = ""
            self.naviVm.textField.resignFirstResponder()
            self.historyFoodsVm.isHidden = true
            self.foodsArray.removeAllObjects()
            self.tableView.isHidden = false
            self.tableView.reloadData()
            
            if self.naviVm.textField.text?.count ?? 0 > 0{
                self.uid = "\(UserInfoModel.shared.uId)"
                self.sendMyFoodsRequest()
                return
            }
            
            if self.myFoodsArray.count > 0 {
//                self.searchMyFoodsList()
                self.foodsArray = NSMutableArray(array: self.myFoodsArray)
                self.tableView.reloadData()
                self.tableView.tableFooterView = self.footerVm
                return
            }
            
            self.uid = "\(UserInfoModel.shared.uId)"
            self.sendMyFoodsRequest()
        }
        return vm
    }()
    lazy var createVm: FoodsListAddVM = {
        let vm = FoodsListAddVM.init(frame: CGRect.init(x: 0, y: self.topTypeVM.frame.maxY, width: 0, height: 0))
        vm.createFoodsButton.addTarget(self, action: #selector(createFoodsActino), for: .touchUpInside)
        vm.createFoodsSoonButton.addTarget(self, action: #selector(createFoodsFastAction), for: .touchUpInside)
        return vm
    }()
    lazy var historyFoodsVm: FoodsListAddListVM = {
        let vm = FoodsListAddListVM.init(frame: CGRect.init(x: 0, y: self.createVm.frame.maxY, width: 0, height: 0))
        vm.isFromPlan = self.isFromPlan
        vm.controller = self
//        vm.canAdd = !self.isFromMain
        vm.sourceType = self.sourceType
        vm.scrollBlock = {()in
            self.naviVm.textField.resignFirstResponder()
        }
        return vm
    }()
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: self.historyFoodsVm.frame, style: .plain)
        table.separatorStyle = .none
        table.isHidden = true
        table.backgroundColor = .white
        table.delegate = self
        table.dataSource = self
        table.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        table.register(FoodsListAddTableViewCell.classForCoder(), forCellReuseIdentifier: "FoodsListAddTableViewCell")
        table.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        
        return table
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.isHidden = true
        return vi
    }()
    lazy var footerVm: FoodsListFooterVM = {
        let vm = FoodsListFooterVM.init(frame: .zero)
        return vm
    }()
}

extension FoodsListVC{
    @objc func createFoodsActino() {
        self.naviVm.textField.resignFirstResponder()
        let vc = FoodsCreateVC()
        self.navigationController?.pushViewController(vc, animated: true)
        vc.addBlock = {()in
            self.view.becomeFirstResponder()
            self.topTypeVM.myFoodsTapAction()
        }
    }
    @objc func createFoodsFastAction(){
        self.naviVm.textField.resignFirstResponder()
        let vc = FoodsCreateFastVC()
        vc.isFromPlan = self.isFromPlan
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func createFoodsNotifi(){
        myFoodsArray = UserDefaults.getMyFoods()
        if self.topTypeVM.foodsType == "my"{
            foodsArray = NSMutableArray.init(array: myFoodsArray)
            tableView.reloadData()
            
            if self.foodsArray.count > 0{
                self.tableView.tableFooterView = self.footerVm
            }else{
                self.tableView.tableFooterView = nil
            }
        }
    }
    func searchMyFoodsList() {
        let fname = self.naviVm.textField.text ?? ""
        foodsArray.removeAllObjects()
        if fname == ""{
            foodsArray = NSMutableArray.init(array: myFoodsArray)
        }else{
            for i in 0..<myFoodsArray.count{
                let foodsDict = myFoodsArray[i]as? NSDictionary ?? [:]
                if (foodsDict["fname"]as? String ?? "").contains("\(fname)"){
                    foodsArray.add(foodsDict)
                }
            }
        }
        self.tableView.reloadData()
    }
    func moveHistory(isTop:Bool) {
        UIView.animate(withDuration: 0.3) {
            if isTop{
                self.historyFoodsVm.frame = CGRect.init(x: 0, y: self.topTypeVM.frame.maxY+kFitWidth(2), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.topTypeVM.frame.maxY-kFitWidth(2))
                self.historyFoodsVm.tableView.frame = CGRect.init(x: 0, y: kFitWidth(44), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.topTypeVM.frame.maxY-kFitWidth(44))
            }else{
                self.historyFoodsVm.frame = CGRect.init(x: 0, y: self.createVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.createVm.frame.maxY)
                self.historyFoodsVm.tableView.frame = CGRect.init(x: 0, y: kFitWidth(44), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.createVm.frame.maxY-kFitWidth(44))
            }
        }
    }
}

extension FoodsListVC{
    func initUI() {
        view.addSubview(naviVm)
        view.addSubview(topTypeVM)
        view.addSubview(createVm)
        view.addSubview(historyFoodsVm)
        view.addSubview(tableView)
        
        tableView.addSubview(noDataView)
        noDataView.center = CGPoint.init(x: self.tableView.frame.width * 0.5, y: kFitWidth(134))
    }
}

extension FoodsListVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        noDataView.isHidden = foodsArray.count > 0 ? true : false
        if topTypeVM.foodsType == "my"{
            footerVm.isHidden = foodsArray.count > 0 ? false : true
            return 1
        }
        
        return foodsArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if topTypeVM.foodsType == "my"{
//            footerVm.isHidden = foodsArray.count > 0 ? false : true
            return self.foodsArray.count
        }
        let dict = self.foodsArray[section]as? NSDictionary ?? [:]
        let array = dict["foodsArray"]as? NSArray ?? []
        return array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodsListAddTableViewCell") as? FoodsListAddTableViewCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodsListAddTableViewCell", for: indexPath) as? FoodsListAddTableViewCell
        
        if topTypeVM.foodsType == "my"{
            let dict = self.foodsArray[indexPath.row]as? NSDictionary ?? [:]
            cell?.updateUI(dict: dict)
        }else{
            let dict = self.foodsArray[indexPath.section]as? NSDictionary ?? [:]
            let array = dict["foodsArray"]as? NSArray ?? []
            
//            let array = self.foodsArray[indexPath.section]as? NSArray ?? []
            let foodsDict = array[indexPath.row]as? NSDictionary ?? [:]
            cell?.updateUI(dict: foodsDict)
        }
        
        return cell ?? FoodsListAddTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(72)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.naviVm.textField.resignFirstResponder()
        if topTypeVM.foodsType == "my" {
            let dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
            
            let vc = FoodsMsgDetailsVC()
            vc.foodsDetailDict = dict
            vc.sourceType = self.sourceType
            self.navigationController?.pushViewController(vc, animated:true)
            
            if self.isFromMain == true {
                vc.confirmButton.isHidden = true
            }
        }else{
            let dict = self.foodsArray[indexPath.section]as? NSDictionary ?? [:]
            let array = dict["foodsArray"]as? NSArray ?? []
            
//            let array = self.foodsArray[indexPath.section]as? NSArray ?? []
            let foodsDict = array[indexPath.row]as? NSDictionary ?? [:]
            
            let vc = FoodsMsgDetailsVC()
            vc.foodsDetailDict = foodsDict
            vc.sourceType = self.sourceType
            self.navigationController?.pushViewController(vc, animated:true)
            if self.isFromMain == true {
                vc.confirmButton.isHidden = true
            }
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
//            let array = self.foodsArray[indexPath.section]as? NSArray ?? []
            let dict = self.foodsArray[indexPath.row]as? NSDictionary ?? [:]
            self.presentAlertVc(confirmBtn: "删除", message: "是否删除食物“\(dict["fname"]as? String ?? "")”", title: "温馨提示", cancelBtn: "取消", handler: { action in
                self.sendDeleteFoodsRequest(fid: "\(Int(dict["fid"]as? String ?? "-1") ?? -1)",indexPath:indexPath,foodsMsg: dict)
            }, viewController: self)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return topTypeVM.foodsType == "all" ? false : true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if foodsArray.count < 2 || topTypeVM.foodsType == "my"{
            return nil
        }
        let headView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(55)))
        headView.backgroundColor = .white
        
        let grayView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(55)))
        headView.addSubview(grayView)
        grayView.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        
        let label = UILabel.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: kFitWidth(200), height: kFitWidth(55)))
        label.textColor = .COLOR_GRAY_BLACK_85
        label.font = .systemFont(ofSize: 16, weight: .medium)
        
        let dict = self.foodsArray[section]as? NSDictionary ?? [:]
        label.text = dict["title"]as? String ?? ""
        
        headView.addSubview(label)
        return headView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if foodsArray.count < 2  || topTypeVM.foodsType == "my"{
            return kFitWidth(0)
        }
        return kFitWidth(55)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.naviVm.textField.resignFirstResponder()
    }
}

extension FoodsListVC{
    func sendFoodsListRequest() {
        
        let param = ["fname":naviVm.textField.text ?? "",
                     "uid":"\(self.uid)",
                     "ftype":""]
        UserInfoModel.shared.postNum = 3
        UserInfoModel.shared.failToastNum = 0
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_list, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
//            let dataArr = responseObject["data"]as? NSDictionary ?? [:]
            
            let bestArray = dataArr["best"]as? NSArray ?? []
            let moreArray = dataArr["more"]as? NSArray ?? []
            
            self.foodsArray.removeAllObjects()
            if bestArray.count > 0 {
                self.foodsArray.add(["title":"精准搜索",
                                     "foodsArray":bestArray])
            }
            if moreArray.count > 0 {
                self.foodsArray.add(["title":"更多食物",
                                     "foodsArray":moreArray])
            }
            self.tableView.reloadData()
            if self.foodsArray.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
            }
            
            if self.foodsArray.count > 0{
                self.tableView.tableFooterView = self.footerVm
            }else{
                self.tableView.tableFooterView = nil
            }
        }
    }
    @objc func sendMyFoodsRequest() {
        let param = ["fname":naviVm.textField.text ?? ""]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_list_my, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
//            
//            let dataArr = responseObject["data"]as? NSArray ?? []
            UserDefaults.set(value: self.getJSONStringFromArray(array: dataArr), forKey: .myFoodsList)
            self.myFoodsArray = dataArr
            self.foodsArray.removeAllObjects()
//            if self.topTypeVM.foodsType == "my"{
            self.foodsArray = NSMutableArray.init(array: dataArr)
            self.tableView.reloadData()
            
            if self.foodsArray.count > 0{
                self.tableView.tableFooterView = self.footerVm
            }else{
                self.tableView.tableFooterView = nil
            }
//            }
        }
    }
    func sendDeleteFoodsRequest(fid:String,indexPath:IndexPath,foodsMsg:NSDictionary) {
        let param = ["fname":"\(foodsMsg.stringValueForKey(key: "fname"))"]
        
        myFoodsArray = UserDefaults.getMyFoods()
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_delete, parameters: param as [String:AnyObject]) { responseObject in
            UserDefaults.delFoods(foodsDict: foodsMsg, forKey: .myFoodsList)
            self.historyFoodsVm.deleteFoods(foodsMsg: foodsMsg)
            
            self.foodsArray.removeObject(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
