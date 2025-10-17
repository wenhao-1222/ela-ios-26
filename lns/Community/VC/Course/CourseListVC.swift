//
//  CourseListVC.swift
//  lns
//
//  Created by Elavatine on 2025/4/11.
//

import AVKit
import MCToast
import AliyunPlayer

class CourseListVC: WHBaseViewVC {
    
    var parentDict = NSDictionary()
    var headMsgDict = NSDictionary()
    var dataSourceArray = NSMutableArray()
    var menuDataArray:[ForumTutorialModel] = [ForumTutorialModel]()
    
    var isManualPause = false
    var hasHistory = false
    var isLoadingData = true
    var isPaid = false
    var isFromOrderList = false
    var courseId = ""
    var tapIndexPath = IndexPath()
    
    var isCNMainLand = true
    
    let backImg = UIImage(named: "back_arrow")//UIImage(named: "back_arrow_white_shadow")
    let shareImg = UIImage(named: "tutorial_share_icon")
    var tableViewBackColor = "044EF4"
    
    override func viewDidAppear(_ animated: Bool) {
        if self.menuDataArray.count > 0 {
            lastMsgVm.showView(parentId: self.parentDict.stringValueForKey(key: "id"))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkCountryDetector.isChinaMainlandByPublicIP { isCN in
            if isCN == true{
                DLLog(message: "中国大陆")
                self.isCNMainLand = true
            }else{
                DLLog(message: "非中国大陆")
                self.isCNMainLand = false
            }
        }
        
        initUI()
        AliPlayerGlobalSettings.setFairPlayCertID("7069e758e56e40eabdab57683b5d815f")
        if UserConfigModel.shared.splashId.count > 0 {
//            self.courseId = UserConfigModel.shared.splashId
            self.parentDict = ["id":UserConfigModel.shared.splashId]
            UserConfigModel.shared.splashId = ""
        }
        sendTutorialListReqeust()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshStatus), name: NOTIFI_NAME_REFRESH_COURSE_STATUS, object: nil)
//        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
//            self.sendDataListReqeust()
//        })
        
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is CoursePayResultVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
    }
    lazy var shareButton: UIButton = {
        let btn = UIButton()
        btn.setImage(shareImg, for: .normal)
        btn.isHidden = true
//        img.setImgLocal(imgName: "tutorial_share_icon")//tutorial_share_icon  course_share_icon
        
        return btn
    }()
    lazy var listHeadVm: CourseListHeadVM = {
        let coverInfoDict = self.headMsgDict["coverInfo"]as? NSDictionary ?? [:]
        var vmHeight = kFitHeight(30)
        let coverHeight = 770.0/750.0 * SCREEN_WIDHT
        vmHeight += coverHeight
//        if coverInfoDict.doubleValueForKey(key: "height") > 0 && coverInfoDict.doubleValueForKey(key: "width") > 0{
//            let coverHeight = coverInfoDict.doubleValueForKey(key: "height")/coverInfoDict.doubleValueForKey(key: "width") * SCREEN_WIDHT
//            vmHeight += coverHeight
//        }
        let vm = CourseListHeadVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: vmHeight))
        
        vm.videoPlayBlock = {[weak self] in
            guard let self = self else { return }
            DLLog(message: "视频介绍\(self.headMsgDict)")
            let coverInfoDict = self.headMsgDict["coverInfo"] as? NSDictionary ?? [:]
            let urlStr = coverInfoDict.stringValueForKey(key: "videoOssUrl")
            guard urlStr.count > 0 else { return }

            DSImageUploader().dealImgUrlSignForOss(urlStr: urlStr) { signUrl in
                let playURLT = URL(string: signUrl)
                guard let playURL = playURLT else { return }
                DispatchQueue.main.async {
                    let player = AVPlayer(url: playURL)
                    let playerVC = AVPlayerViewController()
                    playerVC.player = player
                    self.present(playerVC, animated: true) {
                        player.play()
                    }
                }
//                guard let url = URL(string: signUrl) else { return }
//                let playerVC = CoursePlayerViewController()
//                playerVC.videoURL = url
//                playerVC.modalPresentationStyle = .fullScreen
//                self.present(playerVC, animated: true)
            }
        }
        vm.heightChangeBlock = {[weak self] in
//            self.updateHeadHeight()
//            self.tableView.reloadData()
            guard let self = self else { return }
            self.updateHeadHeight()

            // 无动画 + begin/endUpdates 触发高度重算（包含 header 高度）
            UIView.performWithoutAnimation {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
            // ⚠️不要再调用 self.tableView.reloadData()
        }
        
        return vm
    }()
    lazy var tableView: ForumCommentListTableView = {
        let vi = ForumCommentListTableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT), style: .grouped)
        vi.delegate = self
        vi.dataSource = self
        vi.estimatedRowHeight = kFitWidth(140)
