//
//  SportVC.swift
//  lns
//  计算公式： Calories Burned = Time(in minutes) × MET × Body Weight (kg) ÷ 200
//  Created by Elavatine on 2024/11/22.
//

import IQKeyboardManagerSwift
import HealthKit

class SportVC: WHBaseViewVC {
    
    var dataSourceArray = NSMutableArray()
    
    var isCanAdd = false
    var isFirst = true
    
    //动画播放时间
    var duration:CFTimeInterval = 3
    // 使用示例
    let healthManager = HealthKitManager()
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
        sendCatogaryListRequest()
        sendSportListRequest()
    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        IQKeyboardManager.shared.enable = true
//        
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        let sportData = UserDefaults.getSportData()
        dealDataSource(dataArray: sportData)
        sendSportListRequest()
        let panGes = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(popGestureAction(gesture: )))
        panGes.edges = .left
        view.addGestureRecognizer(panGes)
    }
    lazy var timeButton : GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: kFitWidth(80), y: statusBarHeight, width: kFitWidth(215), height: kFitWidth(44)))
        
        btn.setTitleColor(WHColor_16(colorStr: "222222"), for: .normal)
//        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(timeTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var addButton: SportAddListButton = {
        let btn = SportAddListButton.init(frame: .zero)
        btn.tapBlock = {()in
            let vc = SportHistoryVC()
            vc.dateString = "\(self.dateFilterAlertVm.dateStringYear)"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return btn
    }()
    lazy var leftCatogaryVm: SportCatogaryVM = {
        let vm = SportCatogaryVM.init(frame: .zero)
        vm.tapBlock = {(model)in
            self.categoryHeadVm.updateUI(model: model)
            self.square.setImgUrl(urlString: model.icon)
//            self.itemVm.dataSourceArray = self.dataSourceArray[self.leftCatogaryVm.selectIndex] as! [SportCatogaryItemModel]
            let items = self.dataSourceArray[self.leftCatogaryVm.selectIndex] as! [SportCatogaryItemModel]
            self.itemVm.isRecently = self.leftCatogaryVm.selectIndex == 0
            self.itemVm.canEdit = self.leftCatogaryVm.selectIndex == self.dataSourceArray.count - 1
            self.itemVm.canDelete = (self.leftCatogaryVm.selectIndex == self.dataSourceArray.count - 1 || self.leftCatogaryVm.selectIndex == 0)
//            self.itemVm.tableView.reloadData()
            self.updateItemVm(models: items)
        }
        return vm
    }()
    lazy var categoryHeadVm: SportListHeadVM = {
        let vm = SportListHeadVM.init(frame: .zero)
        vm.addButton.addTarget(self, action: #selector(addCustomAction), for: .touchUpInside)
        vm.tipsButton.addTarget(self, action: #selector(tipsTapAction), for: .touchUpInside)
        return vm
    }()
    lazy var itemVm: SportCatogaryItemVM = {
        let vm = SportCatogaryItemVM.init(frame: .zero)
        vm.tapBlock = {(model)in
            self.addAlertVm.updateUI(sModel: model)
            self.addAlertVm.showSelf()
        }
        vm.editBlock = {(model)in
            let vc = SportCustomVC()
            vc.model = model
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.delBlock = {(model)in
            var arrTemp = self.itemVm.dataSourceArray
            self.dataSourceArray[self.leftCatogaryVm.selectIndex] = arrTemp
        }
        return vm
    }()
    lazy var dateFilterAlertVm : DataAddDateAlertVM = {
        let vm = DataAddDateAlertVM.init(frame: .zero)
        vm.datePicker.maximumDate = Date().getLastYearsAgo(lastYears: 3)
        vm.confirmBlock = {(weekDay)in
            self.setTime(time: weekDay)
            self.sendSportListRequest()
        }
        return vm
    }()
    lazy var addAlertVm: SportAddAlertVM = {
        let vm = SportAddAlertVM.init(frame: .zero)
        vm.confirmBlock = {()in
            self.sendAddSportRequest()
        }
        return vm
    }()
    lazy var tipsAlertVm : QuestionnairePlanTipsAlertVM = {
        let vm = QuestionnairePlanTipsAlertVM.init(frame: .zero)
        vm.titleLabel.text = "运动净消耗"
        vm.contentLabel.attributedText = TutorialAttr.shared.sportMetsTipsAttr
        
        return vm
    }()
    //运动的方块
    lazy var square : UIImageView = {
        let square = UIImageView()
        square.setImgLocal(imgName: "sport_add_icon")
        square.frame = CGRect(x: -23, y: -23, width: kFitWidth(44), height: kFitWidth(44))
        square.backgroundColor = .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT
        square.clipsToBounds = true
        square.layer.cornerRadius = kFitWidth(22)
        self.view.addSubview(square)
        square.isHidden = true
        return square
    }()
}

extension SportVC{
    @objc func timeTapAction() {
        self.dateFilterAlertVm.showView()
    }
    @objc func tipsTapAction() {
        self.tipsAlertVm.showView()
    }
    @objc func addCustomAction() {
        TouchGenerator.shared.touchGeneratorMedium()
        let vc = SportCustomVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func dealDataSource(dataArray:NSArray) {
        if dataArray.count == 0 {
            return
        }
        dataSourceArray.removeAllObjects()
        var menuArray:[SportCatogaryModel] = [SportCatogaryModel]()
        
        for i in 0..<dataArray.count{
            let dict = dataArray[i]as? NSDictionary ?? [:]
            
            let catoModel = SportCatogaryModel().dealDictForModel(dict: dict["menu"]as? NSDictionary ?? [:])
            menuArray.append(catoModel)
            
            if i == self.leftCatogaryVm.selectIndex{
                categoryHeadVm.updateUI(model: catoModel)
                square.setImgUrl(urlString: catoModel.icon)
            }
            
            let items = dict["item"]as? NSArray ?? []
            var itemArray:[SportCatogaryItemModel] = [SportCatogaryItemModel]()
            for j in 0..<items.count{
                let itemModel = SportCatogaryItemModel().dealDictForModel(dict: items[j]as? NSDictionary ?? [:])
                itemArray.append(itemModel)
            }
            dataSourceArray.add(itemArray)
        }
        
        self.leftCatogaryVm.dataSourceArray = menuArray
//        self.leftCatogaryVm.tableView.alpha = 0
        self.leftCatogaryVm.tableView.reloadData()
//        UIView.animate(withDuration: 0.15, animations: {
//            self.leftCatogaryVm.tableView.alpha = 1
//        })
        
//        self.itemVm.dataSourceArray = dataSourceArray[self.leftCatogaryVm.selectIndex] as! [SportCatogaryItemModel]
        let items = dataSourceArray[self.leftCatogaryVm.selectIndex] as! [SportCatogaryItemModel]
        self.itemVm.isRecently = self.leftCatogaryVm.selectIndex == 0
        self.itemVm.canEdit = self.leftCatogaryVm.selectIndex == self.dataSourceArray.count - 1
        self.itemVm.canDelete = (self.leftCatogaryVm.selectIndex == self.dataSourceArray.count - 1 || self.leftCatogaryVm.selectIndex == 0)
//        self.itemVm.tableView.reloadData()
        self.updateItemVm(models: items)
    }
    func updateItemVm(models:[SportCatogaryItemModel]) {
        UIView.transition(with: self.itemVm.tableView, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.itemVm.dataSourceArray = models
            self.itemVm.tableView.reloadData()
        }, completion: nil)
    }
    @objc func popGestureAction(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .ended:
            if self.isCanAdd {
                self.navigationController?.popToRootViewController(animated: true)
            }else{
                self.backTapAction()
            }
            break
        default:
            break
        }
    }
}

extension SportVC{
    func initUI() {
        view.backgroundColor = .white
        view.addSubview(backArrowButton)
        view.addSubview(timeButton)
        view.addSubview(addButton)
        view.addSubview(leftCatogaryVm)
        view.addSubview(categoryHeadVm)
        view.addSubview(itemVm)
        
        view.addSubview(dateFilterAlertVm)
        view.addSubview(addAlertVm)
        view.addSubview(tipsAlertVm)
        setTime(time: dateFilterAlertVm.weekDay)
        
        
        backArrowButton.tapBlock = {()in
            if self.isCanAdd {
                self.navigationController?.popToRootViewController(animated: true)
            }else{
                self.backTapAction()
            }
        }
    }
    func setTime(time:String) {
        timeButton.setTitle("\(time)", for: .normal)
        timeButton.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        timeButton.imagePosition(style: .right, spacing: kFitWidth(5))
    }
    func saveDataToHealthAPP(param:NSDictionary,type:HKWorkoutActivityType) {
        var prancerciseWorkout = PrancerciseWorkout(calories: "\(param["calories"]as? String ?? "0")")
        prancerciseWorkout.duration = "\(self.addAlertVm.minute)"
        prancerciseWorkout.end = Date()
        prancerciseWorkout.getStartDate()
        healthManager.saveRunningDataToHealthKitApp(workoutType: type, prancerciseWorkout: prancerciseWorkout)
    }
}

extension SportVC{
    func sendCatogaryListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_sport_catogary_list, parameters: nil) { responseObject in
            DLLog(message: responseObject)
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = self.getArrayFromJSONString(jsonString: dataString ?? "")
            
            UserDefaults.set(value: self.getJSONStringFromArray(array: dataArray), forKey: .sportData)
            
            DLLog(message: "\(dataArray)")
            self.dealDataSource(dataArray: dataArray)
        }
    }
    func sendDelSportRecentlyRequest(id:String) {
        let param = ["id":"\(id)"]
        DLLog(message: "sendDelSportRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_sport_recently_delete, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "sendDelSportRequest:\(responseObject)")
            self.itemVm.tableView.setEditing(false, animated: false)
            self.sendCatogaryListRequest()
        }
    }
    func sendDelSportRequest(id:String) {
        let param = ["id":"\(id)"]
        DLLog(message: "sendDelSportRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_sport_catogary_delete, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "sendDelSportRequest:\(responseObject)")
            self.itemVm.tableView.setEditing(false, animated: false)
            self.sendCatogaryListRequest()
        }
    }
    func sendAddSportRequest() {
        let param = ["sdate":"\(self.dateFilterAlertVm.dateStringYear)",
                     "sportItemId":"\(self.addAlertVm.model.id)",
                     "sportItemName":"\(self.addAlertVm.model.name)",
//                     "sportCaloriesInTarget":UserInfoModel.shared.statSportDataToTarget,
                     "duration":"\(self.addAlertVm.minute)".replacingOccurrences(of: ",", with: "."),
                     "weight":"\(self.addAlertVm.weight)".replacingOccurrences(of: ",", with: "."),
//                     "calories":WHUtils.convertStringToString("\(self.addAlertVm.calories)".replacingOccurrences(of: ",", with: "."))]
                    "calories":"\(WHUtils.convertStringToString("\(self.addAlertVm.calories)") ?? "")".replacingOccurrences(of: ",", with: ".")]
        DLLog(message: "sendAddSportRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_sport_add, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "sendAddSportRequest:\(responseObject)")
            
            self.addAnimation(rect: self.itemVm.selectRect)
            
            self.sendSportListRequest()
            self.sendCatogaryListRequest()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
            WidgetUtils().reloadWidgetData()
            self.healthManager.authorizeHealthKitWorkouts { success, error in
                if success {
                    self.saveDataToHealthAPP(param: param as NSDictionary, type: self.addAlertVm.model.workType)
                }
            }
        }
    }
    
    func sendSportListRequest() {
        let param = ["sdate":"\(self.dateFilterAlertVm.dateStringYear)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_sport_list, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = self.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendSportListRequest:\(dataArray)")
            self.addButton.updateUI(number: "\(dataArray.count)")
            
            SportDataSQLiteManager.getInstance().updateSportsData(ctime: self.dateFilterAlertVm.dateStringYear, sportsData: self.getJSONStringFromArray(array: dataArray))
        }
    }
}
extension SportVC: CAAnimationDelegate {
    func addAnimation(rect : CGRect) {
        let y = rect.origin.y + self.getNavigationBarHeight()
        
        self.square.isHidden = false
        let path =  CGMutablePath()
        // 移动到原点
        path.move(to: CGPoint.init(x:rect.width*0.5,y:y+kFitWidth(20)))
        // to：移动的终点，control： 控制点
        path.addQuadCurve(to: CGPoint.init(x: SCREEN_WIDHT-addButton.frame.width*0.5, y: addButton.frame.midY), control: CGPoint(x: addButton.frame.minX-kFitWidth(100), y:  addButton.frame.minY-getNavigationBarHeight()-statusBarHeight))
        
        //获取贝塞尔曲线的路径
        let animationPath = CAKeyframeAnimation.init(keyPath: "position")
        animationPath.path = path
        animationPath.rotationMode = CAAnimationRotationMode.rotateAuto
        
        //缩小图片到 0.5
        let scale:CABasicAnimation = CABasicAnimation()
        scale.keyPath = "transform.scale"
        scale.toValue = 0.5
        
        //组合动画
        let animationGroup:CAAnimationGroup = CAAnimationGroup()
        animationGroup.animations = [animationPath,scale]
        animationGroup.duration = 0.7
        animationGroup.delegate = self
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        animationGroup.isRemovedOnCompletion = true
        square.layer.add(animationGroup, forKey:
            nil)
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.square.isHidden = true
    }
}
