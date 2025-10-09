//
//  PlanListSearchVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/11.
//

import Foundation
import MCToast

class PlanListSearchVC: WHBaseViewVC {
    
    var keyWords = ""
    var dataSourceArray = NSMutableArray()
    
    override func viewDidAppear(_ animated: Bool) {
        self.searchVm.textField.startCountdown()
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.searchVm.textField.disableTimer()
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        self.searchVm.textField.disableTimer()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendSearchPlanListRequest()
        sendGetActivePlanRequest()
    }
    lazy var searchVm : PlanSearchVM = {
        let vm = PlanSearchVM.init(frame: .zero)
        vm.textField.text = self.keyWords
        vm.backBlock = {()in
            self.backTapAction()
        }
        vm.searchBlock = {()in
            self.keyWords = self.searchVm.textField.text ?? ""
            self.dataSourceArray.removeAllObjects()
            self.sendSearchPlanListRequest()
            self.sendGetActivePlanRequest()
        }
        return vm
    }()
    lazy var tableView : UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: self.searchVm.frame.maxY+kFitWidth(8), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.searchVm.frame.maxY), style: .plain)
        vi.backgroundColor = .white
        vi.register(PlanListTableViewCell.classForCoder(), forCellReuseIdentifier: "PlanListTableViewCell")
        vi.delegate = self
        vi.dataSource = self
        
        return vi
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.isHidden = true
        return vi
    }()
}

extension PlanListSearchVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noDataView.isHidden = dataSourceArray.count > 0 ? true : false
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanListTableViewCell") as? PlanListTableViewCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanListTableViewCell", for: indexPath) as! PlanListTableViewCell
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict)
        return cell ?? PlanListTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? kFitWidth(92) : kFitWidth(112)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        
        let vc = PlanDetailVC()
        vc.planDictMsg = dict
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension PlanListSearchVC{
    func initUI() {
        view.addSubview(searchVm)
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.addSubview(noDataView)
    }
}

extension PlanListSearchVC{
    func sendSearchPlanListRequest() {
        MCToast.mc_loading()
        let param = ["uid":"\(UserInfoModel.shared.uId)",
                     "pname":"\(self.keyWords)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_dietplan_list, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            self.dataSourceArray.addObjects(from: dataObj as! [Any])
            self.tableView.reloadData()
        }
    }
    func sendGetActivePlanRequest() {
        let param = ["uid":"\(UserInfoModel.shared.uId)",
                     "pname":"\(self.keyWords)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_dietplan_plan_active, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            if dataObj.stringValueForKey(key: "pname").contains(self.keyWords){
                self.dataSourceArray.insert(dataObj, at: 0)
                self.tableView.reloadData()
            }
        }
    }
}
