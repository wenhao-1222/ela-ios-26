//
//  MallOrderCreateVC.swift
//  lns
//
//  Created by Elavatine on 2025/9/11.
//

import MCToast


class MallOrderCreateVC: WHBaseViewVC {
    
    var listModel = MarketListModel()
    var detailModel = MallDetailModel()
    var addressModel = AddressModel()
    
    var number = 1
    var specString = ""
    var shippingFee = ""
    var freeShipping = true
    var payAmount = ""
    
    var orderId = ""
    
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
        self.sendOrderPriceRequest()
        DLLog(message: "-----------------------------")
        for i in 0..<detailModel.selectedSpecList.count{
            let d = detailModel.selectedSpecList[i]
            DLLog(message: "\(i) : \(d)")
            specString = specString +  "\(d["specValueName"] ?? "")"
            if i < detailModel.selectedSpecList.count - 1{
                specString = specString + " | "
            }
        }
        DLLog(message: "-----------------------------")
        sendGetDefaultRequest()
        
        NotificationCenter.default.addObserver(self, selector: #selector(alipayResult(notify: )), name: NSNotification.Name(rawValue: "alipayResult"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(wechatPaySuccess(notify: )), name: NSNotification.Name(rawValue: "wechatSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(wechatPayFail(notify: )), name: NSNotification.Name(rawValue: "wechatFail"), object: nil)
    }
    
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: self.getNavigationBarHeight()+kFitWidth(1), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-(self.getNavigationBarHeight()+kFitWidth(1)-self.bottomVm.selfHeight)), style: .plain)
        vi.separatorStyle = .none
        vi.delegate = self
        vi.dataSource = self
        vi.showsVerticalScrollIndicator = false
        vi.rowHeight = UITableView.automaticDimension
        vi.backgroundColor = .COLOR_BG_F2
        vi.contentInsetAdjustmentBehavior = .never
        vi.register(MallConfirmOrderMsgCell.classForCoder(), forCellReuseIdentifier: "MallConfirmOrderMsgCell")
        vi.register(MallConfirmOrderAddressCell.classForCoder(), forCellReuseIdentifier: "MallConfirmOrderAddressCell")
        vi.register(MallConfirmOrderExpCell.classForCoder(), forCellReuseIdentifier: "MallConfirmOrderExpCell")
        
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.payTypeVm.selfHeight+kFitWidth(180)))
        
        footerView.backgroundColor = .COLOR_BG_F2
        footerView.addSubview(payTypeVm)
        footerView.addSubview(desVm)
        vi.tableFooterView = footerView
        
        if #available(iOS 15.0, *) { vi.sectionHeaderTopPadding = 0 }

        return vi
    }()
    
    lazy var payTypeVm: CoursePayOrderPayTypeVM = {
        let vm = CoursePayOrderPayTypeVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var desVm: CoursePayOrderPayDesVM = {
        let bottomHeight = getBottomSafeAreaHeight() > 0 ? (kFitWidth(55)+getBottomSafeAreaHeight()) : kFitWidth(66)
        let vm = CoursePayOrderPayDesVM.init(frame: CGRect.init(x: 0, y: self.payTypeVm.frame.maxY+kFitWidth(1), width: SCREEN_WIDHT, height: kFitWidth(179)))
        vm.backgroundColor = .COLOR_BG_F2
//        let vm = CoursePayOrderPayDesVM.init(frame: CGRect.init(x: 0, y: self.payTypeVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.payTypeVm.frame.maxY-bottomHeight))
        vm.controller = self
        
        return vm
    }()
    lazy var bottomVm: CoursePayOrderPayBottomVM = {
        let vm = CoursePayOrderPayBottomVM.init(frame: .zero)
        let price = Float(number) * self.detailModel.price_sale.floatValue
        vm.updateMoney(money: "\(price)")
        
        vm.payBlocK = {()in
//            let vc = MallPaySuccessVC()
//            vc.model = self.detailModel
//            vc.orderDict = ["ctime":"2025-09-16 15:27:45",
//                            "orderId":"GO202509161527456955",
//                            "address":"山西省太原市小店区不是说不去你那儿么就行吗",
//                            "discountAmount":"0",
//                            "expectedExpressStartTime":"2025-09-19前",
//                            "shippingFee":"20",
//                            "freeShipping":"1",
//                            "totalAmount":"0",
//                            "payAmount":"0.01",
//                            "payChannel":"支付宝",
//                            "payTime":"2025-09-16 15:28:09",
//                            "tradeState":"SUCCESS"]
//            vc.number = self.number
//            self.navigationController?.pushViewController(vc, animated: true)
            if self.payTypeVm.payType == .wechat{
                self.sendOrderPayWeChatRequest()
            }else{
                self.sendOrderPayAlipayRequest()
            }
        }
        
        return vm
    }()
    lazy var addressAlertVm: MallOrderAddressAlertVM = {
        let vm = MallOrderAddressAlertVM.init(frame: .zero)
        vm.onSelectAddress = {(model)in
            self.addressModel = model
            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        }
        return vm
    }()
}

