//
//  MapListViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/09.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class MapListViewController: UIViewController {
	private let disposeBag = DisposeBag()
	private let myDevice = UIScreen.getDevice()
	
	private lazy var mapListView = MapListView()
	private lazy var closeButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "xmark")?.withTintColor(UIColor.black, renderingMode: .alwaysOriginal), for: .normal)
		button.imageView?.contentMode = .scaleAspectFit
		button.imageEdgeInsets = UIEdgeInsets(top: 22, left: 22, bottom: 22, right: 22)
		return button
	}()
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		layout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func bind(_ viewModel: MapViewModel, _ day: Int, _ location: Location) {
		mapListView.bind(viewModel, day, location)
		
		closeButton.rx.tap
			.bind(onNext: {
				self.dismiss(animated: true)
			})
			.disposed(by: disposeBag)
	}
	
	func layout() {
		[mapListView, closeButton].forEach { view.addSubview($0) }
		closeButton.snp.makeConstraints {
			$0.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
		}
		mapListView.snp.makeConstraints {
			$0.top.equalTo(closeButton.snp.bottom).offset(8)
			$0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
		}
	}
}
