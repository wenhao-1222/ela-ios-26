//
//  JournalWaterViewCell.swift
//  lns
//
//  Created by Elavatine on 2025/5/20.
//

class JournalWaterViewCell: UITableViewCell {
    
    var addBlock:(()->())?
    var totalBlock:(()->())?
    var deleteBlock:(()->())?
    
    var waterNum = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(closeEditStatus), name: NSNotification.Name(rawValue: "closeEditStatus"), object: nil)
        initUI()
    }
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var leftTitleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.text = "饮水量"
        
        return lab
    }()
    
    lazy var tableView: JournalFoodsTableView = {
        let table = JournalFoodsTableView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.register(WaterTableViewCell.classForCoder(), forCellReuseIdentifier: "WaterTableViewCell")
        table.delegate = self
        table.dataSource = self
//        table.backgroundColor = .COLOR_BG_WHITE
        
        return table
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = UIFont().DDInFontSemiBold(fontSize: 16)//.systemFont(ofSize: 11, weight: .regular)
        
        return lab
    }()
    lazy var totalTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(totalTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var addButton: FeedBackTapButton = {
        let btn = FeedBackTapButton()
        btn.addPressEffect()
        btn.setImage(UIImage(named: "logs_add_icon_theme"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        
        return btn
    }()
}

extension JournalWaterViewCell:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WaterTableViewCell")as? WaterTableViewCell ?? WaterTableViewCell()
        cell.updateUI(num: "\(self.waterNum)")
        cell.totalBlock = {()in
            self.totalBlock?()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            self.deleteBlock?()
            self.updateUI(num: "0")
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
        
        return waterNum > 0
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
        return waterNum > 0 ? .delete : .none
    }
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
//        addButton.isHidden = true
        addButton.isUserInteractionEnabled = false
    }
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
//        addButton.isHidden = false
        addButton.isUserInteractionEnabled = true
    }
}

extension JournalWaterViewCell{
    func updateUI(num:String) {
        self.waterNum = num.intValue
        self.tableView.reloadData()
        
//        var numAttr = NSMutableAttributedString(string: "\(num)")
//        let unitAttr = NSMutableAttributedString(string: " ml")
//        unitAttr.yy_font = .systemFont(ofSize: 11, weight: .regular)
//        unitAttr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
////        numAttr.yy_font = UIFont().DDInFontSemiBold(fontSize: 16)//UIFont().DDInFontBold(fontSize: 16)
////        numAttr.yy_color = .COLOR_TEXT_TITLE_0f1214
//        if num.intValue <= 0 {
//            numAttr = NSMutableAttributedString(string: "0")
//        }
//        numAttr.append(unitAttr)
//        numberLabel.attributedText = numAttr
    }
    @objc func closeEditStatus(){
        self.tableView.setEditing(false, animated: true)
    }
    @objc func addAction(){
        if self.addBlock != nil{
            self.addBlock!()
        }
    }
    @objc func totalTapAction(){
        if self.totalBlock != nil{
            self.totalBlock!()
        }
    }
}

extension JournalWaterViewCell{
    func initUI() {
        contentView.addSubview(whiteView)
        contentView.addSubview(leftTitleLabel)
//        contentView.addSubview(numberLabel)
//        contentView.addSubview(totalTapView)
        whiteView.addSubview(tableView)
        whiteView.addSubview(addButton)
        whiteView.addSubview(totalTapView)
        
        setConstrait()
    }
    func setConstrait()  {
        whiteView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(10))
            make.right.equalTo(kFitWidth(-10))
            make.top.equalTo(kFitWidth(12))
            make.bottom.equalToSuperview()
        }
//        totalTapView.snp.makeConstraints { make in
//            make.left.top.bottom.equalTo(whiteView)
////            make.right.equalTo(leftTitleLabel)
//            make.right.equalTo(kFitWidth(-150))
//        }
        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(25))
            make.top.equalTo(kFitWidth(25))
//            make.right.equalTo(kFitWidth(-25))
            make.bottom.equalTo(kFitWidth(-45))
        }
        tableView.snp.makeConstraints { make in
            make.left.right.equalTo(whiteView)
            make.top.equalTo(leftTitleLabel.snp.bottom)
            make.height.equalTo(kFitWidth(40))
            make.bottom.equalToSuperview()
        }
        totalTapView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(120))
        }
//        numberLabel.snp.makeConstraints { make in
//            make.top.equalTo(kFitWidth(59))
//            make.left.equalTo(leftTitleLabel)
//        }
        addButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalTo(kFitWidth(48))
            make.height.equalTo(kFitWidth(48))
        }
    }
}
