//
//  MyAlbumTitleCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/13.
//

import SnapKit
import UIKit

class MyAlbumTitleCollectionViewCell: UICollectionViewCell {
	var isFirstCell = false
	private let myDevice = UIScreen.getDevice()
	private lazy var titleLabel: UILabel = {
		let label =  UILabel()
		label.font = UIFont(name: "EF_Diary", size: 20)
		label.textColor = .black
		return label
	}()
	
	private lazy var lineView: UIView = {
		let view =  UIView()
		view.frame = CGRect(origin: .zero, size: CGSize(width: self.bounds.width, height: 0.1))
		view.backgroundColor = .black
		return view
	}()
	
	override var isSelected: Bool {
		didSet{
			if isSelected {
				lineView.isHidden = false
			} else {
				lineView.isHidden = true
			}
		}
	}
	
	func setup(title: String) {
		[titleLabel, lineView].forEach { self.addSubview($0) }
		if isFirstCell {
			lineView.isHidden = false
		} else {
			lineView.isHidden = true
		}
		titleLabel.text = title
		titleLabel.textAlignment = .center
		titleLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalToSuperview()
			$0.leading.trailing.equalToSuperview()
			$0.bottom.equalToSuperview().inset(2.5)
		}
		
		lineView.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom)
			$0.leading.trailing.equalToSuperview()
			$0.bottom.equalToSuperview()
		}
	}
}
