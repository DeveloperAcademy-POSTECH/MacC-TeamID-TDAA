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
	
	private lazy var imageView: UIImageView = {
		let imageView =  UIImageView()
		imageView.image = UIImage(systemName: "person.circle") ?? UIImage()
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	private lazy var categoryLabel: UILabel = {
		let label =  UILabel()
		label.font = UIFont(name: "EF_Diary", size: 15)
		label.textColor = .gray
		return label
	}()
	
	private lazy var addressLabel: UILabel = {
		let label =  UILabel()
		label.font = UIFont(name: "EF_Diary", size: 17)
		label.textColor = .gray
		label.numberOfLines = 2
		return label
	}()
	
	func setup(location: Location) {
		self.layer.borderColor = UIColor.red.cgColor
		self.layer.borderWidth = 1
		[titleLabel, imageView, categoryLabel, addressLabel].forEach { self.addSubview($0) }
		titleLabel.text = location.locationName
		titleLabel.textAlignment = .center
		titleLabel.snp.makeConstraints {
			$0.top.equalTo(self.safeAreaLayoutGuide)
			$0.leading.equalTo(imageView.snp.trailing).offset(15)
		}
		
		imageView.snp.makeConstraints {
			$0.size.equalTo(80)
			$0.leading.equalTo(self.safeAreaLayoutGuide)
			$0.centerY.equalTo(self.safeAreaLayoutGuide)
		}
		
		categoryLabel.text = location.locationName
		categoryLabel.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).inset(5)
			$0.leading.equalTo(imageView.snp.trailing).offset(15)
		}
		
		addressLabel.text = location.locationAddress
		addressLabel.snp.makeConstraints {
			$0.top.equalTo(categoryLabel.snp.bottom).offset(5)
			$0.leading.equalTo(imageView.snp.trailing).offset(15)
			$0.trailing.equalTo(self.safeAreaLayoutGuide)
			$0.bottom.equalTo(self.safeAreaLayoutGuide)
		}
	}
}
