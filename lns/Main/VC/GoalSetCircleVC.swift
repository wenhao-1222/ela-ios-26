//
//  GoalSetCircleVC.swift
//  lns
//
//  Created by Elavatine on 2025/6/17.
//

import Foundation
import IQKeyboardManagerSwift
import MCToast

class GoalSetCircleVC: WHBaseViewVC {
    
    var goalsDataArray = NSMutableArray()
    var goalsCircleDataArray = NSMutableArray()
    var dataChangeBlock:((NSArray)->())?
    var goalType = "circle" // circle  碳循环  week  周
    
    var dataChange = false
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.fd_interactivePopDisabled = true
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        self.navigationController?.fd_interactivePopDisabled = false
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        var isSetData = true
        if self.goalsDataArray.count == 0 {
            isSetData = false
            let msgString = UserDefaults.getString(forKey: .nutritionDefaultArray) ?? ""
            if msgString.count > 0 {
                let msgArray = NSMutableArray.init(array: WHUtils.getArrayFromJSONString(jsonString: msgString))
                self.goalsDataArray = NSMutableArray(array: msgArray)
                self.centerVm.goalsDataArray = self.goalsDataArray
                self.centerVm.updateWeeksDayData()
            }else{
                let msgStr = UserDefaults.getString(forKey: .nutritionDefault) ?? ""
                let dict = WHUtils.getDictionaryFromJSONString(jsonString: msgStr)
                
                for _ in 0..<7{
                    self.goalsDataArray.add(dict)
                }
                self.centerVm.goalsDataArray = self.goalsDataArray
                self.centerVm.updateWeeksDayData()
                
                sendNutritionsDefaultRequest()
            }
        }
        self.goalsCircleDataArray = NSMutableArray(array: self.goalsDataArray)
//        self.customCircleVm.goalsDataArray = self.goalsCircleDataArray
        self.customCircleVm.updateGoalsDataArray(self.goalsCircleDataArray)
        self.customCircleVm.updateWeeksDayData(isInit: true)
        if isSetData == false{
            sendNutritionsDefaultCircleRequest()
        }
        
