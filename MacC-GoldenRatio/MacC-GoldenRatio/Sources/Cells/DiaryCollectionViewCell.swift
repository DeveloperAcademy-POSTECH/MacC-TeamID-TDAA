//
//  DiaryCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import UIKit

class DiaryCollectionViewCell: UICollectionViewCell {
	private lazy var titleLabel: UILabel = {
		let label =  UILabel()
		label.font = .systemFont(ofSize: 24.0, weight: .bold)
		label.textColor = .white
		
		return label
	}()
	
	func setup(imageViews: [UIImageView]) {
		setupSubViews()
		
		var trailing = 24.0
		
		imageViews.forEach {
			addSubview($0)
			$0.snp.makeConstraints {
				$0.width.height.equalTo(25)
				$0.trailing.equalToSuperview().inset(trailing)
				$0.bottom.equalToSuperview().inset(24.0)
				trailing += 25
			}
		}
		
//		imageView.snp.makeConstraints {
//			$0.width.height.equalTo(25)
//			$0.trailing.equalToSuperview().inset(24.0)
//			$0.bottom.equalToSuperview().inset(24.0)
//		}
		
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = 0.3
		layer.shadowRadius = 10
		
		titleLabel.text = "타이틀"
		
	}
}

private extension DiaryCollectionViewCell {
	func setupSubViews() {
		addSubview(titleLabel)
		
		titleLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(24.0)
			$0.trailing.equalToSuperview().inset(24.0)
			$0.top.equalToSuperview().inset(24.0)
		}
	}
}
