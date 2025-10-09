//
//  PlanCreateVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/12.
//

import Foundation
import MCToast
import UMCommon

class PlanCreateVC : WHBaseViewVC {
    
    var offsetY = kFitWidth(0)
    var edgePanChangeX = CGFloat(0)
    var titleString = ""
    
    var daysNumber = 1
    var daysIndex = 0
    var mealsIndex = 0
    var selectFoodsIndex = -1
    
    var createBlock:(()->())?
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.enableInteractivePopGesture()
        initUI()
        offsetY = headView.frame.height + getNavigationBarHeight()
        NotificationCenter.default.addObserver(self, selector: #selector(addFoodsNotifi(notify: )), name: NSNotification.Name(rawValue: "foodsAddForPlan"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addFoodsFastNotifi(notify: )), name: NSNotification.Name(rawValue: "fastAddFoodsForPlan"), object: nil)
        
        let panGes = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(popGestureAction(gesture: )))
        panGes.edges = .left
        view.addGestureRecognizer(panGes)
        
        let data = UserDefaults.standard.value(forKey: "planCreateData")as? String ?? ""
        if data == ""{
            DLLog(message: "planCreateData：空")
        }else{
            let lastDict = self.getDictionaryFromJSONString(jsonString: data)
            DLLog(message: "planCreateData：\(lastDict)")
            self.daysNumber = lastDict.stringValueForKey(key: "daysNumber").intValue
            self.nameVm.textField.text = lastDict.stringValueForKey(key: "pname")
            self.dataSourceArray = NSMutableArray(array: lastDict["dataSourceArray"]as? NSArray ?? [])
            self.daysVm.updateDaysNumber(daysNumber: self.daysNumber)
            self.tableView.reloadData()
        }
    }
    lazy var dataSourceArray : NSMutableArray = {
        let arr = NSMutableArray()
        
        for i in 0..<7{
            let daysMsgArr = NSArray.init(array: [["mealsIndex":"1","foodsArray":NSArray()],
                                                  ["mealsIndex":"2","foodsArray":NSArray()],
                                                  ["mealsIndex":"3","foodsArray":NSArray()],
                                                  ["mealsIndex":"4","foodsArray":NSArray()],
                                                  ["mealsIndex":"5","foodsArray":NSArray()],
                                                  ["mealsIndex":"6","foodsArray":NSArray()]])
            arr.add(daysMsgArr)
        }
        
        return arr
    }()
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-kFitWidth(72)-getBottomSafeAreaHeight()-getNavigationBarHeight()), style: .plain)
//        vi.tableHeaderView = headView
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        vi.separatorStyle = .none
        vi.separatorInset = .zero
        vi.register(PlanCreateTableViewCell.classForCoder(), forCellReuseIdentifier: "PlanCreateTableViewCell")
        
        vi.delegate = self
        vi.dataSource = self
        
        return vi
    }()

    lazy var nameVm : PlanCreateNameVM = {
        let vm = PlanCreateNameVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
//        vm.startCountdown()
        return vm
    }()
    lazy var daysVm : PlanCreateDaysVM = {
        let vm = PlanCreateDaysVM.init(frame: CGRect.init(x: 0, y: self.nameVm.frame.maxY, width: 0, height: 0))
        vm.daysChangeBlock = {(daysNum)in
            if daysNum < self.daysIndex + 1{
                self.daysIndex = daysNum - 1
                self.filterVm.setDays(days: self.daysIndex)
                self.filterTopVm.setDays(days: self.daysIndex)
                self.tableView.reloadData()
            }
            self.daysNumber = daysNum
            self.synAlertVm.refreshDaysNum(days: daysNum)
            self.synAlertVm.setCurrentDay(dayIndex: self.daysIndex)
            self.filterVm.refreshSynButton(daysNum: daysNum)
            self.filterTopVm.refreshSynButton(daysNum: daysNum)
        }
        return vm
    }()
    lazy var goalsVm : PlanCreateGoalNaturalVM = {
        let vm = PlanCreateGoalNaturalVM.init(frame: CGRect.init(x: 0, y: self.daysVm.frame.maxY+kFitWidth(26), width: 0, height: 0))
        
        return vm
    }()
    lazy var filterVm : PlanCreateFilterVM = {
        let vi = PlanCreateFilterVM.init(frame: CGRect.init(x: 0, y: self.goalsVm.frame.maxY, width: 0, height: 0))
        vi.tapBlock = {()in
            self.choiceDaysAlertVm.showDaysAlertView(daysNumber: self.daysNumber, originY: self.offsetY, selectedDaysIndex: self.daysIndex)
        }
        vi.synBlock = {()in
            self.synAlertVm.showView()
        }
        return vi
    }()
    lazy var filterTopVm : PlanCreateFilterVM = {
        let vi = PlanCreateFilterVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: 0, height: 0))
        vi.isHidden = true
        vi.tapBlock = {()in
            self.choiceDaysAlertVm.showDaysAlertView(daysNumber: self.daysNumber, originY: self.offsetY, selectedDaysIndex: self.daysIndex)
        }
        vi.synBlock = {()in
            self.synAlertVm.showView()
        }
        return vi
    }()
    lazy var headView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: PlanCreateNameVM().selfHeight+PlanCreateDaysVM().selfHeight+PlanCreateGoalNaturalVM().selfHeight+PlanCreateFilterVM().selfHeight+kFitWidth(26)))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        
        return vi
    }()
