//
//  FoodsListAddListVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import UIKit
import UMCommon


class FoodsListAddListVM: UIView {
    
    var selfHeight = kFitWidth(119)
    var historyFoodsArray = NSArray()
    var foodsArray = NSMutableArray()
    var foodsArraySortBySelectCount = NSMutableArray()
    
    var isFromPlan = false
    var controller = WHBaseViewVC()
    var sourceType = ADD_FOODS_SOURCE.other
    var fname = ""
    
    var sortType = "time"//time 按最近添加时间排序    selectCount 按添加次数排序
    
    var scrollBlock:(()->())?
    var searchBlock:((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        selfHeight = SCREEN_HEIGHT-frame.origin.y
        initUI()
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            self.historyFoodsArray = UserDefaults.getHistoryFoods()
            self.foodsArray = NSMutableArray(array: self.historyFoodsArray)
            self.sortDataArray()
            self.tableView.hideSkeleton()
            self.tableView.reloadData()
            
    //        if foodsArray.count == 0 {
            self.sendHistoryFoodsListRequest()
    //        }
//        })
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: kFitWidth(200), height: kFitWidth(44)))
        lab.text = "最近添加"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
//    lazy var sortBtn: UIButton = {
//        let btn = UIButton()
//        btn.setTitle("按时间", for: .normal)
//        btn.setTitleColor(.THEME, for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: WHColorWithAlpha(colorStr: "007AFF", alpha: 0.15)), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .highlighted)
//        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
//        btn.layer.cornerRadius = kFitWidth(12)
//        btn.clipsToBounds = true
//        btn.addTarget(self, action: #selector(sortBtnAction), for: .touchUpInside)
//        
//        return btn
//    }()
    lazy var sortTypeButton: GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT*0.5, height: selfHeight-WHUtils().getBottomSafeAreaHeight()))
        btn.setTitle("最新", for: .normal)
        btn.setImage(UIImage.init(named: "circle_change_icon"), for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.backgroundColor = .clear
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(sortBtnAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.init(x: 0, y: kFitWidth(44), width: SCREEN_WIDHT, height: selfHeight-kFitWidth(44)), style: .plain)
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.delegate = self
        table.dataSource = self
        table.register(FoodsListAddTableViewCell.classForCoder(), forCellReuseIdentifier: "FoodsListAddTableViewCell")
        // 解决tableView为Grouped类型时，设置了sectionHeader时会向下偏移问题
//        table.tableHeaderView = UIView.init(frame: .zero)
        table.tableFooterView = footerVm
        
        return table
    }()
    lazy var noDataVm: FoodsListHeaderNoDataVM = {
        let vm = FoodsListHeaderNoDataVM.init(frame: .zero)
        vm.isHidden = true
        vm.searchFoodsButton.addTarget(self, action: #selector(searchTapAction), for: .touchUpInside)
        return vm
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.isHidden = true
        vi.noDataLabel.text = "- 无最近数据 -"
        vi.tipsLabel.isHidden = true//false
        return vi
    }()
    lazy var footerVm: FoodsListFooterVM = {
        let vm = FoodsListFooterVM.init(frame: .zero)
        vm.searchFoodsButton.addTarget(self, action: #selector(searchTapAction), for: .touchUpInside)
        return vm
    }()
}

extension FoodsListAddListVM{
    @objc func sortBtnAction() {
        let indexSet = IndexSet(integer: 0)
        if self.sortType == "time"{
            self.sortType = "selectCount"
            sortTypeButton.setTitle("次数", for: .normal)
//            self.tableView.reloadSections(indexSet, with: .right)
        }else{
            self.sortType = "time"
            sortTypeButton.setTitle("最新", for: .normal)
//            self.tableView.reloadSections(indexSet, with: .left)
        }
        sortTypeButton.imagePosition(style: .right, spacing: kFitWidth(3))
//        self.tableView.reloadSections(indexSet, with: .fade)
        self.tableView.reloadData()
    }
    func deleteFoods(foodsMsg:NSDictionary) {
        UserDefaults.delFoods(foodsDict: foodsMsg)
        self.historyFoodsArray = UserDefaults.getHistoryFoods()
        self.foodsArray = NSMutableArray(array: self.historyFoodsArray)
        self.tableView.reloadData()
//        self.sendDelHistoryFoods(dict: foodsMsg)
    }
    func searchHistoryFoodsList() {
        foodsArray.removeAllObjects()
        if fname == ""{
            foodsArray = NSMutableArray.init(array: historyFoodsArray)
        }else{
            for i in 0..<historyFoodsArray.count{
                let foodsDict = historyFoodsArray[i]as? NSDictionary ?? [:]
                if let fName = foodsDict["fname"]{
                    if (foodsDict["fname"]as? String ?? "").contains("\(fname)"){
                        foodsArray.add(foodsDict)
                    }
                }else{
                    let foodsMsgDict = foodsDict["foods"]as? NSDictionary ?? [:]
                    
                    if (foodsMsgDict["fname"]as? String ?? "").contains("\(fname)"){
                        foodsArray.add(foodsDict)
                    }
                }
            }
        }
        self.tableView.reloadData()
        
        sendHistoryFoodsListRequest()
    }
    func searchHistory() {
        fname = ""
        foodsArray.removeAllObjects()
        foodsArray = NSMutableArray.init(array: historyFoodsArray)
        self.tableView.reloadData()
    }
    @objc func searchTapAction() {
        self.searchBlock?(self.fname)
    }
    func addAction(foodsMsgDict:NSDictionary) {
        var foodMsg = NSMutableDictionary.init(dictionary: foodsMsgDict)
        let foodsDict = foodsMsgDict["foods"]as? NSDictionary ?? [:]
        if foodMsg.stringValueForKey(key: "qty") == "" || foodMsg.stringValueForKey(key: "qty") == "0"{
//            let foodsDict = foodsMsgDict["foods"]as? NSDictionary ?? [:]
            foodMsg = NSMutableDictionary.init(dictionary: foodsDict)
            
            foodMsg.setValue("\(foodsDict.stringValueForKey(key: "protein"))".replacingOccurrences(of: ",", with: "."), forKey: "proteinNumber")
            foodMsg.setValue("\(foodsDict.stringValueForKey(key: "carbohydrate"))".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrateNumber")
            foodMsg.setValue("\(foodsDict.stringValueForKey(key: "fat"))".replacingOccurrences(of: ",", with: "."), forKey: "fatNumber")
            foodMsg.setValue("\(foodsDict.stringValueForKey(key: "calories"))".replacingOccurrences(of: ",", with: "."), forKey: "caloriesNumber")
            foodMsg.setValue("\(foodsDict.stringValueForKey(key: "protein"))".replacingOccurrences(of: ",", with: "."), forKey: "protein")
            foodMsg.setValue("\(foodsDict.stringValueForKey(key: "carbohydrate"))".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
            foodMsg.setValue("\(foodsDict.stringValueForKey(key: "fat"))".replacingOccurrences(of: ",", with: "."), forKey: "fat")
            foodMsg.setValue("\(foodsDict.stringValueForKey(key: "calories"))".replacingOccurrences(of: ",", with: "."), forKey: "calories")
            foodMsg.setValue("\(foodsDict.stringValueForKey(key: "spec"))", forKey: "spec")
            foodMsg.setValue(foodsDict, forKey: "foods")
            foodMsg.setValue("1", forKey: "select")
            foodMsg.setValue("1", forKey: "state")
            
            let specDefault = WHUtils.getSpecDefaultFromFoods(foodsDict: foodsDict)
            foodMsg.setValue("\(specDefault.stringValueForKey(key: "specName"))", forKey: "specName")
            foodMsg.setValue("\(specDefault.stringValueForKey(key: "specName"))", forKey: "spec")
            foodMsg.setValue("\(specDefault.stringValueForKey(key: "specNum"))".replacingOccurrences(of: ",", with: "."), forKey: "weight")
            foodMsg.setValue("\(specDefault.stringValueForKey(key: "specNum"))".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
            foodMsg.setValue(specDefault.doubleValueForKey(key: "specNum"), forKey: "qty")
        }else{
            if (foodsDict["fname"]as? String ?? "").count > 0{
                foodMsg.setValue("\(foodsDict.stringValueForKey(key: "fname"))", forKey: "fname")
            }
            
            foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "qty"))".replacingOccurrences(of: ",", with: "."), forKey: "weight")
            foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "qty"))".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
            foodMsg.setValue(foodsMsgDict.doubleValueForKey(key: "qty"), forKey: "qty")
            foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "protein"))".replacingOccurrences(of: ",", with: "."), forKey: "proteinNumber")
            foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "carbohydrate"))".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrateNumber")
            foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "fat"))".replacingOccurrences(of: ",", with: "."), forKey: "fatNumber")
            foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "calories"))".replacingOccurrences(of: ",", with: "."), forKey: "caloriesNumber")
            foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "protein"))".replacingOccurrences(of: ",", with: "."), forKey: "protein")
            foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "carbohydrate"))".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
            foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "fat"))".replacingOccurrences(of: ",", with: "."), forKey: "fat")
            foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "calories"))".replacingOccurrences(of: ",", with: "."), forKey: "calories")
            foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "spec"))", forKey: "specName")
            foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "spec"))", forKey: "spec")
            foodMsg.setValue("1", forKey: "select")
            foodMsg.setValue("1", forKey: "state")
        }
