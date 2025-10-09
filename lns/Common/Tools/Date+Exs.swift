//
//  Date+Exs.swift
//  ttjx
//
//  Created by 文 on 2019/11/15.
//  Copyright © 2019 ttjx. All rights reserved.
//

import Foundation

enum DateOffset {
    case days(Int)
    case months(Int)
    case years(Int)
}


extension Date{
    var timeStamp : String{
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    //时间戳转成字符串
    func timeIntervalChangeToTimeStr(timeInterval:TimeInterval, dateFormat:String?) -> String {
        let date:NSDate = NSDate.init(timeIntervalSince1970: timeInterval/1000)
        let formatter = DateFormatter.init()
        if dateFormat == nil {
            formatter.dateFormat = "yyyy-MM-dd"
        }else{
            formatter.dateFormat = dateFormat
        }
        return formatter.string(from: date as Date)
    }
    func changeDateToString(date:Date,targetFormatter:String?="yyyy-MM-dd") -> String {
        let dateformatter = DateFormatter()

        dateformatter.dateFormat = targetFormatter// 自定义时间格式
        dateformatter.calendar = Calendar.init(identifier: .gregorian)
        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.current//Locale.init(identifier: "zh_Hans_CN")

        let time = dateformatter.string(from: date)
        
        return time
    }
    func changeZeroAreaToZHTimeZone(dateString:String,targetFormatter:String?="yyyy-MM-dd") -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone.current//TimeZone(secondsFromGMT: 0)
        dateFormatter.calendar = Calendar.init(identifier: .gregorian)
        dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        let date = dateFormatter.date(from: dateString)
        // 转换为东八区时区
        dateFormatter.timeZone = TimeZone.current//TimeZone(identifier: "Asia/Shanghai")
        dateFormatter.dateFormat = targetFormatter//"yyyy-MM-dd"
        dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.current//Locale.init(identifier: "zh_Hans_CN")
        let beijingDateString = dateFormatter.string(from: date ?? Date())
         
        return beijingDateString
    }
    var currentHourMinute : String{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm"// 自定义时间格式
        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.init(identifier: "zh_Hans_CN")
        dateformatter.calendar = Calendar.init(identifier: .gregorian)
//        dateformatter.timeStyle = .medium
        let time = dateformatter.string(from: Date())

        return time
    }
    var currentSeconds : String{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// 自定义时间格式
        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.init(identifier: "zh_Hans_CN")
        dateformatter.calendar = Calendar.init(identifier: .gregorian)
//        dateformatter.timeStyle = .medium
        let time = dateformatter.string(from: Date())

        return time
    }
    var currentSecondsUTC8 : String{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// 自定义时间格式
        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.init(identifier: "zh_Hans_CN")
        dateformatter.calendar = Calendar.init(identifier: .gregorian)
        dateformatter.timeZone = TimeZone(secondsFromGMT: 8*3600)//东八区
//        dateformatter.timeStyle = .medium
        let time = dateformatter.string(from: Date())

        return time
    }
     /// 获取当前 毫秒级 时间戳 - 13位
    var timeStampMill : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
    func changeDateStringToDate(dateString:String,formatter:String? = "yyyy-MM-dd") -> Date{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = formatter// 自定义时间格式
        dateformatter.calendar = Calendar.init(identifier: .gregorian)
        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.init(identifier: "zh_Hans_CN")
        dateformatter.timeZone = TimeZone.current
        
//        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"// 自定义时间格式
//        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.init(identifier: "zh_Hans_CN")
//        dateformatter.calendar = Calendar.init(identifier: .gregorian)
//        dateformatter.timeZone = TimeZone(secondsFromGMT: 8*3600)//东八区
        
        var dateStr = dateString
        if dateStr.contains("T"){
            dateStr = dateStr.replacingOccurrences(of: "T", with: " ")
        }

        let time = dateformatter.date(from: dateStr)

        return time ?? Date()
    }
    var todayDate : String{
        let dateformatter = DateFormatter()
        dateformatter.calendar = Calendar.init(identifier: .gregorian)
        dateformatter.dateFormat = "yyyy-MM-dd"// 自定义时间格式
        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.init(identifier: "zh_Hans_CN")//Locale.current//Locale.init(identifier: "zh_Hans_CN")

        let time = dateformatter.string(from: Date())

        return time
    }
    //获某天的起始时间也就是：如：2022-05-29 00:00:00
    func getTodayStartDate(date: Date) -> Date {
        //开始时间
        var calendar = NSCalendar.current
        calendar.timeZone = NSTimeZone.local
        let dateAtMidnight:Date = calendar.startOfDay(for: date)
//        print(dateAtMidnight)
//        print("当天开始时间：\(dateAtMidnight)")
        return dateAtMidnight
    }
    func nextDay(days:Int,baseDate:String? = "") -> String{
        // 获取当前日期
        var today = Date()
        
        if baseDate != ""{
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"// 自定义时间格式
            dateformatter.calendar = Calendar.init(identifier: .gregorian)
            dateformatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.current//Locale.init(identifier: "zh_Hans_CN")
            today = dateformatter.date(from: baseDate ?? todayDate) ?? Date()
        }
         
        // 创建一个日历对象
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current//TimeZone(identifier: "Asia/Shanghai")!
         
        // 计算第二天的日期
        if let secondDay = calendar.date(byAdding: .day, value: days, to: today) {
            // 打印第二天的日期和时间
//            print("第二天的日期和时间是: \(secondDay)")
            
            // 创建日期格式器
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.calendar = Calendar.init(identifier: .gregorian)
            dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.current//Locale(identifier: "zh_Hans_CN")
            return dateFormatter.string(from: secondDay)
        } else {
            print("无法计算第二天的日期")
            return todayDate
        }
    }
    func getAdjustedDateString(offset: DateOffset) -> String {
//        let calendar = Calendar.current
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        let now = Date()
        var baseDate: Date?

        switch offset {
        case .days(let dayCount):
            baseDate = calendar.date(byAdding: .day, value: -dayCount, to: now)
        case .months(let monthCount):
            // 先减月份
            if let tempDate = calendar.date(byAdding: .month, value: -monthCount, to: now) {
                // 再加一天
                baseDate = calendar.date(byAdding: .day, value: 1, to: tempDate)
            }
        case .years(let yearCount):
            if let tempDate = calendar.date(byAdding: .year, value: -yearCount, to: now) {
                // 同样加一天
                baseDate = calendar.date(byAdding: .day, value: 1, to: tempDate)
            }
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: baseDate ?? now)
    }
    var todaySeconds : String{
        let dateformatter = DateFormatter()

        dateformatter.dateFormat = "yyyyMMddHHmmss"// 自定义时间格式
        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")
        dateformatter.calendar = Calendar.init(identifier: .gregorian)

        let time = dateformatter.string(from: Date())

        return time
    }
    var currentYear : Int{
        let year = self.currenYearMonth[0] as? String ?? "2024"
        return Int((year as NSString).intValue)
    }
    var currentMonth : String{
        let dateformatter = DateFormatter()

        dateformatter.dateFormat = "yyyy-MM"// 自定义时间格式
        dateformatter.calendar = Calendar.init(identifier: .gregorian)
        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.current//Locale.init(identifier: "zh_Hans_CN")

        let time = dateformatter.string(from: Date())

        return time
    }
    var currentDay : String{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyyMMdd"// 自定义时间格式
        dateformatter.calendar = Calendar.init(identifier: .gregorian)
        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.current//Locale.init(identifier: "zh_Hans_CN")
        let time = dateformatter.string(from: Date())

        return time
    }
    var currenYearMonth : NSArray {
        let dateformatter = DateFormatter()

        dateformatter.dateFormat = "yyyy-MM"// 自定义时间格式
        dateformatter.calendar = Calendar.init(identifier: .gregorian)
        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.current//Locale.init(identifier: "zh_Hans_CN")

        let time = dateformatter.string(from: Date())
        
        let timstrings: [Substring] = time.split(separator: "-")
        var timeArrayStrings: [String] = []
        for item in timstrings {
            timeArrayStrings.append("\(item)")
        }

        return timeArrayStrings as NSArray
    }
    var currenYearMonthM : NSArray {
        let dateformatter = DateFormatter()

        dateformatter.dateFormat = "yyyy-M"// 自定义时间格式
        dateformatter.calendar = Calendar.init(identifier: .gregorian)
        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.current//Locale.init(identifier: "zh_Hans_CN")

        let time = dateformatter.string(from: Date())
        
        let timstrings: [Substring] = time.split(separator: "-")
        var timeArrayStrings: [String] = []
        for item in timstrings {
            timeArrayStrings.append("\(item)")
        }

        return timeArrayStrings as NSArray
    }
    //比较两个日期间   相差多少天
    func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return components.day ?? 0
    }
    /// 计算与指定字符串日期之间相隔的自然天数（忽略时分秒）
  /// - Parameter dateString: 格式为 "yyyy-MM-dd" 的日期字符串
  /// - Returns: 与当前日期之间相差的天数（未来为负，过去为正）
  func daysDifference(from dateString: String) -> Int? {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      formatter.timeZone = TimeZone.current
      formatter.locale = Locale.current
      
      guard let inputDate = formatter.date(from: dateString) else {
          return nil
      }
      
      // 使用 Calendar 忽略时间差异，只计算日期之间的自然天数
      let calendar = Calendar.current
      let startOfToday = calendar.startOfDay(for: self)
      let startOfInput = calendar.startOfDay(for: inputDate)
      
      let components = calendar.dateComponents([.day], from: startOfInput, to: startOfToday)
      return components.day
  }
    //MARK: 比较两个日期之间相距是否超过 month个月
    func isDateDistanceMoreThanMonths(_ date1: Date, from date2: Date,month:Int) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: date2, to: date1)
