//
//  ForumTutorialVC.swift
//  lns
//  教程页面
//  Created by Elavatine on 2024/12/23.
//

import MCToast

class ForumTutorialVC : WHBaseViewVC{
    
    var parentDict = NSDictionary()
    
    var dataSourceArray = NSMutableArray()
    var dataArr = NSArray()
    var tutoIndex = 0
    var currentTutoIndex = 0
    var currentVideoIndex = 0
    
    var tutorialModel = ForumTutorialModel()
    var coverImgViewUrl = ""
//    var allowedOrientations : UIInterfaceOrientationMask = .portrait
    
    var selfIsShow = false
    
//    override var shouldAutorotate: Bool{
//        return true
//    }
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
//        return UserConfigModel.shared.allowedOrientations
//    }
    
    override var prefersStatusBarHidden: Bool{
        return UserConfigModel.shared.allowedOrientations != .portrait
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.navigationController?.fd_interactivePopDisabled = false
//        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
    }
    override func viewDidDisappear(_ animated: Bool) {
//        self.navigationController?.fd_interactivePopDisabled = true
//        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        self.videoVm.player.stop()
        self.videoVm.player.currentPlayerManager.stop?()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = false
        self.backArrowButton.isHidden = false
        self.backArrowButton.backImgView.setImgLocal(imgName: "back_arrow_white_icon")
        self.videoVm.vcBack()
        self.selfIsShow = false
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "nextTutorialVideo"), object: nil)
    }
    func initWidtDict(dict:NSDictionary) ->ForumTutorialVC {
        self.parentDict = dict
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.viewDidLoad()
//        })
        return self
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playNextVideo), name: NSNotification.Name(rawValue: "nextTutorialVideo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endFullAction), name: NSNotification.Name(rawValue: "tutorialEnterFullScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exitFullAction), name: NSNotification.Name(rawValue: "tutorialExitFullScreen"), object: nil)
        self.selfIsShow = true
    }

//    override func viewWillDisappear(_ animated: Bool) {
////        self.videoVm.controlView.resetControlView()
//        
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = true
        
        self.dataSourceArray = NSMutableArray(array: UserConfigModel.shared.tutorialsDataDict["\(self.parentDict.stringValueForKey(key: "id"))"]as? NSArray ?? [])
        initUI()
        if self.dataSourceArray.count > 0 {
            DLLog(message: "教程--------有数据:\(self.dataSourceArray.count)")
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                let currentTutoArray = self.dataSourceArray[self.currentTutoIndex]as? NSArray ?? []
                let model = currentTutoArray[self.currentVideoIndex]as! ForumTutorialModel
                
                self.videoVm.frame = CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: model.contentHeight)
                self.videoVm.updateUI(model: model)
                self.tutorialModel = model
                self.detailVm.updateUI(model: model)
                self.menuVm.dealDataArray(dataArray: self.dataSourceArray)
                self.menuVm.updateUI(model: model)
                self.updateUI()
    //            self.playVideo(index: self.currentVideoIndex)
                
                if (UserConfigModel.shared.tutorialsTypeDict["\(self.parentDict.stringValueForKey(key: "id"))"]as? NSArray ?? []).count > 0 {
                    self.dataArr = (UserConfigModel.shared.tutorialsTypeDict["\(self.parentDict.stringValueForKey(key: "id"))"]as? NSArray ?? [])
                    self.typeVm.updateUI(dataArray: self.dataArr)
                }
//            })
        }else{
            DLLog(message: "教程--------没有数据:\(self.dataSourceArray.count)")
            sendDataListReqeust()
        }
    }
    
    lazy var videoVm: TutorialVideoVM = {
        let vm = TutorialVideoVM.init(frame: .zero)
//        vm.backgroundColor = WHColor_ARC()
        vm.controller = self
        let materialDict = self.parentDict["material"]as? NSDictionary ?? [:]
        let imgArray = materialDict["image"]as? NSArray ?? []
        if imgArray.count > 0{
            let imgDict = imgArray[0]as? NSDictionary ?? [:]
            self.coverImgViewUrl = imgDict.stringValueForKey(key: "ossUrl")
            vm.videoImageView.setImgUrl(urlString: self.coverImgViewUrl)
//            self.backArrowButton.isHidden = true
//            vm.play()
//            vm.controlView.showTitle("", coverURLString: self.coverImgViewUrl, placeholderImage: UIImage(named: "forum_tutorial_default_cover")!, fullScreenMode: .portrait)
        }
//        vm.player.addDeviceOrientationObserver()
        vm.shareBlock = {()in
            self.shareAlertVm.showViewForTutorial(tutorialMo: self.tutorialModel)
        }
        vm.playBlock = {()in
            self.backArrowButton.isHidden = true
            self.videoVm.play()
        }
        vm.heightChanged = {(videoHeight)in
            self.videoVm.frame = CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: videoHeight)
//            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.typeVm.isHidden = false
                self.dataListVm.isHidden = false
                self.detailVm.isHidden = false
                self.menuVm.isHidden = false
                
                self.detailVm.frame = CGRect.init(x: 0, y: self.videoVm.frame.maxY, width: SCREEN_WIDHT, height: self.detailVm.selfHeight)
            self.menuVm.frame = CGRect.init(x: kFitWidth(8), y: self.detailVm.frame.maxY, width: SCREEN_WIDHT-kFitWidth(16), height: self.menuVm.selfHeight)
                self.typeVm.frame = CGRect.init(x: 0, y: self.menuVm.frame.maxY, width: SCREEN_WIDHT, height: self.typeVm.selfHeight)
                self.dataListVm.selfHeight = SCREEN_HEIGHT - self.typeVm.frame.maxY
                self.dataListVm.frame = CGRect.init(x: 0, y: self.typeVm.frame.maxY, width: SCREEN_WIDHT, height: self.dataListVm.selfHeight)
                self.dataListVm.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.dataListVm.selfHeight)
