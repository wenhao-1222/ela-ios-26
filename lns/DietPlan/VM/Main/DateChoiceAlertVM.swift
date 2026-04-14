//
//  DateChoiceAlertVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/11.
//
import Foundation
import UIKit

class DateChoiceAlertVM: UIView {
    
    // MARK: - Public
    
    var dateStringYear = ""
    var dateString = ""
    var weekDay = ""
    var isWeekDay = true
    
    /// true: 返回 "3月15日 周日"
    /// false: 返回 "3月15日"
    var confirmBlock: ((String) -> Void)?
    
    /// 顶部标题
    var pickerTitle: String = "开始日期" {
        didSet {
            titleLabel.text = pickerTitle
        }
    }
    private lazy var calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US_POSIX")
        cal.timeZone = TimeZone.current
        return cal
    }()
    // MARK: - Private - UI
    
    private var whiteViewHeight: CGFloat = kFitWidth(430) + WHUtils().getBottomSafeAreaHeight()
    
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = .COLOR_ALERT_BG_BLACK
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenView))
        v.addGestureRecognizer(tap)
        return v
    }()
    
    lazy var whiteView: UIView = {
        let v = UIView(frame: CGRect(
            x: 0,
            y: SCREEN_HEIGHT,
            width: SCREEN_WIDHT,
            height: whiteViewHeight
        ))
        v.backgroundColor = .COLOR_CARD_BG_WHITE
        v.layer.cornerRadius = kFitWidth(20)
        v.clipsToBounds = true
        if #available(iOS 13.0, *) {
            v.layer.cornerCurve = .continuous
            v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingToDo))
        v.addGestureRecognizer(tap)
        return v
    }()
    
    lazy var closeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        return btn
    }()
    
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = pickerTitle
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .semibold)
        lab.textAlignment = .center
        return lab
    }()
    
    lazy var saveButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("确认", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(28)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var todayButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("今天", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(todayAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .clear
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    // MARK: - Private - Data
    /// 日期源数组（单列）
    private var dateList: [Date] = []
    
    /// 当前选中的日期
    private var selectedDate: Date = Date()
    
    /// 默认最小日期：今天
    private var minSelectableDate: Date = Calendar.current.startOfDay(for: Date())
    
    /// 默认最大日期：今天往后 30 天
    private var maxSelectableDate: Date = {
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .day, value: 30, to: today) ?? today
    }()
    
    private let gregorianCalendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale.current
        cal.timeZone = TimeZone.current
        return cal
    }()
    
    private let yearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    private let monthDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = "M月dd日"
        return f
    }()
    
    private let pickerTextFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = "M月dd日"
        return f
    }()
    
    /// 蒙层目标透明度
    private var targetDimAlpha: CGFloat {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.25
        } else {
            return 0.25
        }
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        isHidden = true
        
        initUI()
        rebuildDateListAndReload(keepSelectedDate: Calendar.current.startOfDay(for: Date()))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.frame = bounds
        
        if isHidden {
            whiteView.frame = CGRect(
                x: 0,
                y: SCREEN_HEIGHT,
                width: SCREEN_WIDHT,
                height: whiteViewHeight
            )
        } else {
            whiteView.frame = CGRect(
                x: 0,
                y: SCREEN_HEIGHT - whiteViewHeight,
                width: SCREEN_WIDHT,
                height: whiteViewHeight
            )
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *),
           previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle,
           !isHidden {
            UIView.animate(withDuration: 0.2) {
                self.bgView.alpha = self.targetDimAlpha
            }
        }
    }
    
    // MARK: - UI Setup
    
    private func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        
        whiteView.addSubview(closeButton)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(todayButton)
        whiteView.addSubview(pickerView)
        whiteView.addSubview(saveButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        closeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(16))
            make.top.equalToSuperview().offset(kFitWidth(14))
            make.width.height.equalTo(kFitWidth(36))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(closeButton)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(closeButton.snp.right).offset(kFitWidth(12))
            make.right.lessThanOrEqualToSuperview().offset(-kFitWidth(48))
        }
        
        todayButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(closeButton.snp.bottom).offset(kFitWidth(8))
            make.height.equalTo(kFitWidth(28))
        }
        
        pickerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(closeButton.snp.bottom).offset(kFitWidth(18))
            make.height.equalTo(kFitWidth(220))
        }
        
        saveButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(20))
            make.right.equalToSuperview().offset(-kFitWidth(20))
            make.height.equalTo(kFitWidth(56))
            make.bottom.equalToSuperview().offset(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(18)))
        }
    }
    
    // MARK: - Show / Hide
    
    @objc func showView() {
        if superview == nil {
            UIApplication.shared.keyWindow?.addSubview(self)
        }
        
        isHidden = false
        bringSubviewToFront(whiteView)
        
        let targetY = SCREEN_HEIGHT - whiteViewHeight
        whiteView.frame = CGRect(
            x: 0,
            y: SCREEN_HEIGHT,
            width: SCREEN_WIDHT,
            height: whiteViewHeight
        )
        bgView.alpha = 0
        
        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseOut) {
            self.bgView.alpha = self.targetDimAlpha
        }
        
        UIView.animate(withDuration: 0.42,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.08,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.frame = CGRect(
                x: 0,
                y: targetY,
                width: SCREEN_WIDHT,
                height: self.whiteViewHeight
            )
        }
    }
    
    @objc func hiddenView() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.whiteView.frame = CGRect(
                x: 0,
                y: SCREEN_HEIGHT,
                width: SCREEN_WIDHT,
                height: self.whiteViewHeight
            )
            self.bgView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }
    
    @objc private func nothingToDo() { }
    
    // MARK: - Action
    
    @objc func confirmAction() {
        let blockString = isWeekDay ? weekDay : dateString
        confirmBlock?(blockString)
        hiddenView()
    }
    
    @objc func todayAction() {
        let today = gregorianCalendar.startOfDay(for: Date())
        setSelectedDate(today, animated: true)
        confirmAction()
    }
    
    // MARK: - Public Methods - Date Range
    
    /// 设置最小日期，最大日期保持不变
    func setMinDate(_ minDate: Date) {
        let normalizedMin = gregorianCalendar.startOfDay(for: minDate)
        minSelectableDate = normalizedMin
        
        if maxSelectableDate < minSelectableDate {
            maxSelectableDate = minSelectableDate
        }
        
        rebuildDateListAndReload(keepSelectedDate: selectedDate)
    }
    
    /// 设置最大日期，最小日期保持不变
    func setMaxDate(_ maxDate: Date) {
        let normalizedMax = gregorianCalendar.startOfDay(for: maxDate)
        maxSelectableDate = normalizedMax
        
        if maxSelectableDate < minSelectableDate {
            minSelectableDate = maxSelectableDate
        }
        
        rebuildDateListAndReload(keepSelectedDate: selectedDate)
    }
    
    /// 同时设置最小、最大日期
    func setDateRange(minDate: Date, maxDate: Date) {
        let normalizedMin = gregorianCalendar.startOfDay(for: minDate)
        let normalizedMax = gregorianCalendar.startOfDay(for: maxDate)
        
        if normalizedMin <= normalizedMax {
            minSelectableDate = normalizedMin
            maxSelectableDate = normalizedMax
        } else {
            minSelectableDate = normalizedMax
            maxSelectableDate = normalizedMin
        }
        
        rebuildDateListAndReload(keepSelectedDate: selectedDate)
    }
    
    /// 恢复默认范围：今天 ~ 今天后30天
    func resetDefaultDateRange() {
        let today = gregorianCalendar.startOfDay(for: Date())
        minSelectableDate = today
        maxSelectableDate = gregorianCalendar.date(byAdding: .day, value: 30, to: today) ?? today
        rebuildDateListAndReload(keepSelectedDate: selectedDate)
    }
    
    /// 外部根据 yyyy-MM-dd 设置选中日期
    func setDate(dateString: String) {
        let date = Date().changeDateStringToDate(dateString: dateString)
        let normalizedDate = gregorianCalendar.startOfDay(for: date)
        setSelectedDate(normalizedDate, animated: false)
    }
    
    /// 外部直接设置选中日期
    func setSelectedDate(_ date: Date, animated: Bool) {
        guard !dateList.isEmpty else { return }
        
        let normalized = gregorianCalendar.startOfDay(for: date)
        let finalDate: Date
        
        if normalized < minSelectableDate {
            finalDate = minSelectableDate
        } else if normalized > maxSelectableDate {
            finalDate = maxSelectableDate
        } else {
            finalDate = normalized
        }
        
        if let row = dateList.firstIndex(where: { gregorianCalendar.isDate($0, inSameDayAs: finalDate) }) {
            pickerView.selectRow(row, inComponent: 0, animated: animated)
            updateSelectedDate(dateList[row])
        } else {
            updateSelectedDate(dateList[0])
            pickerView.selectRow(0, inComponent: 0, animated: animated)
        }
    }
    
    // MARK: - Private Methods - Data
    
    private func rebuildDateListAndReload(keepSelectedDate: Date?) {
        dateList.removeAll()
        
        var current = minSelectableDate
        while current <= maxSelectableDate {
            dateList.append(current)
            guard let next = gregorianCalendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        
        pickerView.reloadAllComponents()
        
        if dateList.isEmpty {
            let fallback = gregorianCalendar.startOfDay(for: Date())
            dateList = [fallback]
            pickerView.reloadAllComponents()
            updateSelectedDate(fallback)
            pickerView.selectRow(0, inComponent: 0, animated: false)
            return
        }
        
        let targetDate = keepSelectedDate ?? minSelectableDate
        setSelectedDate(targetDate, animated: false)
    }
    
    private func updateSelectedDate(_ date: Date) {
        selectedDate = gregorianCalendar.startOfDay(for: date)
        changeDate(date: selectedDate)
    }
    
    private func changeDate(date: Date) {
        dateStringYear = yearFormatter.string(from: date)
        dateString = monthDayFormatter.string(from: date)
        weekDay = "\(monthDayFormatter.string(from: date)) \(weekdayString(from: date))"
        
        DLLog(message: "dateString:\(dateString)")
        DLLog(message: "weekDay:\(weekDay)")
    }
    
    private func weekdayString(from date: Date) -> String {
        let weekday = gregorianCalendar.component(.weekday, from: date)
        switch weekday {
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
    
    private func pickerDisplayString(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "今天"
        }
        if calendar.isDateInTomorrow(date) {
            return "明天"
        }
        return "\(pickerTextFormatter.string(from: date)) \(weekdayString(from: date))"
    }
}

// MARK: - UIPickerViewDataSource

extension DateChoiceAlertVM: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dateList.count
    }
}

// MARK: - UIPickerViewDelegate

extension DateChoiceAlertVM: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kFitWidth(52)
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return SCREEN_WIDHT
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row >= 0, row < dateList.count else { return }
        updateSelectedDate(dateList[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard row >= 0, row < dateList.count else { return nil }
        
        let text = pickerDisplayString(for: dateList[row])
        let attr = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 18, weight: .regular),
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214
            ]
        )
        return attr
    }
    
    /// 如果你想让选中行更接近截图里的大字号效果，可以用 viewForRow
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel
        if let reused = view as? UILabel {
            label = reused
        } else {
            label = UILabel()
            label.textAlignment = .center
        }
        
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.text = pickerDisplayString(for: dateList[row])
        
        return label
    }
}
