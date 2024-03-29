//
//  CalendarPickerViewController.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/06.
//

import SnapKit
import UIKit

class CalendarPickerViewController: UIViewController {
    var dateInterval: [Date]
    
    // MARK: Views
    private lazy var dimmedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var headerView = CalendarPickerHeaderView (
        didTapLastMonthCompletionHandler: { [weak self] in
            guard let self = self else { return }
            
            self.startBaseDate = self.calendar.date(byAdding: .month, value: -1, to: self.startBaseDate) ?? self.startBaseDate
        },
        didTapNextMonthCompletionHandler: { [weak self] in
            guard let self = self else { return }
            
            self.startBaseDate = self.calendar.date(byAdding: .month, value: 1, to: self.startBaseDate) ?? self.startBaseDate
        })
    
    lazy var footerView = CalendarPickerFooterView(timeInterval: dateInterval, selectButtonCompletionHanlder: { [weak self] in
        guard let self = self else { return }
        
        if self.monthPicker.isHidden == true {
            self.selectedDateChanged(self.dateInterval)
            self.dismissCalendar()
        } else {
            
            self.monthPicker.isHidden = true
            UIView.animate(withDuration: 0.2) {
                let scale = CGAffineTransform(rotationAngle: 0)
                self.headerView.monthPickerButton.imageView?.transform = scale
            }
            self.updateFooterButtonLabel(day: nil)
            self.collectionView.reloadData()
        }
    })
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 50)
        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: configuration), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(dismissCalendar), for: .touchUpInside)
        return button
    }()
    
    private let monthPicker = CalendarYearPickerView(frame: CGRect.zero)
    
    // MARK: Calendar Data Values
    
    private let selectedStartDate: Date
    
    private var startBaseDate: Date {
        didSet {
            days = generateDaysInMonth(for: startBaseDate)
            collectionView.reloadData()
            headerView.baseDate = startBaseDate
            monthPicker.setAvailableDate(date: startBaseDate)
        }
    }
    private var endBaseDate: Date? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private lazy var days = generateDaysInMonth(for: startBaseDate)
    
    private var numberOfWeeksInBaseDate: Int {
        calendar.range(of: .weekOfMonth, in: .month, for: startBaseDate)?.count ?? 0
    }
    
    private let selectedDateChanged: (([Date]) -> Void)
    private let calendar = Calendar(identifier: .gregorian)
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    // MARK: Initializers
    
    init(dateArray: [Date], selectedDateChanged: @escaping (([Date]) -> Void)) {
        self.dateInterval = dateArray
        
        if dateArray.isEmpty {
            self.selectedStartDate = Date()
            self.startBaseDate = Date()
        } else {
            self.selectedStartDate = dateArray[0]
            self.startBaseDate = dateArray[0]
        }
        self.selectedDateChanged = selectedDateChanged
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        definesPresentationContext = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attribute()
        layout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
    }
    
    private func attribute() {
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.register(CalendarDateCollectionViewCell.self, forCellWithReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        headerView.baseDate = startBaseDate
        headerView.monthPickerButton.addTarget(self, action: #selector(didTapMonthPickerButton), for: .touchUpInside)
        
        monthPicker.isHidden = true
        monthPicker.dataSource = self
        monthPicker.delegate = self
        monthPicker.setAvailableDate(date: startBaseDate)
        
        [dimmedBackgroundView, collectionView, headerView, footerView, closeButton, monthPicker].forEach {
            view.addSubview($0)
        }
    }
    
    private func layout() {
        dimmedBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Layout.calendarCollectionViewInset)
            $0.centerY.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(Layout.calendarCollectionViewMultiplier)
        }
        
        headerView.snp.makeConstraints {
            $0.leading.trailing.equalTo(collectionView)
            $0.bottom.equalTo(collectionView.snp.top)
            $0.height.equalTo(Layout.calendarHeaderHeight)
        }
        
        footerView.snp.makeConstraints {
            $0.leading.trailing.equalTo(collectionView)
            $0.top.equalTo(collectionView.snp.bottom)
            $0.height.equalTo(Layout.calendarFooterHeight)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(footerView.snp.bottom).offset(Layout.calendarCloseButtonTop)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(Layout.calendarCloseButtonSize)
        }
        
        monthPicker.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(-30)
            $0.centerX.equalTo(collectionView)
            $0.width.equalTo(collectionView).inset(10)
            $0.height.equalTo(collectionView).offset(20)
        }
    }
    
    @objc private func dismissCalendar() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapMonthPickerButton() {
        self.monthPicker.isHidden.toggle()
        
        if monthPicker.isHidden == true {
            collectionView.reloadData()
            self.footerView.buttonLabel = "LzCalendarSelectDate".localized
            self.footerView.selectButton.isEnabled = false
            UIView.animate(withDuration: 0.2) {
                let angle = CGAffineTransform(rotationAngle: 0)
                self.headerView.monthPickerButton.imageView?.transform = angle
                self.monthPicker.alpha = 0
            }
        } else {
            self.dateInterval.removeAll()
            self.footerView.buttonLabel = "LzConfirm".localized
            self.footerView.selectButton.isEnabled = true
            UIView.animate(withDuration: 0.2) {
                let angle = CGAffineTransform(rotationAngle: .pi/2)
                self.headerView.monthPickerButton.imageView?.transform = angle
                self.monthPicker.alpha = 1
            }
        }
    }
}