//    lazy var choiceFoodsAlertVm : PlanCreateFoodsAlertVM = {
//        let vm = PlanCreateFoodsAlertVM.init(frame: .zero)
//        vm.controller = self
//        vm.submitBlock = {()in
//            self.dealFoodsMsg()
//            self.refreshNaturalMsg()
////            self.tableView.reloadData()
//        }
////        vm.changeFoodsBlock = {(dict)in
//        
////        }
//        return vm
//    }()
    lazy var choiceDaysAlertVm : PlanCreateFoodsDaysAlertVM = {
        let vm = PlanCreateFoodsDaysAlertVM.init(frame: .zero)
        vm.isHidden = true
        vm.choiceBlock = {(daysIndex)in
            self.daysIndex = daysIndex
            self.filterVm.setDays(days: daysIndex)
            self.filterTopVm.setDays(days: daysIndex)
            self.tableView.reloadData()
            self.synAlertVm.setCurrentDay(dayIndex: self.daysIndex)
        }
        return vm
    }()
    lazy var synAlertVm: PlanCreateSynAlertVM = {
        let vm = PlanCreateSynAlertVM.init(frame: .zero)
        vm.refreshDaysNum(days: 1)
        vm.synBlock = {()in
            self.synFoods()
        }
        return vm
    }()
    lazy var saveButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("保存计划", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .THEME
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        
        return btn
    }()
}

extension PlanCreateVC{
    @objc func popGestureAction(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.edgePanChangeX = CGFloat(0)
        case .changed:
            let translation = gesture.translation(in: view)
//            DLLog(message: "translation.x:\(translation.x)")
            self.edgePanChangeX = self.edgePanChangeX + translation.x
            
            gesture.setTranslation(.zero, in: view)
        case .ended:
            self.customBackTapAction()
            break
        default:
            break
        }
    }
    @objc func customBackTapAction() {
        if self.nameVm.textField.text?.count == 0 && hasData() == false{
            UserDefaults.standard.setValue("", forKey: "planCreateData")
            self.backTapAction()
//            self.nameVm.disableTimer()
            return
        }
        let alertVc = UIAlertController(title: "是否保存当前计划为草稿？", message: "", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "不保存", style: .default, handler: { (action)in
            UserDefaults.standard.setValue("", forKey: "planCreateData")
//            self.nameVm.disableTimer()
            self.backTapAction()
        })
        alertVc.addAction(okAction)
        let cancelAction = UIAlertAction(title: "保存", style: .default, handler:{ (action)in
            self.saveData()
//            self.nameVm.disableTimer()
        })
        alertVc.addAction(cancelAction)
        
        okAction.setTextColor(WHColorWithAlpha(colorStr: "007AFF", alpha: 0.6))
        
        self.present(alertVc, animated:true, completion:nil)
    }
    func saveData() {
//        var pname = self.nameVm.textField.text ?? ""
//        if pname.count > 16{
//            pname = pname.mc_clipFromPrefix(to: 15)
//        }
        let dict = ["daysNumber":"\(self.daysNumber)",
                    "dataSourceArray":self.dataSourceArray,
                    "pname":"\(self.nameVm.textField.text ?? "")"] as [String : Any]
        
        UserDefaults.standard.setValue(self.getJSONStringFromDictionary(dictionary: dict as NSDictionary), forKey: "planCreateData")
        self.backTapAction()
    }
    func hasData() -> Bool {
        for i in 0..<self.daysNumber{
            let daysArray = self.dataSourceArray[i]as? NSArray ?? []
            for j in 0..<daysArray.count{
                let mealsDict = daysArray[j]as? NSDictionary ?? [:]
                let foodsArray = NSMutableArray.init(array: mealsDict["foodsArray"]as? NSArray ?? [])
                if foodsArray.count > 0 {
                    return true
                }
            }
        }
        return false
    }
}

