//
//  SportCatogaryVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/22.
//


class SportCatogaryVM: UIView {
    
    let selfWidth = kFitWidth(100)
    let selfHeight = SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()
    
    var dataSourceArray:[SportCatogaryModel] = [SportCatogaryModel]()
    var selectIndex = 1
    var tapBlock:((SportCatogaryModel)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight(), width: selfWidth, height: selfHeight))
//        self.backgroundColor = .COLOR_BG_WHITE
        self.backgroundColor = UIColor(named: "color_card_bg_sport_category")//WHColor_16(colorStr: "F5F5F5")
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
        table.backgroundColor = .clear
        table.bounces = false
        table.register(SportCatogaryTableViewCell.classForCoder(), forCellReuseIdentifier: "SportCatogaryTableViewCell")
        table.separatorStyle = .none
        
        return table
    }()
}

extension SportCatogaryVM{
    func initUI() {
        addSubview(tableView)
    }
}

extension SportCatogaryVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SportCatogaryTableViewCell") as? SportCatogaryTableViewCell
        
        let model = self.dataSourceArray[indexPath.row]
        cell?.updateUI(model: model)
        
        if indexPath.row == selectIndex{
            cell?.setSelect(isSelect: true)
        }else{
            cell?.setSelect(isSelect: false)
        }
        
        return cell ?? SportCatogaryTableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectIndex = indexPath.row
        self.tableView.reloadData()
        
        if self.tapBlock != nil{
            let model = self.dataSourceArray[indexPath.row]
            self.tapBlock!(model)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(48)
    }
}
