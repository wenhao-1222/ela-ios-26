//
//  CourseDetailVC.swift
//  lns
//
//  Created by Elavatine on 2025/4/15.
//

class CourseDetailVC : WHBaseViewVC{
    
    var dataSourceArray:[ForumTutorialModel] = [ForumTutorialModel]()
    var videoIndexFromList = -1
    var currentVideoIndex = 0
    var oldIndex = 0
    var tutorialModel = ForumTutorialModel()
    
    var selfIsShow = false
    var isFirst = true
//    var secureWrap = ScreenShieldView(content: UIView())
    
//    var fullScreenShield : ScreenShieldView?
    
    override var prefersStatusBarHidden: Bool{
        return UserConfigModel.shared.allowedOrientations != .portrait
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let current = self.videoVm.player.currentTime
        let total = self.videoVm.player.totalTime
//        CourseProgressSQLiteManager.getInstance().updateProgress(tutorialId: self.tutorialModel.id, courseId: self.tutorialModel.courseId, progress: current, duration: total)
        CourseProgressSQLiteManager.getInstance().updateProgress(tutorialId: self.tutorialModel.id, courseId: self.tutorialModel.courseId, progress: current, duration: total)
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.videoVm.player.stop()
        self.videoVm.player.currentPlayerManager.stop?()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = false
        self.videoVm.vcBack()
        self.selfIsShow = false
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "nextTutorialVideo"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playNextVideo), name: NSNotification.Name(rawValue: "nextTutorialVideo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endFullAction), name: NSNotification.Name(rawValue: "tutorialEnterFullScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exitFullAction), name: NSNotification.Name(rawValue: "tutorialExitFullScreen"), object: nil)
        self.selfIsShow = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = true
        
        initUI()
        self.menuVm.dataSourceArray = self.dataSourceArray
        detailVm.updateUI(model: self.tutorialModel)
        self.menuVm.updateUI(model: self.tutorialModel)
        self.videoVm.updateUI(model: self.tutorialModel)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            self.videoVm.play()
        })
        
        savePlayHistoryToLocal()
    }
    
    lazy var videoVm: TutorialVideoVM = {
        let vm = TutorialVideoVM.init(frame: .zero)
        vm.controller = self
        
        vm.shareBlock = {()in
            self.shareAlertVm.showViewForTutorial(tutorialMo: self.tutorialModel)
        }
        vm.playBlock = {()in
            self.videoVm.play()
        }
        vm.heightChanged = {(videoHeight)in
            self.detailVm.isHidden = false
            self.menuVm.isHidden = false
            self.videoVm.frame = CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: videoHeight)
            self.detailVm.frame = CGRect.init(x: 0, y: self.videoVm.frame.maxY, width: SCREEN_WIDHT, height: self.detailVm.selfHeight)
            self.menuVm.frame = CGRect.init(x: kFitWidth(16), y: self.detailVm.frame.maxY, width: SCREEN_WIDHT-kFitWidth(32), height: self.menuVm.selfHeight)
            self.tableView.frame = CGRect.init(x: 0, y: self.menuVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.menuVm.frame.maxY)
            
            if self.videoIndexFromList > 0{
                DLLog(message: "这里需要滚动到相应 Cell")
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    if self.videoIndexFromList > self.dataSourceArray.count - 1{
                        return
                    }
//                    if self.videoIndexFromList < self.dataSourceArray.count - 1{
//                        self.videoIndexFromList += 1
//                    }
                    self.tableView.scrollToRow(at: IndexPath(row: self.videoIndexFromList, section: 0), at: .middle, animated: false)
                    self.videoIndexFromList = -1
                })
            }
