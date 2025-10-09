//
//  TutorialDataListVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/24.
//


class TutorialDataListVM: UIView {
    
    var selfHeight = kFitWidth(200)
    var dataSourceArray:[ForumTutorialModel] = [ForumTutorialModel]()
    var selectIndex = -1
    var tapBlock:((Int)->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white//WHColor_16(colorStr: "1C1C1C")
        initUI()
    }
    
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight), style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.backgroundColor = .white//WHColor_16(colorStr: "1C1C1C")
        vi.separatorStyle = .none
        vi.register(TutorialDataListCell.classForCoder(), forCellReuseIdentifier: "TutorialDataListCell")
        
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        return vi
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.isHidden = true
        vi.noDataLabel.text = "- 暂无教程 -"
        vi.noDataLabel.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.65)
        return vi
    }()
}

extension TutorialDataListVM{
    func setDataArray(array:[ForumTutorialModel]) {
        self.dataSourceArray = array
        self.tableView.reloadData()
//        tableView.backgroundColor = WHColor_16(colorStr: "1C1C1C")
        
    }
}
extension TutorialDataListVM{
    func initUI() {
        addSubview(tableView)
        tableView.addSubview(noDataView)
        noDataView.center = CGPoint.init(x: self.tableView.frame.width * 0.5, y: kFitWidth(100))
    }
}

extension TutorialDataListVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noDataView.isHidden = dataSourceArray.count > 0 ? true : false
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TutorialDataListCell", for: indexPath) as? TutorialDataListCell
//        cell?.backgroundColor = WHColor_16(colorStr: "C1C1C1")
        let model = self.dataSourceArray[indexPath.row]
        
        cell?.updateUI(model: model)
        cell?.setPlayState(isPlaying: indexPath.row == self.selectIndex)
        
        cell?.tapBlock = {()in
            if self.selectIndex != indexPath.row && self.tapBlock != nil{
                self.tapBlock!(indexPath.row)
                self.selectIndex = indexPath.row
                self.tableView.reloadData()
            }
        }
        
        return cell ?? TutorialDataListCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectIndex != indexPath.row && self.tapBlock != nil{
            self.tapBlock!(indexPath.row)
            self.selectIndex = indexPath.row
            self.tableView.reloadData()
        }
    }
}
