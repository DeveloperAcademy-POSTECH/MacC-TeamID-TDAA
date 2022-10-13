//
//  MyAlbumViewModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/13.
//

import Combine
import Firebase

class MyAlbumViewModel {
	@Published var albumDatas = [AlbumData]()
	private let client = FirestoreClient()
	private var myUID = Auth.auth().currentUser?.uid ?? ""
	
	init() {
		fetchLoadData()
	}
	
	func fetchLoadData() {
		Task {
			do {
				self.albumDatas = try await client.fetchDiaryAlbumData(myUID)
			} catch {
				print(error)
			}
		}
	}
}
