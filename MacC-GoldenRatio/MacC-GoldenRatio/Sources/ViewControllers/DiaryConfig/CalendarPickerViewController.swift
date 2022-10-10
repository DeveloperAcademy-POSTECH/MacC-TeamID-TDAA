//
//  CalendarPickerViewController.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/06.
//

import SnapKit
import UIKit

class CalendarPickerViewController: UIViewController {
    // MARK: Views
    private lazy var dimmedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
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
        
        self.baseDate = self.calendar.date(
            byAdding: .month,
            value: -1,
            to: self.baseDate
        ) ?? self.baseDate
    },
    didTapNextMonthCompletionHandler: { [weak self] in
        guard let self = self else { return }
        
        self.baseDate = self.calendar.date(
            byAdding: .month,
            value: 1,
            to: self.baseDate
        ) ?? self.baseDate
    },
    exitButtonTappedCompletionHandler: { [weak self] in
        guard let self = self else { return }
        self.dismiss(animated: true)
    })
    
    private lazy var footerView = CalendarPickerFooterView(
        didTapStartDateCompletionHandler: { [weak self] in
            guard let self = self else { return }
            
            print("Select Start Date")
        },
        didTapEndDateCompletionHandler: { [weak self] in
            guard let self = self else { return }
            
            print("Select End Date")
        })
    
    // MARK: Calendar Data Values
    
    private let selectedDate: Date
    private var baseDate: Date {
        didSet {
            days = generateDaysInMonth(for: baseDate)
            collectionView.reloadData()
            headerView.baseDate = baseDate
        }
    }
    
    
    private lazy var days = generateDaysInMonth(for: baseDate)
    
    private var numberOfWeeksInBaseDate: Int {
        calendar.range(of: .weekOfMonth, in: .month, for: baseDate)?.count ?? 0
    }
    
    private let selectedDateChanged: ((Date) -> Void)
    private let calendar = Calendar(identifier: .gregorian)
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    // MARK: Initializers
    
    init(baseDate: Date, selectedDateChanged: @escaping ((Date) -> Void)) {
        self.selectedDate = baseDate
        self.baseDate = baseDate
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
        
        [dimmedBackgroundView, collectionView, headerView, footerView].forEach {
            view.addSubview($0)
        }
        
        dimmedBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
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
            $0.height.equalTo(55)
        }
        
        collectionView.register(
            CalendarDateCollectionViewCell.self,
            forCellWithReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        headerView.baseDate = baseDate
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
    }
}

// MARK: - Day Generation
private extension CalendarPickerViewController {
    func monthMetadata(for baseDate: Date) throws -> MonthMetadata {
        guard
            let numberOfDaysInMonth = calendar.range(
                of: .day,
                in: .month,
                for: baseDate)?.count,
            let firstDayOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: baseDate))
        else {
            throw CalendarDataError.metadataGeneration
        }
        
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        return MonthMetadata(
            numberOfDays: numberOfDaysInMonth,
            firstDay: firstDayOfMonth,
            firstDayWeekday: firstDayWeekday)
    }
    
    // 1
    func generateDaysInMonth(for baseDate: Date) -> [Day] {
        guard let metadata = try? monthMetadata(for: baseDate) else {
            preconditionFailure("An error occurred when generating the metadata for \(baseDate)")
        }
        
        let numberOfDaysInMonth = metadata.numberOfDays
        let offsetInInitialRow = metadata.firstDayWeekday
        let firstDayOfMonth = metadata.firstDay
        
        var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
            .map { day in
                let isWithinDisplayedMonth = day >= offsetInInitialRow
                let dayOffset =
                isWithinDisplayedMonth ?
                day - offsetInInitialRow :
                -(offsetInInitialRow - day)
                
                return generateDay(
                    offsetBy: dayOffset,
                    for: firstDayOfMonth,
                    isWithinDisplayedMonth: isWithinDisplayedMonth)
            }
        
        days += generateStartOfNextMonth(using: firstDayOfMonth)
        
        return days
    }
    
    func generateDay(
        offsetBy dayOffset: Int,
        for baseDate: Date,
        isWithinDisplayedMonth: Bool
    ) -> Day {
        let date = calendar.date(
            byAdding: .day,
            value: dayOffset,
            to: baseDate)
        ?? baseDate
        
        return Day(
            date: date,
            number: dateFormatter.string(from: date),
            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
            isWithinDisplayedMonth: isWithinDisplayedMonth
        )
    }

    func generateStartOfNextMonth(
        using firstDayOfDisplayedMonth: Date
    ) -> [Day] {
        guard
            let lastDayInMonth = calendar.date(
                byAdding: DateComponents(month: 1, day: -1),
                to: firstDayOfDisplayedMonth)
        else {
            return []
        }
        
        let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
        guard additionalDays > 0 else {
            return []
        }

        let days: [Day] = (1...additionalDays)
            .map {
                generateDay(
                    offsetBy: $0,
                    for: lastDayInMonth,
                    isWithinDisplayedMonth: false)
            }
        
        return days
    }
    
    enum CalendarDataError: Error {
        case metadataGeneration
    }
}

// MARK: - UICollectionViewDataSource
extension CalendarPickerViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        days.count
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let day = days[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier,
            for: indexPath) as! CalendarDateCollectionViewCell
        
        cell.day = day
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let day = days[indexPath.row]
        selectedDateChanged(day.date)
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = Int(collectionView.frame.width / 7)
        let height = Int(collectionView.frame.height) / numberOfWeeksInBaseDate
        return CGSize(width: width, height: height)
    }
}

