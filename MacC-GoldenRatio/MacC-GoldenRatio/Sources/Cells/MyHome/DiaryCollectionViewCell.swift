//
//  DiaryCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import Combine
import Kingfisher
import UIKit

class DiaryCollectionViewCell: UICollectionViewCell {
	private let myDevice = UIScreen.getDevice()
	private lazy var titleLabel: UILabel = {
		let label =  UILabel()
		label.textAlignment = .center
		label.font = myDevice.diaryCollectionViewCellTitleLabelFont
		label.textColor = .black
		
		return label
	}()
	
	private lazy var cellImageView: UIImageView = {
		let imageView =  UIImageView()
		
		return imageView
	}()
	
	func setup(cellData: DiaryCell) {
		cellImageView.image = UIImage(named: cellData.diaryCover)
		addSubview(cellImageView)
		cellImageView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		
		addSubview(titleLabel)
		titleLabel.text = cellData.diaryName
		titleLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalToSuperview().inset(myDevice.diaryCollectionViewCellTitleLabelTop)
			$0.leading.trailing.equalToSuperview().inset(20)
		}

		var trailing = myDevice.diaryContributerImageViewTrailing
		
		for (index, url) in cellData.userImageURLs.enumerated() {
			if cellData.userImageURLs.count > 3 && index == 0 {
				let label = UILabel()
				label.text = "+\(cellData.userImageURLs.count-3)"
				label.font = UIFont.systemFont(ofSize: 10)
				addSubview(label)
				label.snp.makeConstraints {
					$0.width.height.equalTo(myDevice.diaryContributerImageViewSize)
					$0.trailing.equalToSuperview().inset(trailing-8)
					$0.bottom.equalToSuperview().inset(myDevice.diaryContributerImageViewBottom)
					trailing += myDevice.diaryContributerImageViewSize-5
				}
			} else if index <= 3 {
				let imageView = UIImageView()
				imageView.setImage(with: url)
				imageView.contentMode = .scaleToFill
				imageView.clipsToBounds = true
				imageView.layer.cornerRadius = 12.5
				imageView.layer.borderWidth = 0.2
				imageView.layer.borderColor = UIColor.gray.cgColor
				imageView.backgroundColor = .white
				addSubview(imageView)
				imageView.snp.makeConstraints {
					$0.width.height.equalTo(myDevice.diaryContributerImageViewSize)
					$0.trailing.equalToSuperview().inset(trailing)
					$0.bottom.equalToSuperview().inset(myDevice.diaryContributerImageViewBottom)
					trailing += myDevice.diaryContributerImageViewSize-5
				}
			} else {
				break
			}
		}
	}
}
