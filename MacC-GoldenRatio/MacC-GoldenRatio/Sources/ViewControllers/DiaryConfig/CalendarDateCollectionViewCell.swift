//
//  CalendarDateCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/06.
//

import SnapKit
import UIKit

enum DateOption {
    case start, end, single, normal
}

class CalendarDateCollectionViewCell: UICollectionViewCell {
    private let device: UIScreen.DeviceSize = UIScreen.getDevice()
    var dateOption: DateOption = .normal
    
    lazy var selectionBackgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    lazy var termBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = device.calendarTermColor
        return view
    }()
    
    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = device.numberLabelFont
        return label
    }()
    
    lazy var marker: UIView = {
        let view = UIView()
        view.backgroundColor = device.calendarTermColor
        view.clipsToBounds = true
        return view
    }()
    
    lazy var accessibilityDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
        return dateFormatter
    }()
    
    static let reuseIdentifier = String(describing: CalendarDateCollectionViewCell.self)
    
    var day: Day? {
        didSet {
            guard let day = day else { return }
            
            numberLabel.text = day.number
            accessibilityLabel = accessibilityDateFormatter.string(from: day.date)
            updateSelectionStatus()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        [marker, termBackgroundView, selectionBackgroundView, numberLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        guard let day = day else { return }
        
        super.layoutSubviews()
        selectionBackgroundView.snp.removeConstraints()
        termBackgroundView.snp.removeConstraints()
        marker.snp.removeConstraints()
        
        let size = traitCollection.horizontalSizeClass == .compact ?
        min(min(frame.width, frame.height) - 10, 60) : 45
        
        numberLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        selectionBackgroundView.snp.makeConstraints {
            $0.center.equalTo(numberLabel)
            $0.size.equalTo(CGSize(width: size, height: size))
        }
        
        switch dateOption {
        case .single: // 날짜 1개 선택한 경우
            termBackgroundView.snp.removeConstraints()
            
        case .start: // 시작일 선택
            if day.date.dayOfTheWeek() == "토" {
                termBackgroundView.snp.removeConstraints()
            } else {
                termBackgroundView.snp.makeConstraints {
                    $0.leading.equalTo(numberLabel.snp.centerX).offset(2)
                    $0.top.equalTo(selectionBackgroundView.snp.top)
                    $0.width.equalTo(contentView.snp.width).dividedBy(device.calendarCellDivider)
                    $0.height.equalTo(selectionBackgroundView.snp.height)
                }
            }
            
        case .end: // 종료일 선택
            if day.date.dayOfTheWeek() == "일" {
                termBackgroundView.snp.removeConstraints()
            } else {
                termBackgroundView.snp.makeConstraints {
                    $0.trailing.equalTo(numberLabel.snp.centerX).offset(-2)
                    $0.top.equalTo(selectionBackgroundView.snp.top)
                    $0.width.equalTo(contentView.snp.width).dividedBy(device.calendarCellDivider)
                    $0.height.equalTo(selectionBackgroundView.snp.height)
                }
            }
            
        case .normal: // 시작일과 종료일을 제외한 중간 기간
            marker.snp.makeConstraints {
                $0.center.equalTo(numberLabel)
                $0.size.equalTo(CGSize(width: size, height: size))
            }
            
            if day.date.dayOfTheWeek() == "일" {
                termBackgroundView.snp.makeConstraints {
                    $0.leading.equalTo(numberLabel.snp.centerX).offset(2)
                    $0.top.equalTo(selectionBackgroundView.snp.top)
                    $0.width.equalTo(contentView.snp.width).dividedBy(device.calendarCellDivider)
                    $0.height.equalTo(selectionBackgroundView.snp.height)
                }
            } else if day.date.dayOfTheWeek() == "토" {
                termBackgroundView.snp.makeConstraints {
                    $0.trailing.equalTo(numberLabel.snp.centerX).offset(-2)
                    $0.top.equalTo(selectionBackgroundView.snp.top)
                    $0.width.equalTo(contentView.snp.width).dividedBy(device.calendarCellDivider)
                    $0.height.equalTo(selectionBackgroundView.snp.height)
                }
            } else {
                termBackgroundView.snp.makeConstraints {
                    $0.center.equalTo(numberLabel)
                    $0.width.equalTo(contentView.snp.width).multipliedBy(device.calendarCellMultiplier)
                    $0.height.equalTo(selectionBackgroundView.snp.height)
                }
            }
        }
        
        marker.layer.cornerRadius = size / 2
        selectionBackgroundView.layer.cornerRadius = size / 2
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        layoutSubviews()
    }
}

// MARK: - Appearance
extension CalendarDateCollectionViewCell {
    func updateSelectionStatus() {
        guard let day = day else { return }
        
        if day.isSelected {
            applySelectedStyle()
        } else {
            applyDefaultStyle(isWithinDisplayedMonth: day.isWithinDisplayedMonth)
        }
        
        if day.isInTerm {
            applyInTermStyle()
        }
    }

    var isSmallScreenSize: Bool {
        let isCompact = traitCollection.horizontalSizeClass == .compact
        let smallWidth = UIScreen.main.bounds.width <= 350
        let widthGreaterThanHeight = UIScreen.main.bounds.width > UIScreen.main.bounds.height
        
        return isCompact && (smallWidth || widthGreaterThanHeight)
    }
    
    func applySelectedStyle() {
        accessibilityTraits.insert(.selected)
        accessibilityHint = nil
        
        numberLabel.textColor = isSmallScreenSize ? .systemRed : .white
        selectionBackgroundView.isHidden = isSmallScreenSize
    }
    
    func applyInTermStyle() {
        accessibilityTraits.insert(.selected)
        accessibilityHint = nil
        
        marker.isHidden = isSmallScreenSize
        termBackgroundView.isHidden = isSmallScreenSize
    }
    
    func applyDefaultStyle(isWithinDisplayedMonth: Bool) {
        accessibilityTraits.remove(.selected)
        accessibilityHint = "Tap to select"
        
        numberLabel.textColor = isWithinDisplayedMonth ? .darkgrayColor : device.numberSubLabelColor
        
        marker.isHidden = true
        selectionBackgroundView.isHidden = true
        termBackgroundView.isHidden = true
    }
}

