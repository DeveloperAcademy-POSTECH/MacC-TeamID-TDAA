//
//  CalendarPickerFooterView.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/06.
//
import SnapKit
import UIKit

class CalendarPickerFooterView: UIView {
    var buttonLabel: String = "날짜를 선택하세요" {
        didSet {
            self.selectButton.setTitle(buttonLabel, for: .normal)
        }
    }
    
    private lazy var selectButton: UIButton = {
        let button = UIButton()
        button.setTitle("날짜를 선택하세요", for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let selectButtonCompletionHanlder: (() -> Void)
    
    init(selectButtonCompletionHanlder: @escaping (() -> Void)) {
        self.selectButtonCompletionHanlder = selectButtonCompletionHanlder
        
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
            $0.center.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.65)
        }
    }
    
    @objc func selectButtonTapped() {
        self.selectButtonCompletionHanlder()
    }
    
}

