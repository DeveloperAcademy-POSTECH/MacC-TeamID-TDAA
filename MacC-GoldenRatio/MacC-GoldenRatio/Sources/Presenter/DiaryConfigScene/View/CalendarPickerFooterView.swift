//
//  CalendarPickerFooterView.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/06.
//
import SnapKit
import UIKit

class CalendarPickerFooterView: UIView {
    private var timeInterval: [Date] = []
    var buttonLabel: String = "LzCalendarSelectDate".localized {
        didSet {
            self.selectButton.setTitle(buttonLabel, for: .normal)
        }
    }
    
    lazy var selectButton: UIButton = {
        let button = UIButton()
        button.setTitle(buttonLabel, for: .normal)
        button.titleLabel?.font = UIFont(name: "EF_Diary", size: 14) ?? UIFont.systemFont(ofSize: 14)
        button.backgroundColor = .beige600
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let selectButtonCompletionHanlder: (() -> Void)
    
    init(timeInterval: [Date], selectButtonCompletionHanlder: @escaping (() -> Void)) {
        self.timeInterval = timeInterval
        self.selectButtonCompletionHanlder = selectButtonCompletionHanlder
        
        if timeInterval.isEmpty {
            self.buttonLabel = "LzCalendarSelectDate".localized
        } else {
            let startDate = timeInterval[0]
            let endDate = timeInterval[1]
            self.buttonLabel = "\(startDate.customFormat()) \(startDate.dayOfTheWeek())  - \(endDate.customFormat()) \(endDate.dayOfTheWeek())"
        }
        
        super.init(frame: CGRect.zero)
        
        backgroundColor = .systemGroupedBackground
        
        layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        self.addSubview(selectButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var previousOrientation: UIDeviceOrientation = UIDevice.current.orientation
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(40)
        }
    }
    
    @objc func selectButtonTapped() {
        self.selectButtonCompletionHanlder()
    }
    
}