//        DLLog(message: "\(components.month)")
//        print("isDateDistanceMoreThanMonths:\(components.month)")
        return components.month ?? 0 > month-1
    }
    /**
     firstTime  是否小于 secondTime
     */
    func judgeMin(firstTime:String,secondTime:String,formatter:String? = "yyyy-MM-dd HH:mm:ss") -> Bool {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = formatter
        dateformatter.calendar = Calendar.init(identifier: .gregorian)
        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.current//Locale.init(identifier: "zh_Hans_CN")
        
        let startDate = changeDateStringToDate(dateString: firstTime, formatter: formatter)
        let secondDate = changeDateStringToDate(dateString: secondTime,formatter: formatter)
        
        let startTimeInterval: TimeInterval = startDate.timeIntervalSince1970
        let secondTimeInterval: TimeInterval = secondDate.timeIntervalSince1970
        
        let startTimeStamp = Int(startTimeInterval)
        let secondTimeStamp = Int(secondTimeInterval)
        
        return startTimeStamp < secondTimeStamp ? true : false
    }
    
    func changeDateFormatter(dateString:String,formatter:String,targetFormatter:String,timeZone:String?="") -> String {
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = formatter
        dateformatter.calendar = Calendar.init(identifier: .gregorian)
        dateformatter.locale = Locale.init(identifier: "en_US_POSIX")//Locale.init(identifier: "zh_Hans_CN")
        
        if let date = dateformatter.date(from: dateString) {
            // 转换为本地时区的日期格式
            dateformatter.dateFormat = targetFormatter
            if timeZone == ""{
                dateformatter.timeZone = TimeZone.current
            }else{
                dateformatter.timeZone = TimeZone(abbreviation: timeZone ?? "UTC") // UTC 时区
            }
            
            let localDateString = dateformatter.string(from: date)
//            print(localDateString) // 输出转换后的本地时区日期，例如 "2024-04-03 15:26:28"

            return localDateString
        } else {
            print("Invalid date string")
        }
        
        return dateString
    }
    /// 按本地时区，把日期格式化成字符串
    /// - Parameter format: 例如 "yyyy-MM-dd" / "HH:mm" ...
    /// - Returns: 本地时间对应的字符串
    func toLocalString(_ format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        df.timeZone = TimeZone.current
        df.calendar = Calendar(identifier: .gregorian)
        return df.string(from: self)
    }

    func getWeekday(from date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.component(.weekday, from: date)
        let weekdays = calendar.weekdaySymbols
        return weekdays[components - 1]
    }
    
    func getWeekdayIndex(from date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.component(.weekday, from: date)
        return components - 1
    }
    func getWeekdayIndex(from dateString: String) -> Int {
        let date = self.changeDateStringToDate(dateString: dateString)
        let calendar = Calendar.current
        let components = calendar.component(.weekday, from: date)
        return components > 1 ? (components - 1) : 7
    }
    func getLastYearsAgo(lastYears:Int) -> Date {
        let calendar = Calendar.current
        let components = DateComponents(year: lastYears)
        let threeYearsAgo = calendar.date(byAdding: components, to: Date())
        return threeYearsAgo ?? Date()
    }
    func getNextMonth(nextMonth:Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents(month: nextMonth)
        let newDate = calendar.date(byAdding: components, to: Date())
        return newDate ?? Date()
    }
}

extension Date{
    func getStartAndEndMonth(from startDateStr: String, to endDateStr: String) -> (String, String)? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.calendar = Calendar(identifier: .gregorian) // 强制公历
        formatter.locale = Locale(identifier: "en_US_POSIX")   // 避免本地化影响
        formatter.timeZone = TimeZone(identifier: "UTC")

        guard let startDate = formatter.date(from: startDateStr),
              let endDate = formatter.date(from: endDateStr) else {
            return nil
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-M-d"
        outputFormatter.calendar = Calendar(identifier: .gregorian) // 输出也强制公历
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        outputFormatter.timeZone = TimeZone(identifier: "UTC")

        let startMonth = outputFormatter.string(from: startDate)
        let endMonth = outputFormatter.string(from: endDate)

        return (startMonth, endMonth)
    }
}