//        MobClick.event("journalAddHistoryFoods")
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForLogs"), object: foodMsg)
        if self.sourceType == .logs{
            MobClick.event("journalAddMeals")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForLogs"), object: foodMsg)
        }else if self.sourceType == .plan{
            MobClick.event("journalAddHistoryFoods")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForPlan"), object: foodMsg)
        }
        UserDefaults.saveFoods(foodsDict: foodMsg)
    }
    func sortDataArray() {
        let dictonaries:[Dictionary<String,Any>] = foodsArray.map { $0 as! [String: Any] }
    
        let sortedDictionaries = dictonaries.sorted {
            if let age1 = $0["selected_count"] as? Int, let age2 = $1["selected_count"] as? Int {
                return age1 > age2
            }
            return false
        }
        let sortedArrayOfDictionaries: [NSDictionary] = sortedDictionaries.map { NSDictionary(dictionary: $0) }
        foodsArraySortBySelectCount = NSMutableArray(array: sortedArrayOfDictionaries)
    }
}

extension FoodsListAddListVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(sortTypeButton)
        addSubview(tableView)
        tableView.addSubview(noDataView)
        tableView.addSubview(noDataVm)
        initSkeletonData()
//        noDataView.center = CGPoint.init(x: self.tableView.frame.width * 0.5, y: kFitWidth(90))
        
        sortTypeButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(titleLabel)
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(44))
//            make.width.equalTo(kFitWidth(88))
//            make.height.equalTo(kFitWidth(24))
        }
        
        sortTypeButton.imagePosition(style: .right, spacing: kFitWidth(3))
    }
    func initSkeletonData() {
        foodsArray.add([:])
        foodsArray.add([:])
        foodsArray.add([:])
        foodsArray.add([:])
        foodsArray.add([:])
        foodsArray.add([:])
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05, execute: {
            self.tableView.showAnimatedGradientSkeleton()
            self.tableView.isUserInteractionEnabled = true
        })
    }
}

