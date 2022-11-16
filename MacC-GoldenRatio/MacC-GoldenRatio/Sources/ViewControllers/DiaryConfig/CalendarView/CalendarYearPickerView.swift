//
//  CalendarYearPickerView.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/16.
//

import UIKit

class CalendarYearPickerView: UIPickerView {
    
    var availableYear: [Int] = []
    var allMonth: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    var selectedYear = 0
    var selectedMonth = 0
    var todayYear = "0"
    var todayMonth = "0"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemGroupedBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAvailableDate(date: Date) {
        let formatterYear = DateFormatter()
        formatterYear.dateFormat = "yyyy"
        todayYear = formatterYear.string(from: date)
            
        for i in 1970...Int(todayYear)!+5 {
            availableYear.append(i)
        }
        
        let formatterMonth = DateFormatter()
        formatterMonth.dateFormat = "MM"
        todayMonth = formatterMonth.string(from: date)
            
        selectedYear = Int(todayYear)!
        selectedMonth = Int(todayMonth)!
        
        self.selectRow(selectedYear - 1970, inComponent: 0, animated: true)
        self.selectRow(selectedMonth - 1, inComponent: 1, animated: true)
    }
    
}
