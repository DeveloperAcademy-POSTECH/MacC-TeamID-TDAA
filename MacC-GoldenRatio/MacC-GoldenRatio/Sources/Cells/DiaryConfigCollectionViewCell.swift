//
//  DiaryConfigViewCell.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/04.
//

import SnapKit
import UIKit

enum ConfigContentType: CaseIterable { // allCases 사용을 위한 CaseIterable
    case diaryName
    case location
    case diaryDate
    
    var title: String {
        switch self {
        case .diaryName:
            return "다이어리 이름"
        case .location:
            return "여행지"
        case .diaryDate:
            return "날짜"
        }
    }
}

class DiaryConfigCollectionViewCell: UICollectionViewCell {
    private var contentType: ConfigContentType?
    private let device = UIScreen.getDevice()
    private var diary: Diary?
    
    
    private lazy var contentTitle: UILabel = {
        let title = UILabel()
        title.font = device.diaryConfigCellTitleFont
        return title
    }()

    lazy var contentTextField: UITextField? = {
        let textField = UITextField()
        textField.placeholder = "PlaceHolder"
        textField.font = UIFont(name: "EF_Diary", size: 17)
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()
    
    lazy var contentButton: UIButton? = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = device.diaryConfigCellContentFont
        return button
    }()

    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        button.tintColor = .systemGray
        return button
    }()
    
    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.placeholderText
        return view
    }()

    // CollectionView에서 Cell초기화 담당
    func setContent(indexPath: IndexPath, diary: Diary?) {
        contentType = ConfigContentType.allCases[indexPath.row]
        contentTitle.text = contentType?.title
        
        if let diary = diary {
            let startDate = diary.diaryStartDate.toDate() ?? Date()
            let endDate = diary.diaryEndDate.toDate() ?? Date()
            contentButton?.tintColor = .black
            
            switch contentType {
            case .diaryName:
                // contentTextField?.text = diary.diaryName
                contentButton?.setTitle(diary.diaryName, for: .normal)
            case .location:
                contentButton?.setTitle(diary.diaryLocation.locationName, for: .normal)
            case .diaryDate:
                contentButton?.setTitle("\(startDate.customFormat()) \(startDate.dayOfTheWeek())  - \(endDate.customFormat()) \(endDate.dayOfTheWeek())", for: .normal)
            default:
                contentButton?.tintColor = .placeholderText
                contentButton?.setTitle("PlaceHolder", for: .normal)
            }
        } else {
            contentButton?.tintColor = .placeholderText
            contentButton?.setTitle("PlaceHolder", for: .normal)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = .clear
        
        [contentTitle, clearButton, dividerView].forEach {
            contentView.addSubview($0)
        }

        contentTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(device.diaryConfigCellLeftInset)
            $0.top.equalToSuperview().inset(device.diaryConfigCellTopInset)
        }
        
        clearButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(device.diaryConfigCellRightInset)
            $0.bottom.equalToSuperview().inset(device.diaryConfigCellBottomInset)
        }
        
        dividerView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        switch contentType {
        case .diaryName:
            contentView.addSubview(contentButton ?? UIButton())
            contentButton?.snp.makeConstraints{
                $0.leading.equalTo(contentTitle)
                $0.height.equalTo(44)
                $0.bottom.equalToSuperview()
            }
        case .diaryDate, .location:
            contentView.addSubview(contentButton ?? UIButton())
            contentButton?.snp.makeConstraints{
                $0.leading.equalTo(contentTitle)
                $0.height.equalTo(44)
                $0.bottom.equalToSuperview()
            }
        case .none:
            print("Ther will be no Content Type")
        }
    }
    
    @objc func clearButtonTapped() {
        UIView.performWithoutAnimation {
            contentTextField?.text = nil
            contentButton?.setTitle("PlaceHolder", for: .normal)
            contentButton?.tintColor = .placeholderText
        }
    }
}

extension DiaryConfigCollectionViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
}
