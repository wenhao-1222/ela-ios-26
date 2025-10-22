//
//  CoursePayOrderVC.swift
//  lns
//
//  Created by Elavatine on 2025/7/17.
//

import MCToast

class CoursePayOrderVC: WHBaseViewVC {
    
    var msgDict = NSDictionary()
    var parentId = ""
    var orderId = ""
    
    var payDict = NSDictionary()
    
    override func didReceiveMemoryWarning() {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: - Life Cycle
    deinit {
        DLLog(message: "CoursePayOrderVC   deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(alipayResult(notify: )), name: NSNotification.Name(rawValue: "alipayResult"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(wechatPaySuccess(notify: )), name: NSNotification.Name(rawValue: "wechatSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(wechatPayFail(notify: )), name: NSNotification.Name(rawValue: "wechatFail"), object: nil)
    }
    
    lazy var topMsgVm: CoursePayOrderMsgVM = {
        let vm = CoursePayOrderMsgVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(1), width: 0, height: 0))
        vm.updateUI(dict: self.msgDict)
        return vm
    }()
    lazy var couponVm: CoursePayOrderCouponVM = {
        let vm = CoursePayOrderCouponVM.init(frame: CGRect.init(x: 0, y: self.topMsgVm.frame.maxY + kFitWidth(8), width: 0, height: 0))
        vm.couponApplyBlock = {()in
            self.sendCouponApplyRequest()
        }
        vm.deleteCouponBlock = {()in
            self.payDict = NSDictionary()
            self.bottomVm.updateMoney(money: self.msgDict.stringValueForKey(key: "price"))
        }
        return vm
    }()
    lazy var payTypeVm: CoursePayOrderPayTypeVM = {
        let vm = CoursePayOrderPayTypeVM.init(frame: CGRect.init(x: 0, y: self.couponVm.frame.maxY+kFitWidth(8), width: 0, height: 0))
        return vm
    }()
    lazy var desVm: CoursePayOrderPayDesVM = {
        let bottomHeight = getBottomSafeAreaHeight() > 0 ? (kFitWidth(55)+getBottomSafeAreaHeight()) : kFitWidth(66)
        let vm = CoursePayOrderPayDesVM.init(frame: CGRect.init(x: 0, y: self.payTypeVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.payTypeVm.frame.maxY-bottomHeight))
        vm.controller = self
        vm.tipsTapBlock = {()in
//            PopupView().present(in: self.view)
            self.tipsPopupView.showSelf()
        }
        
        return vm
    }()
    lazy var bottomVm: CoursePayOrderPayBottomVM = {
        let vm = CoursePayOrderPayBottomVM.init(frame: .zero)
        vm.updateMoney(money: self.msgDict.stringValueForKey(key: "price"))
        
        vm.payBlocK = {()in
            if self.payTypeVm.payType == .wechat{
                self.sendTutorialWechatRequest()
            }else{
                self.sendTutorialAlipayRequest()
            }
        }
        
        return vm
    }()
    lazy var tipsPopupView: CoursePayTipsPopupView = {
        let vi = CoursePayTipsPopupView.init(frame: .zero)
        
        return vi
    }()
}

extension CoursePayOrderVC{
    func initUI() {
        initNavi(titleStr: "确认订单")
        view.backgroundColor = .COLOR_BG_F5
        
        view.addSubview(topMsgVm)
        view.addSubview(couponVm)
        view.addSubview(payTypeVm)
        view.addSubview(desVm)
        view.addSubview(bottomVm)
        
        view.addSubview(tipsPopupView)
    }
}

