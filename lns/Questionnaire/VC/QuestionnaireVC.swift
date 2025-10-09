//
//  QuestionnaireVC.swift
//  lns
//  #007AFF
//  Created by LNS2 on 2024/3/27.
//

import Foundation
import MCToast

class QuestionnaireVC: WHBaseViewVC {
    
    var surveytype = "full"
    var step = 1
    
    var leftVmCenter = CGPoint()
    var currentVmCenter = CGPoint()
    var rightVmCenter = CGPoint()
    
    var edgePanChangeX = CGFloat(0)
    var hasNavi = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableInteractivePopGesture()
        
        initUI()
        
        currentVmCenter = sexVm.center
        leftVmCenter = CGPoint.init(x: -SCREEN_WIDHT*0.5, y: currentVmCenter.y)
        rightVmCenter = CGPoint.init(x: SCREEN_WIDHT*1.5, y: currentVmCenter.y)
        if surveytype == "part"{
            progressVm.isHidden = true
            progressPartVm.isHidden = false
        }
        
        if hasNavi == false{
            let panGes = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(popGestureAction(gesture: )))
            panGes.edges = .left
            view.addGestureRecognizer(panGes)
        }
    }
    
    lazy var progressVm: QuestionnaireProgressVM = {
        let vm = QuestionnaireProgressVM.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: 0, height: 0))
        
        vm.backBlock = {()in
            self.step = self.step - 1
            self.scrollMsgVmLast()
        }
        return vm
    }()
    lazy var progressPartVm : QuestionnaireProgressPartVM = {
        let vm = QuestionnaireProgressPartVM.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: 0, height: 0))
        vm.isHidden = true
        vm.backBlock = {()in
            self.step = self.step - 1
            self.scrollMsgVmLast()
        }
        return vm
    }()
    lazy var sexVm : QuestionnaireSexVM = {
        let vm = QuestionnaireSexVM.init(frame: CGRect.init(x: 0, y: self.progressVm.frame.maxY, width: 0, height: 0))
        vm.manTapBlock = {()in
            self.step = 2
            self.scrollMsgVmNext()
            self.bodyFatManVm.updateScrollView()
        }
        vm.femanTapBlock = {()in
            self.step = 2
            self.scrollMsgVmNext()
            self.bodyFatManVm.updateScrollView()
        }
        return vm
    }()
    lazy var birthDayVm : QuestionnaireBirthdayVM = {
        let vm = QuestionnaireBirthdayVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.progressVm.frame.maxY, width: 0, height: 0))
        vm.nextBlock = {()in
            self.step = 3
            self.scrollMsgVmNext()
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
    lazy var heightVm : QuestionnaireHeightVM = {
        let vm = QuestionnaireHeightVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.progressVm.frame.maxY, width: 0, height: 0))
        
        return vm
    }()
    lazy var weightVm : QuestionnaireWeightVM = {
        let vm = QuestionnaireWeightVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.progressVm.frame.maxY, width: 0, height: 0))
        
        return vm
    }()
    lazy var eventsVm : QuestionnaireEventsVM = {
        let vm = QuestionnaireEventsVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: self.progressVm.frame.maxY, width: 0, height: 0))
        vm.selectedBlock = {()in
            self.showNextButtonCenter()
        }
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
        vm.showTipsBlock = {()in
            self.planNameAlertVm.showView()
        }
        vm.submitBlock = {()in
            if UserInfoModel.shared.uId.count > 0 {
                self.sendSurveySaveRequest()
            }else{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let newRootVC = LNSLoginVC()
                appDelegate.switchRootViewController(to: newRootVC)
            }
        }
        return vm
    }()
    lazy var nextBtn : UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(16), y: SCREEN_HEIGHT + kFitWidth(12), width: kFitWidth(343), height: kFitWidth(48))
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.setTitleColor(WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.85), for: .highlighted)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(8)
//        btn.setTitleColor(WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.85), for: .highlighted)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var bodyFatAlertVm : QuestionnaireBodyFatAlertVM = {
        let vm = QuestionnaireBodyFatAlertVM.init(frame: .zero)
        
        return vm
    }()
    lazy var planNameAlertVm : QuestionnairePlanNameAlertVM = {
        let vm = QuestionnairePlanNameAlertVM.init(frame: .zero)
        
        return vm
    }()
}

