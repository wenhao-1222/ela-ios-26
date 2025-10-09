//
//  MallPaySuccessVC.swift
//  lns
//
//  Created by Elavatine on 2025/9/16.
//

class cell_model: NSObject {
    
    var title        = ""
    var detailString = ""
    var textColor    = UIColor.COLOR_TEXT_TITLE_0f1214
    
    func initModel(title:String,detail:String,color:UIColor = .COLOR_TEXT_TITLE_0f1214) -> cell_model {
        let model = cell_model()
        model.title = title
        model.detailString = detail
        model.textColor = color
        
        return model
    }
}

class MallPaySuccessVC: WHBaseViewVC {
    
    var model = MallDetailModel()
    var number = 1
    var orderDict = NSDictionary()
    var dataArray:[cell_model] = [cell_model]()
    
    func removeParentNaviVc() {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        dealDataSource()
        
        removeParentNaviVc()
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
        vi.register(MallPaySuccessTopCell.classForCoder(), forCellReuseIdentifier: "MallPaySuccessTopCell")
        vi.register(MallPaySuccessTextCell.classForCoder(), forCellReuseIdentifier: "MallPaySuccessTextCell")
        vi.register(MallPaySuccessBottomCell.classForCoder(), forCellReuseIdentifier: "MallPaySuccessBottomCell")
        
        if #available(iOS 15.0, *) { vi.sectionHeaderTopPadding = 0 }

        return vi
    }()
    lazy var bottomVm: MallPaySuccessBottomVM = {
        let vm = MallPaySuccessBottomVM.init(frame: .zero)
        vm.payBlocK = {()in
            DLLog(message: "查看订单")
            let vc = CourseOrderListVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return vm
    }()
}

extension MallPaySuccessVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MallPaySuccessTopCell")as? MallPaySuccessTopCell
            cell?.updateUI(model: self.model, number: self.number)
            
            return cell ?? MallPaySuccessTopCell()
        }else{
            if indexPath.row <= dataArray.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MallPaySuccessTextCell")as? MallPaySuccessTextCell
                let model = dataArray[indexPath.row-1]
                cell?.updateUI(leftTitle: model.title,
                               detailString: model.detailString,
                               textColor: model.textColor)
                
                return cell ?? MallPaySuccessTextCell()
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MallPaySuccessBottomCell")as? MallPaySuccessBottomCell
                cell?.updateUI(money: orderDict.stringValueForKey(key: "payAmount"))
                
                return cell ?? MallPaySuccessBottomCell()
            }
        }
    }
}

extension MallPaySuccessVC{
    func initUI() {
        initNavi(titleStr: "购买成功")
        
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(tableView)
        view.addSubview(bottomVm)
    }
}

extension MallPaySuccessVC{
    func dealDataSource() {
        dataArray.removeAll()
        if self.orderDict.stringValueForKey(key: "orderId").count > 0 {
            dataArray.append(cell_model().initModel(title: "订单编号", detail: orderDict.stringValueForKey(key: "orderId")))
        }
        if self.orderDict.stringValueForKey(key: "address").count > 0 {
            dataArray.append(cell_model().initModel(title: "收件信息", detail: "\(orderDict.stringValueForKey(key: "address"))"))
        }
        if self.orderDict.stringValueForKey(key: "ctime").count > 0 {
            dataArray.append(cell_model().initModel(title: "下单时间", detail: orderDict.stringValueForKey(key: "ctime")))
        }
        if self.orderDict.stringValueForKey(key: "expectedExpressStartTime").count > 0 {
            dataArray.append(cell_model().initModel(title: "预计发货时间", detail: orderDict.stringValueForKey(key: "expectedExpressStartTime")))
        }
        if self.orderDict.stringValueForKey(key: "payTime").count > 0 {
            dataArray.append(cell_model().initModel(title: "支付时间", detail: orderDict.stringValueForKey(key: "payTime")))
        }
        if self.orderDict.stringValueForKey(key: "payChannel").count > 0 {
            dataArray.append(cell_model().initModel(title: "付款方式", detail: orderDict.stringValueForKey(key: "payChannel")))
        }
        if self.orderDict.stringValueForKey(key: "totalAmount").count > 0 {
            dataArray.append(cell_model().initModel(title: "商品总价", detail: "¥\(orderDict.stringValueForKey(key: "totalAmount"))"))
        }
        if self.orderDict.stringValueForKey(key: "shippingFee").count > 0 {
            if self.orderDict.stringValueForKey(key: "freeShipping") == "1"{
                dataArray.append(cell_model().initModel(title: "运费", detail: "包邮"))
            }else{
                dataArray.append(cell_model().initModel(title: "运费", detail: "¥\(orderDict.stringValueForKey(key: "shippingFee"))"))
            }
        }
        if self.orderDict.stringValueForKey(key: "discountAmount").floatValue > 0 {
            dataArray.append(cell_model().initModel(title: "优惠金额",
                                                    detail: "-¥\(orderDict.stringValueForKey(key: "discountAmount"))",
                                                    color: .THEME))
        }
        self.tableView.reloadData()
    }
}
