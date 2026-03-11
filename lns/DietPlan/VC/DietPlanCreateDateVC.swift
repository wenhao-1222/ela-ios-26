//
//  DietPlanCreateDateVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/11.
//

import UIKit
import MCToast

class DietPlanCreateDateVC: WHBaseViewVC {
    
    enum SelectDateType {
        case start
        case end
    }
    
    enum DateRangeConfig {
        // 可配置：开始日期可选“今天往后几个月”
        static let startSelectableMonthsAhead = 1
        // 可配置：结束日期可选“开始日期往后几天”
        static let endSelectableDaysAfterStart = 14
    }
    
    private var currentSelectType: SelectDateType = .start
    private var startDate: Date?
    private var endDate: Date?
    
    private lazy var calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US_POSIX")
        return cal
    }()
    
    private lazy var displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "habit_guide_back_icon"), for: .normal)
        btn.backgroundColor = .COLOR_CARD_BG_WHITE//.withAlphaComponent(0.35)
        btn.layer.cornerRadius = kFitWidth(20)
        btn.layer.borderColor = UIColor.COLOR_BG_BLACK_06.cgColor
        btn.layer.borderWidth = 1
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return btn
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
    
    private lazy var nextButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)
        return btn
    }()
//    
//    private lazy var datePickerAlertVm: DataAddDateAlertVM = {
//        let vm = DataAddDateAlertVM(frame: .zero)
//        vm.isHidden = true
//        vm.confirmBlock = { [weak self] _ in
//            self?.applySelectedDate(vm.datePicker.date)
//        }
//        return vm
//    }()
    private lazy var datePickerAlertVm: DateChoiceAlertVM = {
        let vm = DateChoiceAlertVM(frame: .zero)
        vm.isHidden = true
        vm.isWeekDay = true
        vm.confirmBlock = { [weak self] _ in
//            self?.applySelectedDate(vm.datePicker.date)
        }
        return vm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .COLOR_BG_F2
        initUI()
        updateDateButtons()
        updateNextButtonState()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
            self.startDateTapAction()
        })
    }
}

extension DietPlanCreateDateVC {
    @objc func backAction() {
        backTapAction()
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
            MCToast.mc_text("开始日期需在今天起\(DateRangeConfig.startSelectableMonthsAhead)个月内")
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
        QuestinonaireMsgModel.shared.chartStartDate = start
        QuestinonaireMsgModel.shared.chartEndDate = end
        let vc = DietPlanCreateVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showDatePickerAlert(type: SelectDateType) {
        currentSelectType = type
        datePickerAlertVm.titleLabel.text = (type == .start) ? "开始日期" : "结束日期"
        
        switch type {
        case .start:
            let minDate = startSelectableMinDate()
            let maxDate = endOfDay(startSelectableMaxDate())
//            datePickerAlertVm.datePicker.minimumDate = minDate
//            datePickerAlertVm.datePicker.maximumDate = maxDate
            let initialDate = clampDate(startDate ?? minDate, min: minDate, max: maxDate)
//            datePickerAlertVm.datePicker.setDate(initialDate, animated: false)
        case .end:
            guard let startDate = startDate else {
                MCToast.mc_text("请先选择开始日期")
                return
            }
            let minDate = startDate
            let maxDate = endOfDay(endSelectableMaxDate(for: startDate))
//            datePickerAlertVm.datePicker.minimumDate = minDate
//            datePickerAlertVm.datePicker.maximumDate = maxDate
            let initialDate = clampDate(endDate ?? minDate, min: minDate, max: maxDate)
//            datePickerAlertVm.datePicker.setDate(initialDate, animated: false)
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
        button.setTitle(displayFormatter.string(from: date), for: .normal)
        button.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
    }
    
    func updateNextButtonState() {
        guard let start = startDate, let end = endDate else {
            nextButton.isEnabled = false
            return
        }
        nextButton.isEnabled = isStartDateInRange(start)
            && end >= start
            && end <= endSelectableMaxDate(for: start)
    }
    
    func startSelectableMinDate() -> Date {
        return startOfDay(Date())
    }
    
    func startSelectableMaxDate() -> Date {
        let minDate = startSelectableMinDate()
        return calendar.date(byAdding: .month,
                             value: DateRangeConfig.startSelectableMonthsAhead,
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
    
    func endOfDay(_ date: Date) -> Date {
        let dayStart = startOfDay(date)
        return calendar.date(byAdding: DateComponents(day: 1, second: -1), to: dayStart) ?? dayStart
    }
    
    func clampDate(_ date: Date, min minDate: Date, max maxDate: Date) -> Date {
        return max(minDate, min(date, maxDate))
    }
}

extension DietPlanCreateDateVC {
    func initUI() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(startTitleLabel)
        view.addSubview(startDateButton)
        view.addSubview(endTitleLabel)
        view.addSubview(endDateButton)
        view.addSubview(nextButton)
        view.addSubview(datePickerAlertVm)
        
        backButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12.5))
            make.top.equalTo(statusBarHeight + kFitWidth(5))
            make.width.height.equalTo(kFitWidth(40))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(getNavigationBarHeight() + kFitWidth(94))
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
        
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(16)))
        }
        
        datePickerAlertVm.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
