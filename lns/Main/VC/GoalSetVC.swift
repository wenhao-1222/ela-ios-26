//
//  GoalSetVC.swift
//  lns
//
//  Created by LNS2 on 2024/7/31.
//

import Foundation
import MCToast
import IQKeyboardManagerSwift

class GoalSetVC: WHBaseViewVC {
    
    var dataArray = NSMutableArray()
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        self.contentVm.specGVm.initData()
    }
    
    lazy var contentVm: GoalSetVM = {
        let vm = GoalSetVM.init(frame: CGRect.init(x: 0, y: kFitWidth(8), width: 0, height: 0))
        vm.confirmBlock = {()in
//            self.presentAlertVc(confirmBtn: "保存", message: "", title: "温馨提示", cancelBtn: "取消", handler: { action in
                self.sendSaveNutrationRequest()
//            }, viewController: self)
        }
        vm.dataChangeBlock = {()in
            self.dataArray = NSMutableArray()
        }
        return vm
    }()
    lazy var setWeekDayGoalButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("设定碳循环/欺骗日", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.backgroundColor = .clear
        
        btn.addTarget(self, action: #selector(setWeekAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var bottomTypeVm: GoalOtherSetTypeVM = {
        let vm = GoalOtherSetTypeVM.init(frame: CGRect.init(x: 0, y: self.contentVm.frame.maxY+kFitWidth(25), width: 0, height: 0))
        vm.circleButton.addTarget(self, action: #selector(setWeekAction), for: .touchUpInside)
        vm.zhiNengButton.addTarget(self, action: #selector(getGoalAction), for: .touchUpInside)
        
        return vm
    }()
}

extension GoalSetVC{
    @objc func getGoalAction() {
        let vc = QuestionnairePreVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func setWeekAction() {
        if self.contentVm.checkValue() == false{
            return
        }
        let vc = GoalSetCircleVC()

//        let vc = GoalSetWeeksVC()
        if self.contentVm.typeVm.type == "g" && self.contentVm.specGVm.dataIsChanged == true{
            for _ in 0..<7{
                vc.goalsDataArray.add(self.contentVm.dataDict)
            }
        }else if self.contentVm.typeVm.type == "%" && self.contentVm.specPercentVm.dataIsChanged == true{
            for _ in 0..<7{
                vc.goalsDataArray.add(self.contentVm.dataDict)
            }
        }
//        else if self.dataArray.count > 0{
//            vc.goalsDataArray.addObjects(from: self.dataArray as! [Any])
//        }
        self.navigationController?.pushViewController(vc, animated: true)
        vc.dataChangeBlock = {(dataArr)in
//            self.dataArray = NSMutableArray(array: dataArr)
//            self.contentVm.specGVm.dataIsChanged = false
//            self.contentVm.specPercentVm.dataIsChanged = false
        }
    }
}

extension GoalSetVC{
    func initUI() {
        initNavi(titleStr: "卡路里和营养素目标")
        self.navigationView.backgroundColor = .COLOR_BG_F5
//        self.navigationView.addShadow()
//        view.backgroundColor = .COLOR_BG_F5
        
        view.insertSubview(scrollViewBase, belowSubview: self.navigationView)
        scrollViewBase.backgroundColor = .COLOR_BG_F5
        scrollViewBase.delegate = self
        scrollViewBase.frame = CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight())
        scrollViewBase.addSubview(contentVm)
        scrollViewBase.addSubview(bottomTypeVm)
        scrollViewBase.contentSize = CGSize.init(width: 0, height: self.bottomTypeVm.frame.maxY + kFitWidth(40))
//        view.addSubview(setWeekDayGoalButton)
        
//        setConstrait()
    }
    func setConstrait() {
        setWeekDayGoalButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(contentVm.frame.width)
            make.top.equalTo(contentVm.snp.bottom).offset(kFitWidth(12))
            make.height.equalTo(kFitWidth(48))
        }
    }
}

extension GoalSetVC{
    func sendSaveNutrationRequest() {
//        MCToast.mc_loading()
        self.view.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
            self.view.isUserInteractionEnabled = true
        })
        let param = ["uid":"\(UserInfoModel.shared.uId)",
                     "surveytype":"custom",
                     "calories":"\(QuestinonaireMsgModel.shared.calories)",
                 "protein":"\(QuestinonaireMsgModel.shared.protein)",
                 "carbohydrate":"\(QuestinonaireMsgModel.shared.carbohydrates)",
                 "fat":"\(QuestinonaireMsgModel.shared.fats)"]
        DLLog(message: "sendSaveNutrationRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_question_custom_save, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            LogsSQLiteManager.getInstance().refreshDataTarget(sDate: Date().nextDay(days: 0),
                                                              caloriTar: QuestinonaireMsgModel.shared.calories,
                                                              proteinTar: QuestinonaireMsgModel.shared.protein,
                                                              carboTar: QuestinonaireMsgModel.shared.carbohydrates,
                                                              fatsTar: QuestinonaireMsgModel.shared.fats)
            //清空今日往后的数据
//            LogsSQLiteManager.getInstance().deleteTableData(sDate: Date().nextDay(days: 0))
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
            
            if UserInfoModel.shared.isFromSetting == true{
                UserInfoModel.shared.isFromSetting = false
                self.navigationController?.tabBarController?.selectedIndex = 1
                self.navigationController?.popToRootViewController(animated: true)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "activePlan"), object: nil)
            }else{
                self.backTapAction()
            }
        }
    }
}

