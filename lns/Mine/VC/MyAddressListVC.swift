//
//  MyAddressListVC.swift
//  lns
//  收货地址
//  Created by Elavatine on 2025/9/11.
//


class MyAddressListVC: WHBaseViewVC {
    
    var dataSourceArray:[AddressModel] = [AddressModel]()
    var defaultIndex = -1
    /// 选择回调（可选）
    var onSelectAddress: ((AddressModel) -> Void)?
    var deleteAddressBlock:((String)->())?
    var updateAddressBlock:((AddressModel)->())?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sendAddressListRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: self.getNavigationBarHeight()+kFitWidth(1), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-(self.getNavigationBarHeight()+kFitWidth(1) + self.bottomVm.selfHeight)), style: .plain)
        vi.separatorStyle = .none
        vi.delegate = self
        vi.dataSource = self
        vi.showsVerticalScrollIndicator = false
        vi.rowHeight = UITableView.automaticDimension
        vi.backgroundColor = .COLOR_BG_F2
        vi.contentInsetAdjustmentBehavior = .never
        vi.register(AddressTableViewCell.classForCoder(), forCellReuseIdentifier: "AddressTableViewCell")
        
        if #available(iOS 15.0, *) { vi.sectionHeaderTopPadding = 0 }

        return vi
    }()
    lazy var nodataLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: kFitWidth(162), width: SCREEN_WIDHT, height: kFitWidth(20)))
        lab.text = "-无收件地址-"
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.textAlignment = .center
        lab.isHidden = true
        
        return lab
    }()
    lazy var bottomVm: AddressListBottomVM = {
        let vm = AddressListBottomVM.init(frame: .zero)
        vm.addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        
        return vm
    }()
}

extension MyAddressListVC{
    @objc func addButtonAction(){
        let vc = MyAddressDetailVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MyAddressListVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nodataLabel.isHidden = dataSourceArray.count > 0 ? true : false
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell")as? AddressTableViewCell
        
        let model = dataSourceArray[indexPath.row]
        cell?.udpateUI(model:model)
        
        cell?.setDefaultBlock = {()in
            if model.isDefault == false{
                self.sendSetDefaultAddressRequest(model: model, indexPath: indexPath)
            }
        }
        cell?.editBlock = {()in
            let vc = MyAddressDetailVC()
            vc.isUpdate = true
            vc.addressModel = model
            vc.updateBlock = {(addressModel)in
                self.sendAddressListRequest()
                self.updateAddressBlock?(addressModel)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        cell?.deleteBlock = {()in
            self.presentAlertVc(confirmBtn: "删除", message: "", title: "是否删除地址？", cancelBtn: "取消", handler: { action in
                self.sendDeleteAddressRequest(id: model.id,indexPath:indexPath)
            }, viewController: self)
        }
        
        return cell ?? AddressTableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSourceArray[indexPath.row]
        onSelectAddress?(model)
        self.backTapAction()
    }
}

extension MyAddressListVC{
    func initUI() {
        initNavi(titleStr: "收件地址")
        initData()
        view.addSubview(tableView)
        tableView.addSubview(nodataLabel)
        
        view.addSubview(bottomVm)

    }
    func initData() {
        let model = AddressModel()
        model.contactName = ""
        dataSourceArray.append(model)
        dataSourceArray.append(model)
        dataSourceArray.append(model)
        dataSourceArray.append(model)
    }
}

extension MyAddressListVC{
    func sendAddressListRequest(){
        WHNetworkUtil.shareManager().POST(urlString: URL_user_address_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendAddressListRequest:\(dataArray)")
            
            self.dataSourceArray.removeAll()
            self.defaultIndex = -1
            for i in 0..<dataArray.count{
                let model = AddressModel().dealModelWithDict(dict: dataArray[i]as? NSDictionary ?? [:])
                self.dataSourceArray.append(model)
                
                if model.isDefault {
                    self.defaultIndex = i
                }
            }
//            DispatchQueue.main.asyncAfter(deadline: .now()+5, execute: {
                self.tableView.reloadData()
//            })
        }
    }
    func sendDeleteAddressRequest(id:String,indexPath:IndexPath) {
        let param = ["id":id]
        WHNetworkUtil.shareManager().POST(urlString: URL_user_address_delete, parameters: param as [String : AnyObject]) { responseObject in
            self.dataSourceArray.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.deleteAddressBlock?(id)
        }
    }
    func sendSetDefaultAddressRequest(model:AddressModel,indexPath:IndexPath) {
        let param = ["id":model.id,
                     "isDefault":"1"]
        WHNetworkUtil.shareManager().POST(urlString: URL_user_address_setDefault, parameters: param as [String : AnyObject]) { responseObject in
            if self.defaultIndex >= 0{
                let defaultModel = self.dataSourceArray[self.defaultIndex]
                defaultModel.isDefault = false
                self.dataSourceArray[self.defaultIndex] = defaultModel
                UIView.performWithoutAnimation {
                    self.tableView.reloadRows(at: [IndexPath(row: self.defaultIndex, section: 0)], with: .none)
                }
            }

            model.isDefault = true
            
            self.dataSourceArray[indexPath.row] = model
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            self.defaultIndex = indexPath.row
        }
    }
}
