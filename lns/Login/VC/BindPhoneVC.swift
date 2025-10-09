//
//  BindPhoneVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/3.
//  

import Foundation
import MCToast

class BindPhoneVC: WHBaseViewVC {
    
    var hasPlan = true
    var bindType = "wechat"//wechat  or  apple
    
//    let codeTimer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: .global())
    var getCodeTime = 60
    var timer: Timer?
    
    var invideCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
//        initTimer()
        
        let panGes = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(popGestureAction(gesture: )))
        panGes.edges = .left
        view.addGestureRecognizer(panGes)
    }
    lazy var topVm : BIndPhoneTopVM = {
        let vm = BIndPhoneTopVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: 0, height: 0))
        
        return vm
    }()
    lazy var phoneVm : LoginPhoneButton = {
        let vm = LoginPhoneButton.init(frame: CGRect.init(x: kFitWidth(24), y: kFitWidth(171)+getNavigationBarHeight(), width: 0, height: 0))
        vm.controller = self
        return vm
    }()
    lazy var verifyCodeVm : BindPhoneVerifyCodeButton = {
        let vm = BindPhoneVerifyCodeButton.init(frame: CGRect.init(x: kFitWidth(24), y: kFitWidth(247)+getNavigationBarHeight(), width: 0, height: 0))
        vm.judgeVerifyCodeBlock = {(code)in
            self.judgeCodeNumber(code: code)
        }
        vm.getCodeBlock = {()in
            self.getCodeAction()
        }
        return vm
    }()
    lazy var bindBtn : FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("绑定手机号", for: .normal)
        btn.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.45)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(bindPhoneActino), for: .touchUpInside)
        
        return btn
    }()
    lazy var inviteCodeButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("我有邀请码", for:.normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(showInviteCodeAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var inviteCodeAlertVm: InviteCodeAlertVM = {
        let vm = InviteCodeAlertVM.init(frame: .zero)
        vm.confirmBlock = {(code)in
            self.invideCode = code
            if self.invideCode.count > 0 {
                self.inviteCodeButton.setTitle("邀请码：\(code)", for: .normal)
            }else{
                self.inviteCodeButton.setTitle("我有邀请码", for: .normal)
            }
        }
        return vm
    }()
}

extension BindPhoneVC{
    @objc func showInviteCodeAction(){
        inviteCodeAlertVm.showLoginView()
    }
    @objc func bindPhoneActino() {
        if phoneVm.phoneTextField.text?.count ?? 0 < 7 {
            MCToast.mc_text("请输入正确的手机号",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        if verifyCodeVm.codeTextField.text?.count ?? 0 < 4 {
            MCToast.mc_text("请输入4位数验证码",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        if bindType == "wechat"{
            sendBindPhoneRequest()
        }else{
            sendBindPhoneForAppleRequest()
        }
    }
    func getCodeAction() {
//        if !judgePhoneNumber(phoneNum: phoneVm.phoneTextField.text ?? ""){
//            MCToast.mc_text("请输入正确的手机号",offset: kFitWidth(-100),respond: .respond)
//            return
//        }
        if phoneVm.phoneTextField.text?.count ?? 0 < 7 {
            MCToast.mc_text("请输入正确的手机号",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        UserInfoModel.shared.idc = self.phoneVm.idc
        sendGetCodeRequest(phone: phoneVm.phoneTextField.text ?? "")
    }
    
    func judgeCodeNumber(code:String) {
        if code.count == 4 {
            self.bindBtn.isEnabled = true
            self.bindBtn.backgroundColor = .THEME
        }else{
            self.bindBtn.isEnabled = false
            self.bindBtn.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.45)
        }
    }
    @objc func popGestureAction(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .ended:
            self.backTapAction()
            break
        default:
            break
        }
    }
}
extension BindPhoneVC{
    func initUI() {
        initNavi(titleStr: "")
        
        view.addSubview(topVm)
        view.addSubview(phoneVm)
        view.addSubview(verifyCodeVm)
        view.addSubview(bindBtn)
        view.addSubview(inviteCodeButton)
        
        view.addSubview(inviteCodeAlertVm)
        setConstrait()
    }
    func setConstrait() {
        bindBtn.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(327))
            make.top.equalTo(kFitWidth(323)+getNavigationBarHeight())
            make.height.equalTo(kFitWidth(56))
        }
        inviteCodeButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(-40)-self.getBottomSafeAreaHeight())
        }
    }
//    func initTimer() {
//        self.codeTimer.schedule(deadline: .now(), repeating: .milliseconds(1000))
//        self.codeTimer.setEventHandler {
//            self.getCodeTime = self.getCodeTime - 1
//            
//            if self.getCodeTime < 0{
//                self.codeTimer.suspend()
//                self.getCodeTime = 60
//                DispatchQueue.main.async {
//                    self.verifyCodeVm.getCodeBtn.isUserInteractionEnabled = true
//                    self.verifyCodeVm.getCodeBtn.setTitle("获取验证码", for: .normal)
//                    self.verifyCodeVm.getCodeBtn.setTitleColor(.THEME, for: .normal)
//                }
//            }else{
//                DispatchQueue.main.async {
//                    self.verifyCodeVm.getCodeBtn.isUserInteractionEnabled = false
//                    self.verifyCodeVm.getCodeBtn.setTitleColor(WHColor_16(colorStr: "73B6FF"), for: .normal)
//                    self.verifyCodeVm.getCodeBtn.setTitle("重新发送 \(self.getCodeTime) s", for: .normal)
//                }
//            }
//        }
//    }
    func startCountdown() {
        //一般倒计时是操作UI，使用主队列
        self.getCodeTime = 59
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            // 定时器执行的操作
            self.getCodeTime = self.getCodeTime - 1
            if self.getCodeTime < 0{
//                self.codeTimer.suspend()
                self.disableTimer()
                self.getCodeTime = 60
                DispatchQueue.main.async {
                    self.verifyCodeVm.getCodeBtn.isUserInteractionEnabled = true
                    self.verifyCodeVm.getCodeBtn.setTitle("获取验证码", for: .normal)
                    self.verifyCodeVm.getCodeBtn.setTitleColor(.THEME, for: .normal)
                }
            }else{
                DispatchQueue.main.async {
                    self.verifyCodeVm.getCodeBtn.isUserInteractionEnabled = false
                    self.verifyCodeVm.getCodeBtn.setTitleColor(WHColor_16(colorStr: "73B6FF"), for: .normal)
                    self.verifyCodeVm.getCodeBtn.setTitle("重新发送 \(self.getCodeTime) s", for: .normal)
                }
            }
        }
    }
    func disableTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.verifyCodeVm.getCodeBtn.setTitle("获取验证码", for: .normal)
    }
}

