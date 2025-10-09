//
//  JournalReportDailyCaloriesMealsCell.swift
//  lns
//
//  Created by Elavatine on 2025/5/12.
//

class ReportCaloriesModel: NSObject {
    var sn = 0
    var calories = Double(0)
    var percent = Float(0)
    var color = UIColor.THEME
    
    func setSn(index:Int) {
        self.sn = index
        if index == 1{
            self.color = .THEME
        }else if index == 2{
            self.color = WHColor_16(colorStr: "FF8AA9")
        }else if index == 3{
            self.color = WHColor_16(colorStr: "FCDD69")
        }else if index == 4{
            self.color = WHColor_16(colorStr: "52DCC0")
        }else if index == 5{
            self.color = WHColor_16(colorStr: "C081FF")
        }else if index == 6{
            self.color = WHColor_16(colorStr: "84DAFD")
        }
    }
}

class JournalReportDailyCaloriesMealsCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.clipsToBounds = true
        
        initUI()
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
        let vm = JournalReportPieVM.init(frame: CGRect.init(x: 0, y: kFitWidth(65), width: 0, height: 0))
        return vm
    }()
    lazy var bottomWhiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        return vi
    }()
}

extension JournalReportDailyCaloriesMealsCell{
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
            
            var percentArray = NSMutableArray()
            
            for i in 0..<numArray.count{
                let model = numArray[i]
                let percent = model.calories/totalNum*100
                model.percent = Float(percent.rounded())
                numArray[i] = model
//                percentArray.add(WHUtils.convertStringToString(String(format: "%.2f", percent)) ?? "0")
            }
            
            DispatchQueue.main.async {
                DLLog(message: "numArray:\(numArray)")
                self.caloriesPieVm.updateDataSource(array: numArray as NSArray, type: .MEALS)
            }
        }
    }
}

extension JournalReportDailyCaloriesMealsCell{
    func initUI() {
        contentView.addSubview(whiteView)
        whiteView.addSubview(iconImgView)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(caloriesPieVm)
        
        whiteView.addSubview(bottomWhiteView)
        
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
        bottomWhiteView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(50))
            make.right.equalTo(kFitWidth(-50))
            make.top.equalTo(kFitWidth(383))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }
}
