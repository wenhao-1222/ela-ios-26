//
//  DietPlanCreateDateVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/16.
//

import MCToast

class DietPlanCreateDateVM: UIView {
    
    var currentSelectType: SelectDateType = .start
    var nextButtonEnableChangeBlock: ((Bool) -> Void)?
    private var startDate: Date?
    private var endDate: Date?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US_POSIX")
        return cal
    }()
    
    private lazy var displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月dd日"
//        formatter.dateFormat = "yyyy.MM.dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    private lazy var requestDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    private lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "选择日期"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.textAlignment = .center
        return lab
    }()
    
    private lazy var startTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "开始"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 17, weight: .medium)
        lab.textAlignment = .center
        return lab
    }()
    
    private lazy var startDateButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("请选择", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        btn.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
        btn.layer.cornerRadius = kFitWidth(12)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(startDateTapAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var endTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "结束"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 17, weight: .medium)
        lab.textAlignment = .center
        return lab
    }()
    
    private lazy var endDateButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("请选择", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        btn.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
        btn.layer.cornerRadius = kFitWidth(12)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(endDateTapAction), for: .touchUpInside)
        return btn
    }()
    private lazy var datePickerAlertVm: DateChoiceAlertVM = {
        let vm = DateChoiceAlertVM(frame: .zero)
        vm.isHidden = true
        vm.isWeekDay = true
        vm.confirmBlock = { [weak self] _ in
            guard let self = self else { return }
            let selected = Date().changeDateStringToDate(dateString: vm.dateStringYear)
            let selectedType = self.currentSelectType
            self.applySelectedDate(selected)
            
            if selectedType == .start {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { [weak self] in
                    self?.endDateTapAction()
                }
            }
        }
        return vm
    }()
}

extension DietPlanCreateDateVM {
    func restoreDateRange(start startDate: Date, end endDate: Date) {
        let normalizedStart = startOfDay(startDate)
        let normalizedEnd = startOfDay(endDate)

        self.startDate = clampDate(normalizedStart,
                                   min: startSelectableMinDate(),
                                   max: startSelectableMaxDate())

        if let restoredStartDate = self.startDate {
            self.endDate = clampDate(normalizedEnd,
                                     min: restoredStartDate,
                                     max: endSelectableMaxDate(for: restoredStartDate))
        } else {
            self.endDate = nil
        }

        updateDateButtons()
        updateNextButtonState()
    }

    @objc func startDateTapAction() {
        showDatePickerAlert(type: .start)
        
    }
    
    @objc func endDateTapAction() {
        showDatePickerAlert(type: .end)
    }
    
    @objc func nextButtonTapAction() {
        guard let start = startDate, let end = endDate else { return }
        guard isStartDateInRange(start) else {
            MCToast.mc_text("开始日期需在今天起两周内")
            return
        }
        guard end >= start else {
            MCToast.mc_text("结束日期不能早于开始日期")
            return
        }
        guard end <= endSelectableMaxDate(for: start) else {
            MCToast.mc_text("结束日期不能超过开始日期后\(DateRangeConfig.endSelectableDaysAfterStart)天")
            return
        }
//        let startDateStr = requestDateFormatter.string(from: start)
//        let endDateStr = requestDateFormatter.string(from: end)
//        sendCreatePlanRequest(startDate: startDateStr, endDate: endDateStr)
    }
    
    func showDatePickerAlert(type: SelectDateType) {
        currentSelectType = type
        datePickerAlertVm.pickerTitle = (type == .start) ? "开始日期" : "结束日期"
        
        switch type {
        case .start:
            let minDate = startSelectableMinDate()
            let maxDate = startSelectableMaxDate()
            let initialDate = clampDate(startDate ?? minDate, min: minDate, max: maxDate)
            datePickerAlertVm.setDateRange(minDate: minDate, maxDate: maxDate)
            datePickerAlertVm.setSelectedDate(initialDate, animated: false)
        case .end:
            guard let startDate = startDate else {
                MCToast.mc_text("请先选择开始日期")
                return
            }
            let minDate = startDate
            let maxDate = endSelectableMaxDate(for: startDate)
            let initialDate = clampDate(endDate ?? minDate, min: minDate, max: maxDate)
            datePickerAlertVm.setDateRange(minDate: minDate, maxDate: maxDate)
            datePickerAlertVm.setSelectedDate(initialDate, animated: false)
        }
        datePickerAlertVm.showView()
    }
    
