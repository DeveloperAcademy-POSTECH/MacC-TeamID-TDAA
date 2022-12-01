//
//  TravelsCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/14.
//

import UIKit

class TravelsCollectionViewCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .subheadline2
        label.textColor = .buttonColor
        label.textAlignment = .center
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.addSubview(imageView)
        imageView.addSubview(locationLabel)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        locationLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.imageView.image = UIImage()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func setUI(image: UIImage, location: String) {
        imageView.image = image
        locationLabel.text = location
    }
}
