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

	init(_ model: MapModel = MapModel()) {
		mapDiaryData
			.map(model.convertDiaryToMapData)
			.bind(to: mapData)
			.disposed(by: disposeBag)
	}
}
