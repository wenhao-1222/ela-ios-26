//
//  JournalReportVC.swift
//  lns
//
//  Created by Elavatine on 2025/5/9.
//

import SkeletonView
import Photos
import MCToast

class JournalReportVC: WHBaseViewVC {
    
    var currentIndex = 0 // 0  日报   1  周报
    var detailDict = NSDictionary()
    
    override func viewDidDisappear(_ animated: Bool) {
//        SkeletonAppearance.default.gradient = .init(colors: [UIColor.COLOR_TEXT_TITLE_0f1214_06,UIColor.COLOR_TEXT_TITLE_0f1214_10])
        SkeletonAppearance.default.gradient = .init(baseColor: UIColor.COLOR_TEXT_TITLE_0f1214_06,
                                                    secondaryColor: UIColor.COLOR_TEXT_TITLE_0f1214_10)
        weekShareV.cancelPendingSave()
        self.navigationController?.fd_interactivePopDisabled = false
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.sendFriendListRequest()
//        self.navigationController?.fd_interactivePopDisabled = false
//        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        if self.typeVm.currentIndex == 1 { checkPushAuthForWeek() }
        if scrollViewBase.contentOffset.x > kFitWidth(20){
            self.navigationController?.fd_interactivePopDisabled = true
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        }else{
            self.navigationController?.fd_interactivePopDisabled = false
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SkeletonAppearance.default.gradient = .init(baseColor: WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1),
                                                    secondaryColor: WHColorWithAlpha(colorStr: "007AFF", alpha: 0.2))
//        SkeletonAppearance.default.gradient = .init(colors: [WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1),
//                                                             WHColorWithAlpha(colorStr: "007AFF", alpha: 0.05)])
        
        initUI()
        if let popGesture = self.navigationController?.fd_fullscreenPopGestureRecognizer {
            scrollViewBase.panGestureRecognizer.require(toFail: popGesture)
        }
        EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW,
                                            scenarioType: .report_daily,
                                            text: "")
//        if currentIndex == 1 {
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
//                self.typeVm.weekTapAction()
//            })
//        }
    }
    lazy var typeVm: JournalReportTypeVM = {
        let vm = JournalReportTypeVM.init(frame: .zero)
        vm.currentIndex = self.currentIndex
        vm.tapBlock = {()in
            self.updateUI()
        }
        return vm
    }()
    lazy var dailyMsgVm: JournalReportDailyMsgVM = {
        let vm = JournalReportDailyMsgVM.init(frame: CGRect.init(x: 0, y: self.typeVm.frame.maxY, width: 0, height: 0))
        vm.detailDict = self.detailDict
        vm.controller = self
        vm.offsetChangeBlock = {(offsetY)in
            self.typeVm.changeBgAlpha(offsetY: offsetY)
        }
        vm.nodataVm.recordBlock = {()in
            NotificationCenter.default.post(name: NOTIFI_NAME_REPORT_ADD_FOODS, object: nil)
            self.backTapAction()
        }
        return vm
    }()
    lazy var weekMsgVm: JournalReportWeekMsgVM = {
        let vm = JournalReportWeekMsgVM.init(frame: CGRect.init(x: 0, y: self.typeVm.frame.maxY, width: 0, height: 0))
        vm.controller = self
        vm.msgRequestBlock = {(dict)in
            self.weekShareV.weekMsgDict = dict
            self.weekShareV.hideSkeleton()
            self.weekShareV.tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                if (self.weekShareV.weekMsgDict["badges"]as? NSArray ?? []).count > 0{
                    self.weekShareV.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .bottom, animated: false)
                }else{
                    self.weekShareV.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: false)
                }
            })
        }
        vm.snapBlock = {()in
            self.saveAction()
        }
        vm.nodataVm.recordBlock = {()in
            NotificationCenter.default.post(name: NOTIFI_NAME_REPORT_ADD_FOODS, object: nil)
            self.backTapAction()
        }
        return vm
    }()
    lazy var weekShareV: JournalReportWeekMsgShareVM = {
        let vm = JournalReportWeekMsgShareVM.init(frame: self.weekMsgVm.frame)
        
        return vm
    }()
}

