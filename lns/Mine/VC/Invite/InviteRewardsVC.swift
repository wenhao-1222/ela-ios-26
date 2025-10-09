//
//  InviteRewardsVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/21.
//  

import Foundation


class InviteRewardsVC: WHBaseViewVC {
    
    var msgDict = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendFiessionRequest()
    }
    lazy var topVm: InviteRewardsTopVM = {
        let vm = InviteRewardsTopVM.init(frame: .zero)
        vm.withDrawBlock = {()in
            let vc = WithDrawVC()
            vc.msgDict = self.msgDict
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var inviteCodeVm: InviteRewardsCodeVM = {
        let vm = InviteRewardsCodeVM.init(frame: CGRect.init(x: 0, y: self.topVm.frame.maxY+kFitWidth(8), width: 0, height: 0))
        return vm
    }()
    lazy var ruleVm: InviteRewardsRuleVM = {
        let vm = InviteRewardsRuleVM.init(frame: CGRect.init(x: 0, y: self.inviteCodeVm.frame.maxY+kFitWidth(8), width: 0, height: 0))
        vm.showMoreBlock = {()in
            self.ruleAlertVm.showLoginView()
        }
        return vm
    }()
    lazy var ruleAlertVm: InviteRewardsRuleAlertVM = {
        let vm = InviteRewardsRuleAlertVM.init(frame: .zero)
        return vm
    }()
}

extension InviteRewardsVC{
    func initUI() {
        initNavi(titleStr: "邀请奖励")
        
        view.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        view.addSubview(topVm)
        view.addSubview(inviteCodeVm)
        view.addSubview(ruleVm)
        
        view.addSubview(ruleAlertVm)
    }
}

extension InviteRewardsVC{
    func sendFiessionRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_User_fission_detail, parameters: nil,isNeedToast:true,vc: self) { responseObject in
//            self.msgDict = responseObject["data"]as? NSDictionary ?? [:]
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            self.msgDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            self.topVm.refreshUI(dict: self.msgDict)
            UserInfoModel.shared.wxNickName = self.msgDict.stringValueForKey(key: "nickname")
            UserInfoModel.shared.wxHeadImgUrl = self.msgDict.stringValueForKey(key: "headimgurl")
            
        }
    }
}
