//
//  MapModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/11.
//

struct MapModel {
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
						let category = item.contents.count == 5 ? item.contents[4] : ""
						if item.contents.count == 4 {
							locations.append(Location(locationName: name, locationAddress: address, locationCoordinate: [latitude, longitude], locationCategory: category))
						}
					}
				}
			}
			resultData.append(MapData(day: index+1, diaryLocation: diary.diaryLocation, locations: locations))
			locations.removeAll()
		}
		return resultData
	}
	
	func convertMapDatasToLocations(_ mapDatas: [MapData], day: Int) -> MapData {
		return mapDatas
			.filter { $0.day == day }
			.first ?? MapData(day: 0, diaryLocation: Location(locationName: "", locationAddress: "", locationCoordinate: [], locationCategory: ""), locations: [])
	}
	
	func changeIndex(_ locations: [Location], selectedLocation: Location) -> [Location] {
		var resultLocations = locations
			.filter {
				return !($0.locationAddress == selectedLocation.locationAddress)
			}
		resultLocations.insert(selectedLocation, at: 0)
		return resultLocations
	}
}
