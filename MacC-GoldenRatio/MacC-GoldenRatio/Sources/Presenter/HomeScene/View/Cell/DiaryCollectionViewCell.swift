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
	private var isAnimate: Bool = true
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.diaryTitleLabelFont
		label.textColor = UIColor.darkgrayColor
		return label
	}()
	
	private lazy var dateLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.diaryDateLabelFont
		label.textColor = UIColor.darkgrayColor
		return label
	}()
	
	private lazy var addressLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.diaryAddressLabelFont
		label.textColor = UIColor.darkgrayColor
		return label
	}()
	
	private lazy var cellCoverImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.maskedCorners = [.layerMaxXMaxYCorner]
		imageView.layer.cornerRadius = 10
		return imageView
	}()
	
	private lazy var cellImageView: UIImageView = {
		let imageView = UIImageView()
		return imageView
	}()
	
	lazy var removeButton: RemoveButton = {
		let button = RemoveButton()
		button.setImage(UIImage(systemName: "minus.circle.fill")?.withTintColor(UIColor.darkgrayColor, renderingMode: .alwaysOriginal), for: .normal)
		return button
	}()
	
	func setup(cellData: DiaryCell) {
		[cellImageView, cellCoverImageView, titleLabel, dateLabel, addressLabel, removeButton].forEach { self.addSubview($0) }
		
		cellImageView.image = UIImage(named: cellData.diaryCover)
		cellImageView.snp.makeConstraints {
			$0.top.leading.equalToSuperview().inset(10)
			$0.bottom.trailing.equalToSuperview()
		}
		
		cellData.diaryCoverImage == nil || cellData.diaryCoverImage == "" ? cellCoverImageView.image = UIImage(named: "defaultBottomcover") : cellCoverImageView.setImage(with: cellData.diaryCoverImage!)
		cellCoverImageView.snp.makeConstraints {
			$0.height.equalTo(116)
			$0.leading.equalToSuperview().inset(10)
			$0.bottom.trailing.equalToSuperview()
		}
		
		titleLabel.text = cellData.diaryName
		titleLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(myDevice.diaryCollectionViewCellTitleLabelTop)
			$0.leading.equalToSuperview().inset(30)
			$0.trailing.equalToSuperview().inset(20)
		}
		
		let day = Calendar.current.dateComponents([.day], from: cellData.diaryStartDate.toDate() ?? Date(), to: cellData.diaryEndDate.toDate() ?? Date()).day
		dateLabel.text = "\(cellData.diaryStartDate) (\((day ?? 0)+1)일)"
		dateLabel.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom)
			$0.leading.equalToSuperview().inset(30)
			$0.trailing.equalToSuperview().inset(20)
		}
		
		addressLabel.text = cellData.diaryLocation.locationName
		addressLabel.snp.makeConstraints {
			$0.top.equalTo(dateLabel.snp.bottom)
			$0.leading.equalToSuperview().inset(30)
			$0.trailing.equalToSuperview().inset(20)
		}
		
		removeButton.snp.makeConstraints {
			$0.top.leading.equalToSuperview()
		}
	}
	
	func startAnimate() {
		let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
		shakeAnimation.duration = 0.05
		shakeAnimation.repeatCount = 4
		shakeAnimation.autoreverses = true
		shakeAnimation.duration = 0.2
		shakeAnimation.repeatCount = 99999
		
		let startAngle: Float = (-2) * 0.005
		let stopAngle = -startAngle
		
		shakeAnimation.fromValue = NSNumber(value: startAngle as Float)
		shakeAnimation.toValue = NSNumber(value: 3 * stopAngle as Float)
		shakeAnimation.autoreverses = true
		shakeAnimation.timeOffset = 290 * drand48()
		
		let layer: CALayer = self.layer
		layer.add(shakeAnimation, forKey:"animate")
		removeButton.isHidden = false
		isAnimate = true
	}
	
	func stopAnimate() {
		let layer: CALayer = self.layer
		layer.removeAnimation(forKey: "animate")
		self.removeButton.isHidden = true
		isAnimate = false
	}
}
