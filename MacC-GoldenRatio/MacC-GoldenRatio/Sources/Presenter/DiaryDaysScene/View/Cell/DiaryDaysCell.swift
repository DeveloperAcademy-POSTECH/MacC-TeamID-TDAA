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
    let disposeBag = DisposeBag()
    
    let backImageView = UIImageView()
    let gradientLayer = CAGradientLayer()
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
        contentView.backgroundColor = UIColor.gray300
        
        backImageView.contentMode = .scaleAspectFill
        backImageView.clipsToBounds = true
        
        gradientLayer.colors = [
            UIColor.gradientColor(alpha: 1.0).cgColor,
            UIColor.gradientColor(alpha: 0.5).cgColor,
            UIColor.gradientColor(alpha: 0.0).cgColor
        ]
        gradientLayer.locations = [0, 0.31, 0.73]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.73)
        gradientLayer.bounds = contentView.bounds
        gradientLayer.position = contentView.center
        
        dayLabel.textColor = .white
        dayLabel.font = UIFont.title2
        dayLabel.backgroundColor = .clear
        
        dateLabel.textColor = .white
        dateLabel.font = UIFont.title4
        dateLabel.backgroundColor = .clear
        
        contentView.addSubview(backImageView)
        contentView.layer.addSublayer(gradientLayer)
        contentView.addSubview(dayLabel)
        contentView.addSubview(dateLabel)
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
