//
//  FoodsListMyListVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/5.
//

import Foundation
import UIKit

class FoodsListMyListVM: UIView {
    
    var fname = ""
    var fNameChanged = false
    
    
    var selfHeight = kFitWidth(119)
    var myFoodsArray = NSArray()
    var foodsArray = NSMutableArray()
    
    var isFromPlan = false
    var canAdd = true
    var controller = WHBaseViewVC()
    var sourceType = ADD_FOODS_SOURCE.other
    
    var scrollBlock:(()->())?
    var deleteFoodsBlock:((NSDictionary)->())?
    var searchNoDataBlocK:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        myFoodsArray = UserDefaults.getMyFoods()
        foodsArray = NSMutableArray(array: myFoodsArray)
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.selfHeight), style: .plain)
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.delegate = self
        table.dataSource = self
        table.register(FoodsListAddTableViewCell.classForCoder(), forCellReuseIdentifier: "FoodsListAddTableViewCell")
        
        return table
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.isHidden = true
        return vi
    }()
    lazy var footerVm: FoodsListFooterVM = {
        let vm = FoodsListFooterVM.init(frame: .zero)
        return vm
    }()
}

extension FoodsListMyListVM{
    func initUI() {
        addSubview(tableView)
        
        tableView.addSubview(noDataView)
        noDataView.center = CGPoint.init(x: self.tableView.frame.width * 0.5, y: kFitWidth(134))
        
        tableView.isSkeletonable = true
        self.isSkeletonable = true
        
        self.initSkeletonData()
    }
    func searchFoods(fName:String) {
        self.fname = fName
        self.isHidden = false
        if fName.count > 0{
            initSkeletonData()
        }
        self.sendMyFoodsRequest()
    }
    
    func searchMyFoodsList() {
        foodsArray.removeAllObjects()
        initSkeletonData()
        if fname == ""{
            foodsArray = NSMutableArray.init(array: myFoodsArray)
        }else{
            foodsArray.removeAllObjects()
            for i in 0..<myFoodsArray.count{
                let foodsDict = myFoodsArray[i]as? NSDictionary ?? [:]
                if (foodsDict["fname"]as? String ?? "").contains("\(fname)"){
                    foodsArray.add(foodsDict)
                }
            }
        }
        self.tableView.hideSkeleton()
        self.tableView.reloadData()
    }
    func initSkeletonData() {
        foodsArray.removeAllObjects()
        foodsArray.addObjects(from: [[:],[:],[:],[:],[:],[:],[:],[:]])
        self.tableView.reloadData()
        self.tableView.showAnimatedGradientSkeleton()
    }
}

extension FoodsListMyListVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noDataView.isHidden = foodsArray.count > 0 ? true : false
        footerVm.isHidden = foodsArray.count == 0 ? true : false
        if foodsArray.count == 0 && self.searchNoDataBlocK != nil{
            self.searchNoDataBlocK!()
        }
        return foodsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodsListAddTableViewCell") as? FoodsListAddTableViewCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodsListAddTableViewCell", for: indexPath) as? FoodsListAddTableViewCell
        let dict = self.foodsArray[indexPath.row]as? NSDictionary ?? [:]

        cell?.updateUIForMy(dict: dict,keywords: "\(fname)")
        
        return cell ?? FoodsListAddTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(72)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let foodsDict = self.foodsArray[indexPath.row]as? NSDictionary ?? [:]
        
        let vc = FoodsMsgDetailsVC()
        vc.foodsDetailDict = foodsDict
        vc.sourceType = self.sourceType
        self.controller.navigationController?.pushViewController(vc, animated:true)
        if self.sourceType == .main {
            vc.confirmButton.isHidden = true
        }
        vc.deleteBlock = {()in
            if self.deleteFoodsBlock != nil{
                self.deleteFoodsBlock!(foodsDict)
            }
            
//            self.foodsArray.removeObject(at: indexPath.row)
//            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            
            if indexPath.row < self.foodsArray.count {
                self.foodsArray.removeObject(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            guard indexPath.row < self.foodsArray.count else { return }
//            let array = self.foodsArray[indexPath.section]as? NSArray ?? []
            let dict = self.foodsArray[indexPath.row]as? NSDictionary ?? [:]
            self.controller.presentAlertVc(confirmBtn: "删除", message: "是否删除食物“\(dict["fname"]as? String ?? "")”", title: "温馨提示", cancelBtn: "取消", handler: { action in
                self.sendDeleteFoodsRequest(fid: "\(Int(dict["fid"]as? String ?? "-1") ?? -1)",indexPath:indexPath,foodsMsg: dict)
            }, viewController: self.controller)
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

extension FoodsListMyListVM{
    @objc func sendMyFoodsRequest() {
        let param = ["fname":"\(fname)"]
//        if fname.count > 0 {
//            initSkeletonData()
//        }
        if fNameChanged == true{
            foodsArray.removeAllObjects()
            self.tableView.reloadData()
            initSkeletonData()
        }
        fNameChanged = false
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_list_my, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
//            UserDefaults.set(value: WHUtils.getJSONStringFromArray(array: dataArr), forKey: .myFoodsList)
            self.tableView.hideSkeleton()
            self.foodsArray = NSMutableArray.init(array: dataArr)
            self.tableView.reloadData()
            
            if self.foodsArray.count > 0{
                self.tableView.tableFooterView = self.footerVm
            }else{
                self.tableView.tableFooterView = nil
            }
            
            if self.fname == ""{
                UserDefaults.set(value: WHUtils.getJSONStringFromArray(array: dataArr), forKey: .myFoodsList)
            }
        }
    }
    func sendDeleteFoodsRequest(fid:String,indexPath:IndexPath,foodsMsg:NSDictionary) {
        let param = ["fname":"\(foodsMsg.stringValueForKey(key: "fname"))"]
        
        myFoodsArray = UserDefaults.getMyFoods()
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_delete, parameters: param as [String:AnyObject]) { responseObject in
            UserDefaults.delFoods(foodsDict: foodsMsg, forKey: .myFoodsList)
            
            if self.deleteFoodsBlock != nil{
                self.deleteFoodsBlock!(foodsMsg)
            }
//            
//            self.foodsArray.removeObject(at: indexPath.row)
//            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            if indexPath.row < self.foodsArray.count {
                self.foodsArray.removeObject(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}
