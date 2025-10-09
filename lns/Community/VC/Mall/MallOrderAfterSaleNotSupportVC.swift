//
//  MallOrderAfterSaleNotSupportVC.swift
//  lns
//
//  Created by Elavatine on 2025/9/25.
//


class MallOrderAfterSaleNotSupportVC: WHBaseViewVC {
    
    var orderDict = NSDictionary()
    var orderModel = MallDetailModel()
    var number = 1
    
    var cellNumber = 4
    
    var returnType = 0
    var returnReason = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: self.getNavigationBarHeight()+kFitWidth(1), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-(self.getNavigationBarHeight()+kFitWidth(1)+self.bottomVm.selfHeight)), style: .plain)
        vi.separatorStyle = .none
        vi.delegate = self
        vi.dataSource = self
        vi.showsVerticalScrollIndicator = false
        vi.rowHeight = UITableView.automaticDimension
        vi.backgroundColor = .COLOR_BG_F2
        vi.contentInsetAdjustmentBehavior = .never
        vi.sectionFooterHeight = 0
        vi.register(MallPaySuccessTopCell.classForCoder(), forCellReuseIdentifier: "MallPaySuccessTopCell")
        vi.register(MallOrderAfterSaleNotSupportCell.classForCoder(), forCellReuseIdentifier: "MallOrderAfterSaleNotSupportCell")
        
        
        if #available(iOS 15.0, *) { vi.sectionHeaderTopPadding = 0 }
        

        return vi
    }()
    lazy var bottomVm: MallPaySuccessBottomVM = {
        let vm = MallPaySuccessBottomVM.init(frame: .zero)
        vm.payButton.setTitle("联系客服", for: .normal)
        vm.payButton.setBackgroundImage(createImageWithColor(color: .COLOR_GRAY_C4C4C4), for: .disabled)
        vm.payButton.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        vm.payButton.isEnabled = true
        vm.payBlocK = {()in
            let vc = ServiceContactVC()
            vc.relatedOrderId = self.orderDict.stringValueForKey(key: "id")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return vm
    }()
}


extension MallOrderAfterSaleNotSupportVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MallPaySuccessTopCell")as? MallPaySuccessTopCell
            cell?.updateUI(model: self.orderModel, number: self.number)
            cell?.dottedLineView.isHidden = true
            
            return cell ?? MallPaySuccessTopCell()
        }else{// indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MallOrderAfterSaleNotSupportCell")as? MallOrderAfterSaleNotSupportCell
            cell?.updateUI(titleStr: "退货换货规则", detailString: "1、不支持退换货的情况有哪些；\n2、哪些情况支持退换货")
            
            return cell ?? MallOrderAfterSaleNotSupportCell()
        }
    }
}

extension MallOrderAfterSaleNotSupportVC{
    func initUI() {
        initNavi(titleStr: "售后服务")
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(tableView)
        view.addSubview(bottomVm)
    }
}
