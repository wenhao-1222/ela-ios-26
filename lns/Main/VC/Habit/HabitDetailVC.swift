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
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(20), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight()-getBottomSafeAreaHeight()-kFitWidth(30)), style: .grouped)
        vi.backgroundColor = .clear
        
        vi.register(HabitDetailTableViewCell.classForCoder(), forCellReuseIdentifier: "HabitDetailTableViewCell")
        vi.separatorStyle = .none
        
        vi.delegate = self
        vi.dataSource = self
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
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitDetailTableViewCell") as? HabitDetailTableViewCell
        
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict)
        
        return cell ?? HabitDetailTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(54)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(16)))
        headView.backgroundColor = .COLOR_BG_F2
        
        let whiteView = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(16)))
        whiteView.backgroundColor = .COLOR_CARD_BG_WHITE
        whiteView.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(12))
        
        headView.addSubview(whiteView)
        
        return headView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFitWidth(16)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(16)))
        headView.backgroundColor = .COLOR_BG_F2
        
        let whiteView = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(-2), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(18)))
        whiteView.backgroundColor = .COLOR_CARD_BG_WHITE
        whiteView.addClipCorner(corners: [.bottomLeft,.bottomRight], radius: kFitWidth(12))
        
        headView.addSubview(whiteView)
        
        return headView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return kFitWidth(16)
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
