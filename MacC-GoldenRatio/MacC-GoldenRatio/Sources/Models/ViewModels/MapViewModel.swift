//
//  MapViewModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/09.
//
import RxCocoa
import RxSwift
import UIKit

struct MapViewModel {
	private let disposeBag = DisposeBag()

	let mapDiaryData = PublishSubject<Diary>()

	var mapData = BehaviorRelay<[MapData]>(value: [])
	var mapAnnotations = BehaviorRelay<[[CustomAnnotation]]>(value: [])
	var mapCellData = BehaviorRelay<[Location]>(value: [])
	var selectDay = BehaviorRelay<Int>(value: 0)

	init(_ model: MapModel = MapModel()) {
		mapDiaryData
			.map(model.convertDiaryToMapData)
			.bind(to: mapData)
			.disposed(by: disposeBag)
		
		mapData
			.map(model.convertMapDatasToAnnotations)
			.bind(to: mapAnnotations)
			.disposed(by: disposeBag)
		
		selectDay
			.map(fetchMapCellData)
			.bind(to: mapCellData)
			.disposed(by: disposeBag)
	}
	
	func fetchMapCellData(_ day: Int) -> [Location] {
		 return mapData
			.value
			.filter { $0.day == day }
			.first?.locations ?? []
	}
}
