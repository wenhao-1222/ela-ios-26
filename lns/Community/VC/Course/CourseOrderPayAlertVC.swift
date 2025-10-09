//
//  CourseOrderPayAlertVC.swift
//  lns
//
//  Created by Elavatine on 2025/7/23.
//


import UIKit
import MCToast

class CourseOrderPayAlertVC: WHBaseViewVC {
    
    var msgDict = NSDictionary()
    var bizType = "1"
    var bgViewHeight = kFitWidth(360)//+getBottomSafeAreaHeight()
    var topGap = SCREEN_HEIGHT-kFitWidth(360)
    
    var paySuccessBlock:((NSDictionary)->())?
    
    override func didReceiveMemoryWarning() {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: - Life Cycle
    deinit {
        DLLog(message: "CoursePayOrderVC   deinit")
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        bgViewHeight = kFitWidth(360)+getBottomSafeAreaHeight()
//        topGap = SCREEN_HEIGHT - bgViewHeight
        showWhiteView()
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear // 注意此处！清除背景！
        // 禁止系统 pageSheet 在非 whiteView 区域响应上划手势，避免 whiteView 闪烁
        if #available(iOS 15.0, *) {
            if let sheet = self.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = false
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
        }
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        bgViewHeight = kFitWidth(360)-kFitWidth(129)+getBottomSafeAreaHeight()+payTypeVm.selfHeight
        topGap = SCREEN_HEIGHT - bgViewHeight
        
        initUI()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            view.backgroundColor = .COLOR_BG_WHITE
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(alipayResult(notify: )), name: NSNotification.Name(rawValue: "alipayResult"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(wechatPaySuccess(notify: )), name: NSNotification.Name(rawValue: "wechatSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(wechatPayFail(notify: )), name: NSNotification.Name(rawValue: "wechatFail"), object: nil)
        if bizType == "1"{
            EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW,
                                                scenarioType: .launch_view,
                                                text: "教程继续支付【\(self.msgDict.stringValueForKey(key: "title"))】:\(self.msgDict.stringValueForKey(key: "id"))  订单编号 : \(self.msgDict.stringValueForKey(key: "id"))")
        }
    }
    // 白色卡片区域
    lazy var whiteView: UIView = {
//        let vi = UIView.init(frame: CGRect.init(x: 0, y: topGap+SCREEN_HEIGHT, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-topGap+kFitWidth(16)))
        let vi = UIView.init(frame: CGRect.init(x: 0, y: topGap, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-topGap+kFitWidth(16)))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var titleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.font = .systemFont(ofSize: 17, weight: .semibold)
        lab.text = "选择支付方式"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        return lab
    }()
    lazy var cancelBtn: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.4), for: .highlighted)
        
        btn.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        
        return btn
    }()
    lazy var payTypeVm: CoursePayOrderPayTypeVM = {
        let vm = CoursePayOrderPayTypeVM.init(frame: CGRect.init(x: 0, y: self.titleLab.frame.maxY, width: 0, height: 0))
        vm.cancelBtn.isHidden = false
        vm.cancelBtn.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        return vm
    }()
    lazy var desVm: CoursePayOrderPayDesVM = {
//        let bottomHeight = getBottomSafeAreaHeight() > 0 ? (kFitWidth(55)+getBottomSafeAreaHeight()) : kFitWidth(66)
        let vm = CoursePayOrderPayDesVM.init(frame: CGRect.init(x: 0, y: self.payTypeVm.frame.maxY, width: SCREEN_WIDHT, height: kFitWidth(120)))
        vm.controller = self
        
        return vm
    }()
    lazy var bottomVm: CoursePayOrderPayBottomVM = {
        let vm = CoursePayOrderPayBottomVM.init(frame: .zero)

        if self.msgDict.doubleValueForKey(key: "discountAmount") > 0 {
            vm.updateDiscountMonet(dict: self.msgDict)
        }else{
            vm.updateMoney(money: self.msgDict.stringValueForKey(key: "payAmount"))
        }
        
        vm.payBlocK = {()in
            if self.payTypeVm.payType == .wechat{
                self.sendTutorialWechatRequest()
            }else{
                self.sendTutorialAlipayRequest()
            }
        }
        
        return vm
    }()
}

