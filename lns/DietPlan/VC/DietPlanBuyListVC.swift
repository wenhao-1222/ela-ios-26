//
//  DietPlanBuyListVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/12.
//

import MCToast

class DietPlanBuyListVC: WHBaseViewVC {
    
    private let skeletonRowCount = 12
    private let timeSkeletonConfig = SkeletonConfig(baseColorLight: .COLOR_GRAY_E8,
                                                    highlightColorLight: .COLOR_GRAY_D6D6D6,
                                                    cornerRadius: kFitWidth(7),
                                                    shimmerWidth: 0.2,
                                                    shimmerDuration: 1.0,
                                                    skeletonFadeInDuration: 0.0,
                                                    contentFadeInDuration: 0.18)
    private let tipsSkeletonConfig = SkeletonConfig(baseColorLight: .COLOR_GRAY_E8,
                                                    highlightColorLight: .COLOR_GRAY_D6D6D6,
                                                    cornerRadius: kFitWidth(6),
                                                    shimmerWidth: 0.2,
                                                    shimmerDuration: 1.0,
                                                    skeletonFadeInDuration: 0.0,
                                                    contentFadeInDuration: 0.18)
    var selectedDates = [String]()
    var createDateStrings = [String]()
    var showCreateButton = true
    var foodsArray = NSMutableArray()
    private var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        beginLoading()
//        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
            if self.selectedDates.count > 0 {
                self.createBuyListRequest()
            }else{
                self.sendBuyListRequest()
            }
//        })
        
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is DietPlanBuyListDateVC }) {
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
    }
//    lazy var listAddButton: UIButton = {
//        let btn = UIButton()
//        btn.layer.cornerRadius = kFitWidth(12)
//        btn.setTitle("+ 新购物清单", for: .normal)
//        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
//        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
//        btn.clipsToBounds = true
//        btn.enablePressEffect()
//        btn.backgroundColor = .COLOR_CARD_BG_WHITE
//        
//        btn.addTarget(self, action: #selector(addFoodsAction), for: .touchUpInside)
//        
//        return btn
//    }()
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        bottomGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        topGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
    }
    lazy var timeButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.contentHorizontalAlignment = .left
        btn.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(openCreateBuyListDatePage), for: .touchUpInside)
        
        if selectedDates.count > 0 {
            btn.setTitle("\(selectedDates[0]) 至 \(selectedDates[selectedDates.count - 1])", for: .normal)
            btn.imagePosition(style: .right, spacing: kFitWidth(5))
        }
        
        return btn
    }()
    lazy var tipsLab: UILabel = {
        let lab = UILabel()
        lab.text = "请勾选你已购买的食材"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
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
//    lazy var createButton: FeedBackButton = {
//        let btn = FeedBackButton()
//        btn.setTitle("新建", for: .normal)
//        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
//        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_30, for: .highlighted)
//        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
//        btn.addTarget(self, action: #selector(openCreateBuyListDatePage), for: .touchUpInside)
//        btn.isHidden = !showCreateButton
//        return btn
//    }()
}

extension DietPlanBuyListVC{
    func initUI() {
        initNavi(titleStr: "购物清单")
        self.navigationView.backgroundColor = .COLOR_BG_F2
        view.backgroundColor = .COLOR_BG_F2
//        if showCreateButton {
//            navigationView.addSubview(createButton)
//            createButton.snp.makeConstraints { make in
//                make.right.equalTo(kFitWidth(-10))
//                make.width.equalTo(kFitWidth(60))
//                make.height.equalTo(kFitWidth(44))
//                make.centerY.lessThanOrEqualTo(self.naviTitleLabel)
//            }
//        }
        
//        view.addSubview(listAddButton)
        view.addSubview(tableView)
        view.addSubview(topGradientView)
        view.addSubview(bottomGradientView)
        view.addSubview(timeButton)
        view.addSubview(tipsLab)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)
        topGradientView.layer.addSublayer(topGradientLayer)
        
        setConstrait()
        
