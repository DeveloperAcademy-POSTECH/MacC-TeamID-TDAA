//
//  DiaryCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import RxCocoa
import RxSwift
import Kingfisher
import UIKit

class DiaryCollectionViewCell: UICollectionViewCell {
	private let disposeBag = DisposeBag()
	private var isAnimate: Bool = true
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.title4
		label.textColor = UIColor.gray500
		return label
	}()
	
	private lazy var dateLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.caption3
		label.textColor = UIColor.gray500
		return label
	}()
	
	private lazy var addressLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.caption4
		label.textColor = UIColor.gray500
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
		button.setImage(UIImage(named: "minusButton"), for: .normal)
		return button
	}()
	
	lazy var blurButton: UIButton = {
		let button = UIButton()
		return button
	}()
	
	func bind(viewModel: DiaryCollectionViewModel) {
		removeButton.rx.tap
			.map {
				return self.removeButton.diaryCell
			}
			.bind(to: viewModel.removeData)
			.disposed(by: disposeBag)
	}
	
	func setup(cellData: DiaryCell) {
		[cellImageView, cellCoverImageView, titleLabel, dateLabel, addressLabel, blurButton, removeButton].forEach { self.addSubview($0) }
		
		cellImageView.image = UIImage(named: cellData.diaryCover)
		cellImageView.snp.makeConstraints {
			$0.top.leading.trailing.equalToSuperview().inset(10)
			$0.bottom.equalToSuperview()
		}
		
		cellData.diaryCoverImage == nil || cellData.diaryCoverImage == "" ? cellCoverImageView.image = UIImage(named: "defaultBottomcover") : cellCoverImageView.setImage(with: cellData.diaryCoverImage!)
		cellCoverImageView.snp.makeConstraints {
			$0.height.equalTo(116)
			$0.leading.trailing.equalToSuperview().inset(10)
			$0.bottom.equalToSuperview()
		}
		
		titleLabel.text = cellData.diaryName
		titleLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(Layout.diaryCollectionViewCellTitleLabelTop)
			$0.leading.trailing.equalToSuperview().inset(30)
		}
		
		let day = Calendar.current.dateComponents([.day], from: cellData.diaryStartDate.toDate() ?? Date(), to: cellData.diaryEndDate.toDate() ?? Date()).day
        dateLabel.text = "\(cellData.diaryStartDate) (\((day ?? 0)+1)\(day == 0 ? "LzHomeDay".localized : "LzHomeDays".localized))"
		dateLabel.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom)
			$0.leading.trailing.equalToSuperview().inset(30)
		}
		
		addressLabel.text = cellData.diaryLocation.locationName
		addressLabel.snp.makeConstraints {
			$0.top.equalTo(dateLabel.snp.bottom)
			$0.leading.trailing.equalToSuperview().inset(30)
		}
		
		removeButton.snp.makeConstraints {
			$0.width.height.equalTo(18)
			$0.top.leading.equalToSuperview().inset(3)
		}
		
		blurButton.snp.makeConstraints {
			$0.edges.equalToSuperview()
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
		blurButton.isHidden = false
		isAnimate = true
	}
	
	func stopAnimate() {
		let layer: CALayer = self.layer
		layer.removeAnimation(forKey: "animate")
		removeButton.isHidden = true
		blurButton.isHidden = true
		isAnimate = false
	}
}
