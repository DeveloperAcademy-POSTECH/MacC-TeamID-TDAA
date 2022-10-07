//
//  MyDiaryPagesViewCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/08.
//

import UIKit

class MyDiaryPagesViewCollectionViewCell: UICollectionViewCell {
    private lazy var previewImage: UIImage = {
        let image = UIImage()
        return image
    }()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = .clear
    }
    
    func setup(imageURL: URL?) {
        if let _ = imageURL {
            print("Image Show")
        } else {
            previewImage = UIImage(named: "FireSticker") ?? UIImage()
        }
    }
}
