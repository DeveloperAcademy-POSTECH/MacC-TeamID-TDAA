//
//  CalendarPickerFooterView.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/06.
//
import SnapKit
import UIKit

class CalendarPickerFooterView: UIView {
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.label.withAlphaComponent(0.2)
        return view
    }()
    
    lazy var dateTypeSelector: UISegmentedControl = {
        let dateType = ["출발일", "도착일"]
        let sc = UISegmentedControl(items: dateType)
        sc.backgroundColor = UIColor.lightGray
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(controllerTapped), for: UIControl.Event.valueChanged)
        return sc
    }()
    
    let didTapStartDateCompletionHandler: (() -> Void)
    let didTapEndDateCompletionHandler: (() -> Void)
    
    init(
        didTapStartDateCompletionHandler: @escaping (() -> Void),
        didTapEndDateCompletionHandler: @escaping (() -> Void)
    ) {
        self.didTapStartDateCompletionHandler = didTapStartDateCompletionHandler
        self.didTapEndDateCompletionHandler = didTapEndDateCompletionHandler
        
        super.init(frame: CGRect.zero)
        
        backgroundColor = .systemGroupedBackground
        
        layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        [separatorView, dateTypeSelector].forEach {
            self.addSubview($0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var previousOrientation: UIDeviceOrientation = UIDevice.current.orientation
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        separatorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        dateTypeSelector.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.center.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.65)
        }
    }
    
    @objc func controllerTapped(_ controller: UISegmentedControl) {
        let switchIndex = controller.selectedSegmentIndex
        
        switch switchIndex {
        case 0:
            didTapStartDateCompletionHandler()
        case 1:
            didTapEndDateCompletionHandler()
        default:
            return
        }
    }
    
}

