//
//  QuestionCustomVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/2.
//

import Foundation
import MCToast
import IQKeyboardManagerSwift
import UMCommon

class QuestionCustomVC : WHBaseViewVC {
    
    var removefoods = "false"
    var carNumber = 0
    var proteinNumber = 0
    var fatNumber = 0
    
    var isLogin = false
    /// Disable swipe back gesture when entering from SurveyVC
    var disableSwipeBack = false
    private var edgePanGesture: UIScreenEdgePanGestureRecognizer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        if QuestinonaireMsgModel.shared.surveytype == "part"{
            sendGetGoalRequest()
        }
        
//        let panGes = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(popGestureAction(gesture: )))
//        panGes.edges = .left
//        view.addGestureRecognizer(panGes)
        if !disableSwipeBack {
            let panGes = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(popGestureAction(gesture: )))
            panGes.edges = .left
            view.addGestureRecognizer(panGes)
            edgePanGesture = panGes
        }else{
            enableInteractivePopGesture()
        }
        
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is SurveyNoSexVC }){
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }else if let index = controllers.firstIndex(where: { $0 is SurveyVC }){
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
            if let index = controllers.firstIndex(where: { $0 is QuestionnairePreVC }){
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if disableSwipeBack {
            enableInteractivePopGesture()
        }
//        UIView.performWithoutAnimation {
            self.nextBtn.isHidden = false
//        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if disableSwipeBack {
            openInteractivePopGesture()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        UIView.performWithoutAnimation {
//            self.nextBtn.isHidden = false
//        }
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
//        lab.text = "卡路里和营养素目标"
        lab.text = "每日营养目标"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        if QuestinonaireMsgModel.shared.surveytype == "part" {
            lab.text = "您的营养目标"
        }
        return lab
    }()
    lazy var tipsButton : UIButton = {
        let btn = UIButton()
//        btn.setTitle("如何使用这些目标？", for: .normal)
        btn.setTitle("摄入太高/太低？", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(tipsTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(28), y: kFitWidth(160)+statusBarHeight, width: SCREEN_WIDHT-kFitWidth(56), height: kFitWidth(414)))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var labelOne : UILabel = {
        let lab = UILabel()
        lab.text = "-"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.font = UIFont().DDInFontMedium(fontSize: 28)
        
        return lab
    }()
    lazy var labelTwo : UILabel = {
        let lab = UILabel()
        lab.text = "卡路里 (千卡)"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var goalImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_goal_selected")
        
        return img
    }()
    lazy var carVm : QuestionCustomItemVM = {
        let vm = QuestionCustomItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(114), width: SCREEN_WIDHT-kFitWidth(56), height: 0))
        vm.titleLabel.text = "碳水化合物"
        vm.textField.textContentType = nil
//        if QuestinonaireMsgModel.shared.surveytype == "part" {
//            vm.textField.isEnabled = false
//        }
        vm.numberChangeBlock = {(number)in
            self.carNumber = Int(number) ?? 0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var proteinVm : QuestionCustomItemVM = {
        let vm = QuestionCustomItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(182), width: SCREEN_WIDHT-kFitWidth(56), height: 0))
        vm.titleLabel.text = "蛋白质"
        vm.textField.textContentType = nil
//        if QuestinonaireMsgModel.shared.surveytype == "part" {
//            vm.textField.isEnabled = false
//        }
        vm.numberChangeBlock = {(number)in
            self.proteinNumber = Int(number) ?? 0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var fatVm : QuestionCustomItemVM = {
        let vm = QuestionCustomItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(250), width: SCREEN_WIDHT-kFitWidth(56), height: 0))
        vm.titleLabel.text = "脂肪"
        vm.textField.textContentType = nil
//        if QuestinonaireMsgModel.shared.surveytype == "part" {
//            vm.textField.isEnabled = false
//        }
        vm.numberChangeBlock = {(number)in
            self.fatNumber = Int(number) ?? 0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var nextBtn : UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x: kFitWidth(20), y: kFitWidth(346), width: SCREEN_WIDHT-kFitWidth(96), height: kFitWidth(48)))
//        btn.frame =
        btn.setTitle("开始体验", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME, for: .highlighted)
        btn.backgroundColor = .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.isHidden = true
        
//        if QuestinonaireMsgModel.shared.surveytype == "part" {
//            btn.isEnabled = false
//            btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .disabled)
//            btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        }else{
            btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        }
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .highlighted)
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var backButton : FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("返回上一步", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var backHomeButton : FeedBackButton = {
        let btn = FeedBackButton()
        btn.isHidden = true
//        if UserInfoModel.shared.isFromSetting == true{
            btn.setTitle("返回", for: .normal)
//        }else{
//            btn.setTitle("返回日志", for: .normal)
//        }
        
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(backHomeTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var alertVm : QuestionCustomTipsAlertVM = {
        let vm = QuestionCustomTipsAlertVM.init(frame: .zero)
        vm.isHidden = true
//        vm.contentLabelOne.text = "· 您的营养目标会自动显示在软件的概览页及饮食日志顶部。\n\n·记录日常饮食时，您可以轻松核对目标，确保饮食选择有助于达成营养摄入目标。"
        
        vm.titleLabel.text = "摄入太高/太低？"
        vm.contentLabelOne.text = "Elavatine的计划的重心更偏向于最快达到健身目标，比起日常生活更接近专业运动员的需求，如果您觉得某营养素数值过高或者过低，您可以点击该值并进行手动修改。"
        return vm
    }()
}

extension QuestionCustomVC{
    @objc func popGestureAction(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .ended:
            if self.isLogin == false{
                self.backTapAction()
            }
            break
        default:
            break
        }
    }
    @objc func tipsTapAction(){
        self.carVm.textField.resignFirstResponder()
        self.proteinVm.textField.resignFirstResponder()
        self.fatVm.textField.resignFirstResponder()
        alertVm.showView()
    }
    @objc func backHomeTapAction(){
        if UserInfoModel.shared.isFromSetting == true{
            if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 1 {
                for vc in viewControllers{
                    if vc.isKind(of: CancelAccountVC.self){
                        self.navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
            }
        }else{
            if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 1 {
                for vc in viewControllers{
                    if vc.isKind(of: GoalSetVC.self){
                        self.navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
            }
//            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    @objc func backAction(){
        if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true) {
            }
        }
    }
    @objc func nextAction(){
        openNetWorkServiceWithBolck(action: { netConnect in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                if netConnect == true{
                    self.checkValue()
                }else{
                    self.presentAlertVc(confirmBtn: "设置", message: "可以在“设置->App->无线数据”中开启“无线数据”，连接网络后才能流畅使用。", title: "“Elavatine”已关闭网络权限", cancelBtn: "取消", handler: { action in
                        self.openUrl(urlString: UIApplication.openSettingsURLString)
                    }, viewController: self)
                }
            })
        })
    }
    func checkValue() {
        if carVm.textField.text?.count == 0 {
            MCToast.mc_text("请输入碳水化合物数值",respond: .allow)
            return
        }
        
        if Int(carVm.textField.text ?? "0") ?? 0 >= 0 && Int(carVm.textField.text ?? "0") ?? 0 <= 4999 {
            
        }else{
            MCToast.mc_text("碳水化合物目标数值范围 0 ~ 4999 g",respond: .allow)
            return
        }
        if Int(proteinVm.textField.text ?? "0") ?? 0 >= 1 && Int(proteinVm.textField.text ?? "0") ?? 0 <= 4999 {
            
        }else{
            MCToast.mc_text("蛋白质目标数值范围 1 ~ 4999 g",respond: .allow)
            return
        }
        if Int(fatVm.textField.text ?? "0") ?? 0 >= 1 && Int(fatVm.textField.text ?? "0") ?? 0 <= 4999 {
            
        }else{
            MCToast.mc_text("脂肪目标数值范围 1 ~ 4999 g",respond: .allow)
            return
        }
        QuestinonaireMsgModel.shared.carbohydrates = carVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.protein = proteinVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.fats = fatVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.calories = labelOne.text ?? "0"
        
        
        QuestinonaireMsgModel.shared.carbohydratesNumber = carVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.proteinNumber = proteinVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.fatsNumber = fatVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.caloriesNumber = labelOne.text ?? "0"
        
        MobClick.event("createPlanPart")
        
        if isLogin {
            let alertVc = UIAlertController(title: "是否同时清空（今日起）日志内的食物？", message: "", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "清空", style: .default, handler: { (action)in
                
                self.removefoods = "true"
                self.sendSavePlanRequest()
            })
            alertVc.addAction(okAction)
            let cancelAction = UIAlertAction(title: "保留", style: .default, handler:{ (action)in
                self.removefoods = "false"
                self.sendSavePlanRequest()
            })
            alertVc.addAction(cancelAction)
            
            okAction.setTextColor(WHColorWithAlpha(colorStr: "007AFF", alpha: 0.6))
            self.present(alertVc, animated:true, completion:nil)
        }else{
            WHBaseViewVC().changeRootVcToLogin()
        }
    }
    func calculateNumber() {
        if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
            labelOne.text = "-"
            labelOne.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
            return
        }
        //((protein + carbohydrate) * 4) + (fat * 9);
        let number = (proteinNumber + carNumber) * 4 + fatNumber * 9
        labelOne.text = "\(number)"
        labelOne.textColor = .COLOR_GRAY_BLACK_85
    }
}

extension QuestionCustomVC{
    func initUI() {
        view.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        view.addSubview(titleLabel)
        view.addSubview(tipsButton)
        view.addSubview(whiteView)
        whiteView.addSubview(labelOne)
        whiteView.addSubview(labelTwo)
        whiteView.addSubview(goalImgView)
        whiteView.addSubview(carVm)
        whiteView.addSubview(proteinVm)
        whiteView.addSubview(fatVm)
        
        whiteView.addSubview(nextBtn)
        
        whiteView.addShadow()
        view.addSubview(backButton)
        view.addSubview(backHomeButton)
        view.addSubview(alertVm)
        
        setConstrait()
    }
    func setConstrait(){
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(60)+statusBarHeight)
        }
        tipsButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(108)+statusBarHeight)
        }
        labelOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(24))
            make.height.equalTo(kFitWidth(24))
        }
        labelTwo.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(62))
        }
        goalImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(24))
            make.width.height.equalTo(kFitWidth(48))
        }
        backButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(281))
            make.height.equalTo(kFitWidth(48))
            make.top.equalTo(whiteView.snp.bottom).offset(kFitWidth(24))
        }
        backHomeButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(281))
            make.height.equalTo(kFitWidth(48))
            make.top.equalTo(whiteView.snp.bottom).offset(kFitWidth(24))
        }
    }
}

