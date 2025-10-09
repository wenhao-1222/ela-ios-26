//
//  FoodsMergeVC.swift
//  lns
//  食物融合
//  Created by Elavatine on 2025/3/14.
//

import IQKeyboardManagerSwift
import MCToast

class FoodsMergeVC: WHBaseViewVC {
    
    var sourceType = ADD_FOODS_SOURCE.other
    var specArray = ["克"]
    var updateFoodsIndex = -1
    var tableViewHeight = kFitHeight(-10)
    
    var totalCalories = Double(0)
    var totalCarbohydrate = Double(0)
    var totalProtein = Double(0)
    var totalFat = Double(0)
    var totalQty = Float(1)
    
    var foodsDataArray = NSMutableArray()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        IQKeyboardManager.shared.enable = true
        self.foodsMsgAlertVm.hiddenView()
        self.foodsMsgSoonAlertVM.hiddenView()
        self.specAlertVm.hiddenView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        sendSpecEnumRequest()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeFoods(notify: )), name: NSNotification.Name(rawValue: "foodsUpdateForMerge"), object: nil)
    }
    lazy var bottomView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var foodsNameVm : FoodsCreateNameVM = {
//        let vm = FoodsCreateNameVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        let vm = FoodsCreateNameVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: 0, height: 0))
        
//        titleLabel
        let attr = NSMutableAttributedString(string: "食物名称")
        let attr1 = NSMutableAttributedString(string: "*")
        attr1.yy_color = WHColor_16(colorStr: "FF3A3A")
        attr.append(attr1)
        vm.titleLabel.attributedText = attr
        
        vm.numberChangeBlock = {(number)in
//            
            let nameStr = number.replacingOccurrences(of: " ", with: "")
            if nameStr.count > 0 && self.foodsDataArray.count > 0{
                self.bottomFuncVm.saveButton.isEnabled = true
            }else{
                self.bottomFuncVm.saveButton.isEnabled = false
            }
        }
        return vm
    }()
    lazy var specVm : FoodsMergeSpecVM = {
        let vm = FoodsMergeSpecVM.init(frame: CGRect.init(x: 0, y: self.foodsNameVm.frame.maxY, width: 0, height: 0))
        vm.specBlock = {()in
            self.foodsNameVm.textField.resignFirstResponder()
//            self.proteinVm.textField.resignFirstResponder()
//            self.fatVm.textField.resignFirstResponder()
//            self.carboVm.textField.resignFirstResponder()
//            self.caloriVm.numberLabel.resignFirstResponder()
            self.specAlertVm.showView()
        }
        return vm
    }()
    lazy var naturalMsgVm : FoodsMergeNaturalVM = {
        let vm = FoodsMergeNaturalVM.init(frame: CGRect.init(x: 0, y: self.specVm.frame.maxY, width: 0, height: 0))
        return vm
    }()
    lazy var nameTipsVm: FoodsMergeListNameVM = {
        let vm = FoodsMergeListNameVM.init(frame: CGRect.init(x: 0, y: self.naturalMsgVm.frame.maxY, width: 0, height: 0))
        vm.addFoodsBlock = {()in
            self.addFoodsAction()
        }
        return vm
    }()
    lazy var tableView: ForumCommentListTableView = {
        let vi = ForumCommentListTableView.init(frame: CGRect.init(x: kFitWidth(16), y: self.nameTipsVm.frame.maxY, width: SCREEN_WIDHT-kFitWidth(32), height: SCREEN_HEIGHT-getNavigationBarHeight()), style: .grouped)
        vi.delegate = self
        vi.dataSource = self
        vi.backgroundColor = .clear
        vi.separatorStyle = .none
        vi.bounces = false
//        vi.separatorColor = .clear
        vi.separatorInset = UIEdgeInsets(top: -20, left: 0, bottom: kFitWidth(0), right: 0)
        vi.register(FoodsMergeListTableViewCell.classForCoder(), forCellReuseIdentifier: "FoodsMergeListTableViewCell")
//        vi.tableHeaderView = self.headView
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        vi.contentInsetAdjustmentBehavior = .never
        vi.sectionHeaderHeight = .leastNonzeroMagnitude
        
        vi.reloadCompletion = {()in
            let size = self.tableView.contentSize
//            DLLog(message: "reloadCompletion:\(size.height)")
            if abs(self.tableViewHeight - size.height) > 1 {
                self.tableViewHeight = size.height
                let firstCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))as? FoodsMergeListTableViewCell
                let firstOriginY = firstCell?.frame.minY
                
                self.tableView.frame = CGRect.init(x: kFitWidth(16), y: self.nameTipsVm.frame.maxY-(firstOriginY ?? 0), width: SCREEN_WIDHT-kFitWidth(32), height: self.tableViewHeight)
                self.addVm.frame = CGRect.init(x: 0, y: self.tableView.frame.maxY, width: SCREEN_WIDHT, height: self.addVm.selfHeight)
                self.noDataView.center = self.addVm.center
                self.scrollViewBase.contentSize = CGSize.init(width: 0, height: self.addVm.frame.maxY)
            }
        }
        return vi
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: self.tableView.frame.maxY+kFitWidth(50), width: SCREEN_WIDHT, height: 0))
        vi.noDataLabel.text = "- 请添加食材 -"
        vi.isHidden = true
        return vi
    }()
    lazy var addVm: FoodsMergeAddVm = {
        let vm = FoodsMergeAddVm.init(frame: CGRect.init(x: 0, y: self.tableView.frame.maxY, width: 0, height: 0))
        vm.isHidden = true
        vm.tapBlock = {()in
            self.addFoodsAction()
        }
        return vm
    }()
    lazy var headView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.nameTipsVm.frame.maxY))
        vi.addSubview(foodsNameVm)
        vi.addSubview(specVm)
        vi.addSubview(naturalMsgVm)
        vi.addSubview(nameTipsVm)
        return vi
    }()
    lazy var bottomFuncVm: FoodsMergeBottomVm = {
        let vm = FoodsMergeBottomVm.init(frame: .zero)
        vm.tapBlock = {()in
            self.saveAction()
        }
        return vm
    }()
    lazy var specAlertVm: FoodsCreateSpecAlertVM = {
        let vm = FoodsCreateSpecAlertVM.init(frame: .zero)
        vm.specString = "克"
        vm.confirmBlock = {(spec)in
            self.specVm.specName = "\(spec)"
            self.specVm.updateButton()
            self.changeSpecName()
        }
        return vm
    }()
    lazy var foodsMsgSoonAlertVM: FoodsMergeFoodsSoonAlertVm = {
        let vm = FoodsMergeFoodsSoonAlertVm.init(frame: .zero)
        
        vm.updateBlock = {(dict)in
            self.foodsDataArray.replaceObject(at: self.foodsMsgSoonAlertVM.index.section, with: dict)
            self.tableView.reloadSections(IndexSet(integer: self.foodsMsgSoonAlertVM.index.section), with: .fade)
            self.calculateNum()
        }
        
        return vm
    }()
    lazy var foodsMsgAlertVm: FoodsMergeFoodsAlertVm = {
        let vm = FoodsMergeFoodsAlertVm.init(frame: .zero)
        vm.numberSpecVm.specTapBlock = {()in
            self.foodsMsgAlertVm.numberSpecVm.numberTextField.resignFirstResponder()
            self.specAlertVmForFoods.showView()
        }
        vm.updateBlock = {(dict)in
            self.foodsDataArray.replaceObject(at: self.foodsMsgAlertVm.index.section, with: dict)
            self.tableView.reloadSections(IndexSet(integer: self.foodsMsgAlertVm.index.section), with: .fade)
            self.calculateNum()
        }
        return vm
    }()
    lazy var specAlertVmForFoods: FoodsMergeChoiceSpecAlertVM = {
        let vm = FoodsMergeChoiceSpecAlertVM.init(frame: .zero)
        vm.confirmBlock = {(spec)in
            DLLog(message: "FoodsMergeChoiceSpecAlertVM:\(spec)")
            self.foodsMsgAlertVm.numberSpecVm.specDict = spec
            self.foodsMsgAlertVm.numberSpecVm.changeSpec()
//            self.foodsMsgAlertVm.numberSpecVm.specLabel.text = "\(spec)"
        }
        return vm
    }()
}

