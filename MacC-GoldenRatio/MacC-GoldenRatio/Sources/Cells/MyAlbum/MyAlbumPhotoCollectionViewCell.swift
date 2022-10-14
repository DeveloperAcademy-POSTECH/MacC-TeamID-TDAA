//
//  MyAlbumPhotoCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/13.
//

import SnapKit
import UIKit

class MyAlbumPhotoCollectionViewCell: UICollectionViewCell {
	private let myDevice = UIScreen.getDevice()
	private lazy var imageView: UIImageView = {
		let imageView =  UIImageView()
		
		return imageView
	}()
	
	func setup(image: UIImage) {
		self.addSubview(imageView)
		imageView.contentMode = .scaleAspectFit
		imageView.image = image
		imageView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		
	}
}
