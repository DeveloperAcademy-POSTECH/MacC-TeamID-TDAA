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

	init() {
		mapDiaryData
			.map(convertDiaryToMapData)
			.bind(to: mapData)
			.disposed(by: disposeBag)
	}

	func convertDiaryToMapData(_ diary: Diary) -> [MapData] {
		var resultData = [MapData]()
		var locations = [Location]()
		for (index, pages) in diary.diaryPages.enumerated() {
			for page in pages.pages {
				for item in page.items {
					if item.itemType == .location {
						let name = item.contents[0]
						let address = item.contents[1]
						let latitude = Double(item.contents[2]) ?? 0
						let longitude = Double(item.contents[3]) ?? 0
						if item.contents.count == 4 {
							locations.append(Location(locationName: name, locationAddress: address, locationCoordinate: [latitude, longitude]))
						}
					}
				}
			}
			resultData.append(MapData(day: index+1, locations: locations))
			locations.removeAll()
		}
		return resultData
	}
}
