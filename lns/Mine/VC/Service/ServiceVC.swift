//
//  ServiceVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/16.
//


class ServiceVC: WHBaseViewVC {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    lazy var typeLab: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(20), y: getNavigationBarHeight()+kFitWidth(20), width: kFitWidth(200), height: kFitWidth(21)))
        lab.text = "请选择客服类型"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var marketItemVm: ServiceTypeItemVM = {
        let vm = ServiceTypeItemVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(61), width: 0, height: 0))
        vm.titleLab.text = "商品咨询"
        vm.detailLab.text = "商品咨询与售后"
        vm.tapBlock = {()in
            let vc = ServiceContactMarketVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return vm
    }()
    lazy var adviceItemVm: ServiceTypeItemVM = {
        let vm = ServiceTypeItemVM.init(frame: CGRect.init(x: 0, y: self.marketItemVm.frame.maxY, width: 0, height: 0))
        vm.iconImgView.setImgLocal(imgName: "service_type_market")
        vm.titleLab.text = "产品建议"
        vm.detailLab.text = "功能体验不好，想提建议"
        
        vm.tapBlock = {()in
            let vc = ServiceContactVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return vm
    }()
}

extension ServiceVC{
    func initUI() {
        initNavi(titleStr: "联系我们")
        
        navigationView.backgroundColor = .COLOR_BG_F2
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(typeLab)
        view.addSubview(marketItemVm)
        view.addSubview(adviceItemVm)
    }
}