extension QuestionnaireVC{
    @objc func popGestureAction(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.edgePanChangeX = CGFloat(0)
        case .changed:
            let translation = gesture.translation(in: view)
//            DLLog(message: "translation.x:\(translation.x)")
            self.edgePanChangeX = self.edgePanChangeX + translation.x
            if self.step == 1{
//                self.view.center = CGPoint.init(x: self.edgePanChangeX+SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
            }else{
                self.leftEdgePanGesture(x: translation.x)
            }
            
            gesture.setTranslation(.zero, in: view)
        case .ended:
            self.step = self.step - 1
            self.scrollMsgVmLast()
            break
        default:
            break
        }
    }
    func leftEdgePanGesture(x:CGFloat) {
        if self.step == 11 {
            return
        }
        
        switch self.step{
        case 2:
            self.sexVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.birthDayVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 3:
            self.birthDayVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.goalVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 4:
            self.goalVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.weightVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 5:
            self.weightVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.eventsVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 6:
            self.eventsVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.bodyFatManVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 7:
            self.bodyFatManVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.dayMealsVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 8:
            self.dayMealsVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.planWeeksVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 9:
            self.planWeeksVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.foodsVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        case 10:
            self.foodsVm.center = CGPoint.init(x: self.edgePanChangeX+self.leftVmCenter.x, y: self.rightVmCenter.y)
            self.dailyFoodsSqltVm.center = CGPoint.init(x: self.currentVmCenter.x+self.edgePanChangeX, y: self.currentVmCenter.y)
        default:
            break
        }
    }
    
    @objc func nextAction() {
        if self.surveytype == "part" && self.step == 6 {
            self.sendBasicRequest()
            if UserInfoModel.shared.uId.count > 0 {
                self.sendSurveySaveRequest()
            }else{
                openNetWorkServiceWithBolck(action: { netConnect in
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        if netConnect == true{
                            let vc = QuestionCustomVC()
                            vc.tipsButton.isHidden = true
                            if self.navigationController != nil{
                                self.navigationController?.pushViewController(vc, animated: true)
                            }else{
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true)
                            }
                        }else{
                            self.presentAlertVc(confirmBtn: "设置", message: "可以在“设置->App->无线数据”中开启“无线数据”，连接网络后才能流畅使用。", title: "“Elavatine”已关闭网络权限", cancelBtn: "取消", handler: { action in
                                self.openUrl(urlString: UIApplication.openSettingsURLString)
                            }, viewController: self)
                        }
                    })
                })
            }
            return
        }
        if self.step == 9 && !foodsVm.checkValue(){
            return
        }
        self.step = self.step + 1
        self.scrollMsgVmNext()
    }
    
    func scrollMsgVmNext() {
        self.progressVm.setProgressStep(step: self.step)
        self.progressPartVm.setProgressStep(step: self.step)
        
        var delay = 0.0
        if self.step == 2{
            delay = 0.2
        }
        UIView.animate(withDuration: 0.3, delay: TimeInterval(delay), options: .curveEaseInOut){
            switch self.step{
            case 2://性别 -> 出生年份
                self.sexVm.center = self.leftVmCenter
                self.birthDayVm.center = self.currentVmCenter
                if QuestinonaireMsgModel.shared.sex == "2"{ //&& QuestinonaireMsgModel.shared.weight == ""{
                    self.weightVm.pickerView.selectRow(20, inComponent: 0, animated: false)
                }else {
                    self.weightVm.pickerView.selectRow(40, inComponent: 0, animated: false)
                }
            case 3://出生年份 -> 目标
                self.birthDayVm.getBirthDayData()
                self.birthDayVm.center = self.leftVmCenter
                self.goalVm.center = self.currentVmCenter
                if self.goalVm.selectIndex >= 0 {
                    self.showNextButtonCenter()
                }else{
                    self.hiddenNextButtonCenter()
                }
//            case 4://目标 -> 身高  去除身高
//                self.goalVm.center = self.leftVmCenter
//                self.heightVm.center = self.currentVmCenter
            case 4://目标->体重
//                if QuestinonaireMsgModel.shared.sex == "2" && QuestinonaireMsgModel.shared.weight == ""{
//                    self.weightVm.pickerView.selectRow(20, inComponent: 0, animated: false)
//                }
                self.planWeeksVm.dealTipsString()
                self.goalVm.center = self.leftVmCenter
                self.weightVm.center = self.currentVmCenter
            case 5://体重->日常活动量
                self.weightVm.getWeightValue()
                self.weightVm.center = self.leftVmCenter
                self.eventsVm.center = self.currentVmCenter
                if self.eventsVm.selectedIndex < 0{
                    self.hiddenNextButtonCenter()
                }
            case 6:
                self.eventsVm.center = self.leftVmCenter
                self.bodyFatManVm.center = self.currentVmCenter
                if self.bodyFatManVm.selectIndex < 0 {
                    self.hiddenNextButtonCenter()
                }
            case 7 :
                self.bodyFatManVm.center = self.leftVmCenter
                self.dayMealsVm.center = self.currentVmCenter
            case 8:
                self.dayMealsVm.getDataData()
                self.dayMealsVm.center = self.leftVmCenter
                self.planWeeksVm.center = self.currentVmCenter
            case 9:
                self.planWeeksVm.center = self.leftVmCenter
                self.foodsVm.center = self.currentVmCenter
            case 10:
                self.foodsVm.center = self.leftVmCenter
                self.dailyFoodsSqltVm.center = self.currentVmCenter
                self.foodsVm.getSubmitMsgForModel()
                if self.dailyFoodsSqltVm.selectedIndex >= 0 {
                    self.showNextButtonCenter()
                }else{
                    self.hiddenNextButtonCenter()
                }
            case 11:
                self.planNameVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
                
            default:
                break
            }
            
        }completion: { isComplete in
            if self.step == 2{
                self.showNextButtonCenter()
            }
            QuestinonaireMsgModel.shared.printModelMsg()
        }
    }
    func scrollMsgVmLast() {
        if step == 0 {
            backToWelcome()
            return
        }
        self.progressVm.setProgressStep(step: self.step)
        self.progressPartVm.setProgressStep(step: self.step)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut){
            self.showNextButtonCenter()
            switch self.step{
            case 1:
                self.birthDayVm.center = self.rightVmCenter
                self.sexVm.center = self.currentVmCenter
                self.hiddenNextButtonCenter()
            case 2:
                self.goalVm.center = self.rightVmCenter
                self.birthDayVm.center = self.currentVmCenter
//                self.showNextButtonCenter()
            case 3:
                self.weightVm.center = self.rightVmCenter
                self.goalVm.center = self.currentVmCenter
                self.weightVm.getWeightValue()
//                self.showNextButtonCenter()
//            case 4:
//                self.heightVm.center = self.currentVmCenter
//                self.weightVm.center = self.rightVmCenter
//                self.showNextButtonCenter()
            case 4:
                self.weightVm.center = self.currentVmCenter
                self.eventsVm.center = self.rightVmCenter
            case 5:
                self.eventsVm.center = self.currentVmCenter
                self.bodyFatManVm.center = self.rightVmCenter
//                self.showNextButtonCenter()
            case 6:
                self.bodyFatManVm.center = self.currentVmCenter
                self.dayMealsVm.center = self.rightVmCenter
            case 7:
                self.dayMealsVm.center = self.currentVmCenter
                self.planWeeksVm.center = self.rightVmCenter
            case 8:
                self.planWeeksVm.center = self.currentVmCenter
                self.foodsVm.center = self.rightVmCenter
            case 9:
                self.foodsVm.center = self.currentVmCenter
                self.dailyFoodsSqltVm.center = self.rightVmCenter
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
extension QuestionnaireVC{
    func initUI(){
        view.backgroundColor = .COLOR_GRAY_FA
        
        view.clipsToBounds = true
        view.addSubview(progressVm)
        view.addSubview(progressPartVm)
        view.addSubview(sexVm)
        view.addSubview(birthDayVm)
        view.addSubview(goalVm)
        view.addSubview(heightVm)
        view.addSubview(weightVm)
        view.addSubview(eventsVm)
        view.addSubview(bodyFatManVm)
        view.addSubview(dayMealsVm)
        view.addSubview(planWeeksVm)
        view.addSubview(foodsVm)
        view.addSubview(dailyFoodsSqltVm)
        
        view.addSubview(nextBtn)
        
        view.addSubview(planNameVm)
        
        view.addSubview(bodyFatAlertVm)
        view.addSubview(planNameAlertVm)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            self.birthDayVm.pickerView.selectRow(self.birthDayVm.defaultIndex, inComponent: 0, animated: true)
        })
    }
}