        self.backArrowButton.tapBlock = {()in
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    func setConstrait() {
//        listAddButton.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
//            make.right.equalTo(kFitWidth(-16))
//            make.height.equalTo(kFitWidth(58))
//            make.top.equalTo(kFitWidth(20)+self.getNavigationBarHeight())
//        }
        timeButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
//            make.top.equalTo(listAddButton.snp.bottom).offset(kFitWidth(25))
            make.top.equalTo(kFitWidth(15)+self.getNavigationBarHeight())
            make.height.equalTo(kFitWidth(25))
        }
        tipsLab.snp.makeConstraints { make in
            make.left.equalTo(timeButton)
            make.top.equalTo(timeButton.snp.bottom).offset(kFitWidth(6))
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tipsLab.snp.bottom)//.offset(kFitWidth(10))
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
    
    @objc func openCreateBuyListDatePage() {
        guard !createDateStrings.isEmpty else {
            MCToast.mc_text("当前没有可用的购物清单日期")
            return
        }
//        presentAlertVc(confirmBtn: "清空并创建", message: "", title: "放弃当前内容并创建新清单？", cancelBtn: "保留", handler: { action in
            let vc = DietPlanBuyListDateVC(dateStrings: self.createDateStrings) { [weak self] selectedDates in
                self?.applySelectedDatesAndRefresh(selectedDates)
            }
            self.navigationController?.pushViewController(vc, animated: true)
//        }, viewController: self)
    }
    
    func applySelectedDatesAndRefresh(_ selectedDates: [String]) {
        guard !selectedDates.isEmpty else { return }
        self.selectedDates = selectedDates
        updateTimeLabel(with: selectedDates)
        beginLoading()
        createBuyListRequest()
    }
    
    func updateTimeLabel(with selectedDates: [String]) {
        guard let firstDate = selectedDates.first, let lastDate = selectedDates.last else {
            setTimeButtonTitle(nil)
            return
        }
        
        if firstDate == lastDate {
            setTimeButtonTitle(Date().changeDateFormatter(dateString: firstDate,
                                                          formatter: "yyyy-MM-dd",
                                                          targetFormatter: "MM月dd日"))
        } else {
            let firstStr = Date().changeDateFormatter(dateString: firstDate,
                                                      formatter: "yyyy-MM-dd",
                                                      targetFormatter: "MM月dd日")
            let lastStr = Date().changeDateFormatter(dateString: lastDate,
                                                     formatter: "yyyy-MM-dd",
                                                     targetFormatter: "MM月dd日")
            setTimeButtonTitle("\(firstStr) 至 \(lastStr)")
        }
    }
    func updateTimeLabel(firstDate:String,lastDate:String) {
        if firstDate == lastDate {
            setTimeButtonTitle(Date().changeDateFormatter(dateString: firstDate,
                                                          formatter: "yyyy-MM-dd",
                                                          targetFormatter: "MM月dd日"))
        } else {
            let firstStr = Date().changeDateFormatter(dateString: firstDate,
                                                      formatter: "yyyy-MM-dd",
                                                      targetFormatter: "MM月dd日")
            let lastStr = Date().changeDateFormatter(dateString: lastDate,
                                                     formatter: "yyyy-MM-dd",
                                                     targetFormatter: "MM月dd日")
            setTimeButtonTitle("\(firstStr) 至 \(lastStr)")
        }
    }
    
    func setTimeButtonTitle(_ title: String?) {
        timeButton.setTitle(title, for: .normal)
        timeButton.imagePosition(style: .right, spacing: kFitWidth(5))
    }

    func updateSelectStatus(indexPath: IndexPath) {
        if self.foodsArray.count > indexPath.row{
            let dict = NSMutableDictionary(dictionary: self.foodsArray[indexPath.row]as? NSDictionary ?? [:])
            let isChecked: Bool
            if dict.stringValueForKey(key: "checked") == "0"{
                dict.setValue("1", forKey: "checked")
                isChecked = true
                self.sendFoodsCheckRequest(check: "1", id: dict.stringValueForKey(key: "id"))
            }else{
                dict.setValue("0", forKey: "checked")
                isChecked = false
                self.sendFoodsCheckRequest(check: "0", id: dict.stringValueForKey(key: "id"))
            }
            self.foodsArray.replaceObject(at: indexPath.row, with: dict)
            if let cell = tableView.cellForRow(at: indexPath) as? DietPlanBuyListFoodsCell {
                cell.updateCheckState(isChecked)
            }
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}

extension DietPlanBuyListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isLoading ? skeletonRowCount : foodsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DietPlanBuyListFoodsCell.reuseId, for: indexPath) as? DietPlanBuyListFoodsCell ?? DietPlanBuyListFoodsCell()
        cell.isUserInteractionEnabled = !isLoading

        if isLoading {
            cell.updateUI(title: "", weight: "", isSelected: false, isLoading: true)
            return cell
        }
        
        let dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
        cell.updateUI(title: dict.stringValueForKey(key: "fname"),
                      weight: "\(dict.stringValueForKey(key: "qty")) \(dict.stringValueForKey(key: "spec"))",
                      isSelected: dict.stringValueForKey(key: "checked") == "1",
                      isLoading: false)
        
        return cell
    }
//    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isLoading else { return }
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
            NotificationCenter.default.post(name: NOTIFI_NAME_DIET_PLAN_BUY_LIST_CREATE_SUCCESS, object: nil)
            
