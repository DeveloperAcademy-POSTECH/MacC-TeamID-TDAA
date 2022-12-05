//
//  FilterButton.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/25.
//

import UIKit

final class FilterButton: UIButton {
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.titleLabel?.font = .caption1
		self.layer.borderColor = UIColor.beige600.cgColor
		self.layer.borderWidth = 1
		self.layer.cornerRadius = 13
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
