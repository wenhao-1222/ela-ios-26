//
//  FriendRankingDailyListVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/3.
//

class FriendRankingDailyListVM: UIView {
    
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
        
        sendDailyRankingListRequest()
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
        vi.register(FriendRankingDailyTableViewCell.classForCoder(), forCellReuseIdentifier: "FriendRankingDailyTableViewCell")
        
        return vi
    }()
    lazy var footerVm: FriendRankingDailyFootVM = {
        let vm = FriendRankingDailyFootVM.init(frame: .zero)
        
        return vm
    }()
}

extension FriendRankingDailyListVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRankingDailyTableViewCell")as? FriendRankingDailyTableViewCell
        
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict, index: indexPath.row)
        
        cell?.editBlock = { [weak self, weak cell] view in
            guard let self = self else { return }
            // Dismiss any existing popup to prevent multiple delete actions
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
//            let actions = [
//                ("删除", { print("删除 clicked") }),
//                ("重命名", { print("重命名 clicked") }),
//                ("分享", { print("分享 clicked") })
//            ]
//            let popup = ActionPopupController(anchor: tapLocation, in: self.controller.view, actions: actions)
            let popup = ActionPopupController(anchor: tapLocation, in: container!, actions: actions)
//            popup.onDismiss {
//                print("已关闭")
//            }
            
            popup.onDismiss { [weak self] in
                print("已关闭")
                self?.currentPopup = nil
            }
            self.currentPopup = popup
        }
        
        return cell ?? FriendRankingDailyTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(199)
    }
}

extension FriendRankingDailyListVM{
    func initUI() {
        self.isSkeletonable = true
        tableView.isSkeletonable = true
        addSubview(tableView)
        initSkeletonData()
    }
    
    func initSkeletonData() {
        dataSourceArray.removeAllObjects()
        for _ in 0..<3 {
            dataSourceArray.add([:])
        }
        tableView.reloadData()

//        DispatchQueue.main.asyncAfter(deadline: .now()+0.03) {
//            self.tableView.showAnimatedGradientSkeleton()
//        }
    }
}

extension FriendRankingDailyListVM{
    func sendDailyRankingListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_report_daily_ranking, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendDailyRankingListRequest:\(dataArray)")
            self.tableView.hideSkeleton(transition: .crossDissolve(0.3))
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.dataSourceArray.removeAllObjects()
                self.dataSourceArray.addObjects(from: dataArray as! [Any])
                self.tableView.reloadData()
                if self.dataSourceArray.count < 3 {
                    self.tableView.tableFooterView = self.footerVm
                    self.footerVm.updateSkeleton(isLoading: false)
                    // 3) 最后统一把骨架优雅淡出 + 内容淡入
                    [self.footerVm].forEach { $0.hideSkeletonWithCrossfade() }
                }
            }
        }
    }
    func sendDeleteFriendRequest(dict:NSDictionary,indexPath:IndexPath) {
        let param = ["followerUid":dict.stringValueForKey(key: "uid")]
        WHNetworkUtil.shareManager().POST(urlString: URL_friend_delete, parameters: param as [String:AnyObject]) { responseObject in
            self.sendDailyRankingListRequest()
//            self.dataSourceArray.removeObject(at: indexPath.row)
//            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
