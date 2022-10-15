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
	@Published var isInitializing = true {
		didSet {
			if isInitializing {
				LoadingIndicator.showLoading(loadingText: "다이어리를 불러오는 중입니다.")
			} else {
				LoadingIndicator.hideLoading()
			}
		}
	}
	
	private let client = FirestoreClient()
	private var myUID = Auth.auth().currentUser?.uid ?? ""
	
	init() {
		fetchLoadData()
	}
	
	func fetchLoadData() {
		Task {
			do {
				self.isInitializing = true
				albumDatas.removeAll()
				let datas = try await client.fetchDiaryAlbumData(myUID)
				for data in datas {
					var images = [UIImage]()
					for url in data.imageURLs ?? [] {
						try await images.append(FirebaseStorageManager.downloadImage(urlString: url))
					}
					albumDatas.append(AlbumData(diaryUUID: data.diaryUUID, diaryName: data.diaryName, imageURLs: data.imageURLs, images: images))
				}
				self.isInitializing = false
			} catch {
				print(error)
			}
		}
	}
}
