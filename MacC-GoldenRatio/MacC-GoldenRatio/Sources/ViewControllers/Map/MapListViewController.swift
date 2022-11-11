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
	
	private lazy var segmentedControlView: SegmentedControlView = {
		let segmentedControlView = SegmentedControlView()
		segmentedControlView.delegate = self
		segmentedControlView.translatesAutoresizingMaskIntoConstraints = false
		return segmentedControlView
	}()
	
	let viewModel: MapViewModel
	let day: Int
	let selectedLocation: Location
	
	init(viewMdoel: MapViewModel, day: Int, selectedLocation: Location) {
		self.viewModel = viewMdoel
		self.day = day
		self.selectedLocation = selectedLocation
		super.init(nibName: nil, bundle: nil)
		layout()
		mapListView.bind(viewModel, MapModel(), day, selectedLocation)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	func configureSegmentedControl(titles: [String]) {
		let config = SegmentedControlConfiguration(titles: titles,
												   font: UIFont(name: "EF_Diary", size: 20)!,
												   spacing: 10,
												   selectedLabelColor: .black,
												   unselectedLabelColor: .placeholderText,
												   selectedLineColor: .black,
												   day: day-1)
		segmentedControlView.configure(config)
	}
	
	func bind(_ viewModel: MapViewModel,_ day: Int,_ selectedLocation: Location?) {
		mapListView.delegate = nil
		mapListView.dataSource = nil
		mapListView.bind(viewModel, MapModel(), day, selectedLocation)
	}
	
	func layout() {
		view.backgroundColor = .white
		[mapListView, segmentedControlView].forEach { view.addSubview($0) }
		segmentedControlView.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(30)
			$0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
			$0.bottom.equalTo(view.safeAreaLayoutGuide).inset(350)
		}
		mapListView.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(80)
			$0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
		}
	}
}

extension MapListViewController: SegmentedControlViewDelegate {
	
	func segmentedControl(didChange index: Int) {
		bind(viewModel, index+1, nil)
	}

}
