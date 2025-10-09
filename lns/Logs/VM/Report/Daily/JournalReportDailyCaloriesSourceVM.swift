//
//  JournalReportDailyCaloriesSourceVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/13.
//


class JournalReportDailyCaloriesSourceVM: UIView {
    
    let selfWidth = SCREEN_WIDHT-kFitWidth(32)
    var selfHeight = kFitWidth(270)
    
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
        img.setImgLocal(imgName: "report_calories_source_icon")
        
        return img
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "热量来源分布"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var caloriesPieVm: JournalReportPieVM = {
        let vm = JournalReportPieVM.init(frame: CGRect.init(x: kFitWidth(-16), y: kFitWidth(65), width: 0, height: 0))
        
        vm.percentBlock = {(carbo,protein,fat)in
            self.carboLabel.text = "碳水 \(WHUtils.convertStringToString(String(format:"%.2f",carbo*100)) ?? "0.00")%"
            self.proteinLabel.text = "蛋白质 \(WHUtils.convertStringToString(String(format:"%.2f",protein*100)) ?? "0.00")%"
            if carbo > 0 || protein > 0 || fat > 0 {
                self.fatLabel.text = "脂肪 \(WHUtils.convertStringToString(String(format:"%.2f",(100-carbo*100-protein*100))) ?? "0.00")%"
            }else{
                self.fatLabel.text = "脂肪 0%"
            }
        }
        return vm
    }()
    lazy var carboView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARBOHYDRATE
        vi.layer.cornerRadius = kFitWidth(3.25)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var carboLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var proteinView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_PROTEIN
        vi.layer.cornerRadius = kFitWidth(3.25)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var proteinLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var fatView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_FAT
        vi.layer.cornerRadius = kFitWidth(3.25)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var fatLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
}

extension JournalReportDailyCaloriesSourceVM{
    func dealData(detailDict:NSDictionary) {
        let protein = detailDict.doubleValueForKey(key: "proteinDouble")
        let carbo = detailDict.doubleValueForKey(key: "carbohydrateDouble")
        let fat = detailDict.doubleValueForKey(key: "fatDouble")
        
        if protein > 0 || carbo > 0 || fat > 0{
            caloriesPieVm.updateDataSource(array: [carbo,protein,fat], type: .CALORIES)
        }else{
            caloriesPieVm.updateDataSource(array: [detailDict.doubleValueForKey(key: "carbohydrate"),
                                                 detailDict.doubleValueForKey(key: "protein"),
                                                 detailDict.doubleValueForKey(key: "fat")],
                                           type: .CALORIES)
        }
        
    }
}

extension JournalReportDailyCaloriesSourceVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(iconImgView)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(caloriesPieVm)
        
        whiteView.addSubview(carboView)
        whiteView.addSubview(carboLabel)
        whiteView.addSubview(proteinView)
        whiteView.addSubview(proteinLabel)
        whiteView.addSubview(fatView)
        whiteView.addSubview(fatLabel)
        
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
        carboView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(22))
            make.bottom.equalTo(kFitWidth(-25))
            make.width.height.equalTo(kFitWidth(6.5))
        }
        carboLabel.snp.makeConstraints { make in
            make.left.equalTo(carboView.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(carboView)
//            make.right.equalTo(proteinView.snp.left).offset(kFitWidth(-4))
        }
        proteinLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview().offset(kFitWidth(5))
            make.centerY.lessThanOrEqualTo(carboView)
//            make.right.equalTo(fatView.snp.left).offset(kFitWidth(-4))
        }
        proteinView.snp.makeConstraints { make in
            make.right.equalTo(proteinLabel.snp.left).offset(kFitWidth(-4))
            make.centerY.lessThanOrEqualTo(carboView)
            make.width.height.equalTo(carboView)
        }
        fatLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-22))
            make.centerY.lessThanOrEqualTo(carboView)
        }
        fatView.snp.makeConstraints { make in
            make.right.equalTo(fatLabel.snp.left).offset(kFitWidth(-4))
            make.centerY.lessThanOrEqualTo(carboView)
            make.width.height.equalTo(carboView)
        }
    }
}
