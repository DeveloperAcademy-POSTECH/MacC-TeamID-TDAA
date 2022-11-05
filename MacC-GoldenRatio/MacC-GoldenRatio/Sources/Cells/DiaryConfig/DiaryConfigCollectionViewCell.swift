//
//  DiaryConfigViewCell.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/04.
//

import RxSwift
import RxCocoa
import SnapKit
import UIKit

class DiaryConfigCollectionViewCell: UICollectionViewCell {
    private let device = UIScreen.getDevice()
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        attribute()
        layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var contentTitle: UILabel = {
        let title = UILabel()
        title.font = device.diaryConfigCellTitleFont
        title.textColor = .black
        return title
    }()
    
    lazy var titleInputField: UITextField? = {
        let textField = UITextField()
        textField.font = UIFont(name: "EF_Diary", size: 17)
        textField.returnKeyType = .done
        textField.placeholder = "다이어리 이름을 입력해주세요."
        textField.becomeFirstResponder()
        return textField
    }()
    
    lazy var contentButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = device.diaryConfigCellContentFont
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    var contentTap : Observable<Void>{
        return self.contentButton.rx.tap.asObservable()
    }
    
    lazy var clearButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "clearButton")
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.placeholderText
        return view
    }()
    
    func bind(_ viewModel: DiaryConfigCellViewModel) {
        
        viewModel.diaryData
            .subscribe(onNext: {
                viewModel.diary = $0
            })
            .disposed(by: disposeBag)
        
        viewModel.setContent
            .drive(onNext: { self.contentAttribute($0, diary: viewModel.diary) })
            .disposed(by: disposeBag)
        
        viewModel.resetContentLabel
            .subscribe(onNext: {
                if let _ = self.titleInputField {
                    viewModel.textFieldText
                        .accept(nil)
                }
                self.contentAttribute($0, diary: nil)
            })
            .disposed(by: disposeBag)
        
        titleInputField?.rx.text
            .bind(to: viewModel.textFieldText)
            .disposed(by: disposeBag)
        
        clearButton.rx.tap
            .bind(to: viewModel.clearButtonTapped)
            .disposed(by: disposeBag)
        
        contentButton.rx.tap
            .bind(to: viewModel.contentButtonTapped)
            .disposed(by: disposeBag)
    }
    
    
    func contentAttribute(_ contentType: ConfigContentType, diary: Diary?) {
        contentTitle.text = contentType.title
        
        var diaryName: String?
        var locationName: String
        var dateText: String
        
        if let diary = diary {
            let startDate = diary.diaryStartDate.toDate() ?? Date()
            let endDate = diary.diaryEndDate.toDate() ?? Date()
            contentButton.tintColor = .black
            
            diaryName = diary.diaryName
            locationName = diary.diaryLocation.locationName
            dateText = "\(startDate.customFormat()) (\(startDate.dayOfTheWeek())) - \(endDate.customFormat()) (\(endDate.dayOfTheWeek()))"
            
        } else {
            contentButton.tintColor = .placeholderText
            
            diaryName = nil
            locationName = "여행지를 입력해주세요."
            dateText = "여행한 날짜를 선택해주세요."
        }
        
        switch contentType {
        case .diaryName:
            contentButton.setTitle(nil, for: .normal)
            guard let titleInputField = titleInputField else { return }
            titleInputField.text = diaryName
            contentView.addSubview(titleInputField)
            
            titleInputField.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(device.diaryConfigCellLeftInset)
                $0.trailing.equalToSuperview().inset(50)
                $0.height.equalTo(44)
                $0.bottom.equalToSuperview()
            }
            
        case .location:
            contentButton.setTitle(locationName, for: .normal)
        case .diaryDate:
            contentButton.setTitle(dateText, for: .normal)
        }
    }
    
    private func attribute() {
        contentView.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [contentTitle, contentButton, clearButton, dividerView].forEach {
            contentView.addSubview($0)
        }
        
        contentTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(device.diaryConfigCellLeftInset+4)
            $0.bottom.equalTo(contentButton.snp.top)
        }
        
        contentButton.snp.makeConstraints{
            $0.leading.equalTo(dividerView)
            $0.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview()
        }
        
        clearButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(device.diaryConfigCellRightInset)
            $0.bottom.equalToSuperview().inset(device.diaryConfigCellBottomInset)
            $0.size.equalTo(CGSize(width: 17, height: 17))
        }
        
        dividerView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(device.diaryConfigCellLeftInset)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}

extension Reactive where Base: UIButton {
    public func title(for controlState: UIControl.State = []) -> Binder<String?> {
        return Binder(self.base) { button, title -> Void in
            button.setTitle(title, for: controlState)
        }
    }
}

