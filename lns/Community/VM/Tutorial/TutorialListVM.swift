//
//  TutorialListVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/8.
//


class TutorialListVM : UIView{
    
    let selfHeight = SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()-WHUtils().getTabbarHeight()
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
        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        vi.register(TutorialForumTableViewCell.classForCoder(), forCellReuseIdentifier: "TutorialForumTableViewCell")
        
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        
        return vi
    }()
}

extension TutorialListVM{
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

extension TutorialListVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TutorialForumTableViewCell")as? TutorialForumTableViewCell
        
        if cell == nil{
            cell = TutorialForumTableViewCell.init(style: .default, reuseIdentifier: "TutorialForumTableViewCell")
        }
        
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict:dict)
        
        return cell ?? TutorialForumTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        if dict.stringValueForKey(key: "status") != "1"{
//            let vc = ForumTutorialVC().initWidtDict(dict: dict)
//            vc.parentDict = dict
            
            let vc = CourseListVC()
            vc.parentDict = dict
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
        }
    }
}

extension TutorialListVM{
    func sendMenuListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_tutorial_menu_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendMenuListRequest:\(dataArr)")
            
            self.dataSourceArray = NSMutableArray.init(array: dataArr)
            self.tableView.reloadData()
            
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
