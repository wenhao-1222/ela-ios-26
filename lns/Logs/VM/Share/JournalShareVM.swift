//
//  JournalShareVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/6.
//


class JournalShareVM: UIView {
    
    let selfHeight = SCREEN_HEIGHT
    var detailsDict = NSDictionary()
    var mealsArray = NSArray()
    var commenListHeight = kFitWidth(0)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .THEME
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "log_share_bg_img")
        
        return img
    }()
    lazy var dateLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_icon_img")
        return img
    }()
    lazy var receiptVm: JournalShareReceiptVM = {
        let vm = JournalShareReceiptVM.init(frame: CGRect.init(x: 0, y: kFitWidth(165), width: 0, height: 0))
        return vm
    }()
    lazy var topShadowView: UIImageView = {
        let vi = UIImageView()
        vi.setImgLocal(imgName: "journal_share_shadow_view")
        return vi
    }()
    lazy var msgVm: JournalShareMsgVM = {
        let vm = JournalShareMsgVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
//        let vm = JournalShareMsgVM.init(frame: CGRect.init(x: 0, y: self.receiptVm.frame.minY+kFitWidth(13), width: 0, height: 0))
//        vm.caloriesVm.updateUI(dict: self.detailsDict)
//        vm.naturalVm.updateUI(dict: self.detailsDict)
        return vm
    }()
    lazy var dashVm: JournalShareMsgDashVM = {
//        let vm = JournalShareMsgDashVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        let vm = JournalShareMsgDashVM.init(frame: CGRect.init(x: 0, y: self.msgVm.frame.maxY, width: 0, height: 0))
        return vm
    }()
    lazy var headView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: dashVm.frame.maxY))
        vi.backgroundColor = .clear
        vi.addSubview(msgVm)
        vi.addSubview(dashVm)
        return vi
    }()
//    lazy var footView: JournalShareFooterVM = {
//        let emptyFootHeight = self.mealsArray.count > 0 ? kFitWidth(42) : (self.tableView.frame.height - dashVm.frame.maxY)
//        let vm = JournalShareFooterVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: emptyFootHeight))
//        return vm
//    }()
    lazy var tableView: ForumCommentListTableView = {
        let originY = self.receiptVm.frame.minY+kFitWidth(13)
        let vi = ForumCommentListTableView.init(frame: CGRect.init(x: 0, y: originY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-originY-kFitWidth(30)), style: .grouped)
//        vi.tableHeaderView = headView
        vi.backgroundColor = .clear
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.bounces = false
        vi.sectionFooterHeight = 0
        vi.showsVerticalScrollIndicator = false
        
        vi.register(JournalShareTableViewCell.classForCoder(), forCellReuseIdentifier: "JournalShareTableViewCell")
        
        vi.reloadCompletion = {()in
            let size = self.tableView.contentSize
            if abs(self.commenListHeight - size.height) > 1 && self.mealsArray.count > 0{
                self.commenListHeight = size.height
                self.tableView.frame = CGRect.init(x: 0, y: originY, width: SCREEN_WIDHT, height: size.height)
                self.frame = CGRect.init(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: self.tableView.frame.maxY + kFitWidth(30))
            }
        }
        
        return vi
    }()
}

extension JournalShareVM:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return mealsArray.count+1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }else{
            let dict = mealsArray[section-1] as? NSDictionary ?? [:]
            return (dict["mealFoods"]as? NSArray ?? []).count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalShareTableViewCell") as? JournalShareTableViewCell
        
        let dict = mealsArray[indexPath.section-1] as? NSDictionary ?? [:]
        let foodsArray = dict["mealFoods"]as? NSArray ?? []
        cell?.updateUI(dict: foodsArray[indexPath.row] as? NSDictionary ?? [:])
        
        return cell ?? JournalShareTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return headView
        }else{
            let vi = UIView.init(frame: CGRect.init(x: kFitWidth(0), y: 0, width: SCREEN_WIDHT, height: kFitWidth(34)))
            vi.backgroundColor = .clear
            
            let whiteView = UIView.init(frame: CGRect.init(x: kFitWidth(42), y: 0, width: SCREEN_WIDHT-kFitWidth(84), height: kFitWidth(34)))
            whiteView.backgroundColor = .white
            vi.addSubview(whiteView)
            
            let dict = mealsArray[section-1] as? NSDictionary ?? [:]
            let label = UILabel.init(frame: CGRect.init(x: kFitWidth(20), y: 0, width: kFitWidth(200), height: kFitHeight(34)))
            label.text = dict.stringValueForKey(key: "mealName")
            label.textColor = .COLOR_TEXT_TITLE_0f1214
            label.font = .systemFont(ofSize: 14, weight: .semibold)
            whiteView.addSubview(label)
            
            return vi
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return dashVm.frame.maxY
        }else{
            return kFitWidth(34)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == mealsArray.count{
            let emptyFootHeight = kFitWidth(42)//self.mealsArray.count > 0 ? kFitWidth(42) : (self.tableView.frame.height - dashVm.frame.maxY)
            return emptyFootHeight//footView.selfHeight
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == mealsArray.count{
            let emptyFootHeight = kFitWidth(42)//self.mealsArray.count > 0 ? kFitWidth(42) : (self.tableView.frame.height - dashVm.frame.maxY)
            let footView = JournalShareFooterVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: emptyFootHeight))
            return footView
        }
        return nil
    }
}

extension JournalShareVM{
    func initUI() {
        addSubview(bgImgView)
        addSubview(dateLabel)
        addSubview(iconImgView)
        addSubview(receiptVm)
        
        addSubview(tableView)
        addSubview(topShadowView)
        
        setConstrait()
    }
    
    func setConstrait(){
        bgImgView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalTo(SCREEN_WIDHT)
            make.height.equalTo(SCREEN_HEIGHT)
        }
        dateLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(59))
        }
        iconImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(92))
            make.width.equalTo(kFitWidth(182))
            make.height.equalTo(kFitWidth(33))
        }
        topShadowView.snp.makeConstraints { make in
//            make.left.top.width.equalToSuperview()
            make.top.equalTo(self.receiptVm.snp.top).offset(kFitWidth(13))
            make.left.equalTo(kFitWidth(42))
            make.right.equalTo(kFitWidth(-42))
            make.height.equalTo(kFitWidth(12))
        }
    }
    
    func updateMsg(dict:NSDictionary) {
        self.detailsDict = dict
        self.msgVm.caloriesVm.updateUI(dict: dict)
        self.msgVm.naturalVm.updateUI(dict: dict)
        self.msgVm.nameMsgVm.updateCircleTag(dict: dict)
    }
    
    func updateMealsArray(arr:NSArray) {
        self.mealsArray = arr
        self.tableView.reloadData()
    }
}
