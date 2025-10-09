//
//  JournalReportDailyCaloriesMealsVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/12.
//

class JournalReportDailyCaloriesMealsVM: UIView {
    
    let selfWidth = SCREEN_WIDHT-kFitWidth(32)
    var selfHeight = kFitWidth(235)
    
    var heightChangeBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "foods_merge_calories_icon")
        
        return img
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "今日热量分布"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var caloriesPieVm: JournalReportPieVM = {
        let vm = JournalReportPieVM.init(frame: CGRect.init(x: kFitWidth(-16), y: kFitWidth(65), width: 0, height: 0))
        return vm
    }()
}

extension JournalReportDailyCaloriesMealsVM{
    func setDataSource(dataDict:NSDictionary)  {
        DispatchQueue.global(qos: .userInitiated).async {
            let mealsArray = dataDict["foods"]as? NSArray ?? []
            var numArray = [ReportCaloriesModel]()//NSMutableArray()
            
            for k in 0..<mealsArray.count{
                let foodsArray = mealsArray[k]as? NSArray ?? []
                
                var caloriTotal = Double(0)
                var hasData = false
                let model = ReportCaloriesModel()
                for i in 0..<foodsArray.count{
                    let dict = foodsArray[i]as? NSDictionary ?? [:]
                    if dict.stringValueForKey(key: "state") == "1"{
                        var calori = dict.doubleValueForKey(key: "calories")
                        if calori == 0 {
                            calori = Double(dict.stringValueForKey(key: "calories")) ?? 0
                        }
                        caloriTotal = caloriTotal + calori
                        hasData = true
                    }
                }
                if hasData == true{
                    model.setSn(index: k+1)
                    model.calories = caloriTotal
                    numArray.append(model)
                }
            }
            
            DispatchQueue.main.async {
                DLLog(message: "numArray:\(numArray)")
//                self.setChart(dataPoints: self.nameArray, values: numArray as! [Double])
            }
            
            var totalNum = Double(0)
            
            for i in 0..<numArray.count{
                let model = numArray[i]
                totalNum = totalNum + model.calories
            }
            
            for i in 0..<numArray.count{
                let model = numArray[i]
                let percent = Float(model.calories/totalNum)*Float(100)
                model.percent = percent//Float(percent.rounded())
                numArray[i] = model
            }
            
            DispatchQueue.main.async {
                DLLog(message: "numArray:\(numArray)")
                self.caloriesPieVm.updateDataSource(array: numArray as NSArray, type: .MEALS)
                self.updateMealsMsg(dataArray: numArray)
                let lines = (numArray.count+1)/2
                self.selfHeight = CGFloat(lines) * kFitWidth(48) + kFitWidth(5) + kFitWidth(235)
                self.heightChangeBlock?()
            }
        }
    }
    func updateMealsMsg(dataArray:[ReportCaloriesModel]) {
        for i in 0..<dataArray.count{
            let model = dataArray[i]
            let originX = i%2 == 0 ? kFitWidth(47) : selfWidth*0.5+kFitWidth(23)
            let originY = kFitWidth(235)+kFitWidth(48)*CGFloat((i/2))
            let vm = JournalReportDailyCaloriesMealsItemVm.init(frame: CGRect.init(x: originX, y: originY, width: 0, height: 0))
            whiteView.addSubview(vm)
            vm.updateUI(model: model)
        }
    }
}

extension JournalReportDailyCaloriesMealsVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(iconImgView)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(caloriesPieVm)
        
        setConstrait()
    }
    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.bottom.equalToSuperview()
        }
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(15))
            make.top.equalTo(kFitWidth(22))
            make.width.height.equalTo(kFitWidth(20))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(kFitWidth(6))
            make.centerY.lessThanOrEqualTo(iconImgView)
        }
    }
}
