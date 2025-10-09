//
//  JournalReportDailyCaloriesMealsItemVm.swift
//  lns
//
//  Created by Elavatine on 2025/5/12.
//


class JournalReportDailyCaloriesMealsItemVm: UIView {
    
    let selfWidth = kFitWidth(110)
    let selfHeight = kFitWidth(30)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: selfWidth, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var circleView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(3.25)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var caloriesNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()
}

extension JournalReportDailyCaloriesMealsItemVm{
    func updateUI(mealIndex:Int,caloriesNum:Int,percent:Float) {
        
    }
    func updateUI(model:ReportCaloriesModel) {
        circleView.backgroundColor = model.color
        titleLab.text = "第 \(model.sn) 餐  \(WHUtils.convertStringToString(String(format:"%.2f",model.percent)) ?? "0")%"
        caloriesNumLabel.text = "\(Int(model.calories.rounded()))千卡"
    }
}

extension JournalReportDailyCaloriesMealsItemVm{
    func initUI() {
        addSubview(circleView)
        addSubview(titleLab)
        addSubview(caloriesNumLabel)
        
        setConstrait()
    }
    func setConstrait() {
        circleView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.lessThanOrEqualTo(titleLab)
            make.width.height.equalTo(kFitWidth(6.5))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(11))
            make.top.equalToSuperview()
            make.right.equalToSuperview()
        }
        caloriesNumLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLab)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
}