//            }
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
            }
            self.setNeedsStatusBarAppearanceUpdate()
            if #available(iOS 16.0, *) {
//                self.setNeedsUpdateOfSupportedInterfaceOrientations()
            } else {
                // Fallback on earlier versions
                UIViewController.attemptRotationToDeviceOrientation()
            }
            
        }
        vm.player.orientationDidChanged = {play,isFullScreen in
            DLLog(message: "orientationDidChanged:\(isFullScreen)")
//            if isFullScreen{
//                UserConfigModel.shared.userInterfaceOrientation = .landscapeLeft
//                UserConfigModel.shared.allowedOrientations = .landscape
//            }else{
//                UserConfigModel.shared.userInterfaceOrientation = .landscapeLeft
//                UserConfigModel.shared.allowedOrientations = .portrait
//            }
//            if #available(iOS 16.0, *) {
//                self.setNeedsUpdateOfSupportedInterfaceOrientations()
//            } else {
//                // Fallback on earlier versions
//            }
        }
        vm.player.forceDeviceOrientation = true
//        vm.player.orientationWillChange = {()in
//                
//        }
        return vm
    }()
    lazy var detailVm: TutorialContentVM = {
        let vm = TutorialContentVM.init(frame: .zero)
        vm.isHidden = true
        
        vm.heightChangeBlock = {()in
            self.detailVm.frame = CGRect.init(x: 0, y: self.videoVm.frame.maxY, width: SCREEN_WIDHT, height: self.detailVm.selfHeight)
            self.menuVm.frame = CGRect.init(x: kFitWidth(8), y: self.detailVm.frame.maxY, width: SCREEN_WIDHT-kFitWidth(16), height: self.menuVm.selfHeight)
            self.typeVm.frame = CGRect.init(x: 0, y: self.menuVm.frame.maxY, width: SCREEN_WIDHT, height: self.typeVm.selfHeight)
            self.dataListVm.selfHeight = SCREEN_HEIGHT - self.typeVm.frame.maxY
            self.dataListVm.frame = CGRect.init(x: 0, y: self.typeVm.frame.maxY, width: SCREEN_WIDHT, height: self.dataListVm.selfHeight)
            self.dataListVm.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.dataListVm.selfHeight)
        }
        return vm
    }()
    //上一个   下一个
    lazy var menuVm: TutorialMenuVM = {
        let vm = TutorialMenuVM.init(frame: .zero)
        vm.isHidden = true
        vm.nextVm.tapBlock = {()in
            self.playNextVideo()
        }
        vm.lastVm.tapBlock = {()in
            self.playLastVideo()
        }
        return vm
    }()
    //视频分类
    lazy var typeVm: TutorialVideoTypeVM = {
        let vm = TutorialVideoTypeVM.init(frame: CGRect.init(x: 0, y: self.videoVm.frame.maxY, width: 0, height: 0))
        vm.isHidden = true
        vm.tapBlock = {(index)in
            self.tutoIndex = index
            if self.tutoIndex == self.currentTutoIndex{
                self.dataListVm.selectIndex = self.currentVideoIndex
            }else{
                self.dataListVm.selectIndex = -1
            }
            
            self.dataListVm.setDataArray(array: self.dataSourceArray[self.tutoIndex] as! [ForumTutorialModel])
        }
        return vm
    }()
    //视频列表
    lazy var dataListVm: TutorialDataListVM = {
        let vm = TutorialDataListVM.init(frame: .zero)
        vm.isHidden = true
        vm.tapBlock = {(index)in
            self.currentVideoIndex = index
            self.currentTutoIndex = self.tutoIndex
            self.playVideo(index: index)
        }
        return vm
    }()
    lazy var shareAlertVm: ForumShareVM = {
        let vm = ForumShareVM.init(frame: .zero)
        
        return vm
    }()