extension CourseOrderPayAlertVC{
    func showWhiteView() {
        whiteView.transform = CGAffineTransform(translationX: 0, y: whiteView.bounds.height)
        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut) {
//            self.whiteView.transform = .identity
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
        }completion: { _ in
//            self.whiteView.transform = .identity
        }
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
            self.whiteView.transform = .identity
        }
    }
    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .curveEaseIn) {
//            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteView.bounds.height)
            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: self.bgViewHeight+kFitWidth(16))
        } completion: { _ in
//            self.dismiss(animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05, execute: {
//            self.dismiss(animated: true)
//            self.backTapAction()
            if (self.navigationController != nil) {
                self.navigationController?.popViewController(animated: true)
            }else{
                self.dismiss(animated: true) {
                }
            }
        })
//        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
//            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: self.bgViewHeight+kFitWidth(16))
//        }
    }
}

extension CourseOrderPayAlertVC{
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

extension CourseOrderPayAlertVC{
    // 初始化 UI
    func initUI() {
        view.backgroundColor = .clear//UIColor.black.withAlphaComponent(0.1)//.clear // 关键点：整个 VC 背景透明
        view.addSubview(whiteView)
        
        whiteView.addSubview(titleLab)
        whiteView.addSubview(payTypeVm)
//        whiteView.addSubview(cancelBtn)
        
        whiteView.addSubview(desVm)
        whiteView.addSubview(bottomVm)
        
        setConstraints()
        
        desVm.refreshFrame()
        bottomVm.frame = CGRect.init(x: 0, y: self.desVm.frame.maxY, width: SCREEN_WIDHT, height: self.bottomVm.selfHeight)
    }

    // 自动布局
    func setConstraints() {
        titleLab.snp.makeConstraints { make in
//            make.top.equalTo(kFitWidth(15))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(54))
            make.left.equalTo(kFitWidth(20))
        }
//        cancelBtn.snp.makeConstraints { make in
//            make.right.top.equalToSuperview()
//            make.width.height.equalTo(kFitWidth(54))
//        }
    }
}

extension CourseOrderPayAlertVC{
    func sendTutorialAlipayRequest() {
        MCToast.mc_loading()
        let param = ["orderId":self.msgDict.stringValueForKey(key: "id"),
                     "bizType":"\(bizType)"] as [String:String]
        
        DLLog(message: "sendTutorialAlipayRequest:\(param)")
        if bizType == "1"{
            EventLogUtils().sendEventLogRequest(eventName: .CLICK_BUTTON,
                                                scenarioType: .launch_view,
                                                text: "教程继续支付(支付宝)【\(self.msgDict.stringValueForKey(key: "title"))】:\(self.msgDict.stringValueForKey(key: "id"))  订单编号 : \(self.msgDict.stringValueForKey(key: "id"))")
        }
        
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_alipay_order_re, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            DLLog(message: "sendTutorialAlipayRequest:\(dataString ?? "")")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            AlipaySDK.defaultService().payOrder(dataObj.stringValueForKey(key: "orderStr"), fromScheme: "elaAlipayScheme") { payObj in
                DLLog(message: "AlipaySDK result:\(payObj)")
                self.sendOrderStatusQueryRequest()
            }
        }
    }
    
    func sendTutorialWechatRequest() {
        MCToast.mc_loading()
        let param = ["orderId":self.msgDict.stringValueForKey(key: "id"),
                     "bizType":"\(bizType)"] as [String:String]
        DLLog(message: "sendTutorialWechatRequest:\(param)")
        if bizType == "1"{
            EventLogUtils().sendEventLogRequest(eventName: .CLICK_BUTTON,
                                                scenarioType: .launch_view,
                                                text: "教程继续支付(微信)【\(self.msgDict.stringValueForKey(key: "title"))】:\(self.msgDict.stringValueForKey(key: "id"))  订单编号 : \(self.msgDict.stringValueForKey(key: "orderId"))")
        }
        
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_wechat_order_re, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendTutorialWechatRequest:\(dataString ?? "")")
            
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
    func sendOrderStatusQueryRequest() {
//        MCToast.mc_loading(text: "支付结果查询中")
        let param = ["orderId":self.msgDict.stringValueForKey(key: "id"),
                     "bizType":"\(bizType)"]
        DLLog(message: "sendOrderStatusQueryRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_pay_order_query, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendOrderStatusQueryRequest:\(dataString ?? "")")
            
            NotificationCenter.default.removeObserver(self)
            
            if dataObj.stringValueForKey(key: "tradeState") == "SUCCESS" {
                NotificationCenter.default.post(name: NOTIFI_NAME_REFRESH_COURSE_STATUS, object: dataObj)
                self.backTapAction()
                self.paySuccessBlock?(dataObj)
            }
        }
    }
}
