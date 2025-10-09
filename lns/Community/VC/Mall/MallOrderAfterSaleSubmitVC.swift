//
//  MallOrderAfterSaleSubmitVC.swift
//  lns
//
//  Created by Elavatine on 2025/9/22.
//

class MallOrderAfterSaleSubmitVC: WHBaseViewVC {
    
    var type = ""
    var reason = ""
    var images:[UIImage] = [UIImage]()
    var time = Date().currentSeconds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is MallOrderAfterSaleVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
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
        vi.register(MallOrderAfterSaleSubmitTopCell.classForCoder(), forCellReuseIdentifier: "MallOrderAfterSaleSubmitTopCell")
        vi.register(MallOrderAfterSaleSubmitMsgCell.classForCoder(), forCellReuseIdentifier: "MallOrderAfterSaleSubmitMsgCell")
        if #available(iOS 15.0, *) { vi.sectionHeaderTopPadding = 0 }
        

        return vi
    }()
    lazy var bottomVm: MallPaySuccessBottomVM = {
        let vm = MallPaySuccessBottomVM.init(frame: .zero)
        vm.payButton.setTitle("查看", for: .normal)
        vm.payBlocK = {()in
//            self.sendRefundOrderRequest()
            self.backTapAction()
        }
        
        return vm
    }()
}

extension MallOrderAfterSaleSubmitVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MallOrderAfterSaleSubmitTopCell") as? MallOrderAfterSaleSubmitTopCell
            
            return cell ?? MallOrderAfterSaleSubmitTopCell()
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MallOrderAfterSaleSubmitMsgCell") as? MallOrderAfterSaleSubmitMsgCell
            cell?.updateUI(type: type,
                           reason: reason,
                           time: time,
                           imgs: images,
                           imgUrls: nil)
            
            return cell ?? MallOrderAfterSaleSubmitMsgCell()
        }
    }
}


extension MallOrderAfterSaleSubmitVC{
    func initUI() {
        initNavi(titleStr: "售后服务")
        
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(tableView)
        view.addSubview(bottomVm)
    }
}