//    lazy var shareAlertLandscapeVm: ForumShareVM = {
//        let vm = ForumShareVM.init(frame: .zero)
//        
//        return vm
//    }()
    lazy var coverBlackView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: -SCREEN_WIDHT*2, y: -SCREEN_HEIGHT*2, width: SCREEN_WIDHT*5, height: SCREEN_HEIGHT*5))
        vi.backgroundColor = .black
        vi.isHidden = true
        
        return vi
    }()
}

extension ForumTutorialVC{
    func initUI() {
        view.addSubview(self.videoVm)
        view.addSubview(backArrowButton)
        backArrowButton.backImgView.setImgLocal(imgName: "back_arrow_white_icon_max")
        backArrowButton.backImgView.snp.remakeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(32))
        }
        view.backgroundColor = .white//WHColor_16(colorStr: "1C1C1C")
        
        view.insertSubview(detailVm, belowSubview: self.videoVm)
        view.insertSubview(menuVm, belowSubview: self.videoVm)
        view.insertSubview(typeVm, belowSubview: self.videoVm)
        view.insertSubview(dataListVm, belowSubview: self.videoVm)
        
        view.addSubview(coverBlackView)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.getKeyWindow().addSubview(self.shareAlertVm)
        })
    }
    func updateUI() {
//        self.backArrowButton.isHidden = true
        let arrayTemp = NSMutableArray.init(array: dataSourceArray) 
        if arrayTemp.count <= tutoIndex {
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
//                self.updateUI()
//            })
            return
        }
        self.typeVm.updateUI(dataArray: self.dataArr)
        self.dataListVm.selectIndex = 0
        self.dataListVm.setDataArray(array: arrayTemp[tutoIndex] as! [ForumTutorialModel])
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.typeVm.isHidden = false
            self.dataListVm.isHidden = false
            self.videoVm.isHidden = false
            self.menuVm.isHidden = false
            self.detailVm.frame = CGRect.init(x: 0, y: self.videoVm.frame.maxY, width: SCREEN_WIDHT, height: self.detailVm.selfHeight)
            self.menuVm.frame = CGRect.init(x: kFitWidth(8), y: self.detailVm.frame.maxY, width: SCREEN_WIDHT-kFitWidth(16), height: self.menuVm.selfHeight)
            self.typeVm.frame = CGRect.init(x: 0, y: self.menuVm.frame.maxY, width: SCREEN_WIDHT, height: self.typeVm.selfHeight)
            self.dataListVm.selfHeight = SCREEN_HEIGHT - self.typeVm.frame.maxY
            self.dataListVm.frame = CGRect.init(x: 0, y: self.typeVm.frame.maxY, width: SCREEN_WIDHT, height: self.dataListVm.selfHeight)
            self.dataListVm.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.dataListVm.selfHeight)
        }
    }
    func playVideo(index:Int) {
        let currentTutoArray = dataSourceArray[currentTutoIndex]as? NSArray ?? []
        let model = currentTutoArray[index]as! ForumTutorialModel
        
        self.videoVm.updateUI(model: model)
        self.videoVm.play()
//        self.videoVm.playBtn.isHidden = true
//        self.videoVm.shareButton.isHidden = true
        
        self.videoVm.frame = CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: model.contentHeight)
        self.tutorialModel = model
        self.menuVm.updateUI(model: model)
        self.detailVm.updateUI(model: model)
        self.backArrowButton.isHidden = true
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
        DLLog(message: "playNextVideo----------------")
        if dataSourceArray.count == 0 {
            return
        }
        let currentTutoArray = dataSourceArray[currentTutoIndex]as? NSArray ?? []
        if currentTutoArray.count > self.currentVideoIndex + 1{
            self.currentVideoIndex += 1
//            self.dataListVm.tableView.setContentOffset(CGPoint.zero, animated: true)
        }else{
            if dataSourceArray.count > currentTutoIndex + 1{
                self.currentTutoIndex += 1
                self.tutoIndex = self.currentTutoIndex
                let currentTutoArray = dataSourceArray[currentTutoIndex]as? NSArray ?? []
                if currentTutoArray.count > 0 {
                    self.currentVideoIndex = 0
                    self.typeVm.changeType(index: self.currentTutoIndex)
//                    self.dataListVm.tableView.setContentOffset(CGPoint.zero, animated: true)
                }else{
                    self.currentTutoIndex -= 1
                    MBProgressHUD.xy_show("已经是最后一个视频了",delay: 2,toView: self.view)
//                    MCToast.mc_text("已经是最后一个视频了",respond: .allow)
                    return
                }
            }else{
                MBProgressHUD.xy_show("已经是最后一个视频了",delay: 2,toView: self.videoVm.player.controlView)
//                MCToast.mc_text("已经是最后一个视频了",respond: .allow)
                return
            }
        }
        DLLog(message: "currentVideoIndex:\(self.currentTutoIndex)  --  \(self.currentVideoIndex)")
        self.tutoIndex = self.currentTutoIndex
        self.typeVm.changeType(index: self.currentTutoIndex)
        self.playVideo(index: self.currentVideoIndex)
        self.dataListVm.selectIndex = self.currentVideoIndex
        self.dataListVm.setDataArray(array: self.dataSourceArray[currentTutoIndex] as! [ForumTutorialModel])
        self.dataListVm.tableView.scrollToRow(at: IndexPath(row: self.currentVideoIndex, section: 0), at: .middle, animated: true)
