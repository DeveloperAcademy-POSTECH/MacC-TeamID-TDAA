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
		return segmentedControlView
	}()
	
	let viewModel: MapViewModel
	let selectedLocation: Location
	
	init(viewMdoel: MapViewModel, selectedLocation: Location) {
		self.viewModel = viewMdoel
		self.selectedLocation = selectedLocation
		super.init(nibName: nil, bundle: nil)
		layout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	func configureSegmentedControl(titles: [String]) {
		let config = SegmentedControlConfiguration(titles: titles,
												   font: UIFont(name: "EF_Diary", size: 20)!,
												   spacing: 10,
												   selectedLabelColor: .black,
												   unselectedLabelColor: UIColor(named: "separatorColor") ?? .placeholderText,
												   selectedLineColor: .black,
												   day: viewModel.selectDay.value-1)
		segmentedControlView.configure(config)
	}
	
	func bind(_ viewModel: MapViewModel, _ selectedLocation: Location?) {
		mapListView.bind(viewModel, MapModel(), selectedLocation)
		
		mapListView.rx.itemSelected
			.subscribe(onNext: { indexPath in
				print(indexPath.row)
			})
			.disposed(by: self.disposeBag)
	}
	
	func layout() {
		view.backgroundColor = .white
		[mapListView, segmentedControlView].forEach { view.addSubview($0) }
		segmentedControlView.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(30)
			$0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
			$0.height.equalTo(40)
		}
		mapListView.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(80)
			$0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
		}
	}
}

extension MapListViewController: SegmentedControlViewDelegate {
	func segmentedControl(didChange index: Int) {
		Observable.just(index+1)
			.bind(to: viewModel.selectDay)
			.disposed(by: disposeBag)
	}
}
