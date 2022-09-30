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
				$0.width.height.equalTo(UIScreen.getDevice().diaryContributerImageViewSize)
				$0.trailing.equalToSuperview().inset(trailing)
				$0.bottom.equalToSuperview().inset(UIScreen.getDevice().diaryContributerImageViewBottomPadding)
				trailing += UIScreen.getDevice().diaryContributerImageViewSize-5
			}
		}
		
		titleLabel.text = title
		
	}
	
	private func setupSubViews() {
		addSubview(titleLabel)
		
		titleLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(UIScreen.getDevice().diaryCollectionViewCellTitleLabelLeadingInset)
			$0.trailing.equalToSuperview().inset(UIScreen.getDevice().diaryCollectionViewCellTitleLabelTrailingInset)
			$0.top.equalToSuperview().inset(UIScreen.getDevice().diaryCollectionViewCellTitleLabelTopInset)
		}
	}
}
