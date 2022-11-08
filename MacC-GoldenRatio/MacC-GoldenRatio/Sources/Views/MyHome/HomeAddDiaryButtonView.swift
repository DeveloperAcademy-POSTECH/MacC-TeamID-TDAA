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

final class HomeAddDiaryButtonView: UIButton {
	let myDevice = UIScreen.getDevice()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupViews() {
		self.setImage(UIImage(named: "plusButton"), for: .normal)
	}
}
