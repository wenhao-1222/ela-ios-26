//
//  JournalShareVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/29.
//

import Foundation
import Photos
import MCToast

class JournalShareVC: WHBaseViewVC {
    
    var dayString = ""
    var detailsDict = NSDictionary()
    
    var mealsArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dealDataSource()
        initUI()
        
    }
    
    lazy var naviVm: JournalShareNaviVm = {
        let vm = JournalShareNaviVm.init(frame: .zero)
        vm.closeBlock = {()in
            self.backTapAction()
        }
        return vm
    }()
    lazy var receiptVm: JournalShareReceiptVM = {
        let vm = JournalShareReceiptVM.init(frame: CGRect.init(x: 0, y: self.naviVm.frame.maxY, width: 0, height: 0))
        return vm
    }()
    lazy var topShadowView: UIImageView = {
        let vi = UIImageView()
        vi.setImgLocal(imgName: "journal_share_shadow_view")
        return vi
    }()
    lazy var msgVm: JournalShareMsgVM = {
        let vm = JournalShareMsgVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
//        let vm = JournalShareMsgVM.init(frame: CGRect.init(x: 0, y: self.receiptVm.frame.minY+kFitWidth(13), width: 0, height: 0))
        vm.caloriesVm.updateUI(dict: self.detailsDict)
        vm.naturalVm.updateUI(dict: self.detailsDict)
        vm.nameMsgVm.updateCircleTag(dict: self.detailsDict)
        return vm
    }()
    lazy var dashVm: JournalShareMsgDashVM = {
//        let vm = JournalShareMsgDashVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        let vm = JournalShareMsgDashVM.init(frame: CGRect.init(x: 0, y: self.msgVm.frame.maxY, width: 0, height: 0))
        return vm
    }()
    lazy var headView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: dashVm.frame.maxY))
        vi.backgroundColor = .clear
        vi.addSubview(msgVm)
        vi.addSubview(dashVm)
        return vi
    }()
    lazy var footView: JournalShareFooterVM = {
        let emptyFootHeight = kFitWidth(42)//self.mealsArray.count > 0 ? kFitWidth(42) : (self.tableView.frame.height - dashVm.frame.maxY)
        let vm = JournalShareFooterVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: emptyFootHeight))
        return vm
    }()
    lazy var tableView: UITableView = {
        let originY = self.receiptVm.frame.minY+kFitWidth(13)
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: originY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-kFitWidth(60)-kFitWidth(16)-getBottomSafeAreaHeight()-originY-kFitWidth(40)), style: .grouped)
//        vi.tableHeaderView = headView
        vi.backgroundColor = .clear
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.bounces = false
        vi.sectionFooterHeight = 0
        vi.showsVerticalScrollIndicator = false
        
        vi.register(JournalShareTableViewCell.classForCoder(), forCellReuseIdentifier: "JournalShareTableViewCell")
        return vi
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "-滚动预览用餐食物，保存显示完整清单-"
        lab.textColor = UIColor.init(white: 1, alpha: 0.8)
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        
        return lab
    }()
    lazy var shareVm: JournalShareVM = {
        let vm = JournalShareVM.init(frame: .zero)
        return vm
    }()
    lazy var wechatButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(49), y: SCREEN_HEIGHT-kFitWidth(60)-kFitWidth(16)-getBottomSafeAreaHeight(), width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "plan_share_wechat_icon_white")
        btn.contenLab.text = "微信"
        btn.tapBlock = {()in
            self.shareToSession()
        }
        return btn
    }()
    lazy var circleButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: SCREEN_WIDHT*0.5-kFitWidth(29), y: self.wechatButton.frame.minY, width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "plan_share_circle_icon_white")
        btn.contenLab.text = "朋友圈"
        btn.tapBlock = {()in
            self.shareToTimeLine()
        }
        return btn
    }()
    lazy var saveButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(58)-kFitWidth(49), y: self.wechatButton.frame.minY, width: kFitWidth(58), height: kFitWidth(60)))
        btn.imgView.setImgLocal(imgName: "plan_share_save_icon_white")
        btn.contenLab.text = "保存图片"
        btn.tapBlock = {()in
            self.saveAction()
        }
        return btn
    }()
}

extension JournalShareVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return mealsArray.count+1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }else{
            let dict = mealsArray[section-1] as? NSDictionary ?? [:]
            return (dict["mealFoods"]as? NSArray ?? []).count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalShareTableViewCell") as? JournalShareTableViewCell
        
        let dict = mealsArray[indexPath.section-1] as? NSDictionary ?? [:]
        let foodsArray = dict["mealFoods"]as? NSArray ?? []
        cell?.updateUI(dict: foodsArray[indexPath.row] as? NSDictionary ?? [:])
        
        return cell ?? JournalShareTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return headView
        }else{
            let vi = UIView.init(frame: CGRect.init(x: kFitWidth(0), y: 0, width: SCREEN_WIDHT, height: kFitWidth(34)))
            vi.backgroundColor = .clear
            
            let whiteView = UIView.init(frame: CGRect.init(x: kFitWidth(42), y: 0, width: SCREEN_WIDHT-kFitWidth(84), height: kFitWidth(34)))
            whiteView.backgroundColor = .white
            vi.addSubview(whiteView)
            
            let dict = mealsArray[section-1] as? NSDictionary ?? [:]
            let label = UILabel.init(frame: CGRect.init(x: kFitWidth(20), y: 0, width: kFitWidth(200), height: kFitHeight(34)))
            label.text = dict.stringValueForKey(key: "mealName")
            label.textColor = .COLOR_TEXT_TITLE_0f1214
            label.font = .systemFont(ofSize: 14, weight: .semibold)
            whiteView.addSubview(label)
            
            return vi
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return dashVm.frame.maxY
        }else{
            return kFitWidth(34)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == mealsArray.count{
            return footView.selfHeight
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == mealsArray.count{
            return footView
        }
        return nil
    }
}

