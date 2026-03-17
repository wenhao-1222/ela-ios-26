//
//  DietPlanCreateDateVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/11.
//

import UIKit
import MCToast
import SnapKit
import CoreImage

enum SelectDateType {
    case start
    case end
}

enum DateRangeConfig {
    // 可配置：开始日期可选“今天往后几天”（两周）
    static let startSelectableDaysAhead = 14
    // 可配置：结束日期可选“开始日期往后几天”
    static let endSelectableDaysAfterStart = 14
}
class DietPlanCreateDateVC: WHBaseViewVC {
    
    var currentSelectType: SelectDateType = .start
    private var startDate: Date?
    private var endDate: Date?
    private var isSubmittingCreatePlan = false
    // 可调：假进度节奏配置，其他页面可直接复用同一个 VM + 配置
    private var createPlanLoadingConfig = DietPlanFakeProgressLoadingVM.Config(
        fakeDuration: 3.0,
        maxProgressBeforeSuccess: 0.92,
        statusText: "创建食谱中..."
    )
    
    private lazy var createPlanLoadingVm: DietPlanFakeProgressLoadingVM = {
        let vm = DietPlanFakeProgressLoadingVM(frame: .zero)
        vm.updateConfig(createPlanLoadingConfig)
        return vm
    }()
    
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
    
    private lazy var requestDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .COLOR_BG_F2
        initUI()
        updateDateButtons()
        updateNextButtonState()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.fd_interactivePopDisabled = true
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.fd_interactivePopDisabled = false
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
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
        let startDateStr = requestDateFormatter.string(from: start)
        let endDateStr = requestDateFormatter.string(from: end)
        sendCreatePlanRequest(startDate: startDateStr, endDate: endDateStr)
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
        let text = "\(displayFormatter.string(from: date)) \(weekdayText(from: date))"
        button.setTitle(text, for: .normal)
        button.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
    }
    
    func updateNextButtonState() {
        guard !isSubmittingCreatePlan else {
            nextButton.isEnabled = false
            return
        }
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

extension DietPlanCreateDateVC{
    func sendCreatePlanRequest(startDate: String, endDate: String) {
        guard !isSubmittingCreatePlan else { return }
        isSubmittingCreatePlan = true
        updateNextButtonState()
        
        createPlanLoadingVm.updateConfig(createPlanLoadingConfig)
        createPlanLoadingVm.start(on: view)
        
        self.enableInteractivePopGesture()
        
        let param = [
            "startDate": startDate,
            "endDate": endDate
        ]
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_create, parameters: param as [String : AnyObject]) { [weak self] responseObject in
            guard let self = self else { return }
            let code = responseObject["code"] as? Int ?? -1
            guard code == 200 else {
                let msg = responseObject["message"] as? String ?? "创建失败，请稍后重试"
                self.createPlanLoadingVm.completeFailure { [weak self] in
                    guard let self = self else { return }
                    self.isSubmittingCreatePlan = false
                    self.updateNextButtonState()
                    MCToast.mc_text(msg)
                }
                return
            }
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendDietPlanMsgRequest:\(dataObj)")
            
            self.createPlanLoadingVm.completeSuccess { [weak self] in
                guard let self = self else { return }
                self.isSubmittingCreatePlan = false
                self.backAction()
//                self.updateNextButtonState()
            }
        } failure: { [weak self] isError in
            guard let self = self else { return }
            self.createPlanLoadingVm.completeFailure { [weak self] in
                guard let self = self else { return }
                self.isSubmittingCreatePlan = false
                self.updateNextButtonState()
                if isError {
                    MCToast.mc_text("创建失败，请稍后重试")
                }
            }
        }
    }
}