extension BindPhoneVC{
    func sendGetCodeRequest(phone:String){
        MCToast.mc_loading()

        let param = ["phone":"\(phone)",
                     "idc":"\(UserInfoModel.shared.idc)"]
        
//        let param = ["phone":"\(phone)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_send_sms, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
//            self.codeTimer.resume()
            self.verifyCodeVm.getCodeBtn.isUserInteractionEnabled = false
            self.verifyCodeVm.getCodeBtn.setTitleColor(WHColor_16(colorStr: "73B6FF"), for: .normal)
            self.verifyCodeVm.getCodeBtn.setTitle("重新发送 59 s", for: .normal)
            self.startCountdown()
        }
    }
    func sendBindPhoneRequest(){
        MCToast.mc_loading()
        let param = ["phone":"\(phoneVm.phoneTextField.text ?? "")",
                     "code":"\(verifyCodeVm.codeTextField.text ?? "")",
                     "openid":"\(UserInfoModel.shared.wxOpenId)",
                     "invcode":"\(self.invideCode)",
                     "unionid":"\(UserInfoModel.shared.wxUnionId)",
                     "access_token":"\(UserInfoModel.shared.wxAccessToken)",
                     "refresh_token":"\(UserInfoModel.shared.wxRefreshToken)",
                     "headimgurl":"\(UserInfoModel.shared.wxHeadImgUrl)",
                     "nickname":"\(UserInfoModel.shared.wxNickName)"]
//                     "nickname":"\(UserInfoModel.shared.wxNickName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"]
        WHNetworkUtil.shareManager().POST(urlString: URL_bind_phone_wx, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
            
//            let dataObj = responseObject["data"]as? NSDictionary ?? [:]
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            if dataObj["state"]as? Int ?? 1 == 1 {
                UserInfoModel.shared.token = dataObj["token"]as? String ?? ""
                UserInfoModel.shared.uId   = dataObj["uid"]as? String ?? ""
                
                UserDefaults.standard.setValue("\(dataObj["token"]as? String ?? "")", forKey: token)
                UserDefaults.standard.setValue("\(dataObj["uid"]as? String ?? "")", forKey: userId)
                
                WidgetUtils().saveUserInfo(uId: "\(dataObj["uid"]as? String ?? "")", uToken: "\(dataObj["token"]as? String ?? "")")
//                if self.invideCode.count > 0 {
//                    self.sendBindInviteCodeRequest()
//                }else{
                    if QuestinonaireMsgModel.shared.surveytype == "noPlan"{
                        self.changeRootVcToTabbar()
                    }else{
                        self.sendSurveySaveRequest()
                    }
//                }
            }else{
                self.presentAlertVcNoAction(title: "账户已申请注销。", viewController: self)
            }
        }
    }
    
    func sendBindPhoneForAppleRequest(){
        MCToast.mc_loading()
        let param = ["phone":"\(phoneVm.phoneTextField.text ?? "")",
                     "code":"\(verifyCodeVm.codeTextField.text ?? "")",
                     "invcode":"\(self.invideCode)",
                     "appleid":"\(UserInfoModel.shared.appleId)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_bind_phone_apple, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
//            let dataObj = responseObject["data"]as? NSDictionary ?? [:]
//            if dataObj.stringValueForKey(key: "state") == "1" {
                UserInfoModel.shared.token = dataObj["token"]as? String ?? ""
                UserInfoModel.shared.uId   = dataObj["uid"]as? String ?? ""
                
                UserDefaults.standard.setValue("\(dataObj["token"]as? String ?? "")", forKey: token)
                UserDefaults.standard.setValue("\(dataObj["uid"]as? String ?? "")", forKey: userId)
                
//                if self.invideCode.count > 0 {
//                    self.sendBindInviteCodeRequest()
//                }else{
                    if QuestinonaireMsgModel.shared.surveytype == "noPlan"{
                        self.changeRootVcToTabbar()
                    }else{
                        self.sendSurveySaveRequest()
                    }
//                }
//            }else{
//                self.presentAlertVcNoAction(title: "账户已申请注销。", viewController: self)
//            }
        }
    }
    
    func sendBindInviteCodeRequest() {
        let param = ["invcode":"\(self.invideCode)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_bind_inviteCode, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: "\(responseObject)")
            if QuestinonaireMsgModel.shared.surveytype == "noPlan"{
                self.changeRootVcToTabbar()
            }else{
                self.sendSurveySaveRequest()
            }
        }
    }
    
    func sendSurveySaveRequest() {
        MCToast.mc_loading()
        var param = NSDictionary()
        if QuestinonaireMsgModel.shared.surveytype == "custom"{//自定义目标
            param = ["uid":"\(UserInfoModel.shared.uId)",
                     "surveytype":"custom",
                     "calories":"\(QuestinonaireMsgModel.shared.calories)",
                     "protein":"\(QuestinonaireMsgModel.shared.protein)",
                     "carbohydrate":"\(QuestinonaireMsgModel.shared.carbohydrates)",
                     "fat":"\(QuestinonaireMsgModel.shared.fats)"]
            
            WHNetworkUtil.shareManager().POST(urlString: URL_question_custom_save, parameters: param as? [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
                DLLog(message: "\(responseObject)")
                
                self.changeRootVcToTabbar()
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
                    DLLog(message: "\(responseObject)")
//                    if BodyDataSQLiteManager.getInstance().queryTable(sDate: Date().nextDay(days: 0)){
//                        BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "weight", data: "\(QuestinonaireMsgModel.shared.weight)", cTime: Date().nextDay(days: 0))
//                    }else{
//                        BodyDataSQLiteManager.getInstance().updateData(cTime: Date().nextDay(days: 0), imgurl: "", hipsData: "", weightData: "\(QuestinonaireMsgModel.shared.weight)", waistlineData: "", shoulderData: "", bustData: "", thighData: "", calfData: "", bfpData: "", images: "[[],[],[]]", armcircumferenceData: "")
//                    }
                    self.changeRootVcToTabbar()
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
                         "protein":"\(QuestinonaireMsgModel.shared.proteinNumber)",
                         "carbohydrate":"\(QuestinonaireMsgModel.shared.carbohydratesNumber)",
                         "calories":"\(QuestinonaireMsgModel.shared.caloriesNumber)"]
                WHNetworkUtil.shareManager().POST(urlString: URL_question_survey_savepart, parameters: param as? [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
                    DLLog(message: "\(responseObject)")
//                    if BodyDataSQLiteManager.getInstance().queryTable(sDate: Date().nextDay(days: 0)){
//                        BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "weight", data: "\(QuestinonaireMsgModel.shared.weight)", cTime: Date().nextDay(days: 0))
//                    }else{
//                        BodyDataSQLiteManager.getInstance().updateData(cTime: Date().nextDay(days: 0), imgurl: "", hipsData: "", weightData: "\(QuestinonaireMsgModel.shared.weight)", waistlineData: "", shoulderData: "", bustData: "", thighData: "", calfData: "", bfpData: "", images: "[[],[],[]]", armcircumferenceData: "")
//                    }
//                    MCToast.mc_text("计划保存成功")
                    self.changeRootVcToTabbar()
                }
            }
        }
    }
}
