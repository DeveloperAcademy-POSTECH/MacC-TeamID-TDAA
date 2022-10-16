//
//  MyPlaceViewModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/12.
//

import FirebaseFirestore
import FirebaseAuth
import UIKit

// TODO: 수정 예정
class MyPlaceViewModel {
	@Published var mapDatas = [MapData]()
	private let client = FirestoreClient()
	private var myUID = Auth.auth().currentUser?.uid ?? ""
	
	init() {
		fetchLoadData()
	}
	
	func fetchLoadData() {
		Task {
			do {
				mapDatas.removeAll()
				self.mapDatas = try await client.fetchDiaryMapData(myUID)
			} catch {
				print(error)
			}
		}
	}
}
