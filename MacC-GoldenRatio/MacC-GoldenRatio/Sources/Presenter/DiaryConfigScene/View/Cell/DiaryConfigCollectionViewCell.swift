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
        title.font = .body
        title.textColor = .black
        return title
    }()
    
    lazy var titleInputField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "EF_Diary", size: 17)
        textField.returnKeyType = .done
        textField.placeholder = "LzDiaryConfigNamePlaceholder".localized
        textField.becomeFirstResponder()
        return textField
    }()
    
    lazy var contentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .body
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    lazy var contentTap : Observable<Void> = {
        return self.contentButton.rx.tap.asObservable()
    }()
    
    lazy var clearButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "clearButton")
        button.setImage(image, for: .normal)
        return button
    }()
    
    lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.placeholderText
        return view
    }()
    
    lazy var diaryColorCollectionView: DiaryColorCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 32, height: 32)
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.minimumLineSpacing = 20
        let collectionView = DiaryColorCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(DiaryColorCell.self, forCellWithReuseIdentifier: "DiaryColorCell")
        return collectionView
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
                viewModel.textFieldText.accept(nil)
                self.contentAttribute($0, diary: nil)
            })
            .disposed(by: disposeBag)
        
        titleInputField.rx.text
            .bind(to: viewModel.textFieldText)
            .disposed(by: disposeBag)
        
        clearButton.rx.tap
            .bind(to: viewModel.clearButtonTapped)
            .disposed(by: disposeBag)
        
        contentButton.rx.tap
            .bind(to: viewModel.contentButtonTapped)
            .disposed(by: disposeBag)
        
        diaryColorCollectionView.bind(viewModel.diaryColorViewModel)
    }
    
    
    func contentAttribute(_ contentType: ConfigContentType, diary: Diary?) {
        let attributedString = NSMutableAttributedString(string: contentType.title)
        attributedString.setColor(color: UIColor.requiredItemsColor, forText: "*")
        contentTitle.attributedText = attributedString
        
        var diaryName: String?
        var locationName: String
        var dateText: String
        if let diary = diary {
            let startDate = diary.diaryStartDate.toDate() ?? Date()
            let endDate = diary.diaryEndDate.toDate() ?? Date()
            contentButton.setTitleColor(.black, for: .normal)
            
            diaryName = diary.diaryName
            locationName = diary.diaryLocation.locationName
            dateText = "\(startDate.customFormat()) (\(startDate.dayOfTheWeek())) - \(endDate.customFormat()) (\(endDate.dayOfTheWeek()))"
        } else {
            contentButton.setTitleColor(.placeholderText, for: .normal)
            diaryName = nil
            locationName = "LzDiaryConfigLocationPlaceholder".localized
            dateText = "LzDiaryConfigDatePlaceholder".localized
        }
        
        switch contentType {
        case .diaryName:
            contentButton.isHidden = true
            titleInputField.text = diaryName
            contentView.addSubview(titleInputField)
            titleInputField.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(Layout.diaryConfigCellLeftInset)
                $0.trailing.equalToSuperview().inset(50)
                $0.height.equalTo(44)
                $0.bottom.equalToSuperview()
            }
            
        case .location:
            contentButton.setTitle(locationName, for: .normal)
            contentView.addSubview(contentButton)
            contentButton.snp.makeConstraints{
                $0.leading.equalTo(dividerView)
                $0.trailing.equalToSuperview().inset(50)
                $0.height.equalTo(44)
                $0.bottom.equalToSuperview()
            }
            
        case .diaryDate:
            contentButton.setTitle(dateText, for: .normal)
            contentView.addSubview(contentButton)
            contentButton.snp.makeConstraints{
                $0.leading.equalTo(dividerView)
                $0.trailing.equalToSuperview().inset(50)
                $0.height.equalTo(44)
                $0.bottom.equalToSuperview()
            }
            
        case .diaryColor:
            contentButton.isHidden = true
            clearButton.isHidden = true
            dividerView.isHidden = true
            contentView.addSubview(diaryColorCollectionView)
            diaryColorCollectionView.snp.makeConstraints {
                $0.top.equalTo(contentTitle.snp.bottom).offset(20)
                $0.leading.equalToSuperview().inset(20)
                $0.width.equalTo(241)
                $0.height.equalTo(84)
            }
            
        case .diaryImage:
            clearButton.isHidden = true
            dividerView.isHidden = true
            contentButton.backgroundColor = .clear
            contentButton.layer.cornerRadius = 20
            contentView.addSubview(contentButton)
            contentButton.snp.makeConstraints {
                $0.leading.equalTo(dividerView)
                $0.height.equalTo(170)
                $0.width.equalTo(242)
                $0.top.equalTo(contentTitle.snp.bottom).offset(10)
            }
        }
    }
    
    private func attribute() {
        contentView.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [contentTitle, clearButton, dividerView].forEach {
            contentView.addSubview($0)
        }
        
        contentTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Layout.diaryConfigCellLeftInset+4)
            $0.top.equalToSuperview().inset(20)
        }
        
        clearButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(Layout.diaryConfigCellRightInset)
            $0.bottom.equalToSuperview().inset(Layout.diaryConfigCellBottomInset)
            $0.size.equalTo(CGSize(width: 17, height: 17))
        }
        
        dividerView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(Layout.diaryConfigCellLeftInset)
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
