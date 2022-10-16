//
//  MyDiaryPagesViewCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/08.
//

import SnapKit
import UIKit

class MyDiaryPagesViewCollectionViewCell: UICollectionViewCell {
    
    lazy var previewImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "diaryInnerTexture") ?? UIImage()
        return imageView
    }()
    
    override func prepareForReuse() {
        self.previewImageView.image = UIImage(named: "diaryInnerTexture")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(previewImageView)
        previewImageView.snp.makeConstraints {
            $0.size.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
    }
    
}
