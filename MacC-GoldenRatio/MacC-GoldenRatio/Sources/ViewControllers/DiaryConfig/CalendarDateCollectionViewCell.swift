//
//  CalendarDateCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/06.
//

import SnapKit
import UIKit

class CalendarDateCollectionViewCell: UICollectionViewCell {
    lazy var selectionBackgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .blue
        return view
    }()
    
    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .label
        return label
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
        
        [selectionBackgroundView, numberLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectionBackgroundView.snp.removeConstraints()

        let size = traitCollection.horizontalSizeClass == .compact ?
        min(min(frame.width, frame.height) - 10, 60) : 45
        
        numberLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        selectionBackgroundView.snp.makeConstraints {
            $0.center.equalTo(numberLabel)
            $0.size.equalTo(CGSize(width: size, height: size))
        }
        
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
    
    func applyDefaultStyle(isWithinDisplayedMonth: Bool) {
        accessibilityTraits.remove(.selected)
        accessibilityHint = "Tap to select"
        
        numberLabel.textColor = isWithinDisplayedMonth ? .label : .secondaryLabel
        selectionBackgroundView.isHidden = true
    }
}

