//
//  FriendRankingWeekListVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/4.
//


class FriendRankingWeekListVM: UIView {
    
    var selfHeight = kFitWidth(36)
    var dataSourceArray = NSMutableArray()
    var controller = WHBaseViewVC()
    private var currentPopup: ActionPopupController?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .COLOR_BG_WHITE
        selfHeight = SCREEN_HEIGHT-frame.origin.y
        self.isUserInteractionEnabled = true
        
        initUI()
//        DispatchQueue.main.asyncAfter(deadline: .now()+5, execute: {
            self.sendWeekRankingListRequest()
//        })
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight), style: .plain)
        vi.delegate = self
        vi.dataSource = self
//        vi.bounces = false
        vi.backgroundColor = .COLOR_BG_WHITE//.COLOR_BG_F5
        vi.separatorStyle = .none
//        vi.tableFooterView = footerVm
        vi.register(FriendRankingWeekTableViewCell.classForCoder(), forCellReuseIdentifier: "FriendRankingWeekTableViewCell")
        
        return vi
    }()
//    lazy var footerVm: FriendRankingDailyFootVM = {
//        let vm = FriendRankingDailyFootVM.init(frame: .zero)
//        return vm
//    }()
    lazy var nodataVm: TableViewNoDataVM = {
        let vm = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0 ))
        vm.noDataLabel.text = "暂无周榜 — 每周记录满4天，即可生成周榜"
        vm.noDataLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        return vm
    }()
}

extension FriendRankingWeekListVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nodataVm.isHidden = dataSourceArray.count > 0 ? true : false
        if dataSourceArray.count == 0 {
            nodataVm.noDataLabel.text = nil
            nodataVm.noDataLabel.showSkeleton(SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                                             highlightColorLight: .COLOR_GRAY_E2,
                                                             cornerRadius: kFitWidth(4),
                                                             shimmerWidth: 0.22,
                                                             shimmerDuration: 1.15))
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.25, execute: {
                self.nodataVm.noDataLabel.text = "暂无周榜 — 每周记录满4天，即可生成周榜"
                [self.nodataVm,self.nodataVm.noDataLabel].forEach { $0.hideSkeletonWithCrossfade() }
            })
        }
        
        return self.dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRankingWeekTableViewCell")as? FriendRankingWeekTableViewCell
        
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict, index: indexPath.row)
        
        cell?.editBlock = { [weak self, weak cell] view in
            if dict.stringValueForKey(key: "uid") != UserInfoModel.shared.uId{
                guard let self = self else { return }
                // Dismiss an existing popup to avoid showing multiple delete options
                self.currentPopup?.dismissPopup()
                let container = self.controller.view
                let rect = view.convert(view.bounds, to: container)
                let tapLocation = CGPoint(x: rect.midX, y: rect.maxY)
                let actions = [
                    ("删除", {
                        self.currentPopup?.dismissPopup()
                        self.controller.presentAlertVc(confirmBtn: "否", message: "", title: "是否删除好友？", cancelBtn: "是", textAlignLeft: false, handler: { action in
                            
                        }, cancelHandler: { cancelAction in
                            self.sendDeleteFriendRequest(dict: dict, indexPath: indexPath)
                        }, viewController: self.controller)
                    })
                ]
                
                let popup = ActionPopupController(anchor: tapLocation, in: container!, actions: actions)
                
                popup.onDismiss { [weak self] in
                    print("已关闭")
                    self?.currentPopup = nil
                }
                self.currentPopup = popup
            }
        }
        cell?.showWeeklyBlock = {()in
            if dict.stringValueForKey(key: "uid") != UserInfoModel.shared.uId{
                let vc = JournalFriendReportVC()
                vc.followerNickName = dict.stringValueForKey(key: "nickname")
                vc.followerAvatar = dict.stringValueForKey(key: "headimgurl")
                vc.followerUid = dict.stringValueForKey(key: "uid")
                self.controller.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        return cell ?? FriendRankingDailyTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(159)
    }
}

extension FriendRankingWeekListVM{
    func initUI() {
        addSubview(tableView)
        
        tableView.addSubview(nodataVm)
        nodataVm.center = CGPoint.init(x: self.tableView.frame.width * 0.5, y: kFitWidth(40))
        
        initSkeletonData()
    }
    func initSkeletonData() {
        dataSourceArray.removeAllObjects()
        for _ in 0..<3 {
            dataSourceArray.add([:])
        }
        tableView.reloadData()
    }
}

extension FriendRankingWeekListVM{
    func sendWeekRankingListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_report_weekly_ranking, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendWeekRankingListRequest:\(dataArray)")
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.dataSourceArray.removeAllObjects()
                self.dataSourceArray.addObjects(from: dataArray as! [Any])
                self.tableView.reloadData()
            }
        }
    }
    func sendDeleteFriendRequest(dict:NSDictionary,indexPath:IndexPath) {
        let param = ["followerUid":dict.stringValueForKey(key: "uid")]
        WHNetworkUtil.shareManager().POST(urlString: URL_friend_delete, parameters: param as [String:AnyObject]) { responseObject in
            self.sendWeekRankingListRequest()
        }
    }
}
