//
//  CancelAccountVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/16.
//

import Foundation
import IQKeyboardManagerSwift
import MCToast
import UIKit

class CancelAccountVC: WHBaseViewVC {
    
    var reasonsVmArray = [CancelAccountItemVM]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        IQKeyboardManager.shared.enable = true
////        IQKeyboardManager.shared.enableAutoToolbar = true
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
//    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
//        IQKeyboardManager.shared.enableAutoToolbar = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        initUI()
    }
    lazy var reasonArray: NSArray = {
        return ["不想控制饮食了",
                "软件使用太麻烦",
                "对提供的服务不满意",
                "软件太多bug"]
    }()
    lazy var bottomView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        return vi
    }()
    lazy var tipsIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "cancel_account_tips")
        return img
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.text = "请选择注销账号原因："
        
        return lab
    }()
    lazy var remarkTitleLabel : UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.text = "问题描述："
        
        return lab
    }()
    lazy var heplVm: CancelAccountHelpVM = {
        let vm = CancelAccountHelpVM.init(frame: .zero)
        vm.resetButton.addTarget(self, action: #selector(resetLogsAction), for: .touchUpInside)
        vm.resetGoalButton.addTarget(self, action: #selector(resetGoalAction), for: .touchUpInside)
        vm.getGoalButton.addTarget(self, action: #selector(getGoalAction), for: .touchUpInside)
        return vm
    }()
    lazy var remarkTextView: ServiceTextView = {
        let text = ServiceTextView.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(331), width: 0, height: 0))
        text.placeholderLabel.text = "请详细描述您所遇到的问题，以便我们能够提供更加优质的服务。"
        text.placeholderLabel.numberOfLines = 2
        text.placeholderLabel.lineBreakMode = .byWordWrapping
        text.limitCountLabel.isHidden = true
        
        return text
    }()
    
    lazy var submitButton: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(16), y: SCREEN_HEIGHT-kFitWidth(60)-getBottomSafeAreaHeight(), width: kFitWidth(343), height: kFitWidth(48))
        btn.backgroundColor = .THEME
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .disabled)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("确认注销", for: .normal)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        return btn
    }()
}

extension CancelAccountVC{
    @objc func resetLogsAction() {
//        UserInfoModel.shared.isFromSetting = true
        let alertVc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popover = alertVc.popoverPresentationController {
            // 锚点设置为触发按钮
            popover.sourceView = self.heplVm.resetButton
            popover.permittedArrowDirections = [.up]
        }
        let clearNextAction = UIAlertAction(title: "清空今日开始往后的数据", style: .default) { action in
            TouchGenerator.shared.touchGenerator()
            self.presentAlertVc(confirmBtn: "是", message: "是否继续？", title: "点击“是”将清空今日往后的日志内容，可能会清除碳循环目标", cancelBtn: "否", handler: { action in
                LogsSQLiteManager.getInstance().deleteTableData(sDate: Date().nextDay(days: 0))
                self.sendClearLogsRequest(type: "today")
            }, viewController: self)
        }
        let clearAllAction = UIAlertAction(title: "清空所有数据", style: .default) { action in
            TouchGenerator.shared.touchGenerator()
            self.presentAlertVc(confirmBtn: "是", message: "是否继续？", title: "点击“是”将清空全部日志内容\n可能会清除碳循环目标", cancelBtn: "否", handler: { action in
                LogsSQLiteManager.getInstance().deleteAllData()
                self.sendClearLogsRequest(type: "all")
            }, viewController: self)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel){action in
            TouchGenerator.shared.touchGenerator()
        }
        
        alertVc.addAction(clearNextAction)
        alertVc.addAction(clearAllAction)
        alertVc.addAction(cancelAction)
        self.present(alertVc, animated: true)
    }
    @objc func resetGoalAction() {
        UserInfoModel.shared.isFromSetting = true
        let vc = QuestionnairePreVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func getGoalAction() {
        UserInfoModel.shared.isFromSetting = true
        let vc = GoalSetVC()
//        vc.fromWhere =
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CancelAccountVC{
    func updateButtonStatus() {
        submitButton.isEnabled = false
        for vm in reasonsVmArray{
            if vm.isSelect == true{
                submitButton.isEnabled = true
//                return
            }
            
            let bugVm = reasonsVmArray[3]
            if bugVm.isSelect == true{
                remarkTitleLabel.text = "问题描述（必填）："
            }else{
                remarkTitleLabel.text = "问题描述："
            }
        }
    }
    @objc func cancelAction(){
        
        let bugVm = reasonsVmArray[3]
        if bugVm.isSelect == true && (remarkTextView.textView.text).trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            MCToast.mc_text("请输入问题描述")
            return
        }
        self.presentAlertVc(confirmBtn: "确认注销", message: "注销此Elavatine账号后，您可能无法立即重新注册。该账号及其所有数据将被永久删除且无法恢复，请谨慎操作！", title: "温馨提示", cancelBtn: "取消", handler: { action in
            self.sendCancelPreRequest()
//            self.sendCancelRequest()
//            LogsMealsAlertSetManage().removeAllNotifi()
        }, viewController: self)
    }
}

extension CancelAccountVC{
    func initUI(){
        initNavi(titleStr: "注销账号")
        
        view.insertSubview(bottomView, belowSubview: self.navigationView)
        view.addSubview(lineView)
        
        bottomView.addSubview(scrollViewBase)
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        
        scrollViewBase.addSubview(tipsIcon)
        scrollViewBase.addSubview(tipsLabel)
        scrollViewBase.addSubview(heplVm)
        scrollViewBase.addSubview(remarkTitleLabel)
        scrollViewBase.addSubview(remarkTextView)
        scrollViewBase.addSubview(submitButton)
        setConstrait()
        
        initReasonViews()
    }
    func setConstrait(){
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
            make.top.equalTo(getNavigationBarHeight())
        }
        tipsIcon.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(kFitWidth(24)+getNavigationBarHeight())
        }
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(tipsIcon.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(tipsIcon)
        }
        remarkTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(306)+getNavigationBarHeight())
        }
    }
    
    func initReasonViews() {
        var originY = kFitWidth(58)+getNavigationBarHeight()
        
        for i in 0..<reasonArray.count{
            let vm = CancelAccountItemVM.init(frame: CGRect.init(x: 0, y: originY, width: 0, height: 0))
            scrollViewBase.addSubview(vm)
            vm.contenLabel.text = reasonArray[i]as? String ?? ""
            vm.tapBlock = {()in
                self.updateButtonStatus()
            }
            reasonsVmArray.append(vm)
            originY = originY + CancelAccountItemVM().selfHeight
        }
        heplVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: originY+heplVm.selfHeight*0.5)
        remarkTitleLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(heplVm.snp.bottom)
        }
        remarkTextView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.heplVm.frame.maxY+remarkTextView.frame.height*0.5+kFitWidth(25))
        
        submitButton.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: remarkTextView.frame.maxY+kFitWidth(15))
        
        scrollViewBase.contentSize = CGSize.init(width: 0, height: submitButton.frame.maxY+kFitWidth(10)+getBottomSafeAreaHeight())
    }
}

