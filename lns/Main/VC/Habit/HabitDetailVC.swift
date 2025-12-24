//
//  HabitDetailVC.swift
//  lns
//
//  Created by LNS2 on 2025/12/24.
//


class HabitDetailVC: WHBaseViewVC {
    
    var dataSourceArray = NSArray()
    
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
        
        let whiteView = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(16)))
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
    }
}

extension HabitDetailVC{
    func sendDetailRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_user_habit_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendDetailRequest:\(dataArray)")
            self.dataSourceArray = dataArray
            self.tableView.reloadData()
        }
    }
}
