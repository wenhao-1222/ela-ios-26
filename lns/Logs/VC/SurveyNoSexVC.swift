//
//  SurveyNoSexVC.swift
//  lns
//
//  Created by Elavatine on 2025/2/11.
//


import Foundation
import MCToast
import IQKeyboardManagerSwift
import UMCommon

class SurveyNoSexVC: WHBaseViewVC {
    
    var surveytype = "full"
    var step = 1
    
    var leftVmCenter = CGPoint()
    var currentVmCenter = CGPoint()
    var rightVmCenter = CGPoint()
    
    var edgePanChangeX = CGFloat(0)
    var hasNavi = false
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        enableInteractivePopGesture()
        
        initUI()
        
        currentVmCenter = weightVm.center
        leftVmCenter = CGPoint.init(x: -SCREEN_WIDHT*0.5, y: currentVmCenter.y)
        rightVmCenter = CGPoint.init(x: SCREEN_WIDHT*1.5, y: currentVmCenter.y)
//        if surveytype == "part"{
//            progressVm.isHidden = true
//            progressPartVm.isHidden = false
//        }
        
        if hasNavi == false{
            let panGes = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(popGestureAction(gesture: )))
            panGes.edges = .left
            view.addGestureRecognizer(panGes)
        }
        
    }
    
    lazy var progressVm: QuestionnaireProgressVM = {
        let vm = QuestionnaireProgressVM.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: 0, height: 0))
        vm.totalStep = 6//10
        vm.setProgressStep(step: 1)
        vm.backBlock = {()in
            self.step = self.step - 1
            self.scrollMsgVmLast()
        }
        return vm
    }()
    lazy var goalVm : QuestionnaireGoalVM = {
        let vm = QuestionnaireGoalVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.progressVm.frame.maxY, width: 0, height: 0))
        vm.nextBlock = {()in
            self.step = 4
            self.scrollMsgVmNext()
        }
        vm.choiceBlock = {()in
            self.showNextButtonCenter()
        }
        return vm
    }()
    lazy var weightVm : QuestionnaireWeightVM = {
        let vm = QuestionnaireWeightVM.init(frame: CGRect.init(x: 0, y: self.progressVm.frame.maxY, width: 0, height: 0))
        
        return vm
    }()
    lazy var eventsVm : QuestionnaireEventsVM = {
        let vm = QuestionnaireEventsVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.progressVm.frame.maxY, width: 0, height: 0))
        vm.selectedBlock = {()in
            self.showNextButtonCenter()
        }
        return vm
    }()
    lazy var caloriesResultBaseVm: QuestionResultBaseVM = {
        let vm = QuestionResultBaseVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.progressVm.frame.maxY, width: 0, height: 0))
        vm.showTipsBlock = {()in
            self.katchAlertVm.showView()
        }
        return vm
    }()
    lazy var caloriesResultExplainVm: QuestionResultExplainVM = {
        let vm = QuestionResultExplainVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.progressVm.frame.maxY, width: 0, height: 0))
        return vm
    }()
    lazy var bodyFatManVm : QuestionnaireBodyFatManVM = {
        let vm = QuestionnaireBodyFatManVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.progressVm.frame.maxY, width: 0, height: 0))
        vm.selectedBlock = {()in
            self.showNextButtonCenter()
        }
        vm.showTipsBlock = {()in
            self.bodyFatAlertVm.showView()
        }
        return vm
    }()
    lazy var dayMealsVm : QuestionnaireDaylyMealsVM = {
        let vm = QuestionnaireDaylyMealsVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.progressVm.frame.maxY, width: 0, height: 0))
        
        return vm
    }()
    lazy var planWeeksVm : QuestionnairePlanWeeksVM = {
        let vm = QuestionnairePlanWeeksVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.progressVm.frame.maxY, width: 0, height: 0))
        
        return vm
    }()
    lazy var foodsVm: QuestionnairePlanFoodsVM = {
        let vm = QuestionnairePlanFoodsVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.progressVm.frame.maxY, width: 0, height: 0))
        
        vm.showTipsBlock = {()in
            self.foodsTipsAlertVm.showView()
        }
        return vm
    }()
    lazy var dailyFoodsSqltVm : QuestionnairePlanDailyFoodsSqtyVM = {
        let vm = QuestionnairePlanDailyFoodsSqtyVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.progressVm.frame.maxY, width: 0, height: 0))
        vm.selectedBlock = {()in
            self.showNextButtonCenter()
        }
        return vm
    }()
    lazy var planNameVm : QuestionnairePlanNameVM = {
        let vm = QuestionnairePlanNameVM.init(frame: .zero)
        vm.confirmBtn.setTitle("保存计划", for: .normal)
        
        vm.showTipsBlock = {()in
            self.planNameAlertVm.showView()
        }
        vm.submitBlock = {()in
            self.sendSurveySaveRequest()
        }
        
        return vm
    }()
    lazy var nextBtn : UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(16), y: SCREEN_HEIGHT + kFitWidth(12), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(48))
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.setTitleColor(WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.85), for: .highlighted)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(8)

        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var bodyFatAlertVm : QuestionnaireBodyFatAlertVM = {
        let vm = QuestionnaireBodyFatAlertVM.init(frame: .zero)
        
        return vm
    }()
    lazy var foodsTipsAlertVm: QuestionnaireFoodsTipsAlertVM = {
        let vm = QuestionnaireFoodsTipsAlertVM.init(frame: .zero)
        return vm
    }()
    lazy var planNameAlertVm : QuestionnairePlanNameAlertVM = {
        let vm = QuestionnairePlanNameAlertVM.init(frame: .zero)
        vm.contentLabelOne.text = "您的定制营养目标和饮食计划将被保存在软件的“计划列表”中，如需："
        
        return vm
    }()
    lazy var choiceVm: NewQuestionnaireTypeVM = {
        let vm = NewQuestionnaireTypeVM.init(frame: CGRect.init(x: 0, y: self.progressVm.frame.maxY, width: 0, height: 0))
        vm.backBlock = {()in
            self.surveytype = "full"
            QuestinonaireMsgModel.shared.surveytype = "full"
            self.choiceVm.isShow = false
        }
        vm.choiceBlock = {(isFull)in
            self.choiceVm.isShow = false
            if isFull{
                self.surveytype = "full"
                QuestinonaireMsgModel.shared.surveytype = "full"
                self.nextAction()
            }else{
                self.surveytype = "part"
                
                QuestinonaireMsgModel.shared.caloriesNumber = QuestinonaireMsgModel.shared.caloriesNumberFromServer
                QuestinonaireMsgModel.shared.surveytype = "part"
                let vc = QuestionCustomVC()
                vc.disableSwipeBack = true
                vc.nextBtn.setTitle("激活目标", for: .normal)
                vc.backButton.isHidden = true
                vc.backHomeButton.isHidden = false
                vc.isLogin = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return vm
    }()
    lazy var katchAlertVm : QuestionnaireBodyFatAlertVM = {
        let vm = QuestionnaireBodyFatAlertVM.init(frame: .zero)
        vm.titleLabel.text = "为什么选择Katch-McArdle公式?"
        vm.contentLabelOne.text = "Katch-McArdle公式更适合健身人群，因为瘦体重比总体重更能准确反映身体的代谢需求。与传统的BMR和BMI 公式相比，它更能体现肌肉量对代谢的影响，因此对于健美运动员、健身爱好者、或体脂率低的人，这个公式提供了更个性化的结果。"
        vm.contentLabelTwo.text = ""
        vm.contentLabelThree.text = ""
        return vm
    }()
}

extension SurveyNoSexVC{
    @objc func popGestureAction(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.edgePanChangeX = CGFloat(0)
        case .changed:
            let translation = gesture.translation(in: view)
            self.edgePanChangeX = self.edgePanChangeX + translation.x
            if self.step == 1{
//                self.view.center = CGPoint.init(x: self.edgePanChangeX+SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
            }else{
                self.leftEdgePanGesture(x: translation.x)
            }
            
            gesture.setTranslation(.zero, in: view)
        case .ended:
            if self.step == 6 {
                return
            }
            self.step = self.step - 1
            self.scrollMsgVmLast()
            break
        default:
            break
        }
    }
    func leftEdgePanGesture(x:CGFloat) {
        if self.step == 6 {
            return
        }
        
        switch self.step{
        case 2:
            self.weightVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.bodyFatManVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 3:
            self.bodyFatManVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.eventsVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 4:
            self.eventsVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.caloriesResultBaseVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 5:
            self.caloriesResultBaseVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.caloriesResultExplainVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 6:
            self.caloriesResultExplainVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.goalVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 7:
            self.goalVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.choiceVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 8:
            self.choiceVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.dayMealsVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 9:
            self.dayMealsVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.planWeeksVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 10:
            self.planWeeksVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.foodsVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        default:
            break
        }
    }
    
    @objc func nextAction() {
        caloriesResultBaseVm.caloriesTextField.resignFirstResponder()
        if self.step == 3 {
            openNetWorkServiceWithBolck(action: { netConnect in
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    if netConnect == true{
                        self.sendBasicRequest()
                    }else{
                        self.presentAlertVc(confirmBtn: "设置", message: "可以在“设置->App->无线数据”中开启“无线数据”，连接网络后才能流畅使用。", title: "“Elavatine”已关闭网络权限", cancelBtn: "取消", handler: { action in
                            self.openUrl(urlString: UIApplication.openSettingsURLString)
                        }, viewController: self)
                        
                    }
                })
            })
            return
        }else if self.step == 4{
            let calori = self.caloriesResultBaseVm.caloriesTextField.text
            if calori?.floatValue ?? 0 < 10{
                self.presentAlertVcNoAction(title: "请输入合理的热量摄入值", viewController: self)
                return
            }
            QuestinonaireMsgModel.shared.caloriesNumber = "\(Int(calori?.floatValue ?? 0))"
            QuestinonaireMsgModel.shared.caloriesNumberFromServer = "\(Int(calori?.floatValue ?? 0))"
        }
        if self.step == 10 && !foodsVm.checkValue(){
            return
        }
        self.step = self.step + 1
        self.scrollMsgVmNext()
    }
    
    func scrollMsgVmNext() {
        DLLog(message: "scrollMsgVmNext:----\(self.step)")
        self.progressVm.setProgressStep(step: self.step)
//        self.progressPartVm.setProgressStep(step: self.step)
        
        var delay = 0.0
//        if self.step == 2{
//            delay = 0.2
//        }
        UIView.animate(withDuration: 0.3, delay: TimeInterval(delay), options: .curveEaseInOut){
            switch self.step{
            case 2:// 体重---》体脂肪
                self.weightVm.getWeightValue()
                self.weightVm.center = self.leftVmCenter
                self.bodyFatManVm.center = self.currentVmCenter
                if self.bodyFatManVm.selectIndex < 0 {
                    self.hiddenNextButtonCenter()
                }
            case 3://体脂肪---》日常活动量
                self.bodyFatManVm.center = self.leftVmCenter
                self.eventsVm.center = self.currentVmCenter
                if self.eventsVm.selectedIndex < 0{
                    self.hiddenNextButtonCenter()
                }
            case 4:
                self.eventsVm.center = self.leftVmCenter
                self.caloriesResultBaseVm.center = self.currentVmCenter
            case 5 :
                self.caloriesResultBaseVm.center = self.leftVmCenter
                self.caloriesResultExplainVm.center = self.currentVmCenter
            case 6 :
//                self.showNextButtonCenter()
                self.caloriesResultExplainVm.center = self.leftVmCenter
                self.goalVm.center = self.currentVmCenter
                if self.goalVm.selectIndex >= 0 {
                    self.showNextButtonCenter()
                }else{
                    self.hiddenNextButtonCenter()
                }
            case 7:
                self.surveytype = "part"
                QuestinonaireMsgModel.shared.surveytype = "part"
                QuestinonaireMsgModel.shared.caloriesNumber = QuestinonaireMsgModel.shared.caloriesNumberFromServer
                let vc = QuestionCustomVC()
                vc.disableSwipeBack = true
                
                vc.nextBtn.setTitle("激活目标", for: .normal)
                vc.backButton.isHidden = true
                vc.backHomeButton.isHidden = false
                vc.isLogin = true
                self.navigationController?.pushViewController(vc, animated: true)
//                self.planWeeksVm.dealTipsString()
//                self.goalVm.center = self.leftVmCenter
//                self.choiceVm.center = self.currentVmCenter
//                self.hiddenNextButtonCenter()
            case 8:
                self.showNextButtonCenter()
                self.choiceVm.center = self.leftVmCenter
                self.dayMealsVm.center = self.currentVmCenter
            case 9:
                self.dayMealsVm.getDataData()
                self.dayMealsVm.center = self.leftVmCenter
                self.planWeeksVm.center = self.currentVmCenter
            case 10:
                self.planWeeksVm.center = self.leftVmCenter
                self.foodsVm.center = self.currentVmCenter
            case 11:
                self.foodsVm.getSubmitMsgForModel()
                self.planNameVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
                
            default:
                break
            }
            
        }completion: { isComplete in
//            if self.step == 2{
//                self.showNextButtonCenter()
//            }
//            QuestinonaireMsgModel.shared.printModelMsg()
        }
    }
    func scrollMsgVmLast() {
        if step == 0 {
            backToWelcome()
            return
        }
        
        self.progressVm.setProgressStep(step: self.step)
//        self.progressPartVm.setProgressStep(step: self.step)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut){
            self.showNextButtonCenter()
            switch self.step{
            case 1:
                self.bodyFatManVm.center = self.rightVmCenter
                self.weightVm.center = self.currentVmCenter
                self.weightVm.getWeightValue()
//                self.hiddenNextButtonCenter()
            case 2:
                self.eventsVm.center = self.rightVmCenter
                self.bodyFatManVm.center = self.currentVmCenter
            case 3:
                self.eventsVm.center = self.currentVmCenter
                self.caloriesResultBaseVm.center = self.rightVmCenter
            case 4:
                self.caloriesResultBaseVm.center = self.currentVmCenter
                self.caloriesResultExplainVm.center = self.rightVmCenter
            case 5:
                self.caloriesResultExplainVm.center = self.currentVmCenter
                self.goalVm.center = self.rightVmCenter
    //                self.hiddenNextButtonCenter()
            case 6:
                self.showNextButtonCenter()
                self.goalVm.center = self.currentVmCenter
                self.choiceVm.center = self.rightVmCenter
            case 7:
                self.hiddenNextButtonCenter()
                self.choiceVm.center = self.currentVmCenter
                self.dayMealsVm.center = self.rightVmCenter
            case 8:
                self.dayMealsVm.center = self.currentVmCenter
                self.planWeeksVm.center = self.rightVmCenter
            case 9:
                self.foodsVm.center = self.rightVmCenter
                self.planWeeksVm.center = self.currentVmCenter
            default:
                break
            }
        }
    }
    func backToWelcome() {
        QuestinonaireMsgModel.shared.clearMsg()
        if self.navigationController != nil{
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true)
        }
    }
    @objc func showNextButtonCenter() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut){
            self.nextBtn.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT-kFitWidth(36)-WHUtils().getBottomSafeAreaHeight())
        }
    }
    @objc func hiddenNextButtonCenter() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut){
            self.nextBtn.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT+kFitWidth(36))
        }
    }
}
extension SurveyNoSexVC{
    func initUI(){
        view.backgroundColor = .COLOR_GRAY_FA
        
        view.clipsToBounds = true
        view.addSubview(progressVm)
//        view.addSubview(progressPartVm)
//        view.addSubview(sexVm)
//        view.addSubview(birthDayVm)
        view.addSubview(goalVm)
        view.addSubview(weightVm)
        view.addSubview(eventsVm)
        view.addSubview(caloriesResultBaseVm)
        view.addSubview(caloriesResultExplainVm)
        view.addSubview(bodyFatManVm)
        view.addSubview(dayMealsVm)
        view.addSubview(planWeeksVm)
        view.addSubview(foodsVm)
        view.addSubview(dailyFoodsSqltVm)
        
        view.addSubview(nextBtn)
        
        view.addSubview(planNameVm)
        
        view.addSubview(bodyFatAlertVm)
        view.addSubview(foodsTipsAlertVm)
        view.addSubview(planNameAlertVm)
        view.addSubview(choiceVm)
        view.addSubview(katchAlertVm)
        
        foodsVm.choiceFoodsAlertVm.controller = self
        if QuestinonaireMsgModel.shared.sex == "2"{ //&& QuestinonaireMsgModel.shared.weight == ""{
            self.weightVm.pickerView.selectRow(20, inComponent: 0, animated: false)
        }else {
            self.weightVm.pickerView.selectRow(40, inComponent: 0, animated: false)
        }
        self.showNextButtonCenter()
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
//            self.birthDayVm.pickerView.selectRow(self.birthDayVm.defaultIndex, inComponent: 0, animated: true)
//        })
    }
}