//        self.dataListVm.tableView.reloadData()
    }
    @objc func playLastVideo() {
        if dataSourceArray.count == 0 {
            return
        }
        if self.currentVideoIndex == 0 && self.currentTutoIndex == 0 {
            return
        }
        if self.currentVideoIndex == 0 {
            self.currentTutoIndex -= 1
            self.tutoIndex = self.currentTutoIndex
            let currentTutoArray = dataSourceArray[currentTutoIndex]as? NSArray ?? []
            self.currentVideoIndex = currentTutoArray.count - 1
            self.typeVm.changeType(index: self.currentTutoIndex)
        }else{
            self.currentVideoIndex -= 1
        }
        self.tutoIndex = self.currentTutoIndex
        DLLog(message: "currentVideoIndex:\(self.currentTutoIndex)  --  \(self.currentVideoIndex)")
        self.playVideo(index: self.currentVideoIndex)
        self.dataListVm.selectIndex = self.currentVideoIndex
        self.dataListVm.setDataArray(array: self.dataSourceArray[currentTutoIndex] as! [ForumTutorialModel])
//        self.dataListVm.tableView.reloadData()
//        self.dataListVm.tableView.row
        self.typeVm.changeType(index: self.currentTutoIndex)
        self.dataListVm.tableView.scrollToRow(at: IndexPath(row: self.currentVideoIndex, section: 0), at: .middle, animated: true)
    }
}

extension ForumTutorialVC{
    func sendDataListReqeust() {
//        MCToast.mc_loading()
        let param = ["parentId":"\(self.parentDict.stringValueForKey(key: "id"))"]
        WHNetworkUtil.shareManager().POST(urlString: URL_tutorial_menu_catogary_list, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            self.dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendDataListReqeust:\(self.dataArr)")
            DLLog(message: "教程--------没有数据（sendDataListReqeust）:\(self.dataArr.count)")
            let dictLast = self.dataArr[self.currentTutoIndex]as? NSDictionary ?? [:]
            let tutorialsLast = dictLast["tutorials"]as? NSArray ?? []
            let dictVideoLast = tutorialsLast[self.currentVideoIndex]as? NSDictionary ?? [:]
            let modelLast = ForumTutorialModel().dealDictForModel(dict: dictVideoLast)
            self.videoVm.frame = CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: modelLast.contentHeight)
            self.videoVm.updateUI(model: modelLast)
            self.tutorialModel = modelLast
            self.detailVm.updateUI(model: modelLast)
            
            let serialQueue = DispatchQueue(label: "com.tutorials.parse\(self.parentDict.stringValueForKey(key: "id"))")
            var arrayTemp = NSMutableArray()
            serialQueue.async {
                self.dataSourceArray.removeAllObjects()
                for i in 0..<self.dataArr.count{
                    let dict = self.dataArr[i]as? NSDictionary ?? [:]
                    let tutorials = dict["tutorials"]as? NSArray ?? []
                    
                    let dataArrTemp = NSMutableArray()
                    for j in 0..<tutorials.count{
                        let dictTuto = tutorials[j]as? NSDictionary ?? [:]
                        let model = ForumTutorialModel().dealDictForModel(dict: dictTuto)
                        dataArrTemp.add(model)
                    }
                    arrayTemp.add(dataArrTemp)
//                    self.dataSourceArray.add(dataArrTemp)
                }
            }
            serialQueue.async {
                self.dataSourceArray = NSMutableArray(array: arrayTemp)
                DispatchQueue.main.async {
                    self.menuVm.dealDataArray(dataArray: self.dataSourceArray)
                    self.menuVm.updateUI(model: modelLast)
                    self.updateUI()
                }
            }
        }
    }
}