    func applySelectedDate(_ date: Date) {
        let normalizedDate = startOfDay(date)
        switch currentSelectType {
        case .start:
            startDate = clampDate(normalizedDate,
                                  min: startSelectableMinDate(),
                                  max: startSelectableMaxDate())
            if let startDate = startDate, let endDate = endDate,
               (endDate < startDate || endDate > endSelectableMaxDate(for: startDate)) {
                self.endDate = nil
            }
        case .end:
            if let startDate = startDate, normalizedDate < startDate {
                MCToast.mc_text("结束日期不能早于开始日期")
                return
            }
            if let startDate = startDate {
                endDate = clampDate(normalizedDate,
                                    min: startDate,
                                    max: endSelectableMaxDate(for: startDate))
            }
        }
        if let startDate = startDate, let endDate = endDate, isCurrentDateRangeValid() {
            QuestinonaireMsgModel.shared.chartStartDate = startDate
            QuestinonaireMsgModel.shared.chartEndDate = endDate
        }
        updateDateButtons()
        updateNextButtonState()
    }
    
    func updateDateButtons() {
        updateDateButton(startDateButton, with: startDate)
        updateDateButton(endDateButton, with: endDate)
    }
    
    func updateDateButton(_ button: UIButton, with date: Date?) {
        guard let date = date else {
            button.setTitle("请选择", for: .normal)
            button.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
            return
        }
        let text = relativeDisplayText(for: date) ?? "\(displayFormatter.string(from: date)) \(weekdayText(from: date))"
        button.setTitle(text, for: .normal)
        button.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
    }
    
    func updateNextButtonState() {
        nextButtonEnableChangeBlock?(isCurrentDateRangeValid())
    }

    func isCurrentDateRangeValid() -> Bool {
        guard let start = startDate, let end = endDate else {
            return false
        }
        return isStartDateInRange(start)
            && end >= start
            && end <= endSelectableMaxDate(for: start)
    }
    
    func startSelectableMinDate() -> Date {
        return startOfDay(Date())
    }
    
    func startSelectableMaxDate() -> Date {
        let minDate = startSelectableMinDate()
        return calendar.date(byAdding: .day,
                             value: DateRangeConfig.startSelectableDaysAhead,
                             to: minDate) ?? minDate
    }
    
    func endSelectableMaxDate(for startDate: Date) -> Date {
        return calendar.date(byAdding: .day,
                             value: DateRangeConfig.endSelectableDaysAfterStart,
                             to: startDate) ?? startDate
    }
    
    func isStartDateInRange(_ date: Date) -> Bool {
        let minDate = startSelectableMinDate()
        let maxDate = startSelectableMaxDate()
        return date >= minDate && date <= maxDate
    }
    
    func startOfDay(_ date: Date) -> Date {
        return calendar.startOfDay(for: date)
    }

    func relativeDisplayText(for date: Date) -> String? {
        let normalizedDate = startOfDay(date)
        let today = startSelectableMinDate()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)

        if normalizedDate == today {
            return "今天"
        }
        if normalizedDate == tomorrow {
            return "明天"
        }
        return nil
    }
    
    func weekdayText(from date: Date) -> String {
        switch calendar.component(.weekday, from: date) {
        case 1: return "周日"
        case 2: return "周一"
        case 3: return "周二"
        case 4: return "周三"
        case 5: return "周四"
        case 6: return "周五"
        case 7: return "周六"
        default: return ""
        }
    }
    
    func clampDate(_ date: Date, min minDate: Date, max maxDate: Date) -> Date {
        return max(minDate, min(date, maxDate))
    }
}

extension DietPlanCreateDateVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(startTitleLabel)
        addSubview(startDateButton)
        addSubview(endTitleLabel)
        addSubview(endDateButton)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getKeyWindow().addSubview(self.datePickerAlertVm)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(94))
        }
        
        startTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(84))
        }
        
        startDateButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(startTitleLabel.snp.bottom).offset(kFitWidth(20))
            make.height.equalTo(kFitWidth(60))
        }
        
        endTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(startDateButton.snp.bottom).offset(kFitWidth(45))
        }
        
        endDateButton.snp.makeConstraints { make in
            make.left.right.height.equalTo(startDateButton)
            make.top.equalTo(endTitleLabel.snp.bottom).offset(kFitWidth(20))
        }
        
        datePickerAlertVm.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        updateDateButtons()
        updateNextButtonState()
    }
}