extension QuestionnaireVC{
    func sendSurveySaveRequest() {
        MCToast.mc_loading()
        var param = NSDictionary()
        if QuestinonaireMsgModel.shared.surveytype == "custom"{//自定义目标
            param = ["uid":"\(UserInfoModel.shared.uId)",
                     "surveytype":"custom",
                     "calories":"\(QuestinonaireMsgModel.shared.calories)",
                     "protein":"\(QuestinonaireMsgModel.shared.protein)",
                     "carbohydrate":"\(QuestinonaireMsgModel.shared.carbohydrates)",
                     "fat":"\(QuestinonaireMsgModel.shared.fats)",]
            
            WHNetworkUtil.shareManager().POST(urlString: URL_question_custom_save, parameters: param as? [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
                DLLog(message: "\(responseObject)")
                self.navigationController?.popViewController(animated: true)
            }
        }else {//填写了问卷
            if QuestinonaireMsgModel.shared.surveytype == "full"{
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
                         "dailyfoodsqty":"\(QuestinonaireMsgModel.shared.dailyfoodsqty)"]
                WHNetworkUtil.shareManager().POST(urlString: URL_question_survey_save, parameters: param as? [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
//                    DLLog(message: "\(responseObject)")
                    MCToast.mc_text("计划保存成功")
//                    if BodyDataSQLiteManager.getInstance().queryTable(sDate: Date().nextDay(days: 0)){
//                        BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "weight", data: "\(QuestinonaireMsgModel.shared.weight)", cTime: Date().nextDay(days: 0))
//                    }else{
//                        BodyDataSQLiteManager.getInstance().updateData(cTime: Date().nextDay(days: 0), imgurl: "", hipsData: "", weightData: "\(QuestinonaireMsgModel.shared.weight)", waistlineData: "", shoulderData: "", bustData: "", thighData: "", calfData: "", bfpData: "", images: "[[],[],[]]", armcircumferenceData: "")
//                    }
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                param = ["uid":"\(UserInfoModel.shared.uId)",
                         "surveytype":"part",
                         "removefoods":"false",
                         "gender":"\(QuestinonaireMsgModel.shared.sex)",
                         "birthday":"\(QuestinonaireMsgModel.shared.birthDay)",
                         "height":"\(QuestinonaireMsgModel.shared.height)",
                         "weight":"\(QuestinonaireMsgModel.shared.weight)",
                         "goal":"\(QuestinonaireMsgModel.shared.goal)",
                         "dailyact":"\(QuestinonaireMsgModel.shared.events)",
                         "bodyfat":"\(QuestinonaireMsgModel.shared.bodyFat)",
                         "fat":"\(QuestinonaireMsgModel.shared.fatsNumber)",
                         "protein":"\(QuestinonaireMsgModel.shared.protein)",
                         "carbohydrate":"\(QuestinonaireMsgModel.shared.carbohydrates)",
                         "calories":"\(QuestinonaireMsgModel.shared.caloriesNumber)"]
                WHNetworkUtil.shareManager().POST(urlString: URL_question_survey_savepart, parameters: param as? [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
//                    DLLog(message: "\(responseObject)")
                    MCToast.mc_text("计划保存成功")//                    if BodyDataSQLiteManager.getInstance().queryTable(sDate: Date().nextDay(days: 0)){
//                        BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "weight", data: "\(QuestinonaireMsgModel.shared.weight)", cTime: Date().nextDay(days: 0))
//                    }else{
//                        BodyDataSQLiteManager.getInstance().updateData(cTime: Date().nextDay(days: 0), imgurl: "", hipsData: "", weightData: "\(QuestinonaireMsgModel.shared.weight)", waistlineData: "", shoulderData: "", bustData: "", thighData: "", calfData: "", bfpData: "", images: "[[],[],[]]", armcircumferenceData: "")
//                    }
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func sendBasicRequest() {
        let param = ["gender":"\(QuestinonaireMsgModel.shared.sex)",
                     "dailyact":"\(QuestinonaireMsgModel.shared.events)",
                     "bodyfat":"\(QuestinonaireMsgModel.shared.bodyFat)",
                     "weight":"\(QuestinonaireMsgModel.shared.weight)"]
        DLLog(message: "sendBasicRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_question_basic_consumption, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "sendBasicRequest:\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            DLLog(message: "sendBasicRequest:\(dataString ?? "")")
            
        }
    }
}
