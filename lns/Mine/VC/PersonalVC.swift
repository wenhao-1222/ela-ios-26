//
//  PersonalVC.swift
//  lns
//
//  Created by Elavatine on 2025/8/20.
//


import Foundation
import UIKit
import MCToast

class PersonalVC : WHBaseViewVC {
    override func viewWillAppear(_ animated: Bool) {
        self.topVm.updateUI()
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
    }
    lazy var topVm: MineTopVM = {
        let vm = MineTopVM.init(frame: .zero)
        vm.editBlock = {()in
            self.navigationController?.pushViewController(MaterialVC(), animated: true)
        }
        vm.settinBlock = {()in
            let vc = SettingVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.planListVm.tapBlock = {()in
            let vc = PlanListVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.createPlanVm.tapBlock = {()in
            let vc = PlanCreateVC()
            self.navigationController?.pushViewController(vc, animated: true)
            vc.createBlock = {()in
                let vc = PlanListVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return vm
    }()
    lazy var funcVm: MineFuncVM = {
        let vm = MineFuncVM.init(frame: CGRect.init(x: 0, y: self.topVm.frame.maxY-kFitWidth(16), width: 0, height: 0))
        vm.bodyDataVm.tapBlock = {()in
            let vc = BodyDataDetailVC()
            vc.dataType = .weight
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.naturalStatVm.tapBlock = {()in
            let vc = NaturalStatVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.goalVm.tapBlock = {()in
            let vc = GoalSetVC()
//            let vc = VdoTestVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.serviceVm.tapBlock = {()in
            let vc = ServiceContactVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.foodsVm.tapBlock = {()in
            let vc = MyFoodsListVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.tutorialsVm.tapBlock = {()in
            let vc = TutorialsListVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.inviteVm.tapBlock = {()in
            let vc = InviteRewardsVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.forumMsgVm.tapBlock =  {()in
            let vc = ForumNewsListVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vm.courseOrderListVm.tapBlock = {()in
            let vc = CourseOrderListVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var guideCreatePlanAlertVM: GuideMineCreatePlanAlertVM = {
        let vm = GuideMineCreatePlanAlertVM.init(frame: .zero)
        vm.createPlanVm.tapBlock = {()in
            self.guideCreatePlanAlertVM.isHidden = true
            UserDefaults.standard.setValue("1", forKey: guide_mine_create_plan)
            let vc = PlanCreateVC()
            self.navigationController?.pushViewController(vc, animated: true)
            vc.createBlock = {()in
                let vc = PlanListVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return vm
    }()
}

extension PersonalVC{
    @objc func createPlan() {
        let vc = PlanListVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PersonalVC{
    func initUI(){
        view.addSubview(topVm)
        view.addSubview(funcVm)
    }
}

extension PersonalVC{
    func sendUserCenterRequest() {
        let param = ["uid":"\(UserInfoModel.shared.uId)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_User_Center, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            UserInfoModel.shared.updateMsg(dict: dataObj)
            self.funcVm.updateUI()
            self.topVm.updateUI()
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

            self.funcVm.updateForumUnReadNum(unReadNum: dataObj.stringValueForKey(key: "unreadCount"))
        }
    }
}
