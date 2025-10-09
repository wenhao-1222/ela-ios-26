//
//  NaturalUtil.swift
//  lns
//
//  Created by LNS2 on 2024/9/9.
//

import Foundation

class NaturalUtil {
    //MARK: 根据开始 结束日期，获取所有日期数组
    func getDaysSourceArray(startDate:String,endDate:String) -> NSArray{
        let resultsArray = NSMutableArray()
        
//        for i in 0..<100{
//            let date = Date().nextDay(days: i, baseDate: startDate)
//            resultsArray.add(date)
//            if date == endDate{
//                break
//            }
//        }
        let start = Date().changeDateStringToDate(dateString: startDate)
        let end = Date().changeDateStringToDate(dateString: endDate)
        let dayDiff = start.daysBetweenDate(toDate: end)

        if dayDiff >= 0 {
            for i in 0...dayDiff {
                let date = Date().nextDay(days: i, baseDate: startDate)
                resultsArray.add(date)
            }
        }
        
        return resultsArray
    }
    //MARK: 未来一周的日期
    func getDateNextWeekDaysArray() -> NSArray{
        let resultsArray = NSMutableArray()
        
        for i in 0..<7{
            let date = Date().nextDay(days: i)
            resultsArray.add(date)
        }
        
        return resultsArray
    }
    //MARK: 近一周的日期
    func getDateLastWeekDaysArray() -> NSArray{
        let resultsArray = NSMutableArray()
        
        for i in -6..<1{
            let date = Date().nextDay(days: i)
            resultsArray.add(date)
        }
        
        return resultsArray
    }
    //MARK: 近一个月的日期
    func getDateLastMonthDaysArray() -> NSArray {
        let calendar = Calendar.init(identifier: .gregorian)
        
        let now = Date()
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now)
        let oneMonthAgoTimeStamp = CLongLong(round((oneMonthAgo?.timeIntervalSince1970 ?? 0)*1000)) + 24*60*60*1000
        
        let startDate = Date().timeIntervalChangeToTimeStr(timeInterval: TimeInterval(oneMonthAgoTimeStamp), dateFormat: nil)
        
        let resultsArray = NSMutableArray()
        
        for i in 0..<31{
            let date = Date().nextDay(days: -i)
            resultsArray.add(date)
            if date == startDate{
                break
            }
        }
        
        return resultsArray.reversed() as NSArray
    }
    //MARK: 获取近半年/近一年的日期数组
    func getLasYearDaysArray(isHalfYear:Bool? = false) -> NSArray {
        let resultsArray = NSMutableArray()
        
        let calendar = Calendar.current
        let now = Date()
        
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-M"
        formatter.calendar = Calendar.init(identifier: .gregorian)
        formatter.locale = Locale.init(identifier: "en_US_POSIX")
        let lastMonth = isHalfYear! ? 6 : 12
        for i in 0..<lastMonth{
            let oneMonthAgo = calendar.date(byAdding: .month, value: -i, to: now)
            let monthString = formatter.string(from: (oneMonthAgo ?? Date()) as Date)
            
            let monthArr = monthString.components(separatedBy: "-")
            let dict = ["year":monthArr[0],
                        "month":monthArr[1]]
            resultsArray.add(dict)
        }
        DLLog(message: "getLasYearDaysArray:\(resultsArray)")
        return resultsArray.reversed() as NSArray
    }
    //MARK: 获取2021年到今后三年的日期
    func getNext3YearsArray() -> NSArray {
        let calendar = Calendar.current
        let now = Date()
        let oneMonthAgo = calendar.date(byAdding: .year, value: 3, to: now)
        
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-M"
        formatter.calendar = Calendar.init(identifier: .gregorian)
        formatter.locale = Locale.init(identifier: "en_US_POSIX")
        let monthString = formatter.string(from: (oneMonthAgo ?? Date()) as Date)
        let monthArr = monthString.components(separatedBy: "-")
        
        let maxYearString = monthArr[0]
        let maxYear = Int(maxYearString) ?? 2027
        
        let resultsArray = NSMutableArray()
        for i in 2021...maxYear{
            resultsArray.add("\(i)")
        }
        
        return resultsArray
    }
    //MARK: 获取某年某月的天数
    func getDaysInMonth( year: Int, month: Int) -> Int
    {
        let calendar = NSCalendar.current
        
        let startComps = NSDateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
         
        let endComps = NSDateComponents()
        endComps.day = 1
        endComps.month = month == 12 ? 1 : month + 1
        endComps.year = month == 12 ? year + 1 : year
         
        let startDate = calendar.date(from: startComps as DateComponents)
        let endDate = calendar.date(from: endComps as DateComponents)
        
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd"
        let startString = formatter.string(from: startDate ?? Date())
        let endString = formatter.string(from: endDate ?? Date())
//        DLLog(message: "getDaysInMonth:\(month)月：\(startString) --- \(endString)")
        
        var dayNum = 28
        for i in 0..<32{
            let dayStr = Date().nextDay(days: i, baseDate: startString)
            if dayStr == endString{
                dayNum = i
            }
        }
        
        return dayNum
    }
}

