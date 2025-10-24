//
//  CourseOrderListVC.swift
//  lns
//
//  Created by Elavatine on 2025/7/22.
//

import UIKit

class CourseOrderListVC: WHBaseViewVC {

    var status = "" // 1 待支付   3 已支付
    var dataSourceArray = NSMutableArray()
    
    func removeParentNaviVc() {
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is CoursePayOrderVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is MallDetailVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is MallOrderCreateVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is MallPaySuccessVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sendOrderListRequest()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()

        removeParentNaviVc()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshStatus(notify:)), name: NOTIFI_NAME_REFRESH_COURSE_STATUS, object: nil)
    }

    lazy var topTypeVm: CourseOrderListTypeVM = {
        let vm = CourseOrderListTypeVM(frame: .zero)
        vm.typeChangeBlock = { [weak self] index in
            guard let self else { return }
            if index == 0 { self.status = "" }
            else if index == 1 { self.status = "1" }
            else if index == 2 { self.status = "3" }
            self.initSkeletonData()
            self.sendOrderListRequest()
        }
        return vm
    }()

    lazy var tableView: UITableView = {
        let vi = UITableView(frame: CGRect(x: 0, y: self.topTypeVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT - self.topTypeVm.frame.maxY), style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.backgroundColor = .COLOR_BG_F5
        vi.register(OrderListTableViewCell.self, forCellReuseIdentifier: "OrderListTableViewCell")
        vi.register(OrderListMallTableViewCell.self, forCellReuseIdentifier: "OrderListMallTableViewCell")
        vi.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) { vi.sectionHeaderTopPadding = 0 }

        return vi
    }()

    lazy var nodataVm: TableViewNoDataVM = {
        let vm = TableViewNoDataVM(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(50)))
        vm.noDataLabel.text = "- 暂无订单 -"
        vm.isHidden = true
        return vm
    }()
}

// MARK: - Noti
extension CourseOrderListVC {
    @objc func refreshStatus(notify: Notification) {
        NotificationCenter.default.removeObserver(self)
        sendOrderListRequest()
    }
}