extension FoodsMergeVC{
    func addFoodsAction() {
        self.foodsNameVm.textField.resignFirstResponder()
        self.specVm.numberTextField.resignFirstResponder()
        let vc = FoodsListNewVC()
        vc.sourceType = .merge
        vc.isFromMerge = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func saveAction() {
        let nameString = foodsNameVm.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if nameString == "" {
            MCToast.mc_text("请输入食物名称")
            return
        }
        if self.foodsNameVm.textField.text?.count ?? 0 > 30{
            MCToast.mc_text("食物名称不能超过30个字符")
            return
        }
        let number = self.specVm.numberTextField.text ?? ""
        if number.isNumber() == false{
            self.presentAlertVcNoAction(title: "请输入正确的规格数量", viewController: self)
            return
        }
        if number.count == 0 || number.floatValue == 0{
            MCToast.mc_text("请输入食物规格数量")
            return
        }
        
        if ("\(self.totalCarbohydrate)").isNumber() == false{
            self.presentAlertVcNoAction(title: "请输入正确的碳水数量", viewController: self)
            return
        }
        if ("\(self.totalProtein)").isNumber() == false{
            self.presentAlertVcNoAction(title: "请输入正确的蛋白质数量", viewController: self)
            return
        }
        if ("\(self.totalFat)").isNumber() == false{
            self.presentAlertVcNoAction(title: "请输入正确的脂肪数量", viewController: self)
            return
        }
        sendAddFoodsRequest()
    }
}

extension FoodsMergeVC{
    func initUI() {
        initNavi(titleStr: "融合食物")
        
        view.insertSubview(bottomView, belowSubview: self.navigationView)
        bottomView.addSubview(scrollViewBase)
        view.addSubview(bottomFuncVm)
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-bottomFuncVm.selfHeight)
        scrollViewBase.backgroundColor = .white
        scrollViewBase.addSubview(foodsNameVm)
        scrollViewBase.addSubview(specVm)
        scrollViewBase.addSubview(naturalMsgVm)
        scrollViewBase.addSubview(nameTipsVm)
        scrollViewBase.insertSubview(tableView, belowSubview: nameTipsVm)
        scrollViewBase.addSubview(addVm)
        scrollViewBase.addSubview(noDataView)
        
