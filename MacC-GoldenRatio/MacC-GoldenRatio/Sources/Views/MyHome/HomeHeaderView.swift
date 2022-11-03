//
//  DiaryCollectionHeaderView.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import UIKit
import SnapKit

final class HomeHeaderView: UIView {
	let myDevice = UIScreen.getDevice()
	
	private lazy var titleLabel: UILabel = {
		let label =  UILabel()
		label.text = "다이어리"
		label.font = myDevice.TabBarTitleFont
		label.textColor = UIColor.buttonColor
		
		return label
	}()
	
	func setupViews() {
		addSubview(titleLabel)
		
		titleLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(myDevice.TabBarTitleLabelLeading)
			$0.top.equalToSuperview().offset(myDevice.TabBarTitleLabelTop)
		}
	}
}
