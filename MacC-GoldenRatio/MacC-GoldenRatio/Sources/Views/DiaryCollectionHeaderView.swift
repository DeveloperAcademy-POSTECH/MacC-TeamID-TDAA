//
//  DiaryCollectionHeaderView.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import UIKit
import SnapKit

final class DiaryCollectionHeaderView: UICollectionReusableView {
	private lazy var titleLabel: UILabel = {
		let label =  UILabel()
		label.text = "다이어리"
		label.font = .systemFont(ofSize: UIScreen.getDevice().MyDiariesViewTitleFontSize, weight: .black)
		label.textColor = .label
		
		return label
	}()
	
	func setupViews() {
		addSubview(titleLabel)
		
		titleLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(UIScreen.getDevice().MyDiariesViewTitleLabelLeadingPadding)
			$0.top.equalToSuperview().offset(UIScreen.getDevice().MyDiariesViewTitleLabelTopPadding)
		}
	}
}
