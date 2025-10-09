//
//  MyFoodsListVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/20.
//

import Foundation
import MCToast

class MyFoodsListVC: WHBaseViewVC {
    
    var foodsArray = NSMutableArray()
    var foodsSourceArray = NSArray()
    var foodsName = ""
    
    override func viewWillAppear(_ animated: Bool) {
        foodsArray = NSMutableArray.init(array: UserDefaults.getMyFoods())
        foodsSourceArray = foodsArray
        if foodsArray.count > 0 {
//            DispatchQueue.main.asyncAfter(deadline: .now()+4, execute: {
                self.tableView.reloadData()
//            })
            
        }else{
            sendMyFoodsRequest()
        }
//        self.searchVm.textField.startCountdown()
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        self.searchVm.textField.disableTimer()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    lazy var searchVm : QuestionnairePlanFoodsSearchVM = {
        let vm = QuestionnairePlanFoodsSearchVM.init(frame: CGRect.init(x: 0, y: kFitWidth(4)+getNavigationBarHeight(), width: 0, height: 0))
        vm.searchImgView.setImgLocal(imgName: "main_search_icon")
        vm.searchBlock = {()in
            self.searchMyFoodsList()
            
            self.mealsVm.fname = self.searchVm.textField.text ?? ""
            self.mealsVm.sendMyMealsRequest()
        }
        return vm
    }()
    lazy var typeVm: MineFoodsTypeVM = {
        let vm = MineFoodsTypeVM.init(frame: CGRect.init(x: 0, y: self.searchVm.frame.maxY, width: 0, height: 0))
        vm.myFoodsTapBlock = {()in
            self.searchVm.textField.resignFirstResponder()
            let searchString = self.searchVm.textField.text?.replacingOccurrences(of: " ", with: "")
            self.mealsVm.isHidden = true
            self.createButton.setTitle("创建食物", for: .normal)
            self.searchVm.textField.placeholder = "请输入想要搜索的食物"
        }
        vm.myMealsTapBlock = {()in
            self.searchVm.textField.resignFirstResponder()
            let searchString = self.searchVm.textField.text?.replacingOccurrences(of: " ", with: "")
            self.mealsVm.isHidden = false
            self.createButton.setTitle("创建食谱/餐食", for: .normal)
            self.searchVm.textField.placeholder = "请输入想要搜索的食谱/餐食"
        }
        return vm
    }()
    lazy var mealsVm: MealsListVM = {
        let vm = MealsListVM.init(frame: CGRect.init(x: 0, y: self.typeVm.frame.maxY, width: 0, height: 0))
        vm.isHidden = true
        vm.controller = self
        vm.sourceType = .main
        vm.scrollBlock = {()in
            self.searchVm.textField.resignFirstResponder()
        }
        return vm
    }()
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.init(x: 0, y: self.typeVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getBottomSafeAreaHeight()-kFitWidth(60)-self.typeVm.frame.maxY), style: .plain)
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.delegate = self
        table.dataSource = self
        table.register(FoodsListAddTableViewCell.classForCoder(), forCellReuseIdentifier: "FoodsListAddTableViewCell")
        table.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        
        return table
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.isHidden = true
        return vi
    }()
    lazy var createButton: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(16), y: SCREEN_HEIGHT-getBottomSafeAreaHeight()-kFitWidth(60), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(48))
        btn.setTitle("创建食物", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .THEME
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(createFoodsActino), for: .touchUpInside)
        return btn
    }()
}

