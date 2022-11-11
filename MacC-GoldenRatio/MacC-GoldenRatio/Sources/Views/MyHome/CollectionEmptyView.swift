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

final class CollectionEmptyView: UIView {
	private let myDevice = UIScreen.getDevice()
	
	private lazy var textLabel: UILabel = {
		let label = UILabel()
		label.font = myDevice.collectionBackgoundViewFont
		label.textColor = UIColor.calendarWeeklyGrayColor
		label.textAlignment = .center
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupViews(text: String) {
		textLabel.text = text
		addSubview(textLabel)
		textLabel.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}
