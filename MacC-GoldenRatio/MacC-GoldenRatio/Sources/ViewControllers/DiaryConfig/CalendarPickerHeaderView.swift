//
//  CalendarPickerHeaderView.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/06.
//

import SnapKit
import UIKit

class CalendarPickerHeaderView: UIView {
    lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.text = "Month"
        label.accessibilityTraits = .header
        label.isAccessibilityElement = true
        return label
    }()
    
    lazy var previousMonthButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        
        button.addTarget(self, action: #selector(didTapPreviousMonthButton), for: .touchUpInside)
        return button
    }()
    
    lazy var nextMonthButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .black
        
        button.addTarget(self, action: #selector(didTapNextMonthButton), for: .touchUpInside)
        return button
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        
        button.tintColor = .secondaryLabel
        button.contentMode = .scaleAspectFill
        button.isUserInteractionEnabled = true
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Close Picker"
        return button
    }()
    
    lazy var dayOfWeekStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.label.withAlphaComponent(0.2)
        return view
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM y")
        return dateFormatter
    }()
    
    var baseDate = Date() {
        didSet {
            monthLabel.text = dateFormatter.string(from: baseDate)
        }
    }
    
    let didTapLastMonthCompletionHandler: (() -> Void)
    let didTapNextMonthCompletionHandler: (() -> Void)
    var exitButtonTappedCompletionHandler: (() -> Void)
    
    init(didTapLastMonthCompletionHandler: @escaping (() -> Void),
         didTapNextMonthCompletionHandler: @escaping (() -> Void),
         exitButtonTappedCompletionHandler: @escaping (() -> Void)) {
        self.didTapLastMonthCompletionHandler = didTapLastMonthCompletionHandler
        self.didTapNextMonthCompletionHandler = didTapNextMonthCompletionHandler
        self.exitButtonTappedCompletionHandler = exitButtonTappedCompletionHandler
        
        super.init(frame: CGRect.zero)
        
        backgroundColor = .systemGroupedBackground
        
        layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15

        [monthLabel, previousMonthButton, nextMonthButton, closeButton, dayOfWeekStackView, separatorView].forEach {
            self.addSubview($0)
        }
        
        for dayNumber in 1...7 {
            let dayLabel = UILabel()
            dayLabel.font = .systemFont(ofSize: 12, weight: .bold)
            dayLabel.textColor = .secondaryLabel
            dayLabel.textAlignment = .center
            dayLabel.text = dayOfWeekLetter(for: dayNumber)
            dayLabel.isAccessibilityElement = false
            dayOfWeekStackView.addArrangedSubview(dayLabel)
        }
        
        closeButton.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func dayOfWeekLetter(for dayNumber: Int) -> String {
        switch dayNumber {
        case 1:
            return "SUN"
        case 2:
            return "MON"
        case 3:
            return "TUE"
        case 4:
            return "WED"
        case 5:
            return "THU"
        case 6:
            return "FRI"
        case 7:
            return "SAT"
        default:
            return ""
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        monthLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15)
            $0.leading.equalToSuperview().inset(15)
        }
        
        previousMonthButton.snp.makeConstraints {
            $0.centerY.equalTo(monthLabel)
            $0.trailing.equalTo(nextMonthButton.snp.leading).offset(-30)
        }
        
        nextMonthButton.snp.makeConstraints {
            $0.centerY.equalTo(monthLabel)
            $0.trailing.equalTo(closeButton.snp.leading).offset(-20)
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(monthLabel)
            $0.size.equalTo(CGSize(width: 28, height: 28))
            $0.trailing.equalToSuperview().inset(15)
        }
        
        dayOfWeekStackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(separatorView.snp.bottom).inset(5)
        }
    
        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    @objc func didTapPreviousMonthButton() {
        didTapLastMonthCompletionHandler()
    }
    
    @objc func didTapNextMonthButton() {
        didTapNextMonthCompletionHandler()
    }
    
    @objc func didTapExitButton() {
        exitButtonTappedCompletionHandler()
    }
}

