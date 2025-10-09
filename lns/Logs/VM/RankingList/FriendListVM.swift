//
//  FriendListVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/30.
//


class FriendListVM: UIView {
    
    var dataSourceArray = NSMutableArray()
    
    var tableViewOriginY = kFitWidth(56)
    var isFriendList = true
    
    var suffixUid = ""
    
    var friendDataRefreshBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = .COLOR_BG_F5
        self.isUserInteractionEnabled = true
        
        initUI()
        sendFriendListRequest()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.init(x: 0, y: tableViewOriginY, width: SCREEN_WIDHT, height: self.frame.size.height-tableViewOriginY), style: .plain)
        table.backgroundColor = .COLOR_BG_WHITE//.COLOR_BG_F5
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        
        table.register(FriendListTableViewCell.classForCoder(), forCellReuseIdentifier: "FriendListTableViewCell")
        
        return table
    }()
    lazy var titleView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: tableViewOriginY))
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "好友申请"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var noFriendDataLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(82)))
        lab.text = "暂无申请"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.isHidden = true
        return lab
    }()
    lazy var noResultLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: -1, width: SCREEN_WIDHT, height: kFitWidth(75)))
        lab.text = "该ID不存在"
        lab.backgroundColor = .COLOR_BG_WHITE
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 17, weight: .regular)
        lab.textAlignment = .center
        lab.isHidden = true
        return lab
    }()
}

extension FriendListVM{
    func initUI() {
        addSubview(tableView)
        tableView.addSubview(noResultLabel)
        
        addSubview(titleView)
        titleView.addSubview(titleLab)
        
        tableView.addSubview(noFriendDataLabel)
        
        initSkeletonData()
        
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
    func initSkeletonData() {
        dataSourceArray.removeAllObjects()
        dataSourceArray.add("")
        dataSourceArray.add("")
        dataSourceArray.add("")
        dataSourceArray.add("")
        dataSourceArray.add("")
        dataSourceArray.add("")
        dataSourceArray.add("")
        dataSourceArray.add("")
        tableView.reloadData()
    }
    func updateFrame(originY:CGFloat) {
        self.initSkeletonData()
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.frame = CGRect.init(x: 0, y: originY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-originY)
            if self.isFriendList{
                self.tableView.frame = CGRect.init(x: 0, y: self.tableViewOriginY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-originY-self.tableViewOriginY)
                self.titleView.alpha = 1
                self.tableView.backgroundColor = .COLOR_BG_WHITE
            }else{
                self.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-originY)
                self.titleView.alpha = 0
                self.tableView.backgroundColor = .COLOR_BG_F5
            }
        }
    }
}

extension FriendListVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noResultLabel.isHidden = true
        noFriendDataLabel.isHidden = true
        self.tableView.bounces = true
        if isFriendList{
            noFriendDataLabel.isHidden = dataSourceArray.count > 0 ? true : false
            self.tableView.bounces = dataSourceArray.count > 0
        }else{
            noResultLabel.isHidden = dataSourceArray.count > 0 ? true : false
        }
        
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListTableViewCell") as? FriendListTableViewCell
        
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict)
        if indexPath.row == self.dataSourceArray.count - 1{
            cell?.lineView.isHidden = true
        }
        
        cell?.addBlock = {()in
            //未申请、未同意
            if dict.stringValueForKey(key: "status") != "1" && dict.stringValueForKey(key: "status") != "2"{
                self.sendAddFriendRequest(dict: dict, indexPath: indexPath)
            }
        }
        cell?.agreeBlock = {()in
            self.sendFriendPengdingDealRequest(dict: dict, status: "2", indexPath: indexPath)
        }
        cell?.disagreeBlock = {()in
            self.sendFriendPengdingDealRequest(dict: dict, status: "3", indexPath: indexPath)
        }
        
        return cell ?? FriendListTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(75)
    }
}

extension FriendListVM{
    func sendFriendQueryRequest(uid:String) {
        isFriendList = false
        self.suffixUid = uid
        let param = ["suffixUid":"\(uid)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_friend_id_query, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendFriendQueryRequest:\(dataArray)")
            DispatchQueue.main.asyncAfter(deadline: .now()+0.02, execute: {
                self.dataSourceArray = NSMutableArray(array: dataArray)

                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    self.tableView.reloadData()
                })
            })
        }
    }
    func sendAddFriendRequest(dict:NSDictionary,indexPath:IndexPath) {
        let param = ["followeeUid":"\(dict.stringValueForKey(key: "uid"))"]
        WHNetworkUtil.shareManager().POST(urlString: URL_friend_add, parameters: param as [String:AnyObject]) { responseObject in
            let dictTemp = NSMutableDictionary(dictionary: dict)
            dictTemp.setValue("1", forKey: "status")
            self.dataSourceArray.replaceObject(at: indexPath.row, with: dictTemp)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    func sendFriendListRequest() {
        isFriendList = true
        self.suffixUid = ""
        WHNetworkUtil.shareManager().POST(urlString: URL_friend_pengding_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendFriendListRequest:\(dataArray)")
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.02, execute: {
                self.dataSourceArray = NSMutableArray(array: dataArray)
//                DispatchQueue.main.asyncAfter(deadline: .now()+5.5, execute: {
                    self.tableView.reloadData()
//                })
//            })
        }
    }
    func sendFriendPengdingDealRequest(dict:NSDictionary,status:String,indexPath:IndexPath) {
        let param = ["followerUid":"\(dict.stringValueForKey(key: "uid"))",
                     "status":"\(status)"]
        DLLog(message: "sendFriendPengdingDealRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_friend_handle, parameters: param as [String:AnyObject]) { responseObject in
            self.dataSourceArray.removeObject(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            if status == "2"{
                self.friendDataRefreshBlock?()
            }
        }
    }
}