//            self.tableView.frame = CGRect.init(x: 0, y: self.videoVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.videoVm.frame.maxY)
        }
        vm.controlView.shareBtnClickCallback = {(isPortrait)in
            if isPortrait{
                DLLog(message: "竖屏 --- 分享")
                self.shareAlertVm.showViewForTutorial(tutorialMo: self.tutorialModel)
            }else{
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                appDelegate.getKeyWindow().addSubview(self.shareAlertLandscapeVm)
//                self.shareAlertLandscapeVm.showViewForTutorial(tutorialMo: self.tutorialModel)
//                DLLog(message: "横屏 --- 分享")
            }
        }
        vm.player.orientationWillChange = {player,isFullScreen in
            if isFullScreen{
                self.coverBlackView.isHidden = false
//                
//                // 获取当前横屏控制器
//                if let fullVC = self.presentedViewController {
//                    // 取出真正的视频 view
//                    let videoView = player.currentPlayerManager.view   // ZFPlayerView, 非 Optional
//                    // 1️⃣ 把 videoView 从原父视图移除
//                    let originalFrame = videoView.frame
//                    videoView.removeFromSuperview()
//
//                    // 2️⃣ 用 ScreenShieldView 包裹
//                    let shield = ScreenShieldView(content: videoView)
//                    shield.frame = originalFrame
//                    fullVC.view.addSubview(shield)
//
//                    // 3️⃣ 更新 reference
//                    self.fullScreenShield = shield
//                }
            } else {
//                player.orientationObserver.fullScreenContainerView = self.secureWrap
//                self.fullScreenShield?.removeFromSuperview()
//                self.fullScreenShield = nil
            }
            self.setNeedsStatusBarAppearanceUpdate()
            if #available(iOS 16.0, *) {
//                self.setNeedsUpdateOfSupportedInterfaceOrientations()
            } else {
                // Fallback on earlier versions
                UIViewController.attemptRotationToDeviceOrientation()
            }
            
        }
        vm.player.playerPlayFailed = { asset,error in
            self.backArrowButton.isHidden = true
        }
        vm.player.forceDeviceOrientation = true
        return vm
    }()
    lazy var detailVm: TutorialContentVM = {
        let vm = TutorialContentVM.init(frame: CGRect.init(x: 0, y: self.videoVm.frame.maxY, width: 0, height: 0))
//        vm.isHidden = true
        
//        vm.updateUI(model: self.tutorialModel)
        vm.heightChangeBlock = {()in
            self.detailVm.frame = CGRect.init(x: 0, y: self.videoVm.frame.maxY, width: SCREEN_WIDHT, height: self.detailVm.selfHeight)
            self.menuVm.frame = CGRect.init(x: kFitWidth(16), y: self.detailVm.frame.maxY, width: SCREEN_WIDHT-kFitWidth(32), height: self.menuVm.selfHeight)
            self.tableView.frame = CGRect.init(x: 0, y: self.menuVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.menuVm.frame.maxY)
            
        }
        return vm
    }()
    //上一个   下一个
    lazy var menuVm: TutorialMenuVM = {
        let vm = TutorialMenuVM.init(frame: CGRect.init(x: 0, y: self.detailVm.frame.maxY, width: 0, height: 0))
//        let vm = TutorialMenuVM.init(frame: CGRect.init(x: 0, y: kFitWidth(8), width: 0, height: 0))
        vm.layer.cornerRadius = kFitWidth(0)
//        vm.isHidden = true
        
        vm.nextVm.tapBlock = {()in
            self.playNextVideo()
            DLLog(message: "下一个视频")
        }
        vm.lastVm.tapBlock = {()in
            self.playLastVideo()
            DLLog(message: "上一个视频")
        }
        return vm
    }()
    lazy var tableView: ForumCommentListTableView = {
        let vi = ForumCommentListTableView.init(frame: CGRect.init(x: 0, y: self.menuVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.menuVm.frame.maxY), style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.sectionFooterHeight = 0
//        vi.register(CourseTiTleCell.classForCoder(), forCellReuseIdentifier: "CourseTiTleCell")
        vi.register(CoursePlayingItemCell.classForCoder(), forCellReuseIdentifier: "CoursePlayingItemCell")
        
        return vi
    }()
    lazy var shareAlertVm: ForumShareVM = {
        let vm = ForumShareVM.init(frame: .zero)
        
        return vm
    }()
    
    lazy var coverBlackView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: -SCREEN_WIDHT*2, y: -SCREEN_HEIGHT*2, width: SCREEN_WIDHT*5, height: SCREEN_HEIGHT*5))
        vi.backgroundColor = .black
        vi.isHidden = true
        
        return vi
    }()
}