extension MyFoodsListVC{
    func searchMyFoodsList() {
        let fname = self.searchVm.textField.text ?? ""//(self.searchVm.textField.text ?? "").disable_emoji(text: (self.searchVm.textField.text ?? "") as NSString)
        foodsSourceArray = UserDefaults.getMyFoods()
        if fname == ""{
            foodsArray = NSMutableArray.init(array: foodsSourceArray)
//            foodsArray = NSMutableArray.init(array: myFoodsArray)
        }else{
            foodsArray.removeAllObjects()
            for i in 0..<foodsSourceArray.count{
                let foodsDict = foodsSourceArray[i]as? NSDictionary ?? [:]
                if (foodsDict["fname"]as? String ?? "").contains("\(fname)"){
                    foodsArray.add(foodsDict)
                }
            }
        }
        self.tableView.reloadData()
    }
    @objc func createFoodsActino() {
        if self.typeVm.foodsType == "my"{
            let vc = FoodsCreateVC()
            self.navigationController?.pushViewController(vc, animated: true)
            vc.addBlock = {()in
    //            self.view.becomeFirstResponder()
    //            self.topTypeVM.myFoodsTapAction()
            }
        }else{
            let vc = MealsDetailsVC()
            vc.eatButton.isHidden = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MyFoodsListVC{
    func initUI() {
        initNavi(titleStr: "我的食物")
        
        view.addSubview(searchVm)
        view.addSubview(typeVm)
        view.addSubview(tableView)
        view.addSubview(mealsVm)
        view.addSubview(createButton)
        
        tableView.addSubview(noDataView)
        noDataView.center = CGPoint.init(x: self.tableView.frame.width * 0.5, y: self.tableView.frame.height * 0.5)
        
        let mealsFrame = mealsVm.frame
        mealsVm.frame = CGRect.init(x: 0, y: mealsFrame.origin.y, width: SCREEN_WIDHT, height: self.tableView.frame.height)
        mealsVm.clipsToBounds = true
    }
}

extension MyFoodsListVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noDataView.isHidden = foodsArray.count > 0 ? true : false
        return self.foodsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodsListAddTableViewCell") as? FoodsListAddTableViewCell
        let dict = self.foodsArray[indexPath.row]as? NSDictionary ?? [:]
//        cell?.updateUI(dict: dict)
        cell?.updateUIForMy(dict: dict, keywords: self.searchVm.textField.text)
        return cell ?? FoodsListAddTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(72)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchVm.textField.resignFirstResponder()
        let dict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
        
        let vc = FoodsMsgDetailsVC()
        vc.foodsDetailDict = dict
//        vc.sourceType = self.sourceType
        vc.confirmButton.isHidden = true
        self.navigationController?.pushViewController(vc, animated:true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            TouchGenerator.shared.touchGenerator()
            let dict = self.foodsArray[indexPath.row]as? NSDictionary ?? [:]
            self.presentAlertVc(confirmBtn: "删除", message: "是否删除食物“\(dict["fname"]as? String ?? "")”", title: "温馨提示", cancelBtn: "取消", handler: { action in
                self.sendDeleteFoodsRequest(fid: "\(Int(dict["fid"]as? String ?? "-1") ?? -1)",indexPath:indexPath,foodsMsg: dict)
            }, viewController: self)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchVm.textField.resignFirstResponder()
    }
}

extension MyFoodsListVC{
    func sendDeleteFoodsRequest(fid:String,indexPath:IndexPath,foodsMsg:NSDictionary) {
        MCToast.mc_loading()
        
        let param = ["fname":"\(foodsMsg.stringValueForKey(key: "fname"))"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_delete, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: "\(responseObject)")
            UserDefaults.delFoods(foodsDict: foodsMsg, forKey: .myFoodsList)
            UserDefaults.delFoods(foodsDict: foodsMsg, forKey: .hidsoryFoodsAdd)
            self.foodsArray.removeObject(at: indexPath.row)
//            self.foodsSourceArray = self.foodsArray
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    @objc func sendMyFoodsRequest() {
        foodsArray.removeAllObjects()
        let param = ["fname":"\(searchVm.textField.text ?? "")"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_list_my, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = self.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendMyFoodsRequest:\(dataArr)")
//            let dataArr = responseObject["data"]as? NSArray ?? []
            UserDefaults.set(value: self.getJSONStringFromArray(array: dataArr), forKey: .myFoodsList)
            self.foodsArray.addObjects(from: dataArr as! [Any])
//            self.foodsSourceArray = self.foodsArray
            
//            DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
                self.tableView.reloadData()
//            })
            
        }
    }
}
