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
        viewModel.previewData
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { data in
                self.dayLabel.text = data.dayLabel
                self.dateLabel.text = data.dateLabel
                self.backImageView.image = data.image
            })
            .disposed(by: disposeBag)
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
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-40, height: 170)
        
        dayLabel.textColor = .white
        dayLabel.font = UIFont.title3
        dayLabel.backgroundColor = .clear
        
        dateLabel.textColor = .white
        dateLabel.font = UIFont.headline
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
            $0.bottom.equalToSuperview()
        }
        
        dayLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.top.equalToSuperview().inset(25)
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(dayLabel)
            $0.top.equalTo(dayLabel.snp.bottom).offset(15)
        }
    }
}
