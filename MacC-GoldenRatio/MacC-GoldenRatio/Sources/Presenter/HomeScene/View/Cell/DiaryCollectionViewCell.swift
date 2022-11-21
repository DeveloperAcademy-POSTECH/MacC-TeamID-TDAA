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
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.maskedCorners = [.layerMaxXMaxYCorner]
		imageView.layer.cornerRadius = 10
		return imageView
	}()
	
	private lazy var cellImageView: UIImageView = {
		let imageView =  UIImageView()
		return imageView
	}()
	
	func setup(cellData: DiaryCell) {
		[cellImageView, cellCoverImageView, titleLabel, dateLabel, addressLabel].forEach { self.addSubview($0) }
		
		cellImageView.image = UIImage(named: cellData.diaryCover)
		cellImageView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		
		cellData.diaryCoverImage == nil || cellData.diaryCoverImage == "" ? cellCoverImageView.image = UIImage(named: "defaultBottomcover") : cellCoverImageView.setImage(with: cellData.diaryCoverImage!)
		cellCoverImageView.snp.makeConstraints {
			$0.height.equalTo(116)
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
