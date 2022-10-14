//
//  MyAlbumTitleCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/13.
//

import SnapKit
import UIKit

class MyAlbumTitleCollectionViewCell: UICollectionViewCell {
	private let myDevice = UIScreen.getDevice()
	private lazy var titleLabel: UILabel = {
		let label =  UILabel()
		label.font = UIFont(name: "EF_Diary", size: 20)
		label.textColor = .black
		return label
	}()
	
	func setup(title: String) {
		self.addSubview(titleLabel)
		titleLabel.text = title
		titleLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalToSuperview().inset(myDevice.diaryCollectionViewCellTitleLabelTop)
			$0.leading.trailing.equalToSuperview()
		}
		
	}
}
