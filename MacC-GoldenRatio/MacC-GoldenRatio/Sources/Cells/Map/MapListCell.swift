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
	
	private lazy var lineView: UIView = {
		let view = UIView()
		view.backgroundColor = .placeholderText
		
		return view
	}()
	
	func setup(location: Location) {
		[titleLabel, categoryLabel, addressLabel, lineView].forEach { self.addSubview($0) }
		titleLabel.text = location.locationName
		titleLabel.snp.makeConstraints {
			$0.top.leading.trailing.equalTo(self.safeAreaLayoutGuide)
			$0.bottom.equalToSuperview().inset(80)
		}
		
		categoryLabel.text = "카테고리"
		categoryLabel.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).inset(3)
			$0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
		}
		
		addressLabel.text = location.locationAddress
		addressLabel.snp.makeConstraints {
			$0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
			$0.bottom.equalToSuperview().inset(20)
		}
		
		lineView.snp.makeConstraints {
			$0.height.equalTo(1)
			$0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
			$0.bottom.equalToSuperview()
		}
	}
}