extension SurveyNoSexVC{
    func sendSurveySaveRequest() {
        MobClick.event("createPlanFull")
        var param = NSDictionary()
        if QuestinonaireMsgModel.shared.surveytype == "custom"{//自定义目标
            MCToast.mc_loading()
            param = ["uid":"\(UserInfoModel.shared.uId)",
                     "surveytype":"custom",
                     "calories":"\(QuestinonaireMsgModel.shared.calories)",
                     "protein":"\(QuestinonaireMsgModel.shared.protein)",
                     "carbohydrate":"\(QuestinonaireMsgModel.shared.carbohydrates)",
                     "fat":"\(QuestinonaireMsgModel.shared.fats)"]
            
            WHNetworkUtil.shareManager().POST(urlString: URL_question_custom_save, parameters: param as? [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
                DLLog(message: "\(responseObject)")
                UserInfoModel.shared.birthDay = "\(QuestinonaireMsgModel.shared.birthDay)-01-01"
                UserInfoModel.shared.gender = "\(QuestinonaireMsgModel.shared.sex)"
                self.sendSaveMaterialRequest()
                self.navigationController?.popViewController(animated: true)
            }
        }else {//填写了问卷
            if QuestinonaireMsgModel.shared.surveytype == "full"{
                MCToast.mc_loading(duration: 30,respond: .forbid)
                param = ["uid":"\(UserInfoModel.shared.uId)",
                         "surveytype":"full",
                         "pname":"\(QuestinonaireMsgModel.shared.name)",
                         "gender":"\(QuestinonaireMsgModel.shared.sex)",
                         "birthday":"\(QuestinonaireMsgModel.shared.birthDay)",
                         "height":"\(QuestinonaireMsgModel.shared.height)",
                         "weight":"\(QuestinonaireMsgModel.shared.weight)",
                         "goal":"\(QuestinonaireMsgModel.shared.goal)",
                         "dailyact":"\(QuestinonaireMsgModel.shared.events)",
                         "bodyfat":"\(QuestinonaireMsgModel.shared.bodyFat)",
                         "dailymeals":"\(QuestinonaireMsgModel.shared.mealsPerDay)",
                         "planweeks":"\(QuestinonaireMsgModel.shared.planWeeks)",
                         "protein":QuestinonaireMsgModel.shared.foodsMsgProteins,
                         "fat":QuestinonaireMsgModel.shared.foodsMsgFats,
                         "carbohydrate":QuestinonaireMsgModel.shared.foodsMsgCarbohydrates,
                         "vegetable":QuestinonaireMsgModel.shared.foodsMsgVegetables,
                         "fruit":QuestinonaireMsgModel.shared.foodsMsgFrutis,
                         "dailyfoodsqty":"\(QuestinonaireMsgModel.shared.dailyfoodsqty)",
                         "calories":"\(QuestinonaireMsgModel.shared.caloriesNumber)"]
                DLLog(message: "\(param)")
                WHNetworkUtil.shareManager().POST(urlString: URL_question_survey_save, parameters: param as? [String:AnyObject],isNeedToast: true,vc: self,timeOut: 30) { responseObject in
                    DLLog(message: "\(responseObject)")
                    MCToast.mc_text("计划保存成功")
                    UserInfoModel.shared.birthDay = "\(QuestinonaireMsgModel.shared.birthDay)-01-01"
                    UserInfoModel.shared.gender = "\(QuestinonaireMsgModel.shared.sex)"
                    self.sendSaveMaterialRequest()
//                    if BodyDataSQLiteManager.getInstance().queryTable(sDate: Date().nextDay(days: 0)){
//                        BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "weight", data: "\(QuestinonaireMsgModel.shared.weight)", cTime: Date().nextDay(days: 0))
//                    }else{
//                        BodyDataSQLiteManager.getInstance().updateData(cTime: Date().nextDay(days: 0), imgurl: "", hipsData: "", weightData: "\(QuestinonaireMsgModel.shared.weight)", waistlineData: "", shoulderData: "", bustData: "", thighData: "", calfData: "", bfpData: "", images: "[[],[],[]]", armcircumferenceData: "")
//                    }
                    
                    self.navigationController?.popToRootViewController(animated: true)
                    if UserInfoModel.shared.isFromSetting == true{
                        UserInfoModel.shared.isFromSetting = false
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fullPlanSaveForMine"), object: nil)
                    }else{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fullPlanSave"), object: nil)
                    }
                }
            }else{
                QuestinonaireMsgModel.shared.surveytype = "part"
                let vc = QuestionCustomVC()
                vc.disableSwipeBack = true
                vc.isLogin = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    @objc func sendSaveMaterialRequest() {
        MCToast.mc_loading()
        let param = ["gender":"\(UserInfoModel.shared.gender)",
                     "birthday":"\(UserInfoModel.shared.birthDay)"]
        
       WHNetworkUtil.shareManager().POST(urlString: URL_User_Material_Update, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
        }
    }
    func sendBasicRequest() {
        let param = ["gender":"\(QuestinonaireMsgModel.shared.sex)",
                     "dailyact":"\(QuestinonaireMsgModel.shared.events)",
                     "bodyfat":"\(QuestinonaireMsgModel.shared.bodyFat)",
                     "weight":"\(QuestinonaireMsgModel.shared.weight)"]
        DLLog(message: "sendBasicRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_question_basic_consumption, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            DLLog(message: "sendBasicRequest:\(dataString ?? "")")
            QuestinonaireMsgModel.shared.caloriesNumber = "\(dataString ?? "0")"
            QuestinonaireMsgModel.shared.caloriesNumberFromServer = "\(dataString ?? "0")"
            self.caloriesResultBaseVm.caloriesTextField.text = QuestinonaireMsgModel.shared.caloriesNumber
            self.step = self.step + 1
            self.scrollMsgVmNext()
        }
    }
}
