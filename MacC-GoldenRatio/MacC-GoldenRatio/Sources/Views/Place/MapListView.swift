//
//  MapListView.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/09.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class MapListView: UICollectionView {
	private let disposeBag = DisposeBag()
	private let myDevice = UIScreen.getDevice()

	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		let layout = UICollectionViewFlowLayout()
		super.init(frame: frame, collectionViewLayout: layout)
		self.collectionViewLayout = layout
		self.showsVerticalScrollIndicator = false
		self.backgroundColor = UIColor.clear
		self.register(MapListCell.self, forCellWithReuseIdentifier: "MapListCell")
		self.rx.setDelegate(self)
					.disposed(by: disposeBag)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func bind(_ viewModel: MapViewModel, _ day: Int, _ location: Location) {
		viewModel.mapData
			.map {
				return viewModel.convertMapDatasToLocations($0, day: day).locations
			}
			.bind(to: self.rx.items(cellIdentifier: "MapListCell", cellType: MapListCell.self)) { index, data, cell in
				cell.setup(location: data)
			}
			.disposed(by: disposeBag)
	}
}

extension MapListView: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.bounds.width-40, height: 100)
	}
}
