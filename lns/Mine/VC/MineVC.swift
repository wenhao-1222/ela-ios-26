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
    override func viewWillAppear(_ animated: Bool) {
        self.personalTopVm.updateUI()
        sendUserCenterRequest()
        getUserConfigRequest()
        sendForumMsgNuberRequest()
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendServiceWelcomeRequest()
        NotificationCenter.default.addObserver(self, selector: #selector(createPlan), name: NSNotification.Name(rawValue: "fullPlanSaveForMine"), object: nil)
        AliPlayerGlobalSettings.setFairPlayCertID("7069e758e56e40eabdab57683b5d815f")
        
//        AlivcBase.environmentManager.setGlobalEnvironment(AlivcGlobalEnv.SEA)
//        AliPrivateService.initLicense()
        AliPlayer.setEnableLog(true)
        AliPlayer.setLogCallbackInfo(LOG_LEVEL_TRACE, callbackBlock: nil)
    }
//    lazy var topVm: MineTopVM = {
//        let vm = MineTopVM.init(frame: .zero)
//        vm.editBlock = {()in
//            self.navigationController?.pushViewController(MaterialVC(), animated: true)
//        }
//        vm.settinBlock = {()in
//            let vc = SettingVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        vm.planListVm.tapBlock = {()in
//            let vc = PlanListVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        vm.createPlanVm.tapBlock = {()in
//            let vc = PlanCreateVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//            vc.createBlock = {()in
//                let vc = PlanListVC()
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
//        return vm
//    }()
    //MARK: 头像+我的目标、数据统计、食物/食谱、轻断食
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
        vm.fastingVm.tapBlock = {()in
            let vc = LogsMealsAlertSetVC()
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
        vm.planVm.tapBlock = {()in
            let vc = PlanListVC()
//            let vc = AliPlayerTest()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.bodyDataVm.tapBlock = {()in
            let vc = BodyDataDetailVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.orderVm.tapBlock = {()in
            let vc = CourseOrderListVC()
//            let vc = WidgetTestVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.settingVm.tapBlock = {()in
            let vc = JournalSettingVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    //MARK: 个性化设置
    lazy var settingVm: PersonalTopFuncItemVM = {
        let vm = PersonalTopFuncItemVM.init(frame: CGRect.init(x: 0, y: self.funcTopVm.frame.maxY+kFitWidth(20), width: 0, height: 0))
        vm.frame = CGRect.init(x:  kFitWidth(16), y: self.funcTopVm.frame.maxY+kFitWidth(20), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(50))
        vm.layer.cornerRadius = kFitWidth(12)
        vm.titleLab.text = "个性化"
        vm.iconImgView.setImgLocal(imgName: "mine_func_personal_setting")
        vm.lineView.isHidden =  true
        vm.tapBlock = {()in
            let vc = JournalSettingVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    //MARK: 联系我们、使用教程、消息通知
    lazy var funcBottomVm: PersonalBottomFuncVM = {
        let vm = PersonalBottomFuncVM.init(frame: CGRect.init(x: 0, y: self.settingVm.frame.maxY+kFitWidth(20), width: 0, height: 0))
        vm.contactVm.tapBlock = {()in
            let vc = ServiceContactVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.tutorialsVm.tapBlock = {()in
            let vc = TutorialsListVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.msgVm.tapBlock = {()in
            let vc = ForumNewsListVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.inviteVm.tapBlock = {()in
            let vc = InviteRewardsVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.frameChangeBlock = {()in
            self.scrollViewBase.contentSize = CGSize.init(width: 0, height: self.funcBottomVm.frame.maxY+self.getTabbarHeight())
        }
        return vm
    }()
//    lazy var funcVm: MineFuncVM = {
//        let vm = MineFuncVM.init(frame: CGRect.init(x: 0, y: self.personalTopVm.frame.maxY-kFitWidth(16), width: 0, height: 0))
//        vm.bodyDataVm.tapBlock = {()in
//            let vc = BodyDataDetailVC()
//            vc.dataType = .weight
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        vm.naturalStatVm.tapBlock = {()in
//            let vc = NaturalStatVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        vm.goalVm.tapBlock = {()in
//            let vc = GoalSetVC()
////            let vc = VdoTestVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        vm.serviceVm.tapBlock = {()in
//            let vc = ServiceContactVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        vm.foodsVm.tapBlock = {()in
//            let vc = MyFoodsListVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        vm.tutorialsVm.tapBlock = {()in
//            let vc = TutorialsListVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        vm.inviteVm.tapBlock = {()in
//            let vc = InviteRewardsVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        vm.forumMsgVm.tapBlock =  {()in
//            let vc = ForumNewsListVC()
////            let vc = ArticlesVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        vm.courseOrderListVm.tapBlock = {()in
//            let vc = CourseOrderListVC()
////            let vc = AliPlayerTest()
////            let vc = ArticlesVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        return vm
//    }()
}

extension MineVC{
    @objc func createPlan() {
        let vc = PlanListVC()
        self.navigationController?.pushViewController(vc, animated: true)
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
        scrollViewBase.addSubview(settingVm)
        scrollViewBase.addSubview(funcBottomVm)
        [personalTopVm, funcTopVm, settingVm, funcBottomVm].forEach { setupExclusiveTouch(in: $0) }

        scrollViewBase.contentSize = CGSize.init(width: 0, height: self.funcBottomVm.frame.maxY+getTabbarHeight())
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
            self.funcBottomVm.updateUI()
            self.personalTopVm.updateUI()
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