extension CoursePayOrderVC{
    func sendCouponApplyRequest() {
        let param = ["id":parentId,
                     "bizType":"1",
                     "couponCode":"\(self.couponVm.codeInputText.text ?? "")"]
        DLLog(message: "\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_tutorial_coupon_apply, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendCouponApplyRequest:\(dataDict)")
            self.payDict = dataDict
            self.couponVm.showCouponMsg(dict: self.payDict)
            self.bottomVm.updateDiscountMonet(dict: self.payDict)
            
            EventLogUtils().sendEventLogRequest(eventName: .CLICK_BUTTON,
                                                scenarioType: .launch_view,
                                                text: "教程支付页【\(self.msgDict.stringValueForKey(key: "title"))】:\(self.msgDict.stringValueForKey(key: "id")) couponCode : \(self.couponVm.codeInputText.text ?? "")")
        }
    }
    
    func sendTutorialAlipayRequest() {
        MCToast.mc_loading()
        let couponCode = payDict.stringValueForKey(key: "discountAmount").count > 0 ? (self.couponVm.codeInputText.text ?? "") : ""
        var payAmount = self.msgDict.stringValueForKey(key: "price")//payDict.stringValueForKey(key: "payAmount").count > 0 ? payDict.stringValueForKey(key: "payAmount") : self.msgDict.stringValueForKey(key: "price")
        
        var param = ["id":parentId,
                     "bizType":"1",
                     "payAmount":self.msgDict.stringValueForKey(key: "price"),
                     "phoneName":"\(UIDevice.current.name)",
                     "deviceId":DeviceUUIDManager.shared.uuidWithoutHyphen] as [String:String]
        
        if payDict.stringValueForKey(key: "discountAmount").count > 0{
            payAmount = payDict.stringValueForKey(key: "payAmount")
            param = ["id":parentId,
                     "bizType":"1",
                     "payAmount":payDict.stringValueForKey(key: "payAmount"),
                     "discountAmount":payDict.stringValueForKey(key: "discountAmount"),
                     "couponCode":couponCode,
                     "phoneName":"\(UIDevice.current.name)",
                     "deviceId":DeviceUUIDManager.shared.uuidWithoutHyphen]
        }
        
        DLLog(message: "sendTutorialAlipayRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_alipay_order, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            DLLog(message: "sendTutorialAlipayRequest:\(dataString ?? "")")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            self.orderId = dataObj.stringValueForKey(key: "orderId")
            
            EventLogUtils().sendEventLogRequest(eventName: .CLICK_BUTTON,
                                                scenarioType: .course_create_order,
                                                text: "订单编号：\(dataObj.stringValueForKey(key: "orderId")) 支付宝支付")
            
            EventLogUtils().sendEventLogRequest(eventName: .CLICK_BUTTON,
                                                scenarioType: .launch_view,
                                                text: "教程支付页【\(self.msgDict.stringValueForKey(key: "title"))】:\(self.msgDict.stringValueForKey(key: "id"))  订单编号：\(dataObj.stringValueForKey(key: "orderId")) 支付方式 : 支付宝")
            
            if payAmount.floatValue == 0 {
                self.sendOrderStatusQueryRequest()
            }else{
                AlipaySDK.defaultService().payOrder(dataObj.stringValueForKey(key: "orderStr"), fromScheme: "elaAlipayScheme") { payObj in
                    DLLog(message: "AlipaySDK result:\(payObj)")
                    self.sendOrderStatusQueryRequest()
                }
            }
        }
    }
    
    func sendTutorialWechatRequest() {
        MCToast.mc_loading()
        let couponCode = payDict.stringValueForKey(key: "discountAmount").count > 0 ? (self.couponVm.codeInputText.text ?? "") : ""
        var payAmount = self.msgDict.stringValueForKey(key: "price")//payDict.stringValueForKey(key: "payAmount").count > 0 ? payDict.stringValueForKey(key: "payAmount") : self.msgDict.stringValueForKey(key: "price")
        
        var param = ["id":parentId,
                     "bizType":"1",
                     "payAmount":self.msgDict.stringValueForKey(key: "price"),
                     "phoneName":"\(UIDevice.current.name)",
                     "deviceId":DeviceUUIDManager.shared.uuidWithoutHyphen] as [String:String]
        
        if payDict.stringValueForKey(key: "discountAmount").count > 0{
            payAmount = payDict.stringValueForKey(key: "payAmount")
            param = ["id":parentId,
                     "bizType":"1",
                     "payAmount":payDict.stringValueForKey(key: "payAmount"),
                     "discountAmount":payDict.stringValueForKey(key: "discountAmount"),
                     "couponCode":couponCode,
                     "phoneName":"\(UIDevice.current.name)",
                     "deviceId":DeviceUUIDManager.shared.uuidWithoutHyphen]
        }
        DLLog(message: "sendTutorialWechatRequest:\(param)")
        
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_wechat_order, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendTutorialWechatRequest:\(dataString ?? "")")
            EventLogUtils().sendEventLogRequest(eventName: .CLICK_BUTTON,
                                                scenarioType: .course_create_order,
                                                text: "订单编号：\(dataObj.stringValueForKey(key: "orderId"))  微信支付")
            EventLogUtils().sendEventLogRequest(eventName: .CLICK_BUTTON,
                                                scenarioType: .launch_view,
                                                text: "教程支付页【\(self.msgDict.stringValueForKey(key: "title"))】:\(self.msgDict.stringValueForKey(key: "id"))  订单编号：\(dataObj.stringValueForKey(key: "orderId"))  支付方式 : 微信")
            self.orderId = dataObj.stringValueForKey(key: "orderId")
            if payAmount.floatValue == 0 {
                self.sendOrderStatusQueryRequest()
            }else{
                let request = PayReq()
                request.partnerId = dataObj.stringValueForKey(key: "partnerid")
                request.prepayId = dataObj.stringValueForKey(key: "prepayid")
                request.package = "Sign=WXPay"
                request.nonceStr = dataObj.stringValueForKey(key: "noncestr")
                request.timeStamp = UInt32(dataObj.stringValueForKey(key: "timestamp").intValue)
                request.sign = dataObj.stringValueForKey(key: "sign")

                WXApi.send(request)
            }
        }
    }
    func sendOrderStatusQueryRequest() {
        if self.orderId.count > 0 {
            MCToast.mc_loading(text: "支付结果查询中")
            let param = ["orderId":self.orderId,
                         "bizType":"1"]
            DLLog(message: "sendOrderStatusQueryRequest:\(param)")
            WHNetworkUtil.shareManager().POST(urlString: URL_forum_pay_order_query, parameters: param as [String : AnyObject]) { responseObject in
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
                DLLog(message: "sendOrderStatusQueryRequest:\(dataString ?? "")")
                
                NotificationCenter.default.removeObserver(self)
                
                if dataObj.stringValueForKey(key: "tradeState") == "SUCCESS" {
                    NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_COURSE_STATUS, object: nil)
                    let vc = CoursePayResultVC()
                    vc.msgDict = self.msgDict
                    vc.orderDict = dataObj
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = CourseOrderListVC()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

extension CoursePayOrderVC{
    @objc func keyboardWillHide(notification: NSNotification) {
        let couponCode = self.couponVm.codeInputText.text ?? ""
        if couponCode.count > 0 {
            let couponCodeStr = couponCode.replacingOccurrences(of: " ", with: "")
            if couponCodeStr.count == 0 {
                self.couponVm.cancelInputTapAction()
            }
        }else{
            self.couponVm.cancelInputTapAction()
        }
    }
    @objc func alipayResult(notify:Notification) {
        let result = notify.object as? NSDictionary ?? [:]
        
//        if result.stringValueForKey(key: "resultStatus") == "9000"{
//            MCToast.mc_success("支付宝支付成功！")
            self.sendOrderStatusQueryRequest()
//        }else{
//            self.presentAlertVc(confirmBtn: "确定", message: "", title: "\(result.stringValueForKey(key: "memo"))", cancelBtn: nil, handler: { action in
//                
//            }, viewController: self)
//        }
    }
    @objc func wechatPaySuccess(notify:Notification) {
//        self.presentAlertVcNoAction(title: "微信支付成功", viewController: self)
        self.sendOrderStatusQueryRequest()
    }
    @objc func wechatPayFail(notify:Notification) {
//        self.presentAlertVcNoAction(title: "微信支付失败", viewController: self)
        self.sendOrderStatusQueryRequest()
    }
}
