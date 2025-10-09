//
//  WithDrawVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/21.
//

import Foundation
import MCToast

class WithDrawVC: WHBaseViewVC {
    
    var msgDict = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        NotificationCenter.default.addObserver(self, selector: #selector(sendBindWeChatRequest), name: Notification.Name(rawValue: "wechatBind"), object: nil)
        
        DLLog(message: "\(msgDict)")
    }
    lazy var wechatMsgVm : WithDrawWechatVM = {
        let vm = WithDrawWechatVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(20), width: SCREEN_WIDHT, height: 0))
        
        vm.tapBlock = {()in
            if UserInfoModel.shared.isBindWeChat{
//                self.presentAlertVc(confirmBtn: "确认", message: "解绑微信账号后将无法继续使用它登录该Elavatine账号", title: "确认解绑", cancelBtn: "取消", handler: { action in
////                    self.sendUnbindWeChatRequest()
//                }, viewController: self)
            }else{
                if WXApi.isWXAppInstalled(){
                    WXUtil().wxLogin()
                }else{
                    self.presentAlertVcNoAction(title: "请安装微信客户端", viewController: self)
                }
            }
        }
//        vm.refresUI(dict: self.msgDict)
        return vm
    }()
    lazy var moneyVm: WithDrawMoneyVM = {
        let vm = WithDrawMoneyVM.init(frame: CGRect.init(x: 0, y: self.wechatMsgVm.frame.maxY, width: 0, height: 0))
        vm.money = msgDict.stringValueForKey(key: "money")
        vm.limitMoney = Float(msgDict.doubleValueForKey(key: "withdrawalLimits")/100)
        
        vm.tipsLabel.text = "可提现余额 ￥\(msgDict.stringValueForKey(key: "money"))"
        vm.numberChangeBlock = {(t)in
            self.confirmButton.isEnabled = t
        }
        return vm
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("确认提现", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .disabled)
        btn.isEnabled = false
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        
        return btn
    }()
}
extension WithDrawVC{
    @objc func submitAction() {
//        if UserInfoModel.shared.isBindWeChat == false{
//            MCToast.mc_text("请先绑定提现微信账户",offset: kFitWidth(-100),respond: .respond)
//            return
//        }
        let money = moneyVm.moneyTextField.text ?? ""
        if money.doubleValue > msgDict.doubleValueForKey(key: "money"){
            MCToast.mc_text("提现金额不能超过可提现余额（\(msgDict.stringValueForKey(key: "money"))元）",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        
        if money.doubleValue > 200{
            MCToast.mc_text("单笔提现金额不能超过200元",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        
        sendWithDrawRequest()
    }
}

extension WithDrawVC{
    func initUI(){
        initNavi(titleStr: "提现")
        
        view.backgroundColor = .white
        view.addSubview(wechatMsgVm)
        view.addSubview(moneyVm)
        view.addSubview(confirmButton)
        
        setCosntrait()
    }
    func setCosntrait() {
        confirmButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(moneyVm.snp.bottom).offset(kFitWidth(20))
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(48))
        }
    }
}

extension WithDrawVC{
    @objc func sendBindWeChatRequest() {
        let param = ["openid":UserInfoModel.shared.wxOpenId,
                     "unionid":UserInfoModel.shared.wxUnionId]
        WHNetworkUtil.shareManager().POST(urlString: URL_wechat_bind, parameters: param as [String:AnyObject],isNeedToast: true,vc:self) { responseObject in
            UserInfoModel.shared.isBindWeChat = true
            self.wechatMsgVm.updateUI()
        }
    }
    @objc func sendWithDrawRequest(){
        let moneyStr = moneyVm.moneyTextField.text ?? ""
        let money = moneyStr.doubleValue * 100
        let param = ["amount":"\(WHUtils.convertStringToStringNoDigit("\(money)") ?? "")"]
        WHNetworkUtil.shareManager().POST(urlString: URL_wx_withdraw, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            self.presentAlertVc(confirmBtn: "确定", message: "我们已收到您的请求，请留意微信消息", title: "温馨提示", cancelBtn: nil, handler: { action in
                self.navigationController?.popToRootViewController(animated: true)
            }, viewController: self)
        }
    }
}
