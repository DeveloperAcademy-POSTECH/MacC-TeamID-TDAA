//
//  CalendarPickerFooterView.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/06.
//
import SnapKit
import UIKit

class CalendarPickerFooterView: UIView {
    
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.label.withAlphaComponent(0.2)
        return view
    }()
    
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
        
        [separatorView, selectButton].forEach {
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

