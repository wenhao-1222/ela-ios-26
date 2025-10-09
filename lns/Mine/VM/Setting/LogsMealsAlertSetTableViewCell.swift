//
//  LogsMealsAlertSetTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2024/10/15.
//


class LogsMealsAlertSetTableViewCell: FeedBackTableViewCell {
    
    let selfHeight = kFitWidth(56)
    
    var switchBlock:((Bool)->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        initUI()
    }
    
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var mealIndexLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var mealTimeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        
        return lab
    }()
    lazy var weekDaysLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var switchButton: SwitchButton = {
        let btn = SwitchButton.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(16)-SwitchButton().selfWidth, y: (selfHeight-SwitchButton().selfHeight)*0.5, width: 0, height: 0))
        btn.tapBlock = {(isSelect)in
            self.switchBtnAction()
        }
        return btn
    }()
    lazy var remarkLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
}

extension LogsMealsAlertSetTableViewCell{
    @objc func switchBtnAction() {
        if self.switchBlock != nil{
            self.switchBlock!(!self.switchButton.isSelect)
        }
//        self.switchButton.setSelectStatus(status: !self.switchButton.isSelect)
    }
}

extension LogsMealsAlertSetTableViewCell{
    func updateUI(dict:NSDictionary) {
        DLLog(message: "LogsMealsAlertSetTableViewCell:\(dict)")
        mealIndexLabel.text = "第\(dict.stringValueForKey(key: "sn"))餐"
        let timeString = dict.stringValueForKey(key: "clock")
        
        mealTimeLabel.text = "\(timeString.mc_clipFromPrefix(to: 5))"
//        remarkLabel.text = dict.stringValueForKey(key: "remark")
        
        if dict.stringValueForKey(key: "status") == "0"{
            switchButton.setSelectStatus(status: false)
        }else{
            switchButton.setSelectStatus(status: true)
        }
        
//        let rotationString = dict.stringValueForKey(key: "rotation")
//        let rotationArray = WHUtils.getArrayFromJSONString(jsonString: rotationString)
        let rotationArray = dict["rotation"]as? NSArray ?? []
        DLLog(message: "rotationArray:\(rotationArray)")
        
        if rotationArray.count == 7 {
            weekDaysLabel.text = "每天"
        }else {
            var weekDaysStr = ""
            if rotationArray.contains(1){
                weekDaysStr = "周一"
            }
            if rotationArray.contains(2){
                if weekDaysStr.count > 0 {
                    weekDaysStr = weekDaysStr + " "
                }
                weekDaysStr = weekDaysStr + "周二"
            }
            if rotationArray.contains(3){
                if weekDaysStr.count > 0 {
                    weekDaysStr = weekDaysStr + " "
                }
                weekDaysStr = weekDaysStr +  "周三"
            }
            if rotationArray.contains(4){
                if weekDaysStr.count > 0 {
                    weekDaysStr = weekDaysStr + " "
                }
                weekDaysStr = weekDaysStr + "周四"
            }
            if rotationArray.contains(5){
                if weekDaysStr.count > 0 {
                    weekDaysStr = weekDaysStr + " "
                }
                weekDaysStr = weekDaysStr + "周五"
            }
            if rotationArray.contains(6){
                if weekDaysStr.count > 0 {
                    weekDaysStr = weekDaysStr + " "
                }
                weekDaysStr = weekDaysStr + "周六"
            }
            if rotationArray.contains(7){
                if weekDaysStr.count > 0 {
                    weekDaysStr = weekDaysStr + " "
                }
                weekDaysStr = weekDaysStr + "周日"
            }
            weekDaysLabel.text = "\(weekDaysStr)"
        }
    }
}
extension LogsMealsAlertSetTableViewCell{
    func initUI() {
        contentView.addSubview(whiteView)
        whiteView.addSubview(mealIndexLabel)
        whiteView.addSubview(mealTimeLabel)
        whiteView.addSubview(weekDaysLabel)
        whiteView.addSubview(switchButton)
        whiteView.addSubview(remarkLabel)
        
        setConstrait()
    }
    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.top.equalTo(kFitWidth(6))
            make.bottom.equalTo(kFitWidth(-6))
        }
        mealIndexLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(12))
        }
        mealTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(mealIndexLabel.snp.right).offset(kFitWidth(10))
            make.centerY.lessThanOrEqualTo(mealIndexLabel)
        }
        weekDaysLabel.snp.makeConstraints { make in
            make.left.equalTo(mealIndexLabel)
            make.top.equalTo(mealIndexLabel.snp.bottom).offset(kFitWidth(10))
        }
        remarkLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(weekDaysLabel.snp.bottom).offset(kFitWidth(10))
            make.bottom.equalTo(kFitWidth(-8))
        }
        switchButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(switchButton.selfWidth)
            make.height.equalTo(switchButton.selfHeight)
        }
    }
}
