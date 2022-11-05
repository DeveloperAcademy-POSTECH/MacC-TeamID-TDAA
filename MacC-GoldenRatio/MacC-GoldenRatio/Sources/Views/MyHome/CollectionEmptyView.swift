//
//  DiaryCollectionEmptyView.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/06.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class DiaryCollectionEmptyView: UIView {
	let myDevice = UIScreen.getDevice()
	
	private lazy var textLabel: UILabel = {
		let label = UILabel()
		label.text = "다이어리를 추가해주세요."
		label.font = myDevice.collectionBackgoundViewFont
		label.textColor = UIColor.calendarWeeklyGrayColor
		label.textAlignment = .center
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
		addSubview(textLabel)
		textLabel.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}