// MARK: - Day Generation
private extension CalendarPickerViewController {
    func monthMetadata(for startBaseDate: Date) throws -> MonthMetadata {
        guard
            let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: startBaseDate)?.count,
            let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: startBaseDate))
        else {
            throw CalendarDataError.metadataGeneration
        }
        
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        return MonthMetadata(numberOfDays: numberOfDaysInMonth, firstDay: firstDayOfMonth, firstDayWeekday: firstDayWeekday)
    }
    
    func generateDaysInMonth(for startBaseDate: Date) -> [Day] {
        guard let metadata = try? monthMetadata(for: startBaseDate) else {
            preconditionFailure("An error occurred when generating the metadata for \(startBaseDate)")
        }
        
        let numberOfDaysInMonth = metadata.numberOfDays
        let offsetInInitialRow = metadata.firstDayWeekday
        let firstDayOfMonth = metadata.firstDay
        
        var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
            .map { day in
                let isWithinDisplayedMonth = day >= offsetInInitialRow
                let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)
                
                return generateDay(offsetBy: dayOffset, for: firstDayOfMonth, isWithinDisplayedMonth: isWithinDisplayedMonth)
            }
        
        days += generateStartOfNextMonth(using: firstDayOfMonth)
        
        return days
    }
    
    func generateDay(offsetBy dayOffset: Int, for startBaseDate: Date, isWithinDisplayedMonth: Bool) -> Day {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: startBaseDate) ?? startBaseDate
        
        return Day(date: date, number: dateFormatter.string(from: date), isSelected: false, isInTerm: false, isWithinDisplayedMonth: isWithinDisplayedMonth)
    }
    
    func generateStartOfNextMonth(
        using firstDayOfDisplayedMonth: Date) -> [Day] {
            guard
                let lastDayInMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfDisplayedMonth)
            else {
                return []
            }
            
            let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
            guard additionalDays > 0 else {
                return []
            }
            
            let days: [Day] = (1...additionalDays)
                .map {
                    generateDay(offsetBy: $0, for: lastDayInMonth, isWithinDisplayedMonth: false)
                }
            
            return days
        }
    
    enum CalendarDataError: Error {
        case metadataGeneration
    }
}

