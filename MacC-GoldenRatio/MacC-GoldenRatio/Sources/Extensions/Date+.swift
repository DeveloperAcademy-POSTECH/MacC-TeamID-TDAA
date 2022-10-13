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
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

        return weekdays[Calendar.current.component(.weekday, from: self) - 1]
    }
}
