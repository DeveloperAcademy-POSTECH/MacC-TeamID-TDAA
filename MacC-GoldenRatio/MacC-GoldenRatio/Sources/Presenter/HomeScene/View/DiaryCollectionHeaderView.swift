//
//  DiaryCollectionHeaderView.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import RxSwift
import SnapKit
import UIKit

final class DiaryCollectionHeaderView: UIView {
	
	private lazy var titleLabel: UILabel = {
		let label =  UILabel()
		label.font = .title1
        label.text = "LzHomeTitleLabel".localized
		label.textColor = UIColor.buttonColor
		
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupViews() {
		addSubview(titleLabel)
		
		titleLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(Layout.tabBarTitleLabelLeading)
			$0.top.equalToSuperview().offset(Layout.tabBarTitleLabelTop)
		}
	}
}
