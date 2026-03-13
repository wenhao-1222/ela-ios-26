//
//  DietPlanBuyListVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/12.
//


class DietPlanBuyListVC: WHBaseViewVC {
    
    var selectedDates = [String]()
    var foodsArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        if selectedDates.count > 0 {
            createBuyListRequest()
        }else{
            sendBuyListRequest()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
    }
    lazy var listAddButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = kFitWidth(12)
        btn.setTitle("+ 新购物清单", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.backgroundColor = .COLOR_CARD_BG_WHITE
        
        btn.addTarget(self, action: #selector(addFoodsAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var timeLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 17, weight: .medium)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        if selectedDates.count > 0 {
            lab.text = "\(selectedDates[0]) 至 \(selectedDates[selectedDates.count - 1])"
        }
        
        
        return lab
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.contentInsetAdjustmentBehavior = .never
        table.dataSource = self
        table.delegate = self
        table.register(DietPlanBuyListFoodsCell.self, forCellReuseIdentifier: DietPlanBuyListFoodsCell.reuseId)
        return table
    }()
    
    lazy var bottomGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    lazy var topGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    lazy var bottomGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    lazy var topGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
}

extension DietPlanBuyListVC{
    func initUI() {
        initNavi(titleStr: "购物清单")
        view.backgroundColor = .COLOR_BG_F2
        
        view.addSubview(listAddButton)
        view.addSubview(tableView)
        view.addSubview(topGradientView)
        view.addSubview(bottomGradientView)
        view.addSubview(timeLabel)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)
        topGradientView.layer.addSublayer(topGradientLayer)
        
        setConstrait()
        
        self.backArrowButton.tapBlock = {()in
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    func setConstrait() {
        listAddButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(58))
            make.top.equalTo(kFitWidth(20)+self.getNavigationBarHeight())
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(listAddButton.snp.bottom).offset(kFitWidth(25))
            make.height.equalTo(kFitWidth(25))
        }
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(timeLabel.snp.bottom)//.offset(kFitWidth(10))
            make.bottom.equalToSuperview()
        }
        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tableView.snp.top)//.offset(kFitWidth(-10))
            make.height.equalTo(kFitWidth(15))
        }
        bottomGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(35)+self.getTopSafeAreaHeight())
        }
    }
}

extension DietPlanBuyListVC{
    @objc func addFoodsAction() {
        self.backTapAction()
    }
    func updateSelectStatus(indexPath: IndexPath) {
        if self.foodsArray.count > indexPath.row{
            let dict = NSMutableDictionary(dictionary: self.foodsArray[indexPath.row]as? NSDictionary ?? [:])
            if dict.stringValueForKey(key: "checked") == "0"{
                dict.setValue("1", forKey: "checked")
                self.sendFoodsCheckRequest(check: "1", id: dict.stringValueForKey(key: "id"))
            }else{
                dict.setValue("0", forKey: "checked")
                self.sendFoodsCheckRequest(check: "0", id: dict.stringValueForKey(key: "id"))
            }
            self.foodsArray.replaceObject(at: indexPath.row, with: dict)
            tableView.reloadRows(at: [indexPath], with: .none)
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}

extension DietPlanBuyListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        foodsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DietPlanBuyListFoodsCell.reuseId, for: indexPath) as? DietPlanBuyListFoodsCell ?? DietPlanBuyListFoodsCell()
        
        let dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
        cell.updateUI(title: dict.stringValueForKey(key: "fname"),
                      weight: "\(dict.stringValueForKey(key: "qty")) \(dict.stringValueForKey(key: "spec"))",
                      isSelected: dict.stringValueForKey(key: "checked") == "1")
        
        return cell
    }
//    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.updateSelectStatus(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        kFitWidth(64)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(5)))
        return vi
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFitWidth(5)
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(35)+self.getBottomSafeAreaHeight()))
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return kFitWidth(35)+self.getBottomSafeAreaHeight()
    }
}

extension DietPlanBuyListVC{
    func createBuyListRequest() {
        let param = ["sdates":self.selectedDates]
        DLLog(message: "生成购物清单参数：\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_shopping_list_create, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "createBuyListRequest:\(dataObj)")
            
            self.foodsArray = NSMutableArray(array: dataObj["shoppingList"]as? NSArray ?? [])
            self.tableView.reloadData()
        }
    }
    func sendBuyListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_shopping_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendBuyListRequest:\(dataObj)")
            
            let startDate = dataObj.stringValueForKey(key: "startDate")
            let endDate = dataObj.stringValueForKey(key: "endDate")
            if startDate.count > 0 && endDate.count > 0{
                self.timeLabel.text = "\(startDate) 至 \(endDate)"
            }else if startDate.count > 0{
                self.timeLabel.text = "\(startDate)"
            }else if endDate.count > 0{
                self.timeLabel.text = "\(endDate)"
            }
            
            self.foodsArray = NSMutableArray(array: dataObj["shoppingList"]as? NSArray ?? [])
            self.tableView.reloadData()
        }
    }
    func sendFoodsCheckRequest(check:String,id:String) {
        let param = ["checked":check,
                     "id":id]
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_shopping_list_check, parameters: param as [String : AnyObject]) { responseObject in
            
        }
    }
}
