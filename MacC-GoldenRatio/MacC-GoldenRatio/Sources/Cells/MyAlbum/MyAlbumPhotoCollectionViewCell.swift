//
//  MyAlbumPhotoCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/13.
//

import SnapKit
import UIKit

class MyAlbumPhotoCollectionViewCell: UICollectionViewCell {
	private lazy var scrollView: UIScrollView = {
		var scrollView = UIScrollView()
		scrollView.delegate = self
		scrollView.zoomScale = 1.0
		scrollView.minimumZoomScale = 1.0
		scrollView.maximumZoomScale = 5.0
		scrollView.bounces = false
		scrollView.showsVerticalScrollIndicator = false
		scrollView.showsHorizontalScrollIndicator = false
		return scrollView
	}()
	
	private lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	override func prepareForReuse() {
		self.scrollView.zoomScale = 1.0
		self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
	}
	
	func setup(image: UIImage) {
		self.addSubview(scrollView)
		scrollView.snp.makeConstraints {
			$0.top.bottom.equalTo(self.safeAreaLayoutGuide)
			$0.leading.trailing.equalToSuperview()
		}
		
		scrollView.addSubview(imageView)
		imageView.image = image
		imageView.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.width.equalToSuperview()
		}
	}
}

extension MyAlbumPhotoCollectionViewCell: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.zoomScale <= 1.0 {
			scrollView.zoomScale = 1.0
		}

		if scrollView.zoomScale >= 5.0 {
			scrollView.zoomScale = 5.0
		}
	}
}
