//
//  DietPlanCreateYearVM.swift
//  lns
//
//  Created by LNS2 on 2026/2/25.
//


class DietPlanCreateYearVM: UIView {
    
    var defaultIndex = 0
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.text = "出生年份"
        
        return lab
    }()
    lazy var pickerView : UIPickerView = {
        let vi = UIPickerView()
        vi.backgroundColor = . clear
        vi.dataSource = self
        vi.delegate = self
        
        return vi
    }()
    lazy var yearUnitLabel : UILabel = {
        let lab = UILabel()
        lab.text = "年"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var yearDataArray : NSArray = {
        let currentYear = Date().currentYear
        
        let yearArr = NSMutableArray()
        for i in (currentYear-80)...(currentYear-12){
            yearArr.add(i)
            
            if i == 2000 {
                defaultIndex = yearArr.count - 1
            }
        }
        
        return yearArr
    }()
}

extension DietPlanCreateYearVM{
    func applyDefaultAge(_ age: Int) {
        let targetYear = Date().currentYear - age
        guard let yearArray = yearDataArray as? [Int],
              let index = yearArray.firstIndex(of: targetYear) else { return }
        defaultIndex = index
        pickerView.selectRow(index, inComponent: 0, animated: false)
        QuestinonaireMsgModel.shared.birthDay = "\(targetYear)"
    }
    
    func getBirthDayData() {
        let index = pickerView.selectedRow(inComponent: 0)
        QuestinonaireMsgModel.shared.birthDay = "\(yearDataArray[index]as? Int ?? 0)"
        
        DLLog(message: "出生年份：\(QuestinonaireMsgModel.shared.birthDay)")
    }
}

extension DietPlanCreateYearVM{
    func initUI(){
        addSubview(titleLabel)
        addSubview(pickerView)
        pickerView.addSubview(yearUnitLabel)
        
        setConstrait()
        _ = yearDataArray
        pickerView.reloadAllComponents()
        pickerView.selectRow(defaultIndex, inComponent: 0, animated: true)
        QuestinonaireMsgModel.shared.birthDay = "\(yearDataArray[defaultIndex]as? Int ?? 0)"
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight()+kFitWidth(55))
        }
        pickerView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(231))
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(252))
        }
        yearUnitLabel.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(223))
        }
    }
}

extension DietPlanCreateYearVM:UIPickerViewDataSource,UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearDataArray.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kFitWidth(40)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var titleLabel = view as? UILabel
        
        if ((titleLabel == nil)){
            titleLabel = UILabel.init()
            titleLabel?.backgroundColor = .clear
        }
        
        titleLabel?.font = .systemFont(ofSize: 28, weight: .medium)
        titleLabel?.textAlignment = .center
        titleLabel?.text = "\(yearDataArray[row]as? Int ?? 0)"
        
        setUpPickerStyleRowStyle(row: row, component: component)
        
        return titleLabel!
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        QuestinonaireMsgModel.shared.birthDay = "\(yearDataArray[row]as? Int ?? 0)"
        DLLog(message: "生日：\(QuestinonaireMsgModel.shared.birthDay)")
   }
    func setUpPickerStyleRowStyle(row:Int,component:Int) {
//        var contentView = UIView()
//        let subviews = pickerView.subviews
//        if subviews.count > 0{
//            let firstView = subviews.first
//            if firstView != nil{
//                contentView = firstView!
//            }
//        }
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let label = self.pickerView.view(forRow: row, forComponent: component) as? UILabel
            if label != nil{
                label?.textColor = .THEME
            }
        })
    }
}
