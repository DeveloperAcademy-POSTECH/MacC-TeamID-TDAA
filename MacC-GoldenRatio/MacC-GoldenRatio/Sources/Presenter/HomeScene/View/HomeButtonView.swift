//
//  AddDiaryButton.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/04.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class HomeButtonView: UIButton {
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupViews(_ image: UIImage?) {
		self.setImage(image, for: .normal)
	}
}
