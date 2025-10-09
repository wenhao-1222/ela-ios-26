//
//  ForumTimeUtils.swift
//  lns
//
//  Created by Elavatine on 2025/1/9.
//

class ForumTimeUtils {
    /*
     1分钟内：刚刚
     1分钟—59分钟：x分钟前
     今天内：x小时前（未满2小时就显示1小时前）
     昨天：昨天xx：xx
     2-7天：x天前
     更早：年月日
     */
    func changeTimeForShow(timeStr:String,nowTime:String) -> String {
        let nowTimeString = nowTime.replacingOccurrences(of: "T", with: " ")
        let timeString = timeStr.replacingOccurrences(of: "T", with: " ")
        
        if nowTimeString.count < 3 || timeStr.count < 3{
            return ""
        }
        
        // 解析 cTime（UTC 时间）
        let utcFormatter = DateFormatter()
        utcFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        utcFormatter.calendar = Calendar(identifier: .gregorian)
//        utcFormatter.timeZone = TimeZone(abbreviation: "UTC") // UTC 时区
        
        guard let nowDate = utcFormatter.date(from: nowTimeString)else {
            fatalError("日期格式错误")
        }
        guard let cTimeDate = utcFormatter.date(from: timeString) else {
            fatalError("日期格式错误")
        }
        
        let nowTimeStamp = Int(nowDate.timeIntervalSince1970)
        
        let cTimeStamp = Int(cTimeDate.timeIntervalSince1970)
        //差值
        let difValue = abs(nowTimeStamp - cTimeStamp)
        //1分钟内：刚刚
        //系统时间大于ctime 
        if difValue < 60{
            return "刚刚"
        }
        //1分钟—59分钟：x分钟前
        if difValue >= 60 && difValue < 60 * 60{
            let minute = difValue/60
            return "\(minute)分钟前"
        }
//        今天内：x小时前（未满2小时就显示1小时前）
        let nowDay = Date().changeDateFormatter(dateString: nowTimeString, formatter: "yyyy-MM-dd HH:mm:ss", targetFormatter: "yyyy-MM-dd",timeZone: "UTC")
        let cTimeDay = Date().changeDateFormatter(dateString: timeString, formatter: "yyyy-MM-dd HH:mm:ss", targetFormatter: "yyyy-MM-dd",timeZone: "UTC")
        if nowDay == cTimeDay{
            if difValue < 2 * 60 * 60{
                return "1小时前"
            }else{
                let hour = difValue/(60*60)
                return "\(hour)小时前"
            }
        }
//        昨天：昨天xx：xx
        let yesterDay = Date().nextDay(days: -1)
        if cTimeDay == yesterDay || difValue/(24 * 60 * 60) == 0{
            let hourString = Date().changeDateFormatter(dateString: timeString, formatter: "yyyy-MM-dd HH:mm:ss", targetFormatter: "HH:mm")
            return "昨天\(hourString)"
        }
        
        if difValue > 7 * 24 * 60 * 60{//7天前
            return Date().changeDateFormatter(dateString: timeString, formatter: "yyyy-MM-dd HH:mm:ss", targetFormatter: "yyyy-MM-dd")
        }else{//2-7天：x天前
            let day = difValue/(24 * 60 * 60)
            return "\(day)天前"
        }
    }
    
