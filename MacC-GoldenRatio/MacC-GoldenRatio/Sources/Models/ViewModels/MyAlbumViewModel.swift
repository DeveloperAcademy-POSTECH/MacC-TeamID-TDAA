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
		Task {
			do {
				let datas = try await self.client.fetchDiaryAlbumData(self.myUID)
				for data in datas {
					var images = [UIImage]()
					for url in data.imageURLs ?? [] {
                        
                        if let image = ImageManager.shared.searchImage(url: url){
                            images.append(image)
                        } else {
                            let image = try await FirebaseStorageManager.downloadImage(urlString: url)
                            ImageManager.shared.cacheImage(url: url, image: image)
                            images.append(image)
                        }
					}
					var isEqual = false
					fetchDatas.forEach { album in
						if album.diaryUUID == data.diaryUUID {
							isEqual = true
						}
					}
					if !isEqual {
						fetchDatas.append(AlbumData(diaryUUID: data.diaryUUID, diaryName: data.diaryName, imageURLs: data.imageURLs, images: images))
					}
				}
				self.albumDatas = self.fetchDatas
				print(fetchDatas)
			} catch {
				print(error)
			}
		}
		self.fetchDatas.removeAll()
	}
}
