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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
    
    func setUI(image: UIImage) {
        imageView.image = image
    }
}
