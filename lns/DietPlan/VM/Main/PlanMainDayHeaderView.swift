//
//  PlanMainDayHeaderView.swift
//  lns
//
//  Created by LNS2 on 2026/4/15.
//

import SnapKit

class PlanMainDayHeaderView: UICollectionReusableView {
    private var contentTopConstraint: Constraint?
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private let caloriesValueLabel = PlanMainDayHeaderView.makeValueLabel()
    private let proteinValueLabel = PlanMainDayHeaderView.makeValueLabel()
    private let carbohydrateValueLabel = PlanMainDayHeaderView.makeValueLabel()
    private let fatValueLabel = PlanMainDayHeaderView.makeValueLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateTopSpacing(0)
    }
    
    func updateUI(section: PlanMainMealDaySection) {
        dayLabel.text = dateText(from: section.sdate)
        caloriesValueLabel.text = WHUtils.convertStringToStringNoDigit("\(section.totalCalories)") ?? "0"
        proteinValueLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(section.totalProtein)") ?? "0")"
        carbohydrateValueLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(section.totalCarbohydrate)") ?? "0")"
        fatValueLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(section.totalFat)") ?? "0")"
    }
    
    func updateTopSpacing(_ spacing: CGFloat) {
        contentTopConstraint?.update(offset: spacing)
    }
}

private extension PlanMainDayHeaderView {
    static func makeValueLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }
    
    static func makeTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textAlignment = .center
        return label
    }
    
    func metricItem(valueLabel: UILabel, title: String) -> UIView {
        let view = UIView()
        let titleLabel = Self.makeTitleLabel(text: title)
        
        view.addSubview(valueLabel)
        view.addSubview(titleLabel)
        
        valueLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(24))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(valueLabel.snp.bottom)//.offset(kFitWidth(2))
            make.height.equalTo(kFitWidth(17))
        }
        return view
    }
    
    func initUI() {
        let contentView = UIView()
        addSubview(contentView)
        contentView.addSubview(dayLabel)
        
        let rowStack = UIStackView(arrangedSubviews: [
            metricItem(valueLabel: caloriesValueLabel, title: "热量(kcal)"),
            metricItem(valueLabel: proteinValueLabel, title: "蛋白质(g)"),
            metricItem(valueLabel: carbohydrateValueLabel, title: "碳水(g)"),
            metricItem(valueLabel: fatValueLabel, title: "脂肪(g)")
        ])
        rowStack.axis = .horizontal
        rowStack.alignment = .fill
        rowStack.distribution = .fillEqually
        rowStack.spacing = 0
        contentView.addSubview(rowStack)
        
        contentView.snp.makeConstraints { make in
            contentTopConstraint = make.top.equalToSuperview().constraint
            make.left.right.bottom.equalToSuperview()
        }
        
        dayLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.lessThanOrEqualTo(kFitWidth(-16))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(26))
        }
        rowStack.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview().offset(kFitWidth(-8))
            make.height.equalTo(kFitWidth(42))
        }
    }
    
    func dateText(from sdate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.calendar = Calendar(identifier: .gregorian)
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: sdate) else {
            return sdate
        }

        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今天"
        }
        if calendar.isDateInTomorrow(date) {
            return "明天"
        }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "M月d日"
        dayFormatter.calendar = Calendar(identifier: .gregorian)
        dayFormatter.locale = Locale(identifier: "zh_CN")
        
        return "\(dayFormatter.string(from: date))，\(weekdayText(from: date))"
    }
    
    func weekdayText(from date: Date) -> String {
        let week = Calendar(identifier: .gregorian).component(.weekday, from: date)
        switch week {
        case 1: return "星期日"
        case 2: return "星期一"
        case 3: return "星期二"
        case 4: return "星期三"
        case 5: return "星期四"
        case 6: return "星期五"
        case 7: return "星期六"
        default: return ""
        }
    }
}
