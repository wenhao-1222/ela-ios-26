//
//  MineVC.swift
//  lns
//
//  Created by LNS2 on 2024/3/21.
//

import Foundation
import UIKit
import MCToast
import AliyunPlayer

class MineVC : WHBaseViewVC {
    
    var bottomGap = kFitWidth(20)
//    var isAiCoachSurveyFinished = "-1"//是否做过AI教练问卷    0  未做过   1  做过     -1 本地状态：还未请求数据
//    var isVip = "-1"  //0  非VIP   1  VIP     -1 本地状态：还未请求数据
//    var aiCoachDict = NSDictionary()
    
    override func viewWillAppear(_ animated: Bool) {
        self.personalTopVm.updateUI()
        self.funcTopVm.updateUI()
        sendUserCenterRequest()
        getUserConfigRequest()
        sendFriendPendingListRequest()
//        sendForumMsgNuberRequest()
        //2026年02月04日13:41:23   个性化设置新功能红点不再显示
//        settingVm.redView.isHidden = UserInfoModel.shared.settingNewFuncRead
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    public override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.fd_interactivePopDisabled = false
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
//        sendCoachLaunchRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 26.0, *) {
            bottomGap = kFitWidth(20)
        }
        
        initUI()
        sendServiceWelcomeRequest()
        NotificationCenter.default.addObserver(self, selector: #selector(createPlan), name: NSNotification.Name(rawValue: "fullPlanSaveForMine"), object: nil)
    }
    //MARK: 头像+我的目标、数据统计、食物/餐食、轻断食
    lazy var personalTopVm: PersonalTopVM = {
        let vm = PersonalTopVM.init(frame: .zero)
        vm.goalVm.tapBlock = {()in
            let vc = GoalSetVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.statVm.tapBlock = {()in
            let vc = NaturalStatVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.mealVm.tapBlock = {()in
            let vc = MyFoodsListVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
//        vm.fastingVm.tapBlock = {()in
//            let vc = LogsMealsAlertSetVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        vm.friendsVm.tapBlock = {()in
            let vc = FriendRankingVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        vm.settinBlock = {()in
            let vc = SettingVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.editBlock = {()in
            let vc = MaterialVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    //MARK: 我的计划、身体数据、订单、个性化
    lazy var funcTopVm: PersonalTopFuncVM = {
        let vm = PersonalTopFuncVM.init(frame: CGRect.init(x: 0, y: self.personalTopVm.frame.maxY+kFitWidth(6), width: 0, height: 0))
        vm.frameChangeBlock = { [weak self] in
            self?.updateMineLayout()
        }
        vm.planVm.tapBlock = {()in
            let vc = PlanListVC()
//            let vc = AICoachReportPDFDemoVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.bodyDataVm.tapBlock = {()in
//            self.gotoAicoachAction()
            let vc = BodyDataDetailVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.fastingVm.tapBlock = {()in
            let vc = LogsMealsAlertSetVC()
//            let vc = AICoachPreVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.orderVm.tapBlock = {()in
            let vc = CourseOrderListVC()
//            let vc = WidgetTestVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.honorVm.tapBlock = {()in
            let vc = HonorVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.communityVm.tapBlock = {()in
//            let vc = AIEnergyOrbVC()
            let vc = CourseVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.elaproVm.tapBlock = {()in
            let vc = MineElaProVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    //MARK: 个性化设置
//    lazy var settingVm: PersonalTopFuncItemVM = {
//        let vm = PersonalTopFuncItemVM.init(frame: CGRect.init(x: 0, y: self.funcTopVm.frame.maxY+kFitWidth(20), width: 0, height: 0))
//        vm.frame = CGRect.init(x:  kFitWidth(16), y: self.funcTopVm.frame.maxY+kFitWidth(20), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(50))
//        vm.layer.cornerRadius = kFitWidth(12)
//        vm.titleLab.text = "个性化"
//        vm.iconImgView.setImgLocal(imgName: "mine_func_personal_setting")
//        vm.lineView.isHidden =  true
//        vm.tapBlock = {()in
//            let vc = JournalSettingVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        return vm
//    }()
    //MARK: 联系我们、使用教程、消息通知
    lazy var funcBottomVm: PersonalBottomFuncVM = {
        let vm = PersonalBottomFuncVM.init(frame: CGRect.init(x: 0, y: self.funcTopVm.frame.maxY+kFitWidth(20), width: 0, height: 0))
        vm.settingVm.tapBlock = {()in
            let vc = JournalSettingVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.contactVm.tapBlock = {()in
            let vc = ServiceContactVC()
//            let vc = ServiceVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
//        vm.tutorialsVm.tapBlock = {()in
//            let vc = TutorialsListVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        vm.msgVm.tapBlock = {()in
//            let vc = ForumNewsListVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        vm.inviteVm.tapBlock = {()in
//            let vc = InviteRewardsVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        vm.frameChangeBlock = {()in
            self.scrollViewBase.contentSize = CGSize.init(width: 0, height: self.funcBottomVm.frame.maxY+self.getTabbarHeight()+self.bottomGap)
        }
        return vm
    }()
}

extension MineVC{
    @objc func createPlan() {
        let vc = PlanListVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func gotoAicoachAction() {
//        if isVip == "0"{//非VIP ，重新做问卷，走付费墙
//            let vc = AIGuidanceVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }else if isVip == "1"{//VIp 直接进AI教练 PDF  报告页
//            let vc = AICoachPreVC()
//            vc.dataDict = aiCoachDict
//            self.navigationController?.pushViewController(vc, animated: true)
//        }else{
//            
//        }
    }
    func sendFriendPendingListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_friend_pengding_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
            self.personalTopVm.friendsVm.redView.isHidden = dataArray.count == 0
        }
    }
}

extension MineVC{
    func updateMineLayout() {
//        settingVm.frame = CGRect.init(x: settingVm.frame.origin.x, y: funcTopVm.frame.maxY+kFitWidth(20), width: settingVm.frame.width, height: settingVm.frame.height)
        funcBottomVm.frame = CGRect.init(x: funcBottomVm.frame.origin.x, y: funcTopVm.frame.maxY+kFitWidth(20), width: funcBottomVm.frame.width, height: funcBottomVm.frame.height)
        scrollViewBase.contentSize = CGSize.init(width: 0, height: self.funcBottomVm.frame.maxY+getTabbarHeight()+self.bottomGap)
    }
}

extension MineVC{
    
    func initUI(){
        view.addSubview(scrollViewBase)
        scrollViewBase.backgroundColor = .COLOR_BG_F2
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
//        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getTabbarHeight())
        scrollViewBase.addSubview(personalTopVm)
        scrollViewBase.addSubview(funcTopVm)
//        scrollViewBase.addSubview(settingVm)
        scrollViewBase.addSubview(funcBottomVm)
        [personalTopVm, funcTopVm, funcBottomVm].forEach { setupExclusiveTouch(in: $0) }
//        [personalTopVm, funcTopVm, settingVm, funcBottomVm].forEach { setupExclusiveTouch(in: $0) }

        scrollViewBase.contentSize = CGSize.init(width: 0, height: self.funcBottomVm.frame.maxY+getTabbarHeight()+self.bottomGap)
    }
}

extension MineVC{
    func sendUserCenterRequest() {
        let param = ["uid":"\(UserInfoModel.shared.uId)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_User_Center, parameters: param as [String : AnyObject]) { responseObject in
//            DLLog(message: "sendUserCenterRequest:\(responseObject)")
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            UserInfoModel.shared.updateMsg(dict: dataObj)
//            self.funcBottomVm.updateUI()
            self.personalTopVm.updateUI()
            self.funcTopVm.updateUI()
        }
    }
    func sendServiceWelcomeRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_User_Service_config, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendServiceWelcomeRequest:\(dataObj)")
            
            UserInfoModel.shared.serviceWelcome = dataObj["chat_welcome"]as? String ?? "\(UserInfoModel.shared.serviceWelcome)"
            UserInfoModel.shared.serviceResponce = dataObj["chat_reply"]as? String ?? "\(UserInfoModel.shared.serviceResponce)"
        }
    }
    func getUserConfigRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_config_msg, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "getUserConfigRequest:\(dataObj)")
            UserInfoModel.shared.updateUserConfig(dict: dataObj)
        }
    }
    func sendForumMsgNuberRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_msg_count, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendForumMsgNuberRequest:\(dataObj)")
//            self.funcBottomVm.updateForumUnReadNum(unReadNum: "3")
            self.funcBottomVm.updateForumUnReadNum(unReadNum: dataObj.stringValueForKey(key: "unreadCount"))
        }
    }
}
