//
//  CourseListVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/14.
//

import MJRefresh


class CourseListVM : UIView{
    
    let selfHeight = SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()//-WHUtils().getTabbarHeight()
    var centerY = kFitWidth(0)
    var controller = WHBaseViewVC()
    
    var dataSourceArray = NSMutableArray()
    var courseDictArray = NSMutableArray()
    
    var tutorialVcs:[ForumTutorialVC] = [ForumTutorialVC]()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
//        super.init(frame: CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        initUI()
        
        self.centerY = WHUtils().getNavigationBarHeight() + selfHeight*0.5
        self.sendMenuListRequest()
    }
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.showsVerticalScrollIndicator = false
        vi.backgroundColor = .COLOR_BG_F5
        vi.register(CourseListVMTableViewCell.classForCoder(), forCellReuseIdentifier: "CourseListVMTableViewCell")
        
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        
//        vi.mj_header = MJRefreshNormalHeader(refreshingBlock: {
//            self.sendMenuListRequest()
//        })
        
        return vi
    }()
}

extension CourseListVM{
    func initUI() {
        addSubview(tableView)
    }
    func showSelf() {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.centerY)
        }
    }
    func hiddenSelf() {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.center = CGPoint.init(x: -SCREEN_WIDHT*0.5, y: self.centerY)
        }
    }
}

extension CourseListVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CourseListVMTableViewCell")as? CourseListVMTableViewCell
        
        if cell == nil{
            cell = CourseListVMTableViewCell.init(style: .default, reuseIdentifier: "CourseListVMTableViewCell")
        }
        
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict:dict)
        
        
        return cell ?? CourseListVMTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
//        if dict.stringValueForKey(key: "status") == "2"{
            let vc = CourseListVC()
            vc.parentDict = dict
            vc.headMsgDict = dict
//            vc.isPaid = dict.stringValueForKey(key: "isPaid") == "1" ? true : false
            for i in 0..<self.courseDictArray.count{
                let courseDict = self.courseDictArray[i]as? NSDictionary ?? [:]
                if dict.stringValueForKey(key: "id") == courseDict.stringValueForKey(key: "id"){
                    let coverInfoDict = courseDict["coverInfo"]as? NSDictionary ??  [:]
                    if coverInfoDict.stringValueForKey(key: "width").count > 0 {
                        vc.headMsgDict = courseDict
                    }
                    break
                }
            }
            self.controller.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFitWidth(20)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(20)))
        vi.backgroundColor = .clear
        
        return vi
    }
}

extension CourseListVM{
    func sendMenuListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_tutorial_menu_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendMenuListRequest:\(dataArr)")
            
            self.dataSourceArray.removeAllObjects()
            for i in 0..<dataArr.count{
                let dict = dataArr[i]as? NSDictionary ?? [:]
                if dict.stringValueForKey(key: "status") == "2"{
                    self.dataSourceArray.add(dict)
                }
            }
            
            self.tableView.reloadData()
            self.tableView.mj_header?.endRefreshing()
            
            for i in  0..<self.dataSourceArray.count{
                let dict = self.dataSourceArray[i]as? NSDictionary ?? [:]
//                if dict.stringValueForKey(key: "status") != "1"{
                    self.courseDictArray.add(["id":dict.stringValueForKey(key: "id")])
                    self.sendCourseHeadMsgRequest(id: dict.stringValueForKey(key: "id"), index: i)
//                }
            }
        }
    }
    func sendCourseHeadMsgRequest(id:String,index:Int) {
        let param = ["id":id]
        WHNetworkUtil.shareManager().POST(urlString: URL_tutorial_menu_briefing, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = NSMutableDictionary(dictionary: WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? ""))
            DLLog(message: "sendCourseHeadMsgRequest:\(dataDict)")
            dataDict.setValue(id, forKey: "id")
            self.courseDictArray.replaceObject(at: index, with: dataDict)
        }
    }
}