        enableInteractivePopGesture()
        let panGes = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(popGestureAction(gesture: )))
        panGes.edges = .left
        view.addGestureRecognizer(panGes)
    }
    lazy var centerVm: GoalSetWeeksCenterVM = {
        let vm = GoalSetWeeksCenterVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: 0, height: 0))
        vm.controller = self
        vm.isHidden = true
        vm.carboItemVm.percentBlock = {()in
            self.showAlert(type: .percent, natural: .carbo)
        }
        vm.carboItemVm.numberBlock = {()in
            self.showAlert(type: .number, natural: .carbo)
        }
        vm.proteinItemVm.percentBlock = {()in
            self.showAlert(type: .percent, natural: .protein)
        }
        vm.proteinItemVm.numberBlock = {()in
            self.showAlert(type: .number, natural: .protein)
        }
        vm.fatItemVm.percentBlock = {()in
            self.showAlert(type: .percent, natural: .fat)
        }
        vm.fatItemVm.numberBlock = {()in
            self.showAlert(type: .number, natural: .fat)
        }
        vm.changeItemBlock = {(dict)in
            DLLog(message: "changeItemBlock:\(dict)")
            self.alertVm.updateData(dict: dict)
        }
        vm.changeCircleTypeBlock = {()in
            self.centerVm.isHidden = true
            self.customCircleVm.isHidden = false
            self.goalType = "circle"
        }
        vm.tipsVm.caloriesTapBlock = {()in
            self.showAlert(type: .percent, natural: .carbo)
        }
        return vm
    }()
    lazy var customCircleVm: GoalCircleVM = {
        let vm = GoalCircleVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: 0, height: 0))
        vm.changeTypeButton.isHidden = true
        vm.carboItemVm.percentBlock = {()in
            self.showAlertCircle(type: .percent, natural: .carbo)
        }
        vm.carboItemVm.numberBlock = {()in
            self.showAlertCircle(type: .number, natural: .carbo)
        }
        vm.proteinItemVm.percentBlock = {()in
            self.showAlertCircle(type: .percent, natural: .protein)
        }
        vm.proteinItemVm.numberBlock = {()in
            self.showAlertCircle(type: .number, natural: .protein)
        }
        vm.fatItemVm.percentBlock = {()in
            self.showAlertCircle(type: .percent, natural: .fat)
        }
        vm.fatItemVm.numberBlock = {()in
            self.showAlertCircle(type: .number, natural: .fat)
        }
        vm.changeItemBlock = {(dict)in
            DLLog(message: "changeItemBlock:\(dict)")
            self.alertCircleVm.updateData(dict: dict)
        }
        vm.tipsVm.caloriesTapBlock = {()in
            self.showAlertCircle(type: .percent, natural: .calories)
        }
        vm.changeCircleTypeBlock = {()in
            self.centerVm.isHidden = false
            self.customCircleVm.isHidden = true
            self.goalType = "week"
        }
        vm.dataChangeBlock = {()in
            self.dataChange = true
        }
        return vm
    }()
    lazy var alertVm: GoalSetWeeksAlertVM = {
        let vm = GoalSetWeeksAlertVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.controller = self
        vm.topVm.confirmBlock = {()in
//            if self.goalType == "week"{
                self.submitAction()
//            }else{
//                self.submitActionForCircle()
//            }
        }
        return vm
    }()
    lazy var alertCircleVm: GoalSetWeeksAlertVM = {
        let vm = GoalSetWeeksAlertVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.controller = self
        vm.topVm.confirmBlock = {()in
//            if self.goalType == "week"{
//                self.submitAction()
//            }else{
                self.submitActionForCircle()
//            }
        }
        return vm
    }()
    lazy var bottomView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: self.customCircleVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.customCircleVm.frame.maxY))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var previewButton: UIButton = {
        let btn = UIButton()
        
        btn.setTitle("预览目标", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT, for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .white), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .WIDGET_COLOR_GRAY_BLACK_06), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(4)
        btn.clipsToBounds = true
        btn.layer.borderColor = UIColor.THEME.cgColor
        btn.layer.borderWidth = kFitWidth(1)
        
        btn.addTarget(self, action: #selector(previewAction), for: .touchUpInside)
        btn.enablePressEffect()
        
        return btn
    }()
    lazy var nextBtn : UIButton = {
        let btn = UIButton()
//        btn.frame = CGRect.init(x: kFitWidth(16), y: self.centerVm.frame.maxY + kFitWidth(40), width: kFitWidth(288), height: kFitWidth(48))
        btn.setTitle("保存目标", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME, for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .disabled)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.layer.cornerRadius = kFitWidth(4)
        btn.clipsToBounds = true
        
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        btn.enablePressEffect()
        
        return btn
    }()
    lazy var previewAlertVm: GoalSetPreviewAlertVM = {
        let vm = GoalSetPreviewAlertVM.init(frame: .zero)
        vm.saveBtn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return vm
    }()
}

