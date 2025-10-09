//
//  SportCatogaryItemVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/22.
//


class SportCatogaryItemVM: UIView {
    
    let selfWidth = kFitWidth(275)
    let selfHeight = SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()-kFitWidth(56)
    
    var dataSourceArray:[SportCatogaryItemModel] = [SportCatogaryItemModel]()
    var selectIndex = 1
    var canEdit = false
    var canDelete = false
    var isRecently = false //是否为最近添加列表
    var controller = WHBaseViewVC()
    
    var selectRect = CGRect()
    
    var tapBlock:((SportCatogaryItemModel)->())?
    var editBlock:((SportCatogaryItemModel)->())?
    var delBlock:((SportCatogaryItemModel)->())?
    
    var editModel = SportCatogaryItemModel()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: kFitWidth(100), y: WHUtils().getNavigationBarHeight()+kFitWidth(56), width: selfWidth, height: selfHeight))
        self.backgroundColor = WHColor_16(colorStr: "F5F5F5")
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: selfWidth, height: selfHeight), style: .plain)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .white
//        table.bounces = false
        table.register(SportCatogaryItemCell.classForCoder(), forCellReuseIdentifier: "SportCatogaryItemCell")
        table.separatorStyle = .none
        
        return table
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.noDataLabel.text = "- 暂无数据 -"
        vi.isHidden = true
        return vi
    }()
}

extension SportCatogaryItemVM{
    func initUI() {
        addSubview(tableView)
        
        tableView.addSubview(noDataView)
        noDataView.center = CGPoint.init(x: selfWidth * 0.5, y: kFitWidth(150))
    }
}

extension SportCatogaryItemVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noDataView.isHidden = dataSourceArray.count > 0 ? true : false
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SportCatogaryItemCell") as? SportCatogaryItemCell
        
        let model = self.dataSourceArray[indexPath.row]
        cell?.updateUI(model: model)
        
        cell?.tapBlock = {()in
            self.selectIndex = indexPath.row
            self.tableView.reloadData()
            
            self.selectRect = CGRect.init(x: 0, y: self.tableView.contentOffset.y + kFitWidth(56)*CGFloat(indexPath.row + 1), width: self.tableView.frame.width, height: kFitWidth(56))
            
            if self.tapBlock != nil{
                self.tapBlock!(model)
            }
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SportCatogaryItemCell") as? SportCatogaryItemCell
//            self.selectRect = cell?.convert(cell?.nameLabel.frame, to: self.tableView)
        }
        
        return cell ?? SportCatogaryTableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectIndex = indexPath.row
//        self.tableView.reloadData()
//        if self.tapBlock != nil{
//            let model = self.dataSourceArray[indexPath.row]
//            self.tapBlock!(model)
//        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(56)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return canEdit || canDelete
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        self.editModel = self.dataSourceArray[indexPath.row]
        let editAction  = UIContextualAction.init(style: .normal, title: "修改运动") { _,_,_ in
//            self.tableView.setEditing(false, animated: true)
            TouchGenerator.shared.touchGenerator()
            if self.editBlock != nil{
                self.editBlock!(self.editModel)
            }
        }
        let deleteAction  = UIContextualAction.init(style: .destructive, title: "删除") { _,_,_ in
//            self.tableView.setEditing(false, animated: true)
//            if self.delBlock != nil{
//                self.delBlock!(self.editModel)
//            }
            TouchGenerator.shared.touchGenerator()
            if self.isRecently {
                self.sendDelSportRecentlyRequest(model: self.editModel) {
                    self.dataSourceArray.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    if self.delBlock != nil{
                        self.delBlock!(self.editModel)
                    }
                }
            }else{
                self.sendDelSportRequest(model: self.editModel) {
                    self.dataSourceArray.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    if self.delBlock != nil{
                        self.delBlock!(self.editModel)
                    }
                }
            }
        }
        editAction.backgroundColor = .COLOR_BUTTON_HIGHLIGHT_BG_THEME
        var actions = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        if canEdit == false{
            actions = UISwipeActionsConfiguration(actions: [deleteAction])
        }
        actions.performsFirstActionWithFullSwipe = false
        return actions
    }
}


extension SportCatogaryItemVM{
    func sendDelSportRequest(model:SportCatogaryItemModel,success : @escaping () -> ()) {
        let param = ["id":"\(model.id)"]
        DLLog(message: "sendDelSportRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_sport_catogary_delete, parameters: param as [String : AnyObject],isNeedToast: true,vc: self.controller) { responseObject in
            success()
        }
    }
    func sendDelSportRecentlyRequest(model:SportCatogaryItemModel,success : @escaping () -> ()) {
        let param = ["id":"\(model.id)"]
        DLLog(message: "sendDelSportRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_sport_recently_delete, parameters: param as [String : AnyObject],isNeedToast: true,vc: self.controller) { responseObject in
            success()
        }
    }
}
