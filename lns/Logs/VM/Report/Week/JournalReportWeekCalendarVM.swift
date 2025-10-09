//
//  JournalReportWeekCalendarVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/16.
//

class JournalReportWeekCalendarVM: UIView {
    
    let selfHeight = kFitWidth(178)
    let selfWidth = SCREEN_WIDHT-kFitWidth(32)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: selfWidth, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isSkeletonable = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var monthVm: JournalReportWeekCalendarMonthVM = {
        let vm = JournalReportWeekCalendarMonthVM.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var dayVm: JournalReportWeekCalendarDayVM = {
        let vm = JournalReportWeekCalendarDayVM.init(frame: CGRect.init(x: self.monthVm.frame.maxX, y: 0, width: 0, height: 0))
        return vm
    }()
}

extension JournalReportWeekCalendarVM{
    func updateUI(startDate:String,endDate:String,perfectDay:String,logsDate:NSArray){
        let startDateArray = startDate.components(separatedBy: "-")
        let endDateArray = endDate.components(separatedBy: "-")
        
        var monthString = startDateArray[1]
        if startDateArray[1] != endDateArray[1]{
            monthString = "\(startDateArray[1])~\(endDateArray[1])"
        }
        
        let monthAttr = NSMutableAttributedString(string: monthString)
        let monthStr = NSMutableAttributedString(string: "月")
        monthAttr.yy_font = .systemFont(ofSize: 55, weight: .regular)
        monthStr.yy_font = .systemFont(ofSize: 25, weight: .regular)
        monthAttr.append(monthStr)
        monthVm.monthLabel.attributedText = monthAttr
        
        if startDateArray[0] == endDateArray[0]{
            monthVm.yearLabel.text = startDateArray[0]
        }else{
            monthVm.yearLabel.text = "\(startDateArray[0]) ~ \(endDateArray[0])"
        }
        
//        let calendarStartDate = Date().nextDay(days: -13, baseDate: startDate)
//        let calendarEndDate = Date().nextDay(days: 15,baseDate: endDate)
        
        var dateArray:[String] = [String]()
        
        for i in -13..<0{
            let date = Date().nextDay(days: i, baseDate: startDate)
            dateArray.append(date)
        }
//        dateArray.append(startDate)
        for i in 0..<22{
            let date = Date().nextDay(days: i, baseDate: startDate)
            dateArray.append(date)
        }
//        dayVm.updateUI(dataArray: dateArray,
//                       startDate: startDate,
//                       endDate: endDate)
        dayVm.updateUI(dataArray: dateArray,
                       startDate: Date().changeDateFormatter(dateString: startDate, formatter: "yyyy-M-d", targetFormatter: "yyyy-MM-dd"),
                       endDate: Date().changeDateFormatter(dateString: endDate, formatter: "yyyy-M-d", targetFormatter: "yyyy-MM-dd"),
                       perfectDate: Date().changeDateFormatter(dateString: perfectDay, formatter: "yyyy.MM.dd", targetFormatter: "yyyy-MM-dd"),
                       logsDates: logsDate)
    }
}

extension JournalReportWeekCalendarVM{
    func initUI() {
        addSubview(monthVm)
        addSubview(dayVm)
    }
}