// MARK: - UICollectionViewDataSource
extension CalendarPickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let day = days[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier, for: indexPath) as! CalendarDateCollectionViewCell
        
        cell.day = day
        cell.dateOption = .normal
        cell.day?.isInTerm = false
        cell.day?.isSelected = false
        
        guard let date = cell.day?.date else { return cell }
        
        if !dateInterval.isEmpty {
            let startDate = dateInterval[0]
            let endDate = dateInterval.last ?? dateInterval[0]
            let allDate = Date.dates(from: startDate, to: endDate)
            
            // 시작일, 종료일
            if dateInterval.contains(date) {
                cell.day?.isSelected = true
                cell.selectionBackgroundView.backgroundColor = (cell.day?.date == startDate ? .beige500 : .beige600)
            }
            
            // 시작일과 종료일을 포함한 기간
            if allDate.contains(date) {
                cell.day?.isInTerm = true
            }
            
            // 종료일 존재 여부에 대한 분기처리
            if startDate != endDate {
                switch cell.day?.date {
                case startDate:
                    cell.dateOption = .start
                case endDate:
                    cell.dateOption = .end
                default:
                    cell.dateOption = .normal
                }
            } else {
                cell.dateOption = .single
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = days[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier, for: indexPath) as! CalendarDateCollectionViewCell
        cell.day = day
        cell.updateSelectionStatus()
        collectionView.reloadData()
        updateFooterButtonLabel(day: day)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int((collectionView.frame.width - 50) / 7)
        let height = Int(collectionView.frame.height - 10) / numberOfWeeksInBaseDate
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    private func updateFooterButtonLabel(day: Day?) {
        if dateInterval.count == 2 {
            dateInterval.removeAll()
        }
        
        if let day = day {
            dateInterval.append(day.date)
        } else {
            dateInterval.removeAll()
        }
        
        switch dateInterval.count {
        case 1:
            self.footerView.selectButton.isEnabled = false
            let startDate = dateInterval[0]
            self.footerView.buttonLabel =  "LzCalendarFrom".localizedFormat("\(startDate.customFormat()) (\(startDate.dayOfTheWeek()))")
        case 2:
            self.footerView.selectButton.isEnabled = true
            let startDate = dateInterval[0]
            let endDate = dateInterval[1]
            let timeInterval = Int(endDate.timeIntervalSince(startDate)) / 86400
            if timeInterval < 0 {
                dateInterval.removeAll()
                return
            } else {
                if startDate == endDate {
                    self.footerView.buttonLabel = "\(startDate.customFormat()) (\(startDate.dayOfTheWeek()))" + "LzCalendarOneDay".localized
                } else {
                    self.footerView.buttonLabel = "\(startDate.customFormat()) (\(startDate.dayOfTheWeek())) ~ \(endDate.customFormat()) (\(endDate.dayOfTheWeek())) ∙ \(timeInterval+1)" + "LzCalendarDay".localized
                }
            }
        default:
            self.footerView.selectButton.isEnabled = false
            self.footerView.buttonLabel = "LzCalendarSelectDate".localized
        }
    }
}

extension CalendarPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let pickerView = pickerView as? CalendarYearPickerView else { return 0 }
        
        switch component {
        case 0:
            return pickerView.availableYear.count
        case 1:
            return pickerView.allMonth.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        guard let pickerView = pickerView as? CalendarYearPickerView else { return nil }
        
        switch component {
        case 0:
            return "\(pickerView.availableYear[row])" + "LzCalendarYear".localized
        case 1:
            return "\(pickerView.allMonth[row])" + "LzCalendarMonth".localized
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        guard let pickerView = pickerView as? CalendarYearPickerView else { return }
        
        switch component {
        case 0:
            pickerView.selectedYear = pickerView.availableYear[row]
            
        case 1:
            pickerView.selectedMonth = pickerView.allMonth[row]
        default:
            break
        }
        
        startBaseDate = Date("\(pickerView.selectedYear)/\(pickerView.selectedMonth)")
    }
}

