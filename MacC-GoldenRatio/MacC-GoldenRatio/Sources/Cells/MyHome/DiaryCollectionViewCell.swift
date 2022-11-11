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
		label.font = UIFont.diaryTitleLabelFont
		label.textColor = UIColor.darkgrayColor
		return label
	}()
	
	private lazy var dateLabel: UILabel = {
		let label =  UILabel()
		label.font = UIFont.diaryDateLabelFont
		label.textColor = UIColor.darkgrayColor
		return label
	}()
	
	private lazy var addressLabel: UILabel = {
		let label =  UILabel()
		label.font = UIFont.diaryAddressLabelFont
		label.textColor = UIColor.darkgrayColor
		return label
	}()
	
	private lazy var cellCoverImageView: UIImageView = {
		let imageView =  UIImageView()
		return imageView
	}()
	
	private lazy var cellImageView: UIImageView = {
		let imageView =  UIImageView()
		return imageView
	}()
	
	func setup(cellData: DiaryCell) {
		[cellCoverImageView, cellImageView, titleLabel, dateLabel, addressLabel].forEach { self.addSubview($0) }
		
		cellCoverImageView.image = UIImage(named: cellData.diaryCover)
		cellCoverImageView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		
//		cellData.diaryCoverImage != nil ? cellCoverImageView.image = UIImage(named: "defaultBottomcover") : cellCoverImageView.setImage(with: cellData.diaryCoverImage!)
		cellImageView.image = UIImage(named: "defaultBottomcover") ?? UIImage()
		cellImageView.snp.makeConstraints {
			$0.height.equalTo(110)
			$0.bottom.leading.trailing.equalToSuperview()
		}
		
		titleLabel.text = cellData.diaryName
		titleLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalToSuperview().inset(myDevice.diaryCollectionViewCellTitleLabelTop)
			$0.leading.trailing.equalToSuperview().inset(20)
		}
		
		let day = Calendar.current.dateComponents([.day], from: cellData.diaryStartDate.toDate() ?? Date(), to: cellData.diaryEndDate.toDate() ?? Date()).day
		dateLabel.text = "\(cellData.diaryStartDate) (\((day ?? 0)+1)일)"
		dateLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(titleLabel.snp.bottom)
			$0.leading.trailing.equalToSuperview().inset(20)
		}
		
		addressLabel.text = cellData.diaryLocation.locationName
		addressLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(dateLabel.snp.bottom)
			$0.leading.trailing.equalToSuperview().inset(20)
		}
	}
}
