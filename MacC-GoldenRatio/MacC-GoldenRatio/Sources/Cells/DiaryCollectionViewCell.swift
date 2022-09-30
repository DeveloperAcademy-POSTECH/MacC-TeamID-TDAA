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
		label.textColor = .black
		
		return label
	}()
	
	func setup(title: String, imageViews: [UIImageView]) {
		setupSubViews()
		
		var trailing = UIScreen.getDevice().diaryContributerImageViewTrailingPadding
		
		imageViews.forEach {
			addSubview($0)
			$0.snp.makeConstraints {
				$0.width.height.equalTo(25)
				$0.trailing.equalToSuperview().inset(trailing)
				$0.bottom.equalToSuperview().inset(UIScreen.getDevice().diaryContributerImageViewBottomPadding)
				trailing += 26
			}
		}
		
		titleLabel.text = title
		
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
