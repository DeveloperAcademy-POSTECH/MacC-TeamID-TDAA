//
//  AlbumCollectionViewModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/08.
//

import RxCocoa
import RxSwift
import UIKit

struct AlbumCollectionViewModel {
	private let disposeBag = DisposeBag()
	
	let collectionDiaryData = PublishSubject<Diary>()
    let collectionDiaryDataWithDay = PublishSubject<(Diary, Int)>()
    
	var collectionCellData = BehaviorRelay<[UIImage]>(value: [])
	
	
	init() {
		let collectionAlbumData = collectionDiaryData
			.map(convertDiaryToAlbumData)
		
		collectionAlbumData
			.map(fetchLoadData)
			.bind(to: collectionCellData)
			.disposed(by: disposeBag)
        
        let collectionAlbumDataWithDay = collectionDiaryDataWithDay
            .map(convertDiaryToAlbumDataWithDay)
        
        collectionAlbumDataWithDay
            .map(fetchLoadData)
            .bind(to: collectionCellData)
            .disposed(by: disposeBag)
	}
	
	func convertDiaryToAlbumData(_ diary: Diary) -> AlbumData {
		var imageURLs = [String]()
		for pages in diary.diaryPages {
			for page in pages.pages {
				for item in page.items {
					if item.itemType == .image {
						imageURLs.append(item.contents.first ?? "")
					}
				}
			}
		}
		return AlbumData(diaryUUID: diary.diaryUUID, diaryName: diary.diaryName, imageURLs: imageURLs, images: nil)
	}
	
    func convertDiaryToAlbumDataWithDay(_ diary: Diary, selectedDay: Int) -> AlbumData {
        var imageURLs = [String]()
        let pages = diary.diaryPages[selectedDay-1]
        
        for page in pages.pages {
            for item in page.items {
                if item.itemType == .image {
                    imageURLs.append(item.contents.first ?? "")
                }
            }
        }
        return AlbumData(diaryUUID: diary.diaryUUID, diaryName: diary.diaryName, imageURLs: imageURLs, images: nil)
    }
    
	func fetchLoadData(_ albumData: AlbumData) -> [UIImage] {
		var images = [UIImage]()
		for url in albumData.imageURLs ?? [] {
            if url.verifyUrl() {
                if let image = ImageManager.shared.searchImage(urlString: url){
                    images.append(image)
                } else {
                    FirebaseStorageManager.downloadImage(urlString: url, completion: {
                        let image = $0 ?? UIImage()
                        ImageManager.shared.cacheImage(urlString: url, image: image)
                        images.append(image)
                    })
                }
            }
		}
		return images
	}
}