extension GoalSetVC:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: false)
        }
    }
}

extension GoalSetVC{
    @objc func keyboardWillShow(notification: NSNotification) {
//        if self.contentVm.specGVm.fatVm.textField.isEditing{
//            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
////                if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//                let carboVmBottomGap = (SCREEN_HEIGHT-self.contentVm.specGVm.fatVm.frame.maxY-self.contentVm.frame.minY-self.contentVm.specGVm.frame.minY)
//                if carboVmBottomGap < keyboardSize.size.height{
//                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
//                        self.contentVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5-(keyboardSize.size.height-carboVmBottomGap))
//                    }
//                }
//            }
//        }else{
//            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
////                self.contentVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
//                self.contentVm.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(8), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(506))
//            }
//        }
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        var activeField: UITextField?
        if self.contentVm.caloriesVm.numberLabel.isFirstResponder {
            activeField = self.contentVm.caloriesVm.numberLabel
        } else if self.contentVm.specGVm.carVm.textField.isFirstResponder {
            activeField = self.contentVm.specGVm.carVm.textField
        } else if self.contentVm.specGVm.proteinVm.textField.isFirstResponder {
            activeField = self.contentVm.specGVm.proteinVm.textField
        } else if self.contentVm.specGVm.fatVm.textField.isFirstResponder {
            activeField = self.contentVm.specGVm.fatVm.textField
        }

        guard let textField = activeField else { return }
        let fieldFrame = textField.convert(textField.bounds, to: self.scrollViewBase)
        if fieldFrame.maxY + self.getNavigationBarHeight() + kFitWidth(8) > keyboardFrame.minY{
            self.scrollViewBase.setContentOffset(CGPoint(x: 0, y: fieldFrame.maxY + self.getNavigationBarHeight() + kFitWidth(8) - keyboardFrame.minY), animated: true)
        }
        
//        UIView.animate(withDuration: 0.3) {
//            self.scrollViewBase.contentInset.bottom = keyboardFrame.height
//            self.scrollViewBase.scrollIndicatorInsets.bottom = keyboardFrame.height
//            self.scrollViewBase.scrollRectToVisible(fieldFrame, animated: false)
//        }completion: { _ in
//            if fieldFrame.maxY + self.getNavigationBarHeight() + kFitWidth(8) > keyboardFrame.minY{
//                self.scrollViewBase.setContentOffset(CGPoint(x: 0, y: fieldFrame.maxY + self.getNavigationBarHeight() + kFitWidth(8) - keyboardFrame.minY), animated: true)
//            }
//        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
//        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
////            self.contentVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
//            self.contentVm.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(8), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(506))
//        }
        UIView.animate(withDuration: 0.3) {
            self.scrollViewBase.contentInset.bottom = 0
            self.scrollViewBase.verticalScrollIndicatorInsets.bottom = 0
            
        }
    }
}
