//
//  MyAlbumPhotoCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/13.
//

import UIKit

class MyAlbumPhotoCollectionViewCell: UICollectionViewCell {
	private let myDevice = UIScreen.getDevice()
	private lazy var imageView: UIImageView = {
		let imageView =  UIImageView()
		
		return imageView
	}()
	
	func setup(imageURL: String) {
		self.addSubview(imageView)
		imageView.contentMode = .scaleAspectFit
		imageView.setImage(with: imageURL)
		imageView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		
	}
}