            self.prepareTimeLabelFadeInIfNeeded()
            self.prepareTipsLabelFadeInIfNeeded()
            self.updateTimeLabel(with: self.selectedDates)
            self.timeButton.hideSkeletonWithCrossfade()
            self.tipsLab.hideSkeletonWithCrossfade()
            self.finishLoading(with: dataObj["shoppingList"]as? NSArray ?? [])
        }
    }
    func sendBuyListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_shopping_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendBuyListRequest:\(dataObj)")
            
            let startDate = dataObj.stringValueForKey(key: "startDate")
            let endDate = dataObj.stringValueForKey(key: "endDate")
//            if startDate.count > 0 && endDate.count > 0{
//                self.timeLabel.text = "\(startDate) 至 \(endDate)"
//            }else if startDate.count > 0{
//                self.timeLabel.text = "\(startDate)"
//            }else if endDate.count > 0{
//                self.timeLabel.text = "\(endDate)"
//            }
            
            self.prepareTimeLabelFadeInIfNeeded()
            self.prepareTipsLabelFadeInIfNeeded()
            self.updateTimeLabel(firstDate: startDate, lastDate: endDate)
            self.timeButton.hideSkeletonWithCrossfade()
            self.tipsLab.hideSkeletonWithCrossfade()
            self.finishLoading(with: dataObj["shoppingList"]as? NSArray ?? [])
        }
    }
    func sendFoodsCheckRequest(check:String,id:String) {
        let param = ["checked":check,
                     "id":id]
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_shopping_list_check, parameters: param as [String : AnyObject]) { responseObject in
            
        }
    }

    func beginLoading() {
        isLoading = true
        tableView.allowsSelection = false
        if !timeButton.isSkeletonActive {
            if timeButton.title(for: .normal)?.isEmpty != false {
                setTimeButtonTitle("                                                ")
            }
            timeButton.showSkeleton(timeSkeletonConfig)
        }
        if !tipsLab.isSkeletonActive {
            tipsLab.showSkeleton(tipsSkeletonConfig)
        }
        tableView.reloadForSkeleton()
    }

    func finishLoading(with list: NSArray) {
        isLoading = false
        tableView.allowsSelection = true
        foodsArray = NSMutableArray(array: list)
        tableView.reloadData()
    }

    func prepareTimeLabelFadeInIfNeeded() {
        guard timeButton.isSkeletonActive else { return }
        timeButton.alpha = 0
    }

    func prepareTipsLabelFadeInIfNeeded() {
        guard tipsLab.isSkeletonActive else { return }
        tipsLab.alpha = 0
    }
}
