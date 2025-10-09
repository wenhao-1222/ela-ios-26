//
//  JournalFriendReportVC.swift
//  lns
//  好友周报
//  Created by Elavatine on 2025/7/7.
//

class JournalFriendReportVC: WHBaseViewVC {
    
    var followerUid = ""//好友uid
    var followerNickName =  ""
    var followerAvatar = ""
    var weekMsgDict = NSDictionary()
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       self.navigationController?.fd_interactivePopDisabled = false
       self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendWeeklyReposrtRequest()
    }
    
    lazy var tableView: ForumCommentListTableView = {
        let vi = ForumCommentListTableView.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight()), style: .grouped)
        vi.backgroundColor = .COLOR_BG_F5
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
//        vi.tableFooterView = nil
        vi.sectionHeaderHeight = 0
        vi.register(JournalReportFriendWeekTopCell.classForCoder(), forCellReuseIdentifier: "JournalReportFriendWeekTopCell")
        vi.register(JournalReportWeekScoreCell.classForCoder(), forCellReuseIdentifier: "JournalReportWeekScoreCell")
        vi.register(JournalReportWeekNaturalCell.classForCoder(), forCellReuseIdentifier: "JournalReportWeekNaturalCell")
        vi.register(JournalReportWeightCell.classForCoder(), forCellReuseIdentifier: "JournalReportWeightCell")
        vi.register(JournalReportWeekCalendarCell.classForCoder(), forCellReuseIdentifier: "JournalReportWeekCalendarCell")
        vi.register(JournalReportWeekBadgesCell.classForCoder(), forCellReuseIdentifier: "JournalReportWeekBadgesCell")
        
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
//            vi.sectionFooterHeight = 0
        }
        vi.contentInsetAdjustmentBehavior = .never
        vi.contentInset = .zero
        vi.scrollIndicatorInsets = .zero
    
        return vi
    }()
    lazy var nodataVm: WeekReportNoDataVM = {
        let vm = WeekReportNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight()))
        vm.isHidden = true
        return vm
    }()
}

extension JournalFriendReportVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        let badgesArray = weekMsgDict["badges"]as? NSArray ?? []
        if badgesArray.count > 0 {
            return 3
        }
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }else if section == 1{
            let weightChange = self.weekMsgDict["weightChange"]as? NSDictionary ?? [:]
            if weightChange.stringValueForKey(key: "diff").count > 0 {
                return 3
            }else{
                return 2
            }
        }else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportFriendWeekTopCell") as? JournalReportFriendWeekTopCell
                cell?.updateUI(dict: self.weekMsgDict)
                return cell ?? JournalReportFriendWeekTopCell()
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportWeekScoreCell") as? JournalReportWeekScoreCell
                cell?.updateUI(dict: self.weekMsgDict)
                return cell ?? JournalReportWeekScoreCell()
                
            }
        }else if indexPath.section == 1{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportWeekNaturalCell") as? JournalReportWeekNaturalCell
                cell?.titleLabel.text = "在过去一周平均每天摄入"
                cell?.gapTitleLabel.text = "本周的总摄入量与目标相比的差距"
                cell?.updateUI(dict: self.weekMsgDict)
                return cell ?? JournalReportWeekNaturalCell()
            }else if indexPath.row == 1{
                let weightChange = self.weekMsgDict["weightChange"]as? NSDictionary ?? [:]
                if weightChange.stringValueForKey(key: "diff").count > 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportWeightCell") as? JournalReportWeightCell
                    cell?.updateUI(dict: weightChange)
                    return cell ?? JournalReportWeightCell()
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportWeekCalendarCell") as? JournalReportWeekCalendarCell
                    cell?.updateUI(dict: self.weekMsgDict)
                    return cell ?? JournalReportWeekCalendarCell()
                }
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportWeekCalendarCell") as? JournalReportWeekCalendarCell
                cell?.updateUI(dict: self.weekMsgDict)
                return cell ?? JournalReportWeekCalendarCell()
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "JournalReportWeekBadgesCell") as? JournalReportWeekBadgesCell
            cell?.updateUI(dict: self.weekMsgDict)
            return cell ?? JournalReportWeekBadgesCell()
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2{
            let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(40)))
            vi.backgroundColor = .clear
            return vi
        }else if section == 1{
            let badgesArray = weekMsgDict["badges"]as? NSArray ?? []
            if badgesArray.count > 0 {
                let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(16)))
                let vm = JournalReportWeekDashVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
                vi.addSubview(vm)
                
                return vi
            }else{
                let footV = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(20)))
                footV.backgroundColor = .clear
                let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(20)))
                vi.backgroundColor = .white
                vi.addClipCorner(corners: [.bottomLeft,.bottomRight], radius: kFitWidth(12))
                
                footV.addSubview(vi)
                
                return footV
            }
        }else{
            let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(16)))
            let vm = JournalReportWeekDashVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
            vi.addSubview(vm)
            
            return vi
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2{
            return kFitWidth(40)
        }else if section == 1{
            let badgesArray = weekMsgDict["badges"]as? NSArray ?? []
            if badgesArray.count > 0 {
                
            }else{
                return kFitWidth(20)
            }
        }
        return kFitWidth(16)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y < 0{
//            scrollView.contentOffset.y = 0
//        }
//    }
}

extension JournalFriendReportVC{
    func initUI() {
//        initNavi(titleStr: "\(followerNickName)\(followerNickName)\(followerNickName)的周报")
        initNavi(titleStr: "周报")
        self.navigationView.addShadow(opacity: 0.05)
        view.insertSubview(tableView, belowSubview: self.navigationView)
        view.addSubview(nodataVm)
        
        initSkeleton()
    }
    func initSkeleton() {
        self.view.isSkeletonable = true
        self.tableView.isSkeletonable = true
        DispatchQueue.main.asyncAfter(deadline: .now()+0.03, execute: {
            self.tableView.showAnimatedGradientSkeleton()
            self.tableView.isUserInteractionEnabled = true
        })
    }
}

extension JournalFriendReportVC{
    func sendWeeklyReposrtRequest() {
        let param = ["followerUid":self.followerUid]
        WHNetworkUtil.shareManager().POST(urlString: URL_weekly_nutrition_report, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            let code = responseObject["code"] as? Int ?? -1
            DLLog(message: "sendWeeklyReposrtRequest:\(responseObject)")
            if code == 400 {
                self.nodataVm.tipsLabel.text = "\(responseObject["message"] as? String ?? "需要更多数据才能生成更详细营养建议与分析。每周记录满4天，即可解锁完整、精准的营养反馈。")"
                self.nodataVm.showView()
                self.tableView.isHidden = true
            }else{
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
                DLLog(message: "sendWeeklyReposrtRequest:\(dataObj)")
                var obj = NSMutableDictionary(dictionary: dataObj)
                obj.setValue(self.followerAvatar, forKey: "headimgurl")
                obj.setValue(self.followerNickName, forKey: "nickname")
                self.weekMsgDict = obj
                
                self.tableView.hideSkeleton()
                self.tableView.reloadData()
            }
        }
    }
}
