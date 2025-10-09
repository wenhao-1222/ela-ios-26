//
//  Widget+Date+Exs.swift
//  lns
//
//  Created by LNS2 on 2024/8/22.
//

import Foundation


extension Date{
//    第一次刷新时间：延迟2秒刷
    static func getFirstEntryDate() -> Date {
        let offsetSecond: TimeInterval = TimeInterval(1)
        var currentDate = Date()
        currentDate += offsetSecond
        return currentDate
    }

    // 获取第一个分钟时间点所处的时间点
    static func getFirstMinuteEntryDate() -> Date {
        var currentDate = Date()
        let passSecond = Calendar.current.component(.second, from: currentDate)
        let offsetSecond: TimeInterval = TimeInterval(60 - passSecond)
        currentDate += offsetSecond
        return currentDate
    }
    // 获取第一个整点时间点所处的时间点
    static func getFirstHourEntryDate() -> Date {
        var currentDate = Date()
        let passSecond = Calendar.current.component(.hour, from: currentDate)
        let offsetSecond: TimeInterval = TimeInterval(3600 - passSecond)
        currentDate += offsetSecond
        
        return currentDate
    }
    
    static func getZeroDate() -> Date{
        // 获取当前日期
        var dateComponents = DateComponents()
        dateComponents.hour = (dateComponents.hour ?? -1) + 1
        dateComponents.minute = 0
        dateComponents.second = 0
         
        // 设置时区，默认是当前设备时区
        let timeZone = TimeZone.current
        dateComponents.timeZone = timeZone
         
        // 转换为Date
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
         
        
        return date
    }
    
    var currentDayzeroOfDate:NSDate{
        let calendar:NSCalendar = NSCalendar.current as NSCalendar
        //calendar.components(NSCalendarUnit(), fromDate: self)//UIntMax
        
        let unitFlags: NSCalendar.Unit = [
            
            NSCalendar.Unit.year,
            NSCalendar.Unit.month,
            NSCalendar.Unit.day,
            .hour,
            .minute,
            .second ]
        
        //calendar.components(unitFlags, fromDate: self)//解析当前的时间 返回NSDateComponents 解析后的数据后面设置解析后的时间在反转
        var components = calendar.components(unitFlags, from: self)//NSDateComponents() 不初始化, 直接返回解析的时间
        
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        components.timeZone = .current
        components.calendar = Calendar.init(identifier: .gregorian)
//        print(" 2  \(components.year)  \(components.month)  \(components.day) \( components.hour)")
        let date = calendar.date(from: components)

        return date! as NSDate
    }
    
    // 获取当前日期的第一个整点时间
    func getFirstHourOfCurrentDate(minute:Int) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        // 获取当前时间的日期组件
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: now)
        // 设置整点时间的分钟和秒为0
        components.minute = minute
        components.second = 0
        
//        components.timeZone = TimeZone.current
        components.calendar?.locale = Locale.current//Locale.init(identifier: "zh_Hans_CN")
        components.timeZone = TimeZone.current//TimeZone(secondsFromGMT: 0)
//        components.locale = Locale.init(identifier: "zh_Hans_CN")
        
        // 使用日期组件创建整点时间的Date对象
        return calendar.date(from: components)
    }
}
