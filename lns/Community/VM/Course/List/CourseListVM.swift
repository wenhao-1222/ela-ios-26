//
//  CourseListVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/14.
//

import MJRefresh


class CourseListVM : UIView{
    
    private let skeletonRowCount = 3
    var selfHeight = SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()//-WHUtils().getTabbarHeight()
    var controller = WHBaseViewVC()
    
    var dataSourceArray = NSMutableArray()
    var courseDictArray = NSMutableArray()
    private var isLoading = true
    
    var tutorialVcs:[ForumTutorialVC] = [ForumTutorialVC]()
    
    var scrollOffBlock:((CGFloat)->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        selfHeight = SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        initUI()
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
        vi.contentInsetAdjustmentBehavior = .never
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
}

extension CourseListVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? skeletonRowCount : dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CourseListVMTableViewCell")as? CourseListVMTableViewCell
        
        if cell == nil{
            cell = CourseListVMTableViewCell.init(style: .default, reuseIdentifier: "CourseListVMTableViewCell")
        }
        
        cell?.isUserInteractionEnabled = !isLoading
        if isLoading {
            cell?.updateUI(dict: NSDictionary(), isLoading: true)
            return cell ?? CourseListVMTableViewCell()
        }
        
        let dict = self.dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict, isLoading: false)
        
        
        return cell ?? CourseListVMTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isLoading else { return }
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
//        if section == 0{
//            if #available(iOS 26.0, *) {
//                return kFitWidth(20) + WHUtils().getNavigationBarHeight()
//            }
//        }
        return kFitWidth(20)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var h = kFitWidth(20)
//        if section == 0{
//            if #available(iOS 26.0, *) {
//                h = kFitWidth(20) + WHUtils().getNavigationBarHeight()
//            }
//        }
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: h))
        vi.backgroundColor = .clear
        
        return vi
    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if #available(iOS 26.0, *) {
//            return WHUtils().getTabbarHeight() + kFitWidth(20)
//        }
//        return 0
//    }
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if #available(iOS 26.0, *) {
//            let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(20)+WHUtils().getTabbarHeight()))
//            return vi
//        }
//        return nil
//    }
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        self.scrollOffBlock?(offsetY)
//    }
}

extension CourseListVM{
    func sendMenuListRequest() {
        beginLoading()
        WHNetworkUtil.shareManager().POST(urlString: URL_tutorial_menu_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendMenuListRequest:\(dataArr)")
            
            let filteredArray = NSMutableArray()
//            for i in 0..<dataArr.count{
//                let dict = dataArr[i]as? NSDictionary ?? [:]
//                if dict.stringValueForKey(key: "status") == "2"{
//                    filteredArray.add(dict)
//                }
//            }
            for i in 0..<dataArr.count{
                let dict = dataArr[i]as? NSDictionary ?? [:]
                if dict.stringValueForKey(key: "status") == "2"{
                    if dict.doubleValueForKey(key: "price") > 0{
                        if dict.stringValueForKey(key: "isPurchased") == "1" && !UserInfoModel.shared.phone.contains("111111111"){
                            filteredArray.add(dict)
                        }
                    }else{
                        filteredArray.add(dict)
                    }
                }
            }
            
            self.finishLoading(with: filteredArray)
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
    
    func beginLoading() {
        isLoading = true
        tableView.allowsSelection = false
        tableView.reloadForSkeleton()
    }
    
    func finishLoading(with list: NSArray) {
        dataSourceArray = NSMutableArray(array: list)
        courseDictArray.removeAllObjects()
        
        let visibleCells = tableView.visibleCells.compactMap { $0 as? CourseListVMTableViewCell }
        guard visibleCells.count > 0 else {
            isLoading = false
            tableView.allowsSelection = true
            tableView.reloadData()
            return
        }
        
        for cell in visibleCells {
            cell.isUserInteractionEnabled = true
            guard let indexPath = tableView.indexPath(for: cell) else { continue }
            if indexPath.row < dataSourceArray.count {
                let dict = dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
                cell.updateUI(dict: dict, isLoading: false)
            } else {
                cell.hideLoadingSkeleton()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            self.finishSkeletonTransition()
        }
    }
    
    func finishSkeletonTransition() {
        let oldRowCount = skeletonRowCount
        let newRowCount = dataSourceArray.count
        isLoading = false
        tableView.allowsSelection = true
        tableView.visibleCells.forEach { $0.isUserInteractionEnabled = true }
        
        guard oldRowCount != newRowCount else { return }
        
        let indexPaths: [IndexPath]
        if newRowCount > oldRowCount {
            indexPaths = (oldRowCount..<newRowCount).map { IndexPath(row: $0, section: 0) }
            tableView.performBatchUpdates({
                tableView.insertRows(at: indexPaths, with: .none)
            }, completion: nil)
        } else {
            indexPaths = (newRowCount..<oldRowCount).map { IndexPath(row: $0, section: 0) }
            tableView.performBatchUpdates({
                tableView.deleteRows(at: indexPaths, with: .none)
            }, completion: nil)
        }
    }
}
