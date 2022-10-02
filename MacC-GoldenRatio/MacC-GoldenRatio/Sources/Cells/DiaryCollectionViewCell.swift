//
//  DiaryCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import UIKit

class DiaryCollectionViewCell: UICollectionViewCell {
	private let myDevice = UIScreen.getDevice()
	private lazy var titleLabel: UILabel = {
		let label =  UILabel()
		label.font = .systemFont(ofSize: 24.0, weight: .bold)
		label.textColor = .black
		
		return label
	}()
	
	func setup(title: String, imageViews: [UIImageView]) {
		addSubview(titleLabel)
		titleLabel.text = title
		titleLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(myDevice.diaryCollectionViewCellTitleLabelLeading)
			$0.trailing.equalToSuperview().inset(myDevice.diaryCollectionViewCellTitleLabelTrailing)
			$0.top.equalToSuperview().inset(myDevice.diaryCollectionViewCellTitleLabelTop)
		}
		
		var trailing = myDevice.diaryContributerImageViewTrailing
		imageViews.forEach {
			addSubview($0)
			$0.snp.makeConstraints {
				$0.width.height.equalTo(myDevice.diaryContributerImageViewSize)
				$0.trailing.equalToSuperview().inset(trailing)
				$0.bottom.equalToSuperview().inset(myDevice.diaryContributerImageViewBottom)
				trailing += myDevice.diaryContributerImageViewSize-5
			}
		}
	}
}
