//
//  QuestionnaireSurveyFoodsListVC.swift
//  lns
//
//  Created by LNS2 on 2024/3/27.
//

import Foundation
import MJRefresh

class QuestionnaireSurveyFoodsListVC : WHBaseViewVC {
    
    var keywords = ""
    public var fType = 0//食物类型：1-蛋白质；2-碳水化物；3-脂肪；4-蔬菜；5-水果
    
    var dataSourceArray = NSArray()
    var selectArray = NSMutableArray()
    
    var submitBlock:((NSArray)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendFoodsListRequest()
    }
    lazy var submitBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("提交", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var searchVm : SearchVM = {
        let vm = SearchVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(10), width: 0, height: 0))
        vm.searchBlock = {()in
            self.keywords = self.searchVm.textField.text ?? ""
            self.sendFoodsListRequest()
        }
        return vm
    }()
    
    lazy var tableView : UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: self.searchVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT - self.searchVm.frame.maxY), style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        vi.register(FoodsTableViewCell.classForCoder(), forCellReuseIdentifier: "FoodsTableViewCell")
        
        return vi
    }()
    
}

extension QuestionnaireSurveyFoodsListVC{
    @objc func submitAction(){
        let resultArray = NSMutableArray()
        for i in 0..<selectArray.count{
            let status = selectArray[i]as? Int ?? 0
            if status == 1{
                resultArray.add(self.dataSourceArray[i]as? NSDictionary ?? [:])
            }
        }
        if self.submitBlock != nil{
            self.submitBlock!(resultArray)
        }
        self.backTapAction()
    }
}
extension QuestionnaireSurveyFoodsListVC{
    func initUI(){
        initNavi(titleStr: "食物库")
        
        self.navigationView.addSubview(submitBtn)
        
        view.backgroundColor = WHColor_RGB(r: 38.0, g: 40.0, b: 49.0)
        view.addSubview(searchVm)
        view.addSubview(tableView)
        
        setConstrait()
    }
    func setConstrait(){
        submitBtn.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-10))
            make.centerY.lessThanOrEqualTo(naviTitleLabel)
            make.height.equalTo(naviTitleLabel)
            make.width.equalTo(kFitWidth(50))
        }
    }
}

extension QuestionnaireSurveyFoodsListVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodsTableViewCell", for: indexPath) as! FoodsTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodsTableViewCell", for: indexPath) as? FoodsTableViewCell
        
        let dict = dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict)
        cell?.choiceBlock = {(isSelec)in
            let status = isSelec ? 1 : 0
            self.selectArray.replaceObject(at: indexPath.row, with: status)
        }
        return cell ?? FoodsTableViewCell()
    }
}

extension QuestionnaireSurveyFoodsListVC {
    func sendFoodsListRequest(){
        
        let param = ["fname":keywords,
                     "ftype":"\(fType)"]
        UserInfoModel.shared.postNum = 3
        UserInfoModel.shared.failToastNum = 0
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_list, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
//            let data = responseObject["data"]as? NSArray ?? []
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let foodsArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
//
            self.dataSourceArray = foodsArray
            self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            self.tableView.reloadData()
            self.selectArray.removeAllObjects()
            for i in 0..<self.dataSourceArray.count{
                self.selectArray.add(0)
            }
        }
    }
}
