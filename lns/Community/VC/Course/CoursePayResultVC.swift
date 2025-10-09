//
//  CoursePayResultVC.swift
//  lns
//
//  Created by Elavatine on 2025/7/22.
//


class CoursePayResultVC: WHBaseViewVC {
    
    var msgDict = NSDictionary()
    var orderDict = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is CoursePayOrderVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
            if let index = controllers.firstIndex(where: { $0 is CourseOrderListVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
        
        EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW,
                                            scenarioType: .launch_view,
                                            text: "教程支付成功【\(self.msgDict.stringValueForKey(key: "title"))】:\(self.msgDict.stringValueForKey(key: "id"))  订单编号 : \(self.orderDict.stringValueForKey(key: "id"))")
        UserInfoModel.shared.event_log_session_id = ""
    }
    lazy var topMsgVm: CoursePayResultTopVM = {
        let vm = CoursePayResultTopVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: 0))
        vm.updateUI(dict: self.msgDict)
        return vm
    }()
    lazy var orderNoItemVm: CoursePayResultItemVM = {
        let vm = CoursePayResultItemVM.init(frame: CGRect.init(x:0, y: self.topMsgVm.frame.maxY+kFitWidth(15), width: 0, height: 0))
        vm.leftTitleLab.text = "订单编号"
        vm.rightDetailLab.text = self.orderDict.stringValueForKey(key: "id")
        return vm
    }()
    lazy var orderTimeItemVm: CoursePayResultItemVM = {
        let vm = CoursePayResultItemVM.init(frame: CGRect.init(x:0, y: self.orderNoItemVm.frame.maxY, width: 0, height: 0))
        vm.leftTitleLab.text = "下单时间"
        vm.rightDetailLab.text = self.orderDict.stringValueForKey(key: "ctime")
        return vm
    }()
    lazy var orderPayTimeItemVm: CoursePayResultItemVM = {
        let vm = CoursePayResultItemVM.init(frame: CGRect.init(x:0, y: self.orderTimeItemVm.frame.maxY, width: 0, height: 0))
        vm.leftTitleLab.text = "支付时间"
        if self.orderDict.stringValueForKey(key: "payTime").count > 0 {
            vm.rightDetailLab.text = self.orderDict.stringValueForKey(key: "payTime")
        }else{
            vm.rightDetailLab.text = self.orderDict.stringValueForKey(key: "ctime")
        }
        
        return vm
    }()
    lazy var orderPayTypeItemVm: CoursePayResultItemVM = {
        let vm = CoursePayResultItemVM.init(frame: CGRect.init(x:0, y: self.orderPayTimeItemVm.frame.maxY, width: 0, height: 0))
        vm.leftTitleLab.text = "付款方式"
        if self.orderDict.doubleValueForKey(key: "payChannel") > 0 {
            vm.rightDetailLab.text = self.orderDict.stringValueForKey(key: "payChannel")
        }else{
            vm.rightDetailLab.text = "优惠码"
        }
        
        return vm
    }()
    lazy var orderCouponItemVm: CoursePayResultItemVM = {
        let vm = CoursePayResultItemVM.init(frame: CGRect.init(x:0, y: self.orderPayTypeItemVm.frame.maxY, width: 0, height: 0))
        vm.leftTitleLab.text = "优惠券"
        vm.rightDetailLab.textColor = .THEME
        return vm
    }()
    lazy var dottedLineView: DottedLineView = {
        let vi = DottedLineView.init(frame: CGRect.init(x: kFitWidth(20), y: self.orderCouponItemVm.frame.maxY+kFitWidth(15), width: SCREEN_WIDHT-kFitWidth(40), height: kFitHeight(1)))
        
        return vi
    }()
    lazy var priceLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.text = "实际总价："
        return lab
    }()
    lazy var priceLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        return lab
    }()
    lazy var grayBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        
        return vi
    }()
    lazy var bottomVm: CoursePayResultBottomVM = {
        let vm = CoursePayResultBottomVM.init(frame: .zero)
        vm.showButton.addTarget(self, action: #selector(backToCourseAction), for: .touchUpInside)
        return vm
    }()
}

extension CoursePayResultVC{
    @objc func backToCourseAction() {
        var hasCourseList = false
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is CourseListVC }) {
//                controllers.remove(at: index)
//                nav.viewControllers = controllers
                hasCourseList = true
//                BreatheSymbolEffect
            }
        }
        if hasCourseList{
            self.backTapAction()
        }else{
            let vc = CourseListVC()
            vc.parentDict = self.msgDict
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension CoursePayResultVC{
    func initUI() {
        initNavi(titleStr: "购买成功")
        
        view.addSubview(topMsgVm)
        view.addSubview(orderNoItemVm)
        view.addSubview(orderTimeItemVm)
        view.addSubview(orderPayTimeItemVm)
        view.addSubview(orderPayTypeItemVm)
        view.addSubview(orderCouponItemVm)
        view.addSubview(dottedLineView)
        view.addSubview(priceLab)
        view.addSubview(priceLabel)
        view.addSubview(grayBgView)
        view.addSubview(bottomVm)
        
        setConstrait()
        updateUI()
    }
    func updateUI() {
        orderNoItemVm.rightDetailLab.text = orderDict.stringValueForKey(key: "id")
        orderTimeItemVm.rightDetailLab.text = orderDict.stringValueForKey(key: "ctime")
        orderPayTimeItemVm.rightDetailLab.text = orderDict.stringValueForKey(key: "payTime")
        orderPayTypeItemVm.rightDetailLab.text = orderDict.stringValueForKey(key: "payChannel")
        
        priceLabel.text = "¥ \(orderDict.stringValueForKey(key: "payAmount"))"
        
        if orderDict.stringValueForKey(key: "discountAmount").floatValue > 0 {
            orderCouponItemVm.rightDetailLab.text = "- ¥ \(orderDict.stringValueForKey(key: "discountAmount"))"
        }else{
            orderCouponItemVm.isHidden = true
        }
    }
    func setConstrait() {
        priceLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(dottedLineView.snp.bottom).offset(kFitWidth(20))
        }
        priceLab.snp.makeConstraints { make in
            make.right.equalTo(priceLabel.snp.left).offset(kFitWidth(-7))
            make.centerY.lessThanOrEqualTo(priceLabel)
        }
        grayBgView.snp.makeConstraints { make in
            make.left.bottom.width.equalToSuperview()
            make.top.equalTo(priceLabel.snp.bottom).offset(kFitWidth(25))
        }
    }
}
