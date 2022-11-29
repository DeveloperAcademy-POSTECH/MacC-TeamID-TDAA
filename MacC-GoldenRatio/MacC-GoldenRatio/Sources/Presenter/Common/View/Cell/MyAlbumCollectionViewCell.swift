//
//  MyAlbumCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/13.
//

import SnapKit
import UIKit

class MyAlbumCollectionViewCell: UICollectionViewCell {
	private let myDevice = UIScreen.getDevice()
	lazy var imageView: UIImageView = {
		let imageView =  UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
		return imageView
	}()
	
	func setup(image: UIImage) {
		self.addSubview(imageView)
		imageView.image = image
		imageView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}