extension JournalShareVC{
    func initUI() {
        view.backgroundColor = .THEME
        view.addSubview(naviVm)
        view.addSubview(receiptVm)
        
        view.addSubview(tableView)
        view.addSubview(topShadowView)
//        view.addSubview(msgVm)
//        view.addSubview(dashVm)
        
        view.addSubview(tipsLabel)
        
        view.addSubview(wechatButton)
        view.addSubview(circleButton)
        view.addSubview(saveButton)
        
        view.addSubview(shareVm)
        dealDateString()
        
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(tableView.snp.bottom).offset(kFitWidth(10))
        }
        topShadowView.snp.makeConstraints { make in
//            make.left.top.width.equalToSuperview()
            make.top.equalTo(self.receiptVm.snp.top).offset(kFitWidth(13))
            make.left.equalTo(kFitWidth(42))
            make.right.equalTo(kFitWidth(-42))
            make.height.equalTo(kFitWidth(12))
        }
//        topShadowView.addShadow()
    }
}

extension JournalShareVC{
    func dealDataSource() {
        let dataArray = detailsDict["foods"]as? NSArray ?? []
        for i in 0..<dataArray.count{
            let arr = dataArray[i]as? NSArray ?? []
            if arr.count > 0 {
                let foodsArray = NSMutableArray()
                for j in 0..<arr.count{
                    let foodsDict = arr[j]as? NSDictionary ?? [:]
                    if foodsDict.stringValueForKey(key: "state") == "1"{
                        foodsArray.add(foodsDict)
                    }
                }
                
                if foodsArray.count > 0 {
                    self.mealsArray.add(["mealName":"第 \(i+1) 餐",
                                         "mealFoods":foodsArray])
                }
            }
        }
        
        self.tableView.reloadData()
        shareVm.updateMealsArray(arr: self.mealsArray)
        shareVm.updateMsg(dict: self.detailsDict)
//        shareVm.dateLabel.text = dayString
    }
    func dealDateString(){
        let dateString = Date().changeDateFormatter(dateString: dayString, formatter: "yyyy-MM-dd", targetFormatter: "M月d日 yyyy年")
        
        let dateArr = dateString.components(separatedBy: " ")
        let weekDay = getWeekDaysText(date: Date().changeDateStringToDate(dateString: dayString))
        
        var dayString = dateString
        if dateArr.count > 1 {
            dayString = "\(dateArr[0])\(weekDay)·\(dateArr[1])"
        }
//        shareVm.dateLabel.setLineSpace(lineSpcae: kFitWidth(8), textString: dayString)
        shareVm.dateLabel.setCharacterSpacing(kFitWidth(4), text: dayString)
    }
    
    private func getWeekDaysText(date:Date) -> String{
        let weekIndex = Date().getWeekdayIndex(from: date)
//        DLLog(message: "weekIndex:  --- \(weekIndex)")
        if weekIndex == 1 {
            return "周一"
        }else if weekIndex == 2 {
            return "周二"
        }else if weekIndex == 3 {
            return "周三"
        }else if weekIndex == 4 {
            return "周四"
        }else if weekIndex == 5 {
            return "周五"
        }else if weekIndex == 6 {
            return "周六"
        }else{
            return "周日"
        }
    }
}

extension JournalShareVC{
    @objc func shareToSession(){
        let image = self.shareVm.mc_makeImage()
        
        let message = WXMediaMessage()
        message.setThumbImage(UIImage.init(named: "avatar_default")!)
        message.title = "标题"
        message.description = "描述"
        
        let obj = WXImageObject()
        
        // 将UIImage转换为PNG格式的Data
        if let pngData = image.pngData() {
            // 使用pngData
            print("转换成PNG格式的数据成功，数据长度：\(pngData.count)")
            obj.imageData = pngData
            
        } else {
            print("转换成PNG格式的数据失败")
        }
        
        message.mediaObject = obj
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(WXSceneSession.rawValue)
        WXApi.send(req)
    }
    @objc func shareToTimeLine(){
        let image = self.shareVm.mc_makeImage()
        
        let message = WXMediaMessage()
        message.setThumbImage(UIImage.init(named: "avatar_default")!)
        message.title = "标题"
        message.description = "描述"
        
        let obj = WXImageObject()
        
        // 将UIImage转换为PNG格式的Data
        if let pngData = image.pngData() {
            // 使用pngData
            print("转换成PNG格式的数据成功，数据长度：\(pngData.count)")
            obj.imageData = pngData
            
        } else {
            print("转换成PNG格式的数据失败")
        }
        
        message.mediaObject = obj
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(WXSceneTimeline.rawValue)
        WXApi.send(req)
    }
    @objc func saveAction() {
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
                    MCToast.mc_loading(duration: 30)
                    let image = self.shareVm.mc_makeImage()
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
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