extension CourseDetailVC{
    func initUI() {
//        secureWrap = ScreenShieldView(content: videoVm)
        view.addSubview(tableView)
        view.addSubview(videoVm)
        view.bringSubviewToFront(videoVm)
        
        view.backgroundColor = .white//WHColor_16(colorStr: "1C1C1C")
        
        view.insertSubview(detailVm, belowSubview: videoVm)
        view.insertSubview(menuVm, belowSubview: videoVm)
        
        view.addSubview(coverBlackView)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.getKeyWindow().addSubview(self.shareAlertVm)
        })
    }
    
    @objc func endFullAction() {
        self.coverBlackView.isHidden = false
        UserConfigModel.shared.userInterfaceOrientation = .landscapeLeft
        UserConfigModel.shared.allowedOrientations = .landscape
        if #available(iOS 16.0, *) {
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIDevice.current.setValue(NSNumber(value: UserConfigModel.shared.allowedOrientations.rawValue), forKey: "orientation")
//            ZFOrientationObserver()
            // Fallback on earlier versions
//            UIDevice.
        }
    }
    @objc func exitFullAction() {
//        UserConfigModel.shared.allowedOrientations = .portrait
//        UserConfigModel.shared.userInterfaceOrientation = .portrait
//        self.view.backgroundColor = .COLOR_GRAY_BLACK_85
        
        UIView.animate(withDuration: 0.3) {
            self.coverBlackView.alpha = 0
        }completion: { t in
            self.coverBlackView.isHidden = true
            self.coverBlackView.alpha = 1
        }
        self.videoVm.controlView.rateView.isHidden = true
        UserConfigModel.shared.userInterfaceOrientation = .portrait
        UserConfigModel.shared.allowedOrientations = .portrait
        if #available(iOS 16.0, *) {
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIDevice.current.setValue(NSNumber(value: UserConfigModel.shared.allowedOrientations.rawValue), forKey: "orientation")
//            UIDevice.current.setValue(UserConfigModel.shared.allowedOrientations.rawValue, forKey: "orientation")
            // Fallback on earlier versions
        }
    }
    @objc func playNextVideo() {
        if self.currentVideoIndex >= self.dataSourceArray.count - 1{
            return
        }
        self.isFirst = false
        self.oldIndex = self.currentVideoIndex
        self.currentVideoIndex = self.currentVideoIndex + 1
        self.updatePlayModel()
//        self.tableView.scrollToRow(at: IndexPath(row: self.currentVideoIndex, section: 0), at: .middle, animated: true)
    }
    func playLastVideo() {
        if self.currentVideoIndex <= 0{
            return
        }
        self.isFirst = false
        self.oldIndex = self.currentVideoIndex
        self.currentVideoIndex = self.currentVideoIndex - 1
        self.updatePlayModel()
//        self.tableView.scrollToRow(at: IndexPath(row: self.currentVideoIndex, section: 0), at: .middle, animated: true)
    }
    func updatePlayModel() {
        self.tableView.scrollToRow(at: IndexPath(row: self.currentVideoIndex, section: 0), at: .middle, animated: true)
        self.tutorialModel = self.dataSourceArray[self.currentVideoIndex]
        self.detailVm.updateUI(model: self.tutorialModel)
        self.menuVm.updateUI(model: self.tutorialModel)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            self.videoVm.updateUI(model: self.tutorialModel)
            self.videoVm.play()
            self.savePlayHistoryToLocal()
        
            let oldIndexPath = IndexPath(row: self.oldIndex, section: 0)
            let newIndexPath = IndexPath(row: self.currentVideoIndex, section: 0)

            // 更新 oldIndex 对应的 cell 状态（如果在屏幕内）
            if let oldCell = self.tableView.cellForRow(at: oldIndexPath) as? CoursePlayingItemCell {
                oldCell.updateSelectStatus(model: self.dataSourceArray[self.oldIndex], isPlaying: false)
            } else {
                // 不在屏幕上，reload 它
                self.tableView.reloadRows(at: [oldIndexPath], with: .none)
            }

            // 更新 currentVideoIndex 对应的 cell 状态（如果在屏幕内）
            if let newCell = self.tableView.cellForRow(at: newIndexPath) as? CoursePlayingItemCell {
                newCell.updateSelectStatus(model: self.dataSourceArray[self.currentVideoIndex], isPlaying: true)
            } else {
                // 不在屏幕上，reload 它
                self.tableView.reloadRows(at: [newIndexPath], with: .none)
            }
        })
    }
    func savePlayHistoryToLocal() {
        let currentDict = NSMutableDictionary()
        currentDict.setValue(tutorialModel.courseId, forKey: "parentId")
        currentDict.setValue(tutorialModel.id, forKey: "id")
        currentDict.setValue(tutorialModel.coverUrl, forKey: "coverUrl")
        currentDict.setValue(tutorialModel.videoUrl, forKey: "videoUrl")
        currentDict.setValue(tutorialModel.title, forKey: "title")
        currentDict.setValue(tutorialModel.subTitle, forKey: "subTitle")
        currentDict.setValue(tutorialModel.webLink, forKey: "webLink")
        if tutorialModel.videoDuration > 0 {
            currentDict.setValue(tutorialModel.videoDurationShow, forKey: "videoDuration")
        }
        
        UserDefaults.setCourseMsg(dict: currentDict)
    }
}

extension CourseDetailVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return 1
//        }else{
            return dataSourceArray.count
//        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CourseTiTleCell") as? CourseTiTleCell
//            cell?.titleLab.text = self.tutorialModel.title
//            cell?.detailLab.text = self.tutorialModel.subTitle
//            cell?.backgroundColor = .white
////            cell?.updateUI(dict: self.headMsgDict)
//            
//            return cell ?? CourseTiTleCell()
//        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoursePlayingItemCell") as? CoursePlayingItemCell
            let model = self.dataSourceArray[indexPath.row]
        cell?.imgLoadBlock = {()in
            if let img = cell?.imgView.image {
                model.coverImg = img
                model.isLoadImg = true
                self.dataSourceArray[indexPath.row] = model
            }
        }
        cell?.updateUI(model: model, isPlaying: self.currentVideoIndex == indexPath.row,isFirstLoad:self.isFirst)
        
            return cell ?? CoursePlayingItemCell()
//        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.currentVideoIndex == indexPath.row{
            return
        }
//        if indexPath.section == 1{
//        let inde = self.currentVideoIndex
        self.oldIndex = self.currentVideoIndex
        
            self.currentVideoIndex = indexPath.row
        self.isFirst = false
//        self.tableView.reloadRows(at: [IndexPath(row: inde, section: 0)], with: .none)
            self.updatePlayModel()
//        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.contentOffset.y < 0{
            tableView.contentOffset.y = 0
        }
    }
}