extension MallOrderCreateVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MallConfirmOrderMsgCell") as? MallConfirmOrderMsgCell
            cell?.updateUI(model: self.detailModel,spec: self.specString,number: self.number)
            
            return cell ?? MallConfirmOrderMsgCell()
        }else if indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MallConfirmOrderAddressCell") as? MallConfirmOrderAddressCell
            cell?.updateAddress(model: self.addressModel)
            return cell ?? MallConfirmOrderMsgCell()
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MallConfirmOrderExpCell") as? MallConfirmOrderExpCell
            cell?.updateExpress(shippingFee: self.shippingFee, isfreeShipping: self.freeShipping)
            return cell ?? MallConfirmOrderExpCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1{
//            self.addressAlertVm.showSelf()
            let vc = MyAddressListVC()
            vc.onSelectAddress = {(model)in
                self.addressModel = model
                self.sendOrderPriceRequest()
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            }
            vc.deleteAddressBlock = {(id)in
                if self.addressModel.id == id{
                    self.addressModel = AddressModel()
                    self.sendOrderPriceRequest()
                    self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                    self.sendGetDefaultRequest()
                }
            }
            vc.updateAddressBlock = {(model)in
                self.addressModel = model
                self.sendOrderPriceRequest()
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.payTypeVm.selfHeight+kFitWidth(0)))
//        
//        vi.backgroundColor = .COLOR_BG_F2
//        vi.addSubview(payTypeVm)
//        vi.addSubview(desVm)
//        
//        return vi
//    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return self.payTypeVm.selfHeight + kFitWidth(180)//+kFitWidth(8)
//    }
}

extension MallOrderCreateVC{
    func initUI() {
        initNavi(titleStr: "确认订单")
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(tableView)
        
//        view.addSubview(desVm)
        view.addSubview(bottomVm)
        tableView.frame = CGRect.init(x: 0, y: self.getNavigationBarHeight()+kFitWidth(1), width: SCREEN_WIDHT, height: self.bottomVm.frame.minY-(self.getNavigationBarHeight()+kFitWidth(1)))
//        view.addSubview(addressAlertVm)
    }
}

// MARK: - Network
extension MallOrderCreateVC {
    func sendGetDefaultRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_user_address_getDefault, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "") //as? NSDictionary ?? [:]
            DLLog(message: "sendGetDefaultRequest:\(dataDict)")
            
            let model = AddressModel().dealModelWithDict(dict: dataDict)
            if model.id.count > 1 {
                self.addressModel = model
                self.sendOrderPriceRequest()
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            }
        }
    }
    func sendOrderPriceRequest() {
        if self.addressModel.id.count == 0{
            self.bottomVm.updateMoney(money: "--")
            return
        }
        let param = ["bizType":"2",
                     "id":self.detailModel.id,
                     "quantity":"\(self.number)",
                     "addressId":self.addressModel.id]
        DLLog(message: "sendOrderPriceRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_tutorial_coupon_apply, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "") //as? NSDictionary ?? [:]
            DLLog(message: "sendOrderPriceRequest:\(dataDict)")
            self.payAmount = "\(dataDict.stringValueForKey(key: "payAmount"))"
            self.bottomVm.updateMoney(money: self.payAmount)
            self.freeShipping = dataDict.stringValueForKey(key: "freeShipping") == "1"
            self.shippingFee = dataDict.stringValueForKey(key: "shippingFee")
            self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
        }
    }
    func sendOrderPayWeChatRequest() {
        MCToast.mc_loading()
        let param = ["bizType":"2",
                     "id":self.detailModel.id,
                     "quantity":"\(self.number)",
                     "addressId":self.addressModel.id]
        DLLog(message: "sendOrderPayWeChatRequest:\(param)")
        
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_wechat_order, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendTutorialWechatRequest:\(dataString ?? "")")
            self.orderId = dataObj.stringValueForKey(key: "orderId")
            
            if self.payAmount.floatValue == 0{
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
    func sendOrderPayAlipayRequest() {
        MCToast.mc_loading()
        let param = ["bizType":"2",
                     "id":self.detailModel.id,
                     "quantity":"\(self.number)",
                     "addressId":self.addressModel.id]
        DLLog(message: "sendOrderPayAlipayRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_alipay_order, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            DLLog(message: "sendTutorialAlipayRequest:\(dataString ?? "")")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            self.orderId = dataObj.stringValueForKey(key: "orderId")
            if self.payAmount.floatValue == 0{
                self.sendOrderStatusQueryRequest()
            }else{
                AlipaySDK.defaultService().payOrder(dataObj.stringValueForKey(key: "orderStr"), fromScheme: "elaAlipayScheme") { payObj in
                    DLLog(message: "AlipaySDK result:\(payObj)")
                    self.sendOrderStatusQueryRequest()
                }
            }
        }
    }
    func sendOrderStatusQueryRequest() {
        if self.orderId.count > 0 {
            MCToast.mc_loading(text: "支付结果查询中")
            let param = ["orderId":self.orderId,
                         "bizType":"2"]
            DLLog(message: "sendOrderStatusQueryRequest:\(param)")
            WHNetworkUtil.shareManager().POST(urlString: URL_forum_pay_order_query, parameters: param as [String : AnyObject]) { responseObject in
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
                DLLog(message: "sendOrderStatusQueryRequest:\(dataObj)")
                NotificationCenter.default.removeObserver(self)
                
                if dataObj.stringValueForKey(key: "tradeState") == "SUCCESS" {
                    let vc = MallPaySuccessVC()
                    vc.model = self.detailModel
                    vc.orderDict = dataObj
                    vc.number = self.number
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = CourseOrderListVC()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

extension MallOrderCreateVC{
    @objc func alipayResult(notify:Notification) {
        self.sendOrderStatusQueryRequest()
    }
    @objc func wechatPaySuccess(notify:Notification) {
        self.sendOrderStatusQueryRequest()
    }
    @objc func wechatPayFail(notify:Notification) {
        self.sendOrderStatusQueryRequest()
    }
}