extension CancelAccountVC{
    func sendCancelRequest() {
        var reasons = [String]()
        
        for vm in reasonsVmArray{
            if vm.isSelect == true{
                reasons.append(vm.contenLabel.text ?? "")
            }
        }
        
        let param : [String : Any] = ["reasons":reasons,
                                      "remarks":"\(remarkTextView.textView.text ?? "")"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_Uer_Cancel, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
//            UserInfoModel.shared.logoutClearMsg()
//            UserInfoModel.shared.clearMsg()
//            UserDefaults.standard.setValue("", forKey: token)
//            UserDefaults.standard.setValue("", forKey: userId)
//            UserDefaults.set(value: "", forKey: .myFoodsList)
//            UserDefaults.set(value: "", forKey: .hidsoryFoodsAdd)
//            WHBaseViewVC().changeRootVcToWelcome()
//            
//            WidgetUtils().saveUserInfo(uId: "", uToken: "")
            WHBaseViewVC().changeRootVcToWelcome()
            LogsSQLiteUploadManager().clearNaturalData()
            BodyDataSQLiteManager.getInstance().deleteAllData()
            
            LogsSQLiteManager.getInstance().deleteAllData()
            CourseProgressSQLiteManager.getInstance().deleteAllData()
            WidgetUtils().saveUserInfo(uId: "", uToken: "")
            UserDefaults.standard.setValue("", forKey: token)
            UserDefaults.standard.setValue("", forKey: userId)
            UserDefaults.set(value: "", forKey: .myFoodsList)
            UserDefaults.set(value: "", forKey: .hidsoryFoodsAdd)
            UserInfoModel.shared.clearMsg()
        }
    }
    func sendCancelPreRequest() {
        let param : [String : Any] = ["forceDelete":"0"]
        WHNetworkUtil.shareManager().POST(urlString: URL_Uer_Cancel_pre, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "\(dataObj)")
            var reasons = [String]()
            
            for vm in self.reasonsVmArray{
                if vm.isSelect == true{
                    reasons.append(vm.contenLabel.text ?? "")
                }
            }
            let code = responseObject["code"]as? Int ?? -1
            if (code == 99) {
                self.presentAlertVc(confirmBtn: "注销", message: "\(responseObject["message"]as? String ?? "当前有购买的课程")", title: "确认注销？", cancelBtn: "不注销", handler: { action in
                    let vc = CancelAccountCodeVC()
                    vc.reasons = reasons
                    vc.remarks = "\(self.remarkTextView.textView.text ?? "")"
                    self.navigationController?.pushViewController(vc, animated: true)
                }, viewController: self)
            }else if (code == 500) {
                self.presentAlertVc(confirmBtn: "我知道了", message: "\(responseObject["message"]as? String ?? "当前有未完成的商城订单")", title: "无法注销", cancelBtn: nil, handler: { action in
                }, viewController: self)
            }else if (code == 200){
                let vc = CancelAccountCodeVC()
                vc.reasons = reasons
                vc.remarks = "\(self.remarkTextView.textView.text ?? "")"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension CancelAccountVC{
    func sendClearLogsRequest(type:String) {
        let param = ["cleartype":type]
        MCToast.mc_loading()
        WHNetworkUtil.shareManager().POST(urlString: URL_clear_logs, parameters: param as [String: AnyObject],isNeedToast: true,vc: self) { responseObject in
            MCToast.mc_text("已重置日志列表数据",respond: .allow)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
            HealthKitNaturnalManager().clearWaterDataFromToday { t in
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                UserInfoModel.shared.isFromSetting = false
                self.navigationController?.tabBarController?.selectedIndex = 1
                self.navigationController?.popToRootViewController(animated: true)
//                self.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "activePlan"), object: nil)
            })
        }
    }
}

extension CancelAccountVC{
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let carboVmBottomGap = (SCREEN_HEIGHT-self.remarkTextView.frame.maxY)
            if carboVmBottomGap < keyboardSize.size.height{
                UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                    self.bottomView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5-(keyboardSize.size.height-carboVmBottomGap))
                }
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.bottomView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
        }
    }
}
