//
//  HabitRankListVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/30.
//


class HabitRankListVM: UIView {
    
    var selfHeight = kFitWidth(600)
    var controller = WHBaseViewVC()
    
    var dataSourceArray = NSArray()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        initUI()
        sendDataRequest()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var tableView: UITableView = {
        let vi = UITableView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight), style: .plain)
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.tableHeaderView = headVm
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.register(HabitRankTableViewCell.classForCoder(), forCellReuseIdentifier: HabitRankTableViewCell.identifier)
        
        return vi
    }()
    lazy var emptyVm: HabitRankListEmptyVM = {
        let vm = HabitRankListEmptyVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        return vm
    }()
    lazy var headVm: HabitRankListHeadVM = {
        let vm = HabitRankListHeadVM.init(frame: .zero)
        return vm
    }()
}

extension HabitRankListVM{
    func updateUI(dict:NSDictionary) {
        
    }
}

extension HabitRankListVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptyVm.isHidden = dataSourceArray.count > 0
        headVm.isHidden = dataSourceArray.count == 0
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                withIdentifier: HabitRankTableViewCell.identifier,
                for: indexPath
            ) as! HabitRankTableViewCell

        let dict = dataSourceArray[indexPath.row] as? NSDictionary ?? [:]
        
        cell.configure(
            rank: dict.stringValueForKey(key: "sn"),
            avatar: dict.stringValueForKey(key: "headimgurl"),
            name: dict.stringValueForKey(key: "nickname"),
            fireCount: dict.stringValueForKey(key: "donateCount").intValue,
            score: dict.stringValueForKey(key: "pointBalance")
        )
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(70)
    }
}

extension HabitRankListVM{
    func initUI() {
        addSubview(tableView)
        tableView.addSubview(emptyVm)
    }
}

extension HabitRankListVM{
    func sendDataRequest(){
        WHNetworkUtil.shareManager().POST(urlString: URL_user_habit_leaderboard, parameters: nil,isNeedToast: true,vc: self.controller) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendDataRequest:\(dataDict)")
            
            self.dataSourceArray = dataDict["leaderboard"]as? NSArray ?? []
            let weeklyRewardPoint = dataDict["weeklyRewardPoint"]as? NSDictionary ?? [:]
            
            self.headVm.updateUI(champion: weeklyRewardPoint.stringValueForKey(key: "champion"),
                            runnerUp: weeklyRewardPoint.stringValueForKey(key: "runnerUp"),
                            thirdPlace: weeklyRewardPoint.stringValueForKey(key: "thirdPlace"))
            
            self.tableView.reloadData()
        }
    }
}
