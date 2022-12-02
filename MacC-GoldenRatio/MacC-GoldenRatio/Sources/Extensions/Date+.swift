//
//  Date+.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/06.
//

import UIKit

extension Date {
    func customFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    func dayOfTheWeek() -> String {
        let weekdays = ["LzCalendarSunday".localized, "LzCalendarMonday".localized, "LzCalendarTueday".localized, "LzCalendarWednesday".localized, "LzCalendarThursday".localized, "LzCalendarFriday".localized, "LzCalendarSaturday".localized]

        return weekdays[Calendar.current.component(.weekday, from: self) - 1]
    }
    
    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
    
    init(_ dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy/MM"
        dateStringFormatter.locale = Locale(identifier: "LzIdentifier".localized)
        let date = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:date)
    }
}