extension FoodsListAddListVM:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sortType == "time"{
            if self.fname.count > 0 {
                noDataView.isHidden = true
                sortTypeButton.isHidden = true
                noDataVm.isHidden = foodsArray.count > 0 ? true : false
                noDataVm.setNoDataText(text: self.fname)
                footerVm.setNoDataText(text: self.fname)
            }else{
                noDataVm.isHidden = true
                sortTypeButton.isHidden = false
                noDataView.isHidden = foodsArray.count > 0 ? true : false
                footerVm.setNoDataText(text: "")
            }
            footerVm.isHidden = foodsArray.count > 0 ? false : true
            return foodsArray.count
        }else{
            if self.fname.count > 0 {
                noDataView.isHidden = true
                sortTypeButton.isHidden = true
                noDataVm.isHidden = foodsArray.count > 0 ? true : false
                noDataVm.setNoDataText(text: self.fname)
                footerVm.setNoDataText(text: self.fname)
            }else{
                noDataVm.isHidden = true
                sortTypeButton.isHidden = false
                noDataView.isHidden = foodsArray.count > 0 ? true : false
                footerVm.setNoDataText(text: "")
            }
            footerVm.isHidden = foodsArraySortBySelectCount.count > 0 ? false : true
            return foodsArraySortBySelectCount.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodsListAddTableViewCell") as? FoodsListAddTableViewCell
        
//        let cell = FoodsListAddTableViewCell(style: .default, reuseIdentifier: "FoodsListAddTableViewCell")
        var dict = NSDictionary()
        
        if sortType == "time"{
            dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
        }else{
            dict = foodsArraySortBySelectCount[indexPath.row]as? NSDictionary ?? [:]
        }
        cell?.updateUIForHistory(dict: dict,keywords: "\(fname)")
        
        if self.sourceType == .logs{
            cell?.addButtonVm.isHidden = false
            cell?.addButtonVm.bgView.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        }else{
            cell?.addButtonVm.isHidden = true
            cell?.foodsNameLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.top.equalTo(kFitWidth(18))
                make.right.equalTo(kFitWidth(-10))
            }
        }
        
        cell?.addButtonVm.tapBlock = {()in
            self.addAction(foodsMsgDict: dict)
        }
        
        return cell ?? FoodsListAddTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(72)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var dict = NSDictionary()
        
        if sortType == "time"{
            dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
        }else{
            dict = foodsArraySortBySelectCount[indexPath.row]as? NSDictionary ?? [:]
        }
