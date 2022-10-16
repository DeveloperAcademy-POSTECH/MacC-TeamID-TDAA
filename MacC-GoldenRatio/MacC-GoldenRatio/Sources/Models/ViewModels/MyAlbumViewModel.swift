//
//  MyAlbumViewModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/13.
//

import Combine
import Firebase
import UIKit

class MyAlbumViewModel {
	@Published var albumDatas = [AlbumData]()
	
	private let client = FirestoreClient()
	private var myUID = Auth.auth().currentUser?.uid ?? ""
	var fetchDatas = [AlbumData]()
	private var isFirstLoad = true
	
	init() {
		fetchLoadData()
	}
	
	func fetchLoadData() {
		self.fetchDatas.removeAll()
		Task {
			do {
				let datas = try await self.client.fetchDiaryAlbumData(self.myUID)
				for data in datas {
					var images = [UIImage]()
					for url in data.imageURLs ?? [] {
						try await images.append(FirebaseStorageManager.downloadImage(urlString: url))
					}
					self.fetchDatas.append(AlbumData(diaryUUID: data.diaryUUID, diaryName: data.diaryName, imageURLs: data.imageURLs, images: images))
				}
				albumDatas = fetchDatas
			} catch {
				print(error)
			}
		}
	}
}
