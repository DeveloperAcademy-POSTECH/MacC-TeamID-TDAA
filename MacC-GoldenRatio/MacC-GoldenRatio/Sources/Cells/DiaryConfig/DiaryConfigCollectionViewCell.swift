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
        title.textColor = .black
        return title
    }()
    
    lazy var contentButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = device.diaryConfigCellContentFont
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
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
            contentButton.tintColor = .black
            
            switch contentType {
            case .diaryName:
                contentButton.setTitle(nil, for: .normal)
            case .location:
                contentButton.setTitle(diary.diaryLocation.locationName, for: .normal)
            case .diaryDate:
                contentButton.setTitle("\(startDate.customFormat()) (\(startDate.dayOfTheWeek()))  - \(endDate.customFormat()) (\(endDate.dayOfTheWeek()))", for: .normal)
            default:
                contentButton.tintColor = .placeholderText
                contentButton.setTitle("PlaceHolder", for: .normal)
            }
        } else {
            switch contentType {
            case .diaryName:
                contentButton.setTitle(nil, for: .normal)
            case .location:
                contentButton.tintColor = .placeholderText
                contentButton.setTitle("여행지를 입력해주세요.", for: .normal)
            case .diaryDate:
                contentButton.tintColor = .placeholderText
                contentButton.setTitle("여행한 날짜를 선택해주세요.", for: .normal)
            default:
                contentButton.setTitle(nil, for: .normal)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = .clear
        
        [contentTitle, contentButton, dividerView, clearButton].forEach {
            contentView.addSubview($0)
        }
        
        contentTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(device.diaryConfigCellLeftInset+4)
            $0.bottom.equalTo(contentButton.snp.top)
        }
        
        clearButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(device.diaryConfigCellRightInset)
            $0.bottom.equalToSuperview().inset(device.diaryConfigCellBottomInset)
        }
        
        dividerView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(device.diaryConfigCellLeftInset)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        contentButton.snp.makeConstraints{
            $0.leading.equalTo(dividerView)
            $0.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview()
        }
    }
}