//        let dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
        
        let vc = FoodsMsgDetailsVC()
        if dict.doubleValueForKey(key: "qty") > 0{
            vc.specNum = dict.stringValueForKey(key: "qty")
            vc.specName = dict["spec"]as? String ?? "g"
        }
        vc.foodsDetailDict = dict["foods"]as? NSDictionary ?? [:]
        vc.sourceType = self.sourceType
        self.controller.navigationController?.pushViewController(vc, animated:true)
        
        if self.sourceType == .main {
            vc.confirmButton.isHidden = true
        }
        if self.scrollBlock != nil{
            self.scrollBlock!()
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
//            let dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
            var dict = NSDictionary()
            
            if sortType == "time"{
                dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
            }else{
                dict = foodsArraySortBySelectCount[indexPath.row]as? NSDictionary ?? [:]
            }
            self.sendDelHistoryFoods(dict: dict)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.scrollBlock != nil{
            self.scrollBlock!()
        }
    }
}

extension FoodsListAddListVM{
    func sendDelHistoryFoods(dict:NSDictionary) {
        let param = ["fid":"\(dict.stringValueForKey(key: "fid"))"]
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_history_del, parameters: param as [String:AnyObject]) { responseObject in
            UserDefaults.delFoods(foodsDict: dict)
            self.historyFoodsArray = UserDefaults.getHistoryFoods()
            self.foodsArray.remove(dict)
            self.foodsArraySortBySelectCount.remove(dict)
            self.tableView.reloadData()
        }
    }
    func sendHistoryFoodsListRequest(){
        let param = ["fname":"\(fname)"]
        DLLog(message: "文字变化：textChanged  result sendHistoryFoodsListRequest :\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_history_list, parameters: param as [String:AnyObject]) { responseObject in
            DLLog(message: "\(responseObject)")
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendHistoryFoodsListRequest:\(self.historyFoodsArray)")
            
            self.foodsArray = NSMutableArray(array: dataArr)
//            self.tableView.reloadData()
            
            if self.fname == ""{
                self.historyFoodsArray = dataArr
                UserDefaults.set(value: WHUtils.getJSONStringFromArray(array: self.foodsArray), forKey: .hidsoryFoodsAdd)
            }
            self.sortDataArray()
            self.tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05, execute: {
                self.tableView.isUserInteractionEnabled = true
            })
        }
    }
}
