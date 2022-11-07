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
		label.textColor = UIColor.darkgrayColor
		
		return label
	}()
	
	private lazy var cellImageView: UIImageView = {
		let imageView =  UIImageView()
		
		return imageView
	}()
	
	func setup(cellData: DiaryCell) {
		[cellImageView, titleLabel].forEach { self.addSubview($0) }
		
		cellImageView.image = UIImage(named: cellData.diaryCover)
		cellImageView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		
		titleLabel.text = cellData.diaryName
		titleLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalToSuperview().inset(myDevice.diaryCollectionViewCellTitleLabelTop)
			$0.leading.trailing.equalToSuperview().inset(20)
		}
	}
}
