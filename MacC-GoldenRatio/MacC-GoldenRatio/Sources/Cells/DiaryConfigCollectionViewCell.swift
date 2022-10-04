//
//  DiaryConfigViewCell.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/04.
//

import SnapKit
import UIKit

class DiaryConfigCollectionViewCell: UICollectionViewCell {
    private var contentType: ConfigContentType?
    private let device = UIScreen.getDevice()
    private var diary: Diary?
    
    
    private lazy var contentTitle: UILabel = {
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 22)
        return title
    }()

    private lazy var contentTextField: UITextField? = {
        let textField = UITextField()
        return textField
    }()
    
    private lazy var contentButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(contentButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        return button
    }()

    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        button.tintColor = .systemGray
        return button
    }()

    func setContent(indexPath: IndexPath, diary: Diary?) {
        contentType = ConfigContentType.allCases[indexPath.item]
        contentTitle.text = contentType?.title
        
        if let diary = diary {
            contentButton.tintColor = .black
            
            switch contentType {
            case .diaryName:
                contentButton.setTitle(diary.diaryName, for: .normal)
            case .location:
                contentButton.setTitle(diary.diaryLocation.locationName, for: .normal)
            case .diaryDate:
                contentButton.setTitle(diary.diaryStartDate.description, for: .normal)
            default:
                contentButton.tintColor = .systemGray
                contentButton.setTitle("PlaceHolder", for: .normal)
            }
            
        } else {
            contentButton.tintColor = .systemGray
            contentButton.setTitle("PlaceHolder", for: .normal)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = .darkGray
        
        contentView.addSubview(contentTitle)
        contentTitle.snp.makeConstraints {
            $0.left.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(10)
        }
        
        contentView.addSubview(contentButton)
        contentButton.snp.makeConstraints{
            $0.left.equalTo(contentTitle)
            $0.bottom.equalToSuperview().inset(10)
        }
        
        contentView.addSubview(clearButton)
        clearButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(10)
            $0.bottom.equalTo(contentButton)
        }
    }
    
    @objc func contentButtonTapped() {
        switch contentType {
        case .diaryName:
            print("TextField for Diary name Configuration")
        case .location:
            print("Map for Diary location Configuration")
        case .diaryDate:
            print("DatePicker for Diary date Configuration")
        case .none:
            print("You want New type?")
        }
    }
    
    @objc func clearButtonTapped() {
        contentButton.setTitle("PlaceHolder", for: .normal)
        contentButton.tintColor = .systemGray
    }
}

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
