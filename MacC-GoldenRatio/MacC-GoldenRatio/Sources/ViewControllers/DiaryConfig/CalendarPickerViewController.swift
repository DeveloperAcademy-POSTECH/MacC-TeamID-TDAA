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
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissCalendar))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.addGestureRecognizer(tapGestureRecognizer)
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
            
            self.selectedDateChanged(self.dateInterval)
            self.dismissCalendar()
        })
    
    private lazy var closeButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "plusButton"), for: .normal) // TODO: 이미지 수정 필요
        button.addTarget(self, action: #selector(dismissCalendar), for: .touchUpInside)
        return button
    }()
    
    // MARK: Calendar Data Values
    
    private let selectedStartDate: Date
    
    private var startBaseDate: Date {
        didSet {
            days = generateDaysInMonth(for: startBaseDate)
            collectionView.reloadData()
            headerView.baseDate = startBaseDate
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
        collectionView.backgroundColor = .systemGroupedBackground
        
        [dimmedBackgroundView, collectionView, headerView, footerView, closeButton].forEach {
            view.addSubview($0)
        }
        
        dimmedBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.centerY.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.35)
        }
        
        headerView.snp.makeConstraints {
            $0.leading.trailing.equalTo(collectionView)
            $0.bottom.equalTo(collectionView.snp.top)
            $0.height.equalTo(80)
        }
        
        footerView.snp.makeConstraints {
            $0.leading.trailing.equalTo(collectionView)
            $0.top.equalTo(collectionView.snp.bottom)
            $0.height.equalTo(45)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(footerView.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        collectionView.register(CalendarDateCollectionViewCell.self, forCellWithReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        headerView.baseDate = startBaseDate
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
    }
    
    @objc private func dismissCalendar() {
        if dateInterval.count == 2 {
            self.dismiss(animated: true, completion: nil)
        } else {
            print("날짜를 2개 고르세요")
            // TODO: Toast View
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
        
        return Day(date: date, number: dateFormatter.string(from: date), isSelected: false, isWithinDisplayedMonth: isWithinDisplayedMonth)
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
        guard let date = cell.day?.date else { return cell }
        if dateInterval.contains(date) {
            cell.day?.isSelected = true
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
        let width = Int((collectionView.frame.width) / 7)
        let height = Int(collectionView.frame.height - 10) / numberOfWeeksInBaseDate
        return CGSize(width: width, height: height)
    }
    
    private func updateFooterButtonLabel(day: Day) {
        if dateInterval.count == 2 {
            dateInterval.removeAll()
        }
        dateInterval.append(day.date)
        
        switch dateInterval.count {
        case 1:
            let startDate = dateInterval[0]
            self.footerView.buttonLabel = "\(startDate.customFormat()) \(startDate.dayOfTheWeek()) 부터"
        case 2:
            let startDate = dateInterval[0]
            let endDate = dateInterval[1]
            let timeInterval = Int(endDate.timeIntervalSince(startDate)) / 86400
            if timeInterval < 0 {
                dateInterval.removeAll()
                return
            } else {
                self.footerView.buttonLabel = "\(startDate.customFormat()) \(startDate.dayOfTheWeek()) ~ \(endDate.customFormat()) \(endDate.dayOfTheWeek()) ∙ \(timeInterval)박"
            }
        default:
            self.footerView.buttonLabel = "날짜를 선택하세요"
        }
    }
}