// MARK: - UITableView
extension CourseOrderListVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dict = (self.dataSourceArray[indexPath.row] as? NSDictionary) ?? [:]
        
        if dict.stringValueForKey(key: "bizType") == "1"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderListTableViewCell", for: indexPath) as! OrderListTableViewCell
            cell.timeOutBlock = { [weak self] in self?.sendOrderListRequest() }
            cell.payBlock = { [weak self] in
                guard let self else { return }
                let vc = CourseOrderPayAlertVC()
                vc.msgDict = dict
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    // iPhone：保持你原有的视觉（透明背景 + 自定义底部弹出）
                    vc.modalPresentationStyle = .pageSheet
                    vc.modalTransitionStyle = .crossDissolve
                    self.present(vc, animated: true)
                }
            
                vc.paySuccessBlock = { dic in
                    let v = CoursePayResultVC()
                    v.msgDict = dict
                    v.orderDict = dic
                    self.navigationController?.pushViewController(v, animated: true)
                }
            }
            cell.closeBlock = { [weak self] in
                self?.sendCloseOrderRequest(dict: dict, indexPath: indexPath, bizType: "1")
            }
            cell.changeBlock = { [weak self] in
                guard let self else { return }
                self.presentAlertVc(confirmBtn: "确定",
                                    message: "课程仅允许更换一次设备",
                                    title: "课程是否更换设备",
                                    cancelBtn: "取消",
                                    handler: { _ in
                                        let v = CourseChangeDeviceVC()
                                        v.orderId = dict.stringValueForKey(key: "id")
                                        self.navigationController?.pushViewController(v, animated: true)
                                    }, viewController: self)
            }

            cell.updateUI(dict: dict)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderListMallTableViewCell", for: indexPath) as! OrderListMallTableViewCell
            
            cell.timeOutBlock = { [weak self] in self?.sendOrderListRequest() }
            cell.saleAfterBlock = {()in
                DLLog(message: "售后--申请售后")
                
                let vc = MallOrderAfterSaleVC()
                vc.orderDict = dict
                vc.number = dict.stringValueForKey(key: "quantity").intValue
                vc.orderModel = MallDetailModel().dealDataForOrderList(dict: dict)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            cell.payBlock = { [weak self] in
                guard let self else { return }
                let vc = CourseOrderPayAlertVC()
                vc.msgDict = dict
                vc.bizType = "2"
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    // iPhone：保持你原有的视觉（透明背景 + 自定义底部弹出）
                    vc.modalPresentationStyle = .pageSheet
                    vc.modalTransitionStyle = .crossDissolve
                    self.present(vc, animated: true)
                }
                
                vc.paySuccessBlock = { dic in
                    let v = MallPaySuccessVC()
                    v.model = MallDetailModel().dealDataForOrderList(dict: dict)
                    v.orderDict = dic
                    v.number = dict.stringValueForKey(key: "quantity").intValue
                    self.navigationController?.pushViewController(v, animated: true)
                }
            }
            cell.closeBlock = {()in
                self.sendCloseOrderRequest(dict: dict, indexPath: indexPath, bizType: "2")
            }
            cell.disableSaleAfterBlock = {()in
                let vc = MallOrderAfterSaleNotSupportVC()
                vc.orderDict = dict
                vc.number = dict.stringValueForKey(key: "quantity").intValue
                vc.orderModel = MallDetailModel().dealDataForOrderList(dict: dict)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            cell.tapBlock = {()in
                let vc = MallOrderDetailVC()
                vc.orderDict = dict
                vc.number = dict.stringValueForKey(key: "quantity").intValue
                vc.orderModel = MallDetailModel().dealDataForOrderList(dict: dict)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            cell.updateUI(dict: dict)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = self.dataSourceArray[indexPath.row] as? NSDictionary ?? [:]
        if dict.stringValueForKey(key: "bizType") == "2"{
//            let vc = MallOrderDetailVC()
//            vc.orderDict = dict
//            vc.number = dict.stringValueForKey(key: "quantity").intValue
//            vc.orderModel = MallDetailModel().dealDataForOrderList(dict: dict)
//            self.navigationController?.pushViewController(vc, animated: true)
        }else{
//            if dict.stringValueForKey(key: "status") == "3" {
                let courseDict = NSMutableDictionary(dictionary: dict)
                courseDict.setValue(dict.stringValueForKey(key: "tutorialId"), forKey: "id")
                let vc = CourseListVC()
                vc.parentDict = courseDict
                vc.headMsgDict = courseDict
                vc.isFromOrderList = true
                self.navigationController?.pushViewController(vc, animated: true)
//            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vi = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(20)))
        vi.backgroundColor = .COLOR_BG_F5
        return vi
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFitWidth(20)
    }
}

// MARK: - UI & Skeleton 开关
extension CourseOrderListVC {
    func initUI() {
        initNavi(titleStr: "我的订单")
        view.insertSubview(topTypeVm, belowSubview: self.navigationView)
        view.backgroundColor = .COLOR_BG_F5

        view.addSubview(tableView)
        view.addSubview(nodataVm)
        nodataVm.frame = CGRect(x: 0, y: getNavigationBarHeight() + kFitWidth(185), width: SCREEN_WIDHT, height: kFitWidth(50))

        initSkeletonData()
    }

    func initSkeletonData() {
        dataSourceArray.removeAllObjects()
        for _ in 0..<5 { dataSourceArray.add(["bizType":"1"]) }
        tableView.reloadData()

    }
}

// MARK: - 网络
extension CourseOrderListVC {
    func sendCloseOrderRequest(dict: NSDictionary, indexPath: IndexPath,bizType:String) {
        let param = ["orderId": dict.stringValueForKey(key: "id"),
                     "bizType":bizType]
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_order_close, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { _ in
            self.dataSourceArray.removeObject(at: indexPath.row)
            if self.dataSourceArray.count > 0 {
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                self.tableView.isHidden = true
                self.nodataVm.isHidden = false
            }
        }
    }

    func sendOrderListRequest() {
        if status.isEmpty {
            WHNetworkUtil.shareManager().POST(urlString: URL_forum_order_list, parameters: nil) { responseObject in
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
                let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
                DLLog(message: "sendOrderListRequest:\(dataArr)")
//                DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                    self.dealDataSource(dataArr: dataArr)
//                })
            }
        } else {
            let param = ["status": status]
            WHNetworkUtil.shareManager().POST(urlString: URL_forum_order_list, parameters: param as [String : AnyObject]) { responseObject in
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
                let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
                DLLog(message: "sendOrderListRequest:\(dataArr)")
//                DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                    self.dealDataSource(dataArr: dataArr)
//                })
            }
        }
    }

    func dealDataSource(dataArr: NSArray) {
        self.dataSourceArray = NSMutableArray(array: dataArr)
        if self.dataSourceArray.count > 0 {
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self.tableView.isHidden = false
            self.topTypeVm.isHidden = false
//            })
            UIView.animate(withDuration: 0.25, delay: 0,options: .curveEaseInOut) {
                self.tableView.alpha = 1
                self.topTypeVm.alpha = 1
                self.nodataVm.alpha = 0
            }completion: { _ in
                self.nodataVm.isHidden = true
                self.tableView.reloadData()
            }
//            self.nodataVm.isHidden = true
//            self.topTypeVm.isHidden = false
//            self.tableView.reloadData()
        } else {
            self.nodataVm.alpha = 0
            self.nodataVm.isHidden = false
            
//            UIView.animate(withDuration: 0.25, delay: 0, animations: {
//                if self.status.isEmpty {
//                    self.tableView.isHidden = true
//                    self.topTypeVm.isHidden = true
//                }
//                self.nodataVm.isHidden = false
//            })
            UIView.animate(withDuration: 0.25, delay: 0,options: .curveEaseInOut) {
                self.tableView.alpha = 0
                if self.status.isEmpty{
                    self.topTypeVm.alpha = 0
                }
                self.nodataVm.alpha = 1
            }completion: { _ in
                self.tableView.isHidden = true
                if self.status.isEmpty{
                    self.topTypeVm.isHidden = true
                }
            }
        }
    }
}