//        vi.backgroundColor = WHColor_16(colorStr: "044EF4")
        vi.register(CourseTiTleCell.classForCoder(), forCellReuseIdentifier: "CourseTiTleCell")
        vi.register(CourseItemCell.classForCoder(), forCellReuseIdentifier: "CourseItemCell")
        vi.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = .zero
        } else {
            // Fallback on earlier versions
        }
        
        return vi
    }()
    lazy var lastMsgVm: CourseLastMsgVM = {
        let vm = CourseLastMsgVM.init(frame: .zero)
        vm.hasLastRecordBlock = {()in
            if self.hasHistory == false{
                self.hasHistory = true
                self.tableView.reloadData()
                DLLog(message: "有历史记录，这里修改tableview Footer")
            }
        }
        vm.tapBlock = {()in
            DLLog(message: "点击了历史播放")
            if self.headMsgDict.stringValueForKey(key: "isBinding") == "1"{
                
            }else{
                if self.headMsgDict.doubleValueForKey(key: "price") > 0{
                    self.buyButtonTouchUpInside()
                }
                return
            }
            
            let vc = CourseDetailAliVC()
            vc.dataSourceArray = self.menuDataArray
            
            for i in 0..<self.menuDataArray.count{
                let model = self.menuDataArray[i]
                if model.id == self.lastMsgVm.id{
                    vc.tutorialModel = model
                    vc.currentVideoIndex = i
                    vc.videoIndexFromList = i
                    break
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return vm
    }()
    lazy var buyBottomView: UIView = {
        let height = getBottomSafeAreaHeight() > 0 ? (kFitWidth(55)+getBottomSafeAreaHeight()) : kFitWidth(66)
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-height, width: SCREEN_WIDHT, height: height))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .COLOR_BG_WHITE
        
        return vi
    }()
    lazy var buyButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("开始课程", for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.setTitleColor(.COLOR_BG_WHITE, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        
//        btn.addTarget(self, action: #selector(buyButtonTouchDown), for: .touchDown)
        btn.addTarget(self, action: #selector(buyButtonTouchUpInside), for: .touchUpInside)
//        btn.addTarget(self, action: #selector(buyButtonTouchUp), for: .touchUpOutside)
//        btn.addTarget(self, action: #selector(buyButtonTouchUp), for: .touchCancel)
        
        btn.enablePressEffect()
        
        return btn
    }()
    lazy var firstPlayTipsAlertVm: CourseListFirstPlayAlertVM = {
        let vm = CourseListFirstPlayAlertVM.init(frame: .zero)
        vm.confirmBlock = {()in
            self.sendBindDeviceRequest()
        }
        return vm
    }()
}

extension CourseListVC{
    @objc func buyButtonTouchUpInside() {
        if self.headMsgDict.stringValueForKey(key: "isPaid") == "1"{//已购买
            if self.headMsgDict.stringValueForKey(key: "bindingDeviceId").count > 0 {//已绑定
                if self.headMsgDict.stringValueForKey(key: "isBinding") == "0"{//不是绑定的本设备
                    if self.headMsgDict.doubleValueForKey(key: "rebindingQuota") > 0{//有换绑次数，执行换绑逻辑
                        self.presentAlertVc(confirmBtn: "换绑", message: "", title: "当前设备未绑定课程播放", cancelBtn: "取消", handler: { action in
                            if self.isFromOrderList{
                                self.backTapAction()
                            }else{
                                let vc = CourseOrderListVC()
                                //                    vc.orderId = self.headMsgDict.stringValueForKey(key: "orderId")
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }, viewController: self)
                    }else{//没有换绑次数，执行购买逻辑
                        let vc = CoursePayOrderVC()
                        vc.msgDict = self.headMsgDict
                        vc.parentId = self.parentDict.stringValueForKey(key: "id")
                        if self.isCNMainLand == false{
                            self.presentAlertVc(confirmBtn: "购买", message: "", title: "课程在海外网络环境可能无法正常播放，是否要继续购买？", cancelBtn: "取消", handler: { action in
                                self.navigationController?.pushViewController(vc, animated: true)
                            }, viewController: self)
                        }else{
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }else{//未绑定，走第一次绑定的逻辑
                self.view.bringSubviewToFront(self.firstPlayTipsAlertVm)
                firstPlayTipsAlertVm.showView()
                self.lastMsgVm.closeAction()
            }
        }else{//未购买
            let vc = CoursePayOrderVC()
            vc.msgDict = self.headMsgDict
            vc.parentId = self.parentDict.stringValueForKey(key: "id")
            if self.isCNMainLand == false{
                self.presentAlertVc(confirmBtn: "购买", message: "", title: "课程在海外网络环境可能无法正常播放，是否要继续购买？", cancelBtn: "取消", handler: { action in
                    self.navigationController?.pushViewController(vc, animated: true)
                }, viewController: self)
            }else{
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    @objc func refreshStatus() {
        self.isPaid = true
        self.sendTutorialListReqeust()
    }
    
    func playVideo() {
        if tapIndexPath.section > 0 && !isLoadingData{
            let dataDict = self.dataSourceArray[tapIndexPath.section-1]as? NSDictionary ?? [:]
            let tutorials = dataDict["tutorials"]as? NSArray ?? []
            let dict = tutorials[tapIndexPath.row] as? NSDictionary ?? [:]
            
//            let vc = CourseDetailVC()
            let vc = CourseDetailAliVC()
            for i in 0..<self.menuDataArray.count{
                let model = self.menuDataArray[i]
                if model.title == dict.stringValueForKey(key: "title"){
                    vc.tutorialModel = model
                    vc.currentVideoIndex = i
                    vc.videoIndexFromList = i
                    break
                }
            }
            vc.dataSourceArray = self.menuDataArray
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension CourseListVC{
    func initUI() {
        initNavi(titleStr: "",isWhite: true)
//        self.backArrowButton.backImgView.setImgLocal(imgName: "back_arrow_white_shadow")
        self.navigationView.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0)
        self.navigationView.addSubview(self.shareButton)
        
        navigationView.addShadow(opacity: 0.08)
        navigationView.clipsToBounds = false
        view.insertSubview(tableView, belowSubview: navigationView)
//        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
            self.listHeadVm.updateUI(dict: self.headMsgDict)
//        })
        
        view.insertSubview(firstPlayTipsAlertVm, at: 999)
        
        initSkeletonData()
        
        shareButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-12))
            make.centerY.lessThanOrEqualTo(self.backArrowButton)
            make.width.height.equalTo(kFitWidth(38))
        }
    }
    func showPayView() {
        view.addSubview(buyBottomView)
        buyBottomView.addSubview(buyButton)
        buyBottomView.backgroundColor = .clear
        buyButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(260))
            make.top.equalTo(kFitWidth(11))
            make.height.equalTo(kFitWidth(44))
        }
    }
    func updateHeadHeight() {
        let headVmFrame = self.listHeadVm.frame
        self.listHeadVm.frame = CGRect.init(x: 0, y: headVmFrame.minY, width: SCREEN_WIDHT, height: self.listHeadVm.selfHeight)
    }
    func initSkeletonData() {
        dataSourceArray.add(["tutorials":[[:],[:],[:],[:],[:]]])
        tableView.reloadData()
    }
    func changeNaviAlpha(offsetY:CGFloat) {
        var percent = (offsetY - self.listHeadVm.selfHeight + getNavigationBarHeight()*2) / getNavigationBarHeight()
        percent = min(max(percent, 0), 1)

        navigationView.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: percent)
        let colorValue = 1 - percent
        let arrowColor = UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1)
        self.backArrowButton.backImgView.image = backImg?.WHImageWithTintColor(color: arrowColor)
        self.shareButton.setImage(shareImg?.WHImageWithTintColor(color: arrowColor), for: .normal)
    }
}

extension CourseListVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSourceArray.count + 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            let dict = self.dataSourceArray[section-1]as? NSDictionary ?? [:]
            let tutorials = dict["tutorials"]as? NSArray ?? []
            return tutorials.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CourseTiTleCell") as? CourseTiTleCell
            
            cell?.updateUI(dict: self.headMsgDict,isPaid: self.isPaid)
            
            return cell ?? CourseTiTleCell()
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CourseItemCell") as? CourseItemCell
            
            let dataDict = self.dataSourceArray[indexPath.section-1]as? NSDictionary ?? [:]
            let tutorials = dataDict["tutorials"]as? NSArray ?? []
            let dict = tutorials[indexPath.row] as? NSDictionary ?? [:]
            
//            if isLoadingData{
//                cell?.showAnimatedSkeleton()
//            }else{
                cell?.updateUI(dict: dict)
                if self.isPaid == false{
                    cell?.lockedUI()
                }else{
                    cell?.unlockUI()
                }
//            }
            
            return cell ?? CourseItemCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        }else{
            return isLoadingData ? kFitWidth(160) : UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.view.bringSubviewToFront(self.firstPlayTipsAlertVm)
//        firstPlayTipsAlertVm.showView()
        self.tapIndexPath = indexPath
        if self.headMsgDict.stringValueForKey(key: "isBinding") == "1"{
            
        }else{
            if self.headMsgDict.doubleValueForKey(key: "price") == 0{
                self.playVideo()
            }else{
                self.buyButtonTouchUpInside()
            }
            return
        }
        self.playVideo()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return listHeadVm
        }else{
            let dataDict = self.dataSourceArray[section-1]as? NSDictionary ?? [:]
            if dataDict.stringValueForKey(key: "title").count > 0 {
                let vm = CourseItemHeadVM.init(frame: .zero)
                vm.titleLab.text = "\(dataDict.stringValueForKey(key: "sn")).\(dataDict.stringValueForKey(key: "title"))"
                vm.backgroundColor = .COLOR_BG_F5
                return vm
            }else{
                return nil
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return listHeadVm.selfHeight
        }else{
            let dataDict = self.dataSourceArray[section-1]as? NSDictionary ?? [:]
            if dataDict.stringValueForKey(key: "title").count > 0 {
                let vm = CourseItemHeadVM.init(frame: .zero)
                return vm.selfHeight
            }else{
                return 0
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }else{
            if section == self.dataSourceArray.count && self.hasHistory {
                let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.lastMsgVm.selfHeight))
                vi.backgroundColor = .clear
                return vi
            }else{
                return nil
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else{
            if section == self.dataSourceArray.count && self.hasHistory{
                return self.lastMsgVm.selfHeight
            }else{
                return 0
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.contentOffset.y > kFitWidth(10){//listHeadVm.selfHeight + kFitWidth(50){
            tableView.backgroundColor = .COLOR_BG_F5
        }else{
            tableView.backgroundColor = WHColor_16(colorStr: self.tableViewBackColor)
        }
        changeNaviAlpha(offsetY: tableView.contentOffset.y)
    }
}

extension CourseListVC{
    func sendBindDeviceRequest() {
        let param = ["id":parentDict.stringValueForKey(key: "id"),
                     "orderId":headMsgDict.stringValueForKey(key: "orderId")]
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_order_bind_device, parameters: param as [String:AnyObject],isNeedToast: true
                                          ,vc: self) { responseObject in
            let dict = NSMutableDictionary(dictionary: self.headMsgDict)
            dict.setValue("1", forKey: "isBinding")
            self.headMsgDict = dict
            self.playVideo()
        }
    }
    func sendTutorialListReqeust() {
        let param = ["id":parentDict.stringValueForKey(key: "id")]
        WHNetworkUtil.shareManager().POST(urlString: URL_tutorial_menu_briefing, parameters: param as [String:AnyObject],isNeedToast: true
                                          ,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            self.headMsgDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendTutorialListReqeust:\(self.headMsgDict)")
            self.isPaid = self.headMsgDict.stringValueForKey(key: "isPaid") == "1" ? true : false
            if self.isPaid == false{
                self.isPaid = self.headMsgDict.stringValueForKey(key: "price").floatValue > 0 ? false : true
            }
            
            let coverInfoDict = self.headMsgDict["coverInfo"]as? NSDictionary ?? [:]
            self.tableViewBackColor = coverInfoDict["rgb"]as? String ?? "0f1214"
            self.tableView.backgroundColor = WHColor_16(colorStr: self.tableViewBackColor)
            EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW,
                                                scenarioType: .launch_view,
                                                text: "教程详情页【\(self.headMsgDict.stringValueForKey(key: "title"))】:\(self.headMsgDict.stringValueForKey(key: "id"))   isPaid:\(self.headMsgDict.stringValueForKey(key: "isPaid")) price:\(self.headMsgDict.stringValueForKey(key: "price"))")
            
            if self.isPaid == false{
                self.showPayView()
//                self.lastMsgVm.isHidden = true
            }else{
                if self.headMsgDict.stringValueForKey(key: "isBinding") == "1"{
                    self.buyBottomView.isHidden = true
                    self.view.addSubview(self.lastMsgVm)
                }else{
                    if self.headMsgDict.stringValueForKey(key: "bindingDeviceId").count > 0 {
                        self.showPayView()
                        self.isPaid = false
//                        self.lastMsgVm.isHidden = true
                    }else{
                        self.isPaid = true
                        self.view.addSubview(self.lastMsgVm)
                    }
                }
            }
//            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
//                self.listHeadVm.updateUI(dict: self.headMsgDict)
//            })
            
            self.sendDataListReqeust()
        }
    }
    func sendDataListReqeust() {
        let param = ["parentId":"\(self.parentDict.stringValueForKey(key: "id"))"]
        WHNetworkUtil.shareManager().POST(urlString: URL_tutorial_menu_catogary_list, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            
//            DispatchQueue.main.asyncAfter(deadline: .now()+3.3, execute: {
                self.dataSourceArray = NSMutableArray(array: WHUtils.getArrayFromJSONString(jsonString: dataString ?? ""))
                DLLog(message: "sendDataListReqeust:\(self.dataSourceArray)")
                self.dealDataArray(dataArray: self.dataSourceArray)
                self.isLoadingData = false
                self.tableView.reloadData()
//            })
        }
    }
    func dealDataArray(dataArray:NSArray) {
        let serialQueue = DispatchQueue(label: "com.tutorials.parse")
        self.menuDataArray.removeAll()
        serialQueue.async {
            for i in 0..<self.dataSourceArray.count{
                let dict = self.dataSourceArray[i]as? NSDictionary ?? [:]
                let tutorials = dict["tutorials"]as? NSArray ?? []
                
                for j in 0..<tutorials.count{
                    let dictTuto = tutorials[j]as? NSDictionary ?? [:]
                    let model = ForumTutorialModel().dealDictForModel(dict: dictTuto)
                    model.courseId = self.parentDict.stringValueForKey(key: "id")
                    self.menuDataArray.append(model)
                }
            }
            DispatchQueue.main.async {
                self.lastMsgVm.showView(parentId: self.parentDict.stringValueForKey(key: "id"))
            }
        }
    }
}