        view.addSubview(specAlertVm)
        view.addSubview(foodsMsgSoonAlertVM)
        view.addSubview(foodsMsgAlertVm)
        view.addSubview(specAlertVmForFoods)
    }
}

extension FoodsMergeVC{
    func sendSpecEnumRequest() {
        WHNetworkUtil.shareManager().GET(urlString: URL_foods_spec_enum) { responseObject in
//            let dict = responseObject["data"]as? NSDictionary ?? [:]
            
            let dataObj = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            DLLog(message: "\(dataObj ?? "")")
            let arr = self.getArrayFromJSONString(jsonString: dataObj ?? "[]")
            if arr.count > 0 {
                self.specArray = arr as! [String]
            }else{
                self.specArray = ["份"]
            }
//            self.specArray = responseObject["data"]as? [String] ?? ["克"]
//            self.specArray = arr
            self.specAlertVm.setSpecArr(arr: self.specArray)
            self.specAlertVm.specString = "份"
            self.specAlertVm.reloadPickerIndex(arr: ["份"])
        }
    }
}

extension FoodsMergeVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        noDataView.isHidden = foodsDataArray.count > 0 ? true : false
        return foodsDataArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodsMergeListTableViewCell", for: indexPath) as? FoodsMergeListTableViewCell
        
        let dict = foodsDataArray[indexPath.section]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict)
        
        cell?.editBlock = {()in
            DLLog(message: "点击了编辑icon")
        }
        
        return cell ?? FoodsMergeListTableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        TouchGenerator.shared.touchGenerator()
        let dict = foodsDataArray[indexPath.section]as? NSDictionary ?? [:]
        if dict.stringValueForKey(key: "fname") == "快速添加"{
            self.foodsMsgSoonAlertVM.index = indexPath
            self.foodsMsgSoonAlertVM.updateUI(dict: dict)
        }else{
            self.foodsMsgAlertVm.index = indexPath
            self.foodsMsgAlertVm.updateUI(dict: dict)
            self.specAlertVmForFoods.setSpecArr(arr: self.foodsMsgAlertVm.numberSpecVm.specArray)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return kFitWidth(12)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFitWidth(0)
    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return CGFloat.leastNonzeroMagnitude // 更彻底的方式
//    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        DLLog(message: "trailingSwipeActionsConfigurationForRowAt")
        let editAction  = UIContextualAction.init(style: .normal, title: "编辑") { _,_,_ in
            TouchGenerator.shared.touchGenerator()
            let dict = self.foodsDataArray[indexPath.section]as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "fname") == "快速添加"{
                self.foodsMsgSoonAlertVM.index = indexPath
                self.foodsMsgSoonAlertVM.updateUI(dict: dict)
            }else{
                self.foodsMsgAlertVm.index = indexPath
                self.foodsMsgAlertVm.updateUI(dict: dict)
                self.specAlertVmForFoods.setSpecArr(arr: self.foodsMsgAlertVm.numberSpecVm.specArray)
            }
            self.tableView.setEditing(false, animated: true)
        }
        
        let deleteAction  = UIContextualAction.init(style: .destructive, title: "删除") { _,_,_ in
            TouchGenerator.shared.touchGenerator()
            self.tableView.performBatchUpdates {
                self.foodsDataArray.removeObject(at: indexPath.section)
                self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            } completion: { t in
                self.calculateNum()
                self.judgeSelectFoods()
            }
        }
        editAction.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.3)
        
        let actions = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        actions.performsFirstActionWithFullSwipe = false
        
        return actions
    }
    
    /// 重点： 如果这个方法不加圆角在左滑的时候没有任何问题，但delete模式消失时容易出现Cell直角样式
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
            cell.layer.cornerRadius = kFitWidth(12)
            cell.layer.masksToBounds = true
        }
    }
}