extension JournalReportVC{
    @objc func saveAction() {
        if weekShareV.badgesImagesLoaded || (weekShareV.weekMsgDict["badges"]as? NSArray ?? []).count == 0{
            DLLog(message: "JournalReportWeekBadgesCell 加载图片: weekShareV.badgesImagesLoaded -- true")
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    if status == .restricted || status == .denied{
                        self.presentAlertVc(confirmBtn: "打开", message: "无访问相册权限，是否去打开权限?", title: "提示", cancelBtn: "取消", handler: { (actions) in
                            let url = NSURL.init(string: UIApplication.openSettingsURLString)
                            if UIApplication.shared.canOpenURL(url! as URL){
                                UIApplication.shared.openURL(url! as URL)
                            }
                        }, viewController: self)
                    }else{
//                        MCToast.mc_loading(duration: 30)
                        if let image = self.weekShareV.tableView.snapshotFullContentWithPadding(padding: kFitWidth(-16)){//mc_makeImage()
                            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
                        }else{
                            MCToast.mc_remove()
                            MCToast.mc_text("截图失败")
                        }
                    }
                }
            }
        }else{
            DLLog(message: "JournalReportWeekBadgesCell 加载图片: weekShareV.badgesImagesLoaded -- false")
            if weekShareV.pendingSaveBlock == nil {
                weekMsgVm.shareButton.showLoadingIndicator()
                weekShareV.pendingSaveBlock = { [weak self] in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.weekMsgVm.shareButton.hideLoadingIndicator()
                        self.saveAction()
                    }
                }
            }
        }
    }
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject){
        MCToast.mc_remove()
        if error != nil{
            MCToast.mc_text("保存失败。")
        }else{
            MCToast.mc_text("已保存到系统相册")
        }
    }
}

extension JournalReportVC{
    func initUI() {
        initNavi(titleStr: "营养分析")
        view.clipsToBounds = true
        
        view.insertSubview(typeVm, belowSubview: self.navigationView)
        view.insertSubview(scrollViewBase, belowSubview: self.typeVm)
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.delegate = self
        scrollViewBase.bounces = false
        scrollViewBase.showsHorizontalScrollIndicator = false
        scrollViewBase.addSubview(dailyMsgVm)
        scrollViewBase.addSubview(weekMsgVm)
        scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT*2, height: 0)
        scrollViewBase.isPagingEnabled = true
//        scrollViewBase.panGestureRecognizer.delegate = self
        
//        view.insertSubview(dailyMsgVm, belowSubview: self.typeVm)
//        view.insertSubview(weekMsgVm, belowSubview: self.typeVm)
        view.insertSubview(weekShareV, belowSubview: self.weekMsgVm)
        
        weekMsgVm.sendWeeklyReposrtRequest()
        
        if self.detailDict.stringValueForKey(key: "sdate") == Date().todayDate{
            dailyMsgVm.sendDayliReposrtRequest()
        }else{
            dailyMsgVm.hiddenTableView()
        }
        
        dailyMsgVm.naturalHeadVm.alpha = 0
        dailyMsgVm.caloriesMealMsgVm.alpha = 0
        dailyMsgVm.caloriesSourceMsgVm.alpha = 0
        
        dailyMsgVm.caloriesMealMsgVm.setDataSource(dataDict: self.detailDict)
        dailyMsgVm.caloriesSourceMsgVm.dealData(detailDict: self.detailDict)
        UIView.animate(withDuration: 0.45, animations: {
            self.dailyMsgVm.naturalHeadVm.alpha = 1
            self.dailyMsgVm.caloriesMealMsgVm.alpha = 1
            self.dailyMsgVm.caloriesSourceMsgVm.alpha = 1
        })
    }
    func updateUI() {
        let center = self.dailyMsgVm.center
        if self.typeVm.currentIndex == 0 {
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.scrollViewBase.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
            self.navigationController?.fd_interactivePopDisabled = false
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        }else{
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT, y: 0), animated: true)
            }
            self.navigationController?.fd_interactivePopDisabled = true
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
            self.checkPushAuthForWeek()
        }
    }
}

extension JournalReportVC : UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > kFitWidth(20){
            checkPushAuthForWeek()
            self.typeVm.currentIndex = 1
            self.navigationController?.fd_interactivePopDisabled = true
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        }else{
            self.typeVm.currentIndex = 0
            self.navigationController?.fd_interactivePopDisabled = false
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        }
        self.typeVm.changeType()
    }
}

extension JournalReportVC{
    func checkPushAuthForWeek() {
//        UNUserNotificationCenter.current().getNotificationSettings { settings in
//            if settings.authorizationStatus != .authorized {
//                DispatchQueue.main.async {
//                    self.presentAlertVc(confirmBtn: "设置", message: "打开推送权限接收周报", title: "需要通知权限", cancelBtn: "取消", handler: { _ in
//                        self.openUrl(urlString: UIApplication.openSettingsURLString)
//                    }, viewController: self)
//                }
//            }
//        }
    }
    func sendFriendListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_friend_pengding_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendFriendListRequest:\(dataArray)")
            self.dailyMsgVm.rankingButton.redView.isHidden = dataArray.count > 0 ? false : true
            self.weekMsgVm.rankingButton.redView.isHidden = dataArray.count > 0 ? false : true
        }
    }
}
