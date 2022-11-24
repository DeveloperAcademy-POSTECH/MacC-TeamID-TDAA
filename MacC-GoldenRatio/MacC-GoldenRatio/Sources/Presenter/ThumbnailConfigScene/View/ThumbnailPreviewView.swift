//
//  ThumbnailPreviewView.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/24.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class ThumbnailPreviewView: UIView {
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
    
    func bind(_ viewModel: ThumbnailPreviewViewModel) {
        
    }
    
    private func attribute() {
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
        gradientLayer.bounds = self.bounds
        gradientLayer.position = self.center
        
        dayLabel.textColor = .white
        dayLabel.font = UIFont.dayLabelFont
        dayLabel.backgroundColor = .clear
        
        dateLabel.textColor = .white
        dateLabel.font = UIFont.labelTitleFont
        dateLabel.backgroundColor = .clear
        
        self.addSubview(backImageView)
        self.layer.addSublayer(gradientLayer)
        self.addSubview(dayLabel)
        self.addSubview(dateLabel)
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