extension FoodsMergeVC{
    @objc func changeFoods(notify:Notification) {
        let foodsDict = notify.object as? NSDictionary ?? [:]
        DLLog(message: "FoodsMergeVC:\(foodsDict)")
        
        if foodsDict.stringValueForKey(key: "fname") == "快速添加"{
            if self.updateFoodsIndex == -1 {
                self.foodsDataArray.add(foodsDict)
            }else{
                if self.foodsDataArray.count > self.updateFoodsIndex{
                    self.foodsDataArray.replaceObject(at: self.updateFoodsIndex, with: foodsDict)
                }
            }
        }else{
            if self.updateFoodsIndex == -1{//如果是点击的添加食物
                addFoods(foodsMsg: foodsDict)
                
//                WHUtils().sendAddFoodsForCountRequest(fids: [foodsDict.stringValueForKey(key: "fid")])
//                WHUtils().sendAddHistoryFoods(foodsMsgArray: [foodsDict])
            }else{//如果是点击的食物
                if self.foodsDataArray.count > self.updateFoodsIndex{
                    let touchFoods = self.foodsDataArray[self.updateFoodsIndex]as? NSDictionary ?? [:]
                    if touchFoods.stringValueForKey(key: "fid") == foodsDict.stringValueForKey(key: "fid") &&
                        touchFoods.stringValueForKey(key: "spec") == foodsDict.stringValueForKey(key: "spec"){
                        self.foodsDataArray.replaceObject(at: self.updateFoodsIndex, with: foodsDict)
                    }else{
                        self.foodsDataArray.removeObject(at: self.updateFoodsIndex)
                        self.addFoods(foodsMsg: foodsDict)
                    }
                }
            }
        }
        self.tableView.reloadData()
        self.calculateNum()
        self.judgeSelectFoods()
//        self.updateScrollViewContent()
    }
    func addFoods(foodsMsg:NSDictionary){
        var hasFoods = false
        for i in 0..<self.foodsDataArray.count{
            let dict = self.foodsDataArray[i]as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "fid") == foodsMsg.stringValueForKey(key: "fid") &&
                dict.stringValueForKey(key: "spec") == foodsMsg.stringValueForKey(key: "spec"){
                hasFoods = true
                
                let foodsDict = NSMutableDictionary.init(dictionary: dict)
                let specNum = foodsMsg.doubleValueForKey(key: "qty")
                if specNum == 0 {
                    break
                }
                let dictNum = foodsDict.doubleValueForKey(key: "qty")
                let num = dictNum + specNum
                
                foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                
                let caloriesNumber = foodsMsg.doubleValueForKey(key: "caloriesNumber")
                let calories = caloriesNumber/specNum * num
                
                let calori = calories
                let carbo = foodsDict.doubleValueForKey(key: "carbohydrate") + foodsMsg.doubleValueForKey(key: "carbohydrateNumber")
                let protein = foodsDict.doubleValueForKey(key: "protein") + foodsMsg.doubleValueForKey(key: "proteinNumber")
                let fat = foodsDict.doubleValueForKey(key: "fat") + foodsMsg.doubleValueForKey(key: "fatNumber")
                
                foodsDict.setValue("\(WHUtils.convertStringToStringNoDigit("\(calori)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                foodsDict.setValue("\(carbo)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                foodsDict.setValue("\(protein)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                foodsDict.setValue("\(fat)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                
                self.foodsDataArray.replaceObject(at: i, with: foodsDict)
                break
            }
        }
        if hasFoods == false{
            self.foodsDataArray.insert(foodsMsg, at: 0)
//            self.foodsDataArray.add(foodsMsg)
        }
    }

    func calculateNum() {
        totalCalories = Double(0)
        totalCarbohydrate = Double(0)
        totalProtein = Double(0)
        totalFat = Double(0)
        totalQty = Float(0)
        
        for i in 0..<foodsDataArray.count{
            let foodsDict = foodsDataArray[i]as? NSDictionary ?? [:]
            
            totalCalories = totalCalories + foodsDict.doubleValueForKey(key: "calories")
            totalCarbohydrate = totalCarbohydrate + foodsDict.doubleValueForKey(key: "carbohydrate")
            totalProtein = totalProtein + foodsDict.doubleValueForKey(key: "protein")
            totalFat = totalFat + foodsDict.doubleValueForKey(key: "fat")
            
            totalQty = totalQty + Float(foodsDict.doubleValueForKey(key: "qty"))
        }
        
        naturalMsgVm.setDataSource(array: [self.totalCarbohydrate,self.totalProtein,self.totalFat])
        naturalMsgVm.setCaloriesNumber(calories: "\(Int(totalCalories.rounded()))")
        
        self.changeSpecName()
    }
    func changeSpecName() {
        if specVm.specName == "克" || specVm.specName == "g" || specVm.specName == "ml" || specVm.specName == "毫升"{
            self.specVm.numberTextField.text = "\(Int(self.totalQty.rounded()))"
        }else{
//            self.specVm.numberTextField.text = "1"
        }
    }
    func judgeSelectFoods() {
        if foodsDataArray.count > 0 && foodsNameVm.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 > 0{
            bottomFuncVm.saveButton.isEnabled = true
        }else{
            bottomFuncVm.saveButton.isEnabled = false
        }
    }
    // 在数据更新后调用此方法
    func updateScrollViewContent() {
        DispatchQueue.main.async {
            // 确保布局已完成
            self.view.layoutIfNeeded()
            
            // 更新 contentSize
            self.scrollViewBase.contentSize = CGSize(
                width: 0,
                height: self.addVm.frame.maxY
            )
            
            // 仅在内容足够时滚动到底部
            guard self.foodsDataArray.count > 0,
                  self.addVm.frame.maxY > self.scrollViewBase.bounds.height else {
                return
            }
            
            let bottomOffset = CGPoint(
                x: 0,
                y: self.scrollViewBase.contentSize.height - self.scrollViewBase.bounds.height
            )
            
            // 检查偏移合法性
            if bottomOffset.y >= 0 {
                self.scrollViewBase.setContentOffset(bottomOffset, animated: false)
            } else {
                self.scrollViewBase.setContentOffset(.zero, animated: false)
            }
            
            // 打印调试信息
            print("ContentSize: \(self.scrollViewBase.contentSize)")
            print("Current Offset: \(self.scrollViewBase.contentOffset)")
        }
    }
}

extension FoodsMergeVC{
    func sendAddFoodsRequest() {
        MCToast.mc_loading(text: "食物创建中...")
        let spec = [["specNum":"\(self.specVm.numberTextField.text ?? "1")",
                     "specName":"\(self.specVm.specName)"]]
        let param = ["fname":"\(foodsNameVm.textField.text ?? "".trimmingCharacters(in: .whitespacesAndNewlines))",
                     "calories":"\(Int(totalCalories.rounded()))".replacingOccurrences(of: ",", with: "."),
                     "protein":"\(WHUtils.convertStringToString("\(self.totalProtein)") ?? "0")".replacingOccurrences(of: ",", with: "."),
                     "fat":"\(WHUtils.convertStringToString("\(self.totalFat)") ?? "0")".replacingOccurrences(of: ",", with: "."),
                     "carbohydrate":"\(WHUtils.convertStringToString("\(self.totalCarbohydrate)") ?? "0")".replacingOccurrences(of: ",", with: "."),
                     "spec":self.getJSONStringFromArray(array: spec as NSArray)] as NSMutableDictionary
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_save, parameters: param as? [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: "\(responseObject)")
            MCToast.mc_text("“\(self.foodsNameVm.textField.text ?? "")”创建成功",respond: .allow)
            
            let dataStrig = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            
            param.setValue("\(dataStrig ?? "")", forKey: "fid")
            param.setValue("\(self.specVm.specName)", forKey: "specName")
            param.setValue("\(self.specVm.numberTextField.text ?? "1")", forKey: "specNum")
            param.setValue("\(self.specVm.numberTextField.text ?? "1")", forKey: "qty")
            
            UserDefaults.saveFoods(foodsDict: param as NSDictionary,forKey: .myFoodsList)
            param.setValue("\(self.specVm.specName)", forKey: "spec")
            WHUtils().sendAddHistoryFoods(foodsMsgArray: [param])
//            if self.addBlock != nil{
//                self.addBlock!()
//            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createFoodsSuccess"), object: nil)
            self.backTapAction()
        }
    }
}
