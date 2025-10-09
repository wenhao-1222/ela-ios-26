//
//  FoodsListAllListVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/4.
//

import Foundation
import UIKit

class FoodsListAllListVM: UIView {
    
    var fname = ""
    var fNameChanged = false
    
    var selfHeight = kFitWidth(119)
    var foodsArray = NSMutableArray()
    
    var isFromPlan = false
    var canAdd = true
    var controller = WHBaseViewVC()
    var sourceType = ADD_FOODS_SOURCE.other
    
    var scrollBlock:(()->())?
    var searchNoDataBlocK:(()->())?
    
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        selfHeight = SCREEN_HEIGHT-frame.origin.y
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
        table.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
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
    lazy var footerVm: FoodsListFooterVM = {
        let vm = FoodsListFooterVM.init(frame: .zero)
        return vm
    }()
}

extension FoodsListAllListVM{
    func initUI() {
        addSubview(tableView)
        
        tableView.addSubview(noDataView)
        noDataView.center = CGPoint.init(x: self.tableView.frame.width * 0.5, y: kFitWidth(134))
//        tableView.isSkeletonable = true
//        self.isSkeletonable = true
        initSkeletonData()
    }
    func searchFoods(fName:String) {
        self.fname = fName
        self.isHidden = false
        self.sendFoodsListRequest()
    }
    func initSkeletonData() {
        foodsArray.removeAllObjects()
        foodsArray.add(["foodsArray":[[:],[:],[:],[:],[:],[:],[:],[:]]])
//        foodsArray.addObjects(from: ["foodsArray":[[:],[:],[:],[:],[:],[:],[:],[:]]])
        self.tableView.reloadData()
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.03, execute: {
//            self.tableView.showAnimatedGradientSkeleton()
//        })
    }
}

extension FoodsListAllListVM:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        noDataView.isHidden = foodsArray.count > 0 ? true : false
        if foodsArray.count == 0 && self.searchNoDataBlocK != nil{
            self.searchNoDataBlocK!()
        }
        return foodsArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dict = self.foodsArray[section]as? NSDictionary ?? [:]
        let array = dict["foodsArray"]as? NSArray ?? []
        return array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodsListAddTableViewCell") as? FoodsListAddTableViewCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodsListAddTableViewCell", for: indexPath) as! FoodsListAddTableViewCell
        let dict = self.foodsArray[indexPath.section]as? NSDictionary ?? [:]
        let array = dict["foodsArray"]as? NSArray ?? []
        
//            let array = self.foodsArray[indexPath.section]as? NSArray ?? []
        let foodsDict = array[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: foodsDict)
//        cell.updateUIForHistory(dict: dict,keywords: "\(fname)")
        
        return cell ?? FoodsListAddTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(72)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = self.foodsArray[indexPath.section]as? NSDictionary ?? [:]
        let array = dict["foodsArray"]as? NSArray ?? []
        
        let foodsDict = NSMutableDictionary(dictionary: array[indexPath.row]as? NSDictionary ?? [:])
        
        if foodsDict.stringValueForKey(key: "isAi") == "1"{
            let vc = PropotionResultVC()
            let specDefault = WHUtils.getSpecDefaultFromFoods(foodsDict: foodsDict)
            foodsDict.setValue("kcal", forKey: "energyUnit")
            foodsDict.setValue("2", forKey: "contentType")
            foodsDict.setValue("\(specDefault.stringValueForKey(key: "specNum"))", forKey: "measurementNum")
            foodsDict.setValue("\(specDefault.stringValueForKey(key: "specName"))", forKey: "measurementUnit")
            vc.msgDict = foodsDict
            vc.sourceType = self.sourceType
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = FoodsMsgDetailsVC()
            vc.foodsDetailDict = foodsDict
            vc.sourceType = self.sourceType
            self.controller.navigationController?.pushViewController(vc, animated:true)
            if self.sourceType == .main {
                vc.confirmButton.isHidden = true
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if foodsArray.count < 2{
            return nil
        }
        let headView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(55)))
        headView.backgroundColor = .white
        
        let grayView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(55)))
        headView.addSubview(grayView)
        grayView.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        
        let label = UILabel.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: kFitWidth(200), height: kFitWidth(55)))
        label.textColor = .COLOR_GRAY_BLACK_85
        label.font = .systemFont(ofSize: 16, weight: .medium)
        
        let dict = self.foodsArray[section]as? NSDictionary ?? [:]
        label.text = dict["title"]as? String ?? ""
        
        headView.addSubview(label)
        return headView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if foodsArray.count < 2{
            return kFitWidth(0)
        }
        return kFitWidth(55)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.scrollBlock != nil{
            self.scrollBlock!()
        }
    }
}

extension FoodsListAllListVM{
    func sendFoodsListRequest() {
        if fNameChanged == true{
//            foodsArray.removeAllObjects()
//            self.tableView.reloadData()
            initSkeletonData()
        }
//        if fname.count > 0 {
//            foodsArray.removeAllObjects()
//            self.tableView.reloadData()
//            initSkeletonData()
//        }
        self.fNameChanged = false
//        noDataView.noDataLabel.text = "食物库搜索中..."
        let param = ["fname":"\(fname)",
                     "uid":"\(UserInfoModel.shared.uId)"]
        UserInfoModel.shared.postNum = 3
        UserInfoModel.shared.failToastNum = 0
        DLLog(message: "sendFoodsListRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_list, parameters: param as [String:AnyObject],isNeedToast: true,vc: self.controller) { responseObject in
//            self.noDataView.noDataLabel.text = "- 暂无数据 -"
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
//            let dataArr = responseObject["data"]as? NSDictionary ?? [:]
            DLLog(message: "sendFoodsListRequest:\(dataArr)")
            
            let bestArray = dataArr["best"]as? NSArray ?? []
            let moreArray = dataArr["more"]as? NSArray ?? []
            let aiArray = dataArr["ai"]as? NSArray ?? []
            
            self.foodsArray.removeAllObjects()
            if bestArray.count > 0 {
                self.foodsArray.add(["title":"精准搜索",
                                     "foodsArray":bestArray])
            }
            if moreArray.count > 0 {
                self.foodsArray.add(["title":"更多食物",
                                     "foodsArray":moreArray])
            }
            if aiArray.count > 0 {
                let aiFoodsArr = NSMutableArray()
                for i in 0..<aiArray.count{
                    let aiFoods = NSMutableDictionary(dictionary: aiArray[i]as? NSDictionary ?? [:])
                    aiFoods.setValue("1", forKey: "isAi")
                    if aiFoods.stringValueForKey(key: "fname").count > 0 {
                        aiFoodsArr.add(aiFoods)
                    }
                }
                if aiFoodsArr.count > 0 {
                    self.foodsArray.add(["title":"AI搜索",
                                         "foodsArray":aiFoodsArr])
                }
            }
            self.tableView.reloadData()
            if self.foodsArray.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
            }
            
            if self.foodsArray.count > 0{
                self.tableView.tableFooterView = self.footerVm
            }else{
                self.tableView.tableFooterView = nil
            }
        }
    }
}
