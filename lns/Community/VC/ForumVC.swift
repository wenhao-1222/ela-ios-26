//
//  ForumVC.swift
//  lns
//
//  Created by LNS2 on 2024/3/21.
//

import MCToast
import Photos
import MobileCoreServices

class ForumVC : WHBaseViewVC {
    
    override func viewWillAppear(_ animated: Bool) {
        self.forumListVm.autoLoadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.fd_interactivePopDisabled = false
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        
//        self.forumListVm.autoLoadData()
//        self.forumListVm.controlView.isHidden = false
        
//        if self.naviView.selectType == "right"{
//                ZFPlayerModel.shared.playerManager.play()
//                ZFPlayerModel.shared.player.addPlayerViewToCell()
//        }
        
//        UIView.performWithoutAnimation {
////            self.tutorialListVm.tableView.beginUpdates()
//            self.tutorialListVm.tableView.reloadData()
////            self.tutorialListVm.tableView.endUpdates()
//            self.tutorialListVm.tableView.layoutIfNeeded()
//        }
//        self.tutorialListVm.tableView.performBatchUpdates {
//            self.tutorialListVm.tableView.reloadData()
//        }
        
        sendForumMsgNuberRequest()
        
//        if ZFPlayerModel.shared.playerManager.playState == .playStatePlayStopped{
//            ZFPlayerModel.shared.addToTableView(tableView: self.forumListVm.tableView, tag: playerViewTag)
//            ZFPlayerModel.shared.player.controlView = self.forumListVm.controlView
//            self.forumListVm.zfplayerBlock()
//        }
        
        ForumPublishManager.shared.checkForumUploadStatus()
    }
    override func viewDidDisappear(_ animated: Bool) {
//        self.forumListVm.controlView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendOssStsRequest()
        sendReportTypeRequest()
//        let fpsLabel = FPSLabel.init(frame: CGRect.init(x: 50, y: 50, width: 100, height: 30))
//        view.addSubview(fpsLabel)
        NotificationCenter.default.addObserver(self, selector: #selector(showForumPublishButton), name: NSNotification.Name(rawValue: "hasAllowedPosterForum"), object: nil)
    }
    
    lazy var naviView: ForumNaviTypeVM = {
        let vi = ForumNaviTypeVM.init(frame: .zero)
//        vi.publishButton.isHidden = true
        vi.publishButton.addTarget(self, action: #selector(publishAction), for: .touchUpInside)
        vi.statTypeBlock = {(type)in
            if type == .forum{
                self.scrollViewBase.setContentOffset(CGPoint.init(x: SCREEN_WIDHT, y: 0), animated: true)
                self.naviView.publishButton.isHidden = !UserInfoModel.shared.isAllowedPosterForum
            }else if type == .market{
                self.scrollViewBase.setContentOffset(CGPoint.init(x: SCREEN_WIDHT*2, y: 0), animated: true)
                self.naviView.publishButton.isHidden = true
            }else{
                self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
                self.naviView.publishButton.isHidden = true
            }
        }
        return vi
    }()
//    lazy var tutorialListVm: TutorialListVM = {
//        let vm = TutorialListVM.init(frame: .zero)
//        vm.controller = self
//        return vm
//    }()
    lazy var forumListVm: ForumListVM = {
        let vm = ForumListVM.init(frame: .zero)
        vm.controller = self
        return vm
    }()
    lazy var tutorialListVm: CourseListVM = {
        let vm = CourseListVM.init(frame: .zero)
        vm.controller = self
        return vm
    }()
    lazy var marketListVm: MarketListVM = {
        let vm = MarketListVM.init(frame: .zero)
        vm.controller = self
        
        return vm
    }()
}

extension ForumVC{
    @objc func publishAction() {
        
//        ZFPlayerModel.shared.playerManager.pause()
//        if ForumPublishManager.shared.cTime == ""{
            DLLog(message: "新建帖子")
            let localForumId = "\(UserInfoModel.shared.phone)\(Date().todaySeconds)"
            UserDefaults.set(value: localForumId, forKey: .forumLocalId)
            let cTime = localForumId.mc_cutToSuffix(from: UserInfoModel.shared.phone.count)
            ForumPublishManager.shared.forumLocalId = localForumId
            ForumPublishManager.shared.cTime = cTime
            ForumPublishSqlite.getInstance().insertDataUseSql(cTime: cTime)
//        }else{
//            DLLog(message: "有本地草稿")
//        }
        let vc = ForumPublishVC()
//        let vc = PlayerTestVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func showForumPublishButton() {
        naviView.publishButton.isHidden = !UserInfoModel.shared.isAllowedPosterForum
    }
}

extension ForumVC{
    func initUI(){
        view.addSubview(naviView)
        view.addSubview(scrollViewBase)
        scrollViewBase.frame = CGRect.init(x: 0, y: naviView.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-naviView.frame.maxY)
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.delegate = self
        scrollViewBase.showsVerticalScrollIndicator = false
        scrollViewBase.showsHorizontalScrollIndicator = false
        
//        scrollViewBase.addSubview(tutorialListVm)
        self.scrollViewBase.addSubview(self.forumListVm)
        self.scrollViewBase.addSubview(self.marketListVm)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.scrollViewBase.addSubview(self.tutorialListVm)
            self.scrollViewBase.isPagingEnabled = true
            self.scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*3, height: 0)
            self.scrollViewBase.setContentOffset(CGPointMake(SCREEN_WIDHT, 0), animated: false)
        })
    }
}

extension ForumVC:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int((scrollView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
        updateNaviStatus(currentPage: currentPage)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let currentPage = Int((scrollView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
//        updateNaviStatus(currentPage: currentPage)
    }
    func updateNaviStatus(currentPage:Int) {
        if (currentPage == 0 && self.naviView.selectType == .course) ||
        (currentPage == 1 && self.naviView.selectType == .forum) ||
            (currentPage == 2 && self.naviView.selectType == .market){
            return
        }
        if currentPage == 1{
            self.naviView.selectType = .forum
            self.naviView.publishButton.isHidden = !UserInfoModel.shared.isAllowedPosterForum
        }else{
            self.naviView.publishButton.isHidden = true
            if currentPage == 0{
                self.naviView.selectType = .course
            }else{
                self.naviView.selectType = .market
            }
        }
        self.naviView.updateButtonStatus()
    }
}

extension ForumVC{
    func sendOssStsRequest() {
        WHNetworkUtil.shareManager().GET(urlString: URL_OSS_sts) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            UserInfoModel.shared.updateOssParams(dict: self.getDictionaryFromJSONString(jsonString: dataString ?? ""))
        }
    }
    func sendReportTypeRequest() {
        WHNetworkUtil.shareManager().GET(urlString: URL_forum_report_type) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            ForumConfigModel.shared.dealReportData(dataDict: WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? ""))
        }
    }
    func sendForumMsgNuberRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_msg_count, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendForumMsgNuberRequest:\(dataObj)")
            if dataObj.stringValueForKey(key: "unreadCount").intValue > 0 {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "serviceMsgUnRead"), object: nil)
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "serviceMsgRead"), object: nil)
            }
        }
    }
}
