//
//  MyPlaceViewModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/12.
//

import FirebaseFirestore
import UIKit

// TODO: 수정 예정
class MyPlaceViewModel {
	@Published var mapDatas = [MapData]()
	private let client = FirestoreClient()
	var userUid: String
	
	init(userUid: String) {
		self.userUid = userUid
		fetchLoadData(userUid)
	}
	
	func fetchLoadData(_ uid: String) {
		Task {
			do {
				self.mapDatas = try await client.fetchDiaryMapData(uid)
			} catch {
				print(error)
			}
		}
	}
}
