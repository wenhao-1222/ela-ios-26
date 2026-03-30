//
//  HabitDetailVC.swift
//  lns
//
//  Created by LNS2 on 2025/12/24.
//


class HabitDetailVC: WHBaseViewVC {
    
    var dataSourceArray = NSArray()

//    override var prefersSystemNavigationBarOnIOS26: Bool { true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendDetailRequest()
    }
    
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(10), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight()), style: .plain)
        vi.backgroundColor = .clear
        
        vi.register(HabitDetailTableViewCell.classForCoder(), forCellReuseIdentifier: "HabitDetailTableViewCell")
        vi.separatorStyle = .none
        vi.alpha = 0
        vi.delegate = self
        vi.dataSource = self
        vi.showsVerticalScrollIndicator = false
        vi.contentInset = UIEdgeInsets(top: kFitWidth(10), left: 0, bottom: kFitWidth(16)+getBottomSafeAreaHeight(), right: 0)
        vi.bounces = false
        
        vi.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) { vi.sectionHeaderTopPadding = 0 }
        
        return vi
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.isHidden = true
        vi.alpha = 0
        vi.noDataLabel.text = "- 暂无明细 -"

        return vi
    }()
}

extension HabitDetailVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count//min(2,dataSourceArray.count)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitDetailTableViewCell") as? HabitDetailTableViewCell
        
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == dataSourceArray.count - 1
        cell?.updateUI(dict: dict, isFirst: isFirst, isLast: isLast)
//        cell?.updateUI(dict: dict, isFirst: isFirst, isLast: isLast)
        
        return cell ?? HabitDetailTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(58)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

extension HabitDetailVC{
    func initUI() {
        initNavi(titleStr: "积分明细")
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(tableView)
        view.addSubview(noDataView)
        
        noDataView.center = CGPointMake(SCREEN_WIDHT*0.5, SCREEN_HEIGHT*0.5)
    }
}

extension HabitDetailVC{
    func sendDetailRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_user_habit_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendDetailRequest:\(dataArray)")
            self.dataSourceArray = dataArray
            if self.dataSourceArray.count > 0 {
                self.tableView.reloadData()
                UIView.animate(withDuration: 0.35, delay: 0) {
                    self.tableView.alpha = 1
                }
//                DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
//                    self.tableView.reloadData()
//                })
            }else{
                self.noDataView.isHidden = false
                UIView.animate(withDuration: 0.25, delay: 0) {
                    self.tableView.alpha = 0
                    self.noDataView.alpha = 1
                }completion: { t in
                    self.tableView.isHidden = true
                }
            }
        }
    }
}