    /// 将服务器返回的事件时间与服务器当前时间进行比较，
    /// 在全世界任何时区都能显示“刚刚 / x分钟前 / x小时前 / 昨天xx:xx / x天前 / yyyy-MM-dd”。
    ///
    /// - Parameters:
    ///   - timeStr: 事件发生时间，字符串（服务器统一按 Asia/Shanghai，格式 "yyyy-MM-dd HH:mm:ss"）
    ///   - nowTime: 服务器当前时间，字符串（同上）
    /// - Returns: 人性化时间描述
    func changeTimeForShowNew(timeStr: String, nowTime: String) -> String {
        
        // 1. 将服务器字符串 (UTC+8) 解析为 Date（绝对时间）。
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // 服务器明确使用北京时区(UTC+8)
        formatter.timeZone = TimeZone.current//TimeZone(identifier: "Asia/Shanghai")
        formatter.calendar = Calendar(identifier: .gregorian)
        
        // 解析失败则返回空
        guard let eventDate = formatter.date(from: timeStr),
              let serverNowDate = formatter.date(from: nowTime) else {
            return ""
        }
        
        // 2. 计算两者时间差（秒）
        let diff = Int(serverNowDate.timeIntervalSince(eventDate)) // 可能为负值
        let absDiff = abs(diff)
        
        // 3. 根据差值范围，返回人性化显示：
        // 3.1 1分钟内：刚刚
        if absDiff < 60 {
            return "刚刚"
        }
        // 3.2 1分钟—59分钟：x分钟前
        if absDiff < 3600 {
            let minute = absDiff / 60
            return "\(minute)分钟前"
        }
        
        // 3.3 今天内：x小时前（未满2小时就显示1小时前）
        //     昨天：昨天xx:xx
        //     2-7天：x天前
        //     更早：yyyy-MM-dd
        // 这里需要区分“是否同一天 / 是否昨天等”，并将“具体时间”转为**用户本地时区**查看
        
        // 3.3.1 同一天判断 → 用本地时区的 Calendar
//        let localCalendar = Calendar.current
        var localCalendar = Calendar(identifier: .gregorian)
        localCalendar.timeZone = TimeZone.current
        let localNow = serverNowDate // 也可以再转 localNow.toLocalDate()，不过 Date 本身不含时区
        let localEvent = eventDate
        
        if localCalendar.isDate(localNow, inSameDayAs: localEvent) {
            // 同一天
            // 如果差值 < 2小时，就显示“1小时前”
            if absDiff < 2 * 3600 {
                return "1小时前"
            } else {
                let hour = absDiff / 3600
                return "\(hour)小时前"
            }
        } else {
            // 3.3.2 是否昨天
            //    iOS提供 isDateInYesterday，但同样依赖本地时区
            if localCalendar.isDateInYesterday(localEvent) {
                // “昨天xx:xx”，这里要把 eventDate 转成本地时区的 HH:mm
                // 只需用本地时区格式化即可
                let hourString = localEvent.toLocalString("HH:mm")
                return "昨天\(hourString)"
            }
        }
        
        // 不同日且不是昨天
        // 3.4 判断是否在 7 天内
        let dayCount = absDiff / (24 * 3600)
        if dayCount <= 7 {
            // 2-7天：x天前
            return "\(dayCount)天前"
        } else {
            // 3.5 更早，显示 yyyy-MM-dd (本地日期)
            return localEvent.toLocalString("yyyy-MM-dd")
        }
    }
    /// 根据服务器提供的事件时间 `timeStr` 与服务器当前时间 `nowTime`，
      /// 返回人性化的时间差描述，遵循以下逻辑：
      ///  - 1分钟内：刚刚
      ///  - 1分钟~59分钟：x分钟前
      ///  - 同一天内：x小时前（<2小时则显示 1小时前）
      ///  - 昨天：昨天 HH:mm
      ///  - 2~7天：x天前
      ///  - >=8天：YYYY年M月D日
      ///
      /// 特别处理：若本地时区已跨天数，但服务器时间还没跨（如差时区），
      /// 也能正确显示“2天前”或更多天数，绝不出现 0天前等错误。
      ///
      /// - Parameters:
      ///   - timeStr: 事件发生时间，格式 "yyyy-MM-dd HH:mm:ss"，实际 UTC+8
      ///   - nowTime: 服务器当前时间，同格式，同时区
      /// - Returns: 形如 "刚刚"、"35分钟前"、"1小时前"、"昨天 14:23"、"3天前"、"2024年12月15日"
      func changeTimeForShowNN(timeStr: String, nowTime: String) -> String {
          
          // 1. 用 DateFormatter 解析服务器时间（北京时间，UTC+8）
          let formatter = DateFormatter()
          formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
          formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
          formatter.calendar = Calendar(identifier: .gregorian)
          
          // 转为 Date
          guard let eventDate = formatter.date(from: timeStr),
                let serverNowDate = formatter.date(from: nowTime) else {
              return ""
          }
          
          // 2. 计算两者绝对秒数差
          let diff = serverNowDate.timeIntervalSince(eventDate)
          let absDiff = abs(diff)
          //[4]    (null)    "now" : "2025-04-11 11:57:50"
          //[2]    (null)    "ctime" : "2025-04-10T15:26:24"
          
          // 3. 用本地日历判断“自然天”差值
          //    如果 localEvent 与 localNow 差了 N 天，dayDiff 就是 N
//          let localCalendar = Calendar.current
          var localCalendar = Calendar(identifier: .gregorian)
          localCalendar.timeZone = TimeZone.current
          let dayDiff = dayDifferenceInLocalCalendar(from: eventDate, to: serverNowDate, calendar: localCalendar)
          
          // 4. 根据 dayDiff 先决定是否 “几天前” 或 “昨天” 等等
          //    若 dayDiff >= 8 => "YYYY年M月D日"
          if dayDiff >= 8 {
              return eventDate.formatLocal("yyyy年M月d日")
          } else if dayDiff >= 2 {
              // 2~7天：x天前
              return "\(dayDiff)天前"
          } else if dayDiff == 1 {
              // 昨天：昨天HH:mm
              let hhmm = eventDate.formatLocal("HH:mm")
              return "昨天 \(hhmm)"
          }
          
          // 5. 当 dayDiff == 0 => 表示本地时区内是“同一天”，再根据秒数决定
          //  1) 1分钟内：刚刚
          if absDiff < 60 {
              return "刚刚"
          }
          //  2) 1~59分钟：x分钟前
          if absDiff < 3600 {
              let minute = Int(absDiff / 60)
              return "\(minute)分钟前"
          }
          //  3) 今天内的“x小时前”，若 <2小时则显示1小时前
          if absDiff < 2 * 3600 {
              return "1小时前"
          } else {
              let hour = Int(absDiff / 3600)
              return "\(hour)小时前"
          }
      }
      
      /// 计算两个 Date 在“本地日历”下相差的自然天数：
      /// 例如：如果 from=4/10 22:00、to=4/11 01:00，但本地时区已变成 4/12，则 dayDiff=2。
      private func dayDifferenceInLocalCalendar(from: Date, to: Date, calendar: Calendar) -> Int {
          // 取日期部分（年、月、日）比较
          let fromDay = calendar.startOfDay(for: from)
          let toDay = calendar.startOfDay(for: to)
          // dayDiff = 多少天
          let component = calendar.dateComponents([.day], from: fromDay, to: toDay)
          return component.day ?? 0
      }
  }

  /// 让 Date 可以按本地时区输出字符串
  extension Date {
      /// 在本地时区下，以指定格式转换成字符串
      /// - e.g. "yyyy年M月d日"、"HH:mm"
      func formatLocal(_ format: String) -> String {
          let df = DateFormatter()
          df.dateFormat = format
          df.timeZone = TimeZone.current
          df.calendar = Calendar(identifier: .gregorian)
          return df.string(from: self)
      }

}

