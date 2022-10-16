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
	private var isFirstLoad = true
	
	init() {
		fetchLoadData()
	}
	
	func fetchLoadData() {
		Task {
			do {
				albumDatas.removeAll()
				let datas = try await client.fetchDiaryAlbumData(myUID)
				for data in datas {
					var images = [UIImage]()
					for url in data.imageURLs ?? [] {
						try await images.append(FirebaseStorageManager.downloadImage(urlString: url))
					}
					albumDatas.append(AlbumData(diaryUUID: data.diaryUUID, diaryName: data.diaryName, imageURLs: data.imageURLs, images: images))
				}
			} catch {
				print(error)
			}
		}
	}
}
