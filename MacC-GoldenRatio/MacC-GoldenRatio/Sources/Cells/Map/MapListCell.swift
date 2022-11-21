//
//  MapListCell.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/09.
//
import SnapKit
import UIKit

class MapListCell: UICollectionViewCell {
	private let myDevice = UIScreen.getDevice()
	private lazy var titleLabel: UILabel = {
		let label =  UILabel()
		label.font = UIFont(name: "EF_Diary", size: 22)
		label.textColor = .black
		return label
	}()
	
	private lazy var categoryImageView: UIImageView = {
		let imageView =  UIImageView()
		return imageView
	}()
	
	private lazy var categoryLabel: UILabel = {
		let label =  UILabel()
		label.font = UIFont(name: "EF_Diary", size: 15)
		label.textColor = .separatorColor
		return label
	}()
	
	private lazy var addressLabel: UILabel = {
		let label =  UILabel()
		label.font = UIFont(name: "EF_Diary", size: 17)
		label.textColor = .separatorColor2
		label.numberOfLines = 2
		return label
	}()
	
	private lazy var lineView: UIView = {
		let view = UIView()
		view.backgroundColor = .placeholderText
		
		return view
	}()
	
	func setup(location: Location) {
		[titleLabel, categoryImageView, categoryLabel, addressLabel, lineView].forEach { self.addSubview($0) }
		
		let category = MapCategory(rawValue: location.locationCategory ?? "")?.category
		
		categoryImageView.image = UIImage(named: category?.imageName ?? "defaultIcon")
		categoryImageView.snp.makeConstraints {
			$0.width.height.equalTo(101)
			$0.top.equalToSuperview().inset(20)
			$0.leading.equalToSuperview()
		}
		
		titleLabel.text = location.locationName
		titleLabel.snp.makeConstraints {
			$0.height.equalTo(22)
			$0.top.equalToSuperview().inset(20)
			$0.trailing.equalTo(self.safeAreaLayoutGuide)
			$0.leading.equalTo(categoryImageView.snp.trailing).offset(15)
		}
		
		categoryLabel.text = category?.category ?? ""
		categoryLabel.snp.makeConstraints {
			$0.height.equalTo(15)
			$0.top.equalTo(titleLabel.snp.bottom).offset(10)
			$0.trailing.equalTo(self.safeAreaLayoutGuide)
			$0.leading.equalTo(categoryImageView.snp.trailing).offset(15)
		}
		
		addressLabel.text = location.locationAddress
		addressLabel.sizeToFit()
		addressLabel.snp.makeConstraints {
			$0.trailing.equalTo(self.safeAreaLayoutGuide)
			$0.top.equalTo(categoryLabel.snp.bottom).offset(10)
			$0.leading.equalTo(categoryImageView.snp.trailing).offset(15)
		}
		
		lineView.snp.makeConstraints {
			$0.height.equalTo(1)
			$0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
			$0.bottom.equalToSuperview()
		}
	}
}
