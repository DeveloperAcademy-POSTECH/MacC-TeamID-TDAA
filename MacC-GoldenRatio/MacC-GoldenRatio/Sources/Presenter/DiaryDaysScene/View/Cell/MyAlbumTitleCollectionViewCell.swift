//
//  MyAlbumTitleCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/13.
//

import SnapKit
import UIKit

class MyAlbumTitleCollectionViewCell: UICollectionViewCell {
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
				titleLabel.textColor = .black
			} else {
				lineView.isHidden = true
				titleLabel.textColor = .gray400
			}
		}
	}
	
	func setup(title: String, isFirstCell: Bool) {
		[titleLabel, lineView].forEach { self.addSubview($0) }
		if isFirstCell {
			lineView.isHidden = false
			titleLabel.textColor = .black
		} else {
			lineView.isHidden = true
			titleLabel.textColor = .gray400
		}
		titleLabel.text = title
		titleLabel.textAlignment = .center
		titleLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.leading.trailing.equalToSuperview()
			$0.bottom.equalToSuperview().inset(5)
		}
		
		lineView.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).offset(2)
			$0.leading.trailing.bottom.equalToSuperview()
		}
	}
}