extension PlanCreateVC{
    @objc func saveAction() {
        if nameVm.textField.text?.count ?? 0 < 1 {
            MCToast.mc_text("请输入计划名称",respond: .allow)
            return
        }
        if nameVm.textField.text?.count ?? 0 > 15 {
            MCToast.mc_text("计划名称15字以内",respond: .allow)
            return
        }
        
        MobClick.event("createPlan")
        var detailsArray = NSMutableArray()
        for i in 0..<self.daysNumber{
            var hasMealsFoods = false//当天是否有一餐选择了食物
            
            var caloriTotal = Double(0)
            var carboTotal = Double(0.0)
            var proteinTotal = Double(0.0)
            var fatsTotal = Double(0.0)
            var mealsFoodsArray = NSMutableArray()
            
            let daysArray = self.dataSourceArray[i]as? NSArray ?? []
            for j in 0..<daysArray.count{
                let mealsDict = daysArray[j]as? NSDictionary ?? [:]
                let foodsArray = NSMutableArray.init(array: mealsDict["foodsArray"]as? NSArray ?? [])
                if foodsArray.count > 0 {
                    hasMealsFoods = true
                    
                    for k in 0..<foodsArray.count{
                        let dict = NSMutableDictionary.init(dictionary: foodsArray[k]as? NSDictionary ?? [:])
                        var carbo = Double(dict["carbohydrate"]as? String ?? "0.00")
                        var protein = Double(dict["protein"]as? String ?? "0.00")
                        var fats = Double(dict["fat"]as? String ?? "0.00")
                        var calori = Double(dict["calories"]as? String ?? "0.00")
                        
                        carboTotal = carboTotal + (carbo ?? 0.0)
                        proteinTotal = proteinTotal + (protein ?? 0.0)
                        fatsTotal = fatsTotal + (fats ?? 0.0)
                        caloriTotal = caloriTotal + (calori ?? 0)
//
                        
//                        dict.setValue("\(dict["caloriesNumber"]as? String ?? "0.00")", forKey: "calories")
//                        dict.setValue("\(dict["carbohydrateNumber"]as? String ?? "0.00")", forKey: "carbohydrate")
//                        dict.setValue("\(dict["proteinNumber"]as? String ?? "0.00")", forKey: "protein")
//                        dict.setValue("\(dict["fatNumber"]as? String ?? "0.00")", forKey: "fat")
                        
                        dict.setValue("\(j+1)", forKey: "sn")
                        dict.setValue("\(dict["specNum"]as? String ?? "1")", forKey: "qty")
                        dict.setValue("\(dict["specNum"]as? String ?? "1")", forKey: "weight")
                        dict.setValue("\(dict["specName"]as? String ?? "g")", forKey: "spec")
                        foodsArray.replaceObject(at: k, with: dict)
                        mealsFoodsArray.add(dict)
                    }
                }
            }
            if hasMealsFoods == false{
                MCToast.mc_text("第\(i+1)天，请至少添加一餐食物！")
                return
            }
            let dict = ["sdate":"\(Date().nextDay(days: i))",
                        "currentday":"\(i+1)",
                        "protein":"\(String(format: "%.2f", proteinTotal))",
                        "carbohydrate":"\(String(format: "%.2f", carboTotal))",
                        "fat":"\(String(format: "%.2f", fatsTotal))",
                        "calories":"\(String(format: "%.0f", caloriTotal))",
                        "meals":mealsFoodsArray] as [String : Any]
            
            detailsArray.add(dict)
            DLLog(message: "detailsArray:\(detailsArray)")
        }
        
        sendCreateCustomPlanRequest(detail: detailsArray)
    }
    @objc func addFoodsNotifi(notify:Notification) {
        let foodsDict = notify.object ?? [:]
        DLLog(message: "\(foodsDict)")
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.addFoodsSource(foodsMsg: foodsDict as! NSDictionary)
//            self.refreshNaturalMsg()
//        }
    }
    @objc func addFoodsFastNotifi(notify:Notification) {
        let foodsDict = notify.object ?? [:]
        DLLog(message: "\(foodsDict)")
        
        self.addFoodsSource(foodsMsg: foodsDict as! NSDictionary)
//        self.refreshNaturalMsg()
    }
    func deleteFoods(foodsDict:NSDictionary,index:Int) {
        //每一天的数据
        let dataSourceForDay = NSMutableArray.init(array: self.dataSourceArray[self.daysIndex]as? NSArray ?? [])
        //每一餐
        let mealsDict = NSMutableDictionary.init(dictionary: dataSourceForDay[self.mealsIndex]as? NSDictionary ?? [:])
        //每一餐的食物
        let foodsArray = NSMutableArray.init(array: mealsDict["foodsArray"]as? NSArray ?? [])
        foodsArray.removeObject(at: index)
        
        mealsDict.setValue(foodsArray, forKey: "foodsArray")
        dataSourceForDay.replaceObject(at: self.mealsIndex, with: mealsDict)
        dataSourceArray.replaceObject(at: self.daysIndex, with: dataSourceForDay)
        self.tableView.reloadData()
    }
    //新增一种食物
    func addFoodsSource(foodsMsg:NSDictionary) {
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        //每一天的数据
        let dataSourceForDay = NSMutableArray.init(array: self.dataSourceArray[self.daysIndex]as? NSArray ?? [])
        //每一餐
        let mealsDict = NSMutableDictionary.init(dictionary: dataSourceForDay[self.mealsIndex]as? NSDictionary ?? [:])
        //每一餐的食物
        let foodsArray = NSMutableArray.init(array: mealsDict["foodsArray"]as? NSArray ?? [])
        
        var hasFoods = false
        
        if self.selectFoodsIndex == -1 {
            for i in 0..<foodsArray.count{
                let dict = foodsArray[i]as? NSDictionary ?? [:]
                let dictFid = dict["fid"]as? String ?? "\(dict["fid"]as? Int ?? -1)"
                
                if dictFid != "-1" &&  dictFid == foodsMsg["fid"]as? String ?? "\(foodsMsg["fid"]as? Int ?? -2)" && dict["spec"]as? String ?? "" == foodsMsg["spec"]as? String ?? ""{
                    let foodsDict = NSMutableDictionary.init(dictionary: dict)
                    
                    let specNum = foodsMsg["qty"]as? Double ?? 0
                    var dictNum = dict["qty"]as? Double ?? 0
                    if dictNum == 0 {
                        dictNum = ((dict["qty"]as? String ?? "0") as NSString).doubleValue
                    }
                    let num = dictNum + specNum
                    
                    foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                    foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                    
                    let caloriesNumber = foodsMsg.doubleValueForKey(key: "caloriesNumber")
                    let calories = caloriesNumber/specNum * num
                    
                    let calori = calories
                    
//                    let calori = foodsDict.doubleValueForKey(key: "calories") + foodsMsg.doubleValueForKey(key: "caloriesNumber")
                    let carbo = foodsDict.doubleValueForKey(key: "carbohydrate") + foodsMsg.doubleValueForKey(key: "carbohydrateNumber")
                    let protein = foodsDict.doubleValueForKey(key: "protein") + foodsMsg.doubleValueForKey(key: "proteinNumber")
                    let fat = foodsDict.doubleValueForKey(key: "fat") + foodsMsg.doubleValueForKey(key: "fatNumber")
                    
                    foodsDict.setValue("\(WHUtils.convertStringToString("\(calori)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                    foodsDict.setValue("\(carbo)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                    foodsDict.setValue("\(protein)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                    foodsDict.setValue("\(fat)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                    
                    foodsArray.replaceObject(at: i, with: foodsDict)
                    hasFoods = true
                    break
                }
            }
            
            if hasFoods == false{
                foodsArray.add(foodsMsg)
            }
        }else{
            var hasData = false
            for i in 0..<foodsArray.count{
                let dict = foodsArray[i]as? NSDictionary ?? [:]
                
                let dictFid = dict["fid"]as? String ?? "\(dict["fid"]as? Int ?? -1)"
                
                if dictFid != "-1" &&  dictFid == foodsMsg["fid"]as? String ?? "\(foodsMsg["fid"]as? Int ?? -2)" && dict["spec"]as? String ?? "" == foodsMsg["spec"]as? String ?? ""{
                    let foodsDict = NSMutableDictionary.init(dictionary: dict)
                    
                    if self.selectFoodsIndex == i {
                        foodsDict.setValue("\(foodsMsg["qty"]as? Double ?? 0)".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                        foodsDict.setValue("\(foodsMsg["qty"]as? Double ?? 0)".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                        foodsDict.setValue("\(WHUtils.convertStringToString("\(foodsMsg.doubleValueForKey(key: "caloriesNumber"))") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                        foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "carbohydrateNumber"))".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                        foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "proteinNumber"))".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                        foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "fatNumber"))".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                        foodsArray.replaceObject(at: i, with: foodsDict)
                    }else{
                        let specNum = foodsMsg["qty"]as? Double ?? 0
                        var dictNum = dict["qty"]as? Double ?? 0
                        if dictNum == 0 {
                            dictNum = ((dict["qty"]as? String ?? "0") as NSString).doubleValue
                        }
                        let num = dictNum + specNum
                        
                        foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                        foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                        
                        let caloriesNumber = foodsMsg.doubleValueForKey(key: "caloriesNumber")
                        let calories = caloriesNumber/specNum * num
                        let calori = calories
                        
//                        let calori = foodsDict.doubleValueForKey(key: "calories") + foodsMsg.doubleValueForKey(key: "caloriesNumber")
                        let carbo = foodsDict.doubleValueForKey(key: "carbohydrate") + foodsMsg.doubleValueForKey(key: "carbohydrateNumber")
                        let protein = foodsDict.doubleValueForKey(key: "protein") + foodsMsg.doubleValueForKey(key: "proteinNumber")
                        let fat = foodsDict.doubleValueForKey(key: "fat") + foodsMsg.doubleValueForKey(key: "fatNumber")
                        
                        foodsDict.setValue("\(WHUtils.convertStringToString("\(calori)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                        foodsDict.setValue("\(carbo)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                        foodsDict.setValue("\(protein)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                        foodsDict.setValue("\(fat)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                        foodsArray.replaceObject(at: i, with: foodsDict)
                        if foodsArray.count > self.selectFoodsIndex {
                            foodsArray.removeObject(at: self.selectFoodsIndex)
                        }
                    }
                    hasData = true
                    break
                }
            }
            if hasData == false && foodsArray.count > self.selectFoodsIndex && self.selectFoodsIndex >= 0{
                foodsArray.replaceObject(at: self.selectFoodsIndex, with: foodsMsg)
            }
        }
        if foodsMsg.stringValueForKey(key: "fname") != "快速添加" && foodsMsg.stringValueForKey(key: "fid").count > 0{
            WHUtils().sendAddFoodsForCountRequest(fids: [foodsMsg.stringValueForKey(key: "fid")])
            WHUtils().sendAddHistoryFoods(foodsMsgArray: [foodsMsg])
        }
        mealsDict.setValue(foodsArray, forKey: "foodsArray")
        dataSourceForDay.replaceObject(at: self.mealsIndex, with: mealsDict)
        dataSourceArray.replaceObject(at: self.daysIndex, with: dataSourceForDay)
        self.tableView.reloadData()
    }
    //删除
    func delFoodsSource(foodsMsg:NSDictionary) {
        
    }
    func synFoods() {
        let indexArray = NSMutableArray()
        //一天的数据
        
        for i in 0..<self.daysNumber{
            if i != self.daysIndex{
                let vm = self.synAlertVm.daysVmArray[i]
                if vm.isSelect == true{
                    let dataSourceForCurrentDay = NSMutableArray.init(array: self.dataSourceArray[self.daysIndex]as? NSArray ?? [])
                    self.dataSourceArray.replaceObject(at: i, with: dataSourceForCurrentDay)
                }
            }
        }
    }
}

extension PlanCreateVC{
    func initUI() {
        initNavi(titleStr: "制作计划")
        
        self.backArrowButton.tapBlock = {()in
            self.customBackTapAction()
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(customBackTapAction))
        self.backView.addGestureRecognizer(tap)
        
        view.addSubview(tableView)
        view.addSubview(filterTopVm)
        view.addSubview(saveButton)
        
        headView.addSubview(nameVm)
        headView.addSubview(daysVm)
        headView.addSubview(goalsVm)
        headView.addSubview(filterVm)
        tableView.tableHeaderView = headView
        
//        view.addSubview(choiceFoodsAlertVm)
        view.addSubview(choiceDaysAlertVm)
        view.addSubview(synAlertVm)
        
        setConstrait()
    }
    func setConstrait() {
        saveButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(-12)-getBottomSafeAreaHeight())
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(48))
        }
    }
}

extension PlanCreateVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arr = self.dataSourceArray[self.daysIndex]as? NSArray ?? []
        self.refreshNaturalMsg()
        return arr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCreateTableViewCell") as? PlanCreateTableViewCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCreateTableViewCell", for: indexPath) as? PlanCreateTableViewCell
        
        let dataSourceForDay = self.dataSourceArray[self.daysIndex]as? NSArray ?? []
        let dict = dataSourceForDay[indexPath.row]as? NSDictionary ?? [:]
//        cell.updateUI(dict: dict as! NSDictionary)
        cell?.setFoodsArray(dict: dict)
        cell?.controller = self
        
        cell?.addBlock = {()in
            TouchGenerator.shared.touchGeneratorMedium()
            self.nameVm.textField.resignFirstResponder()
            self.mealsIndex = indexPath.row
            self.selectFoodsIndex = -1
//            let foodsArray =  dict["foodsArray"]as? NSArray ?? []
            let vc = FoodsListNewVC()
            vc.isFromPlan = true
            vc.sourceType = .plan
            self.navigationController?.pushViewController(vc, animated: true)
        }
        cell?.addNewSpecBlock = {(dict)in
//            self.choiceFoodsAlertVm.addNewSpecFoods(dict: dict)
        }
        
        cell?.deleteFoodsBlock = {(foodsDict,index)in
            self.mealsIndex = indexPath.row
            self.deleteFoods(foodsDict: foodsDict,index: index)
        }
        cell?.selectMeaslIndexBlock = {(index)in
            self.mealsIndex = indexPath.row
            self.selectFoodsIndex = index
        }
        
        return cell ?? PlanCreateTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dataSourceForDay = self.dataSourceArray[self.daysIndex]as? NSArray ?? []
        let dict = dataSourceForDay[indexPath.row]as? NSDictionary ?? [:]
        let foodsArray =  dict["foodsArray"]as? NSArray ?? []
        if foodsArray.count > 0 {
            return CGFloat(foodsArray.count)*kFitWidth(55) + kFitWidth(70) + kFitWidth(20) + kFitWidth(20)
        }else{
            return kFitWidth(103)
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.nameVm.textField.resignFirstResponder()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView{
            if scrollView.contentOffset.y >= self.filterVm.frame.minY {
                self.filterTopVm.isHidden = false
                self.offsetY = getNavigationBarHeight()+self.filterVm.selfHeight
                
                var titleString = nameVm.textField.text
                if titleString == ""{
                    titleString = "待命名"
                }
                if titleString?.count ?? 0 > 10 {
                    titleString = "\(titleString?.mc_clipFromPrefix(to: 8) ?? "")..."
                }
                self.titleString = "\(titleString ?? "")·\(self.daysNumber)天·"
                titleString = "\(titleString ?? "")·\(self.daysNumber)天·\(goalsVm.caloriTotalLabel.text ?? "0")千卡"
                
                self.naviTitleLabel.text = "\(titleString ?? "制作计划")"
            }else{
                self.filterTopVm.isHidden = true
                self.offsetY = self.headView.frame.height + getNavigationBarHeight() - scrollView.contentOffset.y
                self.naviTitleLabel.text = "制作计划"
                self.titleString = ""
            }
        }
    }
}

extension PlanCreateVC{
    func refreshNaturalMsg(){
        let dataSourceForDay = self.dataSourceArray[self.daysIndex]as? NSArray ?? []
        
        var caloriTotal = Double(0)
        var carboTotal = Double(0.0)
        var proteinTotal = Double(0.0)
        var fatsTotal = Double(0.0)
        
        for i in 0..<dataSourceForDay.count {
            let dict = dataSourceForDay[i]as? NSDictionary ?? [:]
            
            let foodsArray = dict["foodsArray"]as? NSArray ?? []
            for j in 0..<foodsArray.count{
                let foodsDict = foodsArray[j]as? NSDictionary ?? [:]
                let calori = Double(foodsDict["calories"]as? String ?? "0")
                let carbo = Double(foodsDict["carbohydrate"]as? String ?? "0.00")
                let protein = Double(foodsDict["protein"]as? String ?? "0.00")
                let fats = Double(foodsDict["fat"]as? String ?? "0.00")
                
                caloriTotal = caloriTotal + (calori ?? 0)
                carboTotal = carboTotal + (carbo ?? 0.0)
                proteinTotal = proteinTotal + (protein ?? 0.0)
                fatsTotal = fatsTotal + (fats ?? 0.0)
            }
        }
        
        goalsVm.caloriTotalLabel.text = "\(String(format: "%.0f", caloriTotal))"
        goalsVm.carboNumberLabel.text = "\(String(format: "%.0f", carboTotal))"
        goalsVm.proteinNumberLabel.text = "\(String(format: "%.0f", proteinTotal))"
        goalsVm.fatNumberLabel.text = "\(String(format: "%.0f", fatsTotal))"
        
        if self.titleString.count > 0 {
            self.naviTitleLabel.text = "\(self.titleString)\(goalsVm.caloriTotalLabel.text ?? "0")千卡"
        }
    }
}

extension PlanCreateVC{
    func sendCreateCustomPlanRequest(detail:NSArray) {
        MCToast.mc_loading()
        let param = ["pname":"\(self.nameVm.textField.text ?? "")",
                     "pdays":"\(self.daysNumber)",
                     "uid":"\(UserInfoModel.shared.uId)",
                     "details":detail] as [String : Any]
        DLLog(message: "sendCreateCustomPlanRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_create_plan_custom, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: "\(responseObject)")
            UserDefaults.standard.setValue("", forKey: "planCreateData")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshListData"), object: nil)
            
            if self.createBlock != nil{
//                self.backTapAction()
                self.navigationController?.popViewController(animated: false)
                self.createBlock!()
            }else{
                self.presentAlertVc(confirmBtn: "确定", message: "", title: "计划已保存", cancelBtn: nil, handler: { action in
                    self.backTapAction()
                }, viewController: self)
            }
        }
    }
}
