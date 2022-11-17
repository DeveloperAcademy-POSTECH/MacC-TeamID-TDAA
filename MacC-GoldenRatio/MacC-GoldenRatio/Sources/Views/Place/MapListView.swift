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
		let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
		swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
		self.addGestureRecognizer(swipeLeft)
		let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
		swipeRight.direction = UISwipeGestureRecognizer.Direction.right
		self.addGestureRecognizer(swipeRight)
		self.collectionViewLayout = layout
		self.showsVerticalScrollIndicator = false
		self.backgroundColor = UIColor.clear
		self.register(MapListCell.self, forCellWithReuseIdentifier: "MapListCell")
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func bind(_ viewModel: MapViewModel,_ model: MapModel,_ day: Int,_ selectedLocation: Location?) {
		self.rx.setDelegate(self)
			.disposed(by: disposeBag)
		viewModel.mapData
			.map {
				return model.convertMapDatasToLocations($0, day: day).locations
			}
			.map {
				return selectedLocation != nil ? model.changeIndex($0, selectedLocation: selectedLocation!) : $0
			}
			.bind(to: self.rx.items(cellIdentifier: "MapListCell", cellType: MapListCell.self)) { index, data, cell in
				cell.setup(location: data)
			}
			.disposed(by: disposeBag)
	}
	
	@objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
		if let swipeGesture = gesture as? UISwipeGestureRecognizer {
			switch swipeGesture.direction {
			case UISwipeGestureRecognizer.Direction.left:
				NotificationCenter.default.post(name: .mapListSwipeLeft, object: nil)
			case UISwipeGestureRecognizer.Direction.right:
				NotificationCenter.default.post(name: .mapListSwipeRight, object: nil)
			default:
				break
			}
		}
	}
}

extension MapListView: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.bounds.width-40, height: 110)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 20
	}
}