extension QuestionCustomVC{
    func sendGetGoalRequest() {
//        MCToast.mc_loading()
        let param = ["gender":"\(QuestinonaireMsgModel.shared.sex)",
                 "birthday":"\(QuestinonaireMsgModel.shared.birthDay)",
                 "weight":"\(QuestinonaireMsgModel.shared.weight)",
                 "goal":"\(QuestinonaireMsgModel.shared.goal)",
                 "dailyact":"\(QuestinonaireMsgModel.shared.events)",
                 "bodyfat":"\(QuestinonaireMsgModel.shared.bodyFat)",
                     "calories":QuestinonaireMsgModel.shared.caloriesNumber == "" ? QuestinonaireMsgModel.shared.caloriesNumberFromServer : QuestinonaireMsgModel.shared.caloriesNumber]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_question_survey_part_save, parameters: param as [String:AnyObject]) { responseObject in
            if responseObject["code"] as? String ?? "" == "404"{
                self.nextBtn.backgroundColor = .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT
                self.presentAlertVc(confirmBtn: "刷新", message: "", title: "当前网络不稳定", cancelBtn: nil, handler: { action in
                    self.sendGetGoalRequest()
                }, viewController: self)
            }else{
                self.nextBtn.backgroundColor = .THEME
                self.nextBtn.isEnabled = true
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                let data = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
                
                DLLog(message: "sendGetGoalRequest:\(data)")
                
                self.carNumber = data["carbohydrate"]as? Int ?? 0
                self.fatNumber = data["fat"]as? Int ?? 0
                self.proteinNumber = data["protein"]as? Int ?? 0
                
//                self.carNumber = Int(data.doubleValueForKey(key: "carbohydrate").rounded())
//                self.fatNumber = Int(data.doubleValueForKey(key: "fat").rounded())
//                self.proteinNumber = Int(data.doubleValueForKey(key: "protein").rounded())
                
                QuestinonaireMsgModel.shared.fatsNumber = "\(self.fatNumber)"
                QuestinonaireMsgModel.shared.proteinNumber = "\(self.proteinNumber)"
                QuestinonaireMsgModel.shared.carbohydratesNumber = "\(self.carNumber)"
                QuestinonaireMsgModel.shared.caloriesNumber = "\(data["calories"]as? Int ?? 0)"
                
                self.fatVm.textField.text = QuestinonaireMsgModel.shared.fatsNumber
                self.carVm.textField.text = QuestinonaireMsgModel.shared.carbohydratesNumber
                self.proteinVm.textField.text = QuestinonaireMsgModel.shared.proteinNumber
                
                self.labelOne.text = QuestinonaireMsgModel.shared.caloriesNumber
                self.labelOne.textColor = .COLOR_GRAY_BLACK_85
            }
        }
    }
    func sendSavePlanRequest() {
        MCToast.mc_loading()
       let param = ["uid":"\(UserInfoModel.shared.uId)",
                 "surveytype":"part",
                 "removefoods":"\(removefoods)",
                 "gender":"\(QuestinonaireMsgModel.shared.sex)",
                 "birthday":"\(QuestinonaireMsgModel.shared.birthDay)",
                 "height":"\(QuestinonaireMsgModel.shared.height)",
                 "weight":"\(QuestinonaireMsgModel.shared.weight)",
                 "goal":"\(QuestinonaireMsgModel.shared.goal)",
                 "dailyact":"\(QuestinonaireMsgModel.shared.events)",
                 "bodyfat":"\(QuestinonaireMsgModel.shared.bodyFat)",
                 "fat":"\(QuestinonaireMsgModel.shared.fatsNumber)",
                 "protein":"\(QuestinonaireMsgModel.shared.proteinNumber)",
                 "carbohydrate":"\(QuestinonaireMsgModel.shared.carbohydratesNumber)",
                 "calories":"\(QuestinonaireMsgModel.shared.caloriesNumber)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_question_survey_savepart, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            
//            if BodyDataSQLiteManager.getInstance().queryTable(sDate: Date().nextDay(days: 0)){
//                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "weight", data: "\(QuestinonaireMsgModel.shared.weight)", cTime: Date().nextDay(days: 0))
//            }else{
//                BodyDataSQLiteManager.getInstance().updateData(cTime: Date().nextDay(days: 0), imgurl: "", hipsData: "", weightData: "\(QuestinonaireMsgModel.shared.weight)", waistlineData: "", shoulderData: "", bustData: "", thighData: "", calfData: "", bfpData: "", images: "[[],[],[]]", armcircumferenceData: "")
//            }
            
            if self.removefoods == "true"{
                LogsSQLiteManager.getInstance().deleteTableData(sDate: Date().nextDay(days: 0))
            }else{
                LogsSQLiteManager.getInstance().refreshDataTarget(sDate: Date().nextDay(days: 0),
                                                                  caloriTar: QuestinonaireMsgModel.shared.caloriesNumber,
                                                                  proteinTar: QuestinonaireMsgModel.shared.proteinNumber,
                                                                  carboTar: QuestinonaireMsgModel.shared.carbohydratesNumber,
                                                                  fatsTar: QuestinonaireMsgModel.shared.fatsNumber)
            }
            
//            LogsSQLiteManager.getInstance().deleteTableData(sDate: Date().nextDay(days: 0))
            NutritionDefaultModel.shared.saveGoals(dict: ["calories":QuestinonaireMsgModel.shared.caloriesNumber,
                                                          "carbohydrates":QuestinonaireMsgModel.shared.carbohydratesNumber,
                                                          "proteins":QuestinonaireMsgModel.shared.proteinNumber,
                                                          "fats":QuestinonaireMsgModel.shared.fatsNumber])
            
            if UserInfoModel.shared.isFromSetting == true{
                UserInfoModel.shared.isFromSetting = false
                self.navigationController?.tabBarController?.selectedIndex = 1
                self.navigationController?.popToRootViewController(animated: true)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "activePlan"), object: nil)
            }else{
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "activePlan"), object: nil)
//                self.navigationController?.popToRootViewController(animated: true)
//                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                    self.navigationController?.tabBarController?.selectedIndex = 1
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "activePlan"), object: nil)
//                })
            }
        }
    }
}