extension GoalSetCircleVC{
    func showAlert(type:alertType,natural:naturalType) {
        switch type{
        case .percent:
            self.alertVm.topVm.typeVm.perTapAction()
            self.alertVm.showSelf()
        case .number:
            self.alertVm.topVm.typeVm.gTapAction()
            self.alertVm.showSelf()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                switch natural {
                case .carbo:
                    self.alertVm.specGVm.carVm.textField.becomeFirstResponder()
                case .protein:
                    self.alertVm.specGVm.proteinVm.textField.becomeFirstResponder()
                case .fat:
                    self.alertVm.specGVm.fatVm.textField.becomeFirstResponder()
                case .calories:
                    break
                }
            })
        }
    }
    func showAlertCircle(type:alertType,natural:naturalType) {
        switch type{
        case .percent:
            self.alertCircleVm.topVm.typeVm.perTapAction()
            self.alertCircleVm.showSelf()
            if natural == .calories{
                self.alertCircleVm.caloriesVm.numberLabel.becomeFirstResponder()
            }
        case .number:
            self.alertCircleVm.topVm.typeVm.gTapAction()
            self.alertCircleVm.showSelf()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                switch natural {
                case .carbo:
                    self.alertCircleVm.specGVm.carVm.textField.becomeFirstResponder()
                case .protein:
                    self.alertCircleVm.specGVm.proteinVm.textField.becomeFirstResponder()
                case .fat:
                    self.alertCircleVm.specGVm.fatVm.textField.becomeFirstResponder()
                case .calories:
                    break
                }
            })
        }
    }
    
    @objc func previewAction() {
        let array = NSMutableArray()
        if self.goalType == "week"{
            for i in 0..<self.goalsDataArray.count{
                let dict = self.goalsDataArray[i]as? NSDictionary ?? [:]
                let param = NSMutableDictionary()
                param.setValue("\(i + 1)", forKey: "weekday")
                param.setValue("\(Int(dict.doubleValueForKey(key: "calories")))", forKey: "calories")
                param.setValue("\(Int(dict.doubleValueForKey(key: "proteins")))", forKey: "proteins")
                param.setValue("\(Int(dict.doubleValueForKey(key: "carbohydrates")))", forKey: "carbohydrates")
                param.setValue("\(Int(dict.doubleValueForKey(key: "fats")))", forKey: "fats")
                
                array.add(param)
            }
        }else{
            for i in 0..<self.customCircleVm.goalsDataArray.count{
                let dict = self.customCircleVm.goalsDataArray[i]as? NSDictionary ?? [:]
                let param = NSMutableDictionary()
                param.setValue("\(i + 1)", forKey: "sn")
                param.setValue("\(Int(dict.doubleValueForKey(key: "calories")))", forKey: "calories")
                param.setValue("\(Int(dict.doubleValueForKey(key: "proteins")))", forKey: "proteins")
                param.setValue("\(Int(dict.doubleValueForKey(key: "carbohydrates")))", forKey: "carbohydrates")
                param.setValue("\(Int(dict.doubleValueForKey(key: "fats")))", forKey: "fats")
                
                array.add(param)
            }
        }
//        self.previewAlertVm.updateGoalData(goalArray: array,todayIndex: self.customCircleVm.todayIndex)
        self.previewAlertVm.updateGoalCircleData(goalArray: array, todayIndex: self.customCircleVm.todayIndex)
        self.previewAlertVm.showSelf()
    }
    @objc func saveAction() {
        self.previewAlertVm.hiddenView()
        self.presentAlertVc(confirmBtn: "保存目标", message: "", title: "保存目标会重新设置\n今日往后的营养目标", cancelBtn: "取消", handler: { action in
            if self.goalType == "week"{
                let array = NSMutableArray()
                for i in 0..<self.goalsDataArray.count{
                    let dict = self.goalsDataArray[i]as? NSDictionary ?? [:]
                    let param = NSMutableDictionary()
                    param.setValue("\(i + 1)", forKey: "weekday")
                    param.setValue("\(Int(dict.doubleValueForKey(key: "calories")))", forKey: "calories")
                    param.setValue("\(Int(dict.doubleValueForKey(key: "proteins")))", forKey: "proteins")
                    param.setValue("\(Int(dict.doubleValueForKey(key: "carbohydrates")))", forKey: "carbohydrates")
                    param.setValue("\(Int(dict.doubleValueForKey(key: "fats")))", forKey: "fats")
                    
                    array.add(param)
                }
                self.sendSaveWeekGoalRequest(weeks: array)
            }else{
                let array = NSMutableArray()
                for i in 0..<self.customCircleVm.goalsDataArray.count{
                    if i < self.customCircleVm.daysNumber{
                        let dict = self.customCircleVm.goalsDataArray[i]as? NSDictionary ?? [:]
                        let param = NSMutableDictionary()
                        param.setValue("\(i + 1)", forKey: "sn")
    //                    param.setValue("", forKey: "carbLabel")
                        param.setValue("\(Int(dict.doubleValueForKey(key: "calories")))", forKey: "calories")
                        param.setValue("\(Int(dict.doubleValueForKey(key: "proteins")))", forKey: "proteins")
                        param.setValue("\(Int(dict.doubleValueForKey(key: "carbohydrates")))", forKey: "carbohydrates")
                        param.setValue("\(Int(dict.doubleValueForKey(key: "fats")))", forKey: "fats")
                        
                        if i < self.customCircleVm.circleTagsArray.count{
                            param.setValue(self.customCircleVm.circleTagsArray[i], forKey: "carbLabel")
                        }
                        
                        array.add(param)
                    }
                }
                self.sendSaveCircleGoalRequest(goalsArray: array)
            }
        }, viewController: self)
    }
    func submitAction() {
        var dict = NSDictionary()
        if self.alertVm.topVm.typeVm.type == "g"{
            dict = ["calories":"\(self.alertVm.specGVm.caloriesNumber)",
                        "proteins":"\(self.alertVm.specGVm.proteinNumber)",
                        "carbohydrates":"\(self.alertVm.specGVm.carNumber)",
                        "fats":"\(self.alertVm.specGVm.fatNumber)"]
        }else{
            let totalPercent = self.alertVm.specPercentVm.carboPercent + self.alertVm.specPercentVm.proteinPercent + self.alertVm.specPercentVm.fatPercent
            
            if totalPercent != 100{
                MCToast.mc_text("营养素必须等于100%",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
                return
            }
            
            dict = ["calories":"\(self.alertVm.specPercentVm.caloriesNumber)",
                        "proteins":"\(self.alertVm.specPercentVm.proteinNumber)",
                        "carbohydrates":"\(self.alertVm.specPercentVm.carNumber)",
                        "fats":"\(self.alertVm.specPercentVm.fatNumber)"]
        }
        if (dict.stringValueForKey(key: "carbohydrates") == "0" || dict.stringValueForKey(key: "carbohydrates") == "") &&
        (dict.stringValueForKey(key: "proteins") == "0" || dict.stringValueForKey(key: "proteins") == "") &&
        (dict.stringValueForKey(key: "fats") == "0" || dict.stringValueForKey(key: "fats") == ""){
            MCToast.mc_text("请输入营养素数值",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        if dict.doubleValueForKey(key: "carbohydrates") <= 4999 {
            //Int(QuestinonaireMsgModel.shared.carbohydrates) ?? 0 >= 0 &&
        }else{
            MCToast.mc_text("碳水化合物目标数值范围 0 ~ 4999 g",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        if dict.doubleValueForKey(key: "proteins") <= 4999 {
            //Int(QuestinonaireMsgModel.shared.protein) ?? 0 >= 1 &&
        }else{
            MCToast.mc_text("蛋白质目标数值范围 0 ~ 4999 g",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        if dict.doubleValueForKey(key: "fats") <= 4999 {
            //Int(QuestinonaireMsgModel.shared.fats) ?? 0 >= 1 &&
        }else{
            MCToast.mc_text("脂肪目标数值范围 0 ~ 4999 g",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        self.alertVm.hiddenView()
        self.alertVm.msgDict = dict
        self.goalsDataArray.replaceObject(at: self.centerVm.currentIndex, with: dict)
        self.centerVm.goalsDataArray = self.goalsDataArray
        self.centerVm.updateWeeksDayData()
        self.dataChange = true
        if self.dataChangeBlock != nil{
            self.dataChangeBlock!(self.goalsDataArray)
        }
    }
    func submitActionForCircle() {
        var dict = NSDictionary()
        if self.alertCircleVm.topVm.typeVm.type == "g"{
            dict = ["calories":"\(self.alertCircleVm.specGVm.caloriesNumber)",
                    "proteins":"\(self.alertCircleVm.specGVm.proteinNumber)",
                    "carbohydrates":"\(self.alertCircleVm.specGVm.carNumber)",
                    "fats":"\(self.alertCircleVm.specGVm.fatNumber)"]
        }else{
            let totalPercent = self.alertCircleVm.specPercentVm.carboPercent + self.alertCircleVm.specPercentVm.proteinPercent + self.alertCircleVm.specPercentVm.fatPercent
            
            if totalPercent != 100{
                MCToast.mc_text("营养素必须等于100%",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
                return
            }
            
            dict = ["calories":"\(self.alertCircleVm.specPercentVm.caloriesNumber)",
                        "proteins":"\(self.alertCircleVm.specPercentVm.proteinNumber)",
                        "carbohydrates":"\(self.alertCircleVm.specPercentVm.carNumber)",
                        "fats":"\(self.alertCircleVm.specPercentVm.fatNumber)"]
        }
        if (dict.stringValueForKey(key: "carbohydrates") == "0" || dict.stringValueForKey(key: "carbohydrates") == "") &&
        (dict.stringValueForKey(key: "proteins") == "0" || dict.stringValueForKey(key: "proteins") == "") &&
        (dict.stringValueForKey(key: "fats") == "0" || dict.stringValueForKey(key: "fats") == ""){
            MCToast.mc_text("请输入营养素数值",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        if dict.doubleValueForKey(key: "carbohydrates") <= 4999 {
            //Int(QuestinonaireMsgModel.shared.carbohydrates) ?? 0 >= 0 &&
        }else{
            MCToast.mc_text("碳水化合物目标数值范围 0 ~ 4999 g",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        if dict.doubleValueForKey(key: "proteins") <= 4999 {
            //Int(QuestinonaireMsgModel.shared.protein) ?? 0 >= 1 &&
        }else{
            MCToast.mc_text("蛋白质目标数值范围 0 ~ 4999 g",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        if dict.doubleValueForKey(key: "fats") <= 4999 {
            //Int(QuestinonaireMsgModel.shared.fats) ?? 0 >= 1 &&
        }else{
            MCToast.mc_text("脂肪目标数值范围 0 ~ 4999 g",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
//        let oldDict = self.customCircleVm.goalsDataArray[self.customCircleVm.currentIndex]as? NSDictionary ?? [:]
        
        guard self.customCircleVm.currentIndex >= 0,
              self.customCircleVm.currentIndex < self.customCircleVm.goalsDataArray.count,
              self.customCircleVm.currentIndex < self.goalsCircleDataArray.count else {
            DLLog(message: "submitActionForCircle index out of range")
            return
        }

        let oldDict = self.customCircleVm.goalsDataArray[self.customCircleVm.currentIndex] as? NSDictionary ?? [:]
        let newDict = NSMutableDictionary(dictionary: dict)
        
        newDict.setValue(oldDict.stringValueForKey(key: "carbLabel"), forKey: "carbLabel")
//        newDict.setValue(oldDict.stringValueForKey(key: "cc_label"), forKey: "cc_label")
        
        self.alertCircleVm.hiddenView()
        self.alertCircleVm.msgDict = newDict//dict
        self.goalsCircleDataArray.replaceObject(at: self.customCircleVm.currentIndex, with: newDict)
//        self.customCircleVm.goalsDataArray = self.goalsCircleDataArray
        self.customCircleVm.updateGoalsDataArray(self.goalsCircleDataArray)
//        self.goalsCircleDataArray.replaceObject(at: self.customCircleVm.currentIndex, with: dict)
//        self.customCircleVm.goalsDataArray = self.goalsCircleDataArray
        self.customCircleVm.updateWeeksDayData()
        self.dataChange = true
    }
    @objc func popGestureAction(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .ended:
            self.backAction()
            break
        default:
            break
        }
    }
    func backAction() {
        if self.dataChange {
//            self.presentAlertVc(confirmBtn: "返回，不保存", message: "返回页面后，当前页面设置的循环目标不会保存。", title: "温馨提示", cancelBtn: "不返回", handler: { action in
//                self.backTapAction()
//            }, viewController: self)
            self.presentAlertVc(confirmBtn: "返回", message: "", title: "您的修改尚未保存\n确定要返回吗？", cancelBtn: "继续编辑", handler: { action in
                self.backTapAction()
            }, viewController: self)
        }else{
            self.backTapAction()
        }
    }
}

extension GoalSetCircleVC{
    func initUI() {
        initNavi(titleStr: "设定目标")
        self.view.backgroundColor = .white
        self.navigationView.backgroundColor = .clear
        self.backArrowButton.tapBlock = {()in
            self.backAction()
        }
        
        view.addSubview(centerVm)
        view.addSubview(customCircleVm)
        
        view.addSubview(bottomView)
        view.addSubview(previewButton)
        view.addSubview(nextBtn)

        if self.goalsDataArray.count == 0 {
            let msgString = UserDefaults.getString(forKey: .nutritionDefaultArray) ?? ""
            if msgString.count > 0 {
                let msgArray = NSMutableArray.init(array: WHUtils.getArrayFromJSONString(jsonString: msgString))
                self.centerVm.goalsDataArray = NSMutableArray(array: msgArray)
                self.centerVm.updateWeeksDayData()
            }else{
                let msgStr = UserDefaults.getString(forKey: .nutritionDefault) ?? ""
                let dict = WHUtils.getDictionaryFromJSONString(jsonString: msgStr)
                for i in 0..<7{
                    self.centerVm.goalsDataArray.add(dict)
                }
                self.centerVm.updateWeeksDayData()
            }
        }else{
            self.centerVm.goalsDataArray = self.goalsDataArray
            self.centerVm.updateWeeksDayData()
        }
        
        self.view.addSubview(alertVm)
        self.view.addSubview(alertCircleVm)
        view.addSubview(previewAlertVm)
        setConstrait()
        
        bottomView.addShadow()
    }
    
    func setConstrait() {
//        bottomView.snp.makeConstraints { make in
//            make.left.width.bottom.equalToSuperview()
//            make.height.equalTo(getBottomSafeAreaHeight()+kFitWidth(68))
//        }
        previewButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.width.equalTo(kFitWidth(88))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-getBottomSafeAreaHeight()-kFitWidth(10))
        }
        nextBtn.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
            make.left.equalTo(previewButton.snp.right).offset(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-getBottomSafeAreaHeight()-kFitWidth(10))
        }
    }
}

extension GoalSetCircleVC{
    func sendNutritionsDefaultRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_get_default_nutrition, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendNutritionsDefaultRequest:\(dataArray)")
            
            self.goalsDataArray = NSMutableArray(array: dataArray)
            self.centerVm.goalsDataArray = self.goalsDataArray
            self.centerVm.updateWeeksDayData()
            
            UserDefaults.set(value: WHUtils.getJSONStringFromArray(array: dataArray), forKey: .nutritionDefaultArray)
        }
    }
    func sendNutritionsDefaultCircleRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_get_default_nutrition_circle, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendNutritionsDefaultCircleRequest:\(dataArray)")
            
            self.goalsCircleDataArray = NSMutableArray(array: dataArray)
            if dataArray.count == 0 {
                self.goalsCircleDataArray = NSMutableArray(array: self.goalsDataArray)
                self.customCircleVm.updateDaysNumber(dayNumber: 4)
                self.customCircleVm.updateGoalsDataArray(self.goalsCircleDataArray)
//                self.customCircleVm.updateDataForTemplate(type: "2")
            }else{
                self.customCircleVm.updateDaysNumber(dayNumber: self.goalsCircleDataArray.count)
                self.customCircleVm.updateGoalsDataArray(self.goalsCircleDataArray)
            }
            
            self.customCircleVm.goalsDataArray = self.goalsCircleDataArray
            self.customCircleVm.updateWeeksDayData(isInit: true)
        }
    }
    
    func sendSaveWeekGoalRequest(weeks:NSArray) {
        MCToast.mc_loading()
        let param = ["week":weeks]
        DLLog(message: "sendSaveWeekGoalRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_goal_week_save, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            UserDefaults.set(value: WHUtils.getJSONStringFromArray(array: weeks), forKey: .nutritionDefaultArray)
            let serialQueue = DispatchQueue(label: "com.logs.sqlite")
            for i in 0..<weeks.count{
                LogsSQLiteManager.getInstance().refreshDataTarget(weeksDay: i+1, serialQueue: serialQueue)
            }
//            LogsSQLiteManager.getInstance().deleteTableData(sDate: Date().nextDay(days: 0))
            MCToast.mc_remove()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
            if UserInfoModel.shared.isFromSetting == true{
                UserInfoModel.shared.isFromSetting = false
                self.navigationController?.tabBarController?.selectedIndex = 1
                self.navigationController?.popToRootViewController(animated: true)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "activePlan"), object: nil)
            }else{
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func sendSaveCircleGoalRequest(goalsArray:NSArray) {
        MCToast.mc_loading()
        let param = ["cc":goalsArray,
                     "cc_start_date_offset_index":self.customCircleVm.todayIndex] as [String : Any]
        DLLog(message: "sendSaveCircleGoalRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_goal_circle_save, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            
            UserDefaults.set(value: goalsArray, forKey: .circleGoalArray)
            UserInfoModel.shared.ccStartDate = Date().todayDate
            UserInfoModel.shared.ccStartOffsetIndex = self.customCircleVm.todayIndex
            LogsSQLiteManager.getInstance().refreshDataTarget(goalArray: goalsArray,startIndex: self.customCircleVm.todayIndex)

            
            MCToast.mc_remove()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
            if UserInfoModel.shared.isFromSetting == true{
                UserInfoModel.shared.isFromSetting = false
                self.navigationController?.tabBarController?.selectedIndex = 1
                self.navigationController?.popToRootViewController(animated: true)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "activePlan"), object: nil)
            }else{
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
