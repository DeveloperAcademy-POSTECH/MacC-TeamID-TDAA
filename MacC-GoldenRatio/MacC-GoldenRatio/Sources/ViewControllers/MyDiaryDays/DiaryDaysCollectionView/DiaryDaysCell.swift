//
//  DiaryDaysCell.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/10.
//

import RxSwift
import RxCocoa
import SnapKit
import UIKit

class DiaryDaysCell: UICollectionViewCell {
    let identifier = "DiaryDaysCell"
    let disposeBag = DisposeBag()
    let cellViewModel = DiaryDaysCellViewModel()
    
    let backImageView = UIImageView()
    let dayLabel = UILabel()
    let dateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute() {
        contentView.backgroundColor = UIColor.separatorColor2

        backImageView.contentMode = .scaleAspectFill
        backImageView.clipsToBounds = true
        
        dayLabel.textColor = .white
        dayLabel.font = UIFont.dayLabelFont
        dayLabel.backgroundColor = .clear
        
        dateLabel.textColor = .white
        dateLabel.font = UIFont.labelTitleFont
        dateLabel.backgroundColor = .clear
        
        [backImageView, dayLabel, dateLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func layout() {
        backImageView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.center.equalToSuperview()
            $0.bottom.equalToSuperview().inset(1)
        }
        
        dayLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(30)
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(dayLabel)
            $0.top.equalTo(dayLabel.snp.bottom).offset(20)
        }
    }
}
